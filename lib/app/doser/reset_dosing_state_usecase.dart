library;

import '../../platform/contracts/device_repository.dart';
import '../../platform/contracts/dosing_repository.dart';
import '../common/app_error.dart';
import '../common/app_error_code.dart';

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

