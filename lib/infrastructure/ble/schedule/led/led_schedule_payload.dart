import '../../../../domain/led_lighting/led_channel_value.dart';
import '../../../../domain/led_lighting/led_scene.dart';
import '../../../../domain/led_lighting/time_of_day.dart';
import '../../../../domain/led_lighting/weekday.dart';

/// Base payload marker for LED schedule commands.
abstract class LedSchedulePayload {
  const LedSchedulePayload();
}

class LedDailySchedulePayload extends LedSchedulePayload {
  final List<LedDailyPointPayload> points;
  final List<Weekday> repeatOn;

  const LedDailySchedulePayload({required this.points, required this.repeatOn});
}

class LedDailyPointPayload {
  final TimeOfDay time;
  final List<LedChannelValue> channels;

  const LedDailyPointPayload({required this.time, required this.channels});
}

class LedCustomSchedulePayload extends LedSchedulePayload {
  final TimeOfDay start;
  final TimeOfDay end;
  final List<LedChannelValue> channels;
  final List<Weekday> repeatOn;

  const LedCustomSchedulePayload({
    required this.start,
    required this.end,
    required this.channels,
    required this.repeatOn,
  });
}

class LedSceneSchedulePayload extends LedSchedulePayload {
  final LedScene scene;
  final TimeOfDay start;
  final TimeOfDay end;
  final List<Weekday> repeatOn;

  const LedSceneSchedulePayload({
    required this.scene,
    required this.start,
    required this.end,
    required this.repeatOn,
  });
}
