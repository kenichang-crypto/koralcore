import 'dart:typed_data';

/// Envelope emitted for every BLE notification received from the platform.
class BleNotifyPacket {
  final String deviceId;
  final int opcode;
  final Uint8List payload;
  final DateTime timestamp;
  final String? characteristic;

  const BleNotifyPacket({
    required this.deviceId,
    required this.opcode,
    required this.payload,
    required this.timestamp,
    this.characteristic,
  });

  /// Attempts to parse a notification envelope coming from the platform side.
  static BleNotifyPacket? fromEnvelope(Map<Object?, Object?>? envelope) {
    if (envelope == null) {
      return null;
    }
    final Object? deviceIdRaw = envelope['deviceId'];
    final Uint8List? payload = _extractPayload(envelope['payload']);
    if (deviceIdRaw is! String || payload == null) {
      return null;
    }
    final int opcode = _parseOpcode(envelope['opcode']);
    final int timestampMs = _parseTimestamp(envelope['timestamp']);
    final DateTime timestamp = DateTime.fromMillisecondsSinceEpoch(
      timestampMs,
      isUtc: false,
    );
    final String? characteristic = envelope['characteristic'] as String?;
    return BleNotifyPacket(
      deviceId: deviceIdRaw,
      opcode: opcode,
      payload: payload,
      timestamp: timestamp,
      characteristic: characteristic,
    );
  }

  static Uint8List? _extractPayload(Object? rawPayload) {
    if (rawPayload is Uint8List) {
      return rawPayload;
    }
    if (rawPayload is List) {
      return Uint8List.fromList(rawPayload.cast<int>());
    }
    return null;
  }

  static int _parseOpcode(Object? rawOpcode) {
    if (rawOpcode is int) {
      return rawOpcode;
    }
    return -1;
  }

  static int _parseTimestamp(Object? rawTimestamp) {
    if (rawTimestamp is int) {
      return rawTimestamp;
    }
    if (rawTimestamp is double) {
      return rawTimestamp.round();
    }
    return DateTime.now().millisecondsSinceEpoch;
  }
}
