import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../app/common/app_error.dart';
import '../../../../app/common/app_error_code.dart';
import '../../../../app/common/app_session.dart';
import '../../../../domain/usecases/led/apply_led_schedule_usecase.dart';
import '../../../../domain/usecases/led/observe_led_state_usecase.dart';
import '../../../../domain/usecases/led/observe_led_record_state_usecase.dart';
import '../../../../domain/usecases/led/read_led_schedules.dart';
import '../../../../domain/usecases/led/read_led_record_state_usecase.dart';
import '../../../../domain/usecases/led/read_led_state_usecase.dart';
import '../../../../domain/usecases/led/stop_led_preview_usecase.dart';
import '../../../../domain/led_lighting/led_record_state.dart';
import '../../../../domain/led_lighting/led_channel.dart';
import '../../../../domain/led_lighting/led_channel_group.dart';
import '../../../../domain/led_lighting/led_channel_value.dart';
import '../../../../domain/led_lighting/led_custom_schedule.dart';
import '../../../../domain/led_lighting/led_daily_schedule.dart';
import '../../../../domain/led_lighting/led_record.dart';
import '../../../../domain/led_lighting/led_scene.dart';
import '../../../../domain/led_lighting/led_scene_schedule.dart';
import '../../../../domain/led_lighting/led_schedule.dart';
import '../../../../domain/led_lighting/led_schedule_type.dart';
import '../../../../domain/led_lighting/led_spectrum.dart';
import '../../../../domain/led_lighting/led_state.dart';
import '../../../../domain/led_lighting/time_of_day.dart' as domain;
import '../../../../domain/led_lighting/weekday.dart';
import '../../../../domain/led_lighting/led_intensity.dart';
import '../models/led_schedule_summary.dart' as ui_model;

class LedScheduleListController extends ChangeNotifier {
  LedScheduleListController({
    required this.session,
    required this.readLedScheduleUseCase,
    required this.applyLedScheduleUseCase,
    required this.observeLedStateUseCase,
    required this.readLedStateUseCase,
    required this.observeLedRecordStateUseCase,
    required this.readLedRecordStateUseCase,
    required this.stopLedPreviewUseCase,
  });

  final AppSession session;
  final ReadLedScheduleUseCase readLedScheduleUseCase;
  final ApplyLedScheduleUseCase applyLedScheduleUseCase;
  final ObserveLedStateUseCase observeLedStateUseCase;
  final ReadLedStateUseCase readLedStateUseCase;
  final ObserveLedRecordStateUseCase observeLedRecordStateUseCase;
  final ReadLedRecordStateUseCase readLedRecordStateUseCase;
  final StopLedPreviewUseCase stopLedPreviewUseCase;

  StreamSubscription<LedState>? _stateSubscription;
  StreamSubscription<LedRecordState>? _recordSubscription;
  List<ui_model.LedScheduleSummary> _schedules = const [];
  Map<String, ReadLedScheduleSnapshot> _snapshotIndex =
      const <String, ReadLedScheduleSnapshot>{};
  LedStatus? _ledStatus;
  String? _activeScheduleId;
  int? _previewMinutes;
  bool _initialized = false;
  bool _isLoading = true;
  bool _isPerformingAction = false;
  AppErrorCode? _lastErrorCode;
  LedScheduleEvent? _pendingEvent;

  List<ui_model.LedScheduleSummary> get schedules => _schedules;
  bool get isLoading => _isLoading;
  bool get isBusy => _isPerformingAction || _ledStatus == LedStatus.applying;
  bool get isWriteLocked => isBusy || _activeScheduleId != null;
  AppErrorCode? get lastErrorCode => _lastErrorCode;
  int? get previewMinutes => _previewMinutes;

