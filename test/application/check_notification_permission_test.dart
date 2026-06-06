import 'package:cleartray/application/check_notification_permission.dart';
import 'package:cleartray/core/notification_scheduler.dart';
import 'package:cleartray/core/result.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';

void main() {
  late FakeNotificationScheduler scheduler;
  late CheckNotificationPermission check;

  setUp(() {
    scheduler = FakeNotificationScheduler();
    check = CheckNotificationPermission(scheduler: scheduler);
  });

  for (final s in NotificationPermission.values) {
    test('maps $s through without prompting', () async {
      scheduler.status = s;

      final r = await check();

      expect(r, isA<Ok<NotificationPermission, String>>());
      expect((r as Ok).value, s);
      // Querying status must never trigger the OS prompt.
      expect(scheduler.requestCount, 0);
    });
  }
}
