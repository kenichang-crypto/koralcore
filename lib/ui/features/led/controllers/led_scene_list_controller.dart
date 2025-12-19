import 'package:flutter/material.dart';

import '../../../../application/common/app_session.dart';
import '../../../../application/common/app_error.dart';
import '../../../../application/common/app_error_code.dart';
import '../../../../application/led/read_led_scenes.dart';
import '../models/led_scene_summary.dart';

class LedSceneListController extends ChangeNotifier {
  final AppSession session;
  final ReadLedScenesUseCase readLedScenesUseCase;

  List<LedSceneSummary> _scenes = const [];
  bool _isLoading = true;
  AppErrorCode? _lastErrorCode;

  LedSceneListController({
    required this.session,
    required this.readLedScenesUseCase,
  });

  List<LedSceneSummary> get scenes => _scenes;
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
      _scenes = const [];
      _setError(AppErrorCode.noDeviceSelected);
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final snapshots = await readLedScenesUseCase.execute(deviceId: deviceId);
      _scenes = snapshots.map(_mapSnapshot).toList(growable: false);
      _lastErrorCode = null;
    } on AppError catch (error) {
      _scenes = const [];
      _setError(error.code);
    } catch (_) {
      _scenes = const [];
      _setError(AppErrorCode.unknownError);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _setError(AppErrorCode code) {
    _lastErrorCode = code;
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
    );
  }
}
