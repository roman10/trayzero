import 'package:cleartray/domain/entities/entities.dart';
import 'package:cleartray/domain/project_movement.dart';
import 'package:cleartray/features/review/weekly_review_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

void main() {
  final now = DateTime(2026, 10, 13, 9);
  Project project(String id, ProjectStatus status) => Project(
    id: id,
    title: id,
    status: status,
    createdAt: now,
    updatedAt: now,
  );

  test(
    'stalled active Projects lead; waiting/scheduled actions count; closed Projects are excluded',
    () {
      final projects = [
        project('healthy', ProjectStatus.active),
        project('stalled', ProjectStatus.active),
        project('waiting', ProjectStatus.active),
        project('held', ProjectStatus.onHold),
        project('done', ProjectStatus.done),
        project('dropped', ProjectStatus.dropped),
      ];
      final items = [
        anItem(
          projectId: 'healthy',
          status: ItemStatus.nextAction,
          deferUntil: now.add(const Duration(days: 3)),
        ),
        anItem(projectId: 'waiting', status: ItemStatus.calendar, dueAt: now),
        anItem(projectId: 'stalled', status: ItemStatus.done),
        anItem(projectId: 'stalled', status: ItemStatus.someday),
      ];
      final result = reviewProjects(projects, items);
      expect(result.map((p) => p.project.id), [
        'stalled',
        'healthy',
        'waiting',
        'held',
      ]);
      expect(result[0].movement, ProjectMovement.stalled);
      expect(result[1].movement, ProjectMovement.healthy);
      expect(result[2].movement, ProjectMovement.awaiting);
    },
  );

  test(
    'action review includes deferred work; each step uses its canonical list',
    () {
      final items = [
        anItem(id: 'inbox'),
        anItem(
          id: 'future',
          status: ItemStatus.nextAction,
          deferUntil: now.add(const Duration(days: 30)),
        ),
        anItem(id: 'waiting', status: ItemStatus.waiting),
        anItem(id: 'someday', status: ItemStatus.someday),
      ];
      expect(
        reviewStepItems(items, WeeklyReviewStep.capture, now).single.id,
        'inbox',
      );
      expect(
        reviewStepItems(items, WeeklyReviewStep.actions, now).single.id,
        'future',
      );
      expect(
        reviewStepItems(items, WeeklyReviewStep.waiting, now).single.id,
        'waiting',
      );
      expect(
        reviewStepItems(items, WeeklyReviewStep.someday, now).single.id,
        'someday',
      );
    },
  );

  test(
    'calendar review includes missed commitments and the next two weeks, sorted by due date',
    () {
      final items = [
        anItem(
          id: 'later',
          status: ItemStatus.calendar,
          dueAt: DateTime(2026, 10, 28),
        ),
        anItem(
          id: 'last',
          status: ItemStatus.calendar,
          dueAt: DateTime(2026, 10, 27, 23, 59),
        ),
        anItem(
          id: 'missed',
          status: ItemStatus.calendar,
          dueAt: DateTime(2026, 10, 12),
        ),
        anItem(
          id: 'today',
          status: ItemStatus.calendar,
          dueAt: DateTime(2026, 10, 13),
        ),
        anItem(id: 'invalid', status: ItemStatus.calendar),
      ];
      expect(
        reviewStepItems(items, WeeklyReviewStep.calendar, now).map((i) => i.id),
        ['missed', 'today', 'last'],
      );
    },
  );

  group('inactive projects (ADR 0007)', () {
    final now = DateTime(2026, 10, 26, 9);
    Project project(String id, {DateTime? created, ProjectStatus? status}) =>
        Project(
          id: id,
          title: id,
          status: status ?? ProjectStatus.active,
          createdAt: created ?? DateTime(2026, 1, 1),
          updatedAt: created ?? DateTime(2026, 1, 1),
        );

    test('flags 14+ days without action activity', () {
      final p = project('p');
      expect(isProjectInactive(p, DateTime(2026, 10, 12, 9), now), isTrue);
      expect(isProjectInactive(p, DateTime(2026, 10, 12, 9, 1), now), isFalse);
      // No Items: the Project's own creation is its activity.
      expect(isProjectInactive(p, null, now), isTrue);
      expect(
        isProjectInactive(project('new', created: DateTime(2026, 10, 20)),
            null, now),
        isFalse,
      );
      // Only active Projects can go quiet.
      expect(
        isProjectInactive(
            project('held', status: ProjectStatus.onHold), null, now),
        isFalse,
      );
    });

    test('sorts stalled, then inactive, then the rest', () {
      Item action(String projectId) => anItem(
            id: 'a-$projectId',
            status: ItemStatus.nextAction,
            projectId: projectId,
          );
      final result = reviewProjects(
        [
          project('a-moving'),
          project('b-quiet'),
          project('c-stalled'),
          project('d-held', status: ProjectStatus.onHold),
        ],
        [action('a-moving'), action('b-quiet')],
        activity: {
          'a-moving': DateTime(2026, 10, 25),
          'b-quiet': DateTime(2026, 9, 1),
        },
        now: now,
      );
      expect(result.map((r) => r.project.id),
          ['c-stalled', 'b-quiet', 'a-moving', 'd-held']);
      expect(result[0].movement, ProjectMovement.stalled);
      expect(result[1].inactive, isTrue);
      expect(result[2].inactive, isFalse);
    });
  });
}
