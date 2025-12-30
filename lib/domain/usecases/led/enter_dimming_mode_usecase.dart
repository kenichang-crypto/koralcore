library;

import 'dart:typed_data';

import '../../../data/ble/led/led_command_builder.dart';
import '../../../data/ble/ble_adapter.dart';
import '../../../data/ble/transport/ble_transport_models.dart';
import '../../../app/common/app_error.dart';
import '../../../app/common/app_error_code.dart';

/// EnterDimmingModeUseCase
///
/// PARITY: Corresponds to reef-b-app's dimming mode entry:
/// - LedRecordTimeSettingViewModel.bleEnterDimmingMode() -> CommandManager.getLedEnterDimmingModeCommand()
/// - BLE opcode 0x32: ledEnterDimmingModeState callback (SUCCESS = 0x01)
/// - On success: sets inDimmingMode = true, enables channel adjustments
/// - On failure: retries entry (bleEnterDimmingMode() called again)
/// - Must be in dimming mode before adjusting channels (0x33)
class EnterDimmingModeUseCase {
  final BleAdapter bleAdapter;
  final LedCommandBuilder commandBuilder;

  const EnterDimmingModeUseCase({
    required this.bleAdapter,
    required this.commandBuilder,
  });

  Future<void> execute({required String deviceId}) async {
    try {
      final Uint8List command = commandBuilder.enterDimmingMode();
      await bleAdapter.write(
        deviceId: deviceId,
        data: command,
        options: const BleWriteOptions(),
      );
    } catch (error) {
      throw AppError(
        code: AppErrorCode.transportError,
        message: 'Failed to enter dimming mode: $error',
      );
    }
  }
}

