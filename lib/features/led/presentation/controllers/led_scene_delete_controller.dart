import 'package:flutter/material.dart';

import '../../../../app/common/app_session.dart';
import '../../../../domain/usecases/led/clear_led_scene_usecase.dart';
import '../../../../domain/usecases/led/delete_scene_usecase.dart';

class LedSceneDeleteController extends ChangeNotifier {
  LedSceneDeleteController({
    required this.session,
    required this.deleteSceneUseCase,
    required this.clearLedSceneUseCase,
  });

  final AppSession session;
  final DeleteSceneUseCase deleteSceneUseCase;
  final ClearLedSceneUseCase clearLedSceneUseCase;

  bool _isDeleting = false;
  bool get isDeleting => _isDeleting;

  Future<void> deleteScene(int sceneId) async {
    final String? deviceId = session.activeDeviceId;
    if (deviceId == null) {
      throw StateError('No active device.');
    }

    if (_isDeleting) return;
    _isDeleting = true;
    notifyListeners();

    try {
      await deleteSceneUseCase.execute(
        deviceId: deviceId,
        sceneId: sceneId,
      );
      await clearLedSceneUseCase.execute(deviceId);
    } finally {
      _isDeleting = false;
      notifyListeners();
    }
  }
}
