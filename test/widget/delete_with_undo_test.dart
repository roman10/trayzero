import 'package:cleartray/data/repositories/item_repository.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:cleartray/features/common/delete_with_undo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

/// A minimal host: a button that runs [deleteWithUndo] for [itemId].
class _Host extends ConsumerWidget {
  const _Host(this.itemId);
  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => deleteWithUndo(context, ref, itemId),
          child: const Text('Delete'),
        ),
      ),
    );
  }
}

void main() {
  late TestEnv env;
  late ItemRepository items;

  setUp(() async {
    env = await TestEnv.create(now: DateTime(2026, 5, 14, 9));
    items = ItemRepository(env.db, env.clock);
  });
  tearDown(() => env.dispose());

  Future<void> drainSnackBar(WidgetTester tester) =>
      tester.pumpAndSettle(const Duration(seconds: 6));

  testWidgets('trashes the item and shows an Undo snackbar', (tester) async {
    await items.upsert(anItem(id: 'a', status: ItemStatus.nextAction));
    await pumpApp(tester, const _Host('a'), env: env);

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect((await items.getById('a'))!.status, ItemStatus.trashed);
    expect(find.text('Deleted 1 item.'), findsOneWidget);
    expect(find.text('Undo'), findsOneWidget);

    await drainSnackBar(tester);
  });

  testWidgets('Undo restores the item exactly', (tester) async {
    await items.upsert(
      anItem(id: 'a', status: ItemStatus.waiting).copyWith(waitingOn: 'Bob'),
    );
    await pumpApp(tester, const _Host('a'), env: env);

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    final back = (await items.getById('a'))!;
    expect(back.status, ItemStatus.waiting);
    expect(back.waitingOn, 'Bob');

    // Closing after Undo must not purge the restored item.
    await drainSnackBar(tester);
    expect(await items.getById('a'), isNotNull);
  });

  testWidgets('the row is permanently deleted once the snackbar closes',
      (tester) async {
    await items.upsert(anItem(id: 'a', status: ItemStatus.nextAction));
    await pumpApp(tester, const _Host('a'), env: env);

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(await items.getById('a'), isNotNull);

    await drainSnackBar(tester);

    expect(await items.getById('a'), isNull);
  });
}
