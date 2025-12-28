library;

import '../../domain/doser_dosing/dosing_state.dart';
import '../../platform/contracts/dosing_repository.dart';
import '../common/app_error.dart';
import '../common/app_error_code.dart';

class ObserveDosingStateUseCase {
  final DosingRepository dosingRepository;

  const ObserveDosingStateUseCase({required this.dosingRepository});

  Stream<DosingState> execute({required String deviceId}) {
    if (deviceId.isEmpty) {
      throw const AppError(
        code: AppErrorCode.noActiveDevice,
        message: 'Dosing state observation requires an active device id.',
      );
    }

    return dosingRepository.observeDosingState(deviceId);
  }
}

