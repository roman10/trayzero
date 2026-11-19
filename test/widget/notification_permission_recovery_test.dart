import 'dart:async';

import 'package:cleartray/application/providers.dart';
import 'package:cleartray/application/schedule_weekly_review_reminder.dart';
import 'package:cleartray/core/notification_scheduler.dart';
import 'package:cleartray/features/common/notification_permission_recovery.dart';
import 'package:cleartray/features/settings/reminders_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

/// A minimal host: a button that runs [runNotificationPermissionRecovery].
class _Host extends ConsumerWidget {
  const _Host();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => runNotificationPermissionRecovery(context, ref),
          child: const Text('Recover'),
        ),
      ),
    );
  }
}

/// Flips to granted when the OS prompt is "shown" — models the user
/// allowing notifications at the system dialog.
class _GrantingScheduler extends FakeNotificationScheduler {
  @override
  Future<NotificationPermission> requestPermission() async {
    requestCount++;
    status = NotificationPermission.granted;
    return status;
  }
}

const _primedKey = 'notification_primed_v1';

void main() {
  late TestEnv env;

  setUp(() async => env = await TestEnv.create(now: DateTime(2026, 5, 14, 9)));
  tearDown(() => env.dispose());

  Future<void> drain(WidgetTester tester) =>
      tester.pumpAndSettle(const Duration(seconds: 6));

  testWidgets('a reminder setting waits for launch reconciliation', (
    tester,
  ) async {
    final startup = Completer<void>();
    await pumpApp(
      tester,
      const RemindersScreen(),
      env: env,
      extraOverrides: [
        startupStandingRemindersProvider.overrideWithValue(startup.future),
      ],
    );

    await tester.tap(find.byType(Switch).first);
    await tester.pump();
    expect(env.scheduler.cancelled, isEmpty);

    // Model a startup schedule that was in flight when the user tapped.
    env.scheduler.pending[weeklyReviewReminderId] = null;
    startup.complete();
    await tester.pumpAndSettle();

    expect(env.prefs.getBool('weekly_review_reminder_enabled'), isFalse);
    expect(env.scheduler.pending, isNot(contains(weeklyReviewReminderId)));
    expect(env.scheduler.cancelled, contains(weeklyReviewReminderId));
  });

  testWidgets('granted: quiet confirm, no prompt, no settings deep-link',
      (tester) async {
    env.scheduler.status = NotificationPermission.granted;
    await pumpApp(tester, const _Host(), env: env);

    await tester.tap(find.text('Recover'));
    await tester.pumpAndSettle();

    expect(find.text('Reminders are already on.'), findsOneWidget);
    expect(env.scheduler.requestCount, 0);
    expect(env.systemSettings.openCount, 0);
    await drain(tester);
  });

  testWidgets('permanentlyDenied: deep-links to system settings, no prompt',
      (tester) async {
    env.scheduler.status = NotificationPermission.permanentlyDenied;
    await pumpApp(tester, const _Host(), env: env);

    await tester.tap(find.text('Recover'));
    await tester.pumpAndSettle();

    expect(env.systemSettings.openCount, 1);
    expect(env.scheduler.requestCount, 0);
    expect(
      find.text('Opened system settings — turn on Notifications for '
          'Trayzero.'),
      findsOneWidget,
    );
    await drain(tester);
  });

  testWidgets('denied + unprimed: primer shown; Not now marks primed, '
      'no OS prompt', (tester) async {
    env.scheduler.status = NotificationPermission.denied;
    await pumpApp(tester, const _Host(), env: env);

    await tester.tap(find.text('Recover'));
    await tester.pumpAndSettle();

    expect(find.text('Turn on reminders?'), findsOneWidget);
    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();

    expect(env.prefs.getBool(_primedKey), isTrue);
    expect(env.scheduler.requestCount, 0);
    expect(find.textContaining('Reminders stay off'), findsOneWidget);
    await drain(tester);
  });

  testWidgets('denied + unprimed: Continue runs the OS prompt', (tester) async {
    env.scheduler.status = NotificationPermission.denied;
    await pumpApp(tester, const _Host(), env: env);

    await tester.tap(find.text('Recover'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(env.prefs.getBool(_primedKey), isTrue);
    expect(env.scheduler.requestCount, 1);
    await drain(tester);
  });

  testWidgets('denied + Continue then granted: confirms reminders are on',
      (tester) async {
    env = await TestEnv.create(now: DateTime(2026, 5, 14, 9));
    final granting = _GrantingScheduler()
      ..status = NotificationPermission.denied;
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
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(granting.requestCount, 1);
    expect(find.text('Reminders are on.'), findsOneWidget);
    await drain(tester);
  });

  testWidgets('denied + already primed: no primer dialog, prompts directly',
      (tester) async {
    env = await TestEnv.create(
      now: DateTime(2026, 5, 14, 9),
      prefsValues: {_primedKey: true},
    );
    env.scheduler.status = NotificationPermission.denied;
    await pumpApp(tester, const _Host(), env: env);

    await tester.tap(find.text('Recover'));
    await tester.pumpAndSettle();

    expect(find.text('Turn on reminders?'), findsNothing);
    expect(env.scheduler.requestCount, 1);
    await drain(tester);
  });
}
