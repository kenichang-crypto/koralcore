import '../../domain/warning/warning.dart';

/// WarningRepository
///
/// Repository interface for managing device warnings.
///
/// Note: BLE opcodes 0x2C (LED) and 0x7B (Dosing) for getting warnings
/// are defined in reef-b-app but not implemented. This interface is
/// provided for future implementation.
abstract class WarningRepository {
  /// Observes warnings for a specific device.
  Stream<List<Warning>> observeWarnings(String deviceId);

  /// Gets current warnings for a specific device.
  Future<List<Warning>> getWarnings(String deviceId);

  /// Deletes a warning by ID.
  Future<void> deleteWarning(int warningId);

  /// Deletes all warnings for a device.
  Future<void> clearWarnings(String deviceId);

  /// Gets all warnings (across all devices).
  Future<List<Warning>> getAllWarnings();

  /// Clears all warnings (across all devices).
  Future<void> clearAllWarnings();
}

