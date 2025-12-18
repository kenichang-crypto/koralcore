import 'led_channel_group.dart';
import 'led_spectrum.dart';
import 'time_of_day.dart';
import 'weekday.dart';

/// A single time point in a daily LED schedule.
class LedDailyPoint {
  final TimeOfDay time;
  final LedSpectrum spectrum;

  const LedDailyPoint({required this.time, required this.spectrum});
}

/// Daily LED schedule consisting of multiple time points.
class LedDailySchedule {
  final LedChannelGroup channelGroup;
  final List<LedDailyPoint> points;
  final List<Weekday> repeatOn;

  const LedDailySchedule({
    required this.channelGroup,
    required this.points,
    required this.repeatOn,
  });
}
