import 'package:cleartray/app/router.dart';
import 'package:cleartray/app/theme.dart';
import 'package:cleartray/l10n/gen/app_localizations.dart';
import 'package:cleartray/core/notification_scheduler.dart';
import 'package:cleartray/data/repositories/item_repository.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

/// Mirrors the on-device failure: the real flutter_local_notifications
/// plugin can throw from cancel()/schedule() (revoked exact-alarm
/// permission, OEM scheduler quirks). Only items that actually had a
/// reminder scheduled — i.e. ones with a due/defer date — hit cancel with
/// a real notification, which is why this only reproduces there.
class ThrowingScheduler extends FakeNotificationScheduler {
  @override
  Future<void> cancel(int id) async => throw StateError('plugin boom');
}

void main() {
  late TestEnv env;
  late ItemRepository items;

  setUp(() async {
    env = await TestEnv.create(
      now: DateTime(2026, 5, 14, 9),
      prefsValues: {'onboarding_complete_v1': true},
    );
    items = ItemRepository(env.db, env.clock);
  });
  tearDown(() => env.dispose());

  testWidgets(
      'Mark complete still completes + pops when reminder cancel throws',
      (tester) async {
    await items.upsert(anItem(
      id: 'a',
      title: 'Pay rent',
      status: ItemStatus.inbox,
      dueAt: DateTime(2026, 5, 20, 9),
    ));

    final container = ProviderContainer(
      overrides: env.overrides([
        notificationSchedulerProvider
            .overrideWithValue(ThrowingScheduler()),
      ]),
    );
    addTearDown(container.dispose);
    final router = container.read(routerProvider);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        theme: AppTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    ));
    await tester.pumpAndSettle();

    router.go('/inbox');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pay rent'));
    await tester.pumpAndSettle();
    expect(find.text('Edit'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Mark complete'), 300,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('Mark complete'));
    await tester.pumpAndSettle();

    final saved = await items.getById('a');
    expect(saved!.status, ItemStatus.done,
        reason: 'item must be completed even if reminder cancel fails');
    expect(find.text('Edit'), findsNothing,
        reason: 'screen must leave even if reminder cancel fails');
  });
}
