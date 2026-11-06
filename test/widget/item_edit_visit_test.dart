import 'package:cleartray/data/repositories/item_repository.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:cleartray/features/item_edit/item_edit_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

void main() {
  testWidgets('completion, history edit and explicit reopen across visits', (
    tester,
  ) async {
    final env = await TestEnv.create();
    addTearDown(env.dispose);
    final items = ItemRepository(env.db, env.clock);
    await items.upsert(
      anItem(
        id: 'a',
        title: 'Daily action',
        status: ItemStatus.nextAction,
        deferUntil: env.clock.now(),
        recurrence: Recurrence.daily,
      ),
    );
    // One app/provider container throughout; only the editor route changes.
    await pumpApp(
      tester,
      Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const ItemEditScreen(itemId: 'a'),
              ),
            ),
            child: const Text('Open action'),
          ),
        ),
      ),
      env: env,
    );
    await tester.tap(find.text('Open action'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Mark complete'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Mark complete'));
    await tester.pumpAndSettle();
    final completed = (await items.getById('a'))!;
    final successor = (await items.allActive()).single;
    expect(completed.status, ItemStatus.done);

    await tester.tap(find.text('Open action'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Notes'),
      'Corrected notes',
    );
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();
    final edited = (await items.getById('a'))!;
    expect(edited.notes, 'Corrected notes');
    expect(edited.status, ItemStatus.done);
    expect(edited.completedAt, completed.completedAt);
    expect((await items.allActive()).single.id, successor.id);
    expect(
      (await items.getById(successor.id))!.deferUntil,
      successor.deferUntil,
    );

    await tester.scrollUntilVisible(
      find.text('Reopen'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Reopen'));
    await tester.pumpAndSettle();
    expect((await items.getById('a'))!.status, ItemStatus.nextAction);
    expect((await items.getById('a'))!.completedAt, isNull);
    await tester.tap(find.text('Open action'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Mark complete'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Mark complete'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
  });
}
