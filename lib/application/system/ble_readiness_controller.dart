import 'dart:async';
import 'dart:io' show Platform;

import 'package:app_settings/app_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart' as handler;

/// Tracks whether Bluetooth permissions and radios are ready for BLE features.
class BleReadinessController extends ChangeNotifier {
  BleReadinessController({BleSystemAccess? systemAccess})
    : _systemAccess = systemAccess ?? const BleSystemAccess() {
    _bootstrap();
  }

  final BleSystemAccess _systemAccess;
  StreamSubscription<BleRadioState>? _radioSubscription;

  BleReadinessSnapshot _snapshot = BleReadinessSnapshot.initial();

  BleReadinessSnapshot get snapshot => _snapshot;

  Future<void> _bootstrap() async {
    await _loadStatus(requestPermissions: false);
    _radioSubscription = _systemAccess.watchRadioState().listen((state) {
      _updateSnapshot(_snapshot.copyWith(radioState: state));
    });
  }

  Future<void> refresh() async {
    await _loadStatus(requestPermissions: false);
  }

  Future<void> requestPermissions() async {
    if (!_systemAccess.platformChecksSupported) return;
    _updateSnapshot(_snapshot.copyWith(isRequesting: true));
    await _loadStatus(requestPermissions: true);
  }

  Future<void> openBluetoothSettings() async {
    await _systemAccess.openBluetoothSettings();
  }

  Future<void> openSystemSettings() async {
    await _systemAccess.openSystemSettings();
  }

  void _updateSnapshot(BleReadinessSnapshot next) {
    _snapshot = next;
    notifyListeners();
  }

  Future<void> _loadStatus({required bool requestPermissions}) async {
    if (!_systemAccess.platformChecksSupported) {
      _updateSnapshot(
        _snapshot.copyWith(
          bluetoothPermission: BlePermissionState.granted,
          locationPermission: BlePermissionState.granted,
          locationRequired: false,
          radioState: BleRadioState.on,
          isRequesting: false,
          lastUpdated: DateTime.now(),
        ),
      );
      return;
    }

    try {
      final BleSystemAccessResult result = await _systemAccess.readStatus(
        requestPermissions: requestPermissions,
      );
      final BleRadioState radioState = await _systemAccess.currentRadioState();
      _updateSnapshot(
        _snapshot.copyWith(
          bluetoothPermission: result.bluetoothPermission,
          locationPermission: result.locationPermission,
          locationRequired: result.locationRequired,
          radioState: radioState,
          isRequesting: false,
          lastUpdated: DateTime.now(),
        ),
      );
    } catch (_) {
      _updateSnapshot(_snapshot.copyWith(isRequesting: false));
    }
  }

  @override
  void dispose() {
    _radioSubscription?.cancel();
    super.dispose();
  }
}

class BleReadinessSnapshot {
  final BlePermissionState bluetoothPermission;
  final BlePermissionState locationPermission;
  final bool locationRequired;
  final BleRadioState radioState;
  final bool isRequesting;
  final DateTime? lastUpdated;

  const BleReadinessSnapshot({
    required this.bluetoothPermission,
    required this.locationPermission,
    required this.locationRequired,
    required this.radioState,
    required this.isRequesting,
    required this.lastUpdated,
  });

  factory BleReadinessSnapshot.initial() {
    return const BleReadinessSnapshot(
      bluetoothPermission: BlePermissionState.unknown,
      locationPermission: BlePermissionState.unknown,
      locationRequired: false,
      radioState: BleRadioState.unknown,
      isRequesting: false,
      lastUpdated: null,
    );
  }

  bool get permissionsGranted {
    final bool bluetoothGranted =
        bluetoothPermission == BlePermissionState.granted;
    final bool locationGranted =
        !locationRequired || locationPermission == BlePermissionState.granted;
    return bluetoothGranted && locationGranted;
  }

