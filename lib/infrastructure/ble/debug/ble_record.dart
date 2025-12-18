library;

import 'ble_record_type.dart';

/// Immutable snapshot of a BLE event captured by the recorder.
class BleRecord {
  final DateTime timestamp;
  final String deviceId;
  final BleRecordType type;
  final int opcode;
  final List<int> payload;

  const BleRecord({
    required this.timestamp,
    required this.deviceId,
    required this.type,
    required this.opcode,
    required this.payload,
  });

  /// Helper factory that defensively copies the payload bytes.
  factory BleRecord.capture({
    required DateTime timestamp,
    required String deviceId,
    required BleRecordType type,
    required int opcode,
    required List<int> payload,
  }) {
    return BleRecord(
      timestamp: timestamp,
      deviceId: deviceId,
      type: type,
      opcode: opcode,
      payload: List<int>.unmodifiable(List<int>.from(payload)),
    );
  }
}
