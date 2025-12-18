/// DeviceRepository
///
/// Abstract interface for device lifecycle data access and basic state management.
///
/// NOTE:
/// - This file only declares method signatures (no implementations).
/// - Domain models are referenced as placeholders (use existing domain models where available).
/// - Do NOT introduce platform-specific imports or implementations here.
library;

abstract class DeviceRepository {
  const DeviceRepository();

  /// Start scanning for devices.
  /// Returns a list of discovered device descriptors or completes when scan ends.
  ///
  /// TODO: Replace `Map<String, dynamic>` with a concrete `DeviceDescriptor` domain model.
  Future<List<Map<String, dynamic>>> scanDevices({Duration? timeout});

  /// Add a device to local listing.
  /// `device` may be a descriptor or device id with metadata.
  Future<void> addDevice(String deviceId, {Map<String, dynamic>? metadata});

  /// Establish a connection to the device (platform/adapter drives actual BLE connect).
  Future<void> connect(String deviceId);

  /// Disconnect from a connected device.
  Future<void> disconnect(String deviceId);

  /// Remove device from local listing.
  Future<void> removeDevice(String deviceId);

  /// Set current active device in application context.
  Future<void> setCurrentDevice(String deviceId);

  /// Get current active device id, or null if none.
  Future<String?> getCurrentDevice();

  /// Update device lifecycle/state (e.g., connecting, ready, disconnected).
  ///
  /// TODO: Replace `String state` with a `DeviceState` enum from domain.
  Future<void> updateDeviceState(String deviceId, String state);

  /// Observe device list/state changes. Returns a stream of device descriptors.
  ///
  /// TODO: Replace payload type with concrete domain models.
  Stream<List<Map<String, dynamic>>> observeDevices();

  /// Optional: retrieve persisted device state or metadata.
  Future<Map<String, dynamic>?> getDevice(String deviceId);

  /// Optional: retrieve cached device state (e.g., last known state)
  Future<String?> getDeviceState(String deviceId);
}
