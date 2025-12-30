/// UpdateDeviceSinkUseCase
///
/// Updates device sink assignment and group allocation.
///
/// PARITY: Matches reef-b-app's LedSettingViewModel.editDevice() and DropSettingViewModel.editDevice() behavior.
///
/// For LED devices:
/// - Automatically assigns to available group (A-E, max 4 devices per group)
/// - Sets master = false when moving to new sink
/// - Clears group and master when unassigning from sink
///
/// For DROP devices:
/// - Checks sink capacity (max 4 DROP devices per sink)
/// - Clears group and master when unassigning from sink
///
library;

import '../../platform/contracts/device_repository.dart';
import '../common/app_error.dart';
import '../common/app_error_code.dart';

class UpdateDeviceSinkUseCase {
  final DeviceRepository deviceRepository;

  UpdateDeviceSinkUseCase({required this.deviceRepository});

  /// Update device sink assignment.
  ///
  /// [deviceId] - Device to update
  /// [newSinkId] - New sink ID (null or empty string = unassign)
  /// [currentSinkId] - Current sink ID (for comparison)
  /// [deviceType] - Device type ('LED' or 'DROP')
  /// [currentGroup] - Current group (for LED devices)
  /// [currentMaster] - Current master status (for LED devices)
  ///
  /// Returns the assigned group for LED devices, or null if unassigned.
  /// Throws AppError if sink is full or device cannot be moved.
  Future<String?> execute({
    required String deviceId,
    String? newSinkId,
    String? currentSinkId,
    required String? deviceType,
    String? currentGroup,
    bool? currentMaster,
  }) async {
    // Normalize newSinkId: empty string or null = unassign
    final String? normalizedNewSinkId =
        (newSinkId == null || newSinkId.isEmpty) ? null : newSinkId;

    // If sink hasn't changed, no update needed
    if (normalizedNewSinkId == currentSinkId) {
      return currentGroup;
    }

    // Get current device data
    final Map<String, dynamic>? deviceData =
        await deviceRepository.getDevice(deviceId);
    if (deviceData == null) {
      throw const AppError(
        code: AppErrorCode.invalidParam,
        message: 'Device not found',
      );
    }

    // Prepare update data
    final Map<String, dynamic> updates = {};

    if (normalizedNewSinkId == null) {
      // Unassign from sink
      updates['sinkId'] = null;
      if (deviceType == 'LED') {
        updates['group'] = null;
        updates['isMaster'] = null;
      }
    } else {
      // Assign to new sink
      if (deviceType == 'LED') {
        // Check if device can be moved (master restriction)
        if (currentSinkId != null &&
            currentGroup != null &&
            currentMaster == true) {
          final List<Map<String, dynamic>> groupDevices =
              await deviceRepository.getDevicesBySinkIdAndGroup(
            currentSinkId,
            currentGroup,
          );
          // If group has more than 1 device and this is master, cannot move
          if (groupDevices.length > 1) {
            throw const AppError(
              code: AppErrorCode.invalidParam,
              message: 'Master LED device cannot be moved when group has other devices',
            );
          }
        }

        // Find available group
        final String? assignedGroup = await _findAvailableGroup(normalizedNewSinkId);
        if (assignedGroup == null) {
          throw const AppError(
            code: AppErrorCode.sinkFull,
            message: 'All LED groups in this sink are full',
          );
        }

        updates['sinkId'] = normalizedNewSinkId;
        updates['group'] = assignedGroup;
        updates['isMaster'] = false; // New device in group is not master
      } else if (deviceType == 'DROP') {
        // Check DROP device capacity (max 4 per sink)
        final List<Map<String, dynamic>> dropDevices =
            await deviceRepository.getDropDevicesBySinkId(normalizedNewSinkId);
        // Exclude current device if it's already in this sink
        final int dropCount = dropDevices
            .where((d) => d['id']?.toString() != deviceId)
            .length;
        if (dropCount >= 4) {
          throw const AppError(
            code: AppErrorCode.sinkFull,
            message: 'Sink is full. Maximum 4 DROP devices per sink',
          );
        }

        updates['sinkId'] = normalizedNewSinkId;
        // DROP devices don't have group or master
      }
    }

    // Update device using addSavedDevice (which updates if exists)
    final Map<String, dynamic> updatedDevice = Map.from(deviceData);
    updatedDevice.addAll(updates);
    await deviceRepository.addSavedDevice(updatedDevice);

    return updates['group'] as String?;
  }

  /// Find available group in sink for LED device.
  ///
  /// PARITY: Matches reef-b-app's LedSettingViewModel.addToWhichGroup().
  /// Checks groups A-E in order, returns first group with < 4 devices.
  Future<String?> _findAvailableGroup(String sinkId) async {
    final List<Map<String, dynamic>> sinkDevices =
        await deviceRepository.getDevicesBySinkId(sinkId);
    final List<Map<String, dynamic>> ledDevices = sinkDevices
        .where((d) => d['type']?.toString() == 'LED')
        .toList();

    // Count devices per group
    final Map<String, int> groupCounts = {'A': 0, 'B': 0, 'C': 0, 'D': 0, 'E': 0};
    for (final device in ledDevices) {
      final String? group = device['group']?.toString();
      if (group != null && groupCounts.containsKey(group)) {
        groupCounts[group] = (groupCounts[group] ?? 0) + 1;
      }
    }

    // Find first group with < 4 devices
    for (final group in ['A', 'B', 'C', 'D', 'E']) {
      if ((groupCounts[group] ?? 0) < 4) {
        return group;
      }
    }

    return null; // All groups are full
  }
}

