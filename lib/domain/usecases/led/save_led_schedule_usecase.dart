library;

import '../../../app/common/app_error.dart';
import '../../../app/common/app_error_code.dart';
import '../../../data/repositories/schedule_repository_impl.dart';
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
  const SaveLedScheduleUseCase.unavailable()
      : _repository = null,
        _isLocal = false;

  /// Local-only persistence. BLE schedule sync to device is not implemented (firmware limitation).
  const SaveLedScheduleUseCase.local(ScheduleRepositoryImpl repository)
      : _repository = repository,
        _isLocal = true;

  final ScheduleRepositoryImpl? _repository;
  final bool _isLocal;

  Future<ReadLedScheduleSnapshot> execute({
    required String deviceId,
    required SaveLedScheduleRequest request,
  }) async {
    if (_isLocal && _repository != null) {
      final channels = request.channels
          .map(
            (c) => ReadLedScheduleChannelSnapshot(
              id: c.id,
              label: c.label,
              percentage: c.percentage,
            ),
          )
          .toList(growable: false);
      if (request.scheduleId != null) {
        await _repository.updateSchedule(
          deviceId: deviceId,
          scheduleId: request.scheduleId!,
          title: request.title,
          type: request.type,
          recurrence: request.recurrence,
          startMinutesFromMidnight: request.startMinutesFromMidnight,
          endMinutesFromMidnight: request.endMinutesFromMidnight,
          isEnabled: request.isEnabled,
          channels: channels,
          sceneName: request.sceneName,
        );
        return ReadLedScheduleSnapshot(
          id: request.scheduleId!,
          title: request.title,
          type: request.type,
          recurrence: request.recurrence,
          startMinutesFromMidnight: request.startMinutesFromMidnight,
          endMinutesFromMidnight: request.endMinutesFromMidnight,
          sceneName: request.sceneName ?? '',
          isEnabled: request.isEnabled,
          isDerived: false,
          channels: channels,
        );
      } else {
        final scheduleId = await _repository.addSchedule(
          deviceId: deviceId,
          title: request.title,
          type: request.type,
          recurrence: request.recurrence,
          startMinutesFromMidnight: request.startMinutesFromMidnight,
          endMinutesFromMidnight: request.endMinutesFromMidnight,
          isEnabled: request.isEnabled,
          channels: channels,
          sceneName: request.sceneName,
        );
        return ReadLedScheduleSnapshot(
          id: scheduleId,
          title: request.title,
          type: request.type,
          recurrence: request.recurrence,
          startMinutesFromMidnight: request.startMinutesFromMidnight,
          endMinutesFromMidnight: request.endMinutesFromMidnight,
          sceneName: request.sceneName ?? '',
          isEnabled: request.isEnabled,
          isDerived: false,
          channels: channels,
        );
      }
    }
    // BLE schedule sync to device: firmware limitation - not implemented.
    // TODO: Implement BLE schedule write when firmware supports it.
    throw const AppError(
      code: AppErrorCode.notSupported,
      message: 'Saving LED schedules is not available on current firmware.',
    );
  }
}
