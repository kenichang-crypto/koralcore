library;

import '../../device/device_context.dart';
import '../../led_lighting/led_state.dart';
import '../../../platform/contracts/led_repository.dart';
import '../../../app/common/app_error.dart';
import '../../../app/common/app_error_code.dart';
import '../../../app/session/current_device_session.dart';

/// ApplySceneUseCase
///
/// PARITY: Corresponds to reef-b-app's scene application behavior:
/// - LedMainViewModel.usePresetScene() -> bleManager.sendLedUsePresetSceneCommand()
/// - CommandManager.getLedUsePresetSceneCommand() -> BLE opcode 0x4A
/// - LedSceneViewModel: applies scene and updates LedInformation
/// - On success: updates nowSceneLiveData, shows preview state
/// - Validates device is not busy before applying (status != idle check)
class ApplySceneUseCase {
  final LedRepository ledRepository;
  final CurrentDeviceSession currentDeviceSession;

  const ApplySceneUseCase({
    required this.ledRepository,
    required this.currentDeviceSession,
  });

  Future<void> execute({
    required String deviceId,
    required String sceneId,
  }) async {
    final DeviceContext deviceContext = currentDeviceSession.requireContext;
    if (deviceContext.deviceId != deviceId) {
      throw const AppError(
        code: AppErrorCode.invalidParam,
        message: 'Device context mismatch while applying LED scene.',
      );
    }

    final LedState? state = await ledRepository.getLedState(deviceId);
    if (state != null && state.status != LedStatus.idle) {
      throw const AppError(
        code: AppErrorCode.deviceBusy,
        message: 'LED is busy. Try again after current operation completes.',
      );
    }

    await ledRepository.updateStatus(
      deviceId: deviceId,
      status: LedStatus.applying,
    );
    try {
      await ledRepository.applyScene(deviceId: deviceId, sceneId: sceneId);
    } on StateError catch (error) {
      await _markError(deviceId);
      throw AppError(code: AppErrorCode.invalidParam, message: error.message);
    } catch (_) {
      await _markError(deviceId);
      throw const AppError(
        code: AppErrorCode.unknownError,
        message: 'Failed to apply LED scene.',
      );
    }
  }

  Future<void> _markError(String deviceId) async {
    await ledRepository.updateStatus(
      deviceId: deviceId,
      status: LedStatus.error,
    );
    await ledRepository.updateStatus(
      deviceId: deviceId,
      status: LedStatus.idle,
    );
  }
}
