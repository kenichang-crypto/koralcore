import 'time_of_day.dart';
import 'weekday.dart';
import 'led_channel_value.dart';

/// A single time point in a daily LED schedule.
class LedDailyPoint {
  final TimeOfDay time;
  final List<LedChannelValue> channels;

  const LedDailyPoint({required this.time, required this.channels});
}

/// Daily LED schedule consisting of multiple time points.
class LedDailySchedule {
  final List<LedDailyPoint> points;
  final List<Weekday> repeatOn;

  const LedDailySchedule({required this.points, required this.repeatOn});
}
