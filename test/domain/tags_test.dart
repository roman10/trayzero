import 'package:cleartray/domain/entities/entities.dart';
import 'package:cleartray/domain/tags.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('names', () {
    test('cleanTagName trims, collapses spaces, drops sigils, and caps', () {
      expect(cleanTagName('  Big   Rocks '), 'Big Rocks');
      expect(cleanTagName('+kitchen'), 'kitchen');
      expect(cleanTagName('@#home'), 'home');
      expect(cleanTagName('C++'), 'C++');
      expect(cleanTagName(' + '), isNull);
      expect(cleanTagName(''), isNull);
      expect(cleanTagName('x' * 60)!.length, maxTagNameLength);
    });

    test('names are unique ignoring case, including non-ASCII', () {
      const tags = [
        Tag(id: 'a', name: 'Kitchen'),
        Tag(id: 'b', name: 'Émile', isPerson: true),
      ];
      expect(findTagByName(tags, 'kitchen')?.id, 'a');
      expect(findTagByName(tags, ' +KITCHEN ')?.id, 'a');
      expect(findTagByName(tags, 'émile')?.id, 'b');
      expect(findTagByName(tags, 'kitchens'), isNull);
      expect(findTagByName(tags, '+'), isNull);
    });

    test('sortTags orders alphabetically ignoring case', () {
      final sorted = sortTags(const [
        Tag(id: '1', name: 'banana'),
        Tag(id: '2', name: 'Apple'),
        Tag(id: '3', name: 'cherry'),
      ]);
      expect(sorted.map((t) => t.name), ['Apple', 'banana', 'cherry']);
    });
  });

  group('waitingOnNamesPerson', () {
    test('matches whole words ignoring case', () {
      expect(waitingOnNamesPerson('Alice', 'Alice'), isTrue);
      expect(waitingOnNamesPerson('alice (legal)', 'Alice'), isTrue);
      expect(waitingOnNamesPerson('Bob and Alice', 'alice'), isTrue);
      expect(waitingOnNamesPerson('Mary Ann Lee', 'Mary Ann'), isTrue);
    });

    test('does not match parts of words or missing text', () {
      expect(waitingOnNamesPerson('Alison', 'Ali'), isFalse);
      expect(waitingOnNamesPerson('Ann Mary', 'Mary Ann'), isFalse);
      expect(waitingOnNamesPerson(null, 'Alice'), isFalse);
      expect(waitingOnNamesPerson('Alice', '+'), isFalse);
    });
  });

  group('buildAgendas', () {
    final at = DateTime(2026, 10, 27);
    Item item(
      String id,
      ItemStatus status, {
      String? waitingOn,
      DateTime? completedAt,
    }) => Item(
      id: id,
      title: id,
      status: status,
      waitingOn: waitingOn,
      completedAt: completedAt,
      createdAt: at,
      updatedAt: at,
    );
    const alice = Tag(id: 't-alice', name: 'Alice', isPerson: true);
    const bob = Tag(id: 't-bob', name: 'bob', isPerson: true);
    const kitchen = Tag(id: 't-kitchen', name: 'Kitchen');

    test('one agenda per person with tagged and waiting-on items', () {
      final agendas = buildAgendas(
        tags: const [kitchen, bob, alice],
        items: [
          item('next', ItemStatus.nextAction),
          item('inbox', ItemStatus.inbox),
          item('someday', ItemStatus.someday),
          item('done', ItemStatus.done, completedAt: at),
          item('waiting', ItemStatus.waiting, waitingOn: 'Alice from legal'),
          item('tagged-waiting', ItemStatus.waiting, waitingOn: 'Alice'),
          item('kitchen', ItemStatus.nextAction),
        ],
        itemTags: const {
          'next': ['t-alice', 't-kitchen'],
          'inbox': ['t-alice'],
          'someday': ['t-alice'],
          'done': ['t-alice'],
          'tagged-waiting': ['t-alice'],
          'kitchen': ['t-kitchen'],
        },
      );
      expect(agendas.map((a) => a.person.name), ['Alice', 'bob']);
      final [a, b] = agendas;
      expect(a.tagged.map((i) => i.id), ['next', 'inbox', 'tagged-waiting']);
      expect(a.waitingOn.map((i) => i.id), ['waiting']);
      expect(a.count, 4);
      expect(b.count, 0);
    });

    test('no person tags means no agendas', () {
      expect(
        buildAgendas(
          tags: const [kitchen],
          items: [item('x', ItemStatus.nextAction)],
          itemTags: const {
            'x': ['t-kitchen'],
          },
        ),
        isEmpty,
      );
    });
  });

  group('planTagRestore', () {
    test('same id is updated in place, new tags are added', () {
      final plan = planTagRestore(
        const [
          Tag(id: 'a', name: 'Kitchen renamed', isPerson: true),
          Tag(id: 'n', name: 'New'),
        ],
        const [Tag(id: 'a', name: 'Kitchen')],
      );
      expect(plan.upserts, const [
        Tag(id: 'a', name: 'Kitchen renamed', isPerson: true),
        Tag(id: 'n', name: 'New'),
      ]);
      expect(plan.idMap, {'a': 'a', 'n': 'n'});
    });

    test('a name owned by another local tag merges onto it', () {
      final plan = planTagRestore(
        const [Tag(id: 'b', name: 'alice', isPerson: true)],
        const [Tag(id: 'a', name: 'Alice')],
      );
      expect(plan.idMap, {'b': 'a'});
      expect(plan.upserts, const [Tag(id: 'a', name: 'Alice', isPerson: true)]);
    });

    test('duplicate names inside the backup collapse to one tag', () {
      final plan = planTagRestore(const [
        Tag(id: 'x', name: 'Home'),
        Tag(id: 'y', name: 'HOME'),
      ], const []);
      expect(plan.idMap, {'x': 'x', 'y': 'x'});
      expect(plan.upserts, const [Tag(id: 'x', name: 'Home')]);
    });

    test('a renamed local tag frees its old name', () {
      final plan = planTagRestore(
        const [Tag(id: 'a', name: 'Garage'), Tag(id: 'b', name: 'Kitchen')],
        const [Tag(id: 'a', name: 'Kitchen')],
      );
      expect(plan.idMap, {'a': 'a', 'b': 'b'});
      expect(plan.upserts.map((t) => t.name), ['Garage', 'Kitchen']);
    });
  });
}
