import 'package:cleartray/application/request_notification_permission.dart';
import 'package:cleartray/core/notification_scheduler.dart';
import 'package:cleartray/core/result.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';

void main() {
  late FakeNotificationScheduler scheduler;
  late RequestNotificationPermission requestPermission;

  setUp(() {
    scheduler = FakeNotificationScheduler();
    requestPermission = RequestNotificationPermission(scheduler: scheduler);
  });

  test('passes the resulting state through and marks the request', () async {
    scheduler.status = NotificationPermission.granted;

    final r = await requestPermission();

    expect(r, isA<Ok<NotificationPermission, String>>());
    expect((r as Ok).value, NotificationPermission.granted);
    expect(scheduler.requestCount, 1);
  });

  test('surfaces denied without collapsing it to a bool', () async {
    scheduler.status = NotificationPermission.denied;

    final r = await requestPermission();

    expect((r as Ok).value, NotificationPermission.denied);
    expect(scheduler.requestCount, 1);
  });

  test('surfaces permanentlyDenied (the state a bool could not express)',
      () async {
    scheduler.status = NotificationPermission.permanentlyDenied;

    final r = await requestPermission();

    expect((r as Ok).value, NotificationPermission.permanentlyDenied);
  });

  test('delegates to the scheduler exactly once', () async {
    expect(scheduler.requestCount, 0);
    await requestPermission();
    expect(scheduler.requestCount, 1);
  });
}
