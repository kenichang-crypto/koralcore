library;

import '../../doser_dosing/dosing_state.dart';
import '../../../platform/contracts/dosing_repository.dart';
import '../../../app/common/app_error.dart';
import '../../../app/common/app_error_code.dart';

/// ObserveDosingStateUseCase
///
/// PARITY: Corresponds to reef-b-app's dosing state observation:
/// - DropHeadMainViewModel: observes DropInformation state changes
/// - State updates via BLE callbacks: dropSyncInformationState, dropStartAdjustState
/// - LiveData pattern in Android replaced by Stream in Flutter
/// - UI reacts to state changes (mode, schedule, totals)
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

