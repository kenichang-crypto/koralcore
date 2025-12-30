import 'dart:async';
import 'dart:collection';

import 'package:flutter/services.dart';

import '../response/ble_error_code.dart';
import '../transport/ble_transport_models.dart';
import 'ble_notify_packet.dart';

/// Bridges BLE transport writes to the host platform via a method channel so
/// Flutter code can rely on the hardened queue while the native layer drives
/// the actual Bluetooth stack.
class BlePlatformTransportWriter {
  static const String _channelName = 'koralcore/ble_transport';
  static const String _writeMethod = 'write';
  static const String _connectMethod = 'connect';
  static const String _notifyCallback = 'notify';

  final MethodChannel _channel;
  final ListQueue<_PendingPayload> _pendingPayloads =
      ListQueue<_PendingPayload>();
  final Set<String> _connectedDevices = <String>{};
  final Map<String, Future<void>> _connectingDevices = <String, Future<void>>{};
  final StreamController<BleNotifyPacket> _notifyController =
      StreamController<BleNotifyPacket>.broadcast();

  BlePlatformTransportWriter({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(_channelName) {
    _channel.setMethodCallHandler(_handlePlatformCall);
  }

  /// Broadcast stream of every BLE notification envelope emitted by the host.
  Stream<BleNotifyPacket> get notifyStream => _notifyController.stream;

  /// Invokes the platform transport and returns the adapter-level write result.
  Future<BleWriteResult> write({
    required String deviceId,
    required Uint8List payload,
    required BleWriteMode mode,
    required Duration timeout,
    bool expectsResponsePayload = false,
  }) async {
    if (deviceId.isEmpty) {
      throw const BleWriteException('deviceId is required for BLE transport');
    }

    await _ensureConnection(deviceId);

    _PendingPayload? pendingPayload;
    if (expectsResponsePayload) {
      pendingPayload = _PendingPayload();
      _pendingPayloads.add(pendingPayload);
    }

    Map<Object?, Object?>? response;
    try {
      response = await _channel.invokeMethod<Map<Object?, Object?>>(
        _writeMethod,
        <String, Object?>{
          'deviceId': deviceId,
          'payload': payload,
          'mode': mode.name,
        },
      );
    } on PlatformException catch (error) {
      pendingPayload?.cancel();
      _drainCancelledPayloads();
      throw BleWriteException(
        'BLE platform error: ${error.code} ${error.message ?? ''}'.trim(),
      );
    } on MissingPluginException {
      pendingPayload?.cancel();
      _drainCancelledPayloads();
      throw const BleWriteException('BLE platform channel not available.');
    }

    if (response?['errorCode'] == 'notConnected') {
      _connectedDevices.remove(deviceId);
    }

    final BleWriteResult result = _parseResult(response);

    if (!expectsResponsePayload || pendingPayload == null) {
      return result;
    }

    if (result.status != BleTransportResult.ack) {
      pendingPayload.cancel();
      _drainCancelledPayloads();
      return result;
    }

    try {
      final Uint8List? payloadBytes = await pendingPayload.completer.future
          .timeout(timeout);
      final List<int>? responsePayload = payloadBytes == null
          ? null
          : List<int>.unmodifiable(payloadBytes);
      return BleWriteResult(
        status: BleTransportResult.ack,
        payload: responsePayload,
        errorCode: result.errorCode,
      );
    } on TimeoutException {
      pendingPayload.cancel();
      _drainCancelledPayloads();
      throw BleWriteTimeoutException(
        'BLE notification timed out after ${timeout.inMilliseconds}ms.',
      );
    }
  }

  Future<void> _ensureConnection(String deviceId) async {
    if (_connectedDevices.contains(deviceId)) {
      return;
    }
    final Future<void>? inflight = _connectingDevices[deviceId];
    if (inflight != null) {
      await inflight;
      return;
    }
    final Future<void> connectFuture = _invokeConnect(deviceId);
    _connectingDevices[deviceId] = connectFuture;
    try {
      await connectFuture;
    } finally {
      _connectingDevices.remove(deviceId);
    }
  }

  Future<void> _invokeConnect(String deviceId) async {
    try {
      final bool connected =
          await _channel.invokeMethod<bool>(_connectMethod, <String, Object?>{
            'deviceId': deviceId,
          }) ??
          false;
      if (!connected) {
        throw BleWriteException('Failed to connect to $deviceId');
      }
      _connectedDevices.add(deviceId);
    } on PlatformException catch (error) {
      throw BleWriteException(
        'BLE connect error: ${error.code} ${error.message ?? ''}'.trim(),
      );
    } on MissingPluginException {
      throw const BleWriteException('BLE platform channel not available.');
    }
  }

  Future<void> _handlePlatformCall(MethodCall call) async {
    switch (call.method) {
      case _notifyCallback:
        _handleNotify(call.arguments);
        break;
      default:
        break;
    }
  }

  void _handleNotify(dynamic rawArguments) {
    final Map<Object?, Object?>? arguments = rawArguments is Map
        ? rawArguments.cast<Object?, Object?>()
        : null;
    final BleNotifyPacket? packet = BleNotifyPacket.fromEnvelope(arguments);
    final Uint8List? payload =
        packet?.payload ?? _extractPayload(arguments?['payload']);
    if (packet != null) {
      _connectedDevices.add(packet.deviceId);
      if (!_notifyController.isClosed) {
        _notifyController.add(packet);
      }
    }

    while (_pendingPayloads.isNotEmpty) {
      final _PendingPayload pending = _pendingPayloads.removeFirst();
      if (pending.isCancelled) {
        continue;
      }
      if (!pending.completer.isCompleted) {
        pending.completer.complete(payload);
      }
      break;
    }
    _drainCancelledPayloads();
  }

  void _drainCancelledPayloads() {
    while (_pendingPayloads.isNotEmpty && _pendingPayloads.first.isCancelled) {
      _pendingPayloads.removeFirst();
    }
  }

  BleWriteResult _parseResult(Map<Object?, Object?>? response) {
    if (response == null) {
      return const BleWriteResult(
        status: BleTransportResult.failure,
        errorCode: BleErrorCode.unknown,
      );
    }

    final BleTransportResult status = _parseStatus(response['status']);
    final List<int>? payload = _parsePayload(response['payload']);
    final BleErrorCode? errorCode = _parseErrorCode(response['errorCode']);

    return BleWriteResult(
      status: status,
      payload: payload,
      errorCode: errorCode,
    );
  }

  BleTransportResult _parseStatus(Object? rawStatus) {
    if (rawStatus is String) {
      return BleTransportResult.values.firstWhere(
        (BleTransportResult value) => value.name == rawStatus,
        orElse: () => BleTransportResult.failure,
      );
    }
    if (rawStatus is int &&
        rawStatus >= 0 &&
        rawStatus < BleTransportResult.values.length) {
      return BleTransportResult.values[rawStatus];
    }
    return BleTransportResult.failure;
  }

  List<int>? _parsePayload(Object? rawPayload) {
    if (rawPayload is Uint8List) {
      return List<int>.unmodifiable(rawPayload);
    }
    if (rawPayload is List) {
      return List<int>.unmodifiable(rawPayload.cast<int>());
    }
    return null;
  }

  Uint8List? _extractPayload(Object? rawPayload) {
    if (rawPayload is Uint8List) {
      return rawPayload;
    }
    if (rawPayload is List) {
      return Uint8List.fromList(rawPayload.cast<int>());
    }
    return null;
  }

  BleErrorCode? _parseErrorCode(Object? rawErrorCode) {
    if (rawErrorCode == null) {
      return null;
    }
    if (rawErrorCode is String) {
      return BleErrorCode.values.firstWhere(
        (BleErrorCode value) => value.name == rawErrorCode,
        orElse: () => BleErrorCode.unknown,
      );
    }
    if (rawErrorCode is int &&
        rawErrorCode >= 0 &&
        rawErrorCode < BleErrorCode.values.length) {
      return BleErrorCode.values[rawErrorCode];
    }
    return BleErrorCode.unknown;
  }
}

class _PendingPayload {
  final Completer<Uint8List?> completer = Completer<Uint8List?>();
  bool isCancelled = false;

  void cancel() {
    isCancelled = true;
  }
}
