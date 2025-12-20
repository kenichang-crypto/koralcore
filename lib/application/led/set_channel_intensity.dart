library;

import 'dart:async';

import '../common/app_error.dart';
import '../common/app_error_code.dart';
import 'lighting_state_store.dart';

export 'lighting_state_store.dart'
    show LightingStateSnapshot, LightingChannelSnapshot;

/// Updates the simulated LED channel intensities for the active device.
class SetChannelIntensityUseCase {
  final LightingStateMemoryStore store;

  const SetChannelIntensityUseCase({required this.store});

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

    await Future<void>.delayed(const Duration(milliseconds: 250));
    final LightingStateSnapshot current = store.read(deviceId: deviceId);
    final Map<String, int> updateMap = {
      for (final ChannelIntensityChange change in channels)
        change.channelId: change.percentage,
    };
    final List<LightingChannelSnapshot> updatedChannels = current.channels
        .map(
          (channel) => updateMap.containsKey(channel.id)
              ? channel.copyWith(percentage: updateMap[channel.id])
              : channel,
        )
        .toList(growable: false);
    return store.write(deviceId: deviceId, channels: updatedChannels);
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
