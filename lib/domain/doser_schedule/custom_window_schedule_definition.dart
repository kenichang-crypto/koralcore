import '../doser_dosing/pump_speed.dart';
import 'scheduled_dose_trigger.dart';
import 'single_dose_plan.dart';

/// Domain representation of the custom window schedule (BLE opcodes 0x72-0x74).
/// Each event is treated as a single-dose execution that will later be encoded
/// using the shared single-dose helpers.
class CustomWindowScheduleDefinition {
  final String scheduleId;
  final int pumpId;
  final List<ScheduleWindowChunk> chunks;

  CustomWindowScheduleDefinition({
    required this.scheduleId,
    required this.pumpId,
    required List<ScheduleWindowChunk> chunks,
  }) : chunks = List<ScheduleWindowChunk>.unmodifiable(chunks);

  List<SingleDosePlan> buildPlans() {
    final List<SingleDosePlan> plans = <SingleDosePlan>[];
    for (final ScheduleWindowChunk chunk in chunks) {
      for (final WindowDoseEvent event in chunk.events) {
        final ScheduledDoseTrigger trigger = WindowedDoseTrigger(
          windowStartMinute: chunk.windowStartMinute,
          windowEndMinute: chunk.windowEndMinute,
          eventMinuteOffset: event.minuteOffset,
          chunkIndex: chunk.chunkIndex,
        );
        plans.add(
          SingleDosePlan(
            pumpId: pumpId,
            doseMl: event.doseMl,
            speed: event.speed,
            trigger: trigger,
          ),
        );
      }
    }
    return List<SingleDosePlan>.unmodifiable(plans);
  }
}

class ScheduleWindowChunk {
  final int chunkIndex;
  final int windowStartMinute; // minute-of-day [0, 1440]
  final int windowEndMinute; // inclusive end minute-of-day [0, 1440]
  final List<WindowDoseEvent> events;

  ScheduleWindowChunk({
    required this.chunkIndex,
    required this.windowStartMinute,
    required this.windowEndMinute,
    required List<WindowDoseEvent> events,
  }) : assert(windowStartMinute >= 0 && windowStartMinute <= 1440),
       assert(windowEndMinute >= 0 && windowEndMinute <= 1440),
       assert(windowEndMinute >= windowStartMinute),
       events = List<WindowDoseEvent>.unmodifiable(events);
}

class WindowDoseEvent {
  final int minuteOffset; // relative to windowStartMinute
  final double doseMl; // already scaled per SingleDoseEncodingUtils semantics
  final PumpSpeed speed;

  const WindowDoseEvent({
    required this.minuteOffset,
    required this.doseMl,
    required this.speed,
  }) : assert(minuteOffset >= 0, 'minuteOffset must be >= 0');
}
