/// AddDeviceUseCase
///
/// Orchestrates adding a discovered device into local storage/list.
///
/// Execution order:
/// 1. Validate selection from UI (device identifier present)
/// 2. Persist device in local repository (adapter: DeviceRepository.add)
/// 3. Set state: added (but not initialized)
///
/// Adapters / Repositories called:
/// - Local Device Repository (e.g. deviceRepo.add(device))
/// - Optional: Capability registry update (platform)
///
import '../../platform/contracts/device_repository.dart';

class AddDeviceUseCase {
  final DeviceRepository deviceRepository;

  AddDeviceUseCase({required this.deviceRepository});

  Future<void> execute({required String deviceId}) async {
    // 1) Validate input
    // TODO: ensure deviceId is provided; return failure if missing

    // 2) Persist device to local storage
    // TODO: await deviceRepository.add(deviceId)
    await deviceRepository.addDevice(deviceId);

    // 3) Update state: device listed (not connected/initialized)
    // TODO: notify presentation
  }
}
