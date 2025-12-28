import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../application/common/app_error.dart';
import '../../../../application/common/app_error_code.dart';
import '../../../../application/common/app_session.dart';
import '../../../../application/led/add_scene_usecase.dart';
import '../../../../application/led/enter_dimming_mode_usecase.dart';
import '../../../../application/led/exit_dimming_mode_usecase.dart';
import '../../../../application/led/set_channel_intensity.dart';
import '../../../../application/led/update_scene_usecase.dart';
import '../../../../infrastructure/repositories/scene_repository_impl.dart';
import '../../../../application/led/apply_scene_usecase.dart';

class LedSceneEditController extends ChangeNotifier {
  LedSceneEditController({
    required this.session,
    required this.addSceneUseCase,
    required this.updateSceneUseCase,
    required this.enterDimmingModeUseCase,
    required this.exitDimmingModeUseCase,
    required this.setChannelIntensityUseCase,
    this.applySceneUseCase,
    this.initialSceneId,
    this.initialName,
    this.initialChannelLevels,
    this.initialIconId = 5, // Default icon: ic_none
  }) {
    _name = initialName ?? '';
    _channelLevels = Map<String, int>.from(
      initialChannelLevels ??
          const {
            'coldWhite': 0,
            'royalBlue': 0,
            'blue': 0,
            'red': 0,
            'green': 0,
            'purple': 0,
            'uv': 0,
            'warmWhite': 0,
            'moonLight': 0,
          },
    );
    _iconId = initialIconId;
    _isEditMode = initialSceneId != null;
    _loadSceneCount();
  }

  Future<void> _loadSceneCount() async {
    final String? deviceId = session.activeDeviceId;
    if (deviceId == null) {
      return;
    }

    _isLoadingSceneCount = true;
    notifyListeners();

    try {
      final sceneRepository = SceneRepositoryImpl();
      _sceneCount = await sceneRepository.getSceneCount(deviceId);
    } catch (_) {
      // Ignore errors
    } finally {
      _isLoadingSceneCount = false;
      notifyListeners();
    }
  }

  Future<void> previewScene() async {
    if (!_isDimmingMode || _isLoading) {
      return;
    }

    // Preview is already active via dimming mode - channels are applied in real-time
    // This method can be used for future enhancements (e.g., save preview state)
  }

  final AppSession session;
  final AddSceneUseCase addSceneUseCase;
  final UpdateSceneUseCase updateSceneUseCase;
  final EnterDimmingModeUseCase enterDimmingModeUseCase;
  final ExitDimmingModeUseCase exitDimmingModeUseCase;
  final SetChannelIntensityUseCase setChannelIntensityUseCase;
  final ApplySceneUseCase? applySceneUseCase; // Optional, for preview
  final int? initialSceneId;
  final String? initialName;
  final Map<String, int>? initialChannelLevels;
  final int initialIconId;

  String _name = '';
  Map<String, int> _channelLevels = const {};
  int _iconId = 5;
  bool _isEditMode = false;
  bool _isLoading = false;
  bool _isDimmingMode = false;
  AppErrorCode? _lastErrorCode;
  int? _sceneCount;
  bool _isLoadingSceneCount = false;

  String get name => _name;
  Map<String, int> get channelLevels => Map<String, int>.unmodifiable(_channelLevels);
  int get iconId => _iconId;
  bool get isEditMode => _isEditMode;
  bool get isLoading => _isLoading;
  bool get isDimmingMode => _isDimmingMode;
  AppErrorCode? get lastErrorCode => _lastErrorCode;
  int? get sceneCount => _sceneCount;
  bool get isLoadingSceneCount => _isLoadingSceneCount;
  bool get isSceneLimitReached => _sceneCount != null && _sceneCount! >= 5;

  void setName(String value) {
    _name = value;
    notifyListeners();
  }

  void setIconId(int value) {
    _iconId = value;
    notifyListeners();
  }

  void setChannelLevel(String channel, int value) {
    _channelLevels = Map<String, int>.from(_channelLevels)
      ..[channel] = value.clamp(0, 100);
    notifyListeners();
    
    // Send dimming command if in dimming mode
    if (_isDimmingMode) {
      _sendDimmingCommand();
    }
  }

  int getChannelLevel(String channel) {
    return _channelLevels[channel] ?? 0;
  }

  Future<void> enterDimmingMode() async {
    if (_isDimmingMode || _isLoading) {
      return;
    }

    final String? deviceId = session.activeDeviceId;
    if (deviceId == null) {
      _setError(AppErrorCode.noActiveDevice);
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      await enterDimmingModeUseCase.execute(deviceId: deviceId);
      _isDimmingMode = true;
      _lastErrorCode = null;
    } on AppError catch (error) {
      _setError(error.code);
    } catch (_) {
      _setError(AppErrorCode.unknownError);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> exitDimmingMode() async {
    if (!_isDimmingMode || _isLoading) {
      return;
    }

    final String? deviceId = session.activeDeviceId;
    if (deviceId == null) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      await exitDimmingModeUseCase.execute(deviceId: deviceId);
      _isDimmingMode = false;
      _lastErrorCode = null;
    } on AppError catch (error) {
      _setError(error.code);
    } catch (_) {
      _setError(AppErrorCode.unknownError);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveScene() async {
    if (_name.trim().isEmpty) {
      _setError(AppErrorCode.invalidParam);
      return false;
    }

    final String? deviceId = session.activeDeviceId;
    if (deviceId == null) {
      _setError(AppErrorCode.noActiveDevice);
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      if (_isEditMode && initialSceneId != null) {
        await updateSceneUseCase.execute(
          deviceId: deviceId,
          sceneId: initialSceneId!,
          name: _name.trim(),
          iconId: _iconId,
          channelLevels: _channelLevels,
        );
      } else {
        await addSceneUseCase.execute(
          deviceId: deviceId,
          name: _name.trim(),
          iconId: _iconId,
          channelLevels: _channelLevels,
        );
      }
      _lastErrorCode = null;
      return true;
    } on AppError catch (error) {
      _setError(error.code);
      return false;
    } catch (_) {
      _setError(AppErrorCode.unknownError);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _sendDimmingCommand() {
    final String? deviceId = session.activeDeviceId;
    if (deviceId == null) {
      return;
    }

    // Fire and forget - don't wait for ACK
    setChannelIntensityUseCase
        .execute(deviceId: deviceId, channelLevels: _channelLevels)
        .catchError((_) {
      // Ignore errors for real-time dimming
    });
  }

  void _setError(AppErrorCode code) {
    _lastErrorCode = code;
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

