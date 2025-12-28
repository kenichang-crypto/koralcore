library;

import '../../domain/led_lighting/led_state.dart';

abstract class LedRepository {
  const LedRepository();

  Stream<LedState> observeLedState(String deviceId);

  Future<LedState?> getLedState(String deviceId);

  Future<LedState> updateStatus({
    required String deviceId,
    required LedStatus status,
  });

  Future<LedState> applyScene({
    required String deviceId,
    required String sceneId,
  });

  Future<LedState> applySchedule({
    required String deviceId,
    required String scheduleId,
  });

  Future<LedState> resetToDefault(String deviceId);

  Future<LedState> setChannelLevels({
    required String deviceId,
    required Map<String, int> channelLevels,
  });

  Future<LedState> startRecord(String deviceId);
}
