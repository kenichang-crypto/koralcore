library;

import 'dart:async';

import '../common/app_error.dart';
import '../common/app_error_code.dart';

enum ReadLedScheduleType { dailyProgram, customWindow, sceneBased }

enum ReadLedScheduleRecurrence { everyDay, weekdays, weekends }

class ReadLedScheduleSnapshot {
  final String id;
  final String title;
  final ReadLedScheduleType type;
  final ReadLedScheduleRecurrence recurrence;
  final int startMinutesFromMidnight;
  final int endMinutesFromMidnight;
  final String sceneName;
  final bool isEnabled;

  const ReadLedScheduleSnapshot({
    required this.id,
    required this.title,
    required this.type,
    required this.recurrence,
    required this.startMinutesFromMidnight,
    required this.endMinutesFromMidnight,
    required this.sceneName,
    required this.isEnabled,
  });
}

/// Placeholder use case that supplies LED schedule metadata for a device.
/// The final BLE transport wiring will plug in once the firmware protocol
/// stabilizes, but this snapshot list keeps the UI unblocked.
class ReadLedScheduleUseCase {
  const ReadLedScheduleUseCase();

  Future<List<ReadLedScheduleSnapshot>> execute({
    required String deviceId,
  }) async {
    final _LedScheduleSeed? seed =
        _scheduleSeeds[deviceId] ?? _scheduleSeeds['default'];

    if (seed == null) {
      throw const AppError(
        code: AppErrorCode.invalidParam,
        message: 'Unknown device id for LED schedules.',
      );
    }

    await Future<void>.delayed(seed.latency);
    return List<ReadLedScheduleSnapshot>.unmodifiable(seed.entries);
  }
}

class _LedScheduleSeed {
  final Duration latency;
  final List<ReadLedScheduleSnapshot> entries;

  const _LedScheduleSeed({required this.latency, required this.entries});
}

int _minutes(int hour, int minute) => hour * 60 + minute;

final Map<String, _LedScheduleSeed> _scheduleSeeds = {
  'default': _LedScheduleSeed(
    latency: Duration(milliseconds: 180),
    entries: [
      ReadLedScheduleSnapshot(
        id: 'daily_curve',
        title: 'Daily ramp',
        type: ReadLedScheduleType.dailyProgram,
        recurrence: ReadLedScheduleRecurrence.everyDay,
        startMinutesFromMidnight: _minutes(6, 0),
        endMinutesFromMidnight: _minutes(22, 0),
        sceneName: 'Sunrise Blend',
        isEnabled: true,
      ),
      ReadLedScheduleSnapshot(
        id: 'custom_midday',
        title: 'Midday punch',
        type: ReadLedScheduleType.customWindow,
        recurrence: ReadLedScheduleRecurrence.weekdays,
        startMinutesFromMidnight: _minutes(11, 0),
        endMinutesFromMidnight: _minutes(15, 0),
        sceneName: 'Reef Crest',
        isEnabled: true,
      ),
      ReadLedScheduleSnapshot(
        id: 'moon_scene',
        title: 'Moonlight scene',
        type: ReadLedScheduleType.sceneBased,
        recurrence: ReadLedScheduleRecurrence.weekends,
        startMinutesFromMidnight: _minutes(22, 30),
        endMinutesFromMidnight: _minutes(23, 59),
        sceneName: 'Moonlight',
        isEnabled: false,
      ),
    ],
  ),
  'lagoon_x2': _LedScheduleSeed(
    latency: Duration(milliseconds: 150),
    entries: [
      ReadLedScheduleSnapshot(
        id: 'lagoon_daily',
        title: 'Lagoon daylight',
        type: ReadLedScheduleType.dailyProgram,
        recurrence: ReadLedScheduleRecurrence.everyDay,
        startMinutesFromMidnight: _minutes(7, 0),
        endMinutesFromMidnight: _minutes(21, 30),
        sceneName: 'Lagoon Crest',
        isEnabled: true,
      ),
      ReadLedScheduleSnapshot(
        id: 'lagoon_evening',
        title: 'Evening shimmer',
        type: ReadLedScheduleType.customWindow,
        recurrence: ReadLedScheduleRecurrence.weekends,
        startMinutesFromMidnight: _minutes(20, 0),
        endMinutesFromMidnight: _minutes(23, 0),
        sceneName: 'Shimmer Blues',
        isEnabled: true,
      ),
    ],
  ),
};
