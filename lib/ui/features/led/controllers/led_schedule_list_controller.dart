import 'package:flutter/material.dart';

import '../../../../application/common/app_session.dart';
import '../../../../application/common/app_error.dart';
import '../../../../application/common/app_error_code.dart';
import '../../../../application/led/read_led_schedules.dart';
import '../models/led_schedule_summary.dart';

class LedScheduleListController extends ChangeNotifier {
  final AppSession session;
  final ReadLedScheduleUseCase readLedScheduleUseCase;

  List<LedScheduleSummary> _schedules = const [];
  bool _isLoading = true;
  AppErrorCode? _lastErrorCode;

  LedScheduleListController({
    required this.session,
    required this.readLedScheduleUseCase,
  });

  List<LedScheduleSummary> get schedules => _schedules;
  bool get isLoading => _isLoading;
  AppErrorCode? get lastErrorCode => _lastErrorCode;

  void clearError() {
    if (_lastErrorCode == null) {
      return;
    }
    _lastErrorCode = null;
    notifyListeners();
  }

  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();

    final deviceId = session.activeDeviceId;
    if (deviceId == null) {
      _schedules = const [];
      _setError(AppErrorCode.noDeviceSelected);
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final snapshots = await readLedScheduleUseCase.execute(
        deviceId: deviceId,
      );
      _schedules = snapshots.map(_mapSnapshot).toList(growable: false);
      _lastErrorCode = null;
    } on AppError catch (error) {
      _schedules = const [];
      _setError(error.code);
    } catch (_) {
      _schedules = const [];
      _setError(AppErrorCode.unknownError);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _setError(AppErrorCode code) {
    _lastErrorCode = code;
  }

  LedScheduleSummary _mapSnapshot(ReadLedScheduleSnapshot snapshot) {
    return LedScheduleSummary(
      id: snapshot.id,
      title: snapshot.title,
      type: _mapType(snapshot.type),
      recurrence: _mapRecurrence(snapshot.recurrence),
      startTime: _minutesToTime(snapshot.startMinutesFromMidnight),
      endTime: _minutesToTime(snapshot.endMinutesFromMidnight),
      sceneName: snapshot.sceneName,
      isEnabled: snapshot.isEnabled,
      channels: snapshot.channels
          .map(
            (channel) => LedScheduleChannelValue(
              id: channel.id,
              label: channel.label,
              percentage: channel.percentage,
            ),
          )
          .toList(growable: false),
    );
  }

  LedScheduleType _mapType(ReadLedScheduleType type) {
    switch (type) {
      case ReadLedScheduleType.dailyProgram:
        return LedScheduleType.dailyProgram;
      case ReadLedScheduleType.customWindow:
        return LedScheduleType.customWindow;
      case ReadLedScheduleType.sceneBased:
        return LedScheduleType.sceneBased;
    }
  }

  LedScheduleRecurrence _mapRecurrence(ReadLedScheduleRecurrence recurrence) {
    switch (recurrence) {
      case ReadLedScheduleRecurrence.everyDay:
        return LedScheduleRecurrence.everyday;
      case ReadLedScheduleRecurrence.weekdays:
        return LedScheduleRecurrence.weekdays;
      case ReadLedScheduleRecurrence.weekends:
        return LedScheduleRecurrence.weekends;
    }
  }

  TimeOfDay _minutesToTime(int minutes) {
    final normalized = minutes.clamp(0, 23 * 60 + 59);
    final hour = normalized ~/ 60;
    final minute = normalized % 60;
    return TimeOfDay(hour: hour, minute: minute);
  }
}
