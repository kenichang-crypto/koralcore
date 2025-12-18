/// TimeOfDay
///
/// Lightweight domain representation of a time-of-day (hour/minute).
/// Pure data model; not dependent on Flutter.
class TimeOfDay {
  final int hour; // 0-23
  final int minute; // 0-59

  const TimeOfDay({required this.hour, required this.minute});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimeOfDay && other.hour == hour && other.minute == minute;

  @override
  int get hashCode => Object.hash(hour, minute);

  @override
  String toString() => 'TimeOfDay($hour:${minute.toString().padLeft(2, '0')})';
}
