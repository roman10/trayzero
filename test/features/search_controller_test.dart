import 'package:cleartray/domain/entities/entities.dart';
import 'package:cleartray/features/search/search_controller.dart';
import 'package:flutter_test/flutter_test.dart';

Item _item({
  required String id,
  ItemStatus status = ItemStatus.nextAction,
  String? projectId,
  String? contextId,
}) {
  final ts = DateTime(2026, 5, 16);
  return Item(
    id: id,
    title: id,
    status: status,
    projectId: projectId,
    contextId: contextId,
    createdAt: ts,
    updatedAt: ts,
  );
}

void main() {
  group('applySearchFilter', () {
    final items = [
      _item(id: 'inbox', status: ItemStatus.inbox),
      _item(id: 'next', status: ItemStatus.nextAction),
      _item(id: 'waiting', status: ItemStatus.waiting),
      _item(id: 'someday', status: ItemStatus.someday),
      _item(id: 'reference', status: ItemStatus.reference),
      _item(id: 'project', status: ItemStatus.project),
      _item(id: 'calendar', status: ItemStatus.calendar),
      _item(id: 'done', status: ItemStatus.done),
      _item(id: 'trashed', status: ItemStatus.trashed),
    ];

    test('empty filter returns active statuses only, no done/trashed', () {
      final r = applySearchFilter(items, const SearchFilter());
      expect(r.map((i) => i.id),
          ['inbox', 'next', 'waiting', 'someday', 'reference', 'calendar']);
    });

    test('empty status set means all-active, NOT match-nothing', () {
      final r = applySearchFilter(items, const SearchFilter(statuses: {}));
      expect(r, isNotEmpty);
      expect(r.map((i) => i.id),
          ['inbox', 'next', 'waiting', 'someday', 'reference', 'calendar']);
    });

    test('explicit calendar status returns only calendar items', () {
      final r = applySearchFilter(
          items, const SearchFilter(statuses: {ItemStatus.calendar}));
      expect(r.map((i) => i.id), ['calendar']);
    });

    test('includeCompleted adds done but never trashed', () {
      final r = applySearchFilter(
          items, const SearchFilter(includeCompleted: true));
      expect(r.map((i) => i.id), contains('done'));
      expect(r.map((i) => i.id), isNot(contains('trashed')));
    });

    test('trashed is excluded even when explicitly passed in', () {
      final r = applySearchFilter(
        [_item(id: 't', status: ItemStatus.trashed)],
        const SearchFilter(
            statuses: {ItemStatus.trashed}, includeCompleted: true),
      );
      expect(r, isEmpty);
    });

    test('explicit status set narrows; done stays governed by the toggle',
        () {
      final onlyWaiting =
          applySearchFilter(items, const SearchFilter(statuses: {
        ItemStatus.waiting,
      }));
      expect(onlyWaiting.map((i) => i.id), ['waiting']);

      // Selecting only `waiting` must NOT hide done when includeCompleted.
      final waitingPlusDone = applySearchFilter(
        items,
        const SearchFilter(
            statuses: {ItemStatus.waiting}, includeCompleted: true),
      );
      expect(waitingPlusDone.map((i) => i.id), ['waiting', 'done']);
    });

    test('filters by project; null = any', () {
      final scoped = [
        _item(id: 'a', projectId: 'p1'),
        _item(id: 'b', projectId: 'p2'),
        _item(id: 'c'),
      ];
      expect(
        applySearchFilter(scoped, const SearchFilter(projectId: 'p1'))
            .map((i) => i.id),
        ['a'],
      );
      expect(
        applySearchFilter(scoped, const SearchFilter()).map((i) => i.id),
        ['a', 'b', 'c'],
      );
    });

    test('filters by context; null = any', () {
      final scoped = [
        _item(id: 'a', contextId: 'home'),
        _item(id: 'b', contextId: 'work'),
      ];
      expect(
        applySearchFilter(scoped, const SearchFilter(contextId: 'home'))
            .map((i) => i.id),
        ['a'],
      );
    });

    test('dimensions combine with AND', () {
      final scoped = [
        _item(id: 'hit', status: ItemStatus.waiting, projectId: 'p1', contextId: 'home'),
        _item(id: 'wrongCtx', status: ItemStatus.waiting, projectId: 'p1', contextId: 'work'),
        _item(id: 'wrongStatus', status: ItemStatus.inbox, projectId: 'p1', contextId: 'home'),
      ];
      final r = applySearchFilter(
        scoped,
        const SearchFilter(
          statuses: {ItemStatus.waiting},
          projectId: 'p1',
          contextId: 'home',
        ),
      );
      expect(r.map((i) => i.id), ['hit']);
    });
  });

  group('SearchFilterController', () {
    test('toggleStatus adds then removes, preserving other dimensions', () {
      final c = SearchFilterController()
        ..setProject('p1')
        ..toggleStatus(ItemStatus.waiting);
      expect(c.state.statuses, {ItemStatus.waiting});
      expect(c.state.projectId, 'p1');

      c.toggleStatus(ItemStatus.waiting);
      expect(c.state.statuses, isEmpty);
      expect(c.state.projectId, 'p1', reason: 'other dims preserved');
    });

    test('setters preserve other dimensions; clear resets', () {
      final c = SearchFilterController()
        ..toggleStatus(ItemStatus.inbox)
        ..setIncludeCompleted(true)
        ..setProject('p1')
        ..setContext('home');
      expect(c.state.isEmpty, isFalse);
      expect(c.state.activeCount, 4);

      c.setContext(null);
      expect(c.state.contextId, isNull);
      expect(c.state.includeCompleted, isTrue, reason: 'others preserved');

      c.clear();
      expect(c.state.isEmpty, isTrue);
      expect(c.state.activeCount, 0);
    });

    test('SearchFilter equality is value-based incl. the status set', () {
      expect(
        const SearchFilter(statuses: {ItemStatus.inbox, ItemStatus.waiting}),
        const SearchFilter(statuses: {ItemStatus.waiting, ItemStatus.inbox}),
        reason: 'set order must not matter',
      );
      expect(
        const SearchFilter(statuses: {ItemStatus.inbox}).hashCode,
        const SearchFilter(statuses: {ItemStatus.inbox}).hashCode,
      );
      expect(
        const SearchFilter(projectId: 'x'),
        isNot(const SearchFilter(projectId: 'y')),
      );
    });

    test('activeCount counts each engaged dimension once', () {
      expect(const SearchFilter().activeCount, 0);
      expect(
          const SearchFilter(statuses: {ItemStatus.inbox}).activeCount, 1);
      expect(
        const SearchFilter(
          statuses: {ItemStatus.inbox},
          includeCompleted: true,
          projectId: 'p',
          contextId: 'c',
        ).activeCount,
        4,
      );
    });
  });
}
