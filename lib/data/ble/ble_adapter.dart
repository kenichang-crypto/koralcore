import 'dart:typed_data';

import 'transport/ble_transport_models.dart';

/// Thin abstraction for BLE write operations.
abstract class BleAdapter {
  Future<void> write({
    required String deviceId,
    required List<int> data,
    BleWriteOptions? options,
  });

  Future<void> writeBytes({
    required String deviceId,
    required Uint8List data,
    BleWriteOptions? options,
  });

  Future<List<int>?> read({
    required String deviceId,
    required List<int> data,
    BleWriteOptions? options,
  });

  Future<List<int>?> readBytes({
    required String deviceId,
    required Uint8List data,
    BleWriteOptions? options,
  });
}
