import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';

import 'ble_adapter.dart';
import 'response/ble_error_code.dart';
import 'record/ble_record.dart';
import 'record/ble_record_type.dart';
import 'record/ble_recorder.dart';
import 'transport/ble_transport_models.dart';

/// Concrete BLE adapter that delegates to the platform BLE stack.
class BleAdapterImpl implements BleAdapter {
  final BleTransportWriter? transportWriter;
  final BleRecorder? recorder;
  final BleTransportObserver? observer;
  final BleWriteOptions defaultOptions;

  final Queue<_QueuedCommand> _queue = Queue<_QueuedCommand>();
  bool _isProcessing = false;
  static const Duration _defaultNoAckDequeueDelay = Duration(milliseconds: 120);

  BleAdapterImpl({
    this.transportWriter,
    this.recorder,
    this.observer,
    BleWriteOptions? defaultOptions,
  }) : defaultOptions = defaultOptions ?? const BleWriteOptions();

  @override
  Future<void> write({
    required String deviceId,
    required List<int> data,
    BleWriteOptions? options,
  }) async {
    final Uint8List bytes = Uint8List.fromList(data);
    return writeBytes(deviceId: deviceId, data: bytes, options: options);
  }

  @override
  Future<List<int>?> read({
    required String deviceId,
    required List<int> data,
    BleWriteOptions? options,
  }) async {
    final Uint8List bytes = Uint8List.fromList(data);
    return readBytes(deviceId: deviceId, data: bytes, options: options);
  }

  Future<void> _applyPostCommandDelay(_QueuedCommand command) async {
    Duration delay = command.options.interCommandDelay;
    if (command.options.mode == BleWriteMode.withoutResponse) {
      if (delay < _defaultNoAckDequeueDelay) {
        delay = _defaultNoAckDequeueDelay;
      }
    }
    if (delay <= Duration.zero) {
      return;
    }
    await Future<void>.delayed(delay);
  }

  @override
  Future<void> writeBytes({
    required String deviceId,
    required Uint8List data,
    BleWriteOptions? options,
  }) async {
    final BleWriteOptions resolved = options == null
        ? defaultOptions
        : defaultOptions.copyWith(
            mode: options.mode,
            timeout: options.timeout,
            maxRetries: options.maxRetries,
            interCommandDelay: options.interCommandDelay,
            retryDelay: options.retryDelay,
          );

    final _QueuedCommand command = _QueuedCommand(
      deviceId: deviceId,
      payload: Uint8List.fromList(data),
      options: resolved,
      enqueuedAt: DateTime.now(),
      expectsPayload: false,
    );
    _queue.add(command);
    _emitLog(
      type: BleTransportEventType.queued,
      command: command,
      attempt: 0,
      message: 'Queued payload length=${command.payload.length}',
      result: null,
    );
    _processQueue();
    return command.completer.future;
  }

  @override
  Future<List<int>?> readBytes({
    required String deviceId,
    required Uint8List data,
    BleWriteOptions? options,
  }) async {
    final BleWriteOptions resolved = options == null
        ? defaultOptions
        : defaultOptions.copyWith(
            mode: options.mode,
            timeout: options.timeout,
            maxRetries: options.maxRetries,
            interCommandDelay: options.interCommandDelay,
            retryDelay: options.retryDelay,
          );

    final _QueuedCommand command = _QueuedCommand(
      deviceId: deviceId,
      payload: Uint8List.fromList(data),
      options: resolved,
      enqueuedAt: DateTime.now(),
      expectsPayload: true,
    );
    _queue.add(command);
    _emitLog(
      type: BleTransportEventType.queued,
      command: command,
      attempt: 0,
      message: 'Queued read payload length=${command.payload.length}',
      result: null,
    );
    _processQueue();
    return command.responseCompleter!.future;
  }

  void _processQueue() {
    if (_isProcessing) {
      return;
    }
    _isProcessing = true;
    Future<void>(() async {
      while (_queue.isNotEmpty) {
        final _QueuedCommand command = _queue.first;
        try {
          await _executeCommand(command);
        } catch (error, stackTrace) {
          if (command.responseCompleter != null &&
              !command.responseCompleter!.isCompleted) {
            command.responseCompleter!.completeError(error, stackTrace);
          }
          if (!command.completer.isCompleted) {
            command.completer.completeError(error, stackTrace);
          }
        } finally {
          _queue.removeFirst();
          if (_queue.isNotEmpty) {
            await _applyPostCommandDelay(command);
          }
        }
      }
      _isProcessing = false;
      if (_queue.isNotEmpty) {
        _processQueue();
      }
    });
  }

