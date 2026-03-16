import 'package:flutter/foundation.dart';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../../../app/common/app_error_code.dart';
import '../../../../app/common/app_session.dart';
import '../../../../app/device/disconnect_device_usecase.dart';
import '../../../../app/system/ble_readiness_controller.dart';
import '../../../../debug/runtime_logger.dart';
import '../../../../domain/doser_dosing/pump_head.dart';
import '../../../../data/ble/device_name_filter.dart';
import '../../../../features/device/presentation/controllers/device_list_controller.dart';
import '../../../../platform/contracts/device_repository.dart';
import '../../../../platform/contracts/pump_head_repository.dart';
import '../../../../platform/contracts/sink_repository.dart';

/// Controller for add device page.
///
/// PARITY: Mirrors reef-b-app's AddDeviceViewModel.
class AddDeviceController extends ChangeNotifier {
  final AppSession session;
  final DeviceRepository deviceRepository;
  final DeviceListController deviceListController;
  final BleReadinessController bleReadinessController;
  final PumpHeadRepository pumpHeadRepository;
  final SinkRepository sinkRepository;
  final DisconnectDeviceUseCase disconnectDeviceUseCase;

  AddDeviceController({
    required this.session,
    required this.deviceRepository,
    required this.deviceListController,
    required this.bleReadinessController,
    required this.pumpHeadRepository,
    required this.sinkRepository,
    required this.disconnectDeviceUseCase,
  });

  // State
  bool _isLoading = false;
  String _deviceName = '';
  String? _selectedSinkId;
  String? _selectedSinkName;
  AppErrorCode? _lastErrorCode;

  // Getters
  bool get isLoading => _isLoading;
  String get deviceName => _deviceName;
  String? get selectedSinkId => _selectedSinkId;
  String? get selectedSinkName => _selectedSinkName;
  AppErrorCode? get lastErrorCode => _lastErrorCode;

  Future<String?> _resolveActiveDeviceId() async {
    final String? sessionId = session.activeDeviceId;
    String? repositoryDevice;
    if (sessionId == null) {
      repositoryDevice = await deviceRepository.getCurrentDevice();
    }
    final String? resolved = sessionId ?? repositoryDevice;

    // #region agent log
    await appendRuntimeLog(
      hypothesisId: 'H3',
      location: 'lib/features/device/presentation/controllers/add_device_controller.dart:_resolveActiveDeviceId',
      message: 'resolving active device id',
      data: <String, dynamic>{
        'sessionActiveDeviceId': sessionId,
        'repositoryCurrentDevice': repositoryDevice,
        'resolvedDeviceId': resolved,
      },
    );
    // #endregion

    return resolved;
  }

  Future<String?> _resolveActiveDeviceName(String deviceId) async {
    final String? activeName = session.activeDeviceName;
    if (activeName != null && activeName.isNotEmpty) {
      // #region agent log
      await appendRuntimeLog(
        hypothesisId: 'H4',
        location: 'lib/features/device/presentation/controllers/add_device_controller.dart:_resolveActiveDeviceName',
        message: 'using session-provided device name',
        data: <String, dynamic>{
          'deviceId': deviceId,
          'sessionActiveDeviceName': activeName,
        },
      );
      // #endregion
      return activeName;
    }
    final Map<String, dynamic>? saved = await deviceRepository.getDevice(deviceId);
    final String? repositoryName = saved?['name'] as String?;
    final String resolved = repositoryName ?? 'Unknown Device';

    // #region agent log
    await appendRuntimeLog(
      hypothesisId: 'H5',
      location: 'lib/features/device/presentation/controllers/add_device_controller.dart:_resolveActiveDeviceName',
      message: 'resolving device name via repository or fallback',
      data: <String, dynamic>{
        'deviceId': deviceId,
        'repositoryDeviceName': repositoryName,
        'resolvedDeviceName': resolved,
      },
    );
    // #endregion

    return resolved;
  }

  /// Get connected device name from BLE.
  String? get connectedDeviceName {
    // TODO: Get from BLE connection state
    // For now, return from session
    return session.activeDeviceName;
  }

  /// Set device name.
  void setDeviceName(String name) {
    _deviceName = name.trim();
    notifyListeners();
  }

  /// Set selected sink ID.
  Future<void> setSelectedSinkId(String? sinkId) async {
    _selectedSinkId = sinkId;
    if (sinkId != null) {
      _selectedSinkName = await getSinkNameById(sinkId);
    } else {
      _selectedSinkName = null;
    }
    notifyListeners();
  }

  /// Get sink name by ID.
  Future<String?> getSinkNameById(String sinkId) async {
    try {
      final sinks = sinkRepository.getCurrentSinks();
      final sink = sinks.firstWhere(
        (s) => s.id == sinkId,
        orElse: () => throw Exception('Sink not found'),
      );
      return sink.name;
    } catch (e) {
      return null;
    }
  }

