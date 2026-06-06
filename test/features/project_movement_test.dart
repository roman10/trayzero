import 'package:cleartray/domain/entities/entities.dart';
import 'package:cleartray/features/projects/project_movement.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

void main() {
  group('projectMovement', () {
    test('empty list -> stalled', () {
      expect(projectMovement(const <Item>[]), ProjectMovement.stalled);
    });

    test('any next action -> healthy', () {
      final items = [
        anItem(id: '1', status: ItemStatus.nextAction),
        anItem(id: '2', status: ItemStatus.waiting),
      ];
      expect(projectMovement(items), ProjectMovement.healthy);
    });

    test('only waiting items -> awaiting', () {
      final items = [anItem(id: '1', status: ItemStatus.waiting)];
      expect(projectMovement(items), ProjectMovement.awaiting);
    });

    test('only calendar items -> awaiting', () {
      final items = [anItem(id: '1', status: ItemStatus.calendar)];
      expect(projectMovement(items), ProjectMovement.awaiting);
    });

    test('mixed waiting + calendar -> awaiting', () {
      final items = [
        anItem(id: '1', status: ItemStatus.waiting),
        anItem(id: '2', status: ItemStatus.calendar),
      ];
      expect(projectMovement(items), ProjectMovement.awaiting);
    });

    test('only someday + reference -> stalled (not movement)', () {
      final items = [
        anItem(id: '1', status: ItemStatus.someday),
        anItem(id: '2', status: ItemStatus.reference),
      ];
      expect(projectMovement(items), ProjectMovement.stalled);
    });

    test('only inbox items -> stalled (unclarified is not movement)', () {
      final items = [anItem(id: '1', status: ItemStatus.inbox)];
      expect(projectMovement(items), ProjectMovement.stalled);
    });

    test('done and trashed items do not count as movement', () {
      final items = [
        anItem(id: '1', status: ItemStatus.done),
        anItem(id: '2', status: ItemStatus.trashed),
      ];
      expect(projectMovement(items), ProjectMovement.stalled);
    });

    test('next action wins over awaiting signals (healthy)', () {
      final items = [
        anItem(id: '1', status: ItemStatus.waiting),
        anItem(id: '2', status: ItemStatus.someday),
        anItem(id: '3', status: ItemStatus.nextAction),
      ];
      expect(projectMovement(items), ProjectMovement.healthy);
    });
  });
}
