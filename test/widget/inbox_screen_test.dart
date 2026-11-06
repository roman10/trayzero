import 'package:cleartray/data/repositories/item_repository.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:cleartray/features/inbox/inbox_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

void main() {
  late TestEnv env;
  late ItemRepository items;

  setUp(() async {
    env = await TestEnv.create(now: DateTime(2026, 5, 14));
    items = ItemRepository(env.db, env.clock);
  });
  tearDown(() => env.dispose());

  /// Drains the SnackBar's auto-dismiss timer so none is left pending at
  /// teardown (which `testWidgets` flags as a failure).
  Future<void> drainSnackBar(WidgetTester tester) =>
      tester.pumpAndSettle(const Duration(seconds: 5));

  testWidgets('shows empty-state when inbox is empty', (tester) async {
    await pumpApp(tester, const InboxScreen(), env: env);
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Inbox zero'), findsOneWidget);
    expect(find.text('Capture'), findsOneWidget);
  });

  testWidgets('shows captured items', (tester) async {
    await items.upsert(anItem(id: 'a', title: 'Sample inbox item'));
    await pumpApp(tester, const InboxScreen(), env: env);
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Sample inbox item'), findsOneWidget);
    expect(find.textContaining('Process inbox'), findsOneWidget);
  });

  testWidgets('swipe-left Done completes the item without triage',
      (tester) async {
    await items.upsert(anItem(id: 'a', title: 'Already did this'));
    await pumpApp(tester, const InboxScreen(), env: env);
    // Let the staggered entrance animation finish so the card is hit-testable.
    await tester.pumpAndSettle();

    await tester.drag(find.text('Already did this'), const Offset(-300, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    final done = await items.getById('a');
    expect(done!.status, ItemStatus.done);
    expect(done.completedAt, isNotNull);
    expect(find.text('Already did this'), findsNothing);
    expect(find.text('Inbox zero'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);

    await drainSnackBar(tester);
  });

  testWidgets('tapping the leading circle completes the item',
      (tester) async {
    final semantics = tester.ensureSemantics();
    await items.upsert(anItem(id: 'a', title: 'Call the bank'));
    await pumpApp(tester, const InboxScreen(), env: env);
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Mark Call the bank done'));
    await tester.pumpAndSettle();

    expect((await items.getById('a'))!.status, ItemStatus.done);
    expect(find.text('Call the bank'), findsNothing);

    await drainSnackBar(tester);
    semantics.dispose();
  });

  testWidgets('Undo returns a completed item to the inbox', (tester) async {
    await items.upsert(anItem(id: 'a', title: 'Misfired swipe'));
    await pumpApp(tester, const InboxScreen(), env: env);
    await tester.pumpAndSettle();

    await tester.drag(find.text('Misfired swipe'), const Offset(-300, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Misfired swipe'), findsNothing);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    final restored = await items.getById('a');
    expect(restored!.status, ItemStatus.inbox);
    expect(restored.completedAt, isNull);
    expect(find.text('Misfired swipe'), findsOneWidget);

    await drainSnackBar(tester);
  });

  testWidgets('completing from the inbox does not flag it as a 2-min item',
      (tester) async {
    await items.upsert(anItem(id: 'a', title: 'Quick chore'));
    await pumpApp(tester, const InboxScreen(), env: env);
    await tester.pumpAndSettle();

    await tester.drag(find.text('Quick chore'), const Offset(-300, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect((await items.getById('a'))!.isTwoMin, isFalse);

    await drainSnackBar(tester);
  });

  group('batch selection', () {
    Item plain(String title) => anItem(id: title, title: title);

    /// Seeds [selected] and [unselected] as inbox items, opens the inbox,
    /// long-presses the first of [selected] to enter selection mode and taps
    /// the rest of them.
    Future<void> selectItems(
      WidgetTester tester,
      List<Item> selected, {
      List<Item> unselected = const [],
    }) async {
      for (final i in [...selected, ...unselected]) {
        await items.upsert(i);
      }
      await pumpApp(tester, const InboxScreen(), env: env);
      await tester.pumpAndSettle();
      await tester.longPress(find.text(selected.first.title));
      await tester.pumpAndSettle();
      for (final i in selected.skip(1)) {
        await tester.tap(find.text(i.title));
        await tester.pumpAndSettle();
      }
    }

    // A Future query, not watchInbox(): drift streams don't emit under the
    // widget tester's fake clock.
    Future<List<String>> inboxIds() async => (await items.allActive())
        .where((i) => i.status == ItemStatus.inbox)
        .map((i) => i.id)
        .toList()
      ..sort();

    Finder inBar(Finder f) =>
        find.descendant(of: find.byType(BottomAppBar), matching: f);

    testWidgets('bar offers Done; Delete moves to the app bar', (tester) async {
      await selectItems(tester, [plain('One')]);

      expect(inBar(find.text('Done')), findsOneWidget);
      expect(inBar(find.text('Delete')), findsNothing);
      expect(find.byTooltip('Delete'), findsOneWidget);

      // Deselecting the only item disables the bulk actions, trash included.
      await tester.tap(find.text('One'));
      await tester.pumpAndSettle();
      expect(find.text('0 selected'), findsOneWidget);
      expect(
        tester
            .widget<IconButton>(
                find.widgetWithIcon(IconButton, Icons.delete_outline))
            .onPressed,
        isNull,
      );
    });

    testWidgets('Done completes only the selected items and exits selection',
        (tester) async {
      await selectItems(
        tester,
        [plain('One'), plain('Two')],
        unselected: [plain('Three')],
      );

      await tester.tap(inBar(find.text('Done')));
      await tester.pumpAndSettle();

      expect((await items.getById('One'))!.status, ItemStatus.done);
      expect((await items.getById('Two'))!.status, ItemStatus.done);
      expect((await items.getById('Three'))!.status, ItemStatus.inbox);
      expect(find.text('Completed 2 items.'), findsOneWidget);
      // Selection mode is left and only the untouched item remains listed.
      expect(find.byType(BottomAppBar), findsNothing);
      expect(find.text('Three'), findsOneWidget);
      expect(find.text('One'), findsNothing);

      await drainSnackBar(tester);
    });

    testWidgets('Undo restores the batch and drops spawned recurrences',
        (tester) async {
      await selectItems(tester, [
        plain('Plain'),
        // Completing a recurring item spawns a successor instance.
        anItem(
          id: 'Daily',
          title: 'Water plants',
          deferUntil: DateTime(2026, 5, 14),
          recurrence: Recurrence.daily,
        ),
      ]);

      await tester.tap(inBar(find.text('Done')));
      await tester.pumpAndSettle();
      expect((await items.getById('Plain'))!.status, ItemStatus.done);
      expect((await items.getById('Daily'))!.status, ItemStatus.done);
      // The only thing left in the inbox is the recurring item's successor.
      final afterDone = await inboxIds();
      expect(afterDone, hasLength(1));
      expect(afterDone.single, isNot('Daily'));

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();

      // Both originals are back and the spawned successor is gone.
      expect(await inboxIds(), ['Daily', 'Plain']);
      expect((await items.getById('Plain'))!.completedAt, isNull);
      expect((await items.getById('Daily'))!.completedAt, isNull);

      await drainSnackBar(tester);
    });

    testWidgets('trash icon deletes the selection, with Undo', (tester) async {
      await selectItems(tester, [plain('One'), plain('Two')]);

      await tester.tap(find.byTooltip('Delete'));
      await tester.pumpAndSettle();

      // Soft-deleted: hidden from the inbox and awaiting the Undo window.
      expect((await items.getById('One'))!.status, ItemStatus.trashed);
      expect((await items.getById('Two'))!.status, ItemStatus.trashed);
      expect(find.text('Deleted 2 items.'), findsOneWidget);

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect((await items.getById('One'))!.status, ItemStatus.inbox);
      expect((await items.getById('Two'))!.status, ItemStatus.inbox);

      await drainSnackBar(tester);
    });

    testWidgets('the delete is final once the Undo window closes',
        (tester) async {
      await selectItems(tester, [plain('One'), plain('Two')]);

      await tester.tap(find.byTooltip('Delete'));
      await tester.pumpAndSettle();
      await drainSnackBar(tester);

      expect(await items.getById('One'), isNull);
      expect(await items.getById('Two'), isNull);
    });
  });
}
