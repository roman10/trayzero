import 'package:cleartray/domain/entities/entities.dart';
import 'package:cleartray/features/engage/engage_controller.dart';
import 'package:flutter_test/flutter_test.dart';

Item _item({
  required String id,
  String? contextId,
  Energy? energy,
  int? timeEstimateMinutes,
}) {
  final ts = DateTime(2026, 5, 16);
  return Item(
    id: id,
    title: id,
    status: ItemStatus.nextAction,
    contextId: contextId,
    energy: energy,
    timeEstimateMinutes: timeEstimateMinutes,
    createdAt: ts,
    updatedAt: ts,
  );
}

void main() {
  group('applyEngageFilter', () {
    final items = [
      _item(id: 'a', contextId: 'home', energy: Energy.low, timeEstimateMinutes: 5),
      _item(id: 'b', contextId: 'work', energy: Energy.high, timeEstimateMinutes: 60),
      _item(id: 'c', contextId: 'home', energy: Energy.high),
    ];

    test('empty filter returns everything', () {
      expect(applyEngageFilter(items, const EngageFilter()).map((i) => i.id),
          ['a', 'b', 'c']);
    });

    test('filters by tag, combined with context by AND', () {
      const tags = {
        'a': ['kitchen'],
        'b': ['kitchen', 'alice'],
      };
      expect(
        applyEngageFilter(
          items,
          const EngageFilter(tagId: 'kitchen'),
          itemTags: tags,
        ).map((i) => i.id),
        ['a', 'b'],
      );
      expect(
        applyEngageFilter(
          items,
          const EngageFilter(tagId: 'kitchen', contextId: 'work'),
          itemTags: tags,
        ).map((i) => i.id),
        ['b'],
      );
      expect(const EngageFilter(tagId: 'x').isEmpty, isFalse);
      expect(const EngageFilter(tagId: 'x').withContext('c').tagId, 'x');
    });

    test('filters by context', () {
      final r = applyEngageFilter(items, const EngageFilter(contextId: 'home'));
      expect(r.map((i) => i.id), ['a', 'c']);
    });

    test('filters by energy', () {
      final r =
          applyEngageFilter(items, const EngageFilter(energy: Energy.high));
      expect(r.map((i) => i.id), ['b', 'c']);
    });

    test('max-time excludes items over the cap and items with no estimate', () {
      final r =
          applyEngageFilter(items, const EngageFilter(maxTimeMinutes: 10));
      expect(r.map((i) => i.id), ['a']);
    });

    test('combines all three dimensions (AND)', () {
      final r = applyEngageFilter(
        items,
        const EngageFilter(
            contextId: 'home', energy: Energy.low, maxTimeMinutes: 5),
      );
      expect(r.map((i) => i.id), ['a']);
    });
  });

  group('EngageFilterController', () {
    test('setters preserve other dimensions and clear resets', () {
      final c = EngageFilterController()
        ..setContext('home')
        ..setEnergy(Energy.high)
        ..setMaxTime(30);
      expect(c.state.contextId, 'home');
      expect(c.state.energy, Energy.high);
      expect(c.state.maxTimeMinutes, 30);
      expect(c.state.isEmpty, isFalse);

      c.setContext(null);
      expect(c.state.contextId, isNull);
      expect(c.state.energy, Energy.high, reason: 'other dims preserved');

      c.clear();
      expect(c.state.isEmpty, isTrue);
    });

    test('EngageFilter equality is value-based', () {
      expect(const EngageFilter(contextId: 'x'),
          const EngageFilter(contextId: 'x'));
      expect(const EngageFilter(contextId: 'x'),
          isNot(const EngageFilter(contextId: 'y')));
    });
  });
}
