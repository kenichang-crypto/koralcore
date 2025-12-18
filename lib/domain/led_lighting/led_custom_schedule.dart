import 'time_of_day.dart';
import 'weekday.dart';
import 'led_channel_value.dart';

/// Custom LED schedule with a fixed spectrum during a time range.
class LedCustomSchedule {
  final TimeOfDay start;
  final TimeOfDay end;
  final List<LedChannelValue> channels;
  final List<Weekday> repeatOn;

  const LedCustomSchedule({
    required this.start,
    required this.end,
    required this.channels,
    required this.repeatOn,
  });
}
