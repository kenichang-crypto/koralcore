/// ResetDeviceUseCase
///
/// Triggers factory reset if device supports it.
/// This command may not be supported by all product variants.
///
/// Execution order:
/// 1. Verify device supports Reset (capability)
/// 2. Send Reset command via BLE adapter
/// 3. Await result and update repository
///
library;

import '../../platform/contracts/system_repository.dart';
import '../../platform/contracts/device_repository.dart';

class ResetDeviceUseCase {
  final SystemRepository systemRepository;
  final DeviceRepository deviceRepository;

  ResetDeviceUseCase({
    required this.systemRepository,
    required this.deviceRepository,
  });

  Future<void> execute({required String deviceId}) async {
    // 1) Verify capability
    // TODO: if (!capabilityRegistry.supports(deviceId, CapabilityId.reset)) return

    // 2) Send reset command
    // TODO: await bleAdapter.reset(deviceId)
    await systemRepository.reset(deviceId);

    // 3) Persist result
    // TODO: deviceRepository.updateState(deviceId, DeviceState.resetting)
    await deviceRepository.updateDeviceState(deviceId, 'resetting');
  }
}
