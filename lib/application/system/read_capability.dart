/// ReadCapabilityUseCase
///
/// Reads device capability set to determine available features.
///
/// Execution order:
/// 1. Send Read Capability command via BLE adapter
/// 2. Parse capability payload
/// 3. Persist capability snapshot in capability registry / device repo
///
import '../../platform/contracts/system_repository.dart';
import '../../platform/contracts/device_repository.dart';

class ReadCapabilityUseCase {
  final SystemRepository systemRepository;
  final DeviceRepository deviceRepository;

  ReadCapabilityUseCase({
    required this.systemRepository,
    required this.deviceRepository,
  });

  Future<void> execute({required String deviceId}) async {
    // 1) Send command
    // TODO: final resp = await bleAdapter.readCapability(deviceId)
    final resp = await systemRepository.readCapability(deviceId);

    // 2) Parse capability
    // TODO: final caps = parseCapability(resp)

    // 3) Persist capability
    // TODO: capabilityRegistry.register(deviceId, caps)
    // TODO: deviceRepository.saveCapabilities(deviceId, caps)
    await deviceRepository.getDevice(deviceId); // placeholder usage
  }
}
