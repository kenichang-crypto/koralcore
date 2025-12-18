import '../../../../domain/led_lighting/led_custom_schedule.dart';
import 'led_schedule_payload.dart';

LedCustomSchedulePayload buildLedCustomSchedulePayload(
  LedCustomSchedule schedule,
) {
  return LedCustomSchedulePayload(
    start: schedule.start,
    end: schedule.end,
    channels: schedule.channels,
    repeatOn: schedule.repeatOn,
  );
}
