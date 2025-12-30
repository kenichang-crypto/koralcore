library;

import '../../../data/repositories/scene_repository_impl.dart';
import '../../../platform/contracts/led_repository.dart';
import '../../../app/common/app_error.dart';
import '../../../app/common/app_error_code.dart';

/// AddSceneUseCase
///
/// PARITY: Corresponds to reef-b-app's scene addition behavior:
/// - LedSceneAddActivity: adds custom scene via SceneDao.insertScene()
/// - Validates scene name, icon, and channel levels
/// - Maximum 5 custom scenes per device (enforced in database)
/// - On success: returns scene ID, refreshes scene list, navigates back
/// - Scene is stored in database and associated with deviceId
class AddSceneUseCase {
  final LedRepository ledRepository;
  final SceneRepositoryImpl sceneRepository;

  const AddSceneUseCase({
    required this.ledRepository,
    required this.sceneRepository,
  });

  Future<int> execute({
    required String deviceId,
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

    // Check scene count limit (reef-b-app allows max 5 custom scenes)
    final int currentCount = await sceneRepository.getSceneCount(deviceId);
    if (currentCount >= 5) {
      throw const AppError(
        code: AppErrorCode.invalidParam,
        message: 'Maximum number of scenes (5) reached',
      );
    }

    return await sceneRepository.addScene(
      deviceId: deviceId,
      name: name.trim(),
      iconId: iconId,
      channelLevels: channelLevels,
    );
  }
}

