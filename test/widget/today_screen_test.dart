import 'package:cleartray/app/theme.dart';
import 'package:cleartray/data/repositories/item_repository.dart';
import 'package:cleartray/data/repositories/review_repository.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:cleartray/features/engage/daily_plan_screen.dart';
import 'package:cleartray/features/engage/engage_screen.dart';
import 'package:cleartray/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../support/harness.dart';

/// The Do tab's Today view and the daily plan (ADR 0007).
void main() {
  late TestEnv env;
  late ItemRepository items;
  final now = DateTime(2026, 5, 14, 9);

  setUp(() async {
    env = await TestEnv.create(now: now);
    items = ItemRepository(env.db, env.clock);
  });
  tearDown(() => env.dispose());

  Future<void> pumpDo(WidgetTester tester) async {
    final container = ProviderContainer(overrides: env.overrides());
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const EngageScreen()),
        GoRoute(
          path: '/today/plan',
          builder: (_, _) => const DailyPlanScreen(),
        ),
        GoRoute(
          path: '/item/:id',
          builder: (_, _) => const Scaffold(body: Text('item')),
        ),
      ],
    );
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      router.dispose();
      container.dispose();
      await tester.pump(const Duration(seconds: 1));
    });
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          theme: AppTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openToday(WidgetTester tester) async {
    await tester.tap(find.text('Today'));
    await tester.pumpAndSettle();
  }

  testWidgets('Next actions stays the default view', (tester) async {
    await items.upsert(
      anItem(id: 'a', title: 'Email Sara', status: ItemStatus.nextAction),
    );
    await pumpDo(tester);
    expect(find.text('Email Sara'), findsOneWidget);
    expect(find.text('Plan your day'), findsNothing);
  });

  testWidgets('starring a next action commits it to Today', (tester) async {
    await items.upsert(
      anItem(id: 'a', title: 'Email Sara', status: ItemStatus.nextAction),
    );
    await pumpDo(tester);
    await tester.tap(find.bySemanticsLabel('Add Email Sara to Today'));
    await tester.pumpAndSettle();
    expect((await items.getById('a'))!.focusedAt, now);
    expect(find.bySemanticsLabel('Remove Email Sara from Today'), findsOne);

    await openToday(tester);
    expect(find.text('Plan your day'), findsOneWidget);
    expect(find.text('Focus'), findsOneWidget);
    expect(find.text('Email Sara'), findsOneWidget);

    // Unstarring from Today removes it from the list.
    await tester.tap(find.bySemanticsLabel('Remove Email Sara from Today'));
    await tester.pumpAndSettle();
    expect(find.text('Email Sara'), findsNothing);
    expect((await items.getById('a'))!.focusedAt, isNull);
  });

  testWidgets('the chosen view is remembered', (tester) async {
    await pumpDo(tester);
    await openToday(tester);
    expect(env.prefs.getString('do_view'), 'today');
  });

  testWidgets('the daily plan clears un-kept carry-over, with Undo', (
    tester,
  ) async {
    final yesterday = now.subtract(const Duration(days: 1));
    await items.upsertAll([
      anItem(id: 'keep', title: 'Book flights', status: ItemStatus.nextAction),
      anItem(id: 'drop', title: 'Fix the gate', status: ItemStatus.nextAction),
      anItem(id: 'new', title: 'Water plants', status: ItemStatus.nextAction),
    ]);
    await items.setFocusedAt({'keep': yesterday, 'drop': yesterday});

    await pumpDo(tester);
    await openToday(tester);
    // The plan card carries the carry-over line; no separate banner.
    expect(find.text('2 from earlier need a decision'), findsOneWidget);
    expect(find.text('Review'), findsNothing);
    expect(find.textContaining('Star next actions'), findsNothing);

    await tester.tap(find.text('Plan today'));
    await tester.pumpAndSettle();
    expect(find.text('From earlier'), findsOneWidget);
    expect(find.text('Nothing focused yet'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Add Book flights to Today'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Add Water plants to Today'));
    await tester.pumpAndSettle();
    expect(find.text('2 focused for today'), findsOneWidget);
    // Kept rows stay in place rather than jumping sections.
    expect(find.text('Book flights'), findsOneWidget);

    await tester.tap(find.text('Start my day'));
    await tester.pumpAndSettle();
    expect(find.text('Day planned · 1 item back on its list'), findsOneWidget);
    expect((await items.getById('drop'))!.focusedAt, isNull);
    expect((await items.getById('keep'))!.focusedAt, now);
    expect((await items.getById('new'))!.focusedAt, now);
    final reviews = await ReviewRepository(env.db).all();
    expect(reviews.single.type, ReviewType.daily);
    expect(reviews.single.completedAt, now);

    // Back on Today: planned, so no plan card or carry-over line.
    expect(find.text('Plan your day'), findsNothing);
    expect(find.textContaining('from earlier need'), findsNothing);
    expect(find.text('Book flights'), findsOneWidget);
    expect(find.text('Water plants'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect((await items.getById('drop'))!.focusedAt, yesterday);
  });

  testWidgets('Today after planning with nothing focused shows the empty state', (
    tester,
  ) async {
    await ReviewRepository(env.db).insert(
      ReviewLog(
        id: 'd',
        type: ReviewType.daily,
        startedAt: now,
        completedAt: now,
      ),
    );
    await pumpDo(tester);
    await openToday(tester);
    expect(find.text('Nothing focused yet'), findsOneWidget);
    expect(find.text('Plan today'), findsOneWidget);
  });

  testWidgets('calendar band items have no star and carry a count', (
    tester,
  ) async {
    await items.upsertAll([
      anItem(
        id: 'cal',
        title: 'Dentist',
        status: ItemStatus.calendar,
        dueAt: DateTime(2026, 5, 14, 15),
      ),
      anItem(id: 'a', title: 'Email Sara', status: ItemStatus.nextAction),
    ]);
    await pumpDo(tester);
    await openToday(tester);
    expect(find.textContaining('Calendar ·'), findsOneWidget);
    expect(find.textContaining('due today & overdue'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('Dentist'), findsOneWidget);
    expect(find.bySemanticsLabel('Add Dentist to Today'), findsNothing);
    expect(find.bySemanticsLabel('Remove Dentist from Today'), findsNothing);
  });

  testWidgets('the plan shows calendar items read-only, not as carry-over', (
    tester,
  ) async {
    final yesterday = now.subtract(const Duration(days: 1));
    await items.upsertAll([
      anItem(
        id: 'cal',
        title: 'Dentist',
        status: ItemStatus.calendar,
        dueAt: DateTime(2026, 5, 14, 15),
      ),
      anItem(id: 'a', title: 'Email Sara', status: ItemStatus.nextAction),
    ]);
    // A stale star on a band item must not read as carry-over.
    await items.setFocusedAt({'cal': yesterday});
    await pumpDo(tester);
    await openToday(tester);
    expect(find.textContaining('from earlier need'), findsNothing);
    expect(find.text('Plan your day'), findsOneWidget);

    await tester.tap(find.text('Plan today'));
    await tester.pumpAndSettle();
    expect(find.text('From earlier'), findsNothing);
    expect(find.text('Calendar'), findsOneWidget);
    expect(find.text('On Today'), findsOneWidget);
    expect(find.bySemanticsLabel('Add Dentist to Today'), findsNothing);
    expect(find.text('Nothing focused yet'), findsOneWidget);

    await tester.tap(find.text('Dentist'));
    await tester.pumpAndSettle();
    expect(find.text('item'), findsOneWidget);
  });

  testWidgets('a calendar item completed today counts as done', (tester) async {
    await items.upsert(
      anItem(
        id: 'cal',
        title: 'Dentist',
        status: ItemStatus.calendar,
        dueAt: DateTime(2026, 5, 14, 15),
      ),
    );
    await items.markCompleted('cal', now);
    await ReviewRepository(env.db).insert(
      ReviewLog(
        id: 'd',
        type: ReviewType.daily,
        startedAt: now,
        completedAt: now,
      ),
    );
    await pumpDo(tester);
    await openToday(tester);
    expect(find.text('1 done today'), findsOneWidget);
  });

  testWidgets('the daily plan fits a small phone at 3x German text', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await items.upsertAll([
      anItem(id: 'a', title: 'Angebot vorbereiten', status: ItemStatus.nextAction),
      anItem(id: 'b', title: 'Rechnung prüfen', status: ItemStatus.nextAction),
    ]);
    await items.setFocusedAt({'b': now.subtract(const Duration(days: 1))});
    await pumpApp(
      tester,
      const DailyPlanScreen(),
      env: env,
      locale: const Locale('de'),
      textScaler: const TextScaler.linear(3),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Tag starten').hitTestable(), findsOneWidget);
  });
}
