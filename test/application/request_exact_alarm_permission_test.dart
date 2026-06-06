import 'package:cleartray/application/request_exact_alarm_permission.dart';
import 'package:cleartray/core/result.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';

class _ThrowingScheduler extends FakeNotificationScheduler {
  @override
  Future<bool> requestExactAlarmsPermission() async =>
      throw Exception('platform channel blew up');
}

void main() {
  late FakeNotificationScheduler scheduler;
  late RequestExactAlarmPermission request;

  setUp(() {
    scheduler = FakeNotificationScheduler();
    request = RequestExactAlarmPermission(scheduler: scheduler);
  });

  test('returns granted and records the request', () async {
    scheduler.exactAlarmsAllowed = true;

    final r = await request();

    expect(r, isA<Ok<bool, String>>());
    expect((r as Ok).value, isTrue);
    expect(scheduler.exactAlarmRequestCount, 1);
  });

  test('returns blocked and records the request', () async {
    scheduler.exactAlarmsAllowed = false;

    final r = await request();

    expect(r, isA<Ok<bool, String>>());
    expect((r as Ok).value, isFalse);
    expect(scheduler.exactAlarmRequestCount, 1);
  });

  test('wraps a platform-channel failure as Err', () async {
    request = RequestExactAlarmPermission(scheduler: _ThrowingScheduler());

    final r = await request();

    expect(r, isA<Err<bool, String>>());
    expect((r as Err).error, contains('platform channel blew up'));
  });
}
