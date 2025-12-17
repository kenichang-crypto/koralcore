/// Platform-level instant in time.
/// Wrapper to avoid leaking DateTime everywhere.
class Instant {
  final DateTime value;

  const Instant(this.value);

  static Instant now() => Instant(DateTime.now());

  @override
  String toString() => value.toIso8601String();
}
