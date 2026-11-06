import 'package:cleartray/data/repositories/item_repository.dart';
import 'package:cleartray/data/repositories/tag_repository.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:cleartray/features/common/item_card.dart';
import 'package:cleartray/features/common/tag_picker.dart';
import 'package:cleartray/features/engage/engage_screen.dart';
import 'package:cleartray/features/review/review_screen.dart';
import 'package:cleartray/features/tags/agenda_screen.dart';
import 'package:cleartray/features/tags/tags_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

/// Tags, people, and Agendas UI (ADR 0010).
void main() {
  late TestEnv env;
  late ItemRepository items;
  late TagRepository tags;
  final created = DateTime(2026, 5, 1);

  setUp(() async {
    env = await TestEnv.create(now: DateTime(2026, 5, 14, 9));
    items = ItemRepository(env.db, env.clock);
    tags = TagRepository(env.db);
  });
  tearDown(() => env.dispose());

  Future<void> tag(String itemId, List<Tag> list) async {
    await tags.upsertAll(list, createdAt: created);
    await tags.replaceItemTags({itemId: list.map((t) => t.id)});
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  group('item card', () {
    testWidgets('no tags, no chips', (tester) async {
      final item = anItem(id: 'a', status: ItemStatus.nextAction);
      await items.upsert(item);
      await tags.upsert(
        const Tag(id: 'k', name: 'Kitchen'),
        createdAt: created,
      );
      await pumpApp(
        tester,
        Scaffold(body: ItemCard(item: item)),
        env: env,
      );
      await settle(tester);
      expect(find.text('Kitchen'), findsNothing);
      expect(find.byIcon(Icons.sell_outlined), findsNothing);
    });

    testWidgets('two chips then +N; the implied person is hidden', (
      tester,
    ) async {
      final item = anItem(id: 'a', status: ItemStatus.nextAction);
      await items.upsert(item);
      await tag('a', const [
        Tag(id: 'p', name: 'Alice', isPerson: true),
        Tag(id: 'b', name: 'Budget'),
        Tag(id: 'c', name: 'Calls'),
      ]);
      await pumpApp(
        tester,
        Scaffold(
          body: Column(
            children: [
              ItemCard(item: item),
              ItemCard(item: item, hiddenTagId: 'p'),
            ],
          ),
        ),
        env: env,
      );
      await settle(tester);
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Budget'), findsNWidgets(2));
      expect(find.text('+1'), findsOneWidget);
      expect(find.text('Calls'), findsOneWidget);
      final semantics = tester.ensureSemantics();
      await tester.pump();
      expect(find.bySemanticsLabel(RegExp('Person: Alice')), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('1 more tag')), findsOneWidget);
      semantics.dispose();
    });
  });

  testWidgets('tag picker creates and toggles tags on the item', (
    tester,
  ) async {
    await items.upsert(anItem(id: 'a'));
    await tags.upsert(
      const Tag(id: 'k', name: 'Kitchen'),
      createdAt: created,
    );
    await pumpApp(
      tester,
      const Scaffold(body: ItemTagsField(itemId: 'a')),
      env: env,
    );
    await settle(tester);

    await tester.tap(find.text('Add tag'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kitchen'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Bob');
    await tester.pumpAndSettle();
    expect(find.text('Create “Bob”'), findsOneWidget);
    await tester.tap(find.text('Create person “Bob”'));
    await tester.pumpAndSettle();

    final bob = (await tags.all()).firstWhere((t) => t.name == 'Bob');
    expect(bob.isPerson, isTrue);
    expect((await tags.tagIdsFor('a')).toSet(), {'k', bob.id});

    // Typing an existing name, in any case, offers no duplicate.
    await tester.enterText(find.byType(TextField), 'kitchen');
    await tester.pumpAndSettle();
    expect(find.textContaining('Create'), findsNothing);

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Remove Kitchen'));
    await tester.pumpAndSettle();
    expect(await tags.tagIdsFor('a'), [bob.id]);
  });

  group('review', () {
    testWidgets('no Agendas bucket until a tag is a person', (tester) async {
      await tags.upsert(
        const Tag(id: 'k', name: 'Kitchen'),
        createdAt: created,
      );
      await pumpApp(tester, const ReviewScreen(), env: env);
      await settle(tester);
      expect(find.text('Agendas'), findsNothing);

      await tags.upsert(
        const Tag(id: 'k', name: 'Kitchen', isPerson: true),
        createdAt: created,
      );
      await settle(tester);
      expect(find.text('Agendas'), findsOneWidget);
      expect(find.text('1 person'), findsOneWidget);
    });
  });

  group('agenda screen', () {
    testWidgets('empty, then add a point and check it off', (tester) async {
      await tags.upsert(
        const Tag(id: 'p', name: 'Alice', isPerson: true),
        createdAt: created,
      );
      await pumpApp(tester, const AgendaScreen(tagId: 'p'), env: env);
      await settle(tester);
      expect(find.text('Nothing to discuss with Alice yet.'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Ask about Q3');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.text('Ask about Q3'), findsOneWidget);
      // The person's own chip is not repeated on the card.
      expect(find.byIcon(Icons.person_outline), findsNothing);
      final added = (await env.db.select(env.db.items).get()).single;
      expect(added.status, ItemStatus.nextAction);
      expect(await tags.tagIdsFor(added.id), ['p']);
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller!.text, isEmpty);
      expect(field.focusNode!.hasFocus, isTrue);
    });

    testWidgets('waiting-for items naming the person are listed', (
      tester,
    ) async {
      await tags.upsert(
        const Tag(id: 'p', name: 'Alice', isPerson: true),
        createdAt: created,
      );
      await items.upsert(
        anItem(
          id: 'w',
          title: 'Signed lease',
          status: ItemStatus.waiting,
          waitingOn: 'Alice (legal)',
        ),
      );
      await pumpApp(tester, const AgendaScreen(tagId: 'p'), env: env);
      await settle(tester);
      expect(find.text('Waiting on Alice'), findsOneWidget);
      expect(find.text('Signed lease'), findsOneWidget);
    });

    testWidgets('a deleted person shows a message', (tester) async {
      await pumpApp(tester, const AgendaScreen(tagId: 'gone'), env: env);
      await settle(tester);
      expect(find.text('This person no longer exists.'), findsOneWidget);
    });
  });

  group('tags screen', () {
    testWidgets('empty state explains tags and +tag', (tester) async {
      await pumpApp(tester, const TagsScreen(), env: env);
      await settle(tester);
      expect(find.textContaining('type +tag'), findsOneWidget);
    });

    testWidgets('renaming onto an existing name offers a merge', (
      tester,
    ) async {
      await items.upsert(anItem(id: 'a', status: ItemStatus.nextAction));
      await tags.upsert(
        const Tag(id: 'k', name: 'Kitchen'),
        createdAt: created,
      );
      await tag('a', const [Tag(id: 's', name: 'kitchen stuff')]);
      await pumpApp(tester, const TagsScreen(), env: env);
      await settle(tester);
      expect(find.text('1 open item'), findsOneWidget);

      await tester.tap(find.text('kitchen stuff'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'KITCHEN');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(
        find.text('“Kitchen” already exists. Merge “kitchen stuff” into it?'),
        findsOneWidget,
      );
      await tester.tap(find.text('Merge'));
      await tester.pumpAndSettle();

      expect((await tags.all()).map((t) => t.id), ['k']);
      expect(await tags.tagIdsFor('a'), ['k']);
    });

    testWidgets('a tag can become a person', (tester) async {
      await tags.upsert(
        const Tag(id: 'b', name: 'Bob'),
        createdAt: created,
      );
      await pumpApp(tester, const TagsScreen(), env: env);
      await settle(tester);
      await tester.tap(find.text('Bob'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Switch));
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect((await tags.getById('b'))!.isPerson, isTrue);
    });
  });

  group('Do filter', () {
    testWidgets('no Tag chip until a tag exists', (tester) async {
      await pumpApp(tester, const EngageScreen(), env: env);
      await settle(tester);
      expect(find.widgetWithText(FilterChip, 'Tag'), findsNothing);
    });

    testWidgets('choosing a tag narrows the list', (tester) async {
      await items.upsert(
        anItem(id: 'a', title: 'Wipe counters', status: ItemStatus.nextAction),
      );
      await items.upsert(
        anItem(id: 'b', title: 'File taxes', status: ItemStatus.nextAction),
      );
      await tag('a', const [Tag(id: 'k', name: 'Kitchen')]);
      await pumpApp(tester, const EngageScreen(), env: env);
      await settle(tester);
      expect(find.text('File taxes'), findsOneWidget);

      await tester.ensureVisible(find.widgetWithText(FilterChip, 'Tag'));
      await tester.tap(find.widgetWithText(FilterChip, 'Tag'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, 'Kitchen'));
      await tester.pumpAndSettle();

      expect(find.text('Wipe counters'), findsOneWidget);
      expect(find.text('File taxes'), findsNothing);
      expect(find.widgetWithText(FilterChip, 'Kitchen'), findsOneWidget);
    });
  });

  group('large text', () {
    Future<void> phone(WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));
    }

    testWidgets('agenda screen fits a small phone at 3x German text', (
      tester,
    ) async {
      await phone(tester);
      await tags.upsert(
        const Tag(id: 'p', name: 'Alexandra Weißenberger', isPerson: true),
        createdAt: created,
      );
      await items.upsert(
        anItem(
          id: 'a',
          title: 'Budget für das dritte Quartal besprechen',
          status: ItemStatus.nextAction,
        ),
      );
      await tag('a', const [
        Tag(id: 'p', name: 'Alexandra Weißenberger', isPerson: true),
        Tag(id: 'k', name: 'Finanzplanung'),
      ]);
      await pumpApp(
        tester,
        const AgendaScreen(tagId: 'p'),
        env: env,
        locale: const Locale('de'),
        textScaler: const TextScaler.linear(3),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('tags screen and edit sheet fit at 3x German text', (
      tester,
    ) async {
      await phone(tester);
      await tags.upsert(
        const Tag(id: 'p', name: 'Alexandra', isPerson: true),
        createdAt: created,
      );
      await pumpApp(
        tester,
        const TagsScreen(),
        env: env,
        locale: const Locale('de'),
        textScaler: const TextScaler.linear(3),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Alexandra'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Speichern'));
      expect(find.text('Speichern'), findsOneWidget);
    });

    testWidgets('tag picker fits at 3x text', (tester) async {
      await phone(tester);
      await items.upsert(anItem(id: 'a'));
      await tags.upsert(
        const Tag(id: 'k', name: 'Küchenrenovierung'),
        createdAt: created,
      );
      await pumpApp(
        tester,
        const Scaffold(body: ItemTagsField(itemId: 'a')),
        env: env,
        locale: const Locale('de'),
        textScaler: const TextScaler.linear(3),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tag hinzufügen'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Neuer Name');
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('„Neuer Name“ erstellen'), findsOneWidget);
    });
  });
}
