import 'dart:typed_data';

import '../../../../domain/led_lighting/led_custom_schedule.dart';
import '../../../../domain/led_lighting/led_daily_schedule.dart';
import '../../../../domain/led_lighting/led_scene_schedule.dart';
import 'led_schedule_payload.dart';
import '../../encoder/led/led_custom_schedule_encoder.dart';
import '../../encoder/led/led_daily_schedule_encoder.dart';
import '../../encoder/led/led_scene_schedule_encoder.dart';

/// Encodes LED schedule payload models into raw BLE bytes.
Uint8List encodeLedSchedulePayload(LedSchedulePayload payload) {
  if (payload is LedDailySchedulePayload) {
    final LedDailySchedule schedule = LedDailySchedule(
      channelGroup: payload.channelGroup,
      points: payload.points
          .map(
            (LedDailyPointPayload point) =>
                LedDailyPoint(time: point.time, spectrum: point.spectrum),
          )
          .toList(growable: false),
      repeatOn: payload.repeatOn,
    );
    return const LedDailyScheduleEncoder().encode(schedule);
  }

  if (payload is LedCustomSchedulePayload) {
    final LedCustomSchedule schedule = LedCustomSchedule(
      channelGroup: payload.channelGroup,
      start: payload.start,
      end: payload.end,
      spectrum: payload.spectrum,
      repeatOn: payload.repeatOn,
    );
    return const LedCustomScheduleEncoder().encode(schedule);
  }

  if (payload is LedSceneSchedulePayload) {
    final LedSceneSchedule schedule = LedSceneSchedule(
      scene: payload.scene,
      start: payload.start,
      end: payload.end,
      repeatOn: payload.repeatOn,
    );
    return const LedSceneScheduleEncoder().encode(schedule);
  }

  throw UnsupportedError('Unknown LED schedule payload: $payload');
}
