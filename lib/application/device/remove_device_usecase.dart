/// RemoveDeviceUseCase
///
/// Removes a device from local listing and ensures BLE connection closed.
///
/// Execution order:
/// 1. Ensure device disconnected (call DisconnectDeviceUseCase)
/// 2. Remove device from local repository
/// 3. Update state / notify UI
///
import '../../platform/contracts/device_repository.dart';

class RemoveDeviceUseCase {
  final DeviceRepository deviceRepository;

  RemoveDeviceUseCase({required this.deviceRepository});

  Future<void> execute({required String deviceId}) async {
    // 1) Ensure disconnected
    // TODO: await DisconnectDeviceUseCase().execute(deviceId: deviceId)

    // 2) Remove from device repository
    // TODO: await deviceRepository.remove(deviceId)
    await deviceRepository.removeDevice(deviceId);

    // 3) Notify presentation / update currentDevice if needed
    // TODO: notify UI to refresh device list
  }
}
