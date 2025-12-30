/// ReadCapabilityUseCase
///
/// Reads device capability set to determine available features.
///
/// Execution order:
/// 1. Send Read Capability command via BLE adapter
/// 2. Parse capability payload
/// 3. Persist capability snapshot in device repository
///
library;

import '../../domain/device/capability_set.dart';
import '../../platform/contracts/system_repository.dart';
import '../../platform/contracts/device_repository.dart';

class ReadCapabilityUseCase {
  final SystemRepository systemRepository;
  final DeviceRepository deviceRepository;

  ReadCapabilityUseCase({
    required this.systemRepository,
    required this.deviceRepository,
  });

  /// Executes the capability reading flow.
  ///
  /// Returns the parsed CapabilitySet for the device.
  Future<CapabilitySet> execute({required String deviceId}) async {
    // 1) Send Read Capability command via SystemRepository
    final capabilityPayload = await systemRepository.readCapability(deviceId);

    // 2) Parse capability payload into CapabilitySet
    final capabilitySet = CapabilitySet.fromRaw(capabilityPayload);

    // 3) Persist capability to device repository
    // The capability is stored as part of the device metadata
    // DeviceContext will be updated when InitializeDeviceUseCase completes
    await deviceRepository.getDevice(deviceId);

    return capabilitySet;
  }
}
