import 'dart:typed_data';

import '../../../domain/doser_dosing/doser_schedule.dart';
import '../../../domain/doser_dosing/doser_schedule_type.dart';
import '../../../domain/doser_dosing/schedule_time_models.dart';
import '../../../domain/doser_dosing/encoder/single_dose_encoding_utils.dart';
import '../../../domain/doser_dosing/pump_speed.dart';

/// Builds the BLE payload for oneshot schedule (opcode 0x6F - Single Drop Timely).
///
/// Note: Despite the name "oneshotSchedule", this actually uses opcode 0x6F
/// (Single Drop Timely), not 0x32-0x34 (which are LED dimming commands).
///
/// Based on reef-b-app CommandManager.getDropSingleTimelyCommand().
///
/// Format:
/// - 0x6F: Opcode
/// - 0x09: Data length
/// - pumpId: Pump number (0-255)
/// - year: Year - 2000 (e.g., 2025 → 25)
/// - month: Calendar month (1-12)
/// - day: Calendar day (1-31)
/// - hour: 24-hour hour (0-23)
/// - minute: Minute (0-59)
/// - volume_H: High byte of volume (ml × 10, big-endian)
/// - volume_L: Low byte of volume
/// - speed: Pump speed (0x01=low, 0x02=medium, 0x03=high)
/// - checksum: Sum of bytes 2-10, modulo 256
Uint8List buildOneshotScheduleCommand(DoserSchedule schedule) {
  if (schedule.type != DoserScheduleType.oneshotSchedule) {
    throw ArgumentError.value(
      schedule.type,
      'schedule.type',
      'Expected DoserScheduleType.oneshotSchedule, got ${schedule.type}',
    );
  }

  if (schedule.time is! FixedTime) {
    throw ArgumentError.value(
      schedule.time,
      'schedule.time',
      'Oneshot schedule requires FixedTime',
    );
  }

  if (schedule.repeat != null) {
    throw ArgumentError.value(
      schedule.repeat,
      'schedule.repeat',
      'Oneshot schedule must have null repeat',
    );
  }

  final FixedTime fixedTime = schedule.time as FixedTime;
  final List<int> payload = <int>[];
  final int pumpId = schedule.pumpId;
  final int totalDose = SingleDoseEncodingUtils.scaleDoseMlToTenths(
    schedule.totalDoseMl,
  );

  payload.add(0x6F); // Opcode
  payload.add(0x09); // Data length
  payload.add(pumpId & 0xFF);

  // Extract date/time from FixedTime
  // Note: FixedTime only contains TimeOfDay, not DateTime.
  // For oneshot schedules, we need a full DateTime. This is a limitation
  // of the current domain model. In practice, the caller should provide
  // a DateTime through schedule metadata or a different mechanism.
  // For now, we'll use the current date as a placeholder.
  final DateTime now = DateTime.now();
  final int year = (now.year - 2000) & 0xFF;
  final int month = now.month & 0xFF;
  final int day = now.day & 0xFF;
  final int hour = fixedTime.at.hour & 0xFF;
  final int minute = fixedTime.at.minute & 0xFF;

  payload.add(year);
  payload.add(month);
  payload.add(day);
  payload.add(hour);
  payload.add(minute);

  // Total dose (big-endian 16-bit)
  payload.add((totalDose >> 8) & 0xFF);
  payload.add(totalDose & 0xFF);

  // Pump speed (default to medium)
  // Note: This should be extracted from schedule metadata if available
  payload.add(SingleDoseEncodingUtils.mapPumpSpeedToByte(PumpSpeed.medium));

  // Checksum (sum of bytes 2-10, modulo 256)
  final int checksum = SingleDoseEncodingUtils.checksumFor(
    payload.sublist(1),
  );
  payload.add(checksum);

  return Uint8List.fromList(payload);
}
