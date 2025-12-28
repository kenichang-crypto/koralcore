import '../../domain/warning/warning.dart';
import '../../platform/contracts/warning_repository.dart';

/// WarningRepositoryImpl
///
/// Implementation of WarningRepository.
///
/// Note: BLE opcodes 0x2C (LED GET_WARNING) and 0x7B (DROPPING GET_WARNING)
/// are defined in reef-b-app CommandManager but not implemented in the
/// Android app. This implementation provides a placeholder that returns
/// empty lists until BLE protocol is implemented.
///
/// TODO: Implement BLE warning fetching once protocol is available:
/// - 0x2C: LED warnings
/// - 0x7B: Dosing warnings
class WarningRepositoryImpl implements WarningRepository {
  WarningRepositoryImpl();

  @override
  Stream<List<Warning>> observeWarnings(String deviceId) {
    // TODO: Implement BLE warning observation
    // For now, return empty stream
    return Stream.value(<Warning>[]);
  }

  @override
  Future<List<Warning>> getWarnings(String deviceId) async {
    // TODO: Implement BLE warning fetching
    // - Send GET_WARNING command (0x2C for LED, 0x7B for Dosing)
    // - Parse response payload
    // - Return list of warnings
    return <Warning>[];
  }

  @override
  Future<void> deleteWarning(int warningId) async {
    // TODO: Implement warning deletion
    // This may require BLE command or local database operation
  }

  @override
  Future<void> clearWarnings(String deviceId) async {
    // TODO: Implement warning clearing
    // This may require BLE command or local database operation
  }

  @override
  Future<List<Warning>> getAllWarnings() async {
    // TODO: Implement getting all warnings from all devices
    // For now, return empty list
    return <Warning>[];
  }

  @override
  Future<void> clearAllWarnings() async {
    // TODO: Implement clearing all warnings
    // This may require BLE command or local database operation
  }
}

