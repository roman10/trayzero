import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cleartray/application/providers.dart';
import 'package:cleartray/app/theme.dart';
import 'package:cleartray/l10n/gen/app_localizations.dart';
import 'package:cleartray/application/complete_item.dart';
import 'package:cleartray/application/save_item.dart';
import 'package:cleartray/core/clock.dart';
import 'package:cleartray/core/id_generator.dart';
import 'package:cleartray/core/notification_scheduler.dart';
import 'package:cleartray/data/db/database.dart';
import 'package:cleartray/data/repositories/item_repository.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:cleartray/features/engage/engage_screen.dart';
import 'package:cleartray/features/inbox/inbox_screen.dart';
import 'package:cleartray/features/settings/settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/fakes.dart';

/// End-to-end coverage of GTD's killer flow:
///
///   capture → clarify (next-action) → engage → done
///
/// This is not a true `integration_test` (which would need a device), but a
/// widget-test-driven walk through every layer (repo + provider + screen),
/// which catches regressions in the binding between them.
Future<Widget> _wrap({
  required AppDatabase db,
  required SharedPreferences prefs,
  required Clock clock,
  required IdGenerator ids,
  required NotificationScheduler scheduler,
  required Widget child,
}) async {
  return UncontrolledProviderScope(
    container: ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        sharedPreferencesProvider.overrideWithValue(prefs),
        clockProvider.overrideWithValue(clock),
        idGeneratorProvider.overrideWithValue(ids),
        notificationSchedulerProvider.overrideWithValue(scheduler),
      ],
    ),
    child: MaterialApp(
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    ),
  );
}

void main() {
  late AppDatabase db;
  late SharedPreferences prefs;
  late ItemRepository items;
  late Clock clock;
  late IdGenerator ids;
  late FakeNotificationScheduler scheduler;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase.forTesting(NativeDatabase.memory());
    prefs = await SharedPreferences.getInstance();
    clock = FakeClock(DateTime(2026, 5, 14, 9));
    ids = FixedIdGenerator();
    scheduler = FakeNotificationScheduler();
    items = ItemRepository(db, clock);
  });

  tearDown(() async => db.close());

  testWidgets('capture → next-action → engage → done', (tester) async {
    final now = DateTime(2026, 5, 14, 9);

    // 1. Capture: insert an inbox item (the FAB sheet's persistence path).
    await items.upsert(Item(
      id: 'walk-the-dog',
      title: 'Walk the dog',
      status: ItemStatus.inbox,
      createdAt: now,
      updatedAt: now,
    ));

    // Inbox shows the captured item.
    await tester
        .pumpWidget(await _wrap(db: db, prefs: prefs, clock: clock, ids: ids, scheduler: scheduler, child: const InboxScreen()));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Walk the dog'), findsOneWidget);

    // 2. Clarify: promote it to a Next Action (what Process Inbox does).
    final captured = await items.getById('walk-the-dog');
    expect(captured, isNotNull);
    await items.upsert(captured!.copyWith(
      status: ItemStatus.nextAction,
      updatedAt: now,
    ));

    // 3. Engage: filterable list shows the next action.
    await tester
        .pumpWidget(await _wrap(db: db, prefs: prefs, clock: clock, ids: ids, scheduler: scheduler, child: const EngageScreen()));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Walk the dog'), findsOneWidget);

    // 4. Done: complete it and verify it leaves both lists.
    await items.markCompleted('walk-the-dog', now);

    await tester
        .pumpWidget(await _wrap(db: db, prefs: prefs, clock: clock, ids: ids, scheduler: scheduler, child: const EngageScreen()));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Walk the dog'), findsNothing);

    final after = await items.getById('walk-the-dog');
    expect(after?.status, ItemStatus.done);
    expect(after?.completedAt, isNotNull);
  });

  testWidgets(
    'completing a recurring item via CompleteItem generates the next instance',
    (tester) async {
      final now = DateTime(2026, 5, 14);
      // A recurring next action anchors on `deferUntil` (Option A: it never
      // carries a hard `dueAt`).
      await items.upsert(Item(
        id: 'water-plants',
        title: 'Water the plants',
        status: ItemStatus.nextAction,
        recurrence: Recurrence.weekly,
        recurrenceInterval: 1,
        deferUntil: now,
        createdAt: now,
        updatedAt: now,
      ));

      final completeItem = CompleteItem(
        items: items,
        scheduler: scheduler,
        clock: clock,
        ids: FixedIdGenerator(['next-1']),
        saveItem: SaveItem(items: items, scheduler: scheduler, clock: clock),
      );
      await completeItem('water-plants');

      // Original is done.
      final original = await items.getById('water-plants');
      expect(original?.status, ItemStatus.done);

      // Exactly one fresh instance exists with the defer anchor advanced 7
      // days; a next action never holds a dueAt.
      final active = await items.allActive();
      final next =
          active.where((i) => i.title == 'Water the plants').toList();
      expect(next.length, 1);
      expect(next.first.id, 'next-1');
      expect(next.first.dueAt, isNull);
      expect(next.first.deferUntil, now.add(const Duration(days: 7)));
      expect(next.first.recurrence, Recurrence.weekly);
    },
  );
}
