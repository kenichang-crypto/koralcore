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
  StreamSubscription<List<DeviceSnapshot>>? _savedSubscription;
  StreamSubscription<List<DeviceSnapshot>>? _scanSubscription;

  List<DeviceSnapshot> _savedDevices = const [];
  List<DeviceSnapshot> _discoveredDevices = const [];
  bool _isScanning = false;
  bool _selectionMode = false;
  final Set<String> _selection = <String>{};
  AppErrorCode? _lastErrorCode;

  /// Callback for when a new device is connected (device doesn't exist in saved devices).
  /// PARITY: Matches reef-b-app's startAddDeviceLiveData mechanism.
  VoidCallback? onNewDeviceConnected;

  DeviceListController({required this.context})
    : _scanDevicesUseCase = context.scanDevicesUseCase,
      _connectDeviceUseCase = context.connectDeviceUseCase,
      _disconnectDeviceUseCase = context.disconnectDeviceUseCase,
      _removeDeviceUseCase = context.removeDeviceUseCase {
    _savedSubscription = context.deviceRepository
        .observeSavedDevices()
        .map((items) => items.map(DeviceSnapshot.fromMap).toList())
        .listen((devices) {
          _savedDevices = devices;
          _selection.removeWhere((id) => !_savedDevices.any((d) => d.id == id));
          notifyListeners();
        });

    _scanSubscription = _scanDevicesUseCase.observe().listen((devices) {
      _discoveredDevices = devices;
      notifyListeners();
    });
  }

  List<DeviceSnapshot> get savedDevices => _savedDevices;
  List<DeviceSnapshot> get discoveredDevices => _discoveredDevices;
  bool get isScanning => _isScanning;
  bool get selectionMode => _selectionMode;
  Set<String> get selectedIds => Set.unmodifiable(_selection);
  AppErrorCode? get lastErrorCode => _lastErrorCode;

  Future<void> refresh() async {
    print('[DeviceListController] refresh called');
    if (_isScanning) {
      print('[DeviceListController] Already scanning, skipping');
      return;
    }
    _isScanning = true;
    notifyListeners();
    try {
      print('[DeviceListController] Starting scan...');
      await _scanDevicesUseCase.execute(timeout: const Duration(seconds: 2));
      print('[DeviceListController] Scan completed');
    } on AppError catch (error) {
      print('[DeviceListController] Scan error: ${error.code}');
      _setError(error.code);
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }

  /// Connect to a device.
  ///
  /// PARITY: Matches reef-b-app's BluetoothViewModel.connectBle() behavior.
  /// - Checks connection limit (max 1 device) before connecting
  /// - After successful connection, checks if device exists in saved devices
  /// - If device doesn't exist, triggers onNewDeviceConnected callback
  /// - This callback should navigate to AddDevicePage (similar to startAddDeviceLiveData)
  Future<void> connect(String deviceId) async {
    print('[DeviceListController] connect called for device: $deviceId');

    // Check connection limit (PARITY: reef-b-app's alreadyConnect4Device callback)
    // reef-b-app: Maximum 1 device can be connected simultaneously
    final bool hasConnectedDevice = _savedDevices.any((d) => d.isConnected);
    if (hasConnectedDevice) {
      print('[DeviceListController] Connection limit reached, another device is already connected');
      _setError(AppErrorCode.connectLimit);
      return;
    }

    try {
      await _connectDeviceUseCase.execute(deviceId: deviceId);
      print('[DeviceListController] connect succeeded for device: $deviceId');

      // Check if device exists in saved devices (PARITY: reef-b-app)
      // reef-b-app: viewModel.deviceIsExist() -> if false, startAddDeviceLiveData.value = Unit
      final bool deviceExists = _savedDevices.any((d) => d.id == deviceId);
      if (!deviceExists && onNewDeviceConnected != null) {
        print('[DeviceListController] Device $deviceId is new, triggering navigation');
        // Device doesn't exist, trigger navigation to AddDevicePage
        onNewDeviceConnected!();
      }
    } on AppError catch (error) {
      print('[DeviceListController] connect failed for device: $deviceId, error: ${error.code}');
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

  /// Check if a device can be deleted.
  ///
  /// PARITY: Matches reef-b-app's DeviceViewModel.canDeleteDevice() logic.
  /// - Only checks LED devices for master deletion restriction
  /// - DROP devices can always be deleted
  /// - Unassigned devices (no sinkId) can always be deleted
  /// - If group has only 1 device, master can be deleted
  /// - If group has more than 1 device, master cannot be deleted
  Future<bool> canDeleteDevice(String deviceId) async {
    final DeviceSnapshot device =
        _savedDevices.firstWhere((d) => d.id == deviceId, orElse: () => throw StateError('Device not found'));
    
    // DROP devices can always be deleted
    if (device.type != 'LED') {
      return true;
    }

    // Unassigned devices can always be deleted
    final deviceData = await context.deviceRepository.getDevice(deviceId);
    if (deviceData == null) {
      return true;
    }

    final String? sinkId = deviceData['sinkId']?.toString();
    final String? group = deviceData['group']?.toString();

    if (sinkId == null) {
      // Unassigned device
      return true;
    }

    if (group == null) {
      // Has sinkId but no group
      return true;
    }

    // Check if group has other devices
    final List<Map<String, dynamic>> groupDevices =
        await context.deviceRepository.getDevicesBySinkIdAndGroup(sinkId, group);

    if (groupDevices.length <= 1) {
      // Group has only this device (or empty), master can be deleted
      return true;
    }

    // Group has more than 1 device, check if this device is master
    return !device.isMaster;
  }

  Future<void> removeSelected() async {
    final targets = List<String>.from(_selection);
    
    // PARITY: reef-b-app checks LED master deletion restriction before deleting
    // reef-b-app: tmpList.forEach { if (it.type == DeviceType.LED && !viewModel.canDeleteDevice(it)) { createDeleteLedMasterDialog(); return } }
    for (final id in targets) {
      final bool canDelete = await canDeleteDevice(id);
      if (!canDelete) {
        // LED master device in a group with other devices cannot be deleted
        _setError(AppErrorCode.ledMasterCannotDelete);
        return;
      }
    }

    // All devices can be deleted, proceed with deletion
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
    _savedSubscription?.cancel();
    _scanSubscription?.cancel();
    super.dispose();
  }
}
