library;

import 'dart:async';

import '../../domain/led_lighting/led_state.dart';
import '../../platform/contracts/led_repository.dart';

class LedRepositoryImpl extends LedRepository {
  LedRepositoryImpl();

  final Map<String, _LedStateStore> _stores = <String, _LedStateStore>{};

  @override
  Stream<LedState> observeLedState(String deviceId) {
    return _ensureStore(deviceId).stream;
  }

  @override
  Future<LedState?> getLedState(String deviceId) async {
    return _ensureStore(deviceId).state;
  }

  @override
  Future<LedState> updateStatus({
    required String deviceId,
    required LedStatus status,
  }) async {
    return _ensureStore(deviceId).update((LedState state) {
      return state.copyWith(status: status);
    });
  }

  @override
  Future<LedState> applyScene({
    required String deviceId,
    required String sceneId,
  }) async {
    final _LedStateStore store = _ensureStore(deviceId);
    return store.update((LedState state) {
      final LedStateScene scene = state.scenes.firstWhere(
        (scene) => scene.sceneId == sceneId,
        orElse: () => throw StateError('Unknown LED scene $sceneId'),
      );
      return state.copyWith(
        status: LedStatus.idle,
        activeSceneId: scene.sceneId,
        activeScheduleId: null,
        channelLevels: scene.channelLevels,
      );
    });
  }

  @override
  Future<LedState> applySchedule({
    required String deviceId,
    required String scheduleId,
  }) async {
    final _LedStateStore store = _ensureStore(deviceId);
    return store.update((LedState state) {
      final LedStateSchedule schedule = state.schedules.firstWhere(
        (schedule) => schedule.scheduleId == scheduleId,
        orElse: () =>
            throw StateError('Unknown LED schedule $scheduleId for $deviceId'),
      );
      return state.copyWith(
        status: LedStatus.idle,
        activeSceneId: null,
        activeScheduleId: schedule.scheduleId,
        channelLevels: schedule.channelLevels,
      );
    });
  }

  @override
  Future<LedState> resetToDefault(String deviceId) async {
    final _LedStateStore store = _ensureStore(deviceId);
    return store.update((LedState state) {
      return state.copyWith(
        status: LedStatus.idle,
        activeSceneId: null,
        activeScheduleId: null,
        channelLevels: _defaultChannelLevels(),
      );
    });
  }

  @override
  Future<LedState> setChannelLevels({
    required String deviceId,
    required Map<String, int> channelLevels,
  }) async {
    final _LedStateStore store = _ensureStore(deviceId);
    final Map<String, int> sanitized = <String, int>{
      for (final MapEntry<String, int> entry in channelLevels.entries)
        entry.key: entry.value.clamp(0, 100),
    };
    return store.update((LedState state) {
      return state.copyWith(
        channelLevels: Map<String, int>.unmodifiable(<String, int>{
          ...state.channelLevels,
          ...sanitized,
        }),
      );
    });
  }

  _LedStateStore _ensureStore(String deviceId) {
    return _stores.putIfAbsent(deviceId, () {
      final LedState initialState = LedState(
        deviceId: deviceId,
        status: LedStatus.idle,
        activeSceneId: null,
        activeScheduleId: null,
        channelLevels: _defaultChannelLevels(),
        scenes: _defaultScenes(),
        schedules: _defaultSchedules(),
      );
      return _LedStateStore(initialState);
    });
  }

  Map<String, int> _defaultChannelLevels() {
    return <String, int>{'white': 65, 'blue': 80};
  }

  List<LedStateScene> _defaultScenes() {
    return <LedStateScene>[
      LedStateScene(
        sceneId: 'sunrise',
        name: 'Sunrise Blend',
        channelLevels: const <String, int>{'white': 55, 'blue': 70},
      ),
      LedStateScene(
        sceneId: 'reef_crest',
        name: 'Reef Crest',
        channelLevels: const <String, int>{'white': 70, 'blue': 90},
      ),
      LedStateScene(
        sceneId: 'moonlight',
        name: 'Moonlight',
        channelLevels: const <String, int>{'white': 10, 'blue': 25},
      ),
    ];
  }

  List<LedStateSchedule> _defaultSchedules() {
    return <LedStateSchedule>[
      LedStateSchedule(
        scheduleId: 'daily_curve',
        enabled: true,
        window: const LedScheduleWindow(
          startMinutesFromMidnight: 6 * 60,
          endMinutesFromMidnight: 22 * 60,
          recurrenceLabel: 'Every day',
        ),
        channelLevels: const <String, int>{'white': 65, 'blue': 85},
      ),
      LedStateSchedule(
        scheduleId: 'midday_boost',
        enabled: true,
        window: const LedScheduleWindow(
          startMinutesFromMidnight: 11 * 60,
          endMinutesFromMidnight: 15 * 60,
          recurrenceLabel: 'Weekdays',
        ),
        channelLevels: const <String, int>{'white': 80, 'blue': 90},
      ),
    ];
  }
}

class _LedStateStore {
  _LedStateStore(this._state)
    : _controller = StreamController<LedState>.broadcast() {
    _controller.onListen = () {
      _controller.add(_state);
    };
  }

  LedState _state;
  final StreamController<LedState> _controller;

  LedState get state => _state;
  Stream<LedState> get stream => _controller.stream;

  LedState update(LedState Function(LedState) updater) {
    _state = updater(_state);
    _controller.add(_state);
    return _state;
  }
}
