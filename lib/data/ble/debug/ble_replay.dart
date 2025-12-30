import 'ble_record.dart';

/// Abstraction for replaying recorded BLE writes against a target device.
abstract class BleReplay {
  Future<void> replay({
    required List<BleRecord> records,
    required String deviceId,
  });
}
