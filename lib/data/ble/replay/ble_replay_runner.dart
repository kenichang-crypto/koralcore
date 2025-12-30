import '../ble_adapter.dart';
import '../record/ble_record.dart';
import '../record/ble_record_type.dart';
import 'ble_replay.dart';

class BleReplayRunner implements BleReplay {
  final BleAdapter bleAdapter;

  BleReplayRunner({required this.bleAdapter});

  @override
  Future<void> replay({
    required List<BleRecord> records,
    required String deviceId,
  }) async {
    for (final record in records) {
      if (record.type != BleRecordType.write) continue;

      await bleAdapter.write(deviceId: deviceId, data: record.payload);
    }
  }
}
