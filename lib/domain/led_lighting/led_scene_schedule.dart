import 'time_of_day.dart';
import 'weekday.dart';
import 'led_scene.dart';

/// Schedule that applies a predefined LED scene during a time range.
class LedSceneSchedule {
  final LedScene scene;
  final TimeOfDay start;
  final TimeOfDay end;
  final List<Weekday> repeatOn;

  const LedSceneSchedule({
    required this.scene,
    required this.start,
    required this.end,
    required this.repeatOn,
  });
}
