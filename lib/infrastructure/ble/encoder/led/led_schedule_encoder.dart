import 'dart:typed_data';

import '../../../../domain/led_lighting/led_schedule.dart';
import '../../../../domain/led_lighting/led_schedule_type.dart';
import 'led_custom_schedule_encoder.dart';
import 'led_daily_schedule_encoder.dart';
import 'led_scene_schedule_encoder.dart';

class LedScheduleEncoder {
  final LedDailyScheduleEncoder dailyEncoder;
  final LedCustomScheduleEncoder customEncoder;
  final LedSceneScheduleEncoder sceneEncoder;

  const LedScheduleEncoder({
    this.dailyEncoder = const LedDailyScheduleEncoder(),
    this.customEncoder = const LedCustomScheduleEncoder(),
    this.sceneEncoder = const LedSceneScheduleEncoder(),
  });

  Uint8List encode(LedSchedule schedule) {
    switch (schedule.type) {
      case LedScheduleType.daily:
        final daily = schedule.daily;
        if (daily == null) {
          throw StateError('LedSchedule.type=daily requires daily data.');
        }
        return dailyEncoder.encode(daily);
      case LedScheduleType.custom:
        final custom = schedule.custom;
        if (custom == null) {
          throw StateError('LedSchedule.type=custom requires custom data.');
        }
        return customEncoder.encode(custom);
      case LedScheduleType.scene:
        final scene = schedule.scene;
        if (scene == null) {
          throw StateError('LedSchedule.type=scene requires scene data.');
        }
        return sceneEncoder.encode(scene);
    }
  }
}
