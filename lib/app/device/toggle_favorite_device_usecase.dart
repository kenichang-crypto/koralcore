library;

import '../../platform/contracts/device_repository.dart';
import '../common/app_error.dart';
import '../common/app_error_code.dart';

class ToggleFavoriteDeviceUseCase {
  final DeviceRepository deviceRepository;

  const ToggleFavoriteDeviceUseCase({required this.deviceRepository});

  Future<void> execute({required String deviceId}) async {
    if (deviceId.isEmpty) {
      throw const AppError(
        code: AppErrorCode.invalidParam,
        message: 'deviceId must not be empty',
      );
    }

    await deviceRepository.toggleFavoriteDevice(deviceId);
  }
}

