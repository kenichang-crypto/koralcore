class TimeError implements Exception {
  final String message;
  const TimeError(this.message);

  @override
  String toString() => 'TimeError: $message';
}
