/// SystemRepository
///
/// Abstract interface that exposes System / Device BLE commands
/// used by Application UseCases (Initialize sequence and system controls).
///
/// NOTE:
/// - Only method signatures are declared here. No implementations.
/// - Payload types are placeholders and should be replaced by domain models.

abstract class SystemRepository {
  const SystemRepository();

  /// Read device info (device_name, product_id, serial_number, hw_version)
  ///
  /// TODO: Replace return type with concrete `DeviceInfo` domain model.
  Future<Map<String, dynamic>> readDeviceInfo(String deviceId);

  /// Read firmware version string.
  Future<String> readFirmwareVersion(String deviceId);

  /// Read capability payload. Returns structured capability data.
  ///
  /// TODO: Replace return type with `CapabilitySet` domain model when available.
  Future<Map<String, dynamic>> readCapability(String deviceId);

  /// Sync device time with provided timestamp.
  Future<void> syncTime(String deviceId, DateTime timestamp);

  /// Trigger device reboot.
  Future<void> reboot(String deviceId);

  /// Trigger factory reset if supported.
  Future<void> reset(String deviceId);
}