  /// Skip adding device (add without sink assignment).
  ///
  /// PARITY: Matches reef-b-app's AddDeviceViewModel.skip().
  /// - Gets device name from BLE connection (bleManager.getConnectDeviceName())
  /// - Determines device type from name (contains "led" or "dose", case-insensitive)
  /// - For LED: adds device without sink/group
  /// - For DROP: adds device without sink, creates 4 pump heads
  Future<bool> skip() async {
    final repoDevice = await deviceRepository.getCurrentDevice();
    final devices = await FlutterBluePlus.connectedDevices;
    debugPrint('AddDevice debug:');
    debugPrint('session.activeDeviceId=${session.activeDeviceId}');
    debugPrint('repo.currentDevice=$repoDevice');
    debugPrint('connectedDevices=${devices.length}');

    final String? deviceId = await _resolveActiveDeviceId();
    if (deviceId == null) {
      _setError(AppErrorCode.noActiveDevice);
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Get device name from BLE connection (PARITY: reef-b-app)
      final String? deviceName = await _resolveActiveDeviceName(deviceId);
      if (deviceName == null || deviceName.isEmpty) {
        _setError(AppErrorCode.noActiveDevice);
        return false;
      }

      // Determine device type from name (PARITY: reef-b-app)
      // Uses contains("led", ignoreCase = true) or contains("dose", ignoreCase = true)
      final String? deviceType = DeviceNameFilter.getDeviceType(deviceName);
      if (deviceType == null) {
        _setError(AppErrorCode.invalidParam);
        return false;
      }

      final String name = _deviceName.isEmpty ? deviceName : _deviceName;

      // Get device MAC address (for saving device)
      final String? macAddress = await _getDeviceMacAddress(deviceId);

      // Add device to repository (PARITY: reef-b-app's dbAddDevice)
      await deviceRepository.addSavedDevice({
        'id': deviceId,
        'name': name,
        'type': deviceType,
        'sinkId': null, // No sink assignment
        'state': 'connected',
        'macAddress': macAddress,
      });

      await deviceRepository.listSavedDevices();

      // Update device name if changed
      if (_deviceName.isNotEmpty) {
        await deviceRepository.updateDeviceName(deviceId, name);
      }

      // If DROP device, create 4 pump heads (PARITY: reef-b-app)
      if (deviceType == 'DROP') {
        await _createPumpHeads(deviceId);
      }

      _clearError();
      return true;
    } catch (e) {
      _setError(AppErrorCode.unknownError);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add device with sink assignment.
  ///
  /// PARITY: Matches reef-b-app's AddDeviceViewModel.clickBtnRight().
  /// - Gets device name from BLE connection (bleManager.getConnectDeviceName())
  /// - Determines device type from name (contains "led" or "dose", case-insensitive)
  /// - For LED: assigns to available group in sink
  /// - For DROP: checks sink capacity (max 4 devices), creates 4 pump heads
  Future<bool> addDevice() async {
    final repoDevice = await deviceRepository.getCurrentDevice();
    final devices = await FlutterBluePlus.connectedDevices;
    debugPrint('AddDevice debug:');
    debugPrint('session.activeDeviceId=${session.activeDeviceId}');
    debugPrint('repo.currentDevice=$repoDevice');
    debugPrint('connectedDevices=${devices.length}');

    final String? deviceId = await _resolveActiveDeviceId();
    if (deviceId == null) {
      _setError(AppErrorCode.noActiveDevice);
      notifyListeners();
      return false;
    }

    if (!bleReadinessController.snapshot.isReady) {
      debugPrint('[ADD_DEVICE] blocked: BLE not ready');
      _setError(AppErrorCode.deviceNotReady);
      notifyListeners();
      return false;
    }

    if (_deviceName.trim().isEmpty) {
      _setError(AppErrorCode.invalidParam);
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Get device name from BLE connection (PARITY: reef-b-app)
      final String? deviceName = await _resolveActiveDeviceName(deviceId);
      if (deviceName == null || deviceName.isEmpty) {
        _setError(AppErrorCode.noActiveDevice);
        return false;
      }

      // Determine device type from name (PARITY: reef-b-app)
      // Uses contains("led", ignoreCase = true) or contains("dose", ignoreCase = true)
      final String? deviceType = DeviceNameFilter.getDeviceType(deviceName);
      if (deviceType == null) {
        _setError(AppErrorCode.invalidParam);
        return false;
      }

      // Get device MAC address (for saving device)
      final String? macAddress = await _getDeviceMacAddress(deviceId);

      // Prepare device data
      final Map<String, dynamic> deviceData = {
        'id': deviceId,
        'name': _deviceName.trim(),
        'type': deviceType,
        'macAddress': macAddress,
        'state': 'connected',
      };

      if (_selectedSinkId != null && _selectedSinkId!.isNotEmpty) {
        deviceData['sinkId'] = _selectedSinkId;

        if (deviceType == 'LED') {
          // Assign to group (PARITY: reef-b-app's addToWhichGroup)
          final String? group = await _findAvailableGroup(_selectedSinkId!);
          if (group == null) {
            // All groups are full
            _setError(AppErrorCode.sinkFull);
            return false;
          }
          deviceData['group'] = group;
          deviceData['is_master'] = false; // New device is not master
        } else if (deviceType == 'DROP') {
          // Check if sink already has 4 DROP devices (PARITY: reef-b-app)
          final int dropCount = await _getDropCountInSink(_selectedSinkId!);
          if (dropCount >= 4) {
            _setError(AppErrorCode.sinkFull);
            return false;
          }
        }
      } else {
        // No sink assignment
        deviceData['sinkId'] = null;
        deviceData['group'] = null;
      }

      // Add/update device (PARITY: reef-b-app's dbAddDevice)
      await deviceRepository.addSavedDevice(deviceData);
      deviceListController.refresh();

      await deviceRepository.listSavedDevices();

      // If DROP device, create 4 pump heads (PARITY: reef-b-app)
      if (deviceType == 'DROP') {
        await _createPumpHeads(deviceId);
      }

      _clearError();
      return true;
    } catch (e) {
      _setError(AppErrorCode.unknownError);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Find available group for LED device in sink.
  Future<String?> _findAvailableGroup(String sinkId) async {
    final List<Map<String, dynamic>> devices = await deviceRepository
        .listSavedDevices();
    final List<Map<String, dynamic>> sinkDevices = devices
        .where((d) => d['sink_id'] == sinkId && d['type'] == 'LED')
        .toList();

    // Count devices per group
    final Map<String, int> groupCounts = {
      'A': 0,
      'B': 0,
      'C': 0,
      'D': 0,
      'E': 0,
    };
    for (final device in sinkDevices) {
      final String? group = device['device_group'] as String?;
      if (group != null && groupCounts.containsKey(group)) {
        groupCounts[group] = (groupCounts[group] ?? 0) + 1;
      }
    }

    // Find first group with less than 4 devices
    for (final entry in groupCounts.entries) {
      if (entry.value < 4) {
        return entry.key;
      }
    }

    return null; // All groups are full
  }

  /// Get count of DROP devices in sink.
  Future<int> _getDropCountInSink(String sinkId) async {
    final List<Map<String, dynamic>> devices = await deviceRepository
        .listSavedDevices();
    return devices
        .where((d) => d['sink_id'] == sinkId && d['type'] == 'DROP')
        .length;
  }

  /// Create pump heads for DROP device.
  Future<void> _createPumpHeads(String deviceId) async {
    // Check if pump heads already exist
    final List<PumpHead> existingHeads = await pumpHeadRepository.listPumpHeads(
      deviceId,
    );
    if (existingHeads.length >= 4) {
      return; // Already created
    }

    // Create 4 pump heads (A, B, C, D)
    final List<String> existingHeadIds = existingHeads
        .map((h) => h.headId)
        .toList();
    for (int i = 0; i < 4; i++) {
      final String headId = String.fromCharCode(65 + i); // A, B, C, D
      if (!existingHeadIds.contains(headId)) {
        // Create pump head with default values
        final PumpHead newHead = PumpHead(
          headId: headId,
          pumpId: i + 1,
          additiveName: '',
          dailyTargetMl: 30.0,
          todayDispensedMl: 0.0,
          flowRateMlPerMin: 1.0,
          lastDoseAt: null,
          statusKey: 'idle',
          status: PumpHeadStatus.idle,
        );
        // Save via savePumpHeads (adds to existing list)
        final List<PumpHead> allHeads = List.from(existingHeads)..add(newHead);
        await pumpHeadRepository.savePumpHeads(deviceId, allHeads);
      }
    }
  }

  /// Get device MAC address from repository.
  Future<String?> _getDeviceMacAddress(String deviceId) async {
    try {
      final List<Map<String, dynamic>> devices = await deviceRepository
          .listSavedDevices();
      final Map<String, dynamic> device = devices.firstWhere(
        (d) => d['id'] == deviceId,
        orElse: () => <String, dynamic>{},
      );
      return device['macAddress'] as String?;
    } catch (e) {
      return null;
    }
  }

  /// Disconnect BLE device.
  ///
  /// PARITY: Mirrors reef-b-app's AddDeviceViewModel.disconnect().
  Future<void> disconnect() async {
    final String? deviceId = session.activeDeviceId;
    if (deviceId == null) {
      return; // No device to disconnect
    }

    try {
      await disconnectDeviceUseCase.execute(deviceId: deviceId);
    } catch (e) {
      // Log error but don't throw - disconnection failure shouldn't block UI
      debugPrint('[AddDeviceController] Failed to disconnect device: $e');
    }
  }

  void _setError(AppErrorCode code) {
    _lastErrorCode = code;
  }

  void _clearError() {
    _lastErrorCode = null;
  }
}

