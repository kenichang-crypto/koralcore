/// Domain value object representing a time of day.
///
/// - Pure domain model
/// - No validation, parsing, formatting, or UI dependency
/// - Independent from Flutter's TimeOfDay
class TimeOfDay {
  final int hour; // expected 0–23 (not enforced here)
  final int minute; // expected 0–59 (not enforced here)

  const TimeOfDay({required this.hour, required this.minute});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimeOfDay &&
          runtimeType == other.runtimeType &&
          hour == other.hour &&
          minute == other.minute;

  @override
  int get hashCode => hour.hashCode ^ minute.hashCode;

  @override
  String toString() => 'TimeOfDay(hour: $hour, minute: $minute)';
}
