library;

import '../../device/device_context.dart';
import '../../../platform/contracts/led_port.dart';
import '../../../app/common/app_error.dart';
import '../../../app/common/app_error_code.dart';
import '../../../app/session/current_device_session.dart';

/// ReadLedScheduleSummaryUseCase
///
/// Reads the active LED schedule overview for the connected device.
///
/// PARITY: Corresponds to reef-b-app's LED schedule summary reading:
/// - LedScheduleListActivity: displays schedule overview from LedInformation
/// - LedInformation tracks active schedules and their details
/// - Schedule info is populated via BLE sync: ledSyncInformation callback
/// - Overview includes schedule type, time windows, and channel levels
class ReadLedScheduleSummaryUseCase {
  final LedPort ledPort;
  final CurrentDeviceSession currentDeviceSession;

  const ReadLedScheduleSummaryUseCase({
    required this.ledPort,
    required this.currentDeviceSession,
  });

  Future<LedScheduleOverview?> execute({required String deviceId}) async {
    final DeviceContext deviceContext = currentDeviceSession.requireContext;
    if (deviceContext.deviceId != deviceId) {
      throw const AppError(
        code: AppErrorCode.invalidParam,
        message: 'DeviceContext mismatch for LED schedule summary.',
      );
    }

    return ledPort.readScheduleOverview(deviceId: deviceId);
  }
}
