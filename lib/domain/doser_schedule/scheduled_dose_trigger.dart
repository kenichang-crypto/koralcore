import 'schedule_weekday.dart';

/// Marker interface describing when a single-dose plan should be executed.
///
/// Encoders (0x6E/0x6F today, 0x70/0x72-0x74 soon) will translate concrete
/// triggers into opcode-specific bytes. Keeping timing metadata here ensures
/// the domain layer stays byte-agnostic.
abstract class ScheduledDoseTrigger {
  const ScheduledDoseTrigger();
}

/// Trigger representing a repeated daily time (HH:MM) with an optional
/// week-day repeat mask. Used by 24h average schedules (opcode 0x70).
class DailyTimeTrigger extends ScheduledDoseTrigger {
  final int hour;
  final int minute;
  final Set<ScheduleWeekday> repeatDays;

  const DailyTimeTrigger({
    required this.hour,
    required this.minute,
    required this.repeatDays,
  }) : assert(hour >= 0 && hour < 24, 'hour must be 0-23'),
       assert(minute >= 0 && minute < 60, 'minute must be 0-59');
}

/// Trigger representing a windowed execution (custom schedules 0x72-0x74).
/// `windowStartMinute`/`windowEndMinute` model the day window (0-1440),
/// while `eventMinuteOffset` specifies when inside that window to fire.
class WindowedDoseTrigger extends ScheduledDoseTrigger {
  final int windowStartMinute;
  final int windowEndMinute;
  final int eventMinuteOffset;
  final int chunkIndex;

  const WindowedDoseTrigger({
    required this.windowStartMinute,
    required this.windowEndMinute,
    required this.eventMinuteOffset,
    required this.chunkIndex,
  }) : assert(windowStartMinute >= 0 && windowStartMinute <= 1440),
       assert(windowEndMinute >= 0 && windowEndMinute <= 1440),
       assert(windowEndMinute >= windowStartMinute),
       assert(
         eventMinuteOffset >= 0,
         'eventMinuteOffset must be >= 0 relative to window start',
       );
}
