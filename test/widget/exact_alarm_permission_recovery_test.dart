import 'package:cleartray/core/notification_scheduler.dart';
import 'package:cleartray/features/common/exact_alarm_permission_recovery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

class _Host extends ConsumerWidget {
  const _Host();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => runExactAlarmPermissionRecovery(context, ref),
          child: const Text('Recover'),
        ),
      ),
    );
  }
}

class _GrantingScheduler extends FakeNotificationScheduler {
  @override
  Future<bool> requestExactAlarmsPermission() async {
    exactAlarmRequestCount++;
    exactAlarmsAllowed = true;
    return true;
  }
}

class _ThrowingScheduler extends FakeNotificationScheduler {
  @override
  Future<bool> canScheduleExactAlarms() async =>
      throw Exception('platform channel blew up');
}

void main() {
  late TestEnv env;

  setUp(() async => env = await TestEnv.create(now: DateTime(2026, 5, 14, 9)));
  tearDown(() => env.dispose());

  Future<void> drain(WidgetTester tester) =>
      tester.pumpAndSettle(const Duration(seconds: 6));

  testWidgets('already granted: quiet confirm, no request', (tester) async {
    env.scheduler.exactAlarmsAllowed = true;
    await pumpApp(tester, const _Host(), env: env);

    await tester.tap(find.text('Recover'));
    await tester.pumpAndSettle();

    expect(find.text('Precise reminder timing is already on.'), findsOneWidget);
    expect(env.scheduler.exactAlarmRequestCount, 0);
    await drain(tester);
  });

  testWidgets('blocked then granted: confirms exact alarms are on', (
    tester,
  ) async {
    final granting = _GrantingScheduler()..exactAlarmsAllowed = false;
    await pumpApp(
      tester,
      const _Host(),
      env: env,
      extraOverrides: [
        notificationSchedulerProvider.overrideWithValue(granting),
      ],
    );

    await tester.tap(find.text('Recover'));
    await tester.pumpAndSettle();

    expect(find.text('Precise reminder timing is on.'), findsOneWidget);
    expect(granting.exactAlarmRequestCount, 1);
    await drain(tester);
  });

  testWidgets('blocked and still blocked: explains short reminders may delay', (
    tester,
  ) async {
    env.scheduler.exactAlarmsAllowed = false;
    await pumpApp(tester, const _Host(), env: env);

    await tester.tap(find.text('Recover'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Precise reminder timing stays off. Short reminders may be '
        'delayed.',
      ),
      findsOneWidget,
    );
    expect(env.scheduler.exactAlarmRequestCount, 1);
    await drain(tester);
  });

  testWidgets('check failure: honest snack, no request attempted', (
    tester,
  ) async {
    final throwing = _ThrowingScheduler();
    await pumpApp(
      tester,
      const _Host(),
      env: env,
      extraOverrides: [
        notificationSchedulerProvider.overrideWithValue(throwing),
      ],
    );

    await tester.tap(find.text('Recover'));
    await tester.pumpAndSettle();

    expect(find.text('Couldn’t open exact alarm settings.'), findsOneWidget);
    expect(throwing.exactAlarmRequestCount, 0);
    await drain(tester);
  });
}
