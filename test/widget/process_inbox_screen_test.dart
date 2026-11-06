import 'package:cleartray/application/providers.dart';
import 'package:cleartray/data/repositories/item_repository.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:cleartray/features/process/process_inbox_controller.dart';
import 'package:cleartray/features/process/process_inbox_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

/// Fails every write, to exercise the screen's error path.
class _FailingItems extends ItemRepository {
  _FailingItems(super.db, super.clock);

  @override
  Future<void> upsert(Item item) => throw StateError('disk full');
}

void main() {
  late TestEnv env;
  late ItemRepository items;

  setUp(() async {
    env = await TestEnv.create(now: DateTime(2026, 5, 14, 9));
    items = ItemRepository(env.db, env.clock);
  });
  tearDown(() => env.dispose());

  testWidgets('shows inbox-zero empty state when nothing to clarify', (
    tester,
  ) async {
    await pumpApp(tester, const ProcessInboxScreen(), env: env);
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Inbox zero!'), findsOneWidget);
    expect(find.text('There is nothing to clarify.'), findsOneWidget);
    expect(find.text('Back'), findsOneWidget);
  });

  testWidgets('renders the first captured item with the actionable step', (
    tester,
  ) async {
    await items.upsert(anItem(id: 'a', title: 'Call the dentist'));
    await items.upsert(anItem(id: 'b', title: 'Buy milk'));

    await pumpApp(tester, const ProcessInboxScreen(), env: env);
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Call the dentist'), findsOneWidget);
    expect(find.text('CAPTURED'), findsOneWidget);
    expect(find.text('Is this actionable?'), findsOneWidget);
    expect(find.text('Step 1 of $processStepCount'), findsOneWidget);
    expect(find.text('2 left'), findsOneWidget);
  });

  testWidgets('Trash decision removes the item from the inbox', (tester) async {
    await items.upsert(anItem(id: 'a', title: 'Junk thought'));

    await pumpApp(tester, const ProcessInboxScreen(), env: env);
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.text('Trash'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Trash soft-deletes (so Undo works); the row is purged after the snackbar.
    expect((await items.getById('a'))!.status, ItemStatus.trashed);
    expect(find.text('Inbox zero!'), findsOneWidget);
    expect(find.textContaining('trashed 1'), findsOneWidget);
  });

  testWidgets('reference decision files the item out of the inbox', (
    tester,
  ) async {
    await items.upsert(anItem(id: 'a', title: 'Article to keep'));

    await pumpApp(tester, const ProcessInboxScreen(), env: env);
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.text('No — keep as reference'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect((await items.getById('a'))!.status, ItemStatus.reference);
    expect(find.text('Inbox zero!'), findsOneWidget);
  });

  testWidgets('advancing through steps walks the clarify decision tree', (
    tester,
  ) async {
    await items.upsert(anItem(id: 'a', title: 'Plan trip'));

    await pumpApp(tester, const ProcessInboxScreen(), env: env);
    await tester.pump(const Duration(milliseconds: 100));

    // actionable -> twoMin
    await tester.tap(find.text('Yes — there is something to do'));
    await tester.pump();
    expect(find.text('Will it take less than 2 minutes?'), findsOneWidget);

    // twoMin -> delegate
    await tester.tap(find.text('No — keep clarifying'));
    await tester.pump();
    expect(find.text('Can someone else do it?'), findsOneWidget);

    // delegate -> singleStep
    await tester.tap(find.text("No — it's on me"));
    await tester.pump();
    expect(find.text('Is this a single physical action?'), findsOneWidget);
  });

  testWidgets('waiting-on dialog keeps OK disabled until a name is typed', (
    tester,
  ) async {
    await items.upsert(anItem(id: 'a', title: 'Plan trip'));

    await pumpApp(tester, const ProcessInboxScreen(), env: env);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('Yes — there is something to do'));
    await tester.pump();
    await tester.tap(find.text('No — keep clarifying'));
    await tester.pump();
    await tester.tap(find.text('Yes — delegate & wait for them'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    FilledButton ok() =>
        tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'OK'));
    expect(ok().onPressed, isNull);

    await tester.enterText(find.byType(TextField), '   ');
    await tester.pump();
    expect(ok().onPressed, isNull);

    await tester.enterText(find.byType(TextField), 'Sam');
    await tester.pump();
    expect(ok().onPressed, isNotNull);

    await tester.tap(find.widgetWithText(FilledButton, 'OK'));
    await tester.pump(const Duration(milliseconds: 100));
    expect((await items.getById('a'))!.waitingOn, 'Sam');
  });

  testWidgets('long captured notes scroll without hiding the step buttons', (
    tester,
  ) async {
    // Use a realistic phone surface (default test surface is 800x600, too
    // short for the step UI once the card takes its 40% cap).
    await tester.binding.setSurfaceSize(const Size(400, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final longNote = List.generate(120, (i) => 'Note line $i').join('\n');
    await items.upsert(
      anItem(id: 'a', title: 'Item with a very long note', notes: longNote),
    );

    await pumpApp(tester, const ProcessInboxScreen(), env: env);
    await tester.pump(const Duration(milliseconds: 100));

    // Regression: a note far taller than the screen used to overflow the
    // body Column (RenderFlex overflow — caught by testWidgets) and shove
    // the step UI off screen. The CapturedCard is now height-capped and
    // scrolls internally, so the question and buttons stay reachable.
    expect(find.text('CAPTURED'), findsOneWidget);
    expect(find.text('Is this actionable?'), findsOneWidget);
    expect(find.text('Trash'), findsOneWidget);

    // The card owns a scroll view so its overflowing content is reachable.
    final cardScroll = find.descendant(
      of: find.byType(Scrollbar),
      matching: find.byType(SingleChildScrollView),
    );
    expect(cardScroll, findsOneWidget);

    // Buttons remain wired up even with an oversized note.
    await tester.tap(find.text('Trash'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect((await items.getById('a'))!.status, ItemStatus.trashed);
  });

  group('undo and failures', () {
    Future<void> drain(WidgetTester tester) =>
        tester.pumpAndSettle(const Duration(seconds: 6));

    testWidgets('Undo after Reference puts the item back in the flow', (
      tester,
    ) async {
      await items.upsert(anItem(id: 'a', title: 'Article to keep'));
      await pumpApp(tester, const ProcessInboxScreen(), env: env);
      await tester.pumpAndSettle();

      await tester.tap(find.text('No — keep as reference'));
      await tester.pumpAndSettle();
      expect(find.text('Inbox zero!'), findsOneWidget);
      expect(find.text('Filed.'), findsOneWidget);

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();

      expect((await items.getById('a'))!.status, ItemStatus.inbox);
      expect(find.text('Article to keep'), findsOneWidget);
      expect(find.text('Is this actionable?'), findsOneWidget);
      expect(find.text('Inbox zero!'), findsNothing);
      await drain(tester);
    });

    testWidgets('Undo after Trash restores it; the tally drops the trash', (
      tester,
    ) async {
      await items.upsert(anItem(id: 'a', title: 'Junk thought'));
      await pumpApp(tester, const ProcessInboxScreen(), env: env);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Trash'));
      await tester.pumpAndSettle();
      expect(find.text('Deleted 1 item.'), findsOneWidget);

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();

      expect((await items.getById('a'))!.status, ItemStatus.inbox);
      expect(find.text('Junk thought'), findsOneWidget);
      await drain(tester);
      // Closing after Undo never purges the restored item.
      expect(await items.getById('a'), isNotNull);
    });

    testWidgets('a trashed item is purged once the snackbar closes', (
      tester,
    ) async {
      await items.upsert(anItem(id: 'a', title: 'Junk thought'));
      await pumpApp(tester, const ProcessInboxScreen(), env: env);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Trash'));
      await tester.pumpAndSettle();
      await drain(tester);

      expect(await items.getById('a'), isNull);
    });

    testWidgets('Undo after Do-it-now reopens the item', (tester) async {
      await items.upsert(anItem(id: 'a', title: 'Quick one'));
      await pumpApp(tester, const ProcessInboxScreen(), env: env);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Yes — there is something to do'));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Yes — I'll do it now"));
      await tester.pumpAndSettle();
      expect((await items.getById('a'))!.status, ItemStatus.done);

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();

      final back = (await items.getById('a'))!;
      expect(back.status, ItemStatus.inbox);
      expect(back.completedAt, isNull);
      await drain(tester);
    });

    testWidgets('a failed save shows the error and leaves the item to retry', (
      tester,
    ) async {
      await items.upsert(anItem(id: 'a', title: 'Article to keep'));
      await pumpApp(
        tester,
        const ProcessInboxScreen(),
        env: env,
        extraOverrides: [
          itemRepositoryProvider.overrideWithValue(
            _FailingItems(env.db, env.clock),
          ),
        ],
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('No — keep as reference'));
      await tester.pumpAndSettle();

      expect(
        find.text("Couldn't save your changes. Please try again."),
        findsOneWidget,
      );
      expect((await items.getById('a'))!.status, ItemStatus.inbox);
      // Still on the same item, buttons live again.
      expect(find.text('Is this actionable?'), findsOneWidget);
      await tester.tap(find.text('No — keep as reference'));
      await tester.pumpAndSettle();
      expect(find.text('Is this actionable?'), findsOneWidget);
      await drain(tester);
    });
  });
}