  LedScheduleEvent? consumeEvent() {
    final LedScheduleEvent? event = _pendingEvent;
    _pendingEvent = null;
    return event;
  }

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    _initialized = true;
    await _bootstrapLedState();
    await _bootstrapRecordState();
    await refresh();
    _subscribeToLedState();
    _subscribeToRecordState();
  }

  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();

    final String? deviceId = session.activeDeviceId;
    if (deviceId == null) {
      _schedules = const [];
      _snapshotIndex = const <String, ReadLedScheduleSnapshot>{};
      _setError(AppErrorCode.noActiveDevice);
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final List<ReadLedScheduleSnapshot> snapshots =
          await readLedScheduleUseCase.execute(deviceId: deviceId);
      _snapshotIndex = <String, ReadLedScheduleSnapshot>{
        for (final ReadLedScheduleSnapshot snapshot in snapshots)
          snapshot.id: snapshot,
      };
      _schedules = snapshots.map(_mapSnapshot).toList(growable: false);
      _applyActiveScheduleFlag();
      _lastErrorCode = null;
    } on AppError catch (error) {
      _schedules = const [];
      _snapshotIndex = const <String, ReadLedScheduleSnapshot>{};
      _setError(error.code);
    } catch (_) {
      _schedules = const [];
      _snapshotIndex = const <String, ReadLedScheduleSnapshot>{};
      _setError(AppErrorCode.unknownError);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> applySchedule(String scheduleId) async {
    final String? deviceId = session.activeDeviceId;
    if (deviceId == null) {
      _setError(AppErrorCode.noActiveDevice);
      notifyListeners();
      return;
    }
    if (isBusy) {
      return;
    }

    final ReadLedScheduleSnapshot? snapshot = _snapshotIndex[scheduleId];
    if (snapshot == null) {
      _setEvent(const LedScheduleEvent.applyFailure(AppErrorCode.invalidParam));
      return;
    }
    final LedSchedule? schedule = _buildLedSchedule(snapshot);
    if (schedule == null) {
      _setEvent(const LedScheduleEvent.applyFailure(AppErrorCode.invalidParam));
      return;
    }

    await _stopPreview(deviceId);
    await _runAction(() async {
      try {
        await applyLedScheduleUseCase.execute(
          deviceId: deviceId,
          scheduleId: scheduleId,
          schedule: schedule,
        );
        _setEvent(const LedScheduleEvent.applySuccess());
      } on AppError catch (error) {
        _setError(error.code);
        _setEvent(LedScheduleEvent.applyFailure(error.code));
      } catch (_) {
        _setError(AppErrorCode.unknownError);
        _setEvent(
          const LedScheduleEvent.applyFailure(AppErrorCode.unknownError),
        );
      }
    });
  }

  Future<void> ensurePreviewStopped() async {
    final String? deviceId = session.activeDeviceId;
    if (deviceId == null) {
      return;
    }
    await _stopPreview(deviceId);
  }

  void clearError() {
    if (_lastErrorCode == null) {
      return;
    }
    _lastErrorCode = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _stateSubscription?.cancel();
    _recordSubscription?.cancel();
    super.dispose();
  }

  void _setError(AppErrorCode code) {
    _lastErrorCode = code;
  }

  void _setEvent(LedScheduleEvent event) {
    _pendingEvent = event;
    notifyListeners();
  }

  ui_model.LedScheduleSummary _mapSnapshot(ReadLedScheduleSnapshot snapshot) {
    return ui_model.LedScheduleSummary(
      id: snapshot.id,
      title: snapshot.title,
      type: _mapType(snapshot.type),
      recurrence: _mapRecurrence(snapshot.recurrence),
      startTime: _minutesToTime(snapshot.startMinutesFromMidnight),
      endTime: _minutesToTime(snapshot.endMinutesFromMidnight),
      sceneName: snapshot.sceneName,
      isEnabled: snapshot.isEnabled,
      isDerived: snapshot.isDerived,
      channels: snapshot.channels
          .map(
            (channel) => ui_model.LedScheduleChannelValue(
              id: channel.id,
              label: channel.label,
              percentage: channel.percentage,
            ),
          )
          .toList(growable: false),
      isActive: snapshot.id == _activeScheduleId,
    );
  }

  Future<void> _bootstrapLedState() async {
    final String? deviceId = session.activeDeviceId;
    if (deviceId == null) {
      return;
    }
    try {
      final LedState state = await readLedStateUseCase.execute(
        deviceId: deviceId,
      );
      _updateLedState(state);
    } on AppError catch (error) {
      _setError(error.code);
    } catch (_) {
      _setError(AppErrorCode.unknownError);
    }
  }

  void _subscribeToLedState() {
    final String? deviceId = session.activeDeviceId;
    if (deviceId == null) {
      return;
    }
    _stateSubscription?.cancel();
    _stateSubscription = observeLedStateUseCase
        .execute(deviceId: deviceId)
        .listen(_updateLedState, onError: _handleStateError);
  }

  Future<void> _bootstrapRecordState() async {
    final String? deviceId = session.activeDeviceId;
    if (deviceId == null) {
      return;
    }
    try {
      final LedRecordState state = await readLedRecordStateUseCase.execute(
        deviceId: deviceId,
      );
      _updateRecordState(state);
    } on AppError {
      // Ignore record errors during bootstrap; schedule list still functions.
    } catch (_) {
      // Swallow unexpected errors to keep UI responsive.
    }
  }

  void _subscribeToRecordState() {
    final String? deviceId = session.activeDeviceId;
    if (deviceId == null) {
      return;
    }
    _recordSubscription?.cancel();
    _recordSubscription = observeLedRecordStateUseCase
        .execute(deviceId: deviceId)
        .listen(_updateRecordState, onError: _handleRecordStateError);
  }

  void _updateLedState(LedState state) {
    _ledStatus = state.status;
    _activeScheduleId = state.activeScheduleId;
    _applyActiveScheduleFlag();
    notifyListeners();
  }

  void _updateRecordState(LedRecordState state) {
    _previewMinutes = _resolvePreviewMinutes(state);
    notifyListeners();
  }

  void _applyActiveScheduleFlag() {
    if (_schedules.isEmpty) {
      return;
    }
    _schedules = _schedules
        .map(
          (schedule) =>
              schedule.copyWith(isActive: schedule.id == _activeScheduleId),
        )
        .toList(growable: false);
  }

  void _handleStateError(Object error) {
    if (error is AppError) {
      _setError(error.code);
    } else {
      _setError(AppErrorCode.unknownError);
    }
    notifyListeners();
  }

  void _handleRecordStateError(Object error) {
    if (error is AppError) {
      _setError(error.code);
    } else {
      _setError(AppErrorCode.unknownError);
    }
    notifyListeners();
  }

  int? _resolvePreviewMinutes(LedRecordState state) {
    final String? previewId = state.previewingRecordId;
    if (previewId == null) {
      return null;
    }
    for (final LedRecord record in state.records) {
      if (record.id == previewId) {
        return record.minutesFromMidnight;
      }
    }
    return null;
  }

  ui_model.LedScheduleType _mapType(ReadLedScheduleType type) {
    switch (type) {
      case ReadLedScheduleType.dailyProgram:
        return ui_model.LedScheduleType.dailyProgram;
      case ReadLedScheduleType.customWindow:
        return ui_model.LedScheduleType.customWindow;
      case ReadLedScheduleType.sceneBased:
        return ui_model.LedScheduleType.sceneBased;
    }
  }

  ui_model.LedScheduleRecurrence _mapRecurrence(
    ReadLedScheduleRecurrence recurrence,
  ) {
    switch (recurrence) {
      case ReadLedScheduleRecurrence.everyDay:
        return ui_model.LedScheduleRecurrence.everyday;
      case ReadLedScheduleRecurrence.weekdays:
        return ui_model.LedScheduleRecurrence.weekdays;
      case ReadLedScheduleRecurrence.weekends:
        return ui_model.LedScheduleRecurrence.weekends;
    }
  }

  TimeOfDay _minutesToTime(int minutes) {
    final int normalized = minutes.clamp(0, 23 * 60 + 59);
    final int hour = normalized ~/ 60;
    final int minute = normalized % 60;
    return TimeOfDay(hour: hour, minute: minute);
  }

  LedSchedule? _buildLedSchedule(ReadLedScheduleSnapshot snapshot) {
    final List<LedChannelValue> channels = snapshot.channels
        .map(_mapChannelValue)
        .whereType<LedChannelValue>()
        .toList(growable: false);
    if (channels.isEmpty) {
      return null;
    }
    final LedChannelGroup group = LedChannelGroup.fullSpectrum;
    final LedSpectrum spectrum = LedSpectrum(
      channelGroup: group,
      channels: channels,
    );
    final List<Weekday> repeatOn = _recurrenceToWeekdays(snapshot.recurrence);
    final domain.TimeOfDay start = _toDomainTime(
      snapshot.startMinutesFromMidnight,
    );
    final domain.TimeOfDay end = _toDomainTime(snapshot.endMinutesFromMidnight);

    switch (snapshot.type) {
      case ReadLedScheduleType.dailyProgram:
        final LedDailySchedule dailySchedule = LedDailySchedule(
          channelGroup: group,
          points: <LedDailyPoint>[
            LedDailyPoint(time: start, spectrum: spectrum),
            LedDailyPoint(time: end, spectrum: spectrum),
          ],
          repeatOn: repeatOn,
        );
        return LedSchedule(type: LedScheduleType.daily, daily: dailySchedule);
      case ReadLedScheduleType.customWindow:
        final LedCustomSchedule customSchedule = LedCustomSchedule(
          channelGroup: group,
          start: start,
          end: end,
          spectrum: spectrum,
          repeatOn: repeatOn,
        );
        return LedSchedule(
          type: LedScheduleType.custom,
          custom: customSchedule,
        );
      case ReadLedScheduleType.sceneBased:
        final LedScene scene = LedScene(
          presetId: 0,
          sceneId: snapshot.id,
          name: snapshot.sceneName,
          spectrum: spectrum,
          channelGroup: group,
        );
        final LedSceneSchedule sceneSchedule = LedSceneSchedule(
          scene: scene,
          start: start,
          end: end,
          repeatOn: repeatOn,
        );
        return LedSchedule(type: LedScheduleType.scene, scene: sceneSchedule);
    }
  }

  LedChannelValue? _mapChannelValue(ReadLedScheduleChannelSnapshot snapshot) {
    final LedChannel? channel = _channelForId(snapshot.id, snapshot.label);
    if (channel == null) {
      return null;
    }
    final LedIntensity intensity = _percentToIntensity(snapshot.percentage);
    return LedChannelValue(channel: channel, intensity: intensity);
  }

  LedChannel? _channelForId(String id, String label) {
    final String normalized = id.toLowerCase();
    if (normalized.contains('red')) {
      return LedChannel.red;
    }
    if (normalized.contains('green')) {
      return LedChannel.green;
    }
    if (normalized.contains('blue')) {
      return LedChannel.blue;
    }
    if (normalized.contains('white')) {
      return LedChannel.white;
    }
    if (normalized.contains('uv') || normalized.contains('violet')) {
      return LedChannel.uv;
    }

    final String labelNormalized = label.toLowerCase();
    if (labelNormalized.contains('red')) {
      return LedChannel.red;
    }
    if (labelNormalized.contains('green')) {
      return LedChannel.green;
    }
    if (labelNormalized.contains('blue')) {
      return LedChannel.blue;
    }
    if (labelNormalized.contains('white')) {
      return LedChannel.white;
    }
    if (labelNormalized.contains('uv') || labelNormalized.contains('violet')) {
      return LedChannel.uv;
    }
    return null;
  }

  LedIntensity _percentToIntensity(int percentage) {
    final int clamped = percentage.clamp(0, 100);
    final int value = (clamped * 255 / 100).round();
    return LedIntensity(value);
  }

  domain.TimeOfDay _toDomainTime(int minutes) {
    final int normalized = minutes.clamp(0, 23 * 60 + 59);
    final int hour = normalized ~/ 60;
    final int minute = normalized % 60;
    return domain.TimeOfDay(hour: hour, minute: minute);
  }

  List<Weekday> _recurrenceToWeekdays(ReadLedScheduleRecurrence recurrence) {
    switch (recurrence) {
      case ReadLedScheduleRecurrence.everyDay:
        return const <Weekday>[
          Weekday.mon,
          Weekday.tue,
          Weekday.wed,
          Weekday.thu,
          Weekday.fri,
          Weekday.sat,
          Weekday.sun,
        ];
      case ReadLedScheduleRecurrence.weekdays:
        return const <Weekday>[
          Weekday.mon,
          Weekday.tue,
          Weekday.wed,
          Weekday.thu,
          Weekday.fri,
        ];
      case ReadLedScheduleRecurrence.weekends:
        return const <Weekday>[Weekday.sat, Weekday.sun];
    }
  }

  Future<void> _runAction(Future<void> Function() action) async {
    _isPerformingAction = true;
    notifyListeners();
    try {
      await action();
    } finally {
      _isPerformingAction = false;
      notifyListeners();
    }
  }

  Future<void> _stopPreview(String deviceId) async {
    try {
      await stopLedPreviewUseCase.execute(deviceId: deviceId);
    } on AppError {
      // Ignore best-effort guard errors.
    }
  }
}

class LedScheduleEvent {
  const LedScheduleEvent._(this.type, {this.errorCode});

  const LedScheduleEvent.applySuccess()
    : this._(LedScheduleEventType.applySuccess);
  const LedScheduleEvent.applyFailure(AppErrorCode? code)
    : this._(LedScheduleEventType.applyFailure, errorCode: code);

  final LedScheduleEventType type;
  final AppErrorCode? errorCode;
}

enum LedScheduleEventType { applySuccess, applyFailure }
