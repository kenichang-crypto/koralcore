import 'package:flutter/foundation.dart';

import '../../../../application/common/app_error_code.dart';
import '../../../../application/common/app_session.dart';
import '../../../../domain/doser_dosing/pump_head.dart';
import '../../../../platform/contracts/device_repository.dart';
import '../../../../platform/contracts/pump_head_repository.dart';
import '../../../../platform/contracts/sink_repository.dart';

/// Controller for add device page.
///
/// PARITY: Mirrors reef-b-app's AddDeviceViewModel.
class AddDeviceController extends ChangeNotifier {
  final AppSession session;
  final DeviceRepository deviceRepository;
  final PumpHeadRepository pumpHeadRepository;
  final SinkRepository sinkRepository;

  AddDeviceController({
    required this.session,
    required this.deviceRepository,
    required this.pumpHeadRepository,
    required this.sinkRepository,
  });

  // State
  bool _isLoading = false;
  String _deviceName = '';
  String? _selectedSinkId;
  AppErrorCode? _lastErrorCode;

  // Getters
  bool get isLoading => _isLoading;
  String get deviceName => _deviceName;
  String? get selectedSinkId => _selectedSinkId;
  AppErrorCode? get lastErrorCode => _lastErrorCode;

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
  void setSelectedSinkId(String? sinkId) {
    _selectedSinkId = sinkId;
    notifyListeners();
  }

  /// Get sink name by ID.
  Future<String?> getSinkNameById(String sinkId) async {
    try {
      final sinks = await sinkRepository.getCurrentSinks();
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
  Future<bool> skip() async {
    final String? deviceId = session.activeDeviceId;
    if (deviceId == null) {
      _setError(AppErrorCode.noActiveDevice);
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Get device info
      final List<Map<String, dynamic>> devices =
          await deviceRepository.listSavedDevices();
      final Map<String, dynamic>? device = devices.firstWhere(
        (d) => d['id'] == deviceId,
        orElse: () => <String, dynamic>{},
      );

      if (device.isEmpty) {
        _setError(AppErrorCode.noActiveDevice);
        return false;
      }

      final String? deviceType = device['type'] as String?;
      final String name = _deviceName.isEmpty
          ? (device['name'] as String? ?? 'Unknown Device')
          : _deviceName;

      // Update device name if changed
      if (_deviceName.isNotEmpty) {
        await deviceRepository.updateDeviceName(deviceId, name);
      }

      // If DROP device, create pump heads
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
  Future<bool> addDevice() async {
    final String? deviceId = session.activeDeviceId;
    if (deviceId == null) {
      _setError(AppErrorCode.noActiveDevice);
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
      // Get device info
      final List<Map<String, dynamic>> devices =
          await deviceRepository.listSavedDevices();
      final Map<String, dynamic>? device = devices.firstWhere(
        (d) => d['id'] == deviceId,
        orElse: () => <String, dynamic>{},
      );

      if (device.isEmpty) {
        _setError(AppErrorCode.noActiveDevice);
        return false;
      }

      final String? deviceType = device['type'] as String?;

      // Prepare updates
      final Map<String, dynamic> updates = {
        'name': _deviceName.trim(),
      };

      if (_selectedSinkId != null && _selectedSinkId!.isNotEmpty) {
        updates['sink_id'] = _selectedSinkId;

        if (deviceType == 'LED') {
          // Assign to group
          final String? group = await _findAvailableGroup(_selectedSinkId!);
          if (group == null) {
            // All groups are full
            _setError(AppErrorCode.invalidParam);
            return false;
          }
          updates['device_group'] = group;
          updates['is_master'] = false; // New device is not master
        } else if (deviceType == 'DROP') {
          // Check if sink already has 4 DROP devices
          final int dropCount = await _getDropCountInSink(_selectedSinkId!);
          if (dropCount >= 4) {
            _setError(AppErrorCode.invalidParam);
            return false;
          }
        }
      } else {
        // No sink assignment
        updates['sink_id'] = null;
        updates['device_group'] = null;
      }

      // Update device using addSavedDevice (which updates if exists)
      final Map<String, dynamic> deviceData = Map.from(device);
      deviceData.addAll(updates);
      await deviceRepository.addSavedDevice(deviceData);

      // If DROP device, create pump heads
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
    final List<Map<String, dynamic>> devices =
        await deviceRepository.getDevices();
    final List<Map<String, dynamic>> sinkDevices = devices
        .where((d) =>
            d['sink_id'] == sinkId &&
            d['type'] == 'LED')
        .toList();

    // Count devices per group
    final Map<String, int> groupCounts = {'A': 0, 'B': 0, 'C': 0, 'D': 0, 'E': 0};
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
    final List<Map<String, dynamic>> devices =
        await deviceRepository.getDevices();
    return devices
        .where((d) =>
            d['sink_id'] == sinkId &&
            d['type'] == 'DROP')
        .length;
  }

  /// Create pump heads for DROP device.
  Future<void> _createPumpHeads(String deviceId) async {
    // Check if pump heads already exist
    final List<PumpHead> existingHeads =
        await pumpHeadRepository.listPumpHeads(deviceId);
    if (existingHeads.length >= 4) {
      return; // Already created
    }

    // Create 4 pump heads (A, B, C, D)
    final List<String> existingHeadIds =
        existingHeads.map((h) => h.headId).toList();
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

  /// Disconnect BLE device.
  Future<void> disconnect() async {
    // TODO: Implement BLE disconnection
    // This should disconnect the currently connected device
  }

  void _setError(AppErrorCode code) {
    _lastErrorCode = code;
  }

  void _clearError() {
    _lastErrorCode = null;
  }
}

