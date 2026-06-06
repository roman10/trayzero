import 'package:cleartray/domain/entities/entities.dart';
import 'package:cleartray/features/projects/project_detail_screen.dart';
import 'package:flutter_test/flutter_test.dart';

Item _i(String id) => Item(
      id: id,
      title: id,
      status: ItemStatus.nextAction,
      createdAt: DateTime(2026, 5, 18),
      updatedAt: DateTime(2026, 5, 18),
    );

void main() {
  group('reorderedActionIds (onReorderItem destination semantics)', () {
    test('moving an item down: newIndex is the destination after removal', () {
      // Drag "a" (0) to the end of [a,b,c]. With `onReorderItem` the
      // framework passes newIndex == 2 — the actual destination after a
      // is removed — not the legacy `onReorder` value of 3.
      expect(reorderedActionIds(['a', 'b', 'c'], 0, 2), ['b', 'c', 'a']);
    });

    test('moving an item up uses newIndex as-is', () {
      expect(reorderedActionIds(['a', 'b', 'c'], 2, 0), ['c', 'a', 'b']);
    });

    test('adjacent swap downward', () {
      expect(reorderedActionIds(['a', 'b'], 0, 1), ['b', 'a']);
    });
  });

  group('applyManualOrder', () {
    test('null pending → unchanged live order', () {
      final live = [_i('a'), _i('b')];
      expect(applyManualOrder(live, null), live);
    });

    test('reorders live to follow the pending id sequence', () {
      final live = [_i('a'), _i('b'), _i('c')];
      expect(
        applyManualOrder(live, ['c', 'a', 'b']).map((e) => e.id).toList(),
        ['c', 'a', 'b'],
      );
    });

    test('items not in pending keep their DB position at the end', () {
      // "d" was added elsewhere after the drop; it must not vanish.
      final live = [_i('a'), _i('b'), _i('d')];
      expect(
        applyManualOrder(live, ['b', 'a']).map((e) => e.id).toList(),
        ['b', 'a', 'd'],
      );
    });

    test('pending ids no longer present are skipped', () {
      final live = [_i('a'), _i('c')];
      expect(
        applyManualOrder(live, ['c', 'b', 'a']).map((e) => e.id).toList(),
        ['c', 'a'],
      );
    });
  });
}
