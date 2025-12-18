import 'doser_schedule.dart';
import 'schedule_time_models.dart';
import 'weekday.dart';

/// DoserScheduleValidator
///
/// Pure domain validator that verifies invariants of `DoserSchedule`.
/// Returns a list of human-readable error messages; an empty list means valid.
///
/// Reference only to domain rules specified in docs/reef_b_app_behavior.md; no
/// BLE logic lives here.
class DoserScheduleValidator {
  const DoserScheduleValidator._();

  static List<String> validate(DoserSchedule schedule) {
    final errors = <String>[];

    // Common rules
    if (!(schedule.totalDoseMl > 0)) {
      errors.add('totalDoseMl must be > 0');
    }

    if (schedule.distribution.times < 1) {
      errors.add('distribution.times must be >= 1');
    }

    // Type-specific rules
    switch (schedule.type) {
      case var t when t == DoserScheduleType.h24:
        // time must be TimeRange(00:00 ~ 23:59)
        if (schedule.time is! TimeRange) {
          errors.add('h24 schedule time must be a TimeRange');
        } else {
          final tr = schedule.time as TimeRange;
          final start = tr.start;
          final end = tr.end;
          if (!(start.hour == 0 &&
              start.minute == 0 &&
              end.hour == 23 &&
              end.minute == 59)) {
            errors.add('h24 TimeRange must span 00:00 to 23:59');
          }
        }

        if (schedule.distribution.times != 24) {
          errors.add('h24 distribution.times must equal 24');
        }

        if (schedule.repeat == null) {
          errors.add('h24 schedule repeat must be defined (Mon–Sun)');
        } else {
          final allWeekdays = Weekday.values.toSet();
          if (schedule.repeat!.days.length != allWeekdays.length ||
              !schedule.repeat!.days.containsAll(allWeekdays)) {
            errors.add('h24 repeat.days must include all days Monday–Sunday');
          }
        }
        break;

      case var t when t == DoserScheduleType.custom:
        // time must be TimeRange
        if (schedule.time is! TimeRange) {
          errors.add('custom schedule time must be a TimeRange');
        }

        // distribution.times >= 1 already checked above

        // repeat.days must not be empty
        if (schedule.repeat == null || schedule.repeat!.days.isEmpty) {
          errors.add('custom schedule repeat.days must not be empty');
        }
        break;

      case var t when t == DoserScheduleType.oneshotSchedule:
        // time must be FixedTime
        if (schedule.time is! FixedTime) {
          errors.add('oneshotSchedule time must be a FixedTime');
        }

        if (schedule.distribution.times != 1) {
          errors.add('oneshotSchedule distribution.times must equal 1');
        }

        if (schedule.repeat != null) {
          errors.add('oneshotSchedule repeat must be null');
        }
        break;
    }

    return errors;
  }
}
