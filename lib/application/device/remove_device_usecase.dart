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
    final String? currentDeviceId = await deviceRepository.getCurrentDevice();
    await deviceRepository.removeDevice(deviceId);

    if (currentDeviceId == deviceId) {
      currentDeviceSession.clear();
    }

    // TODO: notify UI to refresh device list
  }
}
