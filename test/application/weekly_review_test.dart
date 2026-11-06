import 'package:cleartray/application/backup_service.dart';
import 'package:cleartray/application/providers.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:cleartray/features/review/weekly_review_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../support/harness.dart';

void main() {
  late TestEnv env;
  setUp(() async => env = await TestEnv.create());
  tearDown(() => env.dispose());

  test(
    'overlapping starts share one Review; progress resumes after a new container',
    () async {
      final first = env.container();
      final start = first.read(startWeeklyReviewProvider);
      final sessions = await Future.wait([start(), start()]);
      expect(sessions.map((s) => s.id).toSet(), hasLength(1));
      expect(await first.read(reviewRepositoryProvider).all(), hasLength(1));
      await first
          .read(saveWeeklyReviewStepProvider)
          .call(sessions.first.id, WeeklyReviewStep.projects);
      final second = env.container();
      final resumed = await second.read(startWeeklyReviewProvider).call();
      expect(resumed.id, sessions.first.id);
      expect(resumed.startedAt, sessions.first.startedAt);
      expect(resumed.currentStep, WeeklyReviewStep.projects);
    },
  );

  test(
    'finishing updates the same Review and a later start creates a fresh session',
    () async {
      final c = env.container();
      final review = await c.read(startWeeklyReviewProvider).call();
      await c
          .read(saveWeeklyReviewStepProvider)
          .call(review.id, WeeklyReviewStep.someday);
      env.clock.advance(const Duration(hours: 1));
      await c.read(finishWeeklyReviewProvider).call(review.id);
      final rows = await c.read(reviewRepositoryProvider).all();
      expect(rows.single.completedAt, env.clock.now());
      expect(rows.single.currentStep, WeeklyReviewStep.someday);
      await expectLater(
        c.read(finishWeeklyReviewProvider).call(review.id),
        throwsStateError,
      );
      final fresh = await c.read(startWeeklyReviewProvider).call();
      expect(fresh.id, isNot(review.id));
      expect(fresh.currentStep, WeeklyReviewStep.capture);
      await expectLater(
        c
            .read(saveWeeklyReviewStepProvider)
            .call(review.id, WeeklyReviewStep.actions),
        throwsStateError,
      );
    },
  );

  test('daily reviews never become the resumable Weekly Review', () async {
    final c = env.container();
    await c
        .read(reviewRepositoryProvider)
        .insert(
          ReviewLog(
            id: 'daily',
            type: ReviewType.daily,
            startedAt: env.clock.now(),
          ),
        );
    expect(
      (await c.read(startWeeklyReviewProvider).call()).type,
      ReviewType.weekly,
    );
  });

  test(
    'backup preserves the current step; v5 reviews start at capture',
    () async {
      final c = env.container();
      final review = await c.read(startWeeklyReviewProvider).call();
      await c
          .read(saveWeeklyReviewStepProvider)
          .call(review.id, WeeklyReviewStep.waiting);
      final backup = c.read(backupServiceProvider);
      final snapshot = await backup.export();
      expect((snapshot['reviews'] as List).single['currentStep'], 'waiting');
      await c
          .read(saveWeeklyReviewStepProvider)
          .call(review.id, WeeklyReviewStep.actions);
      await backup.import(snapshot);
      expect(
        (await c.read(startWeeklyReviewProvider).call()).currentStep,
        WeeklyReviewStep.waiting,
      );
      final legacy = Map<String, dynamic>.from(snapshot)..['version'] = 5;
      (legacy['reviews'] as List).first.remove('currentStep');
      await backup.import(legacy);
      expect(
        (await c.read(startWeeklyReviewProvider).call()).currentStep,
        WeeklyReviewStep.capture,
      );
      expect(BackupService.formatVersion, greaterThan(5));
    },
  );

  test(
    'adding a next action repairs a Project and status changes retain its outcome',
    () async {
      final c = env.container();
      final projects = c.read(projectRepositoryProvider);
      await projects.upsert(
        Project(
          id: 'p',
          title: 'Launch',
          outcome: 'Reach launch day',
          status: ProjectStatus.active,
          createdAt: env.clock.now(),
          updatedAt: env.clock.now(),
        ),
      );
      await c.read(addProjectNextActionProvider).call('p', '  Email Sara  ');
      final item = (await c.read(itemRepositoryProvider).allActive()).single;
      expect(item.title, 'Email Sara');
      expect(item.projectId, 'p');
      expect(item.status, ItemStatus.nextAction);
      await c.read(changeProjectStatusProvider).call('p', ProjectStatus.onHold);
      expect((await projects.getById('p'))!.outcome, 'Reach launch day');
      expect((await projects.getById('p'))!.status, ProjectStatus.onHold);
      await projects.delete('p');
      await expectLater(
        c.read(changeProjectStatusProvider).call('p', ProjectStatus.done),
        throwsStateError,
      );
      expect(await projects.getById('p'), isNull);
      await expectLater(
        c.read(addProjectNextActionProvider).call('missing', 'Action'),
        throwsStateError,
      );
      await expectLater(
        c.read(addProjectNextActionProvider).call('p', ' '),
        throwsArgumentError,
      );
    },
  );

  test('controller persists its step before reporting it to the UI', () async {
    final c = env.container();
    final subscription = c.listen(weeklyReviewControllerProvider, (_, _) {});
    addTearDown(subscription.close);
    await c.read(weeklyReviewControllerProvider.future);
    await c
        .read(weeklyReviewControllerProvider.notifier)
        .moveTo(WeeklyReviewStep.calendar);
    final review = c.read(weeklyReviewControllerProvider).requireValue;
    expect(review.currentStep, WeeklyReviewStep.calendar);
    expect(
      (await c.read(reviewRepositoryProvider).all()).single.currentStep,
      WeeklyReviewStep.calendar,
    );
  });
}
