library;

/// Represents a single LED record (hour/minute intensity snapshot).
class LedRecord {
  final String id;
  final int minutesFromMidnight;
  final Map<String, int> channelLevels;
  final bool isPreviewing;

  LedRecord({
    required this.id,
    required int minutesFromMidnight,
    required Map<String, int> channelLevels,
    this.isPreviewing = false,
  }) : assert(
         minutesFromMidnight >= 0 && minutesFromMidnight < 1440,
         'Minutes must be within a single day.',
       ),
       minutesFromMidnight = minutesFromMidnight,
       channelLevels = Map<String, int>.unmodifiable(channelLevels);

  int get hour => minutesFromMidnight ~/ 60;
  int get minute => minutesFromMidnight % 60;

  LedRecord copyWith({
    String? id,
    int? minutesFromMidnight,
    Map<String, int>? channelLevels,
    bool? isPreviewing,
  }) {
    return LedRecord(
      id: id ?? this.id,
      minutesFromMidnight: minutesFromMidnight ?? this.minutesFromMidnight,
      channelLevels: channelLevels ?? this.channelLevels,
      isPreviewing: isPreviewing ?? this.isPreviewing,
    );
  }
}
