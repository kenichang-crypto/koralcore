/// DisconnectDeviceUseCase
///
/// Gracefully closes BLE connection and updates state.
///
/// Execution order:
/// 1. Request BLE adapter to disconnect
/// 2. Update local state -> disconnected
/// 3. Optionally attempt reconnection (outside scope)
///
library;

import '../../platform/contracts/device_repository.dart';
import '../common/app_error.dart';
import '../common/app_error_code.dart';
import '../session/current_device_session.dart';

class DisconnectDeviceUseCase {
  final DeviceRepository deviceRepository;
  final CurrentDeviceSession currentDeviceSession;

  DisconnectDeviceUseCase({
    required this.deviceRepository,
    required this.currentDeviceSession,
  });

  Future<void> execute({required String deviceId}) async {
    try {
      await deviceRepository.disconnect(deviceId);
    } catch (error) {
      throw AppError(
        code: AppErrorCode.transportError,
        message: 'Failed to disconnect: $error',
      );
    }

    await deviceRepository.updateDeviceState(deviceId, 'disconnected');
    currentDeviceSession.clear();
  }
}
