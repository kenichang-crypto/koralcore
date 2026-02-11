library;

import 'dart:async';

import '../../../data/repositories/scene_repository_impl.dart';
import '../../led_lighting/led_state.dart';
import '../../led_lighting/scene_catalog.dart';
import '../../../platform/contracts/led_repository.dart';

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

/// ReadLedScenesUseCase
///
/// PARITY: Corresponds to reef-b-app's scene reading behavior:
/// - LedSceneViewModel.getAllScene() -> SceneDao.getAllScene(deviceId)
/// - Returns both preset scenes (from catalog) and custom scenes (from database)
/// - LedSceneActivity displays scene list with preset and custom scenes
/// - SceneDao queries Scene table filtered by deviceId
class ReadLedScenesUseCase {
  const ReadLedScenesUseCase({
    required this.ledRepository,
    this.sceneRepository,
  });

  final LedRepository ledRepository;
  final SceneRepositoryImpl? sceneRepository;

  Future<List<ReadLedSceneSnapshot>> execute({required String deviceId}) async {
    final LedState? state = await ledRepository.getLedState(deviceId);

    // Build preset list (from catalog when state empty, else from state)
    final List<ReadLedSceneSnapshot> presets = (state == null || state.scenes.isEmpty)
        ? SceneCatalog.presetScenes.values
            .map(
              (scene) => ReadLedSceneSnapshot(
                id: scene.sceneId,
                name: scene.name,
                description: scene.name,
                palette: _buildPalette(scene),
                isEnabled: true,
                isPreset: true,
                isDynamic: scene.isDynamic,
                iconKey: scene.iconKey,
                presetCode: scene.presetCode,
                channelLevels: Map<String, int>.unmodifiable(scene.channelLevels),
              ),
            )
            .toList(growable: false)
        : state.scenes
            .where((s) => s.presetCode != null)
            .map(
              (scene) => ReadLedSceneSnapshot(
                id: scene.sceneId,
                name: scene.name,
                description: scene.name,
                palette: _buildPalette(scene),
                isEnabled: true,
                isPreset: true,
                isDynamic: scene.isDynamic,
                iconKey: scene.iconKey,
                presetCode: scene.presetCode,
                channelLevels: Map<String, int>.unmodifiable(scene.channelLevels),
              ),
            )
            .toList(growable: false);

    // Merge custom scenes from local database so AddScene/EditScene show up after save
    final List<ReadLedSceneSnapshot> custom = <ReadLedSceneSnapshot>[];
    if (sceneRepository != null) {
      final dbScenes = await sceneRepository!.getScenes(deviceId);
      for (final r in dbScenes) {
        custom.add(
          ReadLedSceneSnapshot(
            id: 'local_scene_${r.sceneId}',
            name: r.name,
            description: r.name,
            palette: _paletteFromChannels(r.channelLevels),
            isEnabled: true,
            isPreset: false,
            isDynamic: false,
            iconKey: _iconIdToKey(r.iconId),
            presetCode: null,
            channelLevels: Map<String, int>.unmodifiable(r.channelLevels),
          ),
        );
      }
    }
    // Also include custom scenes from BLE state not yet in DB (e.g. from device sync)
    if (state != null && state.scenes.isNotEmpty) {
      for (final scene in state.scenes) {
        if (scene.presetCode == null && !custom.any((c) => c.id == scene.sceneId)) {
          custom.add(
            ReadLedSceneSnapshot(
              id: scene.sceneId,
              name: scene.name,
              description: scene.name,
              palette: _buildPalette(scene),
              isEnabled: true,
              isPreset: false,
              isDynamic: scene.isDynamic,
              iconKey: scene.iconKey,
              presetCode: null,
              channelLevels: Map<String, int>.unmodifiable(scene.channelLevels),
            ),
          );
        }
      }
    }

    return [...presets, ...custom];
  }
}

String _iconIdToKey(int iconId) {
  switch (iconId) {
    case 0:
      return 'ic_thunder';
    case 1:
      return 'ic_cloudy';
    case 2:
      return 'ic_sunny';
    case 3:
      return 'ic_rainy';
    case 4:
      return 'ic_dizzle';
    case 5:
      return 'ic_none';
    case 6:
      return 'ic_moon';
    case 7:
      return 'ic_sunrise';
    case 8:
      return 'ic_sunset';
    case 9:
      return 'ic_mist';
    case 10:
      return 'ic_light_off';
    default:
      return 'ic_none';
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
