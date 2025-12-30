library;

import '../../led_lighting/led_state.dart';
import '../../../platform/contracts/led_repository.dart';
import '../../../app/common/app_error.dart';
import '../../../app/common/app_error_code.dart';

/// StartLedRecordUseCase
///
/// PARITY: Corresponds to reef-b-app's LED record start:
/// - LedMainViewModel.clickBtnContinueRecord() -> bleStartRecord()
/// - CommandManager.getLedStartRecordCommand() -> BLE opcode 0x2B
/// - On success: updates LedInformation mode to RECORD, enables preview/expand buttons
/// - Record mode allows schedule execution and preview functionality
class StartLedRecordUseCase {
  const StartLedRecordUseCase({required this.repository});

  final LedRepository repository;

  Future<LedState> execute({required String deviceId}) {
    if (deviceId.isEmpty) {
      throw const AppError(
        code: AppErrorCode.noActiveDevice,
        message: 'Start record requires an active device.',
      );
    }
    return repository.startRecord(deviceId);
  }
}

