library;

import '../../domain/led_lighting/led_state.dart' show LedState;
import '../../platform/contracts/led_repository.dart';
import '../common/app_error.dart';
import '../common/app_error_code.dart';
import 'lighting_state_store.dart';

export 'lighting_state_store.dart'
    show LightingStateSnapshot, LightingChannelSnapshot;

/// Updates the simulated LED channel intensities for the active device.
class SetChannelIntensityUseCase {
  final LedRepository ledRepository;

  const SetChannelIntensityUseCase({required this.ledRepository});

  Future<LightingStateSnapshot> execute({
    required String deviceId,
    required List<ChannelIntensityChange> channels,
  }) async {
    if (deviceId.isEmpty) {
      throw const AppError(
        code: AppErrorCode.noActiveDevice,
        message: 'LED writes require an active device id.',
      );
    }
    if (channels.isEmpty) {
      throw const AppError(
        code: AppErrorCode.invalidParam,
        message: 'Provide at least one LED channel to update.',
      );
    }
    final bool hasOutOfRange = channels.any(
      (change) => change.percentage < 0 || change.percentage > 100,
    );
    if (hasOutOfRange) {
      throw const AppError(
        code: AppErrorCode.invalidParam,
        message: 'Channel percentages must be between 0 and 100.',
      );
    }

    final Map<String, int> updates = <String, int>{
      for (final ChannelIntensityChange change in channels)
        change.channelId: change.percentage,
    };

    try {
      final LedState state = await ledRepository.setChannelLevels(
        deviceId: deviceId,
        channelLevels: updates,
      );
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
    } on StateError catch (error) {
      throw AppError(code: AppErrorCode.invalidParam, message: error.message);
    }
  }
}

class ChannelIntensityChange {
  final String channelId;
  final int percentage;

  const ChannelIntensityChange({
    required this.channelId,
    required this.percentage,
  });
}
