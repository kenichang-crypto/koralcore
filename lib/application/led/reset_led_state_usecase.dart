library;

import '../../platform/contracts/device_repository.dart';
import '../../platform/contracts/led_repository.dart';
import '../common/app_error.dart';
import '../common/app_error_code.dart';

class ResetLedStateUseCase {
  final DeviceRepository deviceRepository;
  final LedRepository ledRepository;

  const ResetLedStateUseCase({
    required this.deviceRepository,
    required this.ledRepository,
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
    if (device['isMaster'] == true) {
      throw const AppError(
        code: AppErrorCode.invalidParam,
        message: 'Master devices cannot be reset.',
      );
    }

    await ledRepository.resetToDefault(deviceId);
  }
}
