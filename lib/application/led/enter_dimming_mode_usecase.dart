library;

import 'dart:typed_data';

import '../../infrastructure/ble/led/led_command_builder.dart';
import '../../infrastructure/ble/ble_adapter.dart';
import '../../infrastructure/ble/transport/ble_transport_models.dart';
import '../common/app_error.dart';
import '../common/app_error_code.dart';

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

