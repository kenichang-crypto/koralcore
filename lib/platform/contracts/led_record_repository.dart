library;

import '../../domain/led_lighting/led_record_state.dart';

/// Repository surface dedicated to LED record orchestration.
abstract class LedRecordRepository {
  Stream<LedRecordState> observeState(String deviceId);

  Future<LedRecordState> getState(String deviceId);

  Future<LedRecordState> refresh(String deviceId);

  Future<LedRecordState> deleteRecord({
    required String deviceId,
    required String recordId,
  });

  Future<LedRecordState> clearRecords(String deviceId);

  Future<LedRecordState> startPreview({
    required String deviceId,
    String? recordId,
  });

  Future<LedRecordState> stopPreview(String deviceId);
}
