library;

import '../../domain/led_lighting/led_record_state.dart';
import '../../platform/contracts/led_record_repository.dart';
import 'led_record_guard.dart';

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
