import 'led_channel.dart';
import 'led_intensity.dart';

/// Domain value object representing intensity of a single LED channel.
///
/// - Intensity range is NOT enforced here
/// - Hardware limits are handled elsewhere
class LedChannelValue {
  final LedChannel channel;
  final LedIntensity intensity;

  const LedChannelValue({required this.channel, required this.intensity});

  int get byteValue => intensity.value;

  @override
  String toString() =>
      'LedChannelValue(channel: $channel, intensity: ${intensity.value})';
}
