import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show TimeOfDay;

import '../../../../application/common/app_error.dart';
import '../../../../application/common/app_error_code.dart';
import '../../../../application/common/app_session.dart';
import '../../../../application/doser/apply_schedule_usecase.dart';
import '../../../../application/doser/read_schedule.dart';
import '../../../../application/doser/schedule_result.dart';
import '../../../../domain/doser_dosing/pump_speed.dart';
import '../../../../domain/doser_schedule/custom_window_schedule_definition.dart';
import '../../../../domain/doser_schedule/daily_average_schedule_definition.dart';
import '../../../../domain/doser_schedule/schedule_weekday.dart';
import '../models/pump_head_schedule_entry.dart';

class PumpHeadScheduleController extends ChangeNotifier {
  final String headId;
  final AppSession session;
  final ReadScheduleUseCase readScheduleUseCase;
  final ApplyScheduleUseCase applyScheduleUseCase;

  List<PumpHeadScheduleEntry> _entries = const [];
  bool _isLoading = true;
  bool _isApplyingDailyAverage = false;
  bool _isApplyingCustomWindow = false;
  AppErrorCode? _lastErrorCode;

  PumpHeadScheduleController({
    required this.headId,
    required this.session,
    required this.readScheduleUseCase,
    required this.applyScheduleUseCase,
  });

  List<PumpHeadScheduleEntry> get entries => _entries;
  bool get isLoading => _isLoading;
  bool get isApplyingDailyAverage => _isApplyingDailyAverage;
  bool get isApplyingCustomWindow => _isApplyingCustomWindow;
  AppErrorCode? get lastErrorCode => _lastErrorCode;

