import 'led_state.dart';

/// Static mapping of preset scene codes to canonical scene metadata.
class SceneCatalog {
  static final Map<int, LedStateScene> presetScenes = _buildPresetScenes();

  static LedStateScene? findByCode(int code) => presetScenes[code];

  static LedStateScene? findById(String sceneId) {
    final int? code = _parsePresetCode(sceneId);
    if (code == null) {
      return null;
    }
    return findByCode(code);
  }

  static Map<int, LedStateScene> _buildPresetScenes() {
    return <int, LedStateScene>{
      0x00: _preset(code: 0x00, name: 'Lights Off', iconKey: 'ic_none'),
      0x01: _preset(code: 0x01, name: '30% Intensity', iconKey: 'ic_none'),
      0x02: _preset(code: 0x02, name: '60% Intensity', iconKey: 'ic_none'),
      0x03: _preset(code: 0x03, name: '100% Intensity', iconKey: 'ic_none'),
      0x04: _preset(code: 0x04, name: 'Moonlight', iconKey: 'ic_moon'),
      0x05: _preset(
        code: 0x05,
        name: 'Thunderstorm',
        iconKey: 'ic_thunder',
        isDynamic: true,
      ),
    };
  }

  static LedStateScene _preset({
    required int code,
    required String name,
    required String iconKey,
    bool isDynamic = false,
  }) {
    final String sceneId = 'preset_${code.toString().padLeft(2, '0')}';
    return LedStateScene(
      sceneId: sceneId,
      name: name,
      channelLevels: const <String, int>{},
      presetCode: code,
      iconKey: iconKey,
      isDynamic: isDynamic,
    );
  }

  static int? _parsePresetCode(String sceneId) {
    if (!sceneId.startsWith('preset_')) {
      return null;
    }
    final String suffix = sceneId.substring('preset_'.length);
    return int.tryParse(suffix, radix: 10);
  }
}
