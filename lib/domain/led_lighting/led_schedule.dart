import 'led_schedule_type.dart';
import 'led_daily_schedule.dart';
import 'led_custom_schedule.dart';
import 'led_scene_schedule.dart';

/// Root aggregate for LED scheduling.
///
/// Exactly one of [daily], [custom], or [scene] should be non-null,
/// depending on [type].
class LedSchedule {
  final LedScheduleType type;

  final LedDailySchedule? daily;
  final LedCustomSchedule? custom;
  final LedSceneSchedule? scene;

  const LedSchedule({
    required this.type,
    this.daily,
    this.custom,
    this.scene,
  });
}
