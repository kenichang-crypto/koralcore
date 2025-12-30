library;

import '../../led_lighting/led_state.dart';
import '../../../platform/contracts/led_repository.dart';
import '../../../app/common/app_error.dart';
import '../../../app/common/app_error_code.dart';

/// ReadLedStateUseCase
///
/// PARITY: Corresponds to reef-b-app's LED state reading behavior:
/// - LedMainViewModel: ledInformation is managed by BleContainer
/// - State is read after bleSyncInformation() completes
/// - LedInformation is updated via BLE callbacks: ledSyncInformation, ledUsePresetScene, etc.
/// - LedMainActivity displays state from LedInformation after sync
class ReadLedStateUseCase {
  final LedRepository ledRepository;

  const ReadLedStateUseCase({required this.ledRepository});

  Future<LedState> execute({required String deviceId}) async {
    if (deviceId.isEmpty) {
      throw const AppError(
        code: AppErrorCode.noActiveDevice,
        message: 'LED state requires an active device id.',
      );
    }

    final LedState? state = await ledRepository.getLedState(deviceId);
    if (state == null) {
      throw const AppError(
        code: AppErrorCode.invalidParam,
        message: 'Unable to find LED state for the requested device.',
      );
    }
    return state;
  }
}
