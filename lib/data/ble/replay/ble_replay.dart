import '../record/ble_record.dart';

abstract class BleReplay {
  Future<void> replay({
    required List<BleRecord> records,
    required String deviceId,
  });
}
