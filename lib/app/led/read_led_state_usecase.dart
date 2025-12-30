library;

import '../../domain/led_lighting/led_state.dart';
import '../../platform/contracts/led_repository.dart';
import '../common/app_error.dart';
import '../common/app_error_code.dart';

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
