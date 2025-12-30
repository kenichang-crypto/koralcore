library;

import 'dart:typed_data';

import '../../data/ble/led/led_command_builder.dart';
import '../../data/ble/ble_adapter.dart';
import '../../data/ble/transport/ble_transport_models.dart';
import '../common/app_error.dart';
import '../common/app_error_code.dart';

class ExitDimmingModeUseCase {
  final BleAdapter bleAdapter;
  final LedCommandBuilder commandBuilder;

  const ExitDimmingModeUseCase({
    required this.bleAdapter,
    required this.commandBuilder,
  });

  Future<void> execute({required String deviceId}) async {
    try {
      final Uint8List command = commandBuilder.exitDimmingMode();
      await bleAdapter.write(
        deviceId: deviceId,
        data: command,
        options: const BleWriteOptions(),
      );
    } catch (error) {
      throw AppError(
        code: AppErrorCode.transportError,
        message: 'Failed to exit dimming mode: $error',
      );
    }
  }
}

