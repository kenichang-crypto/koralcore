import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:koralcore/data/ble/platform_channels/ble_platform_transport_writer.dart';
import 'package:koralcore/data/ble/transport/ble_transport_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late BlePlatformTransportWriter writer;
  late MethodChannel channel;

  setUp(() {
    channel = const MethodChannel('koralcore/ble_transport');
    writer = BlePlatformTransportWriter(channel: channel);
  });

  test(
    'connectionStateStream emits events when platform calls connectionStateChange',
    () async {
      final List<BleConnectionState> states = [];
      final subscription = writer.connectionStateStream.listen(states.add);

      // Simulate platform call: Connected
      final ByteData? message = const StandardMethodCodec().encodeMethodCall(
        const MethodCall('connectionStateChange', {
          'deviceId': 'test_device',
          'isConnected': true,
        }),
      );

      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.defaultBinaryMessenger.handlePlatformMessage(
        'koralcore/ble_transport',
        message,
        (ByteData? reply) {},
      );

      await Future.delayed(Duration.zero);

      expect(states.length, 1);
      expect(states.first.deviceId, 'test_device');
      expect(states.first.isConnected, true);

      // Simulate platform call: Disconnected
      final ByteData? message2 = const StandardMethodCodec().encodeMethodCall(
        const MethodCall('connectionStateChange', {
          'deviceId': 'test_device',
          'isConnected': false,
        }),
      );

      await binding.defaultBinaryMessenger.handlePlatformMessage(
        'koralcore/ble_transport',
        message2,
        (ByteData? reply) {},
      );

      await Future.delayed(Duration.zero);

      expect(states.length, 2);
      expect(states.last.deviceId, 'test_device');
      expect(states.last.isConnected, false);

      await subscription.cancel();
    },
  );
}
