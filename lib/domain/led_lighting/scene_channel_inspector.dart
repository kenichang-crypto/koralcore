import 'led_state.dart';

class SceneChannelInspector {
  const SceneChannelInspector();

  bool matches(LedStateScene scene, Map<String, int> channels) {
    if (scene.channelLevels.isEmpty) {
      return false;
    }
    for (final String key in channels.keys) {
      if ((scene.channelLevels[key] ?? 0) != channels[key]) {
        return false;
      }
    }
    return true;
  }
}
