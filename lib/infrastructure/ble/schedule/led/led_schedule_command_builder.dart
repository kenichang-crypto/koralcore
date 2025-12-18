import '../../../../domain/led_lighting/led_schedule.dart';
import '../../../../domain/led_lighting/led_schedule_type.dart';

import 'led_custom_schedule_builder.dart';
import 'led_daily_schedule_builder.dart';
import 'led_scene_schedule_builder.dart';
import 'led_schedule_payload.dart';

/// Converts `LedSchedule` instances into BLE-ready payload models.
class LedScheduleCommandBuilder {
  const LedScheduleCommandBuilder();

  LedSchedulePayload build(LedSchedule schedule) {
    switch (schedule.type) {
      case LedScheduleType.daily:
        final daily = schedule.daily;
        if (daily == null) {
          throw StateError('LedSchedule.type=daily requires daily data');
        }
        return buildLedDailySchedulePayload(daily);

      case LedScheduleType.custom:
        final custom = schedule.custom;
        if (custom == null) {
          throw StateError('LedSchedule.type=custom requires custom data');
        }
        return buildLedCustomSchedulePayload(custom);

      case LedScheduleType.scene:
        final scene = schedule.scene;
        if (scene == null) {
          throw StateError('LedSchedule.type=scene requires scene data');
        }
        return buildLedSceneSchedulePayload(scene);
    }
  }
}
