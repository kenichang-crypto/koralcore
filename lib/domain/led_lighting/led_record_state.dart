library;

import 'led_record.dart';

enum LedRecordStatus { idle, previewing, applying, error }

class LedRecordState {
  final String deviceId;
  final LedRecordStatus status;
  final String? previewingRecordId;
  final List<LedRecord> records;

  LedRecordState({
    required this.deviceId,
    required this.status,
    required List<LedRecord> records,
    this.previewingRecordId,
  }) : records = List<LedRecord>.unmodifiable(records);

  bool get isPreviewing =>
      status == LedRecordStatus.previewing && previewingRecordId != null;

  LedRecordState copyWith({
    LedRecordStatus? status,
    Object? previewingRecordId = _sentinel,
    List<LedRecord>? records,
  }) {
    return LedRecordState(
      deviceId: deviceId,
      status: status ?? this.status,
      previewingRecordId: identical(previewingRecordId, _sentinel)
          ? this.previewingRecordId
          : previewingRecordId as String?,
      records: records ?? this.records,
    );
  }

  factory LedRecordState.initial({
    required String deviceId,
    required List<LedRecord> records,
  }) {
    return LedRecordState(
      deviceId: deviceId,
      status: LedRecordStatus.idle,
      previewingRecordId: null,
      records: records,
    );
  }
}

const Object _sentinel = Object();
