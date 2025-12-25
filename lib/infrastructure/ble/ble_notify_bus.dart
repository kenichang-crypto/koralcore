import 'dart:async';

import 'platform_channels/ble_notify_packet.dart';
import 'platform_channels/ble_platform_transport_writer.dart';

/// Global helper that exposes the BLE notification broadcast stream.
class BleNotifyBus {
  BleNotifyBus._(this._stream);

  static BleNotifyBus? _instance;

  /// Configures the bus with the shared [BlePlatformTransportWriter].
  static void configure(BlePlatformTransportWriter writer) {
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

  Stream<BleNotifyPacket> get stream => _stream;
}
