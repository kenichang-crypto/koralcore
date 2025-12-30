library;

import '../../device/device_context.dart';
import '../../../platform/contracts/dosing_port.dart';
import '../../../app/common/app_error.dart';
import '../../../app/common/app_error_code.dart';
import '../../../app/session/current_device_session.dart';

/// ReadDosingScheduleSummaryUseCase
///
/// Reads the lightweight dosing schedule summary for a pump head.
///
/// PARITY: Corresponds to reef-b-app's schedule summary reading:
/// - DropHeadMainViewModel.getNowRecords() -> dropInformation.getMode(headId)
/// - DropInformation.getMode() returns DropHeadMode with schedule type and details
/// - Schedule info is populated via BLE sync: dropSyncInformationState, dropGetTotalDropNo
/// - Mode types: NONE, _24HR, SINGLE, CUSTOM (matching DropRecordType enum)
class ReadDosingScheduleSummaryUseCase {
  final DosingPort dosingPort;
  final CurrentDeviceSession currentDeviceSession;

  const ReadDosingScheduleSummaryUseCase({
    required this.dosingPort,
    required this.currentDeviceSession,
  });

  Future<DosingScheduleSummary?> execute({
    required String deviceId,
    required String headId,
  }) async {
    final DeviceContext deviceContext = currentDeviceSession.requireContext;
    if (deviceContext.deviceId != deviceId) {
      throw const AppError(
        code: AppErrorCode.invalidParam,
        message: 'DeviceContext mismatch for dosing schedule summary.',
      );
    }

    final int pumpId = _pumpIdFromHeadId(headId);
    return dosingPort.readScheduleSummary(deviceId: deviceId, pumpId: pumpId);
  }

  int _pumpIdFromHeadId(String value) {
    final String normalized = value.trim().toUpperCase();
    if (normalized.isEmpty) {
      return 1;
    }
    final int candidate = normalized.codeUnitAt(0) - 64;
    if (candidate < 1) {
      return 1;
    }
    return candidate;
  }
}
