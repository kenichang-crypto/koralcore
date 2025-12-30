library;

import '../../../data/repositories/scene_repository_impl.dart';
import '../../../platform/contracts/led_repository.dart';

/// DeleteSceneUseCase
///
/// PARITY: Corresponds to reef-b-app's scene deletion behavior:
/// - LedSceneDeleteActivity: deletes custom scene via SceneDao.deleteScene()
/// - Shows confirmation dialog before deletion
/// - On confirm: deletes scene from database, refreshes scene list
/// - Only custom scenes can be deleted (preset scenes are read-only)
class DeleteSceneUseCase {
  final LedRepository ledRepository;
  final SceneRepositoryImpl sceneRepository;

  const DeleteSceneUseCase({
    required this.ledRepository,
    required this.sceneRepository,
  });

  Future<void> execute({required String deviceId, required int sceneId}) async {
    await sceneRepository.deleteScene(deviceId: deviceId, sceneId: sceneId);
  }
}
