library;

import '../../infrastructure/ble/led/led_command_builder.dart';
import '../../infrastructure/ble/ble_adapter.dart';
import '../../infrastructure/ble/transport/ble_transport_models.dart';
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

