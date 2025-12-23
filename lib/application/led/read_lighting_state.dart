library;

import '../../domain/led_lighting/led_state.dart' show LedState;
import '../../platform/contracts/led_repository.dart';
import '../common/app_error.dart';
import '../common/app_error_code.dart';
import 'lighting_state_store.dart';

export 'lighting_state_store.dart'
    show LightingStateSnapshot, LightingChannelSnapshot;

/// Reads the current lighting state snapshot from the in-memory store.
class ReadLightingStateUseCase {
  final LedRepository ledRepository;

  const ReadLightingStateUseCase({required this.ledRepository});

  Future<LightingStateSnapshot> execute({required String deviceId}) async {
    if (deviceId.isEmpty) {
      throw const AppError(
        code: AppErrorCode.noActiveDevice,
        message: 'Lighting state requires an active device id.',
      );
    }

    final LedState? state = await ledRepository.getLedState(deviceId);
    if (state == null) {
      throw const AppError(
        code: AppErrorCode.invalidParam,
        message: 'Unable to read LED state for device.',
      );
    }

    return LightingStateSnapshot(
      channels: state.channelLevels.entries
          .map(
            (entry) => LightingChannelSnapshot(
              id: entry.key,
              label: entry.key,
              percentage: entry.value,
            ),
          )
          .toList(growable: false),
      updatedAt: DateTime.now(),
    );
  }
}
