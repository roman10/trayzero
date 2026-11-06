import 'package:cleartray/data/repositories/item_repository.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:cleartray/features/item_edit/item_edit_screen.dart';
import 'package:cleartray/features/item_edit/sections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../support/harness.dart';

void main() {
  testWidgets('canceling Calendar date selection preserves the original list', (
    tester,
  ) async {
    final env = await TestEnv.create();
    addTearDown(env.dispose);
    final items = ItemRepository(env.db, env.clock);
    await items.upsert(anItem(id: 'a', status: ItemStatus.nextAction));
    await pumpApp(tester, const ItemEditScreen(itemId: 'a'), env: env);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Calendar'));
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect((await items.getById('a'))!.status, ItemStatus.nextAction);
  });

  testWidgets('Calendar date can be changed but cannot be cleared', (
    tester,
  ) async {
    final env = await TestEnv.create();
    addTearDown(env.dispose);
    final items = ItemRepository(env.db, env.clock);
    await items.upsert(
      anItem(
        id: 'a',
        status: ItemStatus.calendar,
        dueAt: env.clock.now().add(const Duration(days: 2)),
      ),
    );
    await pumpApp(tester, const ItemEditScreen(itemId: 'a'), env: env);
    await tester.pumpAndSettle();
    final dueTile = find.byType(DateTile).first;
    await tester.ensureVisible(dueTile);
    expect(
      find.descendant(of: dueTile, matching: find.byType(IconButton)),
      findsNothing,
    );
    await tester.tap(dueTile);
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect((await items.getById('a'))!.dueAt, isNotNull);
  });

  testWidgets('filing completed work replaces Reopen with active work', (
    tester,
  ) async {
    final env = await TestEnv.create();
    addTearDown(env.dispose);
    final items = ItemRepository(env.db, env.clock);
    await items.upsert(
      anItem(
        id: 'a',
        status: ItemStatus.done,
        completedAt: env.clock.now(),
        previousStatus: ItemStatus.waiting,
      ),
    );
    await pumpApp(tester, const ItemEditScreen(itemId: 'a'), env: env);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Next action'));
    await tester.pumpAndSettle();
    final stored = (await items.getById('a'))!;
    expect(stored.status, ItemStatus.nextAction);
    expect(stored.completedAt, isNull);
    expect(stored.previousStatus, isNull);
    await tester.pump(const Duration(seconds: 3));
  });
}
