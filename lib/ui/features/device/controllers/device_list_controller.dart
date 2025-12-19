import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../application/common/app_context.dart';
import '../../../../application/common/app_error_code.dart';
import '../../../../application/device/connect_device_usecase.dart';
import '../../../../application/device/device_snapshot.dart';
import '../../../../application/device/disconnect_device_usecase.dart';
import '../../../../application/device/remove_device_usecase.dart';
import '../../../../application/device/scan_devices_usecase.dart';
import '../../../../application/common/app_error.dart';

class DeviceListController extends ChangeNotifier {
  final AppContext context;
  final ScanDevicesUseCase _scanDevicesUseCase;
  final ConnectDeviceUseCase _connectDeviceUseCase;
  final DisconnectDeviceUseCase _disconnectDeviceUseCase;
  final RemoveDeviceUseCase _removeDeviceUseCase;

  StreamSubscription<List<DeviceSnapshot>>? _subscription;

  List<DeviceSnapshot> _devices = const [];
  bool _isScanning = false;
  bool _selectionMode = false;
  final Set<String> _selection = <String>{};
  AppErrorCode? _lastErrorCode;

  DeviceListController({required this.context})
    : _scanDevicesUseCase = context.scanDevicesUseCase,
      _connectDeviceUseCase = context.connectDeviceUseCase,
      _disconnectDeviceUseCase = context.disconnectDeviceUseCase,
      _removeDeviceUseCase = context.removeDeviceUseCase {
    _subscription = _scanDevicesUseCase.observe().listen((devices) {
      _devices = devices;
      _selection.removeWhere((id) => !_devices.any((d) => d.id == id));
      notifyListeners();
    });
  }

  List<DeviceSnapshot> get devices => _devices;
  bool get isScanning => _isScanning;
  bool get selectionMode => _selectionMode;
  Set<String> get selectedIds => Set.unmodifiable(_selection);
  AppErrorCode? get lastErrorCode => _lastErrorCode;

  Future<void> refresh() async {
    if (_isScanning) return;
    _isScanning = true;
    notifyListeners();
    try {
      await _scanDevicesUseCase.execute(timeout: const Duration(seconds: 2));
    } on AppError catch (error) {
      _setError(error.code);
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }

  Future<void> connect(String deviceId) async {
    try {
      await _connectDeviceUseCase.execute(deviceId: deviceId);
    } on AppError catch (error) {
      _setError(error.code);
    }
  }

  Future<void> disconnect(String deviceId) async {
    try {
      await _disconnectDeviceUseCase.execute(deviceId: deviceId);
    } on AppError catch (error) {
      _setError(error.code);
    }
  }

  Future<void> removeSelected() async {
    final targets = List<String>.from(_selection);
    for (final id in targets) {
      try {
        await _removeDeviceUseCase.execute(deviceId: id);
      } on AppError catch (error) {
        _setError(error.code);
        break;
      }
    }
    exitSelectionMode();
  }

  void enterSelectionMode() {
    if (_selectionMode) return;
    _selectionMode = true;
    notifyListeners();
  }

  void exitSelectionMode() {
    if (!_selectionMode) return;
    _selectionMode = false;
    _selection.clear();
    notifyListeners();
  }

  void toggleSelection(String deviceId) {
    if (!_selectionMode) return;
    if (_selection.contains(deviceId)) {
      _selection.remove(deviceId);
    } else {
      _selection.add(deviceId);
    }
    notifyListeners();
  }

  void clearError() {
    if (_lastErrorCode == null) return;
    _lastErrorCode = null;
    notifyListeners();
  }

  void _setError(AppErrorCode code) {
    _lastErrorCode = code;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
