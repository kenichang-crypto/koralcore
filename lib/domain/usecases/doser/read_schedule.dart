library;

import '../../../app/common/app_error.dart';
import '../../../app/common/app_error_code.dart';
import '../../../domain/doser_dosing/dosing_state.dart';
import '../../../domain/doser_dosing/pump_head_mode.dart';
import '../../../domain/doser_dosing/pump_head_record_detail.dart';
import '../../../domain/doser_dosing/pump_head_record_type.dart';
import '../../../platform/contracts/dosing_repository.dart';

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

/// ReadScheduleUseCase
///
/// Reads pump head schedule from DosingState (BLE sync). Falls back to seed
/// when device not connected or state empty (for demo/offline).
///
/// PARITY: Corresponds to reef-b-app's schedule reading behavior:
/// - DropHeadMainViewModel.getNowRecords() -> dropInformation.getMode(headId)
/// - BLE RETURN opcodes 0x68-0x6D populate DosingState
class ReadScheduleUseCase {
  final DosingRepository dosingRepository;

  const ReadScheduleUseCase({required this.dosingRepository});

  Future<List<ReadScheduleEntrySnapshot>> execute({
    required String deviceId,
    required String headId,
  }) async {
    final int headIndex = _headIdToIndex(headId);
    final DosingState? state = await dosingRepository.getDosingState(deviceId);
    if (state != null) {
      final List<ReadScheduleEntrySnapshot> fromState =
          _mapModeToSnapshots(headId, headIndex, state.getMode(headIndex));
      if (fromState.isNotEmpty) {
        return fromState;
      }
    }
    // Fallback to seed when offline or no schedule
    return _getSeedSnapshots(headId);
  }

  int _headIdToIndex(String headId) {
    final String n = headId.trim().toUpperCase();
    if (n.isEmpty) return 0;
    return (n.codeUnitAt(0) - 65).clamp(0, 3);
  }

  List<ReadScheduleEntrySnapshot> _mapModeToSnapshots(
    String headId,
    int headIndex,
    PumpHeadMode mode,
  ) {
    if (mode.mode == PumpHeadRecordType.none) {
      return const [];
    }
    final String id = '${headId}_${mode.mode.name}';
    final double dose = mode.recordDrop > 0 ? mode.recordDrop : 1.0;
    final int events = mode.totalDrop != null && mode.totalDrop! > 0
        ? mode.totalDrop!.clamp(1, 24)
        : 4;
    final int start = _parseStartMinutes(mode);
    final int? end = _parseEndMinutes(mode);

    switch (mode.mode) {
      case PumpHeadRecordType.h24:
        return [
          ReadScheduleEntrySnapshot(
            id: id,
            type: ReadScheduleEntryType.average24h,
            isEnabled: true,
            doseMlPerEvent: dose,
            eventsPerDay: events,
            startMinutes: start,
            endMinutes: null,
            recurrence: _runDayToRecurrence(mode.runDay),
          ),
        ];
      case PumpHeadRecordType.single:
        return [
          ReadScheduleEntrySnapshot(
            id: id,
            type: ReadScheduleEntryType.singleDose,
            isEnabled: true,
            doseMlPerEvent: dose,
            eventsPerDay: 1,
            startMinutes: start,
            endMinutes: null,
            recurrence: ReadScheduleRecurrence.daily,
          ),
        ];
      case PumpHeadRecordType.custom:
        if (mode.recordDetail.isEmpty) {
          return [
            ReadScheduleEntrySnapshot(
              id: id,
              type: ReadScheduleEntryType.customWindow,
              isEnabled: true,
              doseMlPerEvent: dose,
              eventsPerDay: events,
              startMinutes: start,
              endMinutes: end ?? start + 240,
              recurrence: _runDayToRecurrence(mode.runDay),
            ),
          ];
        }
        final PumpHeadRecordDetail d = mode.recordDetail.first;
        final int detailStart = _parseDetailStart(d.timeString);
        final int detailEnd = _parseDetailEnd(d.timeString);
        return [
          ReadScheduleEntrySnapshot(
            id: id,
            type: ReadScheduleEntryType.customWindow,
            isEnabled: true,
            doseMlPerEvent: (d.totalDrop / 10.0).clamp(0.1, 500.0),
            eventsPerDay: d.dropTime.clamp(1, 24),
            startMinutes: detailStart,
            endMinutes: detailEnd,
            recurrence: _runDayToRecurrence(mode.runDay),
          ),
        ];
      case PumpHeadRecordType.none:
        return const [];
    }
  }

  int _parseStartMinutes(PumpHeadMode mode) {
    if (mode.timeString != null) {
      final int? m = _parseTimeStringToMinutes(mode.timeString!);
      if (m != null) return m;
    }
    return 6 * 60;
  }

  int? _parseEndMinutes(PumpHeadMode mode) {
    if (mode.recordDetail.isNotEmpty) {
      return _parseDetailEnd(mode.recordDetail.first.timeString);
    }
    return null;
  }

  int? _parseTimeStringToMinutes(String s) {
    final RegExpMatch? hhmm = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(s);
    if (hhmm != null) {
      final int h = int.tryParse(hhmm.group(1)!) ?? 0;
      final int m = int.tryParse(hhmm.group(2)!) ?? 0;
      return (h % 24) * 60 + (m % 60);
    }
    return null;
  }

  int _parseDetailStart(String? timeString) {
    if (timeString == null) return 8 * 60;
    final List<String> parts = timeString.split('~');
    if (parts.isNotEmpty) {
      final int? m = _parseTimeStringToMinutes(parts.first.trim());
      if (m != null) return m;
    }
    return 8 * 60;
  }

  int _parseDetailEnd(String? timeString) {
    if (timeString == null) return 12 * 60;
    final List<String> parts = timeString.split('~');
    if (parts.length > 1) {
      final int? m = _parseTimeStringToMinutes(parts[1].trim());
      if (m != null) return m;
    }
    return 12 * 60;
  }

  ReadScheduleRecurrence _runDayToRecurrence(List<bool>? runDay) {
    if (runDay == null || runDay.length < 7) return ReadScheduleRecurrence.daily;
    final bool monFri = runDay[0] && runDay[1] && runDay[2] && runDay[3] && runDay[4];
    final bool satSun = runDay[5] && runDay[6];
    if (monFri && !satSun) return ReadScheduleRecurrence.weekdays;
    if (!monFri && satSun) return ReadScheduleRecurrence.weekends;
    return ReadScheduleRecurrence.daily;
  }

  List<ReadScheduleEntrySnapshot> _getSeedSnapshots(String headId) {
    final String n = headId.toUpperCase();
    final _ScheduleSeed? seed = _scheduleSeeds[n];
    if (seed == null) {
      throw const AppError(
        code: AppErrorCode.invalidParam,
        message: 'Unknown pump head identifier.',
      );
    }
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
