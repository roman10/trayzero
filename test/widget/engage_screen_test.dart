import 'package:cleartray/data/repositories/item_repository.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:cleartray/features/engage/engage_screen.dart';
import 'package:flutter/material.dart' show Key;
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

/// Time and energy live in a sheet behind one chip.
Future<void> pickUnder5Minutes(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('engage-filter-time-energy')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('< 5m'));
  await tester.pump();
  await tester.tap(find.text('Done'));
  await tester.pumpAndSettle();
}

void main() {
  late TestEnv env;
  late ItemRepository items;

  setUp(() async {
    env = await TestEnv.create(now: DateTime(2026, 5, 14, 9));
    items = ItemRepository(env.db, env.clock);
  });
  tearDown(() => env.dispose());

  testWidgets('shows the empty state when there are no next actions', (
    tester,
  ) async {
    await pumpApp(tester, const EngageScreen(), env: env);
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('No next actions yet'), findsOneWidget);
    expect(find.text('Open inbox'), findsOneWidget);
  });

  testWidgets('renders next-action items', (tester) async {
    await items.upsert(
      anItem(id: 'a', title: 'Email Sara', status: ItemStatus.nextAction),
    );
    await items.upsert(
      anItem(id: 'b', title: 'Draft proposal', status: ItemStatus.nextAction),
    );
    // Inbox item must not appear in the Do-now list.
    await items.upsert(anItem(id: 'c', title: 'Random thought'));

    await pumpApp(tester, const EngageScreen(), env: env);
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Email Sara'), findsOneWidget);
    expect(find.text('Draft proposal'), findsOneWidget);
    expect(find.text('Random thought'), findsNothing);
  });

  testWidgets('time filter narrows the list to matching estimates', (
    tester,
  ) async {
    await items.upsert(
      anItem(
        id: 'quick',
        title: 'Quick win',
        status: ItemStatus.nextAction,
      ).copyWith(timeEstimateMinutes: 5),
    );
    await items.upsert(
      anItem(
        id: 'long',
        title: 'Long slog',
        status: ItemStatus.nextAction,
      ).copyWith(timeEstimateMinutes: 120),
    );

    await pumpApp(tester, const EngageScreen(), env: env);
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Quick win'), findsOneWidget);
    expect(find.text('Long slog'), findsOneWidget);

    await pickUnder5Minutes(tester);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Quick win'), findsOneWidget);
    expect(find.text('Long slog'), findsNothing);
  });

  testWidgets('no hard-landscape band when there are no calendar items', (
    tester,
  ) async {
    await items.upsert(
      anItem(id: 'a', title: 'Email Sara', status: ItemStatus.nextAction),
    );

    await pumpApp(tester, const EngageScreen(), env: env);
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.textContaining('Calendar ·'), findsNothing);
    expect(find.text('Email Sara'), findsOneWidget);
  });

  testWidgets(
    'band shows overdue (with re-decide) + today calendar items above '
    'next actions',
    (tester) async {
      await items.upsert(
        anItem(
          id: 'over',
          title: 'File taxes',
          status: ItemStatus.calendar,
          dueAt: DateTime(2026, 5, 10, 9),
        ),
      );
      await items.upsert(
        anItem(
          id: 'today',
          title: 'Dentist',
          status: ItemStatus.calendar,
          dueAt: DateTime(2026, 5, 14, 15),
        ),
      );
      await items.upsert(
        anItem(
          id: 'na',
          title: 'Draft proposal',
          status: ItemStatus.nextAction,
        ),
      );

      await pumpApp(tester, const EngageScreen(), env: env);
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining('Calendar ·'), findsOneWidget);
      expect(find.text('File taxes'), findsOneWidget);
      expect(find.text('Dentist'), findsOneWidget);
      expect(find.text('Draft proposal'), findsOneWidget);
      // Overdue item carries the explicit re-decide actions.
      expect(find.text('Reschedule'), findsOneWidget);
    },
  );

  testWidgets(
    'band stays visible (with inline note, not full-screen empty state) '
    'when there are no next actions',
    (tester) async {
      await items.upsert(
        anItem(
          id: 'today',
          title: 'Dentist',
          status: ItemStatus.calendar,
          dueAt: DateTime(2026, 5, 14, 15),
        ),
      );

      await pumpApp(tester, const EngageScreen(), env: env);
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining('Calendar ·'), findsOneWidget);
      expect(find.text('Dentist'), findsOneWidget);
      expect(
        find.text('No next actions yet — capture or process your inbox.'),
        findsOneWidget,
      );
      // The full-screen empty state must NOT take over.
      expect(find.text('Open inbox'), findsNothing);
      expect(find.text('No next actions yet'), findsNothing);
    },
  );

  testWidgets('filters narrow next actions but never touch the band', (
    tester,
  ) async {
    await items.upsert(
      anItem(
        id: 'today',
        title: 'Dentist',
        status: ItemStatus.calendar,
        dueAt: DateTime(2026, 5, 14, 15),
      ),
    );
    await items.upsert(
      anItem(
        id: 'long',
        title: 'Long slog',
        status: ItemStatus.nextAction,
      ).copyWith(timeEstimateMinutes: 120),
    );

    await pumpApp(tester, const EngageScreen(), env: env);
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.textContaining('Calendar ·'), findsOneWidget);
    expect(find.text('Long slog'), findsOneWidget);

    await pickUnder5Minutes(tester);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Long slog'), findsNothing);
    // Band is unaffected by the discretionary filter.
    expect(find.textContaining('Calendar ·'), findsOneWidget);
    expect(find.text('Dentist'), findsOneWidget);
  });

  testWidgets('tapping the complete affordance removes it from the list', (
    tester,
  ) async {
    await items.upsert(
      anItem(id: 'a', title: 'Finish report', status: ItemStatus.nextAction),
    );

    await pumpApp(tester, const EngageScreen(), env: env);
    await tester.pump(const Duration(milliseconds: 100));
    // Let the staggered list entrance animation finish so the card is laid
    // out and hit-testable.
    await tester.pumpAndSettle();

    // Swipe the card left to reveal the Slidable end action pane, then tap
    // its "Done" action.
    await tester.drag(find.text('Finish report'), const Offset(-300, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect((await items.getById('a'))!.status, ItemStatus.done);
    expect(find.text('Finish report'), findsNothing);
  });

  testWidgets('filters hiding everything offer Clear filters and a count', (
    tester,
  ) async {
    await items.upsert(
      anItem(
        id: 'long',
        title: 'Long slog',
        status: ItemStatus.nextAction,
      ).copyWith(timeEstimateMinutes: 120),
    );

    await pumpApp(tester, const EngageScreen(), env: env);
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byKey(const Key('engage-filter-reset')), findsNothing);

    await pickUnder5Minutes(tester);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Nothing matches'), findsOneWidget);
    expect(
      find.text('1 next action is hidden by your filters'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('engage-filter-reset')), findsOneWidget);

    await tester.tap(find.text('Clear filters'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Long slog'), findsOneWidget);
    expect(find.byKey(const Key('engage-filter-reset')), findsNothing);
  });

  testWidgets('filters fit one row; time and energy sit behind one chip', (
    tester,
  ) async {
    await items.upsert(
      anItem(
        id: 'a',
        title: 'Quick win',
        status: ItemStatus.nextAction,
      ).copyWith(timeEstimateMinutes: 5),
    );
    await pumpApp(tester, const EngageScreen(), env: env);
    await tester.pump(const Duration(milliseconds: 100));

    // Time/energy choices are not in the strip until the sheet opens.
    expect(find.text('Time & energy'), findsOneWidget);
    expect(find.text('< 5m'), findsNothing);
    expect(find.text('Any energy'), findsNothing);
    final reset = find.byKey(const Key('engage-filter-reset'));
    expect(reset, findsNothing);

    await pickUnder5Minutes(tester);
    // The chip now summarises the active choice and Reset appears.
    expect(find.text('< 5m'), findsOneWidget);
    expect(find.text('Time & energy'), findsNothing);
    expect(reset, findsOneWidget);
    expect(find.text('Quick win'), findsOneWidget);
  });

  testWidgets('Reset chip clears active filters', (tester) async {
    await items.upsert(
      anItem(
        id: 'long',
        title: 'Long slog',
        status: ItemStatus.nextAction,
      ).copyWith(timeEstimateMinutes: 120),
    );
    await items.upsert(
      anItem(
        id: 'quick',
        title: 'Quick win',
        status: ItemStatus.nextAction,
      ).copyWith(timeEstimateMinutes: 5),
    );

    await pumpApp(tester, const EngageScreen(), env: env);
    await tester.pump(const Duration(milliseconds: 100));
    await pickUnder5Minutes(tester);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Long slog'), findsNothing);

    await tester.tap(find.byKey(const Key('engage-filter-reset')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Long slog'), findsOneWidget);
  });
}
