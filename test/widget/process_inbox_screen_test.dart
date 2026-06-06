import 'package:cleartray/data/repositories/item_repository.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:cleartray/features/process/process_inbox_controller.dart';
import 'package:cleartray/features/process/process_inbox_screen.dart';
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

  testWidgets('shows inbox-zero empty state when nothing to clarify',
      (tester) async {
    await pumpApp(tester, const ProcessInboxScreen(), env: env);
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Inbox zero!'), findsOneWidget);
    expect(find.text('There is nothing to clarify.'), findsOneWidget);
    expect(find.text('Back'), findsOneWidget);
  });

  testWidgets('renders the first captured item with the actionable step',
      (tester) async {
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

  testWidgets('Trash decision removes the item from the inbox',
      (tester) async {
    await items.upsert(anItem(id: 'a', title: 'Junk thought'));

    await pumpApp(tester, const ProcessInboxScreen(), env: env);
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.text('Trash'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // The Trash decision hard-deletes the item (DeleteItem use case), so the
    // row is gone entirely rather than left in a `trashed` status.
    expect(await items.getById('a'), isNull);
    expect(find.text('Inbox zero!'), findsOneWidget);
    expect(find.textContaining('trashed 1'), findsOneWidget);
  });

  testWidgets('reference decision files the item out of the inbox',
      (tester) async {
    await items.upsert(anItem(id: 'a', title: 'Article to keep'));

    await pumpApp(tester, const ProcessInboxScreen(), env: env);
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.text('No — keep as reference'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect((await items.getById('a'))!.status, ItemStatus.reference);
    expect(find.text('Inbox zero!'), findsOneWidget);
  });

  testWidgets('advancing through steps walks the clarify decision tree',
      (tester) async {
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

  testWidgets('long captured notes scroll without hiding the step buttons',
      (tester) async {
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
    expect(await items.getById('a'), isNull);
  });
}
