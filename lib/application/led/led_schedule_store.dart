library;

import 'read_led_schedules.dart';

class LedScheduleChannelState {
  final String id;
  final String label;
  final int percentage;

  const LedScheduleChannelState({
    required this.id,
    required this.label,
    required this.percentage,
  });

  LedScheduleChannelState copyWith({String? label, int? percentage}) {
    return LedScheduleChannelState(
      id: id,
      label: label ?? this.label,
      percentage: percentage ?? this.percentage,
    );
  }
}

class LedScheduleRecord {
  final String id;
  final String title;
  final ReadLedScheduleType type;
  final ReadLedScheduleRecurrence recurrence;
  final int startMinutesFromMidnight;
  final int endMinutesFromMidnight;
  final bool isEnabled;
  final List<LedScheduleChannelState> channels;
  final String? sceneName;

  LedScheduleRecord({
    required this.id,
    required this.title,
    required this.type,
    required this.recurrence,
    required this.startMinutesFromMidnight,
    required this.endMinutesFromMidnight,
    required this.isEnabled,
    required List<LedScheduleChannelState> channels,
    this.sceneName,
  }) : channels = List<LedScheduleChannelState>.unmodifiable(
         channels.map((channel) => channel.copyWith()),
       );

  LedScheduleRecord copyWith({
    String? id,
    String? title,
    ReadLedScheduleType? type,
    ReadLedScheduleRecurrence? recurrence,
    int? startMinutesFromMidnight,
    int? endMinutesFromMidnight,
    bool? isEnabled,
    List<LedScheduleChannelState>? channels,
    String? sceneName,
  }) {
    return LedScheduleRecord(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      recurrence: recurrence ?? this.recurrence,
      startMinutesFromMidnight:
          startMinutesFromMidnight ?? this.startMinutesFromMidnight,
      endMinutesFromMidnight:
          endMinutesFromMidnight ?? this.endMinutesFromMidnight,
      isEnabled: isEnabled ?? this.isEnabled,
      channels: channels ?? this.channels,
      sceneName: sceneName ?? this.sceneName,
    );
  }
}

class LedScheduleMemoryStore {
  LedScheduleMemoryStore();

  final Map<String, _DeviceScheduleState> _state = {};

  Future<List<LedScheduleRecord>> listSchedules({
    required String deviceId,
  }) async {
    final _DeviceScheduleState state = _ensureState(deviceId);
    await Future<void>.delayed(state.latency);
    return state.records
        .map((record) => record.copyWith())
        .toList(growable: false);
  }

  Future<LedScheduleRecord> saveSchedule({
    required String deviceId,
    required LedScheduleRecord record,
  }) async {
    final _DeviceScheduleState state = _ensureState(deviceId);
    await Future<void>.delayed(const Duration(milliseconds: 220));

    final LedScheduleRecord sanitized = record.copyWith();
    final int existingIndex = state.records.indexWhere(
      (entry) => entry.id == sanitized.id,
    );
    if (existingIndex == -1) {
      state.records.insert(0, sanitized);
    } else {
      state.records[existingIndex] = sanitized;
    }
    return sanitized.copyWith();
  }

  String nextScheduleId(String deviceId) {
    final String prefix = deviceId.isEmpty ? 'default' : deviceId;
    return 'user-$prefix-${DateTime.now().millisecondsSinceEpoch}';
  }

  _DeviceScheduleState _ensureState(String deviceId) {
    if (_state.containsKey(deviceId)) {
      return _state[deviceId]!;
    }

    final _SeedSchedule seed =
        _seedSchedules[deviceId] ?? _seedSchedules['default']!;
    _state[deviceId] = _DeviceScheduleState(
      latency: seed.latency,
      records: seed.records.map((record) => record.copyWith()).toList(),
    );
    return _state[deviceId]!;
  }
}

class _DeviceScheduleState {
  final Duration latency;
  final List<LedScheduleRecord> records;

  _DeviceScheduleState({required this.latency, required this.records});
}

class _SeedSchedule {
  final Duration latency;
  final List<LedScheduleRecord> records;

  const _SeedSchedule({required this.latency, required this.records});
}

int _minutes(int hour, int minute) => hour * 60 + minute;

List<LedScheduleChannelState> _channels({
  required int white,
  required int blue,
}) {
  return [
    LedScheduleChannelState(
      id: 'white',
      label: 'Cool white',
      percentage: white,
    ),
    LedScheduleChannelState(id: 'blue', label: 'Royal blue', percentage: blue),
  ];
}

final Map<String, _SeedSchedule> _seedSchedules = {
  'default': _SeedSchedule(
    latency: const Duration(milliseconds: 180),
    records: [
      LedScheduleRecord(
        id: 'daily_curve',
        title: 'Daily ramp',
        type: ReadLedScheduleType.dailyProgram,
        recurrence: ReadLedScheduleRecurrence.everyDay,
        startMinutesFromMidnight: _minutes(6, 0),
        endMinutesFromMidnight: _minutes(22, 0),
        isEnabled: true,
        channels: _channels(white: 65, blue: 85),
        sceneName: 'Sunrise Blend',
      ),
      LedScheduleRecord(
        id: 'custom_midday',
        title: 'Midday punch',
        type: ReadLedScheduleType.customWindow,
        recurrence: ReadLedScheduleRecurrence.weekdays,
        startMinutesFromMidnight: _minutes(11, 0),
        endMinutesFromMidnight: _minutes(15, 0),
        isEnabled: true,
        channels: _channels(white: 80, blue: 90),
        sceneName: 'Reef Crest',
      ),
      LedScheduleRecord(
        id: 'moon_scene',
        title: 'Moonlight scene',
        type: ReadLedScheduleType.sceneBased,
        recurrence: ReadLedScheduleRecurrence.weekends,
        startMinutesFromMidnight: _minutes(22, 30),
        endMinutesFromMidnight: _minutes(23, 59),
        isEnabled: false,
        channels: _channels(white: 10, blue: 25),
        sceneName: 'Moonlight',
      ),
    ],
  ),
  'lagoon_x2': _SeedSchedule(
    latency: const Duration(milliseconds: 150),
    records: [
      LedScheduleRecord(
        id: 'lagoon_daily',
        title: 'Lagoon daylight',
        type: ReadLedScheduleType.dailyProgram,
        recurrence: ReadLedScheduleRecurrence.everyDay,
        startMinutesFromMidnight: _minutes(7, 0),
        endMinutesFromMidnight: _minutes(21, 30),
        isEnabled: true,
        channels: _channels(white: 60, blue: 80),
        sceneName: 'Lagoon Crest',
      ),
      LedScheduleRecord(
        id: 'lagoon_evening',
        title: 'Evening shimmer',
        type: ReadLedScheduleType.customWindow,
        recurrence: ReadLedScheduleRecurrence.weekends,
        startMinutesFromMidnight: _minutes(20, 0),
        endMinutesFromMidnight: _minutes(23, 0),
        isEnabled: true,
        channels: _channels(white: 30, blue: 60),
        sceneName: 'Shimmer Blues',
      ),
    ],
  ),
};
