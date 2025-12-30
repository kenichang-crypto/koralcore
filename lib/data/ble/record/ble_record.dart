import 'ble_record_type.dart';

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
}
