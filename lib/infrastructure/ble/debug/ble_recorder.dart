library;

import 'ble_record.dart';

/// Passive recorder API for BLE traffic.
abstract class BleRecorder {
  void record(BleRecord record);
}
