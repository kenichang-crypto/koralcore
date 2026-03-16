import 'dart:async';
import 'dart:collection';
import 'dart:developer' as developer;
import 'dart:typed_data';

import 'ble_adapter.dart';
import 'response/ble_error_code.dart';
import 'record/ble_record.dart';
import 'record/ble_record_type.dart';
import 'record/ble_recorder.dart';
import 'transport/ble_transport_models.dart';
import 'ble_notify_bus.dart';
import 'ble_uuid.dart';
import 'platform_channels/ble_notify_packet.dart';

void _bleLog(String event, String message) {
  developer.log(message, name: 'BleAdapter.$event');
}

enum _BleLifecycleState {
  disconnected,
  connecting,
  connected,
  servicesDiscovered,
  notificationsEnabling,
  notificationsReady,
}

/// Concrete BLE adapter that delegates to the platform BLE stack.
class BleAdapterImpl implements BleAdapter {
  final BleTransportWriter? transportWriter;
  final BleRecorder? recorder;
  final BleTransportObserver? observer;
  final BleWriteOptions defaultOptions;
  final Stream<BleConnectionState>? connectionStream;

  final Map<String, Queue<_QueuedCommand>> _deviceQueues = {};
  final Map<String, bool> _deviceIsProcessing = {};
  final Map<String, _QueuedCommand?> _currentCommands = {};
  final Map<String, bool> _notificationEnabled = <String, bool>{};
  final Map<String, _BleLifecycleState> _connectionStates = {};
  final Map<String, Completer<void>> _notificationsReadyCompleters = {};
  static const Duration _defaultNoAckDequeueDelay = Duration(milliseconds: 120);
  late final StreamSubscription<BleNotifyPacket> _notifySubscription;
  StreamSubscription<BleConnectionState>? _connectionSubscription;

  BleAdapterImpl({
    this.transportWriter,
    this.recorder,
    this.observer,
    BleWriteOptions? defaultOptions,
    this.connectionStream,
  }) : defaultOptions = defaultOptions ?? const BleWriteOptions() {
    _notifySubscription =
        BleNotifyBus.instance.stream.listen(_onNotifyPacketReady);
    _connectionSubscription =
        connectionStream?.listen(_handleConnectionState);
  }

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

  Queue<_QueuedCommand> _ensureDeviceQueue(String deviceId) {
    return _deviceQueues.putIfAbsent(deviceId, () => Queue<_QueuedCommand>());
  }

  void _enqueueDeviceCommand(String deviceId, _QueuedCommand command) {
    final queue = _ensureDeviceQueue(deviceId);
    queue.add(command);
    _emitLog(
      type: BleTransportEventType.queued,
      command: command,
      attempt: 0,
      message:
          'Queued payload length=${command.payload.length} (device=$deviceId, queue=${queue.length})',
      result: null,
    );
    _bleLog('BLE_QUEUE', 'device=$deviceId size=${queue.length}');
    _processDeviceQueue(deviceId);
  }

  void _processDeviceQueue(String deviceId) {
    if (_deviceIsProcessing[deviceId] == true) {
      return;
    }
    final Queue<_QueuedCommand>? queue = _deviceQueues[deviceId];
    if (queue == null || queue.isEmpty) {
      return;
    }
    _deviceIsProcessing[deviceId] = true;
    Future<void>(() async {
      try {
        while (queue.isNotEmpty) {
          final _QueuedCommand command = queue.first;
          final _BleLifecycleState state =
              _connectionStates[deviceId] ?? _BleLifecycleState.disconnected;
          if (state != _BleLifecycleState.notificationsReady) {
            await _waitForNotificationsReady(deviceId);
            continue;
          }
          _currentCommands[deviceId] = command;
          try {
            await _executeCommand(command);
          } finally {
            if (queue.isNotEmpty && queue.first == command) {
              queue.removeFirst();
            }
          }
          if (queue.isNotEmpty) {
            await _applyPostCommandDelay(command);
          }
        }
      } finally {
        _deviceIsProcessing[deviceId] = false;
        _currentCommands.remove(deviceId);
        if (queue.isEmpty) {
          _deviceQueues.remove(deviceId);
        }
      }
    });
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
    _enqueueDeviceCommand(deviceId, command);
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
    _enqueueDeviceCommand(deviceId, command);
    return command.responseCompleter!.future;
  }

