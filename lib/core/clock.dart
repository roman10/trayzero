import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// An injectable wall-clock. Replace in tests with [FakeClock].
abstract class Clock {
  const Clock();
  DateTime now();

  /// Wake up at a wall-clock transition. Returns a cancellation function.
  /// Keeping scheduling alongside now() lets FakeClock advance both together.
  void Function() scheduleAt(DateTime at, void Function() callback) {
    final timer = Timer(at.difference(now()), callback);
    return timer.cancel;
  }
}

class SystemClock extends Clock {
  const SystemClock();
  @override
  DateTime now() => DateTime.now();
}

class FakeClock extends Clock {
  FakeClock(this._now);
  DateTime _now;
  int _alarmId = 0;
  final _alarms = <int, ({DateTime at, void Function() callback})>{};

  void advance(Duration d) => setTo(_now.add(d));
  void setTo(DateTime t) {
    _now = t;
    while (true) {
      final due = _alarms.entries.where((e) => !e.value.at.isAfter(_now)).toList()
        ..sort((a, b) => a.value.at.compareTo(b.value.at));
      if (due.isEmpty) break;
      final alarm = due.first;
      _alarms.remove(alarm.key);
      alarm.value.callback();
    }
  }

  @override
  void Function() scheduleAt(DateTime at, void Function() callback) {
    final id = _alarmId++;
    _alarms[id] = (at: at, callback: callback);
    return () {
      _alarms.remove(id);
    };
  }

  @override
  DateTime now() => _now;
}

final clockProvider = Provider<Clock>((ref) => const SystemClock());
