import 'package:flutter/foundation.dart';

import '../../../../app/common/app_error_code.dart';
import '../../../../platform/contracts/device_repository.dart';
import '../../../../platform/contracts/sink_repository.dart';

/// Controller for LED master setting page.
///
/// PARITY: Mirrors reef-b-app's LedMasterSettingViewModel.
class LedMasterSettingController extends ChangeNotifier {
  final String sinkId;
  final DeviceRepository deviceRepository;
  final SinkRepository sinkRepository;

  LedMasterSettingController({
    required this.sinkId,
    required this.deviceRepository,
    required this.sinkRepository,
  });

  // State
  bool _isLoading = false;
  List<_DeviceGroup> _groups = [];
  AppErrorCode? _lastErrorCode;

  // Getters
  bool get isLoading => _isLoading;
  List<_DeviceGroup> get groups => List.unmodifiable(_groups);
  AppErrorCode? get lastErrorCode => _lastErrorCode;

  /// Initialize controller and load devices by groups.
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load all devices for this sink
      final List<Map<String, dynamic>> allDevices = await deviceRepository
          .listSavedDevices();

      // Filter LED devices for this sink
      final List<Map<String, dynamic>> sinkDevices = allDevices
          .where(
            (device) => device['sink_id'] == sinkId && device['type'] == 'LED',
          )
          .toList();

      // Group devices by group (A, B, C, D, E)
      final Map<String, List<Map<String, dynamic>>> grouped = {};
      for (final device in sinkDevices) {
        final String? group = device['device_group'] as String?;
        final String groupKey = group ?? 'none';
        grouped.putIfAbsent(groupKey, () => []).add(device);
      }

      // Create group structures
      _groups = ['A', 'B', 'C', 'D', 'E'].map((groupKey) {
        final List<Map<String, dynamic>> devices = grouped[groupKey] ?? [];
        // Sort by master (master first)
        devices.sort((a, b) {
          final bool aMaster = (a['is_master'] as int? ?? 0) != 0;
          final bool bMaster = (b['is_master'] as int? ?? 0) != 0;
          if (aMaster == bMaster) return 0;
          return aMaster ? -1 : 1;
        });
        return _DeviceGroup(id: groupKey, devices: devices);
      }).toList();

      _clearError();
    } catch (e) {
      _setError(AppErrorCode.unknownError);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Set master device for a group.
  Future<bool> setMaster(String deviceId, String groupId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Get current master in this group
      final _DeviceGroup group = _groups.firstWhere(
        (g) => g.id == groupId,
        orElse: () => _DeviceGroup(id: groupId, devices: []),
      );

      final Map<String, dynamic> currentMaster = group.devices.firstWhere(
        (d) => (d['is_master'] as int? ?? 0) != 0,
        orElse: () => <String, dynamic>{},
      );

      // Update devices using addSavedDevice (which updates if exists)
      if (currentMaster.isNotEmpty) {
        final Map<String, dynamic> masterDevice = Map.from(currentMaster);
        masterDevice['isMaster'] = false;
        await deviceRepository.addSavedDevice(masterDevice);
      }

      // Reload to get fresh device data
      final List<Map<String, dynamic>> allDevices = await deviceRepository
          .listSavedDevices();
      final Map<String, dynamic> deviceToUpdate = allDevices.firstWhere(
        (d) => d['id'] == deviceId,
        orElse: () => <String, dynamic>{},
      );
      if (deviceToUpdate.isNotEmpty) {
        final Map<String, dynamic> updatedDevice = Map.from(deviceToUpdate);
        updatedDevice['isMaster'] = true;
        await deviceRepository.addSavedDevice(updatedDevice);
      }

      // Reload
      await initialize();

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

  /// Move device to another group.
  Future<bool> moveGroup(String deviceId, String targetGroupId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Check if target group is full (max 4 devices)
      final _DeviceGroup targetGroup = _groups.firstWhere(
        (g) => g.id == targetGroupId,
        orElse: () => _DeviceGroup(id: targetGroupId, devices: []),
      );

      if (targetGroup.devices.length >= 4) {
        _setError(AppErrorCode.invalidParam);
        return false;
      }

      // Update device group using addSavedDevice
      final List<Map<String, dynamic>> allDevices = await deviceRepository
          .listSavedDevices();
      final Map<String, dynamic> deviceToUpdate = allDevices.firstWhere(
        (d) => d['id'] == deviceId,
        orElse: () => <String, dynamic>{},
      );
      if (deviceToUpdate.isNotEmpty) {
        final Map<String, dynamic> updatedDevice = Map.from(deviceToUpdate);
        updatedDevice['group'] = targetGroupId;
        updatedDevice['isMaster'] = false; // New device in group is not master
        await deviceRepository.addSavedDevice(updatedDevice);
      }

      // Reload
      await initialize();

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

  /// Get group sizes for display.
  List<int> getGroupSizes() {
    return _groups.map((group) => group.devices.length).toList();
  }

  void _setError(AppErrorCode code) {
    _lastErrorCode = code;
  }

  void _clearError() {
    _lastErrorCode = null;
  }
}

class _DeviceGroup {
  final String id;
  final List<Map<String, dynamic>> devices;

  const _DeviceGroup({required this.id, required this.devices});
}