  Future<void> _executeCommand(_QueuedCommand command) async {
    int attempt = 0;
    while (true) {
      attempt++;
      command.lastSendAt = DateTime.now();
      _emitLog(
        type: BleTransportEventType.sending,
        command: command,
        attempt: attempt,
        message: 'Sending (mode=${command.options.mode.name})',
        result: null,
      );

      try {
        final BleWriteResult result = await _performWriteWithTimeout(
          command,
          attempt,
        );
        _emitLog(
          type: BleTransportEventType.success,
          command: command,
          attempt: attempt,
          message: 'ACK received',
          result: result.status,
        );
        _recordWrite(deviceId: command.deviceId, payload: command.payload);
        if (command.responseCompleter != null &&
            !command.responseCompleter!.isCompleted) {
          command.responseCompleter!.complete(result.payload);
        }
        if (!command.completer.isCompleted) {
          command.completer.complete();
        }
        return;
      } on BleWriteTimeoutException catch (error) {
        if (attempt > command.options.maxRetries) {
          _emitLog(
            type: BleTransportEventType.failure,
            command: command,
            attempt: attempt,
            message: error.message,
            result: BleTransportResult.timeout,
          );
          if (command.responseCompleter != null &&
              !command.responseCompleter!.isCompleted) {
            command.responseCompleter!.completeError(error);
          }
          if (!command.completer.isCompleted) {
            command.completer.completeError(error);
          }
          return;
        }
        _emitLog(
          type: BleTransportEventType.retry,
          command: command,
          attempt: attempt,
          message: 'Timeout, retrying',
          result: BleTransportResult.timeout,
        );
        await Future<void>.delayed(command.options.retryDelay);
        continue;
      } on BleCommandRejectedException catch (error) {
        _emitLog(
          type: BleTransportEventType.failure,
          command: command,
          attempt: attempt,
          message: error.message,
          result: BleTransportResult.failure,
        );
        if (command.responseCompleter != null &&
            !command.responseCompleter!.isCompleted) {
          command.responseCompleter!.completeError(error);
        }
        if (!command.completer.isCompleted) {
          command.completer.completeError(error);
        }
        return;
      } on BleWriteException catch (error) {
        if (attempt > command.options.maxRetries) {
          _emitLog(
            type: BleTransportEventType.failure,
            command: command,
            attempt: attempt,
            message: error.message,
            result: BleTransportResult.failure,
          );
          if (command.responseCompleter != null &&
              !command.responseCompleter!.isCompleted) {
            command.responseCompleter!.completeError(error);
          }
          if (!command.completer.isCompleted) {
            command.completer.completeError(error);
          }
          return;
        }
        _emitLog(
          type: BleTransportEventType.retry,
          command: command,
          attempt: attempt,
          message: error.message,
          result: BleTransportResult.failure,
        );
        await Future<void>.delayed(command.options.retryDelay);
      }
    }
  }

  Future<BleWriteResult> _performWriteWithTimeout(
    _QueuedCommand command,
    int attempt,
  ) async {
    final BleTransportWriter? writer = transportWriter;
    if (writer == null) {
      throw const BleWriteException('No BLE transport writer configured.');
    }

    try {
      final Future<BleWriteResult> writerFuture = writer(
        deviceId: command.deviceId,
        payload: command.payload,
        mode: command.options.mode,
      );

      final BleWriteResult result =
          command.options.mode == BleWriteMode.withResponse
          ? await writerFuture.timeout(command.options.timeout)
          : await writerFuture;

      switch (result.status) {
        case BleTransportResult.ack:
          return result;
        case BleTransportResult.timeout:
          throw BleWriteTimeoutException(
            'Command timed out after '
            '${command.options.timeout.inMilliseconds}ms (attempt $attempt).',
          );
        case BleTransportResult.failure:
          throw BleCommandRejectedException(
            errorCode: result.errorCode ?? BleErrorCode.unknown,
            message: 'BLE command rejected.',
          );
      }
    } on TimeoutException {
      throw BleWriteTimeoutException(
        'Command timed out after ${command.options.timeout.inMilliseconds}ms '
        '(attempt $attempt).',
      );
    } on BleWriteTimeoutException {
      rethrow;
    } on BleCommandRejectedException {
      rethrow;
    } on BleWriteException {
      rethrow;
    } catch (error) {
      throw BleWriteException('BLE write failed: $error');
    }
  }

  void _recordWrite({required String deviceId, required List<int> payload}) {
    final BleRecorder? activeRecorder = recorder;
    if (activeRecorder == null) {
      return;
    }

    final int opcode = payload.isNotEmpty ? payload.first : 0;
    activeRecorder.record(
      BleRecord(
        timestamp: DateTime.now(),
        deviceId: deviceId,
        type: BleRecordType.write,
        opcode: opcode,
        payload: List<int>.from(payload),
      ),
    );
  }

  void _emitLog({
    required BleTransportEventType type,
    required _QueuedCommand command,
    required int attempt,
    required String message,
    required BleTransportResult? result,
  }) {
    final BleTransportObserver? activeObserver = observer;
    if (activeObserver == null) {
      return;
    }
    activeObserver.onEvent(
      BleTransportLogEntry(
        type: type,
        timestamp: DateTime.now(),
        enqueueTimestamp: command.enqueuedAt,
        sendTimestamp: command.lastSendAt,
        deviceId: command.deviceId,
        opcode: command.payload.isNotEmpty ? command.payload.first : -1,
        payloadLength: command.payload.length,
        attempt: attempt,
        message: message,
        result: result,
      ),
    );
  }
}

class _QueuedCommand {
  final String deviceId;
  final Uint8List payload;
  final BleWriteOptions options;
  final DateTime enqueuedAt;
  DateTime? lastSendAt;
  final Completer<void> completer = Completer<void>();
  final Completer<List<int>?>? responseCompleter;

  _QueuedCommand({
    required this.deviceId,
    required this.payload,
    required this.options,
    required this.enqueuedAt,
    required bool expectsPayload,
  }) : responseCompleter = expectsPayload ? Completer<List<int>?>() : null;
}
