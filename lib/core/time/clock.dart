import 'instant.dart';

/// Abstract clock used by the platform.
abstract class Clock {
  const Clock();

  Instant now();
}
