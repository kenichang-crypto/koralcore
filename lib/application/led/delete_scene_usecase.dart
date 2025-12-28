library;

import '../../infrastructure/repositories/scene_repository_impl.dart';
import '../../platform/contracts/led_repository.dart';
import '../common/app_error.dart';
import '../common/app_error_code.dart';

class DeleteSceneUseCase {
  final LedRepository ledRepository;
  final SceneRepositoryImpl sceneRepository;

  const DeleteSceneUseCase({
    required this.ledRepository,
    required this.sceneRepository,
  });

  Future<void> execute({
    required String deviceId,
    required int sceneId,
  }) async {
    await sceneRepository.deleteScene(
      deviceId: deviceId,
      sceneId: sceneId,
    );
  }
}

