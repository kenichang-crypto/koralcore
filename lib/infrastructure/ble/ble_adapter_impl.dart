import 'dart:typed_data';

import 'ble_adapter.dart';

/// Concrete BLE adapter that delegates to the platform BLE stack.
class BleAdapterImpl implements BleAdapter {
  const BleAdapterImpl();

  @override
  Future<void> write({
    required String serviceUuid,
    required String characteristicUuid,
    required List<int> payload,
  }) async {
    // TODO: Invoke underlying BLE library write with provided service/characteristic.
    // TODO: Ensure the call handles List<int> payload without additional mutation.
  }

  @override
  Future<void> writeBytes({
    required String serviceUuid,
    required String characteristicUuid,
    required Uint8List payload,
  }) async {
    // TODO: Invoke underlying BLE library write with provided service/characteristic.
    // TODO: Ensure the call handles Uint8List payload without additional mutation.
  }
}
