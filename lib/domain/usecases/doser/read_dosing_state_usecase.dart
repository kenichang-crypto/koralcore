library;

import '../../doser_dosing/dosing_state.dart';
import '../../../platform/contracts/dosing_repository.dart';
import '../../../app/common/app_error.dart';
import '../../../app/common/app_error_code.dart';

/// ReadDosingStateUseCase
///
/// PARITY: Corresponds to reef-b-app's dosing state reading:
/// - DropHeadMainViewModel.getNowRecords() -> dropInformation.getMode(headId)
/// - DropInformation.getMode() returns DropHeadMode with current state
/// - State includes: mode (NONE/_24HR/SINGLE/CUSTOM), schedule details, totals
/// - State is populated via BLE sync: dropSyncInformationState callback
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

