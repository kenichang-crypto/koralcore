library;

import '../../led_lighting/led_record_state.dart';
import '../../../platform/contracts/led_record_repository.dart';
import 'led_record_guard.dart';

/// ClearLedRecordsUseCase
///
/// PARITY: Corresponds to reef-b-app's LED record clearing:
/// - LedRecordActivity: clears all records via BLE command
/// - CommandManager.getLedClearRecordCommand() -> BLE opcode 0x30
/// - On success: clears LedInformation records, updates chart, shows toast
/// - Clears all schedule time points and channel levels
class ClearLedRecordsUseCase {
  const ClearLedRecordsUseCase({required this.repository});

  final LedRecordRepository repository;

  Future<LedRecordState> execute({required String deviceId}) {
    ensureDeviceId(deviceId);
    return repository.clearRecords(deviceId);
  }
}
