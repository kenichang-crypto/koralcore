import 'led_channel_value.dart';

/// LED scene definition.
///
/// A scene is a named, reusable spectral configuration.
class LedScene {
  final String sceneId;
  final String name;
  final List<LedChannelValue> channels;

  const LedScene({
    required this.sceneId,
    required this.name,
    required this.channels,
  });
}
