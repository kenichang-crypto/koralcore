library;

import '../../domain/doser_dosing/dosing_state.dart';
import '../../platform/contracts/dosing_repository.dart';
import '../common/app_error.dart';
import '../common/app_error_code.dart';

class ReadDosingStateUseCase {
  final DosingRepository dosingRepository;

  const ReadDosingStateUseCase({required this.dosingRepository});

  Future<DosingState> execute({required String deviceId}) async {
    if (deviceId.isEmpty) {
      throw const AppError(
        code: AppErrorCode.noActiveDevice,
        message: 'Dosing state requires an active device id.',
      );
    }

    final DosingState? state = await dosingRepository.getDosingState(deviceId);
    if (state == null) {
      throw const AppError(
        code: AppErrorCode.invalidParam,
        message: 'Unable to find Dosing state for the requested device.',
      );
    }
    return state;
  }
}

