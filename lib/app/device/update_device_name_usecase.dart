library;

import '../../platform/contracts/device_repository.dart';
import '../common/app_error.dart';
import '../common/app_error_code.dart';

class UpdateDeviceNameUseCase {
  final DeviceRepository deviceRepository;

  UpdateDeviceNameUseCase({required this.deviceRepository});

  Future<void> execute({
    required String deviceId,
    required String name,
  }) async {
    if (name.trim().isEmpty) {
      throw const AppError(
        code: AppErrorCode.invalidParam,
        message: 'Device name must not be empty',
      );
    }

    await deviceRepository.updateDeviceName(deviceId, name.trim());
  }
}

