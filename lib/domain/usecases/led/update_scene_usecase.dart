library;

import '../../../data/repositories/scene_repository_impl.dart';
import '../../../platform/contracts/led_repository.dart';
import '../../../app/common/app_error.dart';
import '../../../app/common/app_error_code.dart';

/// UpdateSceneUseCase
///
/// PARITY: Corresponds to reef-b-app's scene update behavior:
/// - LedSceneEditActivity: updates custom scene via SceneDao.updateScene()
/// - Validates scene name, icon, and channel levels
/// - Updates scene in database and refreshes scene list
/// - On success: navigates back to scene list, shows updated scene
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

