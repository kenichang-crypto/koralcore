import 'clock.dart';
import 'instant.dart';

class FixedClock extends Clock {
  Instant _current;

  FixedClock(this._current);

  @override
  Instant now() => _current;

  void advance(Duration delta) {
    _current = Instant(_current.value.add(delta));
  }
}
