import 'ble_record.dart';
import 'ble_recorder.dart';

class InMemoryBleRecorder implements BleRecorder {
  final List<BleRecord> _records = [];

  @override
  void record(BleRecord record) {
    _records.add(record);
  }

  List<BleRecord> snapshot() => List.unmodifiable(_records);

  void clear() => _records.clear();
}
