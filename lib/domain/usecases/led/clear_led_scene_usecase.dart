library;

import '../../../platform/contracts/led_repository.dart';

/// Use case that mirrors Reef-B's scene deletion flow plus clearing LED records.
class ClearLedSceneUseCase {
  final LedRepository repository;

  ClearLedSceneUseCase(this.repository);

  Future<void> execute(String deviceId) async {
    await repository.clearScene(deviceId);
  }
}
