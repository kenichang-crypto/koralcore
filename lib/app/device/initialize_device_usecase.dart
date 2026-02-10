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
library;

import '../../domain/device/capability/capability_id.dart';
import '../../domain/device/capability_set.dart';
import '../../domain/device/device_context.dart';
import '../../domain/device/device_product.dart';
import '../../domain/device/device_product_resolver.dart';
import '../../domain/device/firmware_version.dart';
import '../../platform/contracts/device_repository.dart';
import '../../platform/contracts/system_repository.dart';
import '../session/current_device_session.dart';

class InitializeDeviceUseCase {
  final DeviceRepository deviceRepository;
  final SystemRepository systemRepository;
  final CurrentDeviceSession currentDeviceSession;
  final DeviceProductResolver deviceProductResolver;

  InitializeDeviceUseCase({
    required this.deviceRepository,
    required this.systemRepository,
    required this.currentDeviceSession,
    this.deviceProductResolver = const DeviceProductResolver(),
  });

  Future<DeviceContext> execute({required String deviceId}) async {
    // 1) Read Device Info
    // TODO: await ReadDeviceInfoUseCase().execute(deviceId: deviceId)
    final deviceInfo = await systemRepository.readDeviceInfo(deviceId);
    // TODO: persist metadata
    await deviceRepository.getDevice(deviceId); // placeholder to show usage

    // 2) Read Firmware Version
    // TODO: await ReadFirmwareVersionUseCase().execute(deviceId: deviceId)
    final firmwareVersionString = await systemRepository.readFirmwareVersion(
      deviceId,
    );
    final firmware = FirmwareVersion(firmwareVersionString);
    // TODO: deviceRepository.saveFirmware(deviceId, firmware)

    // 3) Read Product ID (if applicable)
    // Use 'product' field if available (internal ID), otherwise 'device_name'
    final productIdentity =
        deviceInfo['product'] as String? ??
        deviceInfo['device_name'] as String?;

    // 4) Read Capability
    final capabilityPayload = await systemRepository.readCapability(deviceId);
    final capabilitySet = CapabilitySet.fromRaw(capabilityPayload);
    // Capability is stored in DeviceContext, which is the single source of truth

    // Resolve Product using authoritative resolver (no heuristics)
    final product = deviceProductResolver.resolve(productIdentity);

    final deviceContext = DeviceContext(
      deviceId: deviceId,
      product: product,
      firmware: firmware,
      capabilities: capabilitySet,
    );

    // DeviceContext is the single source of truth for downstream use cases.
    // All other application flows must depend on this context instead of
    // re-deriving firmware or capability knowledge to keep behavior aligned.

    // 5) Sync Time
    // TODO: await SyncTimeUseCase().execute(deviceId: deviceId)
    await systemRepository.syncTime(deviceId, DateTime.now());

    // 6) Mark device as Ready
    // TODO: deviceRepository.updateState(deviceId, DeviceState.ready)
    await deviceRepository.updateDeviceState(deviceId, 'ready');
    // TODO: notify presentation to open device feature pages

    // Establish the session so every other use case can read a consistent
    // DeviceContext without caching its own copy. Use cases must always read
    // from this session instead of persisting their own context references.
    currentDeviceSession.start(deviceContext);

    return deviceContext;
  }
}
