/// RebootDeviceUseCase
///
/// Triggers device reboot via system command.
///
/// Execution order:
/// 1. Send Reboot command via BLE adapter
/// 2. Optionally wait for device to drop connection
/// 3. Mark device state as rebooting; once back online, caller may reconnect
///
library;

import '../../platform/contracts/system_repository.dart';
import '../../platform/contracts/device_repository.dart';

class RebootDeviceUseCase {
  final SystemRepository systemRepository;
  final DeviceRepository deviceRepository;

  RebootDeviceUseCase({
    required this.systemRepository,
    required this.deviceRepository,
  });

  Future<void> execute({required String deviceId}) async {
    // 1) Send reboot command
    // TODO: await bleAdapter.reboot(deviceId)
    await systemRepository.reboot(deviceId);

    // 2) Optionally wait for disconnect
    // TODO: await connectionObserver.waitForDisconnect(deviceId)

    // 3) Mark device state
    // TODO: deviceRepository.updateState(deviceId, DeviceState.rebooting)
    await deviceRepository.updateDeviceState(deviceId, 'rebooting');
  }
}
