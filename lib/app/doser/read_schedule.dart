library;

import 'dart:async';

import '../common/app_error.dart';
import '../common/app_error_code.dart';

/// Canonical schedule entry types returned from a read-only poll.
enum ReadScheduleEntryType { average24h, customWindow, singleDose }

enum ReadScheduleRecurrence { daily, weekdays, weekends }

/// Snapshot describing a single scheduled dose entry.
class ReadScheduleEntrySnapshot {
  final String id;
  final ReadScheduleEntryType type;
  final bool isEnabled;
  final double doseMlPerEvent;
  final int eventsPerDay;
  final int startMinutes;
  final int? endMinutes;
  final ReadScheduleRecurrence recurrence;

  const ReadScheduleEntrySnapshot({
    required this.id,
    required this.type,
    required this.isEnabled,
    required this.doseMlPerEvent,
    required this.eventsPerDay,
    required this.startMinutes,
    this.endMinutes,
    required this.recurrence,
  });
}

/// Placeholder use case for retrieving a pump head schedule overview.
/// The actual BLE / repository wiring will be added once the transport
/// strategy for dosing schedules is finalized.
class ReadScheduleUseCase {
  const ReadScheduleUseCase();

  Future<List<ReadScheduleEntrySnapshot>> execute({
    required String deviceId,
    required String headId,
  }) async {
    final String normalizedHeadId = headId.toUpperCase();
    final _ScheduleSeed? seed = _scheduleSeeds[normalizedHeadId];

    if (seed == null) {
      throw const AppError(
        code: AppErrorCode.invalidParam,
        message: 'Unknown pump head identifier.',
      );
    }

    await Future<void>.delayed(seed.latency);
    return List<ReadScheduleEntrySnapshot>.unmodifiable(seed.entries);
  }
}

class _ScheduleSeed {
  final Duration latency;
  final List<ReadScheduleEntrySnapshot> entries;

  const _ScheduleSeed({required this.latency, required this.entries});
}

const Map<String, _ScheduleSeed> _scheduleSeeds = <String, _ScheduleSeed>{
  'A': _ScheduleSeed(
    latency: Duration(milliseconds: 180),
    entries: [
      ReadScheduleEntrySnapshot(
        id: 'A_daily',
        type: ReadScheduleEntryType.average24h,
        isEnabled: true,
        doseMlPerEvent: 2.5,
        eventsPerDay: 4,
        startMinutes: 6 * 60,
        recurrence: ReadScheduleRecurrence.daily,
      ),
      ReadScheduleEntrySnapshot(
        id: 'A_custom',
        type: ReadScheduleEntryType.customWindow,
        isEnabled: true,
        doseMlPerEvent: 1.8,
        eventsPerDay: 3,
        startMinutes: 8 * 60,
        endMinutes: 12 * 60,
        recurrence: ReadScheduleRecurrence.weekdays,
      ),
      ReadScheduleEntrySnapshot(
        id: 'A_single',
        type: ReadScheduleEntryType.singleDose,
        isEnabled: false,
        doseMlPerEvent: 5.0,
        eventsPerDay: 1,
        startMinutes: 21 * 60 + 30,
        recurrence: ReadScheduleRecurrence.weekends,
      ),
    ],
  ),
  'B': _ScheduleSeed(
    latency: Duration(milliseconds: 160),
    entries: [
      ReadScheduleEntrySnapshot(
        id: 'B_daily',
        type: ReadScheduleEntryType.average24h,
        isEnabled: true,
        doseMlPerEvent: 1.9,
        eventsPerDay: 6,
        startMinutes: 5 * 60,
        recurrence: ReadScheduleRecurrence.daily,
      ),
      ReadScheduleEntrySnapshot(
        id: 'B_custom',
        type: ReadScheduleEntryType.customWindow,
        isEnabled: false,
        doseMlPerEvent: 2.2,
        eventsPerDay: 2,
        startMinutes: 18 * 60,
        endMinutes: 22 * 60,
        recurrence: ReadScheduleRecurrence.weekdays,
      ),
    ],
  ),
  'C': _ScheduleSeed(
    latency: Duration(milliseconds: 140),
    entries: [
      ReadScheduleEntrySnapshot(
        id: 'C_single',
        type: ReadScheduleEntryType.singleDose,
        isEnabled: true,
        doseMlPerEvent: 4.5,
        eventsPerDay: 1,
        startMinutes: 10 * 60,
        recurrence: ReadScheduleRecurrence.daily,
      ),
    ],
  ),
  'D': _ScheduleSeed(
    latency: Duration(milliseconds: 200),
    entries: [
      ReadScheduleEntrySnapshot(
        id: 'D_custom',
        type: ReadScheduleEntryType.customWindow,
        isEnabled: true,
        doseMlPerEvent: 2.0,
        eventsPerDay: 4,
        startMinutes: 7 * 60,
        endMinutes: 13 * 60,
        recurrence: ReadScheduleRecurrence.daily,
      ),
      ReadScheduleEntrySnapshot(
        id: 'D_daily',
        type: ReadScheduleEntryType.average24h,
        isEnabled: true,
        doseMlPerEvent: 3.0,
        eventsPerDay: 4,
        startMinutes: 0,
        recurrence: ReadScheduleRecurrence.weekends,
      ),
    ],
  ),
};
