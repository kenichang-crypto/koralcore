import 'clock.dart';
import 'system_clock.dart';

class TimeProvider {
  Clock _clock;

  TimeProvider({Clock? clock}) : _clock = clock ?? const SystemClock();

  Clock get clock => _clock;

  void overrideClock(Clock clock) {
    _clock = clock;
  }
}
