library;

import '../../device/device_context.dart';
import '../../../platform/contracts/dosing_port.dart';
import '../../../platform/contracts/pump_head_repository.dart';
import '../../../app/common/app_error.dart';
import '../../../app/common/app_error_code.dart';
import '../../../app/session/current_device_session.dart';

/// ReadTodayTotalUseCase
///
/// Reads the "today total" dosing summary using firmware opcodes 0x7E/0x7A.
///
/// PARITY: Corresponds to reef-b-app's today total reading:
/// - DropHeadMainViewModel.getTodayTotal() -> dropInformation.getTodayTotalDrop(headId)
/// - DropInformation.getTodayTotalDrop() returns recrodDrop + otherDrop
/// - Uses BLE opcodes 0x7E (modern) or 0x7A (legacy) based on firmware support
/// - DropInformation.setDropVolume() updates totals via BLE callbacks
/// - Totals are displayed in DropHeadMainActivity pump head summary
class ReadTodayTotalUseCase {
  final DosingPort dosingPort;
  final CurrentDeviceSession currentDeviceSession;
  final PumpHeadRepository pumpHeadRepository;

  const ReadTodayTotalUseCase({
    required this.dosingPort,
    required this.currentDeviceSession,
    required this.pumpHeadRepository,
  });

  Future<TodayDoseSummary?> execute({
    required String deviceId,
    required String headId,
  }) async {
    final DeviceContext deviceContext = currentDeviceSession.requireContext;
    if (deviceContext.deviceId != deviceId) {
      throw const AppError(
        code: AppErrorCode.invalidParam,
        message: 'DeviceContext mismatch for ReadTodayTotalUseCase.',
      );
    }

    final int pumpId = _pumpIdFromHeadId(headId);
    final List<TodayDoseReadOpcode> attempts = deviceContext.supportsDecimalMl
        ? <TodayDoseReadOpcode>[
            TodayDoseReadOpcode.modern0x7E,
            TodayDoseReadOpcode.legacy0x7A,
          ]
        : <TodayDoseReadOpcode>[TodayDoseReadOpcode.legacy0x7A];

    for (final TodayDoseReadOpcode opcode in attempts) {
      try {
        final TodayDoseSummary? summary = await dosingPort.readTodayTotals(
          deviceId: deviceId,
          pumpId: pumpId,
          opcode: opcode,
        );
        if (summary != null) {
          await pumpHeadRepository.updateTotals(
            deviceId: deviceId,
            headId: headId,
            totalMl: summary.totalMl,
            lastDoseAt: DateTime.now(),
          );
          return summary;
        }
      } on AppError catch (error) {
        final bool canFallback =
            opcode == TodayDoseReadOpcode.modern0x7E &&
            error.code == AppErrorCode.notSupported;
        if (canFallback) {
          continue;
        }
        rethrow;
      }
    }

    return null;
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
