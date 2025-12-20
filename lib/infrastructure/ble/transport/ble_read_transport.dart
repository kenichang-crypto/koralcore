library;

import 'dart:typed_data';

import '../ble_adapter.dart';
import 'ble_transport_models.dart';

/// Abstraction for BLE read operations so higher layers only depend on the
/// transport contract rather than the concrete adapter implementation.
abstract class BleReadTransport {
  Future<Uint8List?> read({
    required String deviceId,
    required int opcode,
    required Uint8List payload,
    BleWriteOptions? options,
  });
}

/// Default transport backed by the shared [BleAdapter] queue. This keeps the
/// read semantics (timeouts, retries, pacing) identical to write operations.
class BleAdapterReadTransport implements BleReadTransport {
  final BleAdapter _adapter;

  const BleAdapterReadTransport({required BleAdapter adapter})
    : _adapter = adapter;

  @override
  Future<Uint8List?> read({
    required String deviceId,
    required int opcode,
    required Uint8List payload,
    BleWriteOptions? options,
  }) async {
    assert(opcode >= 0, 'opcode must be non-negative');
    final List<int>? response = await _adapter.readBytes(
      deviceId: deviceId,
      data: payload,
      options: options,
    );
    if (response == null) {
      return null;
    }
    return Uint8List.fromList(response);
  }
}
