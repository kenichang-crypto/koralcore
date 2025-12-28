import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show TimeOfDay;

import '../../../../application/common/app_error.dart';
import '../../../../application/common/app_error_code.dart';
import '../../../../application/common/app_session.dart';
import '../../../../application/doser/apply_schedule_usecase.dart';
import '../../../../application/doser/read_schedule.dart';
import '../../../../application/doser/schedule_result.dart';
import '../../../../domain/doser_dosing/custom_window_schedule_definition.dart';
import '../../../../domain/doser_dosing/daily_average_schedule_definition.dart';
import '../models/pump_head_schedule_entry.dart';

class PumpHeadScheduleController extends ChangeNotifier {
  final String headId;
  final AppSession session;
  final ReadScheduleUseCase readScheduleUseCase;
  final ApplyScheduleUseCase applyScheduleUseCase;

  List<PumpHeadScheduleEntry> _entries = const [];
  List<PumpHeadScheduleEntry> _remoteEntries = const [];
  final Map<String, PumpHeadScheduleEntry> _localOverrides =
      <String, PumpHeadScheduleEntry>{};
  bool _isLoading = true;
  AppErrorCode? _lastErrorCode;

  PumpHeadScheduleController({
    required this.headId,
    required this.session,
    required this.readScheduleUseCase,
    required this.applyScheduleUseCase,
  });

  List<PumpHeadScheduleEntry> get entries => _entries;
  bool get isLoading => _isLoading;
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
      _remoteEntries = snapshots.map(_mapSnapshot).toList(growable: false);
      _mergeEntries();
      _clearErrorFlag();
    } on AppError catch (error) {
      _remoteEntries = const [];
      _mergeEntries();
      _setError(error.code);
    } catch (_) {
      _remoteEntries = const [];
      _mergeEntries();
      _setError(AppErrorCode.unknownError);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveDailyAverageSchedule({
    required DailyAverageScheduleDefinition definition,
    required PumpHeadScheduleEntry preview,
  }) async {
    final String? deviceId = session.activeDeviceId;
    if (deviceId == null) {
      _setError(AppErrorCode.noActiveDevice);
      notifyListeners();
      return false;
    }

    try {
      final ScheduleResult result = await applyScheduleUseCase
          .applyDailyAverageSchedule(deviceId: deviceId, schedule: definition);

      if (result.isSuccess) {
        upsertLocalEntry(preview);
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
    }
  }

  Future<bool> saveCustomWindowSchedule({
    required CustomWindowScheduleDefinition definition,
    required PumpHeadScheduleEntry preview,
  }) async {
    final String? deviceId = session.activeDeviceId;
    if (deviceId == null) {
      _setError(AppErrorCode.noActiveDevice);
      notifyListeners();
      return false;
    }

    try {
      final ScheduleResult result = await applyScheduleUseCase
          .applyCustomWindowSchedule(deviceId: deviceId, schedule: definition);

      if (result.isSuccess) {
        upsertLocalEntry(preview);
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

  void _mergeEntries() {
    final List<PumpHeadScheduleEntry> merged = <PumpHeadScheduleEntry>[];
    final Set<String> seen = <String>{};

    for (final PumpHeadScheduleEntry entry in _remoteEntries) {
      final PumpHeadScheduleEntry next = _localOverrides[entry.id] ?? entry;
      merged.add(next);
      seen.add(entry.id);
    }

    for (final PumpHeadScheduleEntry override in _localOverrides.values) {
      if (seen.contains(override.id)) {
        continue;
      }
      merged.add(override);
    }

    _entries = merged;
  }

  void upsertLocalEntry(PumpHeadScheduleEntry entry) {
    _localOverrides[entry.id] = entry;
    _mergeEntries();
    notifyListeners();
  }

  void clearError() {
    if (_lastErrorCode == null) {
      return;
    }
    _lastErrorCode = null;
    notifyListeners();
  }
}
