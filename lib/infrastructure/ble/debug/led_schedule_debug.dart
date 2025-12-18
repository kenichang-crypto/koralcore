import 'dart:typed_data';

import '../../domain/led_lighting/led_channel.dart';
import '../../domain/led_lighting/led_channel_group.dart';
import '../../domain/led_lighting/led_channel_value.dart';
import '../../domain/led_lighting/led_custom_schedule.dart';
import '../../domain/led_lighting/led_daily_schedule.dart';
import '../../domain/led_lighting/led_intensity.dart';
import '../../domain/led_lighting/led_scene.dart';
import '../../domain/led_lighting/led_scene_schedule.dart';
import '../../domain/led_lighting/led_spectrum.dart';
import '../../domain/led_lighting/time_of_day.dart';
import '../../domain/led_lighting/weekday.dart';
import '../encoder/led/led_custom_schedule_encoder.dart';
import '../encoder/led/led_daily_schedule_encoder.dart';
import '../encoder/led/led_scene_schedule_encoder.dart';
import '../verification/encoder_verifier.dart';

/// Exerciser for the LED encoders that mirrors the dosing debug hooks.
class LedScheduleDebug {
  const LedScheduleDebug();

  EncoderVerificationReport runDailyScheduleSelfTest() {
    final LedDailySchedule schedule = LedDailySchedule(
      channelGroup: LedChannelGroup.fullSpectrum,
      points: <LedDailyPoint>[
        LedDailyPoint(
          time: const TimeOfDay(hour: 9, minute: 0),
          spectrum: _spectrum(<int>[120, 80, 64, 90, 45]),
        ),
        LedDailyPoint(
          time: const TimeOfDay(hour: 15, minute: 30),
          spectrum: _spectrum(<int>[180, 160, 140, 200, 110]),
        ),
      ],
      repeatOn: const <Weekday>[Weekday.mon, Weekday.wed, Weekday.fri],
    );

    final Uint8List payload = const LedDailyScheduleEncoder().encode(schedule);
    return verifyLedDailySchedule(
      expectedPayload: payload,
      actualPayload: payload,
    );
  }

  EncoderVerificationReport runCustomScheduleSelfTest() {
    final LedCustomSchedule schedule = LedCustomSchedule(
      channelGroup: LedChannelGroup.fullSpectrum,
      start: const TimeOfDay(hour: 18, minute: 0),
      end: const TimeOfDay(hour: 22, minute: 0),
      spectrum: _spectrum(<int>[50, 75, 190, 210, 80]),
      repeatOn: const <Weekday>[Weekday.tue, Weekday.thu],
    );

    final Uint8List payload = const LedCustomScheduleEncoder().encode(schedule);
    return verifyLedCustomSchedule(
      expectedPayload: payload,
      actualPayload: payload,
    );
  }

  EncoderVerificationReport runSceneScheduleSelfTest() {
    final LedScene scene = LedScene(
      presetId: 0x05,
      sceneId: 'sunset',
      name: 'Sunset Fade',
      spectrum: _spectrum(<int>[255, 140, 80, 60, 20]),
    );

    final LedSceneSchedule schedule = LedSceneSchedule(
      scene: scene,
      start: const TimeOfDay(hour: 19, minute: 30),
      end: const TimeOfDay(hour: 21, minute: 0),
      repeatOn: const <Weekday>[Weekday.sat, Weekday.sun],
    );

    final Uint8List payload = const LedSceneScheduleEncoder().encode(schedule);
    return verifyLedSceneSchedule(
      expectedPayload: payload,
      actualPayload: payload,
    );
  }

  LedSpectrum _spectrum(List<int> values) {
    if (values.length != LedChannelGroup.fullSpectrum.channelOrder.length) {
      throw ArgumentError(
        'Spectrum requires ${LedChannelGroup.fullSpectrum.channelOrder.length} values.',
      );
    }
    final List<LedChannelValue> channels = <LedChannelValue>[];
    for (int i = 0; i < values.length; i++) {
      channels.add(
        LedChannelValue(
          channel: LedChannelGroup.fullSpectrum.channelOrder[i],
          intensity: LedIntensity(values[i]),
        ),
      );
    }
    return LedSpectrum(
      channelGroup: LedChannelGroup.fullSpectrum,
      channels: channels,
    );
  }
}
