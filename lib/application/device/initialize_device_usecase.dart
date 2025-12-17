/// InitializeDeviceUseCase
///
/// Performs the Initialize sequence described in docs/reef_b_app_behavior.md
/// Execution sequence (on connect):
/// 1. Read Device Info
/// 2. Read Firmware Version
/// 3. Read Product ID (if applicable)
/// 4. Read Capability
/// 5. Sync Time
/// 6. Mark device -> Ready
///
/// Each step should call the corresponding system usecase (system layer)
/// Adapters / Repositories called:
/// - BLE adapter for system commands
/// - Device repository to persist device metadata
///
import '../../platform/contracts/device_repository.dart';
import '../../platform/contracts/system_repository.dart';

class InitializeDeviceUseCase {
  final DeviceRepository deviceRepository;
  final SystemRepository systemRepository;

  InitializeDeviceUseCase({
    required this.deviceRepository,
    required this.systemRepository,
  });

  Future<void> execute({required String deviceId}) async {
    // 1) Read Device Info
    // TODO: await ReadDeviceInfoUseCase().execute(deviceId: deviceId)
    final deviceInfo = await systemRepository.readDeviceInfo(deviceId);
    // TODO: persist metadata
    await deviceRepository.getDevice(deviceId); // placeholder to show usage

    // 2) Read Firmware Version
    // TODO: await ReadFirmwareVersionUseCase().execute(deviceId: deviceId)
    final fw = await systemRepository.readFirmwareVersion(deviceId);
    // TODO: deviceRepository.saveFirmware(deviceId, fw)

    // 3) Read Product ID (if applicable)
    // TODO: await ReadDeviceInfoUseCase.productId or separate usecase

    // 4) Read Capability
    // TODO: await ReadCapabilityUseCase().execute(deviceId: deviceId)
    final caps = await systemRepository.readCapability(deviceId);
    // TODO: capabilityRegistry.register(deviceId, caps)

    // 5) Sync Time
    // TODO: await SyncTimeUseCase().execute(deviceId: deviceId)
    await systemRepository.syncTime(deviceId, DateTime.now());

    // 6) Mark device as Ready
    // TODO: deviceRepository.updateState(deviceId, DeviceState.ready)
    await deviceRepository.updateDeviceState(deviceId, 'ready');
    // TODO: notify presentation to open device feature pages
  }
}
