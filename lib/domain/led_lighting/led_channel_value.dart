import 'led_channel.dart';

/// Domain value object representing intensity of a single LED channel.
///
/// - Intensity range is NOT enforced here
/// - Hardware limits are handled elsewhere
class LedChannelValue {
  final LedChannel channel;
  final int intensity;

  const LedChannelValue({required this.channel, required this.intensity});

  @override
  String toString() =>
      'LedChannelValue(channel: $channel, intensity: $intensity)';
}
