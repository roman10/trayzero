import 'package:cleartray/application/providers.dart';
import 'package:cleartray/application/process_inbox_decision.dart';
import 'package:cleartray/features/process/process_inbox_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

/// Regression: the clarify flow is per-item. Reaching the last step on one
/// item must not leak that step pointer onto the next item — the reset is
/// driven off the inbox stream, so the list and the step never disagree
/// about which item is on screen.
void main() {
  late TestEnv env;

  setUp(() async => env = await TestEnv.create());
  tearDown(() => env.dispose());

  test('next inbox item restarts at step 1, session tally preserved', () async {
    final container = env.container();
    final repo = container.read(itemRepositoryProvider);
    await repo.upsert(anItem(id: 'a', title: 'A').copyWith(sortOrder: 0));
    await repo.upsert(anItem(id: 'b', title: 'B').copyWith(sortOrder: 1));

    // Reading the notifier wires the build-time stream listener; pump so the
    // first emission binds the head item ('a') before we drive the wizard.
    final notifier = container.read(processInboxControllerProvider.notifier);
    container.listen(inboxItemsProvider, (_, _) {});
    await pumpEventQueue();

    final itemA = container.read(inboxItemsProvider).valueOrNull!.first;
    expect(itemA.id, 'a');

    // Walk 'a' to the final step (step 6 of 6).
    for (var i = 0; i < processStepCount - 1; i++) {
      notifier.advance();
    }
    expect(
      container.read(processInboxControllerProvider).step,
      ProcessStep.detail,
    );

    await notifier.decide(itemA, const TrashDecision());
    await pumpEventQueue();

    final state = container.read(processInboxControllerProvider);
    expect(
      state.step,
      ProcessStep.actionable,
      reason: 'next item must start from step 1',
    );
    expect(state.canGoBack, isFalse);
    expect(state.trashed, 1, reason: 'session tally survives the reset');
    expect(
      container.read(inboxItemsProvider).valueOrNull!.single.id,
      'b',
      reason: 'inbox head advanced to the next item',
    );
  });

  test('skipping the only inbox item still restarts at step 1', () async {
    final container = env.container();
    final repo = container.read(itemRepositoryProvider);
    await repo.upsert(anItem(id: 'solo', title: 'Solo').copyWith(sortOrder: 0));

    final notifier = container.read(processInboxControllerProvider.notifier);
    container.listen(inboxItemsProvider, (_, _) {});
    await pumpEventQueue();

    final solo = container.read(inboxItemsProvider).valueOrNull!.single;
    notifier.advance();
    notifier.advance();
    expect(container.read(processInboxControllerProvider).step,
        ProcessStep.delegate);

    // Skip only re-queues the item — it stays the inbox head, so the stream
    // listener never fires. Skip must reset on its own or it looks dead.
    await notifier.skip(solo);
    await pumpEventQueue();

    final state = container.read(processInboxControllerProvider);
    expect(state.step, ProcessStep.actionable,
        reason: 'skip restarts the flow even when the head is unchanged');
    expect(container.read(inboxItemsProvider).valueOrNull!.single.id, 'solo',
        reason: 'the lone item is still there to clarify later');
  });

  test('captured context and project are preselected per item (ADR 0007)',
      () async {
    final container = env.container();
    final repo = container.read(itemRepositoryProvider);
    await repo.upsert(
      anItem(id: 'a', title: 'A', contextId: 'c1', projectId: 'p1')
          .copyWith(sortOrder: 0),
    );
    await repo.upsert(anItem(id: 'b', title: 'B').copyWith(sortOrder: 1));
    final notifier = container.read(processInboxControllerProvider.notifier);
    container.listen(inboxItemsProvider, (_, _) {});
    await pumpEventQueue();

    var state = container.read(processInboxControllerProvider);
    expect(state.selectedContextId, 'c1');
    expect(state.selectedProjectId, 'p1');

    final itemA = container.read(inboxItemsProvider).valueOrNull!.first;
    await notifier.decide(itemA, const TrashDecision());
    await pumpEventQueue();
    state = container.read(processInboxControllerProvider);
    expect(state.selectedContextId, isNull);
    expect(state.selectedProjectId, isNull);
  });
}
