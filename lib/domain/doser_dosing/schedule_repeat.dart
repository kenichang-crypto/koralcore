import 'weekday.dart';

/// ScheduleRepeat
///
/// Represents repetition settings for schedules.
class ScheduleRepeat {
  final Set<Weekday> days;

  const ScheduleRepeat({required this.days});

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ScheduleRepeat && other.days == days;

  @override
  int get hashCode => days.hashCode;

  @override
  String toString() => 'ScheduleRepeat(days: $days)';
}
