library;

import '../../data/repositories/scene_repository_impl.dart';
import '../../platform/contracts/led_repository.dart';
import '../common/app_error.dart';
import '../common/app_error_code.dart';

class UpdateSceneUseCase {
  final LedRepository ledRepository;
  final SceneRepositoryImpl sceneRepository;

  const UpdateSceneUseCase({
    required this.ledRepository,
    required this.sceneRepository,
  });

  Future<void> execute({
    required String deviceId,
    required int sceneId,
    required String name,
    required int iconId,
    required Map<String, int> channelLevels,
  }) async {
    if (name.trim().isEmpty) {
      throw const AppError(
        code: AppErrorCode.invalidParam,
        message: 'Scene name must not be empty',
      );
    }

    await sceneRepository.updateScene(
      deviceId: deviceId,
      sceneId: sceneId,
      name: name.trim(),
      iconId: iconId,
      channelLevels: channelLevels,
    );
  }
}

