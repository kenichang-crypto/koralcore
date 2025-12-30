library;

import '../../domain/led_lighting/led_record_state.dart';
import '../../platform/contracts/led_record_repository.dart';
import 'led_record_guard.dart';

class StartLedPreviewUseCase {
  const StartLedPreviewUseCase({required this.repository});

  final LedRecordRepository repository;

  Future<LedRecordState> execute({required String deviceId, String? recordId}) {
    ensureDeviceId(deviceId);
    if (recordId != null) {
      ensureRecordId(recordId);
    }
    return repository.startPreview(deviceId: deviceId, recordId: recordId);
  }
}
