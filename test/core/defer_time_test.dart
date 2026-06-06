import 'package:cleartray/core/defer_time.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a start-of-day defer is shifted to the surface hour, never midnight',
      () {
    final at = deferReminderAt(DateTime(2026, 5, 20), 540);
    expect(at, DateTime(2026, 5, 20, 9));
  });

  test('surface minutes with a non-zero minute component is honoured', () {
    final at = deferReminderAt(DateTime(2026, 5, 20), 545);
    expect(at, DateTime(2026, 5, 20, 9, 5));
  });

  test('an explicit-time defer passes through unchanged', () {
    final defer = DateTime(2026, 5, 20, 14, 30);
    expect(deferReminderAt(defer, 540), defer);
  });

  test('a defer at 00:01 counts as explicit and is not shifted', () {
    final defer = DateTime(2026, 5, 20, 0, 1);
    expect(deferReminderAt(defer, 540), defer);
  });
}
