import 'led_channel_group.dart';
import 'led_spectrum.dart';

/// LED scene definition.
///
/// A scene is a named, reusable spectral configuration.
class LedScene {
  final int presetId;
  final String sceneId;
  final String name;
  final LedSpectrum spectrum;
  final LedChannelGroup channelGroup;

  const LedScene({
    required this.presetId,
    required this.sceneId,
    required this.name,
    required this.spectrum,
    this.channelGroup = LedChannelGroup.fullSpectrum,
  });
}
