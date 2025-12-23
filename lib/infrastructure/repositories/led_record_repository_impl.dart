library;

import '../../application/led/led_record_store.dart';
import '../../domain/led_lighting/led_record_state.dart';
import '../../platform/contracts/led_record_repository.dart';

class LedRecordRepositoryImpl extends LedRecordRepository {
  LedRecordRepositoryImpl({required this.store});

  final LedRecordMemoryStore store;

  @override
  Stream<LedRecordState> observeState(String deviceId) =>
      store.observe(deviceId);

  @override
  Future<LedRecordState> getState(String deviceId) async =>
      store.snapshot(deviceId);

  @override
  Future<LedRecordState> refresh(String deviceId) {
    return store.refresh(deviceId);
  }

  @override
  Future<LedRecordState> deleteRecord({
    required String deviceId,
    required String recordId,
  }) {
    return store.deleteRecord(deviceId, recordId);
  }

  @override
  Future<LedRecordState> clearRecords(String deviceId) {
    return store.clearRecords(deviceId);
  }

  @override
  Future<LedRecordState> startPreview({
    required String deviceId,
    String? recordId,
  }) {
    return store.startPreview(deviceId, recordId: recordId);
  }

  @override
  Future<LedRecordState> stopPreview(String deviceId) {
    return store.stopPreview(deviceId);
  }
}
