import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../application/common/app_error.dart';
import '../../../../application/common/app_error_code.dart';
import '../../../../application/common/app_session.dart';
import '../../../../application/led/clear_led_records_usecase.dart';
import '../../../../application/led/delete_led_record_usecase.dart';
import '../../../../application/led/observe_led_record_state_usecase.dart';
import '../../../../application/led/read_led_record_state_usecase.dart';
import '../../../../application/led/refresh_led_record_state_usecase.dart';
import '../../../../application/led/start_led_preview_usecase.dart';
import '../../../../application/led/stop_led_preview_usecase.dart';
import '../../../../domain/led_lighting/led_record.dart';
import '../../../../domain/led_lighting/led_record_state.dart';

class LedRecordController extends ChangeNotifier {
  LedRecordController({
    required this.session,
    required this.observeLedRecordStateUseCase,
    required this.readLedRecordStateUseCase,
    required this.refreshLedRecordStateUseCase,
    required this.deleteLedRecordUseCase,
    required this.clearLedRecordsUseCase,
    required this.startLedPreviewUseCase,
    required this.stopLedPreviewUseCase,
  });

  final AppSession session;
  final ObserveLedRecordStateUseCase observeLedRecordStateUseCase;
  final ReadLedRecordStateUseCase readLedRecordStateUseCase;
  final RefreshLedRecordStateUseCase refreshLedRecordStateUseCase;
  final DeleteLedRecordUseCase deleteLedRecordUseCase;
  final ClearLedRecordsUseCase clearLedRecordsUseCase;
  final StartLedPreviewUseCase startLedPreviewUseCase;
  final StopLedPreviewUseCase stopLedPreviewUseCase;

  StreamSubscription<LedRecordState>? _subscription;
  LedRecordState? _state;
  bool _initialized = false;
  bool _isLoading = true;
  bool _isPerformingAction = false;
  AppErrorCode? _lastErrorCode;
  LedRecordEvent? _pendingEvent;
  String? _deviceId;
  String? _selectedRecordId;
  int? _selectedMinutes;

  bool get isLoading => _isLoading;
  bool get isBusy =>
      _isPerformingAction || _state?.status == LedRecordStatus.applying;
  bool get isPreviewing => _state?.status == LedRecordStatus.previewing;
  LedRecordStatus? get status => _state?.status;
  List<LedRecord> get records => _state?.records ?? const <LedRecord>[];
  AppErrorCode? get lastErrorCode => _lastErrorCode;
  String get selectedTimeLabel =>
      _formatMinutes(_selectedMinutes ?? _nowMinutes());
  bool get hasSelection => selectedRecord != null;
  LedRecord? get selectedRecord =>
      _recordMatching((record) => record.id == _selectedRecordId) ??
      _recordMatching(
        (record) => record.minutesFromMidnight == _selectedMinutes,
      );
  bool get canDeleteSelected => selectedRecord != null && !isBusy;
  bool get canNavigate => records.length >= 2 && !isBusy;
  bool get canPreview => records.isNotEmpty && !isBusy;
  bool get canClear => records.isNotEmpty && !isBusy;

  LedRecordEvent? consumeEvent() {
    final LedRecordEvent? event = _pendingEvent;
    _pendingEvent = null;
    return event;
  }

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    _initialized = true;
    _selectedMinutes ??= _nowMinutes();

    final String? deviceId = session.activeDeviceId;
    if (deviceId == null) {
      _lastErrorCode = AppErrorCode.noActiveDevice;
      _isLoading = false;
      notifyListeners();
      return;
    }
    _deviceId = deviceId;

    _subscription = observeLedRecordStateUseCase
        .execute(deviceId: deviceId)
        .listen(_handleState, onError: _handleStreamError);

