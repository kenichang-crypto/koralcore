library;

import 'dart:async';

import '../../../data/repositories/schedule_repository_impl.dart';
import '../../led_lighting/led_state.dart';
import '../../../platform/contracts/led_repository.dart';

enum ReadLedScheduleType { dailyProgram, customWindow, sceneBased }

enum ReadLedScheduleRecurrence { everyDay, weekdays, weekends }

class ReadLedScheduleChannelSnapshot {
  final String id;
  final String label;
  final int percentage;

  const ReadLedScheduleChannelSnapshot({
    required this.id,
    required this.label,
    required this.percentage,
  });
}

class ReadLedScheduleSnapshot {
  final String id;
  final String title;
  final ReadLedScheduleType type;
  final ReadLedScheduleRecurrence recurrence;
  final int startMinutesFromMidnight;
  final int endMinutesFromMidnight;
  final String sceneName;
  final bool isEnabled;
  final bool isDerived;
  final List<ReadLedScheduleChannelSnapshot> channels;

  const ReadLedScheduleSnapshot({
    required this.id,
    required this.title,
    required this.type,
    required this.recurrence,
    required this.startMinutesFromMidnight,
    required this.endMinutesFromMidnight,
    required this.sceneName,
    required this.isEnabled,
    required this.isDerived,
    required this.channels,
  });
}

/// ReadLedScheduleUseCase
///
/// PARITY: Corresponds to reef-b-app's LED schedule reading:
/// - LedScheduleListActivity: displays schedules from LedInformation
/// - LedInformation.schedules contains all active schedules
/// - Schedules are populated via BLE sync: ledSyncInformation callback
/// - Schedule types: daily program, custom window, scene-based
class ReadLedScheduleUseCase {
  final LedRepository ledRepository;
  final ScheduleRepositoryImpl? scheduleRepository;

  const ReadLedScheduleUseCase({
    required this.ledRepository,
    this.scheduleRepository,
  });

  Future<List<ReadLedScheduleSnapshot>> execute({
    required String deviceId,
  }) async {
    final List<ReadLedScheduleSnapshot> result = [];
    final LedState? state = await ledRepository.getLedState(deviceId);
    if (state != null && state.schedules.isNotEmpty) {
      result.addAll(
        state.schedules.map(_mapStateSchedule).toList(growable: false),
      );
    }
    if (scheduleRepository != null) {
      final local = await scheduleRepository!.getSchedules(deviceId);
      final existingIds = result.map((s) => s.id).toSet();
      for (final r in local) {
        if (!existingIds.contains(r.scheduleId)) {
          result.add(
            ReadLedScheduleSnapshot(
              id: r.scheduleId,
              title: r.title,
              type: r.type,
              recurrence: r.recurrence,
              startMinutesFromMidnight: r.startMinutesFromMidnight,
              endMinutesFromMidnight: r.endMinutesFromMidnight,
              sceneName: r.sceneName,
              isEnabled: r.isEnabled,
              isDerived: false,
              channels: r.channels,
            ),
          );
        }
      }
    }
    return result;
  }
}

ReadLedScheduleSnapshot _mapStateSchedule(LedStateSchedule record) {
  final bool derived = _isDerivedSchedule(record);
  return ReadLedScheduleSnapshot(
    id: record.scheduleId,
    title: _formatWindowTitle(record.window),
    type: ReadLedScheduleType.customWindow,
    recurrence: ReadLedScheduleRecurrence.everyDay,
    startMinutesFromMidnight: record.window.startMinutesFromMidnight,
    endMinutesFromMidnight: record.window.endMinutesFromMidnight,
    sceneName: _formatChannelSummary(record.channelLevels),
    isEnabled: record.enabled,
    isDerived: derived,
    channels: record.channelLevels.entries
        .map(
          (entry) => ReadLedScheduleChannelSnapshot(
            id: entry.key,
            label: entry.key,
            percentage: entry.value,
          ),
        )
        .toList(growable: false),
  );
}

String _formatChannelSummary(Map<String, int> channels) {
  if (channels.isEmpty) {
    return 'Custom spectrum';
  }
  return channels.entries
      .map((entry) => '${entry.key} ${entry.value}%')
      .join(' / ');
}

String _formatWindowTitle(LedScheduleWindow window) {
  final Duration start = Duration(minutes: window.startMinutesFromMidnight);
  final Duration end = Duration(minutes: window.endMinutesFromMidnight);
  String format(Duration duration) {
    final int hours = (duration.inMinutes ~/ 60) % 24;
    final int minutes = duration.inMinutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  return '${format(start)} → ${format(end)}';
}

bool _isDerivedSchedule(LedStateSchedule schedule) {
  return schedule.scheduleId.startsWith('record-');
}
