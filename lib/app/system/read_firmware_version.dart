/// ReadFirmwareVersionUseCase
///
/// Reads firmware version from device.
///
/// Execution order:
/// 1. Send Read Firmware Version command via BLE adapter
/// 2. Parse firmware_version string
/// 3. Persist to device repository
///
library;

import '../../platform/contracts/system_repository.dart';
import '../../platform/contracts/device_repository.dart';

class ReadFirmwareVersionUseCase {
  final SystemRepository systemRepository;
  final DeviceRepository deviceRepository;

  ReadFirmwareVersionUseCase({
    required this.systemRepository,
    required this.deviceRepository,
  });

  Future<void> execute({required String deviceId}) async {
    // 1) Send command
    // TODO: final resp = await bleAdapter.readFirmwareVersion(deviceId)
    await systemRepository.readFirmwareVersion(deviceId);

    // 2) Parse firmware version
    // TODO: final fw = parseFirmware(resp)

    // 3) Persist firmware info
    // TODO: deviceRepository.saveFirmware(deviceId, fw)
    // placeholder to show usage
    await deviceRepository.getDevice(deviceId);
  }
}
