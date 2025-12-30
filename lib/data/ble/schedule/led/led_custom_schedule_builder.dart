import '../../../../domain/led_lighting/led_custom_schedule.dart';
import 'led_schedule_payload.dart';

LedCustomSchedulePayload buildLedCustomSchedulePayload(
  LedCustomSchedule schedule,
) {
  return LedCustomSchedulePayload(
    channelGroup: schedule.channelGroup,
    start: schedule.start,
    end: schedule.end,
    spectrum: schedule.spectrum,
    repeatOn: schedule.repeatOn,
  );
}
