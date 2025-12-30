library;

import '../../domain/led_lighting/led_state.dart';
import '../../platform/contracts/led_repository.dart';
import '../common/app_error.dart';
import '../common/app_error_code.dart';

class StartLedRecordUseCase {
  const StartLedRecordUseCase({required this.repository});

  final LedRepository repository;

  Future<LedState> execute({required String deviceId}) {
    if (deviceId.isEmpty) {
      throw const AppError(
        code: AppErrorCode.noActiveDevice,
        message: 'Start record requires an active device.',
      );
    }
    return repository.startRecord(deviceId);
  }
}

