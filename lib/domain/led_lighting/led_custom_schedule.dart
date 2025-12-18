import 'led_channel_group.dart';
import 'led_spectrum.dart';
import 'time_of_day.dart';
import 'weekday.dart';

/// Custom LED schedule with a fixed spectrum during a time range.
class LedCustomSchedule {
  final LedChannelGroup channelGroup;
  final TimeOfDay start;
  final TimeOfDay end;
  final LedSpectrum spectrum;
  final List<Weekday> repeatOn;

  const LedCustomSchedule({
    required this.channelGroup,
    required this.start,
    required this.end,
    required this.spectrum,
    required this.repeatOn,
  });
}
