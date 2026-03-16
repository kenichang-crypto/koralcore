import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:collection/collection.dart';

import '../../../../app/common/app_context.dart';
import '../../../../app/common/app_error_code.dart';
import '../../../../app/common/app_session.dart';
import '../../../../app/device/connect_device_usecase.dart';
import '../../../../app/device/device_snapshot.dart';
import '../../../../app/device/disconnect_device_usecase.dart';
import '../../../../app/device/remove_device_usecase.dart';
import '../../../../app/device/scan_devices_usecase.dart';
import '../../../../app/common/app_error.dart';
import '../../../../app/system/ble_readiness_controller.dart';

class DeviceListController extends ChangeNotifier {
  final AppContext context;
  final AppSession session;
  final ScanDevicesUseCase _scanDevicesUseCase;
  final ConnectDeviceUseCase _connectDeviceUseCase;
  final DisconnectDeviceUseCase _disconnectDeviceUseCase;
  final RemoveDeviceUseCase _removeDeviceUseCase;
  final BleReadinessController bleReadinessController;
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

  DeviceListController({
    required this.context,
    required this.session,
    required this.bleReadinessController,
  })
    : _scanDevicesUseCase = context.scanDevicesUseCase,
      _connectDeviceUseCase = context.connectDeviceUseCase,
      _disconnectDeviceUseCase = context.disconnectDeviceUseCase,
      _removeDeviceUseCase = context.removeDeviceUseCase {
    _savedSubscription = context.deviceRepository
        .observeSavedDevices()
        .map((items) => items.map(DeviceSnapshot.fromMap).toList())
        .listen((devices) {
          // PARITY: reef-b-app DeviceFragment.setObserver()
          // Sorting: favorite > sinkId > group > master
          // reef-b-app: device.sortedByDescending { it.master }.sortedBy { it.group }.sortedByDescending { it.sinkId }.sortedByDescending { it.favorite }
          _savedDevices = _sortDevices(devices);
          _selection.removeWhere((id) => !_savedDevices.any((d) => d.id == id));
          notifyListeners();
        });

    _scanSubscription = _scanDevicesUseCase.observe().listen((devices) {
      _discoveredDevices = _filterDiscoveredDevices(devices);
      notifyListeners();
    });
  }

  List<DeviceSnapshot> get savedDevices => _savedDevices;

  /// Sort devices according to reef-b-app's logic.
  /// PARITY: device.sortedByDescending { it.master }.sortedBy { it.group }.sortedByDescending { it.sinkId }.sortedByDescending { it.favorite }
  /// Priority: favorite > sinkId > group > master
  List<DeviceSnapshot> _sortDevices(List<DeviceSnapshot> devices) {
    return List<DeviceSnapshot>.from(devices)
      ..sort((a, b) {
        // 1. Favorite (descending): favorite devices first
        if (a.favorite != b.favorite) {
          return b.favorite ? 1 : -1;
        }
        // 2. SinkId (descending): assigned devices before unassigned
        final aSinkId = a.sinkId ?? '';
        final bSinkId = b.sinkId ?? '';
        if (aSinkId != bSinkId) {
          return bSinkId.compareTo(aSinkId);
        }
        // 3. Group (ascending): A < B < C < D < E
        final aGroup = a.group ?? '';
        final bGroup = b.group ?? '';
        if (aGroup != bGroup) {
          return aGroup.compareTo(bGroup);
        }
        // 4. Master (descending): master devices first
        if (a.isMaster != b.isMaster) {
          return b.isMaster ? 1 : -1;
        }
        return 0;
      });
  }

  List<DeviceSnapshot> _filterDiscoveredDevices(List<DeviceSnapshot> devices) {
    final Set<String> savedIds = _savedDevices.map((device) => device.id).toSet();
    return devices.where((device) => !savedIds.contains(device.id)).toList();
  }
  List<DeviceSnapshot> get discoveredDevices => _discoveredDevices;
  bool get isScanning => _isScanning;
  bool get selectionMode => _selectionMode;
  Set<String> get selectedIds => Set.unmodifiable(_selection);
  AppErrorCode? get lastErrorCode => _lastErrorCode;

