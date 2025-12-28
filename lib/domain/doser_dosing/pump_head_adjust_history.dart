library;

/// Pump head adjust history entry.
///
/// PARITY: Mirrors reef-b-app Android's DropAdjustHistory data class.
///
/// Represents a single calibration/adjustment history entry for a pump head.
class PumpHeadAdjustHistory {
  /// Time string (e.g., "2025-01-15 14:30:00")
  final String timeString;

  /// Volume in ml (note: reef-b-app uses "vloume" typo, we use "volume")
  final int volume;

  /// Pump rotating speed: 1=low, 2=medium, 3=high
  final int rotatingSpeed;

  const PumpHeadAdjustHistory({
    required this.timeString,
    required this.volume,
    required this.rotatingSpeed,
  }) : assert(rotatingSpeed >= 1 && rotatingSpeed <= 3,
          'rotatingSpeed must be 1-3');

  PumpHeadAdjustHistory copyWith({
    String? timeString,
    int? volume,
    int? rotatingSpeed,
  }) {
    return PumpHeadAdjustHistory(
      timeString: timeString ?? this.timeString,
      volume: volume ?? this.volume,
      rotatingSpeed: rotatingSpeed ?? this.rotatingSpeed,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PumpHeadAdjustHistory &&
        other.timeString == timeString &&
        other.volume == volume &&
        other.rotatingSpeed == rotatingSpeed;
  }

  @override
  int get hashCode => Object.hash(timeString, volume, rotatingSpeed);

  @override
  String toString() =>
      'PumpHeadAdjustHistory(timeString: $timeString, volume: $volume, '
      'rotatingSpeed: $rotatingSpeed)';
}

