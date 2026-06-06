import 'package:flutter_riverpod/flutter_riverpod.dart';

/// An injectable wall-clock. Replace in tests with [FakeClock].
abstract class Clock {
  const Clock();
  DateTime now();
}

class SystemClock extends Clock {
  const SystemClock();
  @override
  DateTime now() => DateTime.now();
}

class FakeClock extends Clock {
  FakeClock(this._now);
  DateTime _now;
  void advance(Duration d) => _now = _now.add(d);
  void setTo(DateTime t) => _now = t;
  @override
  DateTime now() => _now;
}

final clockProvider = Provider<Clock>((ref) => const SystemClock());
