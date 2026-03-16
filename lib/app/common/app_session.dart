library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../domain/doser_dosing/pump_head.dart';
import '../../domain/led_lighting/led_state.dart';
import '../../domain/sink/sink.dart';
import '../device/device_snapshot.dart';
import '../../debug/runtime_logger.dart';
import 'app_context.dart';

/// Reactive view of global session state (connection, guards, etc.).
class AppSession extends ChangeNotifier with WidgetsBindingObserver {
  final AppContext context;
  StreamSubscription<List<DeviceSnapshot>>? _scanSubscription;
  StreamSubscription<List<DeviceSnapshot>>? _savedSubscription;
  StreamSubscription<List<Sink>>? _sinkSubscription;
  StreamSubscription<List<PumpHead>>? _pumpHeadSubscription;
  StreamSubscription<LedState>? _ledStateSubscription;
  StreamSubscription<bool>? _isReadySubscription;

  String? _activeDeviceId;
  String? _activeDeviceName;
  List<DeviceSnapshot> _savedDevices = const [];
  List<Sink> _sinks = const [];
  List<PumpHead> _pumpHeads = const [];
  LedState? _ledState;

  AppSession({required this.context}) {
    _scanSubscription = context.scanDevicesUseCase
        .observe()
        .listen((devices) => _onDevices(devices));
    _savedSubscription = context.deviceRepository
        .observeSavedDevices()
        .map(
          (items) => items.map(DeviceSnapshot.fromMap).toList(growable: false),
        )
        .listen((devices) => _onSavedDevices(devices));
    _sinkSubscription = context.sinkRepository.observeSinks().listen(_onSinks);
    _sinks = context.sinkRepository.getCurrentSinks();
    _isReadySubscription = context.currentDeviceSession.isReadyStream.listen((
      _,
    ) {
      notifyListeners();
    });
    WidgetsBinding.instance.addObserver(this);
  }

  bool get isBleConnected => _activeDeviceId != null;
  bool get isReady => context.currentDeviceSession.isReady;
  String? get activeDeviceId => _activeDeviceId;
  String? get activeDeviceName => _activeDeviceName;
  bool get isAssigned => _activeDeviceId != null;
  String? get activeDeviceSinkId {
    if (_activeDeviceId == null) {
      return null;
    }
    for (final device in _savedDevices) {
      if (device.id == _activeDeviceId) {
        return device.sinkId;
      }
    }
    return null;
  }
  String? get activeDeviceSinkName {
    final String? sinkId = activeDeviceSinkId;
    if (sinkId == null) {
      return null;
    }
    for (final sink in _sinks) {
      if (sink.id == sinkId) {
        return sink.name;
      }
    }
    return null;
  }

  /// Set the active device manually.
  ///
  /// PARITY: Matches reef-b-app's Intent.putExtra("device_id", ...) behavior.
  /// This allows setting the active device when navigating to a device page
  /// even if the device is not currently connected via BLE.
  ///
  /// Lifecycle: Calls [CurrentDeviceSession.switchTo] to sync session state.
  /// This resets isReady to false until [InitializeDeviceUseCase] runs on BLE connect.
  void setActiveDevice(String deviceId) {
    // Find device name from saved devices
    String? deviceName;
    for (final device in _savedDevices) {
      if (device.id == deviceId) {
        deviceName = device.name;
        break;
      }
    }

    if (_activeDeviceId == deviceId && _activeDeviceName == deviceName) {
      return;
    }

    // KC-A-FINAL: Sync with CurrentDeviceSession. Switching device resets isReady
    // to false. No stale ready state persists after device switch.
    context.currentDeviceSession.switchTo(deviceId);

    _activeDeviceId = deviceId;
    _activeDeviceName = deviceName;
    _resubscribePumpHeads(_activeDeviceId);
    _resubscribeLedState(_activeDeviceId);
    notifyListeners();
  }

  /// Override the active device name without affecting the ID.
  void setActiveDeviceName(String? name) {
    if (_activeDeviceName == name) {
      return;
    }
    _activeDeviceName = name;
    notifyListeners();
  }

  Sink get defaultSink =>
      _defaultSink ??
      Sink.defaultSink(
        _savedDevices.map((device) => device.id).toList(growable: false),
      );
  List<DeviceSnapshot> get devicesInDefaultSink {
    final Sink? sink = _defaultSink;
    if (sink == null) {
      return List.unmodifiable(_savedDevices);
    }
    final Map<String, DeviceSnapshot> lookup = <String, DeviceSnapshot>{
      for (final DeviceSnapshot device in _savedDevices) device.id: device,
    };
    final List<DeviceSnapshot> ordered = <DeviceSnapshot>[];
    for (final String id in sink.deviceIds) {
      final DeviceSnapshot? device = lookup[id];
      if (device != null) {
        ordered.add(device);
      }
    }
    return List.unmodifiable(ordered);
  }

