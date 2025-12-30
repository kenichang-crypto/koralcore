library;

import 'ble_record.dart';
import 'ble_recorder.dart';

/// Default in-memory implementation of [BleRecorder].
class InMemoryBleRecorder implements BleRecorder {
  final List<BleRecord> _records = <BleRecord>[];

  @override
  void record(BleRecord record) {
    _records.add(record);
  }

  List<BleRecord> snapshot() => List.unmodifiable(_records);

  void clear() => _records.clear();
}
