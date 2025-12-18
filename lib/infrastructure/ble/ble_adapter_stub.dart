import 'dart:typed_data';

import 'ble_adapter.dart';
import 'transport/ble_transport_models.dart';

class BleAdapterStub implements BleAdapter {
  @override
  Future<void> write({
    required String deviceId,
    required List<int> data,
    BleWriteOptions? options,
  }) async {
    // No-op stub implementation.
  }

  @override
  Future<void> writeBytes({
    required String deviceId,
    required Uint8List data,
    BleWriteOptions? options,
  }) async {
    // No-op stub implementation.
  }
}
