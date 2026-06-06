import 'package:cleartray/application/check_exact_alarm_permission.dart';
import 'package:cleartray/core/result.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';

class _ThrowingScheduler extends FakeNotificationScheduler {
  @override
  Future<bool> canScheduleExactAlarms() async =>
      throw Exception('platform channel blew up');
}

void main() {
  late FakeNotificationScheduler scheduler;
  late CheckExactAlarmPermission check;

  setUp(() {
    scheduler = FakeNotificationScheduler();
    check = CheckExactAlarmPermission(scheduler: scheduler);
  });

  test('passes through granted exact-alarm access', () async {
    scheduler.exactAlarmsAllowed = true;

    final r = await check();

    expect(r, isA<Ok<bool, String>>());
    expect((r as Ok).value, isTrue);
  });

  test('passes through blocked exact-alarm access', () async {
    scheduler.exactAlarmsAllowed = false;

    final r = await check();

    expect(r, isA<Ok<bool, String>>());
    expect((r as Ok).value, isFalse);
  });

  test('wraps a platform-channel failure as Err', () async {
    check = CheckExactAlarmPermission(scheduler: _ThrowingScheduler());

    final r = await check();

    expect(r, isA<Err<bool, String>>());
    expect((r as Err).error, contains('platform channel blew up'));
  });
}