  Future<void> refresh() async {
    final String? deviceId = session.activeDeviceId;
    if (deviceId == null) {
      _entries = const [];
      _isLoading = false;
      _setError(AppErrorCode.noActiveDevice);
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final List<ReadScheduleEntrySnapshot> snapshots =
          await readScheduleUseCase.execute(deviceId: deviceId, headId: headId);
      _entries = snapshots.map(_mapSnapshot).toList(growable: false);
      _clearErrorFlag();
    } on AppError catch (error) {
      _entries = const [];
      _setError(error.code);
    } catch (_) {
      _entries = const [];
      _setError(AppErrorCode.unknownError);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    if (_lastErrorCode == null) return;
    _lastErrorCode = null;
    notifyListeners();
  }

  Future<bool> applyDailyAverageSchedule() async {
    final String? deviceId = session.activeDeviceId;
    if (deviceId == null) {
      _setError(AppErrorCode.noActiveDevice);
      notifyListeners();
      return false;
    }

    if (_isApplyingDailyAverage) {
      return false;
    }

    _isApplyingDailyAverage = true;
    notifyListeners();

    try {
      final DailyAverageScheduleDefinition schedule =
          _buildDailyAverageScheduleDefinition();
      final ScheduleResult result = await applyScheduleUseCase
          .applyDailyAverageSchedule(deviceId: deviceId, schedule: schedule);

      if (result.isSuccess) {
        await refresh();
        return true;
      }

      _setError(result.errorCode ?? AppErrorCode.unknownError);
      notifyListeners();
      return false;
    } on AppError catch (error) {
      _setError(error.code);
      notifyListeners();
      return false;
    } catch (_) {
      _setError(AppErrorCode.unknownError);
      notifyListeners();
      return false;
    } finally {
      _isApplyingDailyAverage = false;
      notifyListeners();
    }
  }

  Future<bool> applyCustomWindowSchedule() async {
    final String? deviceId = session.activeDeviceId;
    if (deviceId == null) {
      _setError(AppErrorCode.noActiveDevice);
      notifyListeners();
      return false;
    }

    if (_isApplyingCustomWindow) {
      return false;
    }

    _isApplyingCustomWindow = true;
    notifyListeners();

    try {
      final CustomWindowScheduleDefinition schedule =
          _buildCustomWindowScheduleDefinition();
      final ScheduleResult result = await applyScheduleUseCase
          .applyCustomWindowSchedule(deviceId: deviceId, schedule: schedule);

      if (result.isSuccess) {
        await refresh();
        return true;
      }

      _setError(result.errorCode ?? AppErrorCode.unknownError);
      notifyListeners();
      return false;
    } on AppError catch (error) {
      _setError(error.code);
      notifyListeners();
      return false;
    } catch (_) {
      _setError(AppErrorCode.unknownError);
      notifyListeners();
      return false;
    } finally {
      _isApplyingCustomWindow = false;
      notifyListeners();
    }
  }

  PumpHeadScheduleEntry _mapSnapshot(ReadScheduleEntrySnapshot snapshot) {
    return PumpHeadScheduleEntry(
      id: snapshot.id,
      type: _mapType(snapshot.type),
      doseMlPerEvent: snapshot.doseMlPerEvent,
      eventsPerDay: snapshot.eventsPerDay,
      startTime: _timeFromMinutes(snapshot.startMinutes),
      endTime: snapshot.endMinutes == null
          ? null
          : _timeFromMinutes(snapshot.endMinutes!),
      recurrence: _mapRecurrence(snapshot.recurrence),
      isEnabled: snapshot.isEnabled,
    );
  }

  TimeOfDay _timeFromMinutes(int minutes) {
    final int normalized = minutes % (24 * 60);
    final int hour = normalized ~/ 60;
    final int minute = normalized % 60;
    return TimeOfDay(hour: hour, minute: minute);
  }

  PumpHeadScheduleType _mapType(ReadScheduleEntryType type) {
    switch (type) {
      case ReadScheduleEntryType.average24h:
        return PumpHeadScheduleType.dailyAverage;
      case ReadScheduleEntryType.customWindow:
        return PumpHeadScheduleType.customWindow;
      case ReadScheduleEntryType.singleDose:
        return PumpHeadScheduleType.singleDose;
    }
  }

  PumpHeadScheduleRecurrence _mapRecurrence(ReadScheduleRecurrence recurrence) {
    switch (recurrence) {
      case ReadScheduleRecurrence.daily:
        return PumpHeadScheduleRecurrence.daily;
      case ReadScheduleRecurrence.weekdays:
        return PumpHeadScheduleRecurrence.weekdays;
      case ReadScheduleRecurrence.weekends:
        return PumpHeadScheduleRecurrence.weekends;
    }
  }

  void _clearErrorFlag() {
    if (_lastErrorCode == null) return;
    _lastErrorCode = null;
  }

  void _setError(AppErrorCode code) {
    _lastErrorCode = code;
  }

  DailyAverageScheduleDefinition _buildDailyAverageScheduleDefinition() {
    final int pumpId = _pumpIdFromHeadId(headId);
    final Set<ScheduleWeekday> repeatDays = ScheduleWeekday.values.toSet();
    final List<DailyDoseSlot> slots = <DailyDoseSlot>[
      DailyDoseSlot(hour: 0, minute: 0, doseMl: 0.8, speed: PumpSpeed.low),
      DailyDoseSlot(hour: 6, minute: 0, doseMl: 0.8, speed: PumpSpeed.low),
      DailyDoseSlot(hour: 12, minute: 0, doseMl: 0.8, speed: PumpSpeed.low),
      DailyDoseSlot(hour: 18, minute: 0, doseMl: 0.8, speed: PumpSpeed.low),
    ];

    return DailyAverageScheduleDefinition(
      scheduleId: 'daily-$pumpId',
      pumpId: pumpId,
      repeatDays: repeatDays,
      slots: slots,
    );
  }

  CustomWindowScheduleDefinition _buildCustomWindowScheduleDefinition() {
    final int pumpId = _pumpIdFromHeadId(headId);
    final List<ScheduleWindowChunk> chunks = <ScheduleWindowChunk>[
      ScheduleWindowChunk(
        chunkIndex: 0,
        windowStartMinute: 0,
        windowEndMinute: 120,
        events: const <WindowDoseEvent>[
          WindowDoseEvent(
            minuteOffset: 0,
            doseMl: 0.9,
            speed: PumpSpeed.medium,
          ),
          WindowDoseEvent(
            minuteOffset: 60,
            doseMl: 0.9,
            speed: PumpSpeed.medium,
          ),
        ],
      ),
      ScheduleWindowChunk(
        chunkIndex: 1,
        windowStartMinute: 240,
        windowEndMinute: 360,
        events: const <WindowDoseEvent>[
          WindowDoseEvent(minuteOffset: 15, doseMl: 1.1, speed: PumpSpeed.high),
          WindowDoseEvent(minuteOffset: 75, doseMl: 1.1, speed: PumpSpeed.high),
        ],
      ),
      ScheduleWindowChunk(
        chunkIndex: 2,
        windowStartMinute: 720,
        windowEndMinute: 900,
        events: const <WindowDoseEvent>[
          WindowDoseEvent(minuteOffset: 0, doseMl: 1.3, speed: PumpSpeed.low),
          WindowDoseEvent(minuteOffset: 90, doseMl: 1.3, speed: PumpSpeed.low),
        ],
      ),
    ];

    return CustomWindowScheduleDefinition(
      scheduleId: 'custom-$pumpId',
      pumpId: pumpId,
      chunks: chunks,
    );
  }

  int _pumpIdFromHeadId(String value) {
    final String normalized = value.trim().toUpperCase();
    if (normalized.isEmpty) {
      return 1;
    }
    final int candidate = normalized.codeUnitAt(0) - 64;
    if (candidate < 1) {
      return 1;
    }
    return candidate;
  }
}
