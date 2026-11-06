import 'package:cleartray/application/manage_tags.dart';
import 'package:cleartray/application/providers.dart';
import 'package:cleartray/data/repositories/item_repository.dart';
import 'package:cleartray/data/repositories/tag_repository.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

/// Tags, people, and Agendas end to end through the use cases (ADR 0010).
void main() {
  late TestEnv env;
  late ProviderContainer c;
  late ManageTags manage;
  late TagRepository tags;
  late ItemRepository items;

  setUp(() async {
    env = await TestEnv.create(now: DateTime(2026, 10, 27, 9));
    c = env.container();
    manage = c.read(manageTagsProvider);
    tags = c.read(tagRepositoryProvider);
    items = c.read(itemRepositoryProvider);
  });
  tearDown(() => env.dispose());

  Future<void> addItem(
    String id, {
    ItemStatus status = ItemStatus.nextAction,
    String title = 'Item',
  }) => items.upsert(anItem(id: id, title: title, status: status));

  group('ManageTags', () {
    test(
      'obtain reuses a tag ignoring case and can make it a person',
      () async {
        final a = await manage.obtain(' +Alice ');
        final b = await manage.obtain('alice', isPerson: true);
        expect(a!.name, 'Alice');
        expect(b!.id, a.id);
        expect(b.isPerson, isTrue);
        expect(await tags.all(), [b]);
        expect(await manage.obtain('  '), isNull);
      },
    );

    test('rename reports a clash instead of creating a duplicate', () async {
      final kitchen = (await manage.obtain('Kitchen'))!;
      final stuff = (await manage.obtain('kitchen stuff'))!;
      expect(await manage.rename(stuff.id, 'KITCHEN'), isA<TagNameTaken>());
      expect(await manage.rename(stuff.id, '#'), isA<TagNameInvalid>());
      // Changing only the case of its own name is a rename.
      expect(await manage.rename(kitchen.id, 'kitchen'), isA<TagRenamed>());
      expect((await tags.getById(kitchen.id))!.name, 'kitchen');
    });

    test('merge moves items, keeps a person, and deletes the source', () async {
      await addItem('a');
      await addItem('b');
      final alice = (await manage.obtain('Alice', isPerson: true))!;
      final ali = (await manage.obtain('Ali'))!;
      await manage.setItemTags('a', [alice.id]);
      await manage.setItemTags('b', [alice.id, ali.id]);

      await manage.merge(alice.id, ali.id);

      expect(await tags.getById(alice.id), isNull);
      expect((await tags.getById(ali.id))!.isPerson, isTrue);
      expect(await tags.allItemTagIds(), {
        'a': [ali.id],
        'b': [ali.id],
      });
    });

    test('delete keeps the items; deleting an item drops its links', () async {
      await addItem('a');
      await addItem('b');
      final home = (await manage.obtain('Home'))!;
      final work = (await manage.obtain('Work'))!;
      await manage.setItemTags('a', [home.id, work.id]);
      await manage.setItemTags('b', [home.id]);

      await manage.delete(home.id);
      expect(await items.getById('a'), isNotNull);
      expect(await tags.allItemTagIds(), {
        'a': [work.id],
      });

      await items.delete('a');
      expect(await tags.allItemTagIds(), isEmpty);
      expect(await tags.isUsed(work.id), isFalse);
    });

    test('tag writes leave the item untouched', () async {
      await addItem('a');
      final before = (await items.getById('a'))!.updatedAt;
      env.clock.advance(const Duration(hours: 1));
      await manage.setItemTags('a', [(await manage.obtain('x'))!.id]);
      expect((await items.getById('a'))!.updatedAt, before);
    });

    test('open counts ignore done and trashed items', () async {
      await addItem('open');
      await addItem('done', status: ItemStatus.done);
      await addItem('trash', status: ItemStatus.trashed);
      final t = (await manage.obtain('Garage'))!;
      for (final id in ['open', 'done', 'trash']) {
        await manage.setItemTags(id, [t.id]);
      }
      expect(await tags.watchOpenCounts().first, {t.id: 1});
    });
  });

  test('capture attaches +tags, creating missing ones once', () async {
    final kitchen = (await manage.obtain('Kitchen'))!;
    final item = await c
        .read(captureItemProvider)
        .call(
          title: 'Wipe counters',
          tagNames: ['kitchen', 'Chores', 'chores'],
        );
    final all = await tags.all();
    expect(all.map((t) => t.name), ['Chores', 'Kitchen']);
    expect((await tags.tagIdsFor(item.id)).toSet(), {kitchen.id, all.first.id});
  });

  test('a recurring action carries its tags to the next occurrence', () async {
    await items.upsert(
      anItem(
        id: 'r',
        status: ItemStatus.nextAction,
        recurrence: Recurrence.weekly,
        deferUntil: DateTime(2026, 10, 27),
      ),
    );
    final t = (await manage.obtain('Garden'))!;
    await manage.setItemTags('r', [t.id]);

    final next = await c.read(completeItemProvider).call('r');

    expect(next, isNotNull);
    expect(await tags.tagIdsFor(next!), [t.id]);
    expect(await tags.tagIdsFor('r'), [t.id]);
  });

  test('search matches an item through its tag name', () async {
    await addItem('a', title: 'Fix the tap');
    await addItem('b', title: 'Unrelated');
    final t = (await manage.obtain('Kitchen'))!;
    await manage.setItemTags('a', [t.id]);
    final hits = await items.search('kitch', tagIds: [t.id]);
    expect(hits.map((i) => i.id), ['a']);
    expect(await items.search('kitch'), isEmpty);
  });

  group('agendas', () {
    test('adding to an agenda files a tagged next action', () async {
      final alice = (await manage.obtain('Alice', isPerson: true))!;
      final item = await c
          .read(addAgendaItemProvider)
          .call(alice.id, '  Ask about Q3  ');
      expect(item.title, 'Ask about Q3');
      expect(item.status, ItemStatus.nextAction);
      expect(await tags.tagIdsFor(item.id), [alice.id]);
    });

    test('adding to a deleted person fails without writing', () async {
      await expectLater(
        c.read(addAgendaItemProvider).call('gone', 'Hello'),
        throwsStateError,
      );
      expect(await env.db.select(env.db.items).get(), isEmpty);
    });

    test('the read model lists people with their open items', () async {
      final alice = (await manage.obtain('Alice', isPerson: true))!;
      await manage.obtain('Kitchen');
      await addItem('a', title: 'Budget');
      await items.upsert(
        anItem(id: 'w', status: ItemStatus.waiting, waitingOn: 'alice'),
      );
      await manage.setItemTags('a', [alice.id]);

      final sub = c.listen(agendasProvider, (_, _) {});
      addTearDown(sub.close);
      await c.read(tagsProvider.future);
      await c.read(itemTagIdsProvider.future);
      await c.read(reviewItemsProvider.future);

      final [agenda] = c.read(agendasProvider);
      expect(agenda.person.id, alice.id);
      expect(agenda.tagged.map((i) => i.id), ['a']);
      expect(agenda.waitingOn.map((i) => i.id), ['w']);
    });

    test('no person tag, no Agendas', () async {
      await manage.obtain('Kitchen');
      final sub = c.listen(agendasProvider, (_, _) {});
      addTearDown(sub.close);
      await c.read(tagsProvider.future);
      expect(c.read(agendasProvider), isEmpty);
    });
  });
}
