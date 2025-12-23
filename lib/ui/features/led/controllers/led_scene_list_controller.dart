import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../application/common/app_error.dart';
import '../../../../application/common/app_error_code.dart';
import '../../../../application/common/app_session.dart';
import '../../../../application/led/apply_scene_usecase.dart';
import '../../../../application/led/observe_led_state_usecase.dart';
import '../../../../application/led/read_led_scenes.dart';
import '../../../../application/led/read_led_state_usecase.dart';
import '../../../../application/led/stop_led_preview_usecase.dart';
import '../../../../domain/led_lighting/led_state.dart';
import '../models/led_scene_summary.dart';

class LedSceneListController extends ChangeNotifier {
  LedSceneListController({
    required this.session,
    required this.readLedScenesUseCase,
    required this.applySceneUseCase,
    required this.observeLedStateUseCase,
    required this.readLedStateUseCase,
    required this.stopLedPreviewUseCase,
  });

  final AppSession session;
  final ReadLedScenesUseCase readLedScenesUseCase;
  final ApplySceneUseCase applySceneUseCase;
  final ObserveLedStateUseCase observeLedStateUseCase;
  final ReadLedStateUseCase readLedStateUseCase;
  final StopLedPreviewUseCase stopLedPreviewUseCase;

  StreamSubscription<LedState>? _stateSubscription;
  List<LedSceneSummary> _scenes = const [];
  LedStatus? _ledStatus;
  String? _activeSceneId;
  Map<String, int> _currentChannelLevels = const <String, int>{};
  bool _initialized = false;
  bool _isLoading = true;
  bool _isPerformingAction = false;
  AppErrorCode? _lastErrorCode;
  LedSceneEvent? _pendingEvent;

  List<LedSceneSummary> get scenes => _scenes;
  bool get isLoading => _isLoading;
  bool get isBusy => _isPerformingAction || _ledStatus == LedStatus.applying;
  AppErrorCode? get lastErrorCode => _lastErrorCode;
  Map<String, int> get currentChannelLevels => _currentChannelLevels;

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
    await refresh();
    _subscribeToLedState();
  }

  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();

    final String? deviceId = session.activeDeviceId;
    if (deviceId == null) {
      _scenes = const [];
      _setError(AppErrorCode.noActiveDevice);
      _currentChannelLevels = const <String, int>{};
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final List<ReadLedSceneSnapshot> snapshots = await readLedScenesUseCase
          .execute(deviceId: deviceId);
      _scenes = snapshots.map(_mapSnapshot).toList(growable: false);
      _applyActiveSceneFlag();
      _lastErrorCode = null;
    } on AppError catch (error) {
      _scenes = const [];
      _currentChannelLevels = const <String, int>{};
      _setError(error.code);
    } catch (_) {
      _scenes = const [];
      _currentChannelLevels = const <String, int>{};
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
        _setEvent(LedSceneEvent.applyFailure(error.code));
      } catch (_) {
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

  @override
  void dispose() {
    _stateSubscription?.cancel();
    super.dispose();
  }

  void _setError(AppErrorCode code) {
    _lastErrorCode = code;
  }

  void _setEvent(LedSceneEvent event) {
    _pendingEvent = event;
    notifyListeners();
  }

  LedSceneSummary _mapSnapshot(ReadLedSceneSnapshot snapshot) {
    return LedSceneSummary(
      id: snapshot.id,
      name: snapshot.name,
      description: snapshot.description,
      palette: snapshot.palette
          .map((colorValue) => Color(colorValue))
          .toList(growable: false),
      isEnabled: snapshot.isEnabled,
      isActive: snapshot.id == _activeSceneId,
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

  Future<void> _stopPreview(String deviceId) async {
    try {
      await stopLedPreviewUseCase.execute(deviceId: deviceId);
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
