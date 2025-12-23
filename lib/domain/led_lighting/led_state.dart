library;

/// Runtime LED status exposed to the UI/application layers.
enum LedStatus { idle, applying, error }

class LedScheduleWindow {
  final int startMinutesFromMidnight;
  final int endMinutesFromMidnight;
  final String recurrenceLabel;

  const LedScheduleWindow({
    required this.startMinutesFromMidnight,
    required this.endMinutesFromMidnight,
    required this.recurrenceLabel,
  });
}

class LedStateScene {
  final String sceneId;
  final String name;
  final Map<String, int> channelLevels;

  LedStateScene({
    required this.sceneId,
    required this.name,
    required Map<String, int> channelLevels,
  }) : channelLevels = Map<String, int>.unmodifiable(channelLevels);

  LedStateScene copyWith({
    String? sceneId,
    String? name,
    Map<String, int>? channelLevels,
  }) {
    return LedStateScene(
      sceneId: sceneId ?? this.sceneId,
      name: name ?? this.name,
      channelLevels: channelLevels ?? this.channelLevels,
    );
  }
}

class LedStateSchedule {
  final String scheduleId;
  final bool enabled;
  final LedScheduleWindow window;
  final Map<String, int> channelLevels;

  LedStateSchedule({
    required this.scheduleId,
    required this.enabled,
    required this.window,
    required Map<String, int> channelLevels,
  }) : channelLevels = Map<String, int>.unmodifiable(channelLevels);

  LedStateSchedule copyWith({
    String? scheduleId,
    bool? enabled,
    LedScheduleWindow? window,
    Map<String, int>? channelLevels,
  }) {
    return LedStateSchedule(
      scheduleId: scheduleId ?? this.scheduleId,
      enabled: enabled ?? this.enabled,
      window: window ?? this.window,
      channelLevels: channelLevels ?? this.channelLevels,
    );
  }
}

class LedState {
  final String deviceId;
  final LedStatus status;
  final String? activeSceneId;
  final String? activeScheduleId;
  final Map<String, int> channelLevels;
  final List<LedStateScene> scenes;
  final List<LedStateSchedule> schedules;

  LedState({
    required this.deviceId,
    required this.status,
    required this.activeSceneId,
    required this.activeScheduleId,
    required Map<String, int> channelLevels,
    required List<LedStateScene> scenes,
    required List<LedStateSchedule> schedules,
  }) : channelLevels = Map<String, int>.unmodifiable(channelLevels),
       scenes = List<LedStateScene>.unmodifiable(scenes),
       schedules = List<LedStateSchedule>.unmodifiable(schedules);

  LedState copyWith({
    LedStatus? status,
    String? activeSceneId,
    String? activeScheduleId,
    Map<String, int>? channelLevels,
    List<LedStateScene>? scenes,
    List<LedStateSchedule>? schedules,
  }) {
    return LedState(
      deviceId: deviceId,
      status: status ?? this.status,
      activeSceneId: activeSceneId ?? this.activeSceneId,
      activeScheduleId: activeScheduleId ?? this.activeScheduleId,
      channelLevels: channelLevels ?? this.channelLevels,
      scenes: scenes ?? this.scenes,
      schedules: schedules ?? this.schedules,
    );
  }
}
