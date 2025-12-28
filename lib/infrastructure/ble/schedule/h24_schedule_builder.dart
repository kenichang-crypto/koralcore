import 'dart:typed_data';

import '../../../domain/doser_dosing/doser_schedule.dart';
import '../../../domain/doser_dosing/doser_schedule_type.dart';
import '../../../domain/doser_dosing/schedule_time_models.dart';
import '../../../domain/doser_dosing/weekday.dart';
import '../../../domain/doser_dosing/schedule_weekday.dart';
import '../../../domain/doser_dosing/encoder/single_dose_encoding_utils.dart';
import '../../../domain/doser_dosing/pump_speed.dart';
import '../../../domain/doser_dosing/daily_average_schedule_definition.dart';
import '../../ble/encoder/schedule/daily_average_schedule_encoder.dart';

/// Builds the BLE payload for a 24h schedule (opcodes 0x70 or 0x71).
///
/// Returns payload for:
/// - 0x70: Weekly repeat schedule (uses DailyAverageScheduleEncoder)
/// - 0x71: Date range schedule (legacy format, not commonly used)
///
/// Based on reef-b-app CommandManager.getDrop24WeeklyCommand() and
/// getDrop24RangeCommand().
///
/// Note: This builder converts DoserSchedule to DailyAverageScheduleDefinition
/// and uses the existing encoder. For 0x71 (date range), a simplified
/// implementation is provided, but it's recommended to use 0x70 format.
Uint8List buildH24ScheduleCommand(DoserSchedule schedule) {
  if (schedule.type != DoserScheduleType.h24) {
    throw ArgumentError.value(
      schedule.type,
      'schedule.type',
      'Expected DoserScheduleType.h24, got ${schedule.type}',
    );
  }

  // For weekly repeat schedules (0x70), use DailyAverageScheduleEncoder
  if (schedule.repeat != null && schedule.repeat!.days.isNotEmpty) {
    final DailyAverageScheduleDefinition definition =
        _convertToDailyAverageDefinition(schedule);
    final DailyAverageScheduleEncoder encoder = DailyAverageScheduleEncoder();
    return encoder.encode(definition);
  }

  // For date range schedules (0x71), use legacy format
  // Note: This is a simplified implementation. In practice, date range
  // schedules may need additional domain models or parameters.
  return _buildDateRangeCommand(schedule);
}

DailyAverageScheduleDefinition _convertToDailyAverageDefinition(
  DoserSchedule schedule,
) {
  if (schedule.time is! TimeRange) {
    throw ArgumentError.value(
      schedule.time,
      'schedule.time',
      'H24 schedule requires TimeRange',
    );
  }

  final TimeRange timeRange = schedule.time as TimeRange;
  final Set<ScheduleWeekday> repeatDays = schedule.repeat!.days
      .map((Weekday day) => ScheduleWeekday.values[day.index])
      .toSet();

  // Distribute total dose across the time range based on distribution.times
  final int times = schedule.distribution.times;
  final List<DailyDoseSlot> slots = <DailyDoseSlot>[];
  final double dosePerSlot = schedule.totalDoseMl / times;

  // Calculate time slots evenly distributed across the range
  final int startMinutes = timeRange.start.hour * 60 + timeRange.start.minute;
  final int endMinutes = timeRange.end.hour * 60 + timeRange.end.minute;
  final int rangeMinutes = endMinutes - startMinutes;

  for (int i = 0; i < times; i++) {
    final int slotMinutes = startMinutes + (rangeMinutes * i ~/ times);
    final int hour = slotMinutes ~/ 60;
    final int minute = slotMinutes % 60;

    slots.add(
      DailyDoseSlot(
        hour: hour,
        minute: minute,
        doseMl: dosePerSlot,
        speed: PumpSpeed
            .medium, // Default speed, can be extracted from schedule if available
      ),
    );
  }

  return DailyAverageScheduleDefinition(
    scheduleId: 'h24-${schedule.pumpId}',
    pumpId: schedule.pumpId,
    repeatDays: repeatDays,
    slots: slots,
  );
}

Uint8List _buildDateRangeCommand(DoserSchedule schedule) {
  final List<int> payload = <int>[];
  final int pumpId = schedule.pumpId;
  final int totalDose = SingleDoseEncodingUtils.scaleDoseMlToTenths(
    schedule.totalDoseMl,
  );

  payload.add(0x71);
  payload.add(0x0A); // Data length
  payload.add(pumpId & 0xFF);

  // Date range: Use current date as placeholder
  // In practice, this should be extracted from schedule metadata or
  // a separate date range parameter
  final DateTime now = DateTime.now();
  final int startYear = (now.year - 2000) & 0xFF;
  final int startMonth = now.month & 0xFF;
  final int startDay = now.day & 0xFF;
  final int endYear = startYear;
  final int endMonth = startMonth;
  final int endDay = startDay;

  payload.add(startYear);
  payload.add(startMonth);
  payload.add(startDay);
  payload.add(endYear);
  payload.add(endMonth);
  payload.add(endDay);

  // Total dose (big-endian 16-bit)
  payload.add((totalDose >> 8) & 0xFF);
  payload.add(totalDose & 0xFF);

  // Pump speed (default to medium)
  payload.add(SingleDoseEncodingUtils.mapPumpSpeedToByte(PumpSpeed.medium));

  // Checksum
  final int checksum = SingleDoseEncodingUtils.checksumFor(payload.sublist(1));
  payload.add(checksum);

  return Uint8List.fromList(payload);
}
