import '../../../domain/doser_dosing/pump_speed.dart';
import '../../../domain/doser_schedule/custom_window_schedule_definition.dart';

CustomWindowScheduleDefinition buildSampleCustomWindowSchedule() {
  return CustomWindowScheduleDefinition(
    scheduleId: 'sample-custom-schedule',
    pumpId: 0x01,
    chunks: <ScheduleWindowChunk>[
      ScheduleWindowChunk(
        chunkIndex: 0,
        windowStartMinute: 60,
        windowEndMinute: 180,
        events: <WindowDoseEvent>[
          const WindowDoseEvent(
            minuteOffset: 0,
            doseMl: 5.0,
            speed: PumpSpeed.low,
          ),
          const WindowDoseEvent(
            minuteOffset: 45,
            doseMl: 6.5,
            speed: PumpSpeed.medium,
          ),
        ],
      ),
      ScheduleWindowChunk(
        chunkIndex: 1,
        windowStartMinute: 300,
        windowEndMinute: 420,
        events: <WindowDoseEvent>[
          const WindowDoseEvent(
            minuteOffset: 10,
            doseMl: 7.0,
            speed: PumpSpeed.high,
          ),
        ],
      ),
      ScheduleWindowChunk(
        chunkIndex: 2,
        windowStartMinute: 600,
        windowEndMinute: 720,
        events: <WindowDoseEvent>[
          const WindowDoseEvent(
            minuteOffset: 5,
            doseMl: 4.0,
            speed: PumpSpeed.low,
          ),
        ],
      ),
    ],
  );
}