  @override
  void clearQueue({String? deviceId}) {
    final void Function(_QueuedCommand) completeError = (_QueuedCommand command) {
      final BleWriteException error =
          BleWriteException('BLE command aborted due to disconnect.');
      if (command.responseCompleter != null &&
          !command.responseCompleter!.isCompleted) {
        command.responseCompleter!.completeError(error);
      }
      if (!command.completer.isCompleted) {
        command.completer.completeError(error);
      }
    };

    final Iterable<String> targets = deviceId == null
        ? List<String>.from(_deviceQueues.keys)
        : [deviceId];
    for (final id in targets) {
      final Queue<_QueuedCommand>? queue = _deviceQueues.remove(id);
      if (queue != null) {
        for (final command in queue) {
          completeError(command);
        }
      }
      final _QueuedCommand? current = _currentCommands.remove(id);
      if (current != null) {
        completeError(current);
      }
      _deviceIsProcessing.remove(id);
      _notificationEnabled.remove(id);
      _connectionStates[id] = _BleLifecycleState.disconnected;
      final readyCompleter = _notificationsReadyCompleters.remove(id);
      if (readyCompleter != null && !readyCompleter.isCompleted) {
        readyCompleter.complete();
      }
    }
  }

  void _onNotifyPacketReady(BleNotifyPacket packet) {
    final String? characteristic = packet.characteristic;
    if (characteristic?.toLowerCase() ==
            uuidDropNotify.toLowerCase() &&
        _notificationEnabled[packet.deviceId] != true) {
      _notificationEnabled[packet.deviceId] = true;
      _setLifecycleState(packet.deviceId, _BleLifecycleState.notificationsReady);
    }
  }

  bool isNotificationReady(String deviceId) =>
      _notificationEnabled[deviceId] == true;

  void _handleConnectionState(BleConnectionState state) {
    final String? deviceId = state.deviceId;
    if (deviceId == null || deviceId.isEmpty) {
      return;
    }

    if (state.isConnected) {
      _setLifecycleState(deviceId, _BleLifecycleState.connected);
    } else {
      _setLifecycleState(deviceId, _BleLifecycleState.disconnected);
      _notificationEnabled.remove(deviceId);
      _deviceQueues.remove(deviceId);
      _deviceIsProcessing.remove(deviceId);
      _currentCommands.remove(deviceId);
      _notificationsReadyCompleters.remove(deviceId);
    }
  }

  void _setLifecycleState(String deviceId, _BleLifecycleState state) {
    _connectionStates[deviceId] = state;
    if (state == _BleLifecycleState.notificationsReady) {
      final completer = _notificationsReadyCompleters.remove(deviceId);
      completer?.complete();
    }
  }

  Future<void> _waitForNotificationsReady(String deviceId) {
    if (_connectionStates[deviceId] == _BleLifecycleState.notificationsReady) {
      return Future<void>.value();
    }
    _setLifecycleState(deviceId, _BleLifecycleState.notificationsEnabling);
    final completer = _notificationsReadyCompleters.putIfAbsent(
      deviceId,
      () => Completer<void>(),
    );
    return completer.future;
  }

  Future<void> _executeCommand(_QueuedCommand command) async {
    int attempt = 0;
    while (true) {
      attempt++;
      command.lastSendAt = DateTime.now();
      final int opcode = command.payload.isNotEmpty ? command.payload.first : -1;
      _emitLog(
        type: BleTransportEventType.sending,
        command: command,
        attempt: attempt,
        message: 'Sending (mode=${command.options.mode.name})',
        result: null,
      );

      try {
        _bleLog(
          'BLE_SEND',
          'opcode=$opcode device=${command.deviceId} retry=$attempt',
        );
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
      final int expectedOpcode =
          command.payload.isNotEmpty ? command.payload.first : -1;
      final Future<BleWriteResult> writerFuture = writer(
        deviceId: command.deviceId,
        payload: command.payload,
        mode: command.options.mode,
        timeout: command.options.timeout,
        expectsResponsePayload: command.responseCompleter != null,
        expectedOpcode:
            command.responseCompleter != null ? expectedOpcode : null,
      );

      final BleWriteResult result = await writerFuture.timeout(
        command.options.timeout,
      );

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
