library;

import '../../led_lighting/led_record_state.dart';
import '../../../platform/contracts/led_record_repository.dart';
import 'led_record_guard.dart';

/// DeleteLedRecordUseCase
///
/// PARITY: Corresponds to reef-b-app's LED record deletion:
/// - LedRecordActivity: deletes specific record via BLE command
/// - CommandManager.getLedDeleteRecordCommand() -> BLE opcode 0x2D (with hour/minute)
/// - On success: removes record from LedInformation, updates chart, shows toast
/// - Deletes record at specific time point (hour, minute)
class DeleteLedRecordUseCase {
  const DeleteLedRecordUseCase({required this.repository});

  final LedRecordRepository repository;

  Future<LedRecordState> execute({
    required String deviceId,
    required String recordId,
  }) {
    ensureDeviceId(deviceId);
    ensureRecordId(recordId);
    return repository.deleteRecord(deviceId: deviceId, recordId: recordId);
  }
}