    await _loadInitial(deviceId);
  }

  Future<void> refresh() async {
    if (_deviceId == null) {
      return;
    }
    await _runAction(() async {
      await refreshLedRecordStateUseCase.execute(deviceId: _deviceId!);
    });
  }

  Future<void> handleBackNavigation() async {
    await _stopPreviewIfNeeded();
  }

  Future<void> selectRecord(String recordId) async {
    await _stopPreviewIfNeeded();
    _selectedRecordId = recordId;
    _selectedMinutes = _recordMatching(
      (record) => record.id == recordId,
    )?.minutesFromMidnight;
    notifyListeners();
  }

  Future<void> goToNextRecord() async {
    if (records.isEmpty) {
      return;
    }
    await _stopPreviewIfNeeded();
    final List<LedRecord> ordered = _sortedRecords();
    final int target = _selectedMinutes ?? ordered.first.minutesFromMidnight;
    for (int i = 0; i < ordered.length; i++) {
      final LedRecord current = ordered[i];
      final int start = current.minutesFromMidnight;
      final int end = i == ordered.length - 1
          ? 1440
          : ordered[i + 1].minutesFromMidnight;
      if (target >= start && target < end) {
        final int nextMinutes = end == 1440 ? 0 : end;
        _updateSelectionByMinutes(nextMinutes);
        return;
      }
    }
    _updateSelectionByMinutes(ordered.first.minutesFromMidnight);
  }

  Future<void> goToPreviousRecord() async {
    if (records.isEmpty) {
      return;
    }
    await _stopPreviewIfNeeded();
    final List<LedRecord> ordered = _sortedRecords().reversed.toList(
      growable: false,
    );
    final int target = _selectedMinutes ?? ordered.first.minutesFromMidnight;

    if (target == 0) {
      _updateSelectionByMinutes(ordered.first.minutesFromMidnight);
      return;
    }

    for (int i = 0; i < ordered.length; i++) {
      final LedRecord current = ordered[i];
      final int upperBound = current.minutesFromMidnight;
      final int lowerBound = i == ordered.length - 1
          ? 0
          : ordered[i + 1].minutesFromMidnight;
      if (target >= lowerBound + 1 && target <= upperBound) {
        _updateSelectionByMinutes(lowerBound);
        return;
      }
    }
    _updateSelectionByMinutes(ordered.last.minutesFromMidnight);
  }

  Future<void> deleteSelectedRecord() async {
    final LedRecord? record = selectedRecord;
    if (record == null) {
      _emitEvent(const LedRecordEvent.missingSelection());
      return;
    }
    await _runAction(() async {
      try {
        await deleteLedRecordUseCase.execute(
          deviceId: _deviceId!,
          recordId: record.id,
        );
        _emitEvent(const LedRecordEvent.deleteSuccess());
      } on AppError catch (error) {
        _emitEvent(LedRecordEvent.deleteFailure(error.code));
      }
    });
  }

  Future<void> clearRecords() async {
    if (!canClear) {
      return;
    }
    await _runAction(() async {
      try {
        await clearLedRecordsUseCase.execute(deviceId: _deviceId!);
        _emitEvent(const LedRecordEvent.clearSuccess());
      } on AppError catch (error) {
        _emitEvent(LedRecordEvent.clearFailure(error.code));
      }
    });
  }

  Future<void> togglePreview() async {
    if (!canPreview && !isPreviewing) {
      return;
    }
    if (_deviceId == null) {
      return;
    }

    if (isPreviewing) {
      await _stopPreviewIfNeeded();
      return;
    }

    final LedRecord? record = selectedRecord ?? records.firstOrNull;
    if (record == null) {
      _emitEvent(const LedRecordEvent.missingSelection());
      return;
    }

    await _runAction(() async {
      try {
        await startLedPreviewUseCase.execute(
          deviceId: _deviceId!,
          recordId: record.id,
        );
        _emitEvent(const LedRecordEvent.previewStarted());
      } on AppError catch (error) {
        _emitEvent(LedRecordEvent.previewFailed(error.code));
      }
    });
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
    _subscription?.cancel();
    if (isPreviewing && _deviceId != null) {
      unawaited(stopLedPreviewUseCase.execute(deviceId: _deviceId!));
    }
    super.dispose();
  }

  Future<void> _loadInitial(String deviceId) async {
    try {
      final LedRecordState state = await readLedRecordStateUseCase.execute(
        deviceId: deviceId,
      );
      _handleState(state);
      _isLoading = false;
      _lastErrorCode = null;
    } on AppError catch (error) {
      _isLoading = false;
      _lastErrorCode = error.code;
    } catch (_) {
      _isLoading = false;
      _lastErrorCode = AppErrorCode.unknownError;
    } finally {
      notifyListeners();
    }
  }

  void _handleState(LedRecordState state) {
    _state = state;
    _lastErrorCode = null;
    if (state.previewingRecordId != null) {
      _selectedRecordId = state.previewingRecordId;
      _selectedMinutes = _recordMatching(
        (record) => record.id == state.previewingRecordId!,
      )?.minutesFromMidnight;
    }
    _selectedRecordId ??= state.records.isNotEmpty
        ? state.records.first.id
        : null;
    _selectedMinutes ??= _recordMatching(
      (record) => record.id == _selectedRecordId,
    )?.minutesFromMidnight;
    notifyListeners();
  }

  void _handleStreamError(Object error) {
    if (error is AppError) {
      _lastErrorCode = error.code;
    } else {
      _lastErrorCode = AppErrorCode.unknownError;
    }
    notifyListeners();
  }

  Future<void> _runAction(Future<void> Function() action) async {
    if (_deviceId == null) {
      return;
    }
    _isPerformingAction = true;
    notifyListeners();
    try {
      await action();
    } finally {
      _isPerformingAction = false;
      notifyListeners();
    }
  }

  Future<void> _stopPreviewIfNeeded() async {
    if (!isPreviewing || _deviceId == null) {
      return;
    }
    try {
      await stopLedPreviewUseCase.execute(deviceId: _deviceId!);
      _emitEvent(const LedRecordEvent.previewStopped());
    } on AppError catch (error) {
      _emitEvent(LedRecordEvent.previewFailed(error.code));
    }
  }

  LedRecord? _recordMatching(bool Function(LedRecord record) test) {
    for (final LedRecord record in records) {
      if (test(record)) {
        return record;
      }
    }
    return null;
  }

  List<LedRecord> _sortedRecords() {
    final List<LedRecord> ordered = List<LedRecord>.from(records);
    ordered.sort(
      (LedRecord a, LedRecord b) =>
          a.minutesFromMidnight.compareTo(b.minutesFromMidnight),
    );
    return ordered;
  }

  void _updateSelectionByMinutes(int minutes) {
    _selectedMinutes = minutes;
    _selectedRecordId = _recordMatching(
      (LedRecord record) => record.minutesFromMidnight == minutes,
    )?.id;
    notifyListeners();
  }

  void _emitEvent(LedRecordEvent event) {
    _pendingEvent = event;
    notifyListeners();
  }

  int _nowMinutes() {
    final DateTime now = DateTime.now();
    return now.hour * 60 + now.minute;
  }

  String _formatMinutes(int minutes) {
    final int safe = minutes.clamp(0, 1439);
    final int hour = safe ~/ 60;
    final int minute = safe % 60;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
}

