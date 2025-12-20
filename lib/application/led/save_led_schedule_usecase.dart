library;

import '../common/app_error.dart';
import '../common/app_error_code.dart';
import 'led_schedule_store.dart';
import 'read_led_schedules.dart';

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
  final LedScheduleMemoryStore store;

  const SaveLedScheduleUseCase({required this.store});

  Future<ReadLedScheduleSnapshot> execute({
    required String deviceId,
    required SaveLedScheduleRequest request,
  }) async {
    if (deviceId.isEmpty) {
      throw const AppError(
        code: AppErrorCode.noActiveDevice,
        message: 'LED schedule saves require an active device id.',
      );
    }

    final String trimmedTitle = request.title.trim();
    if (trimmedTitle.isEmpty) {
      throw const AppError(
        code: AppErrorCode.invalidParam,
        message: 'Provide a schedule title.',
      );
    }
    if (request.startMinutesFromMidnight >= request.endMinutesFromMidnight) {
      throw const AppError(
        code: AppErrorCode.invalidParam,
        message: 'Start time must be before end time.',
      );
    }
    if (request.channels.isEmpty) {
      throw const AppError(
        code: AppErrorCode.invalidParam,
        message: 'Provide at least one LED channel.',
      );
    }
    final bool invalidChannel = request.channels.any(
      (channel) => channel.percentage < 0 || channel.percentage > 100,
    );
    if (invalidChannel) {
      throw const AppError(
        code: AppErrorCode.invalidParam,
        message: 'Channel intensity must be between 0 and 100%.',
      );
    }

    final String scheduleId = (request.scheduleId?.trim().isNotEmpty ?? false)
        ? request.scheduleId!.trim()
        : store.nextScheduleId(deviceId);

    final List<LedScheduleChannelState> channelStates = request.channels
        .map(
          (channel) => LedScheduleChannelState(
            id: channel.id,
            label: channel.label,
            percentage: channel.percentage,
          ),
        )
        .toList(growable: false);

    final LedScheduleRecord record = LedScheduleRecord(
      id: scheduleId,
      title: trimmedTitle,
      type: request.type,
      recurrence: request.recurrence,
      startMinutesFromMidnight: request.startMinutesFromMidnight,
      endMinutesFromMidnight: request.endMinutesFromMidnight,
      isEnabled: request.isEnabled,
      channels: channelStates,
      sceneName: request.sceneName?.trim().isEmpty ?? true
          ? null
          : request.sceneName!.trim(),
    );

    final LedScheduleRecord saved = await store.saveSchedule(
      deviceId: deviceId,
      record: record,
    );

    return mapLedScheduleRecordToSnapshot(saved);
  }
}
