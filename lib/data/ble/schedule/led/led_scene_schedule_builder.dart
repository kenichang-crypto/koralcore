import '../../../../domain/led_lighting/led_scene_schedule.dart';
import 'led_schedule_payload.dart';

LedSceneSchedulePayload buildLedSceneSchedulePayload(
  LedSceneSchedule schedule,
) {
  return LedSceneSchedulePayload(
    scene: schedule.scene,
    start: schedule.start,
    end: schedule.end,
    repeatOn: schedule.repeatOn,
  );
}