class LedRecordEvent {
  const LedRecordEvent._(this.type, {this.errorCode});

  const LedRecordEvent.deleteSuccess()
    : this._(LedRecordEventType.deleteSuccess);
  const LedRecordEvent.deleteFailure(AppErrorCode? code)
    : this._(LedRecordEventType.deleteFailure, errorCode: code);
  const LedRecordEvent.clearSuccess() : this._(LedRecordEventType.clearSuccess);
  const LedRecordEvent.clearFailure(AppErrorCode? code)
    : this._(LedRecordEventType.clearFailure, errorCode: code);
  const LedRecordEvent.missingSelection()
    : this._(LedRecordEventType.missingSelection);
  const LedRecordEvent.previewStarted()
    : this._(LedRecordEventType.previewStarted);
  const LedRecordEvent.previewStopped()
    : this._(LedRecordEventType.previewStopped);
  const LedRecordEvent.previewFailed(AppErrorCode? code)
    : this._(LedRecordEventType.previewFailed, errorCode: code);

  final LedRecordEventType type;
  final AppErrorCode? errorCode;
}

enum LedRecordEventType {
  deleteSuccess,
  deleteFailure,
  clearSuccess,
  clearFailure,
  missingSelection,
  previewStarted,
  previewStopped,
  previewFailed,
}

extension FirstOrNullExtension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
