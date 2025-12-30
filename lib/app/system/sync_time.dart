/// SyncTimeUseCase
///
/// Synchronizes device clock with host time.
///
/// Execution order:
/// 1. Obtain current system time
/// 2. Send Sync Time command via BLE adapter
/// 3. Await response and persist sync result if necessary
///
library;

import '../../platform/contracts/system_repository.dart';
import '../../platform/contracts/device_repository.dart';

class SyncTimeUseCase {
  final SystemRepository systemRepository;
  final DeviceRepository deviceRepository;

  SyncTimeUseCase({
    required this.systemRepository,
    required this.deviceRepository,
  });

  Future<void> execute({required String deviceId}) async {
    // 1) Obtain time
    // TODO: final now = clock.now()
    final now = DateTime.now(); // placeholder

    // 2) Send sync command
    // TODO: final resp = await bleAdapter.syncTime(deviceId, now)
    await systemRepository.syncTime(deviceId, now);

    // 3) Handle response
    // TODO: if success -> mark lastSync in repository
    await deviceRepository.updateDeviceState(deviceId, 'time_synced');
  }
}
