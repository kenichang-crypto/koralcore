library;

import 'dart:async';

import '../common/app_error.dart';
import '../common/app_error_code.dart';

class ReadLedSceneSnapshot {
  final String id;
  final String name;
  final String description;
  final List<int> palette;
  final bool isEnabled;

  const ReadLedSceneSnapshot({
    required this.id,
    required this.name,
    required this.description,
    required this.palette,
    required this.isEnabled,
  });
}

/// Placeholder use case that returns the currently saved LED scenes for a
/// device. The list is read-only and the transport wiring will be added once
/// the BLE protocol for scenes is finalized.
class ReadLedScenesUseCase {
  const ReadLedScenesUseCase();

  Future<List<ReadLedSceneSnapshot>> execute({required String deviceId}) async {
    final List<_LedSceneSeed>? seeds =
        _deviceScenes[deviceId] ?? _deviceScenes['default'];
    if (seeds == null) {
      throw const AppError(
        code: AppErrorCode.invalidParam,
        message: 'Unknown device id for LED scenes.',
      );
    }

    await Future<void>.delayed(const Duration(milliseconds: 160));
    return seeds
        .map(
          (seed) => ReadLedSceneSnapshot(
            id: seed.id,
            name: seed.name,
            description: seed.description,
            palette: seed.palette,
            isEnabled: seed.isEnabled,
          ),
        )
        .toList(growable: false);
  }
}

class _LedSceneSeed {
  final String id;
  final String name;
  final String description;
  final List<int> palette;
  final bool isEnabled;

  const _LedSceneSeed({
    required this.id,
    required this.name,
    required this.description,
    required this.palette,
    required this.isEnabled,
  });
}

const Map<String, List<_LedSceneSeed>> _deviceScenes = {
  'default': [
    _LedSceneSeed(
      id: 'sunrise',
      name: 'Sunrise Blend',
      description: 'Warm ramp into daylight. Soft reds then bright whites.',
      palette: [0xFFFFD180, 0xFFFF8A65],
      isEnabled: true,
    ),
    _LedSceneSeed(
      id: 'reef_crest',
      name: 'Reef Crest',
      description: 'Peaks tuned for SPS growth and crisp midday looks.',
      palette: [0xFF80D8FF, 0xFF1976D2],
      isEnabled: true,
    ),
    _LedSceneSeed(
      id: 'lunar',
      name: 'Moonlight',
      description: 'Royal blue shimmer for night viewing.',
      palette: [0xFF4FC3F7, 0xFF0D47A1],
      isEnabled: false,
    ),
  ],
};
