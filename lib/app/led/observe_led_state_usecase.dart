library;

import '../../domain/led_lighting/led_state.dart';
import '../../platform/contracts/led_repository.dart';
import '../common/app_error.dart';
import '../common/app_error_code.dart';

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
