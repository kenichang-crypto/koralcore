library;

import '../../domain/device/device_context.dart';
import '../../platform/contracts/led_port.dart';
import '../common/app_error.dart';
import '../common/app_error_code.dart';
import '../session/current_device_session.dart';

/// Reads the active LED schedule overview for the connected device.
class ReadLedScheduleSummaryUseCase {
  final LedPort ledPort;
  final CurrentDeviceSession currentDeviceSession;

  const ReadLedScheduleSummaryUseCase({
    required this.ledPort,
    required this.currentDeviceSession,
  });

  Future<LedScheduleOverview?> execute({required String deviceId}) async {
    final DeviceContext deviceContext = currentDeviceSession.requireContext();
    if (deviceContext.deviceId != deviceId) {
      throw const AppError(
        code: AppErrorCode.invalidParam,
        message: 'DeviceContext mismatch for LED schedule summary.',
      );
    }

    return ledPort.readScheduleOverview(deviceId: deviceId);
  }
}
