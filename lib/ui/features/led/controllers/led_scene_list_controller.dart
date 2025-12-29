import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../application/common/app_error.dart';
import '../../../../application/common/app_error_code.dart';
import '../../../../application/common/app_session.dart';
import '../../../../application/led/apply_scene_usecase.dart';
import '../../../../application/led/observe_led_record_state_usecase.dart';
import '../../../../application/led/observe_led_state_usecase.dart';
import '../../../../application/led/read_led_record_state_usecase.dart';
import '../../../../application/led/read_led_scenes.dart';
import '../../../../application/led/read_led_state_usecase.dart';
import '../../../../application/led/start_led_preview_usecase.dart';
import '../../../../application/led/start_led_record_usecase.dart';
import '../../../../application/led/stop_led_preview_usecase.dart';
import '../../../../domain/led_lighting/led_record.dart';
import '../../../../domain/led_lighting/led_record_state.dart';
import '../../../../domain/led_lighting/led_state.dart';
import '../../../../infrastructure/repositories/favorite_repository_impl.dart';
import '../models/led_scene_summary.dart';

class LedSceneListController extends ChangeNotifier {
  LedSceneListController({
    required this.session,
    required this.readLedScenesUseCase,
    required this.applySceneUseCase,
    required this.observeLedStateUseCase,
    required this.readLedStateUseCase,
    required this.stopLedPreviewUseCase,
    required this.observeLedRecordStateUseCase,
    required this.readLedRecordStateUseCase,
    required this.startLedPreviewUseCase,
    required this.startLedRecordUseCase,
  });

  final AppSession session;
  final ReadLedScenesUseCase readLedScenesUseCase;
  final ApplySceneUseCase applySceneUseCase;
  final ObserveLedStateUseCase observeLedStateUseCase;
  final ReadLedStateUseCase readLedStateUseCase;
  final StopLedPreviewUseCase stopLedPreviewUseCase;
  final ObserveLedRecordStateUseCase observeLedRecordStateUseCase;
  final ReadLedRecordStateUseCase readLedRecordStateUseCase;
  final StartLedPreviewUseCase startLedPreviewUseCase;
  final StartLedRecordUseCase startLedRecordUseCase;
  final FavoriteRepositoryImpl _favoriteRepository = FavoriteRepositoryImpl();

  StreamSubscription<LedState>? _stateSubscription;
  StreamSubscription<LedRecordState>? _recordSubscription;
  List<LedSceneSummary> _scenes = const [];
  LedStatus? _ledStatus;
  String? _activeSceneId;
  String? _activeScheduleId;
  List<LedStateSchedule> _schedules = const [];
  Map<String, int> _currentChannelLevels = const <String, int>{};
  List<LedRecord> _records = const <LedRecord>[];
  bool _isRecordPreviewing = false;
  bool _initialized = false;
  bool _isLoading = true;
  bool _isPerformingAction = false;
  AppErrorCode? _lastErrorCode;
  LedSceneEvent? _pendingEvent;

  List<LedSceneSummary> get scenes => _scenes;
  List<LedSceneSummary> get dynamicScenes =>
      _scenes.where((scene) => scene.isDynamic).toList(growable: false);
  List<LedSceneSummary> get staticScenes =>
      _scenes.where((scene) => !scene.isDynamic).toList(growable: false);
  bool get isLoading => _isLoading;
  bool get isBusy => _isPerformingAction || _ledStatus == LedStatus.applying;
  bool get isPreviewing => _activeSceneId != null || _isRecordPreviewing;
  bool get isWriteLocked => isBusy || isPreviewing;
  AppErrorCode? get lastErrorCode => _lastErrorCode;
  Map<String, int> get currentChannelLevels => _currentChannelLevels;
  LedStatus get ledStatus => _ledStatus ?? LedStatus.idle;
  String? get activeSceneId => _activeSceneId;
  String? get activeScheduleId => _activeScheduleId;
  List<LedStateSchedule> get schedules => _schedules;
  List<LedRecord> get records => _records;
  bool get hasRecords => _records.isNotEmpty;

