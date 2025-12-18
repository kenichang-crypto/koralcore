import 'dart:typed_data';

import '../ble_adapter.dart';
import '../transport/ble_transport_models.dart';

/// Sends prebuilt schedule payloads over BLE without interpreting them.
class ScheduleSender {
  final BleAdapter bleAdapter;

  const ScheduleSender({required this.bleAdapter});

  Future<void> send({
    required String deviceId,
    required List<int> payload,
    BleWriteOptions? options,
  }) async {
    await sendBytes(
      deviceId: deviceId,
      payload: Uint8List.fromList(payload),
      options: options,
    );
  }

  Future<void> sendBytes({
    required String deviceId,
    required Uint8List payload,
    BleWriteOptions? options,
  }) async {
    await bleAdapter.writeBytes(
      deviceId: deviceId,
      data: payload,
      options: options,
    );
  }
}