  bool get hasPermanentDenial {
    if (bluetoothPermission == BlePermissionState.permanentlyDenied) {
      return true;
    }
    if (locationRequired &&
        locationPermission == BlePermissionState.permanentlyDenied) {
      return true;
    }
    return false;
  }

  bool get isReady => permissionsGranted && radioState == BleRadioState.on;

  BleBlockingReason get blockingReason {
    if (isReady) return BleBlockingReason.none;
    if (locationRequired && locationPermission == BlePermissionState.denied) {
      return BleBlockingReason.locationRequired;
    }
    if (hasPermanentDenial) {
      return BleBlockingReason.permissionPermanentlyDenied;
    }
    if (!permissionsGranted) {
      return BleBlockingReason.permissionsNeeded;
    }
    switch (radioState) {
      case BleRadioState.off:
        return BleBlockingReason.bluetoothOff;
      case BleRadioState.unauthorized:
        return BleBlockingReason.permissionsNeeded;
      case BleRadioState.unsupported:
        return BleBlockingReason.bluetoothRestricted;
      default:
        return BleBlockingReason.none;
    }
  }

  BleReadinessSnapshot copyWith({
    BlePermissionState? bluetoothPermission,
    BlePermissionState? locationPermission,
    bool? locationRequired,
    BleRadioState? radioState,
    bool? isRequesting,
    DateTime? lastUpdated,
  }) {
    return BleReadinessSnapshot(
      bluetoothPermission: bluetoothPermission ?? this.bluetoothPermission,
      locationPermission: locationPermission ?? this.locationPermission,
      locationRequired: locationRequired ?? this.locationRequired,
      radioState: radioState ?? this.radioState,
      isRequesting: isRequesting ?? this.isRequesting,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

enum BlePermissionState {
  unknown,
  granted,
  denied,
  permanentlyDenied,
  restricted,
}

enum BleRadioState { unknown, on, off, turningOn, unauthorized, unsupported }

enum BleBlockingReason {
  none,
  permissionsNeeded,
  permissionPermanentlyDenied,
  locationRequired,
  bluetoothOff,
  bluetoothRestricted,
}

class BleSystemAccessResult {
  final BlePermissionState bluetoothPermission;
  final BlePermissionState locationPermission;
  final bool locationRequired;

  const BleSystemAccessResult({
    required this.bluetoothPermission,
    required this.locationPermission,
    required this.locationRequired,
  });
}

class BleSystemAccess {
  const BleSystemAccess();

  bool get platformChecksSupported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  Stream<BleRadioState> watchRadioState() {
    if (!platformChecksSupported) {
      return const Stream.empty();
    }
    return FlutterBluePlus.adapterState.map(_mapAdapterState);
  }

  Future<BleRadioState> currentRadioState() async {
    if (!platformChecksSupported) {
      return BleRadioState.on;
    }
    try {
      final BluetoothAdapterState state =
          await FlutterBluePlus.adapterState.first;
      return _mapAdapterState(state);
    } catch (_) {
      return BleRadioState.unknown;
    }
  }

  Future<void> openBluetoothSettings() async {
    if (!platformChecksSupported) return;
    try {
      await AppSettings.openAppSettings(type: AppSettingsType.bluetooth);
    } catch (_) {
      // ignore - best effort
    }
  }

  Future<void> openSystemSettings() async {
    if (!platformChecksSupported) return;
    try {
      await handler.openAppSettings();
    } catch (_) {
      try {
        await AppSettings.openAppSettings();
      } catch (_) {}
    }
  }

  Future<BleSystemAccessResult> readStatus({
    required bool requestPermissions,
  }) async {
    if (!platformChecksSupported) {
      return const BleSystemAccessResult(
        bluetoothPermission: BlePermissionState.granted,
        locationPermission: BlePermissionState.granted,
        locationRequired: false,
      );
    }

    if (Platform.isAndroid) {
      return _readAndroidStatus(requestPermissions: requestPermissions);
    }
    return _readIosStatus(requestPermissions: requestPermissions);
  }

  Future<BleSystemAccessResult> _readAndroidStatus({
    required bool requestPermissions,
  }) async {
    final List<handler.PermissionStatus> rawStatuses = await Future.wait([
      _resolve(handler.Permission.bluetoothScan, requestPermissions),
      _resolve(handler.Permission.bluetoothConnect, requestPermissions),
    ]);

    final BlePermissionState bluetoothState = _collapse(rawStatuses);

    final int? majorVersion = _androidMajorVersion();
    final bool requiresLocation = majorVersion == null
        ? true
        : majorVersion < 12;

    handler.PermissionStatus locationStatus = handler.PermissionStatus.granted;
    if (requiresLocation) {
      locationStatus = await _resolve(
        handler.Permission.locationWhenInUse,
        requestPermissions,
      );
    }

    return BleSystemAccessResult(
      bluetoothPermission: bluetoothState,
      locationPermission: requiresLocation
          ? _mapStatus(locationStatus)
          : BlePermissionState.granted,
      locationRequired: requiresLocation,
    );
  }

  Future<BleSystemAccessResult> _readIosStatus({
    required bool requestPermissions,
  }) async {
    final handler.PermissionStatus bluetoothStatus = await _resolve(
      handler.Permission.bluetooth,
      requestPermissions,
    );
    final handler.PermissionStatus locationStatus = await _resolve(
      handler.Permission.locationWhenInUse,
      requestPermissions,
    );

    return BleSystemAccessResult(
      bluetoothPermission: _mapStatus(bluetoothStatus),
      locationPermission: _mapStatus(locationStatus),
      locationRequired: false,
    );
  }

  Future<handler.PermissionStatus> _resolve(
    handler.Permission permission,
    bool request,
  ) async {
    try {
      return request ? await permission.request() : await permission.status;
    } catch (_) {
      return handler.PermissionStatus.denied;
    }
  }

  BlePermissionState _collapse(List<handler.PermissionStatus> statuses) {
    BlePermissionState result = BlePermissionState.granted;
    for (final status in statuses) {
      final BlePermissionState candidate = _mapStatus(status);
      if (_priority(candidate) > _priority(result)) {
        result = candidate;
      }
    }
    return result;
  }

  BlePermissionState _mapStatus(handler.PermissionStatus status) {
    if (status.isPermanentlyDenied) return BlePermissionState.permanentlyDenied;
    if (status.isRestricted) return BlePermissionState.restricted;
    if (status.isDenied) return BlePermissionState.denied;
    if (status.isLimited) return BlePermissionState.granted;
    if (status.isProvisional) return BlePermissionState.granted;
    if (status.isGranted) return BlePermissionState.granted;
    return BlePermissionState.unknown;
  }

  int _priority(BlePermissionState state) {
    switch (state) {
      case BlePermissionState.permanentlyDenied:
        return 4;
      case BlePermissionState.denied:
        return 3;
      case BlePermissionState.restricted:
        return 2;
      case BlePermissionState.unknown:
        return 1;
      case BlePermissionState.granted:
        return 0;
    }
  }

  BleRadioState _mapAdapterState(BluetoothAdapterState state) {
    switch (state) {
      case BluetoothAdapterState.on:
        return BleRadioState.on;
      case BluetoothAdapterState.off:
        return BleRadioState.off;
      case BluetoothAdapterState.turningOn:
        return BleRadioState.turningOn;
      case BluetoothAdapterState.turningOff:
        return BleRadioState.off;
      case BluetoothAdapterState.unauthorized:
        return BleRadioState.unauthorized;
      case BluetoothAdapterState.unavailable:
        return BleRadioState.unsupported;
      case BluetoothAdapterState.unknown:
        return BleRadioState.unknown;
    }
  }

  int? _androidMajorVersion() {
    final String version = Platform.operatingSystemVersion;
    final RegExpMatch? match = RegExp(r'Android\s+(\d+)').firstMatch(version);
    if (match == null) {
      return null;
    }
    return int.tryParse(match.group(1) ?? '');
  }
}
