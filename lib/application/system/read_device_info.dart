/// ReadDeviceInfoUseCase
///
/// Reads basic device info via system BLE commands.
///
/// Execution order:
/// 1. Send Read Device Info command via BLE adapter
/// 2. Parse response into device metadata (name, product id, sn, hw)
/// 3. Persist to device repository
///
/// Adapters / Repositories called:
/// - BLE adapter (system command)
/// - Device repository (persist metadata)
///
import '../../platform/contracts/system_repository.dart';
import '../../platform/contracts/device_repository.dart';

class ReadDeviceInfoUseCase {
  final SystemRepository systemRepository;
  final DeviceRepository deviceRepository;

  ReadDeviceInfoUseCase({
    required this.systemRepository,
    required this.deviceRepository,
  });

  Future<void> execute({required String deviceId}) async {
    // 1) Send Read Device Info command
    // TODO: final resp = await bleAdapter.readDeviceInfo(deviceId)
    final resp = await systemRepository.readDeviceInfo(deviceId);

    // 2) Parse response
    // TODO: parse resp -> {device_name, product_id, serial_number, hw_version}

    // 3) Persist metadata
    // TODO: deviceRepository.saveMetadata(deviceId, metadata)
    await deviceRepository.getDevice(deviceId); // placeholder to show usage
  }
}
