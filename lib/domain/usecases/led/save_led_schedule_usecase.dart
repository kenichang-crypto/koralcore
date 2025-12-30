library;

import '../../../app/common/app_error.dart';
import '../../../app/common/app_error_code.dart';
import 'read_led_schedules.dart';

/// SaveLedScheduleUseCase
///
/// PARITY: Corresponds to reef-b-app's LED schedule saving:
/// - LedScheduleEditActivity: saves schedule via BLE commands
/// - CommandManager.getLedSetRecordCommand() -> BLE opcode 0x41
/// - Schedule is sent to device and stored in LedInformation
/// - On success: updates schedule list, shows toast, navigates back
/// - Note: Currently unavailable in koralcore (firmware limitation)
class LedScheduleChannelInput {
  final String id;
  final String label;
  final int percentage;

  const LedScheduleChannelInput({
    required this.id,
    required this.label,
    required this.percentage,
  });
}

class SaveLedScheduleRequest {
  final String? scheduleId;
  final String title;
  final ReadLedScheduleType type;
  final ReadLedScheduleRecurrence recurrence;
  final int startMinutesFromMidnight;
  final int endMinutesFromMidnight;
  final bool isEnabled;
  final List<LedScheduleChannelInput> channels;
  final String? sceneName;

  const SaveLedScheduleRequest({
    this.scheduleId,
    required this.title,
    required this.type,
    required this.recurrence,
    required this.startMinutesFromMidnight,
    required this.endMinutesFromMidnight,
    required this.isEnabled,
    required this.channels,
    this.sceneName,
  });
}

class SaveLedScheduleUseCase {
  const SaveLedScheduleUseCase.unavailable();

  Future<ReadLedScheduleSnapshot> execute({
    required String deviceId,
    required SaveLedScheduleRequest request,
  }) async {
    throw const AppError(
      code: AppErrorCode.notSupported,
      message: 'Saving LED schedules is not available on current firmware.',
    );
  }
}
