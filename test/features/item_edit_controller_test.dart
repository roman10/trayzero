import 'dart:async';

import 'package:cleartray/application/providers.dart';
import 'package:cleartray/data/repositories/item_repository.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:cleartray/features/item_edit/item_edit_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

class _DelayedItems extends ItemRepository {
  _DelayedItems(super.db, super.clock);
  Completer<void>? entered;
  Completer<void>? release;
  bool fail = false;
  int writes = 0;

  @override
  Future<void> upsert(Item item) async {
    writes++;
    final gate = release;
    if (gate != null) {
      release = null;
      entered!.complete();
      await gate.future;
    }
    if (fail) throw StateError('write failed');
    await super.upsert(item);
  }
}

void main() {
  late TestEnv env;
  late _DelayedItems items;
  setUp(() async {
    env = await TestEnv.create();
    items = _DelayedItems(env.db, env.clock);
    await items.upsert(
      anItem(id: 'a', title: 'Original', status: ItemStatus.nextAction),
    );
    items.writes = 0;
  });
  tearDown(() => env.dispose());

  for (final change in ['complete', 'reopen', 'edit', 'delete']) {
    test('a new editor visit reloads after $change', () async {
      final c = env.container([
        itemRepositoryProvider.overrideWithValue(items),
      ]);
      final provider = itemEditControllerProvider('a');
      if (change == 'reopen') await c.read(completeItemProvider).call('a');
      final visit = c.listen(provider, (_, _) {});
      await c.read(provider.future);
      visit.close();
      await c.pump();
      switch (change) {
        case 'complete':
          await c.read(completeItemProvider).call('a');
        case 'reopen':
          await c.read(reopenItemProvider).call('a');
        case 'edit':
          await items.upsert(
            (await items.getById('a'))!.copyWith(title: 'External edit'),
          );
        case 'delete':
          await items.delete('a');
      }
      final nextVisit = c.listen(provider, (_, _) {});
      addTearDown(nextVisit.close);
      if (change == 'delete') {
        await expectLater(c.read(provider.future), throwsStateError);
        return;
      }
      final loaded = await c.read(provider.future);
      final stored = (await items.getById('a'))!;
      expect(loaded.status, stored.status);
      expect(loaded.completedAt, stored.completedAt);
      expect(loaded.title, stored.title);
      c
          .read(provider.notifier)
          .updateDraft((i) => i.copyWith(notes: 'New notes'));
      await c.read(provider.notifier).commit();
      expect((await items.getById('a'))!.status, stored.status);
      expect((await items.getById('a'))!.completedAt, stored.completedAt);
    });
  }

  test('leaving during a save finishes every pending draft revision', () async {
    final c = env.container([itemRepositoryProvider.overrideWithValue(items)]);
    final provider = itemEditControllerProvider('a');
    final visit = c.listen(provider, (_, _) {});
    await c.read(provider.future);
    final editor = c.read(provider.notifier);
    editor.updateDraft((i) => i.copyWith(title: 'First edit'));
    items.entered = Completer<void>();
    final release = items.release = Completer<void>();
    final saving = editor.commit();
    await items.entered!.future;
    editor.updateDraft((i) => i.copyWith(notes: 'Last edit'));
    visit.close();
    await c.pump();
    release.complete();
    await saving;
    await c.pump();
    expect((await items.getById('a'))!.title, 'First edit');
    expect((await items.getById('a'))!.notes, 'Last edit');
  });

  test(
    'overlapping commits preserve and persist edits made during a save',
    () async {
      final c = env.container([
        itemRepositoryProvider.overrideWithValue(items),
      ]);
      await c.read(itemEditControllerProvider('a').future);
      final n = c.read(itemEditControllerProvider('a').notifier);
      n.updateDraft((i) => i.copyWith(title: 'First edit'));
      items.entered = Completer<void>();
      final release = items.release = Completer<void>();
      final first = n.commit();
      await items.entered!.future;
      n.updateDraft(
        (i) => i.copyWith(title: 'Latest edit', notes: 'Latest notes'),
      );
      final overlapping = n.commit();
      release.complete();
      expect(await first, isTrue);
      expect(await overlapping, isTrue);
      final saved = await items.getById('a');
      expect(saved!.title, 'Latest edit');
      expect(saved.notes, 'Latest notes');
      expect(
        c.read(itemEditControllerProvider('a')).valueOrNull!.title,
        'Latest edit',
      );
      expect(n.hasUnsavedDraft, isFalse);
      expect(items.writes, 2);
    },
  );

  test('a failed save retains the draft and can be retried', () async {
    final c = env.container([itemRepositoryProvider.overrideWithValue(items)]);
    await c.read(itemEditControllerProvider('a').future);
    final n = c.read(itemEditControllerProvider('a').notifier);
    n.updateDraft((i) => i.copyWith(title: 'Keep this draft'));
    items.fail = true;
    await expectLater(n.commit(), throwsStateError);
    expect(n.hasUnsavedDraft, isTrue);
    expect(
      c.read(itemEditControllerProvider('a')).valueOrNull!.title,
      'Keep this draft',
    );
    items.fail = false;
    expect(await n.commit(), isTrue);
    expect((await items.getById('a'))!.title, 'Keep this draft');
  });

  test(
    'completion waits for an in-flight save and cannot be overwritten by it',
    () async {
      final c = env.container([
        itemRepositoryProvider.overrideWithValue(items),
      ]);
      await c.read(itemEditControllerProvider('a').future);
      final n = c.read(itemEditControllerProvider('a').notifier);
      n.updateDraft((i) => i.copyWith(title: 'Final title'));
      items.entered = Completer<void>();
      final release = items.release = Completer<void>();
      final saving = n.commit();
      await items.entered!.future;
      final completing = n.complete();
      release.complete();
      await saving;
      await completing;
      final saved = await items.getById('a');
      expect(saved!.title, 'Final title');
      expect(saved.status, ItemStatus.done);
    },
  );
}
