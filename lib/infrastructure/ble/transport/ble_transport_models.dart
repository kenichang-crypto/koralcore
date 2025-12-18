import 'dart:typed_data';

/// Mode describing whether the BLE write expects a response/ack from firmware.
enum BleWriteMode { withResponse, withoutResponse }

/// Options controlling BLE write transport behavior.
class BleWriteOptions {
  final BleWriteMode mode;
  final Duration timeout;
  final int maxRetries;
  final Duration interCommandDelay;
  final Duration retryDelay;

  const BleWriteOptions({
    this.mode = BleWriteMode.withResponse,
    this.timeout = const Duration(seconds: 3),
    this.maxRetries = 1,
    this.interCommandDelay = const Duration(milliseconds: 60),
    this.retryDelay = const Duration(milliseconds: 150),
  });

  BleWriteOptions copyWith({
    BleWriteMode? mode,
    Duration? timeout,
    int? maxRetries,
    Duration? interCommandDelay,
    Duration? retryDelay,
  }) {
    return BleWriteOptions(
      mode: mode ?? this.mode,
      timeout: timeout ?? this.timeout,
      maxRetries: maxRetries ?? this.maxRetries,
      interCommandDelay: interCommandDelay ?? this.interCommandDelay,
      retryDelay: retryDelay ?? this.retryDelay,
    );
  }
}

/// Transport-level event types for logging/debugging.
enum BleTransportEventType { queued, sending, retry, success, failure }

/// Result state for a command once the transport finishes processing it.
enum BleTransportResult { ack, timeout, failure }

/// Structured log entry describing a single transport event.
class BleTransportLogEntry {
  final BleTransportEventType type;
  final DateTime timestamp;
  final DateTime enqueueTimestamp;
  final DateTime? sendTimestamp;
  final String deviceId;
  final int opcode;
  final int payloadLength;
  final int attempt;
  final String message;
  final BleTransportResult? result;

  const BleTransportLogEntry({
    required this.type,
    required this.timestamp,
    required this.enqueueTimestamp,
    required this.sendTimestamp,
    required this.deviceId,
    required this.opcode,
    required this.payloadLength,
    required this.attempt,
    required this.message,
    required this.result,
  });
}

/// Observer interface for transport-level logging.
abstract class BleTransportObserver {
  void onEvent(BleTransportLogEntry entry);
}

/// Signature for the platform-specific BLE writer.
typedef BleTransportWriter =
    Future<void> Function({
      required String deviceId,
      required Uint8List payload,
      required BleWriteMode mode,
    });

class BleWriteException implements Exception {
  final String message;

  const BleWriteException(this.message);

  @override
  String toString() => 'BleWriteException: $message';
}

class BleWriteTimeoutException extends BleWriteException {
  const BleWriteTimeoutException(String message) : super(message);
}
