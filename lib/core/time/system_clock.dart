import 'clock.dart';
import 'instant.dart';

class SystemClock extends Clock {
  const SystemClock();

  @override
  Instant now() => Instant.now();
}
