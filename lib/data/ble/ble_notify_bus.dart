import 'dart:async';

import 'package:flutter/foundation.dart';

import 'platform_channels/ble_notify_packet.dart';
import 'platform_channels/ble_platform_transport_writer.dart';

/// Global helper that exposes the BLE notification broadcast stream.
class BleNotifyBus {
  BleNotifyBus._(this._stream);

  static BleNotifyBus? _instance;

  /// Configures the bus with the shared [BlePlatformTransportWriter].
  static void configure(BlePlatformTransportWriter writer) {
    writer.notifyStream.listen((packet) {
      debugPrint(
        '[BLE_NOTIFY_BUS] packet received device=${packet.deviceId} bytes=${packet.payload}',
      );
    });
    _instance ??= BleNotifyBus._(writer.notifyStream);
  }

  /// Accessor used by higher layers once [configure] has been called.
  static BleNotifyBus get instance {
    final BleNotifyBus? bus = _instance;
    if (bus == null) {
      throw StateError('BleNotifyBus has not been configured.');
    }
    return bus;
  }

  final Stream<BleNotifyPacket> _stream;
  final Map<String, double> _doseFactors = {};

  Stream<BleNotifyPacket> get stream => _stream;

  void registerDoseFactor(String deviceId, double factor) {
    if (deviceId.isEmpty) {
      return;
    }
    _doseFactors[deviceId] = factor;
  }

  double convertDoseRaw(String deviceId, double raw) {
    final double factor = _doseFactors[deviceId] ?? 1.0;
    return raw * factor;
  }

  void clearDoseFactor(String deviceId) {
    _doseFactors.remove(deviceId);
  }
}