  List<DeviceSnapshot> get savedDevices => List.unmodifiable(_savedDevices);
  List<PumpHead> get pumpHeads => List.unmodifiable(_pumpHeads);
  LedState? get ledState => _ledState;

  Future<void> _onDevices(List<DeviceSnapshot> devices) async {
    DeviceSnapshot? connected;
    for (final device in devices) {
      if (device.isConnected) {
        connected = device;
        break;
      }
    }

    final String? nextId = connected?.id;
    final String? nextName = connected?.name;

    if (_activeDeviceId == nextId && _activeDeviceName == nextName) {
      return;
    }

    if (nextId == null) {
      final String? currentDevice = await context.deviceRepository.getCurrentDevice();
      // #region agent log
      await appendRuntimeLog(
        hypothesisId: 'H1',
        location: 'lib/app/common/app_session.dart:_onDevices',
        message: 'active device captured during scan update',
        data: <String, dynamic>{
          'activeDeviceId': _activeDeviceId,
          'repositoryCurrentDevice': currentDevice,
          'connectedDeviceId': nextId,
        },
      );
      // #endregion

      if (_activeDeviceId != null && currentDevice == null) {
        await _clearCurrentDevice();
      }
      return;
    }

    _activeDeviceId = nextId;
    _activeDeviceName = nextName;
    _resubscribePumpHeads(_activeDeviceId);
    _resubscribeLedState(_activeDeviceId);
    notifyListeners();
  }

  Future<void> _onSavedDevices(List<DeviceSnapshot> devices) async {
    _savedDevices = devices;
    if (_activeDeviceId != null &&
        !devices.any((d) => d.id == _activeDeviceId)) {
      final String? currentDevice =
          await context.deviceRepository.getCurrentDevice();
      if (currentDevice == null) {
        await _clearCurrentDevice();
        return;
      }
      // Device is still connected (in repository) even if not yet persisted.
      return;
    }

    if (_activeDeviceId != null) {
      for (final d in devices) {
        if (d.id == _activeDeviceId) {
          _activeDeviceName = d.name;
          break;
        }
      }
    }

    notifyListeners();
  }

  Future<void> _clearCurrentDevice() async {
    debugPrint('AppSession.clearCurrentDevice called');
    debugPrint('activeDeviceId=$_activeDeviceId');
    // #region agent log
    await appendRuntimeLog(
      hypothesisId: 'H2',
      location: 'lib/app/common/app_session.dart:_clearCurrentDevice',
      message: 'clearing active device session',
      data: <String, dynamic>{
        'clearedDeviceId': _activeDeviceId,
        'clearedDeviceName': _activeDeviceName,
      },
    );
    // #endregion

    context.currentDeviceSession.clear();
    _activeDeviceId = null;
    _activeDeviceName = null;
    _resubscribePumpHeads(null);
    _resubscribeLedState(null);
    notifyListeners();
  }

  void _onSinks(List<Sink> sinks) {
    _sinks = sinks;
    notifyListeners();
  }

  void _onPumpHeadsUpdate(List<PumpHead> heads) {
    _pumpHeads = List.unmodifiable(heads);
    notifyListeners();
  }

  Sink? get _defaultSink {
    for (final Sink sink in _sinks) {
      if (sink.type == SinkType.defaultSink) {
        return sink;
      }
    }
    return null;
  }

  void _resubscribePumpHeads(String? deviceId) {
    _pumpHeadSubscription?.cancel();
    _pumpHeadSubscription = null;
    _pumpHeads = const [];
    if (deviceId == null) {
      notifyListeners();
      return;
    }
    _pumpHeadSubscription = context.pumpHeadRepository
        .observePumpHeads(deviceId)
        .listen(_onPumpHeadsUpdate);
  }

  void _resubscribeLedState(String? deviceId) {
    _ledStateSubscription?.cancel();
    _ledStateSubscription = null;
    _ledState = null;
    if (deviceId == null) {
      notifyListeners();
      return;
    }
    _ledStateSubscription = context.ledRepository
        .observeLedState(deviceId)
        .listen((LedState state) {
          _ledState = state;
          notifyListeners();
        });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_handleAppResumed());
    }
  }

  Future<void> _handleAppResumed() async {
    final String? deviceId = _activeDeviceId;
    if (deviceId == null) {
      return;
    }
    final DateTime now = DateTime.now();
    await context.pumpHeadRepository.resetDailyIfNeeded(
      deviceId: deviceId,
      now: now,
    );
    final List<PumpHead> heads = await context.pumpHeadRepository.listPumpHeads(
      deviceId,
    );
    for (final PumpHead head in heads) {
      try {
        await context.readTodayTotalUseCase.execute(
          deviceId: deviceId,
          headId: head.headId,
        );
      } catch (_) {
        // Ignore transport or capability errors on resume sync.
      }
    }
    _resubscribeLedState(deviceId);
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _savedSubscription?.cancel();
    _sinkSubscription?.cancel();
    _pumpHeadSubscription?.cancel();
    _ledStateSubscription?.cancel();
    _isReadySubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
