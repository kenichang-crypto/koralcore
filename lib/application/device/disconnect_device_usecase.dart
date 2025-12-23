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

import '../../domain/doser_dosing/pump_head.dart';
import '../../domain/led_lighting/led_state.dart';
import '../../platform/contracts/device_repository.dart';
import '../../platform/contracts/led_repository.dart';
import '../../platform/contracts/pump_head_repository.dart';
import '../common/app_error.dart';
import '../common/app_error_code.dart';
import '../session/current_device_session.dart';

class DisconnectDeviceUseCase {
  final DeviceRepository deviceRepository;
  final CurrentDeviceSession currentDeviceSession;
  final PumpHeadRepository pumpHeadRepository;
  final LedRepository ledRepository;

  DisconnectDeviceUseCase({
    required this.deviceRepository,
    required this.currentDeviceSession,
    required this.pumpHeadRepository,
    required this.ledRepository,
  });

  Future<void> execute({required String deviceId}) async {
    final String? currentDeviceId = await deviceRepository.getCurrentDevice();
    try {
      await deviceRepository.disconnect(deviceId);
    } catch (error) {
      throw AppError(
        code: AppErrorCode.transportError,
        message: 'Failed to disconnect: $error',
      );
    }

    await deviceRepository.updateDeviceState(deviceId, 'disconnected');
    if (currentDeviceId == deviceId) {
      currentDeviceSession.clear();
    }
    await _resetRunningPumpHeads(deviceId);
    await _resetLedState(deviceId);
  }

  Future<void> _resetRunningPumpHeads(String deviceId) async {
    try {
      final List<PumpHead> heads = await pumpHeadRepository.listPumpHeads(
        deviceId,
      );
      for (final PumpHead head in heads) {
        if (head.status == PumpHeadStatus.running) {
          await pumpHeadRepository.updateStatus(
            deviceId: deviceId,
            headId: head.headId,
            status: PumpHeadStatus.idle,
          );
        }
      }
    } catch (_) {
      // Ignore pump head reset failures on disconnect.
    }
  }

  Future<void> _resetLedState(String deviceId) async {
    try {
      final LedState? state = await ledRepository.getLedState(deviceId);
      if (state != null && state.status == LedStatus.applying) {
        await ledRepository.updateStatus(
          deviceId: deviceId,
          status: LedStatus.idle,
        );
      }
    } catch (_) {
      // Ignore LED reset failures on disconnect.
    }
  }
}
