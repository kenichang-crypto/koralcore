library;

import '../../../platform/contracts/device_repository.dart';
import '../../../platform/contracts/dosing_repository.dart';
import '../../../app/common/app_error.dart';
import '../../../app/common/app_error_code.dart';

/// ResetDosingStateUseCase
///
/// PARITY: Corresponds to reef-b-app's dosing state reset behavior:
/// - DropHeadMainViewModel.resetDevice() -> dropInformation.resetSchedule(headId)
/// - DropInformation.resetSchedule() clears schedule, mode, totals
/// - On success: updates UI, shows toast, refreshes pump head state
/// - Validates device exists before reset
class ResetDosingStateUseCase {
  final DeviceRepository deviceRepository;
  final DosingRepository dosingRepository;

  const ResetDosingStateUseCase({
    required this.deviceRepository,
    required this.dosingRepository,
  });

  Future<void> execute({required String deviceId}) async {
    if (deviceId.isEmpty) {
      throw const AppError(
        code: AppErrorCode.noActiveDevice,
        message: 'Reset requires an active device.',
      );
    }

    final Map<String, dynamic>? device = await deviceRepository.getDevice(
      deviceId,
    );
    if (device == null) {
      throw const AppError(
        code: AppErrorCode.invalidParam,
        message: 'Unknown device id for reset.',
      );
    }

    await dosingRepository.resetToDefault(deviceId);
  }
}

