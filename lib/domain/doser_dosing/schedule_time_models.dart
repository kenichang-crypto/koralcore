import 'time_of_day.dart';

/// Abstract ScheduleTime
///
/// Represents scheduling time information derived from docs definitions.
/// Concrete implementations:
/// - TimeRange(start, end) → used by h24 / custom schedules (BLE 24h/custom)
/// - FixedTime(at) → used by oneshotSchedule (BLE 32–34 sequence)
///
/// TODO(BLE-MAPPING): Provide translation helpers outside domain to convert
/// these value objects to raw BLE payload structures when constructing commands.
abstract class ScheduleTime {
  const ScheduleTime();
}

/// TimeRange: repetitive window between start and end times.
class TimeRange extends ScheduleTime {
  final TimeOfDay start;
  final TimeOfDay end;

  const TimeRange({required this.start, required this.end});

  @override
  String toString() => 'TimeRange(start: $start, end: $end)';
}

/// FixedTime: single fixed time in day.
class FixedTime extends ScheduleTime {
  final TimeOfDay at;

  const FixedTime({required this.at});

  @override
  String toString() => 'FixedTime(at: $at)';
}
