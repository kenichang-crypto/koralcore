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

import '../../data/ble/ble_notify_bus.dart';
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
    final deviceInfo = await systemRepository.readDeviceInfo(deviceId);
    await deviceRepository.getDevice(deviceId); // placeholder to show usage

    // 2) Read Firmware Version
    final firmwareVersionString = await systemRepository.readFirmwareVersion(
      deviceId,
    );
    final firmware = FirmwareVersion(firmwareVersionString);

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

    BleNotifyBus.instance.registerDoseFactor(
      deviceId,
      deviceContext.product.doseRawToMlFactor,
    );

    // DeviceContext is the single source of truth for downstream use cases.
    // All other application flows must depend on this context instead of
    // re-deriving firmware or capability knowledge to keep behavior aligned.

    // 5) Sync Time
    await systemRepository.syncTime(deviceId, DateTime.now());

    // 6) Mark device as Ready
    await deviceRepository.updateDeviceState(deviceId, 'ready');

    // Establish the session so every other use case can read a consistent
    // DeviceContext without caching its own copy. Use cases must always read
    // from this session instead of persisting their own context references.
    currentDeviceSession.start(deviceContext);

    return deviceContext;
  }
}