  LedStateSchedule? get activeSchedule {
    if (_activeScheduleId == null) {
      return null;
    }
    for (final schedule in _schedules) {
      if (schedule.scheduleId == _activeScheduleId) {
        return schedule;
      }
    }
    return null;
  }

  LedSceneEvent? consumeEvent() {
    final LedSceneEvent? event = _pendingEvent;
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

  /// Refresh all data (LED state, record state, and scenes).
  ///
  /// PARITY: Matches reef-b-app's onResume() behavior:
  /// - getAllLedInfo() → _bootstrapLedState()
  /// - getNowRecords() → _bootstrapRecordState()
  /// - getAllFavoriteScene() → refresh() (includes favorite scenes)
  Future<void> refreshAll() async {
    await _bootstrapLedState();
    await _bootstrapRecordState();
    await refresh();
  }

  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();

    final String? deviceId = session.activeDeviceId;
    if (deviceId == null) {
      _scenes = const [];
      _setError(AppErrorCode.noActiveDevice);
      _currentChannelLevels = const <String, int>{};
      _schedules = const [];
      _activeScheduleId = null;
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final List<ReadLedSceneSnapshot> snapshots = await readLedScenesUseCase
          .execute(deviceId: deviceId);
      final Set<String> favoriteSceneIds = await _favoriteRepository.getFavoriteScenes(deviceId);
      _scenes = snapshots.map((snapshot) => _mapSnapshot(snapshot, favoriteSceneIds)).toList(growable: false);
      _applyActiveSceneFlag();
      _lastErrorCode = null;
    } on AppError catch (error) {
      _scenes = const [];
      _currentChannelLevels = const <String, int>{};
      _schedules = const [];
      _activeScheduleId = null;
      _setError(error.code);
    } catch (_) {
      _scenes = const [];
      _currentChannelLevels = const <String, int>{};
      _schedules = const [];
      _activeScheduleId = null;
      _setError(AppErrorCode.unknownError);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> applyScene(String sceneId) async {
    final String? deviceId = session.activeDeviceId;
    if (deviceId == null) {
      _setError(AppErrorCode.noActiveDevice);
      notifyListeners();
      return;
    }
    if (isBusy) {
      return;
    }

    await _stopPreview(deviceId);
    await _runAction(() async {
      try {
        await applySceneUseCase.execute(deviceId: deviceId, sceneId: sceneId);
        _setEvent(const LedSceneEvent.applySuccess());
      } on AppError catch (error) {
        _setError(error.code);
        _setEvent(LedSceneEvent.applyFailure(error.code));
      } catch (_) {
        _setError(AppErrorCode.unknownError);
        _setEvent(const LedSceneEvent.applyFailure(AppErrorCode.unknownError));
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

  Future<void> startRecord() async {
    final String? deviceId = session.activeDeviceId;
    if (deviceId == null) {
      _setError(AppErrorCode.noActiveDevice);
      notifyListeners();
      return;
    }
    if (isBusy || isPreviewing) {
      return;
    }

    await _stopPreview(deviceId);
    await _runAction(() async {
      try {
        await startLedRecordUseCase.execute(deviceId: deviceId);
      } on AppError catch (error) {
        _setError(error.code);
      } catch (_) {
        _setError(AppErrorCode.unknownError);
      }
    });
  }

  Future<void> togglePreview() async {
    final String? deviceId = session.activeDeviceId;
    if (deviceId == null) {
      _setError(AppErrorCode.noActiveDevice);
      notifyListeners();
      return;
    }
    if (isBusy) {
      return;
    }

    if (_isRecordPreviewing) {
      await _stopPreview(deviceId);
      return;
    }

    // Start preview from first record if available
    if (_records.isEmpty) {
      return;
    }

    await _runAction(() async {
      try {
        await startLedPreviewUseCase.execute(
          deviceId: deviceId,
          recordId: _records.first.id,
        );
      } on AppError catch (error) {
        _setError(error.code);
      } catch (_) {
        _setError(AppErrorCode.unknownError);
      }
    });
  }

  @override
  void dispose() {
    // PARITY: reef-b-app onStop() - stop preview if active
    // Stop preview when controller is disposed (e.g., when leaving the page)
    if (isPreviewing) {
      final String? deviceId = session.activeDeviceId;
      if (deviceId != null) {
        // Use unawaited to avoid blocking dispose, but ensure preview is stopped
        unawaited(_stopPreview(deviceId));
      }
    }
    
    _stateSubscription?.cancel();
    _recordSubscription?.cancel();
    super.dispose();
  }

  void _setError(AppErrorCode code) {
    _lastErrorCode = code;
  }

  void _setEvent(LedSceneEvent event) {
    _pendingEvent = event;
    notifyListeners();
  }

  LedSceneSummary _mapSnapshot(ReadLedSceneSnapshot snapshot, Set<String> favoriteSceneIds) {
    return LedSceneSummary(
      id: snapshot.id,
      name: snapshot.name,
      description: snapshot.description,
      palette: snapshot.palette
          .map((colorValue) => Color(colorValue))
          .toList(growable: false),
      isEnabled: snapshot.isEnabled,
      isActive: snapshot.id == _activeSceneId,
      isPreset: snapshot.isPreset,
      isDynamic: snapshot.isDynamic,
      iconKey: snapshot.iconKey,
      presetCode: snapshot.presetCode,
      channelLevels: snapshot.channelLevels,
      isFavorite: favoriteSceneIds.contains(snapshot.id),
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

  void _updateLedState(LedState state) {
    _ledStatus = state.status;
    _activeSceneId = state.activeSceneId;
    _activeScheduleId = state.activeScheduleId;
    _schedules = state.schedules;
    _currentChannelLevels = state.channelLevels;
    _applyActiveSceneFlag();
    notifyListeners();
  }

  void _applyActiveSceneFlag() {
    if (_scenes.isEmpty) {
      return;
    }
    _scenes = _scenes
        .map((scene) => scene.copyWith(isActive: scene.id == _activeSceneId))
        .toList(growable: false);
  }

  Future<void> toggleFavoriteScene(String sceneId) async {
    final String? deviceId = session.activeDeviceId;
    if (deviceId == null) {
      return;
    }

    await _favoriteRepository.toggleFavoriteScene(
      deviceId: deviceId,
      sceneId: sceneId,
    );

    // Refresh scenes to update favorite status
    await refresh();
  }

  void _handleStateError(Object error) {
    if (error is AppError) {
      _setError(error.code);
    } else {
      _setError(AppErrorCode.unknownError);
    }
    notifyListeners();
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
      // Ignore record errors during bootstrap
    } catch (_) {
      // Swallow unexpected errors
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

  void _updateRecordState(LedRecordState state) {
    _records = state.records;
    _isRecordPreviewing = state.status == LedRecordStatus.previewing;
    notifyListeners();
  }

  void _handleRecordStateError(Object error) {
    // Ignore record state errors in main page
  }

  /// Stop preview if active.
  ///
  /// PARITY: Matches reef-b-app's bleStopPreview() behavior.
  /// This method is called before performing actions that require stopping preview.
  Future<void> stopPreview() async {
    final String? deviceId = session.activeDeviceId;
    if (deviceId == null) {
      return;
    }
    await _stopPreview(deviceId);
  }

  Future<void> _stopPreview(String deviceId) async {
    try {
      if (_isRecordPreviewing) {
        await stopLedPreviewUseCase.execute(deviceId: deviceId);
      }
    } on AppError {
      // Best-effort guard; ignore errors so scene apply can still surface them.
    }
  }
}

class LedSceneEvent {
  const LedSceneEvent._(this.type, {this.errorCode});

  const LedSceneEvent.applySuccess() : this._(LedSceneEventType.applySuccess);
  const LedSceneEvent.applyFailure(AppErrorCode? code)
    : this._(LedSceneEventType.applyFailure, errorCode: code);

  final LedSceneEventType type;
  final AppErrorCode? errorCode;
}

enum LedSceneEventType { applySuccess, applyFailure }
