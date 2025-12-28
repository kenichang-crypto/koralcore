library;

/// Pump head record detail for custom schedules.
///
/// PARITY: Mirrors reef-b-app Android's DropHeadRecordDetail data class.
///
/// Represents a single detail entry within a custom schedule, containing
/// time range, drop count, total volume, and pump speed.
class PumpHeadRecordDetail {
  /// Time range string (e.g., "08:00 ~ 10:00")
  final String? timeString;

  /// Number of drops in this interval
  final int dropTime;

  /// Total drop volume
  final int totalDrop;

  /// Pump rotating speed: 1=low, 2=medium, 3=high
  final int rotatingSpeed;

  const PumpHeadRecordDetail({
    this.timeString,
    required this.dropTime,
    required this.totalDrop,
    this.rotatingSpeed = 2,
  }) : assert(rotatingSpeed >= 1 && rotatingSpeed <= 3,
          'rotatingSpeed must be 1-3');

  PumpHeadRecordDetail copyWith({
    String? timeString,
    int? dropTime,
    int? totalDrop,
    int? rotatingSpeed,
  }) {
    return PumpHeadRecordDetail(
      timeString: timeString ?? this.timeString,
      dropTime: dropTime ?? this.dropTime,
      totalDrop: totalDrop ?? this.totalDrop,
      rotatingSpeed: rotatingSpeed ?? this.rotatingSpeed,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PumpHeadRecordDetail &&
        other.timeString == timeString &&
        other.dropTime == dropTime &&
        other.totalDrop == totalDrop &&
        other.rotatingSpeed == rotatingSpeed;
  }

  @override
  int get hashCode =>
      Object.hash(timeString, dropTime, totalDrop, rotatingSpeed);

  @override
  String toString() =>
      'PumpHeadRecordDetail(timeString: $timeString, dropTime: $dropTime, '
      'totalDrop: $totalDrop, rotatingSpeed: $rotatingSpeed)';
}

