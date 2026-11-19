import 'package:cleartray/app/theme.dart';
import 'package:cleartray/data/repositories/context_repository.dart';
import 'package:cleartray/data/repositories/item_repository.dart';
import 'package:cleartray/data/repositories/project_repository.dart';
import 'package:cleartray/data/repositories/review_repository.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:cleartray/features/common/focus_star.dart';
import 'package:cleartray/features/common/item_metadata_label.dart';
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

  Finder planCount(String value) => find.byWidgetPredicate(
    (widget) => widget is Semantics && widget.properties.value == value,
  );

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
    expect(planCount('Nothing focused yet'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Add Book flights to Today'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Add Water plants to Today'));
    await tester.pumpAndSettle();
    expect(planCount('2 focused for today'), findsOneWidget);
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

  testWidgets(
    'Today after planning with nothing focused shows the empty state',
    (tester) async {
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
    },
  );

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
    expect(planCount('Nothing focused yet'), findsOneWidget);

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

  Future<void> seedPlanMetadata() async {
    final projects = ProjectRepository(env.db);
    for (final (id, title) in [
      ('web', 'Website redesign and customer onboarding'),
      ('kitchen', 'Kitchen renovation and appliance installation'),
    ]) {
      await projects.upsert(
        Project(
          id: id,
          title: title,
          status: ProjectStatus.active,
          createdAt: now,
          updatedAt: now,
        ),
      );
    }
    await ContextRepository(env.db).upsert(
      const GtdContext(
        id: 'office',
        name: '@office',
        icon: 'work',
        color: 0xFF1E88E5,
      ),
    );
    await items.upsertAll([
      anItem(
        id: 'waiting',
        title: 'Confirm delivery',
        status: ItemStatus.waiting,
        projectId: 'kitchen',
        waitingOn: 'Alex',
        deferUntil: DateTime(2026, 5, 13),
        dueAt: DateTime(2026, 5, 15),
      ),
      anItem(
        id: 'scheduled',
        title: 'Installation appointment',
        status: ItemStatus.calendar,
        projectId: 'kitchen',
        dueAt: DateTime(2026, 5, 16, 15, 30),
      ),
      anItem(
        id: 'calendar',
        title: 'Client meeting',
        status: ItemStatus.calendar,
        projectId: 'web',
        dueAt: DateTime(2026, 5, 14, 10),
      ),
      anItem(
        id: 'follow',
        title: 'Check approval',
        status: ItemStatus.waiting,
        projectId: 'web',
        waitingOn: 'Sam',
        dueAt: DateTime(2026, 5, 14),
      ),
      anItem(
        id: 'available',
        title: 'Prepare proposal',
        status: ItemStatus.nextAction,
        projectId: 'web',
        contextId: 'office',
        deferUntil: DateTime(2026, 5, 14),
      ).copyWith(timeEstimateMinutes: 25),
      anItem(
        id: 'next',
        title: 'Prepare proposal',
        status: ItemStatus.nextAction,
        projectId: 'kitchen',
        isTwoMin: true,
      ),
      anItem(
        id: 'plain',
        title: 'Standalone action',
        status: ItemStatus.nextAction,
      ),
    ]);
    await items.setFocusedAt({
      'waiting': now.subtract(const Duration(days: 1)),
      'scheduled': now.subtract(const Duration(days: 1)),
    });
  }

  Finder planRow(String id) => find.byKey(ValueKey('plan-$id'));
  Finder rowText(String id, Pattern text) =>
      find.descendant(of: planRow(id), matching: find.textContaining(text));

  testWidgets('planning rows identify projects and preserve date meanings', (
    tester,
  ) async {
    await seedPlanMetadata();
    // A tall viewport lets this test inspect all sections and their ordering.
    await tester.binding.setSurfaceSize(const Size(600, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpApp(tester, const DailyPlanScreen(), env: env);
    await tester.pumpAndSettle();
    expect(rowText('available', 'Website redesign'), findsOneWidget);
    expect(rowText('next', 'Kitchen renovation'), findsOneWidget);
    expect(rowText('available', '@office'), findsOneWidget);
    expect(rowText('available', '25 min'), findsOneWidget);
    expect(rowText('available', 'Starts'), findsOneWidget);
    expect(rowText('available', 'Due'), findsNothing);
    expect(rowText('next', '2 min'), findsOneWidget);
    expect(rowText('waiting', 'Waiting on Alex'), findsOneWidget);
    expect(rowText('waiting', 'Follow up'), findsOneWidget);
    expect(rowText('waiting', 'Due'), findsOneWidget);
    expect(rowText('waiting', 'Starts'), findsNothing);
    expect(rowText('scheduled', 'Scheduled'), findsOneWidget);
    expect(rowText('scheduled', '3:30'), findsOneWidget);
    expect(rowText('scheduled', 'PM'), findsOneWidget);
    expect(rowText('calendar', 'Website redesign'), findsOneWidget);
    expect(rowText('calendar', 'Scheduled'), findsOneWidget);
    expect(rowText('calendar', 'On Today'), findsOneWidget);
    expect(
      find.descendant(
        of: planRow('calendar'),
        matching: find.byType(FocusStar),
      ),
      findsNothing,
    );
    expect(rowText('follow', 'Waiting on Sam'), findsOneWidget);
    expect(rowText('follow', 'Follow up'), findsOneWidget);
    expect(
      find.descendant(of: planRow('plain'), matching: find.byType(Text)),
      findsOneWidget,
    );
    final sections = [
      'From earlier',
      'Calendar',
      'Waiting follow-ups',
      'Available from today',
      'Next actions',
    ];
    for (var i = 1; i < sections.length; i++) {
      expect(
        tester.getTopLeft(find.text(sections[i])).dy,
        greaterThan(tester.getTopLeft(find.text(sections[i - 1])).dy),
      );
    }
  });

  testWidgets('opening a planning row and starring it are independent', (
    tester,
  ) async {
    await seedPlanMetadata();
    await pumpDo(tester);
    await openToday(tester);
    await tester.tap(find.text('Plan today'));
    await tester.pumpAndSettle();
    final star = find.descendant(
      of: planRow('waiting'),
      matching: find.byType(FocusStar),
    );
    final semantics = tester.ensureSemantics();
    await tester.pump();
    expect(
      tester.getSemantics(find.bySemanticsLabel('Start my day')).value,
      'Nothing focused yet',
    );
    expect(
      tester.getSemantics(
        find.bySemanticsLabel(
          'Add Confirm delivery, Kitchen renovation and appliance installation, '
          'Waiting on Alex, Follow up Wed, May 13, Due Fri, May 15 to Today',
        ),
      ),
      matchesSemantics(
        label:
            'Add Confirm delivery, Kitchen renovation and appliance installation, '
            'Waiting on Alex, Follow up Wed, May 13, Due Fri, May 15 to Today',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        hasToggledState: true,
        hasTapAction: true,
      ),
    );
    await tester.tap(star);
    await tester.pumpAndSettle();
    expect((await items.getById('waiting'))!.focusedAt, now);
    expect(find.text('Start my day'), findsOneWidget);
    expect(
      tester.getSemantics(find.bySemanticsLabel('Start my day')).value,
      '1 focused for today',
    );
    semantics.dispose();
    await tester.tap(rowText('waiting', 'Confirm delivery'));
    await tester.pumpAndSettle();
    expect(find.text('item'), findsOneWidget);
    expect((await items.getById('waiting'))!.focusedAt, now);
    // Returning from details uses live content without moving carry-over rows.
    final current = (await items.getById('waiting'))!;
    await items.upsert(
      current.copyWith(title: 'Updated delivery', projectId: 'web'),
    );
    GoRouter.of(tester.element(find.text('item'))).pop();
    await tester.pumpAndSettle();
    expect(rowText('waiting', 'Updated delivery'), findsOneWidget);
    expect(rowText('waiting', 'Website redesign'), findsOneWidget);
    expect((await items.getById('waiting'))!.focusedAt, now);
  });

  for (final scale in [1.0, 3.0]) {
    for (final locale in [const Locale('en'), const Locale('de')]) {
      testWidgets(
        'rich planning cards fit a 320px phone at ${scale}x ${locale.languageCode} text',
        (tester) async {
          await tester.binding.setSurfaceSize(const Size(320, 568));
          addTearDown(() => tester.binding.setSurfaceSize(null));
          await seedPlanMetadata();
          await pumpApp(
            tester,
            const DailyPlanScreen(),
            env: env,
            locale: locale,
            textScaler: TextScaler.linear(scale),
          );
          await tester.pumpAndSettle();
          for (final id in [
            'waiting',
            'scheduled',
            'calendar',
            'follow',
            'available',
            'next',
            'plain',
          ]) {
            await tester.scrollUntilVisible(planRow(id), 150, maxScrolls: 100);
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull, reason: 'Layout of $id');
            final row = planRow(id);
            for (final text
                in find
                    .descendant(of: row, matching: find.byType(Text))
                    .evaluate()) {
              final rect = tester.getRect(find.byWidget(text.widget));
              expect(rect.left, greaterThanOrEqualTo(0));
              expect(rect.right, lessThanOrEqualTo(320));
            }
            if (id != 'calendar') {
              final star = find.descendant(
                of: row,
                matching: find.byType(FocusStar),
              );
              expect(tester.getSize(star), const Size(48, 48));
              final labels = find.descendant(
                of: row,
                matching: find.byType(ItemMetadataLabel),
              );
              if (labels.evaluate().isNotEmpty) {
                expect(
                  tester.getTopLeft(labels.first).dy,
                  greaterThanOrEqualTo(tester.getBottomRight(star).dy),
                  reason: 'Metadata must not overlap the star touch target',
                );
              }
            }
          }
          final l = await AppLocalizations.delegate.load(locale);
          expect(find.text(l.planStartDay).hitTestable(), findsOneWidget);
          expect(planCount(l.planFocusedCount(0)), findsOneWidget);
          expect(find.text(l.planFocusedCount(0)), findsNothing);
          expect(
            tester.getSize(find.byType(FilledButton)).height,
            lessThan(568 / 2),
            reason: 'Keep most of the small viewport available to cards',
          );
        },
      );
    }
  }
}