  Future<void> refresh() async {
    if (!bleReadinessController.snapshot.isReady) {
      debugPrint('[BLE] scan blocked: BLE not ready');
      return;
    }
    final List<BluetoothDevice> connected =
        await FlutterBluePlus.connectedDevices;
    final String? repoDevice = await context.deviceRepository.getCurrentDevice();
    final bool hasActiveConnection = (session.isBleConnected &&
            session.activeDeviceId != null) ||
        repoDevice != null ||
        connected.isNotEmpty;
    if (hasActiveConnection) {
      debugPrint(
        'DeviceListController - refresh skipped: BLE device already connected, rebuilding saved list',
      );
      await _rebuildDeviceList();
      return;
    }
    // PARITY: reef-b-app BLEManager.scanLeDevice() -> Log.d("$TAG - 藍芽掃描", "掃描開始")
    debugPrint('DeviceListController - 藍芽掃描: 掃描開始');
    if (_isScanning) {
      debugPrint('DeviceListController - 藍芽掃描: 已在掃描中，跳過');
      return;
    }
    _isScanning = true;
    notifyListeners();
    try {
      await _scanDevicesUseCase.execute(timeout: const Duration(seconds: 2));
      debugPrint('DeviceListController - 藍芽掃描: 掃描結束');
    } on AppError catch (error) {
      debugPrint('DeviceListController - 藍芽掃描: 掃描錯誤 ${error.code}');
      _setError(error.code);
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }

  Future<void> _rebuildDeviceList() async {
    final savedMaps = await context.deviceRepository.listSavedDevices();
    final savedSnapshots =
        savedMaps.map(DeviceSnapshot.fromMap).toList(growable: false);
    _savedDevices = _sortDevices(savedSnapshots);
    _selection.removeWhere((id) => !_savedDevices.any((d) => d.id == id));
    _discoveredDevices = _filterDiscoveredDevices(_discoveredDevices);
    notifyListeners();
  }

  /// Connect to a device.
  ///
  /// PARITY: Matches reef-b-app's BluetoothViewModel.connectBle() behavior.
  /// - Checks connection limit (max 1 device) before connecting
  /// - After successful connection, checks if device exists in saved devices
  /// - If device doesn't exist, triggers onNewDeviceConnected callback
  /// - This callback should navigate to AddDevicePage (similar to startAddDeviceLiveData)
  Future<void> connect(String deviceId) async {
    if (!bleReadinessController.snapshot.isReady) {
      debugPrint('[BLE] connect blocked: BLE not ready');
      _setError(AppErrorCode.deviceNotReady);
      return;
    }
    if (!bleReadinessController.snapshot.isReady) {
      debugPrint('DeviceListController - BLE not ready, skipping connect');
      _setError(AppErrorCode.deviceNotReady);
      return;
    }
    // PARITY: reef-b-app BLEManager.connectBLE() -> Log.d("$TAG - 藍芽連線", "${gatt?.device?.address} 成功連線")
    debugPrint('DeviceListController - 藍芽連線: 開始連線 $deviceId');

    // Check connection limit (PARITY: reef-b-app's alreadyConnect4Device callback)
    // reef-b-app: Maximum 1 device can be connected simultaneously
    final bool hasConnectedDevice = _savedDevices.any((d) => d.isConnected);
    if (hasConnectedDevice) {
      debugPrint('DeviceListController - 藍芽連線: 連線限制已達上限，已有其他設備連線');
      _setError(AppErrorCode.connectLimit);
      return;
    }

    try {
      await _connectDeviceUseCase.execute(deviceId: deviceId);
      // PARITY: reef-b-app BLEManager.onConnectionStateChange() -> Log.d("$TAG - 藍芽連線", "${gatt?.device?.address} 成功連線")
      debugPrint('DeviceListController - 藍芽連線: $deviceId 成功連線');

      final DeviceSnapshot? deviceSnapshot = _savedDevices.firstWhereOrNull(
        (device) => device.id == deviceId,
      );
      final DeviceSnapshot? discoveredSnapshot =
          _discoveredDevices.firstWhereOrNull(
        (device) => device.id == deviceId,
      );
      final String? resolvedName =
          deviceSnapshot?.name ?? discoveredSnapshot?.name;
      session.setActiveDevice(deviceId);
      if (resolvedName != null) {
        session.setActiveDeviceName(resolvedName);
      }

      // Check if device exists in saved devices (PARITY: reef-b-app)
      // reef-b-app: viewModel.deviceIsExist() -> if false, startAddDeviceLiveData.value = Unit
      final bool deviceExists = _savedDevices.any((d) => d.id == deviceId);
      if (!deviceExists && onNewDeviceConnected != null) {
        debugPrint('DeviceListController - 藍芽連線: 設備 $deviceId 為新設備，觸發導航');
        // Device doesn't exist, trigger navigation to AddDevicePage
        onNewDeviceConnected!();
      }
    } on AppError catch (error) {
      // PARITY: reef-b-app BLEManager.onConnectionStateChange() -> Log.d("$TAG - 藍芽連線", "${gatt?.device?.address} 斷線")
      debugPrint('DeviceListController - 藍芽連線: $deviceId 連線失敗，錯誤: ${error.code}');
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

  /// Remove selected devices.
  /// PARITY: reef-b-app DeviceViewModel.deleteDevice(list: List<Device>)
  /// Note: Master deletion restriction check is done in DevicePage._confirmDelete() before calling this method.
  Future<void> removeSelected() async {
    final targets = List<String>.from(_selection);

    // PARITY: reef-b-app deletes all devices in the list
    // reef-b-app: list.forEach { dbDeleteDeviceById(it.id); if (it.macAddress == bleManager.getConnectDeviceMacAddress()) { bleManager.disConnect() } }
    bool hasError = false;
    for (final id in targets) {
      try {
        await _removeDeviceUseCase.execute(deviceId: id);
      } on AppError catch (error) {
        _setError(error.code);
        hasError = true;
        break;
      }
    }
    
    // PARITY: reef-b-app deleteDeviceLiveData.value = true/false
    // reef-b-app: isDeleteMode(false) is called in observer
    // koralcore: exitSelectionMode() is called here
    if (!hasError) {
      exitSelectionMode();
    }
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
