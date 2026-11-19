import 'package:cleartray/core/haptic_feedback.dart';
import 'package:cleartray/data/repositories/item_repository.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:cleartray/features/common/complete_with_undo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

/// A minimal host: a button that runs [completeWithUndo] for [itemId].
class _Host extends ConsumerWidget {
  const _Host(this.itemIds);
  final List<String> itemIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => itemIds.length == 1
              ? completeWithUndo(context, ref, itemIds.single)
              : completeManyWithUndo(context, ref, itemIds),
          child: const Text('Done'),
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

  /// Drains the SnackBar's auto-dismiss timer so none is left pending at
  /// teardown (which `testWidgets` flags as a failure).
  Future<void> drainSnackBar(WidgetTester tester) =>
      tester.pumpAndSettle(const Duration(seconds: 5));

  testWidgets('completes the item and shows an Undo snackbar', (tester) async {
    await items.upsert(anItem(id: 'a', status: ItemStatus.nextAction));
    await pumpApp(tester, const _Host(['a']), env: env);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle(); // async completion + snackbar fully in

    expect((await items.getById('a'))!.status, ItemStatus.done);
    expect(find.text('Completed'), findsOneWidget);
    expect(find.text('Undo'), findsOneWidget);

    await drainSnackBar(tester);
  });

  testWidgets('Undo reopens the completed item', (tester) async {
    await items.upsert(anItem(id: 'a', status: ItemStatus.nextAction));
    await env.prefs.setBool('haptics_enabled', false);
    final cues = <HapticCue>[];
    await pumpApp(
      tester,
      const _Host(['a']),
      env: env,
      extraOverrides: [
        playHapticCueProvider.overrideWithValue((cue) async => cues.add(cue)),
      ],
    );

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect((await items.getById('a'))!.status, ItemStatus.done);
    expect(cues, isEmpty);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    final restored = await items.getById('a');
    expect(restored!.status, ItemStatus.nextAction);
    expect(restored.completedAt, isNull);

    await drainSnackBar(tester);
  });

  testWidgets('Undo also removes the recurrence instance completion spawned', (
    tester,
  ) async {
    // A recurring next action anchors on `deferUntil` (Option A).
    await items.upsert(
      anItem(
        id: 'r',
        status: ItemStatus.nextAction,
        deferUntil: DateTime(2026, 5, 14),
        recurrence: Recurrence.daily,
      ),
    );
    final cues = <HapticCue>[];
    await pumpApp(
      tester,
      const _Host(['r']),
      env: env,
      extraOverrides: [
        playHapticCueProvider.overrideWithValue((cue) async => cues.add(cue)),
      ],
    );

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    // Original is done; completion spawned a fresh recurring instance.
    // The first id drawn from the FixedIdGenerator is "test-1".
    expect((await items.getById('r'))!.status, ItemStatus.done);
    final spawned = await items.getById('test-1');
    expect(
      spawned,
      isNotNull,
      reason: 'recurrence rollover should create a new open instance',
    );
    expect(spawned!.status, ItemStatus.nextAction);

    // A repeated action must neither buzz again nor replace the original Undo.
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(cues, [HapticCue.taskCompleted]);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    // Original restored to its list, spawned instance removed entirely.
    expect((await items.getById('r'))!.status, ItemStatus.nextAction);
    expect(await items.getById('test-1'), isNull);

    await drainSnackBar(tester);
  });

  testWidgets('a batch gives one cue and Undo only restores changed items', (
    tester,
  ) async {
    await items.upsert(anItem(id: 'a', status: ItemStatus.nextAction));
    await items.upsert(anItem(id: 'b', status: ItemStatus.nextAction));
    await items.upsert(anItem(id: 'c', status: ItemStatus.done));
    final cues = <HapticCue>[];
    await pumpApp(
      tester,
      const _Host(['a', 'b', 'c']),
      env: env,
      extraOverrides: [
        playHapticCueProvider.overrideWithValue((cue) async => cues.add(cue)),
      ],
    );
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(cues, [HapticCue.taskCompleted]);
    expect((await items.getById('a'))!.status, ItemStatus.done);
    expect((await items.getById('b'))!.status, ItemStatus.done);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect((await items.getById('a'))!.status, ItemStatus.nextAction);
    expect((await items.getById('b'))!.status, ItemStatus.nextAction);
    expect((await items.getById('c'))!.status, ItemStatus.done);
    await drainSnackBar(tester);
  });
}
