/// RemoveDeviceUseCase
///
/// Removes a device from local listing and ensures BLE connection closed.
///
/// Execution order:
/// 1. Ensure device disconnected (call DisconnectDeviceUseCase)
/// 2. Remove device from local repository
/// 3. Update state / notify UI
///
library;

import '../../platform/contracts/device_repository.dart';
import '../session/current_device_session.dart';

class RemoveDeviceUseCase {
  final DeviceRepository deviceRepository;
  final CurrentDeviceSession currentDeviceSession;

  RemoveDeviceUseCase({
    required this.deviceRepository,
    required this.currentDeviceSession,
  });

  Future<void> execute({required String deviceId}) async {
    // 1) Ensure disconnected
    // TODO: await DisconnectDeviceUseCase().execute(deviceId: deviceId)

    // 2) Remove from device repository
    // TODO: await deviceRepository.remove(deviceId)
    await deviceRepository.removeDevice(deviceId);

    // 3) Clear any lingering session when the device disappears entirely.
    currentDeviceSession.clear();

    // 4) Notify presentation / update currentDevice if needed
    // TODO: notify UI to refresh device list
  }
}
