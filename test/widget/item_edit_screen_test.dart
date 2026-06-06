import 'package:cleartray/data/repositories/item_repository.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:cleartray/features/item_edit/item_edit_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

void main() {
  late TestEnv env;
  late ItemRepository items;

  setUp(() async {
    env = await TestEnv.create(now: DateTime(2026, 5, 14, 9));
    items = ItemRepository(env.db, env.clock);
  });
  tearDown(() => env.dispose());

  testWidgets('shows "Item not found" error when the id does not exist',
      (tester) async {
    await pumpApp(tester, const ItemEditScreen(itemId: 'missing'), env: env);
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.textContaining('Item not found'), findsOneWidget);
  });

  testWidgets('seeds the form fields from the loaded item', (tester) async {
    await items.upsert(anItem(
      id: 'a',
      title: 'Call the plumber',
      notes: 'Leaking tap in kitchen',
      status: ItemStatus.nextAction,
    ));

    await pumpApp(tester, const ItemEditScreen(itemId: 'a'), env: env);
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Call the plumber'), findsOneWidget);
    expect(find.text('Leaking tap in kitchen'), findsOneWidget);
    // nextAction shows the Context/Energy sections.
    expect(find.text('CONTEXT'), findsOneWidget);
    expect(find.text('ENERGY'), findsOneWidget);
  });

  testWidgets('editing the title and unfocusing persists via the repo',
      (tester) async {
    await items.upsert(anItem(
      id: 'a',
      title: 'Old title',
      status: ItemStatus.nextAction,
    ));

    await pumpApp(tester, const ItemEditScreen(itemId: 'a'), env: env);
    await tester.pump(const Duration(milliseconds: 100));

    await tester.enterText(
        find.widgetWithText(TextField, 'Old title'), 'New shiny title');
    // The title field schedules a 600ms debounced commit on change.
    await tester.pump(const Duration(milliseconds: 700));

    final saved = await items.getById('a');
    expect(saved!.title, 'New shiny title');

    // Drain the post-save "Saved" flash timer before the tree disposes.
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('changing status commits immediately', (tester) async {
    await items.upsert(anItem(
      id: 'a',
      title: 'Reconsider later',
      status: ItemStatus.nextAction,
    ));

    await pumpApp(tester, const ItemEditScreen(itemId: 'a'), env: env);
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.widgetWithText(ChoiceChip, 'Someday / Maybe'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final saved = await items.getById('a');
    expect(saved!.status, ItemStatus.someday);

    // Drain the post-save "Saved" flash timer before the tree disposes.
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('debounced text change persists notes', (tester) async {
    await items.upsert(anItem(
      id: 'a',
      title: 'Task',
      status: ItemStatus.nextAction,
    ));

    await pumpApp(tester, const ItemEditScreen(itemId: 'a'), env: env);
    await tester.pump(const Duration(milliseconds: 100));

    await tester.enterText(
        find.widgetWithText(TextField, 'Notes'), 'Some fresh notes');
    // 600ms debounce timer flushes the commit.
    await tester.pump(const Duration(milliseconds: 700));

    final saved = await items.getById('a');
    expect(saved!.notes, 'Some fresh notes');

    // Drain the post-save "Saved" flash timer before the tree disposes.
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('recurrence interval stepper persists recurrenceInterval',
      (tester) async {
    await items.upsert(anItem(
      id: 'a',
      title: 'Water the plants',
      status: ItemStatus.nextAction,
      recurrence: Recurrence.weekly,
      recurrenceInterval: 1,
    ));

    await pumpApp(tester, const ItemEditScreen(itemId: 'a'), env: env);
    await tester.pump(const Duration(milliseconds: 100));

    // The stepper only renders when a recurrence is set; it lives near the
    // bottom of the form so scroll it into view first.
    await tester.scrollUntilVisible(
      find.byIcon(Icons.add_circle_outline),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    // Removing the Due tile for next actions shortens the form, so the
    // stepper can settle flush against the viewport edge — pull it fully
    // into view before tapping.
    await tester.ensureVisible(find.byIcon(Icons.add_circle_outline));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final saved = await items.getById('a');
    expect(saved!.recurrenceInterval, 2);

    // Drain the post-save "Saved" flash timer before the tree disposes.
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('recurrence end picker enforces until/count exclusivity',
      (tester) async {
    await items.upsert(anItem(
      id: 'a',
      title: 'Weekly standup',
      status: ItemStatus.nextAction,
      recurrence: Recurrence.weekly,
      recurrenceUntil: DateTime(2026, 12, 31),
    ));

    await pumpApp(tester, const ItemEditScreen(itemId: 'a'), env: env);
    await tester.pump(const Duration(milliseconds: 100));

    // Switching to a count cap must clear the until-date (at most one
    // end condition is meaningful at a time).
    await tester.scrollUntilVisible(
      find.widgetWithText(ChoiceChip, 'After N times'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.widgetWithText(ChoiceChip, 'After N times'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    var saved = await items.getById('a');
    expect(saved!.recurrenceCount, 2, reason: 'count floored at 2');
    expect(saved.recurrenceUntil, isNull, reason: 'until must be cleared');

    // "Never" clears both caps.
    await tester.tap(find.widgetWithText(ChoiceChip, 'Never'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    saved = await items.getById('a');
    expect(saved!.recurrenceCount, isNull);
    expect(saved.recurrenceUntil, isNull);

    // Drain the post-save "Saved" flash timer before the tree disposes.
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('weekly weekday picker persists recurrenceByWeekdays',
      (tester) async {
    await items.upsert(anItem(
      id: 'a',
      title: 'Standup',
      status: ItemStatus.nextAction,
      recurrence: Recurrence.weekly,
    ));

    await pumpApp(tester, const ItemEditScreen(itemId: 'a'), env: env);
    await tester.pump(const Duration(milliseconds: 100));

    await tester.scrollUntilVisible(
      find.widgetWithText(FilterChip, 'Wed'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.widgetWithText(FilterChip, 'Mon'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.widgetWithText(FilterChip, 'Wed'));
    await tester.pump(const Duration(milliseconds: 100));

    final saved = await items.getById('a');
    expect(saved!.recurrenceByWeekdays, const [1, 3]);

    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('monthly "Day of week" sets the nth-weekday qualifier',
      (tester) async {
    await items.upsert(anItem(
      id: 'a',
      title: 'Rent',
      status: ItemStatus.nextAction,
      recurrence: Recurrence.monthly,
    ));

    await pumpApp(tester, const ItemEditScreen(itemId: 'a'), env: env);
    await tester.pump(const Duration(milliseconds: 100));

    await tester.scrollUntilVisible(
      find.widgetWithText(ChoiceChip, 'Day of week'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.widgetWithText(ChoiceChip, 'Day of week'));
    await tester.pump(const Duration(milliseconds: 100));

    final saved = await items.getById('a');
    expect(saved!.recurrenceMonthlyWeek, 1);
    expect(saved.recurrenceMonthlyWeekday, DateTime.monday);
    expect(saved.recurrenceRule?.monthlyMode, MonthlyMode.nthWeekday);

    await tester.pump(const Duration(seconds: 3));
  });

  // The form is a lazily-built list; scroll the Dates section into the
  // viewport so its tiles are actually constructed before asserting.
  Future<void> revealDates(WidgetTester tester) => tester.scrollUntilVisible(
        find.text('Defer until'),
        300,
        scrollable: find.byType(Scrollable).first,
      );

  testWidgets('no Due tile for a next action; Defer until is still offered',
      (tester) async {
    await items.upsert(anItem(
      id: 'a',
      title: 'Email Alice',
      status: ItemStatus.nextAction,
    ));

    await pumpApp(tester, const ItemEditScreen(itemId: 'a'), env: env);
    await tester.pump(const Duration(milliseconds: 100));
    await revealDates(tester);

    expect(find.text('Defer until'), findsOneWidget);
    expect(find.text('Due'), findsNothing);
  });

  testWidgets('a calendar item still shows the Due tile', (tester) async {
    await items.upsert(anItem(
      id: 'a',
      title: 'Dentist',
      status: ItemStatus.calendar,
      dueAt: DateTime(2026, 5, 20, 9),
    ));

    await pumpApp(tester, const ItemEditScreen(itemId: 'a'), env: env);
    await tester.pump(const Duration(milliseconds: 100));
    await revealDates(tester);

    expect(find.text('Due'), findsOneWidget);
  });

  testWidgets('switching status to Next Action clears the Due date',
      (tester) async {
    await items.upsert(anItem(
      id: 'a',
      title: 'Dentist',
      status: ItemStatus.calendar,
      dueAt: DateTime(2026, 5, 20, 9),
    ));

    await pumpApp(tester, const ItemEditScreen(itemId: 'a'), env: env);
    await tester.pump(const Duration(milliseconds: 100));

    // The status chips sit at the top of the form, in view from the start.
    await tester.tap(find.widgetWithText(ChoiceChip, 'Next Action'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final saved = await items.getById('a');
    expect(saved!.status, ItemStatus.nextAction);
    expect(saved.dueAt, isNull);

    // And the control is gone once it is a next action.
    await revealDates(tester);
    expect(find.text('Defer until'), findsOneWidget);
    expect(find.text('Due'), findsNothing);

    await tester.pump(const Duration(seconds: 3));
  });
}
