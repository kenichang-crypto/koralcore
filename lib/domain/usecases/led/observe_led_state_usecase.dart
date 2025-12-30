library;

import '../../led_lighting/led_state.dart';
import '../../../platform/contracts/led_repository.dart';
import '../../../app/common/app_error.dart';
import '../../../app/common/app_error_code.dart';

/// ObserveLedStateUseCase
///
/// PARITY: Corresponds to reef-b-app's LED state observation:
/// - LedMainViewModel: ledModeLiveData observes LedInformation state changes
/// - State updates via BLE callbacks: ledSyncInformation, ledUsePresetScene, ledPreview
/// - LiveData pattern in Android replaced by Stream in Flutter
/// - UI reacts to state changes (mode, preview state, current scene)
class ObserveLedStateUseCase {
  final LedRepository ledRepository;

  const ObserveLedStateUseCase({required this.ledRepository});

  Stream<LedState> execute({required String deviceId}) {
    if (deviceId.isEmpty) {
      throw const AppError(
        code: AppErrorCode.noActiveDevice,
        message: 'LED state observation requires an active device id.',
      );
    }

    return ledRepository.observeLedState(deviceId);
  }
}
