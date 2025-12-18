import 'dart:typed_data';

/// Thin abstraction for BLE write operations.
abstract class BleAdapter {
  Future<void> write({
    required String serviceUuid,
    required String characteristicUuid,
    required List<int> payload,
  });

  Future<void> writeBytes({
    required String serviceUuid,
    required String characteristicUuid,
    required Uint8List payload,
  });
}
