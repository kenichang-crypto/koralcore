import '../doser_dosing/pump_speed.dart';
import 'schedule_weekday.dart';
import 'scheduled_dose_trigger.dart';
import 'single_dose_plan.dart';

/// Domain model describing the 24h "average" schedule (BLE opcode 0x70).
///
/// Each slot will map to a single `SingleDosePlan`, and future encoders will
/// serialize those plans using the same single-dose language as opcodes 0x6E
/// and 0x6F.
class DailyAverageScheduleDefinition {
  final String scheduleId;
  final int pumpId;
  final Set<ScheduleWeekday> repeatDays;
  final List<DailyDoseSlot> slots;

  DailyAverageScheduleDefinition({
    required this.scheduleId,
    required this.pumpId,
    required Set<ScheduleWeekday> repeatDays,
    required List<DailyDoseSlot> slots,
  }) : repeatDays = Set<ScheduleWeekday>.unmodifiable(repeatDays),
       slots = List<DailyDoseSlot>.unmodifiable(slots);

  /// Expands high-level slots into discrete single-dose plans.
  List<SingleDosePlan> buildPlans() {
    final List<SingleDosePlan> plans = <SingleDosePlan>[];
    for (final DailyDoseSlot slot in slots) {
      final ScheduledDoseTrigger trigger = DailyTimeTrigger(
        hour: slot.hour,
        minute: slot.minute,
        repeatDays: repeatDays,
      );
      plans.add(
        SingleDosePlan(
          pumpId: pumpId,
          doseMl: slot.doseMl,
          speed: slot.speed,
          trigger: trigger,
        ),
      );
    }
    return List<SingleDosePlan>.unmodifiable(plans);
  }
}

/// Represents a single HH:MM slot inside the daily average program.
class DailyDoseSlot {
  final int hour;
  final int minute;
  final double doseMl;
  final PumpSpeed speed;

  const DailyDoseSlot({
    required this.hour,
    required this.minute,
    required this.doseMl,
    required this.speed,
  }) : assert(hour >= 0 && hour < 24, 'hour must be 0-23'),
       assert(minute >= 0 && minute < 60, 'minute must be 0-59');
}
