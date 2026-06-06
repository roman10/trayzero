import 'package:cleartray/domain/entities/entities.dart';
import 'package:cleartray/features/projects/projects_controller.dart';
import 'package:flutter_test/flutter_test.dart';

Project _p(String id, ProjectStatus status, {String? areaId}) {
  final ts = DateTime(2026, 5, 16);
  return Project(
    id: id,
    title: id,
    status: status,
    areaId: areaId,
    createdAt: ts,
    updatedAt: ts,
  );
}

void main() {
  group('groupProjects', () {
    test('no areas: single Active section then status sections', () {
      final sections = groupProjects([
        _p('a1', ProjectStatus.active),
        _p('h1', ProjectStatus.onHold),
        _p('s1', ProjectStatus.someday),
        _p('d1', ProjectStatus.done),
        _p('x1', ProjectStatus.dropped),
      ], const []);

      expect(sections.map((s) => s.label),
          ['Active', 'On hold', 'Someday', 'Completed']);
      // dropped is never surfaced
      expect(
        sections.expand((s) => s.projects).map((p) => p.id),
        isNot(contains('x1')),
      );
    });

    test('with areas: active grouped by area order then Unfiled', () {
      final areas = [
        const Area(id: 'work', name: 'Work'),
        const Area(id: 'home', name: 'Home'),
      ];
      final sections = groupProjects([
        _p('w1', ProjectStatus.active, areaId: 'work'),
        _p('u1', ProjectStatus.active),
        _p('h1', ProjectStatus.active, areaId: 'home'),
      ], areas);

      expect(sections.map((s) => s.label), ['Work', 'Home', 'Unfiled']);
      expect(sections[0].projects.single.id, 'w1');
      expect(sections[2].projects.single.id, 'u1');
    });

    test('areas with no active projects fall back to no Active section', () {
      final sections = groupProjects(
        [_p('h1', ProjectStatus.onHold)],
        [const Area(id: 'work', name: 'Work')],
      );
      expect(sections.map((s) => s.label), ['On hold']);
    });

    test('empty input yields no sections', () {
      expect(groupProjects(const [], const []), isEmpty);
    });
  });
}
