library;

import 'dart:async';

import '../common/app_error.dart';
import '../common/app_error_code.dart';
import 'led_schedule_store.dart';

enum ReadLedScheduleType { dailyProgram, customWindow, sceneBased }

enum ReadLedScheduleRecurrence { everyDay, weekdays, weekends }

class ReadLedScheduleChannelSnapshot {
  final String id;
  final String label;
  final int percentage;

  const ReadLedScheduleChannelSnapshot({
    required this.id,
    required this.label,
    required this.percentage,
  });
}

class ReadLedScheduleSnapshot {
  final String id;
  final String title;
  final ReadLedScheduleType type;
  final ReadLedScheduleRecurrence recurrence;
  final int startMinutesFromMidnight;
  final int endMinutesFromMidnight;
  final String sceneName;
  final bool isEnabled;
  final List<ReadLedScheduleChannelSnapshot> channels;

  const ReadLedScheduleSnapshot({
    required this.id,
    required this.title,
    required this.type,
    required this.recurrence,
    required this.startMinutesFromMidnight,
    required this.endMinutesFromMidnight,
    required this.sceneName,
    required this.isEnabled,
    required this.channels,
  });
}

/// Placeholder use case that supplies LED schedule metadata for a device.
/// The final BLE transport wiring will plug in once the firmware protocol
/// stabilizes, but this snapshot list keeps the UI unblocked.
class ReadLedScheduleUseCase {
  final LedScheduleMemoryStore store;

  const ReadLedScheduleUseCase({required this.store});

  Future<List<ReadLedScheduleSnapshot>> execute({
    required String deviceId,
  }) async {
    if (deviceId.isEmpty) {
      throw const AppError(
        code: AppErrorCode.noActiveDevice,
        message: 'LED schedules require an active device id.',
      );
    }

    final List<LedScheduleRecord> records = await store.listSchedules(
      deviceId: deviceId,
    );
    return records.map(mapLedScheduleRecordToSnapshot).toList(growable: false);
  }
}

ReadLedScheduleSnapshot mapLedScheduleRecordToSnapshot(
  LedScheduleRecord record,
) {
  return ReadLedScheduleSnapshot(
    id: record.id,
    title: record.title,
    type: record.type,
    recurrence: record.recurrence,
    startMinutesFromMidnight: record.startMinutesFromMidnight,
    endMinutesFromMidnight: record.endMinutesFromMidnight,
    sceneName: record.sceneName ?? _formatChannelSummary(record.channels),
    isEnabled: record.isEnabled,
    channels: record.channels
        .map(
          (channel) => ReadLedScheduleChannelSnapshot(
            id: channel.id,
            label: channel.label,
            percentage: channel.percentage,
          ),
        )
        .toList(growable: false),
  );
}

String _formatChannelSummary(List<LedScheduleChannelState> channels) {
  if (channels.isEmpty) {
    return 'Custom spectrum';
  }
  return channels
      .map((channel) => '${channel.label} ${channel.percentage}%')
      .join(' / ');
}
