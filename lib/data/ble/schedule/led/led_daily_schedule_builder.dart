import '../../../../domain/led_lighting/led_daily_schedule.dart';
import 'led_schedule_payload.dart';

LedDailySchedulePayload buildLedDailySchedulePayload(
  LedDailySchedule schedule,
) {
  final points = schedule.points
      .map(
        (point) =>
            LedDailyPointPayload(time: point.time, spectrum: point.spectrum),
      )
      .toList(growable: false);

  return LedDailySchedulePayload(
    channelGroup: schedule.channelGroup,
    points: points,
    repeatOn: schedule.repeatOn,
  );
}
