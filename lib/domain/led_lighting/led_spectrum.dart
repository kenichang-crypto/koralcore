import 'led_channel.dart';
import 'led_channel_value.dart';
import 'led_channel_group.dart';
import 'led_intensity.dart';

/// Immutable collection of per-channel intensities that stays aligned with the
/// firmware's channel order.
class LedSpectrum {
  final Map<LedChannel, LedIntensity> _intensities;
  final LedChannelGroup channelGroup;

  const LedSpectrum._(this._intensities, this.channelGroup);

  factory LedSpectrum({
    required LedChannelGroup channelGroup,
    required List<LedChannelValue> channels,
  }) {
    final Map<LedChannel, LedIntensity> normalized =
        <LedChannel, LedIntensity>{};
    for (final LedChannelValue value in channels) {
      normalized[value.channel] = value.intensity;
    }
    for (final LedChannel channel in channelGroup.channelOrder) {
      normalized[channel] = normalized[channel] ?? LedIntensity.zero;
    }
    return LedSpectrum._(
      Map<LedChannel, LedIntensity>.unmodifiable(normalized),
      channelGroup,
    );
  }

  LedIntensity intensityOf(LedChannel channel) {
    return _intensities[channel] ?? LedIntensity.zero;
  }

  List<LedChannelValue> asChannelValues() {
    return channelGroup.channelOrder
        .map(
          (LedChannel channel) => LedChannelValue(
            channel: channel,
            intensity: intensityOf(channel),
          ),
        )
        .toList(growable: false);
  }
}
