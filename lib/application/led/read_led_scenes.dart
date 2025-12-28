library;

import 'dart:async';

import '../../domain/led_lighting/led_state.dart';
import '../../platform/contracts/led_repository.dart';

class ReadLedSceneSnapshot {
  final String id;
  final String name;
  final String description;
  final List<int> palette;
  final bool isEnabled;
  final bool isPreset;
  final bool isDynamic;
  final String? iconKey;
  final int? presetCode;
  final Map<String, int> channelLevels;

  const ReadLedSceneSnapshot({
    required this.id,
    required this.name,
    required this.description,
    required this.palette,
    required this.isEnabled,
    required this.isPreset,
    required this.isDynamic,
    required this.channelLevels,
    this.iconKey,
    this.presetCode,
  });
}

class ReadLedScenesUseCase {
  const ReadLedScenesUseCase({required this.ledRepository});

  final LedRepository ledRepository;

  Future<List<ReadLedSceneSnapshot>> execute({required String deviceId}) async {
    final LedState? state = await ledRepository.getLedState(deviceId);
    if (state == null || state.scenes.isEmpty) {
      return const <ReadLedSceneSnapshot>[];
    }
    return state.scenes
        .map(
          (scene) => ReadLedSceneSnapshot(
            id: scene.sceneId,
            name: scene.name,
            description: scene.name,
            palette: _buildPalette(scene),
            isEnabled: true,
            isPreset: scene.presetCode != null,
            isDynamic: scene.isDynamic,
            iconKey: scene.iconKey,
            presetCode: scene.presetCode,
            channelLevels: Map<String, int>.unmodifiable(scene.channelLevels),
          ),
        )
        .toList(growable: false);
  }
}

const List<int> _defaultPalette = <int>[0xFF1E3C72, 0xFF2A5298];

List<int> _buildPalette(LedStateScene scene) {
  if (scene.channelLevels.isEmpty) {
    return _defaultPalette;
  }
  return _paletteFromChannels(scene.channelLevels);
}

List<int> _paletteFromChannels(Map<String, int> channels) {
  final int primary = _argb(
    _channelByte(channels['red']),
    _channelByte(channels['green']),
    _channelByte(channels['blue']),
  );
  final int secondary = _argb(
    _channelByte(channels['royalBlue']),
    _channelByte(channels['warmWhite']),
    _channelByte(channels['moonLight'] ?? channels['moon']),
  );
  if (primary == secondary) {
    return <int>[primary, _tint(primary)];
  }
  return <int>[primary, secondary];
}

int _channelByte(int? percent) {
  final int clamped = (percent ?? 0).clamp(0, 100);
  return ((clamped / 100) * 255).round();
}

int _argb(int r, int g, int b) {
  return 0xFF000000 | ((r & 0xFF) << 16) | ((g & 0xFF) << 8) | (b & 0xFF);
}

int _tint(int color) {
  final int r = (((color >> 16) & 0xFF) + 30).clamp(0, 255);
  final int g = (((color >> 8) & 0xFF) + 30).clamp(0, 255);
  final int b = ((color & 0xFF) + 30).clamp(0, 255);
  return _argb(r, g, b);
}
