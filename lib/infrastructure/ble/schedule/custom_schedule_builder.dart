import 'dart:typed_data';

import '../../../domain/doser_dosing/doser_schedule.dart';
import '../../../domain/doser_dosing/doser_schedule_type.dart';
import '../../../domain/doser_dosing/schedule_time_models.dart';
import '../../../domain/doser_dosing/schedule_repeat.dart';
import '../../../domain/doser_dosing/weekday.dart';
import '../../../domain/doser_dosing/schedule_weekday.dart';
import '../../../domain/doser_dosing/custom_window_schedule_definition.dart';
import '../../../domain/doser_dosing/dose_distribution.dart';
import '../../../domain/doser_dosing/pump_speed.dart';
import '../../../domain/doser_dosing/time_of_day.dart';
import '../../ble/encoder/schedule/custom_schedule_chunk_encoder.dart';
import '../../ble/encoder/schedule/custom_schedule_encoder_0x72.dart';
import '../../ble/encoder/schedule/custom_schedule_encoder_0x73.dart';
import '../../ble/encoder/schedule/custom_schedule_encoder_0x74.dart';

/// Builds the BLE payloads for a custom schedule (opcodes 0x72, 0x73, 0x74).
///
/// Returns a list of payloads, one for each chunk:
/// - 0x72: First chunk (chunkIndex 0)
/// - 0x73: Second chunk (chunkIndex 1)
/// - 0x74: Third chunk (chunkIndex 2)
///
/// Based on reef-b-app CommandManager.getDropCustomWeeklyCommand(),
/// getDropCustomRangeCommand(), and getDropCustomDetailCommand().
///
/// Note: This builder converts DoserSchedule to CustomWindowScheduleDefinition
/// and uses the existing encoders. The schedule is split into chunks based on
/// the time range and distribution.
List<Uint8List> buildCustomScheduleCommand(DoserSchedule schedule) {
  if (schedule.type != DoserScheduleType.custom) {
    throw ArgumentError.value(
      schedule.type,
      'schedule.type',
      'Expected DoserScheduleType.custom, got ${schedule.type}',
    );
  }

  if (schedule.time is! TimeRange) {
    throw ArgumentError.value(
      schedule.time,
      'schedule.time',
      'Custom schedule requires TimeRange',
    );
  }

  final TimeRange timeRange = schedule.time as TimeRange;
  final CustomWindowScheduleDefinition definition =
      _convertToCustomWindowDefinition(schedule, timeRange);

  // Use existing encoders for each chunk
  final List<Uint8List> payloads = <Uint8List>[];
  final Map<int, CustomScheduleChunkEncoder> encoders = <int, CustomScheduleChunkEncoder>{
    0: CustomScheduleEncoder0x72(),
    1: CustomScheduleEncoder0x73(),
    2: CustomScheduleEncoder0x74(),
  };

  for (final ScheduleWindowChunk chunk in definition.chunks) {
    final CustomScheduleChunkEncoder? encoder = encoders[chunk.chunkIndex];
    if (encoder == null) {
      throw StateError(
        'Custom schedule chunk index ${chunk.chunkIndex} is not supported. '
        'Only indices 0-2 are supported (opcodes 0x72-0x74).',
      );
    }
    payloads.add(encoder.encode(definition));
  }

  return payloads;
}

CustomWindowScheduleDefinition _convertToCustomWindowDefinition(
  DoserSchedule schedule,
  TimeRange timeRange,
) {
  final int pumpId = schedule.pumpId;
  final int times = schedule.distribution.times;
  final double dosePerEvent = schedule.totalDoseMl / times;

  // Convert time range to minute-of-day
  final int startMinutes = timeRange.start.hour * 60 + timeRange.start.minute;
  final int endMinutes = timeRange.end.hour * 60 + timeRange.end.minute;
  final int rangeMinutes = endMinutes - startMinutes;

  // Distribute events across the time range
  final List<WindowDoseEvent> events = <WindowDoseEvent>[];
  for (int i = 0; i < times; i++) {
    final int eventMinutes = startMinutes + (rangeMinutes * i ~/ times);
    final int minuteOffset = eventMinutes - startMinutes;

    events.add(
      WindowDoseEvent(
        minuteOffset: minuteOffset,
        doseMl: dosePerEvent,
        speed: PumpSpeed.medium, // Default speed, can be extracted from schedule if available
      ),
    );
  }

  // Create a single chunk (chunkIndex 0)
  // In practice, if there are many events, they may need to be split into
  // multiple chunks based on firmware constraints
  final List<ScheduleWindowChunk> chunks = <ScheduleWindowChunk>[
    ScheduleWindowChunk(
      chunkIndex: 0,
      windowStartMinute: startMinutes,
      windowEndMinute: endMinutes,
      events: events,
    ),
  ];

  return CustomWindowScheduleDefinition(
    scheduleId: 'custom-${schedule.pumpId}',
    pumpId: pumpId,
    chunks: chunks,
  );
}
