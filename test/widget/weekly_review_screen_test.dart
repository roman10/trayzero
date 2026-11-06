import 'dart:async';

import 'package:cleartray/app/router.dart';
import 'package:cleartray/features/item_edit/item_edit_screen.dart';
import 'package:cleartray/app/theme.dart';
import 'package:cleartray/application/providers.dart';
import 'package:cleartray/data/repositories/review_repository.dart';
import 'package:cleartray/data/repositories/item_repository.dart';
import 'package:cleartray/features/common/complete_circle.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:cleartray/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../support/harness.dart';

class FailingReviewRepository extends ReviewRepository {
  FailingReviewRepository(super.db);
  bool fail = true;
  bool failFinish = false;
  @override
  Future<void> saveStep(String id, WeeklyReviewStep step) async {
    if (fail) throw StateError('write failed');
    await super.saveStep(id, step);
  }

  @override
  Future<void> finishWeekly(String id, DateTime now) async {
    if (failFinish) throw StateError('write failed');
    await super.finishWeekly(id, now);
  }
}

class FailingItemRepository extends ItemRepository {
  FailingItemRepository(super.db, super.clock);
  bool fail = true;
  @override
  Future<void> upsert(Item item) async {
    if (fail) throw StateError('write failed');
    await super.upsert(item);
  }
}

class GatedItemRepository extends ItemRepository {
  GatedItemRepository(super.db, super.clock);
  final gate = Completer<void>();
  @override
  Future<void> upsert(Item item) async {
    await gate.future;
    await super.upsert(item);
  }
}

void main() {
  late TestEnv env;
  late ProviderContainer c;
  late GoRouter router;

  setUp(() async {
    env = await TestEnv.create(prefsValues: {'onboarding_complete_v1': true});
  });
  tearDown(() => env.dispose());

  Future<void> openReview(
    WidgetTester tester, {
    WeeklyReviewStep? step,
    List<Override> overrides = const [],
    Locale? locale,
    double textScale = 1,
  }) async {
    c = ProviderContainer(overrides: env.overrides(overrides));
    if (step != null) {
      final session = await c.read(startWeeklyReviewProvider).call();
      await c.read(saveWeeklyReviewStepProvider).call(session.id, step);
    }
    router = c.read(routerProvider);
    router.go('/review');
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      router.dispose();
      c.dispose();
      // Drain existing Item Edit saved-indicator and Drift cancellation timers.
      await tester.pump(const Duration(seconds: 3));
    });
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: MaterialApp.router(
          theme: AppTheme.light(),
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.text(step == null ? 'Weekly review' : 'Resume weekly review'),
    );
    await tester.pumpAndSettle();
  }

  Future<void> next(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(FilledButton, 'Next'));
    await tester.pumpAndSettle();
  }

  Future<void> resize(WidgetTester tester, Size size) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  }

  testWidgets(
    'capture draft and session survive compact, roomy and short windows',
    (tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewInsets);
      await resize(tester, const Size(390, 844));
      c = env.container();
      for (var i = 0; i < 25; i++) {
        await c
            .read(itemRepositoryProvider)
            .upsert(
              anItem(
                id: 'inbox$i',
                title: 'Inbox $i',
                status: ItemStatus.inbox,
              ),
            );
      }
      await openReview(tester);
      final field = tester.widget<TextField>(find.byType(TextField));
      await tester.enterText(find.byType(TextField), 'Unfinished thought');
      final original = (await c.read(reviewRepositoryProvider).all()).single;
      for (final size in [
        const Size(900, 1000),
        const Size(1200, 900),
        const Size(844, 390),
        const Size(320, 568),
        const Size(900, 1000),
      ]) {
        await resize(tester, size);
        expect(
          tester.widget<TextField>(find.byType(TextField)).controller,
          same(field.controller),
        );
        expect(find.text('Unfinished thought'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('review-step-capture')),
          size.height > 480 && size.width > 560 ? findsOneWidget : findsNothing,
        );
      }
      FocusManager.instance.primaryFocus?.unfocus();
      final captureScroll = tester.state<ScrollableState>(
        find
            .descendant(
              of: find.byKey(const PageStorageKey(WeeklyReviewStep.capture)),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      captureScroll.position.jumpTo(1200);
      await resize(tester, const Size(390, 844));
      await resize(tester, const Size(900, 1000));
      captureScroll.position.jumpTo(0);
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller,
        same(field.controller),
      );
      expect(find.text('Unfinished thought'), findsOneWidget);
      tester.view.viewInsets = const FakeViewPadding(bottom: 650);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('review-step-capture')), findsNothing);
      expect(find.text('Unfinished thought'), findsOneWidget);
      expect(tester.takeException(), isNull);
      tester.view.resetViewInsets();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('review-step-waiting')));
      await tester.pumpAndSettle();
      final saved = (await c.read(reviewRepositoryProvider).all()).single;
      expect(saved.id, original.id);
      expect(saved.currentStep, WeeklyReviewStep.waiting);
      expect(saved.completedAt, isNull);
      await resize(tester, const Size(390, 844));
      expect(find.text('Step 4 of 7'), findsOneWidget);
    },
  );

  testWidgets(
    'review and editor retain scroll and drafts through resizing and return',
    (tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await resize(tester, const Size(900, 1000));
      c = env.container();
      for (var i = 0; i < 40; i++) {
        await c
            .read(itemRepositoryProvider)
            .upsert(
              anItem(
                id: 'a$i',
                title: 'Action $i',
                status: ItemStatus.nextAction,
              ),
            );
      }
      await openReview(tester, step: WeeklyReviewStep.actions);
      final reviewScroll = tester.state<ScrollableState>(
        find
            .descendant(
              of: find.byKey(const PageStorageKey(WeeklyReviewStep.actions)),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      reviewScroll.position.jumpTo(450);
      await tester.pumpAndSettle();
      final offset = reviewScroll.position.pixels;
      await resize(tester, const Size(390, 844));
      expect(reviewScroll.position.pixels, offset);
      await resize(tester, const Size(900, 1000));
      expect(reviewScroll.position.pixels, offset);
      final item = find
          .descendant(
            of: find.byKey(const PageStorageKey(WeeklyReviewStep.actions)),
            matching: find.text('Action 5'),
          )
          .first;
      await tester.tap(item);
      await tester.pumpAndSettle();
      expect(find.byTooltip('Resume weekly review'), findsOneWidget);
      expect(find.byType(BackButton), findsNothing);
      expect(find.byKey(const ValueKey('review-step-actions')), findsOneWidget);
      final editor = tester.state(find.byType(ItemEditScreen));
      final title = tester.widget<TextField>(find.byType(TextField).first);
      await tester.enterText(
        find.byType(TextField).first,
        'Edited during review',
      );
      final editorScroll = tester.state<ScrollableState>(
        find
            .descendant(
              of: find.byType(ItemEditScreen),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      editorScroll.position.jumpTo(180);
      await tester.pumpAndSettle();
      final editorOffset = editorScroll.position.pixels;
      for (final size in [const Size(390, 844), const Size(900, 1000)]) {
        await resize(tester, size);
        expect(tester.state(find.byType(ItemEditScreen)), same(editor));
        expect(title.controller!.text, 'Edited during review');
        expect(editorScroll.position.pixels, editorOffset);
      }
      await tester.tap(find.byTooltip('Resume weekly review'));
      await tester.pumpAndSettle();
      expect(find.byType(ItemEditScreen), findsNothing);
      expect(reviewScroll.position.pixels, offset);
      expect(find.text('Step 3 of 7'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      reviewScroll.position.jumpTo(0);
      await tester.pumpAndSettle();
      expect(find.text('Your place is saved when you leave.'), findsOneWidget);
      expect((await c.read(reviewRepositoryProvider).all()), hasLength(1));
      expect(
        (await c.read(itemRepositoryProvider).allActive()).where(
          (i) => i.title == 'Edited during review',
        ),
        hasLength(1),
      );
      await tester.pump(const Duration(seconds: 3));
    },
  );

  testWidgets('step rail navigation keeps the current step on a failed save', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await resize(tester, const Size(900, 1000));
    final repo = FailingReviewRepository(env.db);
    await openReview(
      tester,
      overrides: [reviewRepositoryProvider.overrideWithValue(repo)],
    );
    await tester.tap(find.byKey(const ValueKey('review-step-actions')));
    await tester.pumpAndSettle();
    expect((await repo.all()).single.currentStep, WeeklyReviewStep.capture);
    expect(
      tester
          .widget<ListTile>(find.byKey(const ValueKey('review-step-capture')))
          .selected,
      isTrue,
    );
    repo.fail = false;
    await tester.tap(find.byKey(const ValueKey('review-step-actions')));
    await tester.pumpAndSettle();
    expect((await repo.all()).single.currentStep, WeeklyReviewStep.actions);
    expect(
      tester
          .widget<ListTile>(find.byKey(const ValueKey('review-step-actions')))
          .selected,
      isTrue,
    );
  });

  testWidgets('return save failure retains editor and draft for retry', (
    tester,
  ) async {
    c = env.container();
    await c
        .read(itemRepositoryProvider)
        .upsert(
          anItem(id: 'a', title: 'Edit me', status: ItemStatus.nextAction),
        );
    final items = FailingItemRepository(env.db, env.clock);
    await openReview(
      tester,
      step: WeeklyReviewStep.actions,
      overrides: [itemRepositoryProvider.overrideWithValue(items)],
    );
    await tester.tap(find.text('Edit me'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Keep this draft');
    await tester.tap(find.byTooltip('Resume weekly review'));
    await tester.pumpAndSettle();
    expect(find.byType(ItemEditScreen), findsOneWidget);
    expect(find.text('Keep this draft'), findsOneWidget);
    items.fail = false;
    await tester.tap(find.byTooltip('Resume weekly review'));
    await tester.pumpAndSettle();
    expect(find.byType(ItemEditScreen), findsNothing);
    expect((await items.getById('a'))!.title, 'Keep this draft');
  });

  for (final config in const [
    (size: Size(320, 568), scale: 1.0),
    (size: Size(430, 932), scale: 1.0),
    (size: Size(844, 390), scale: 1.0),
    (size: Size(768, 1024), scale: 2.0),
    (size: Size(390, 844), scale: 3.0),
  ]) {
    testWidgets('guided flow fits ${config.size} at ${config.scale}x', (
      tester,
    ) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await resize(tester, config.size);
      await openReview(tester, textScale: config.scale);
      expect(find.byKey(const ValueKey('review-step-capture')), findsNothing);
      await tester.scrollUntilVisible(
        find.byType(TextField),
        200,
        scrollable: find
            .descendant(
              of: find.byKey(const PageStorageKey(WeeklyReviewStep.capture)),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      expect(find.byType(TextField), findsOneWidget);
      expect(tester.takeException(), isNull);
      await next(tester);
      expect(find.text('Step 2 of 7'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'captures, processes Inbox, and edits live actions without leaving the review',
    (tester) async {
      await openReview(tester);
      expect(find.text('Step 1 of 7'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Call Sara');
      await tester.tap(find.text('Add to inbox'));
      await tester.pumpAndSettle();
      expect(find.text('Call Sara'), findsOneWidget);
      await next(tester);
      expect(find.text('Step 2 of 7'), findsOneWidget);
      await tester.tap(find.text('Process inbox'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('No — keep as reference'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Back'));
      await tester.pumpAndSettle();
      expect(find.text('Step 2 of 7'), findsOneWidget);
      expect(find.text('Call Sara'), findsNothing);
      expect(
        (await c.read(itemRepositoryProvider).allActive()).single.status,
        ItemStatus.reference,
      );

      await c
          .read(itemRepositoryProvider)
          .upsert(
            anItem(id: 'a', title: 'Draft plan', status: ItemStatus.nextAction),
          );
      await next(tester);
      expect(find.text('Draft plan'), findsOneWidget);
      await tester.tap(find.text('Draft plan'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'Send plan');
      await tester.tap(find.byTooltip('Resume weekly review'));
      await tester.pumpAndSettle();
      expect(find.text('Step 3 of 7'), findsOneWidget);
      expect(find.text('Send plan'), findsOneWidget);
      expect(
        (await c.read(itemRepositoryProvider).getById('a'))!.title,
        'Send plan',
      );
      await tester.pump(const Duration(seconds: 3));
    },
  );

  testWidgets(
    'leaving and reopening resumes the same session and finishes it once',
    (tester) async {
      await openReview(tester);
      await next(tester);
      await next(tester);
      final original = (await c.read(reviewRepositoryProvider).all()).single;
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('Resume weekly review'), findsOneWidget);
      expect(
        (await c.read(reviewRepositoryProvider).all()).single.completedAt,
        isNull,
      );
      await tester.tap(find.text('Resume weekly review'));
      await tester.pumpAndSettle();
      expect(find.text('Step 3 of 7'), findsOneWidget);
      for (var i = 0; i < 4; i++) {
        await next(tester);
      }
      expect(find.text('Step 7 of 7'), findsOneWidget);
      await tester.tap(find.text('Finish review'));
      await tester.pumpAndSettle();
      final reviews = await c.read(reviewRepositoryProvider).all();
      expect(reviews, hasLength(1));
      expect(reviews.single.id, original.id);
      expect(reviews.single.completedAt, env.clock.now());
      expect(find.text('Step 7 of 7'), findsNothing);
      expect(find.text('Weekly review'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 100));
    },
  );

  testWidgets('capture prevents navigation until the write finishes', (
    tester,
  ) async {
    final items = GatedItemRepository(env.db, env.clock);
    await openReview(
      tester,
      overrides: [itemRepositoryProvider.overrideWithValue(items)],
    );
    await tester.enterText(find.byType(TextField), 'Call Sara');
    await tester.tap(find.text('Add to inbox'));
    await tester.pump();
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Next'))
          .onPressed,
      isNull,
    );
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Step 1 of 7'), findsOneWidget);
    items.gate.complete();
    await tester.pumpAndSettle();
    expect((await items.allActive()).single.title, 'Call Sara');
    await next(tester);
    expect(find.text('Step 2 of 7'), findsOneWidget);
  });

  testWidgets(
    'repairs stalled Projects while waiting work counts as movement',
    (tester) async {
      c = env.container();
      final repo = c.read(projectRepositoryProvider);
      for (final title in ['Launch', 'Pause', 'Finished', 'Awaiting']) {
        await repo.upsert(
          Project(
            id: title,
            title: title,
            status: ProjectStatus.active,
            createdAt: env.clock.now(),
            updatedAt: env.clock.now(),
          ),
        );
      }
      await c
          .read(itemRepositoryProvider)
          .upsert(
            anItem(id: 'w', projectId: 'Awaiting', status: ItemStatus.waiting),
          );
      await openReview(tester, step: WeeklyReviewStep.projects);
      expect(find.text('No next action defined'), findsNWidgets(3));
      expect(
        find.text('Waiting or scheduled work is moving this project forward.'),
        findsOneWidget,
      );
      Finder card(String title) =>
          find.ancestor(of: find.text(title), matching: find.byType(Card));
      await tester.ensureVisible(
        find.descendant(
          of: card('Launch'),
          matching: find.text('Add next action'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: card('Launch'),
          matching: find.text('Add next action'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Email Sara');
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Add'));
      await tester.pumpAndSettle();
      final added = (await c.read(itemRepositoryProvider).allActive())
          .singleWhere((i) => i.projectId == 'Launch');
      expect(added.status, ItemStatus.nextAction);
      expect(added.title, 'Email Sara');
      await tester.pumpAndSettle();
      expect(find.text('No next action defined'), findsNWidgets(2));
      await tester.ensureVisible(
        find.descendant(of: card('Pause'), matching: find.text('On hold')),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(of: card('Pause'), matching: find.text('On hold')),
      );
      await tester.pumpAndSettle();
      expect((await repo.getById('Pause'))!.status, ProjectStatus.onHold);
      await tester.ensureVisible(
        find.descendant(of: card('Finished'), matching: find.text('Done')),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(of: card('Finished'), matching: find.text('Done')),
      );
      await tester.pumpAndSettle();
      expect((await repo.getById('Finished'))!.status, ProjectStatus.done);
      expect(find.text('Finished'), findsNothing);
      expect(find.text('No next action defined'), findsNothing);
      // Closing a project offers Undo, which reopens it.
      expect(find.text('Completed'), findsOneWidget);
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect((await repo.getById('Finished'))!.status, ProjectStatus.active);
      await tester.pump(const Duration(seconds: 6));
    },
  );

  testWidgets('projects can be marked reviewed; quiet ones are flagged', (
    tester,
  ) async {
    c = env.container();
    final repo = c.read(projectRepositoryProvider);
    await repo.upsert(
      Project(
        id: 'quiet',
        title: 'Quiet',
        status: ProjectStatus.active,
        createdAt: env.clock.now().subtract(const Duration(days: 30)),
        updatedAt: env.clock.now().subtract(const Duration(days: 30)),
      ),
    );
    await c
        .read(itemRepositoryProvider)
        .upsert(
          anItem(
            id: 'q1',
            projectId: 'quiet',
            status: ItemStatus.nextAction,
          ).copyWith(
            updatedAt: env.clock.now().subtract(const Duration(days: 20)),
          ),
        );
    await openReview(tester, step: WeeklyReviewStep.projects);
    expect(find.text('No activity in 14+ days'), findsOneWidget);
    expect(find.text('Not reviewed yet'), findsOneWidget);
    expect(find.text('Reviewed 0 of 1'), findsOneWidget);

    await tester.ensureVisible(find.text('Mark reviewed'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mark reviewed'));
    await tester.pumpAndSettle();
    expect(find.text('Reviewed 1 of 1'), findsOneWidget);
    expect(find.text('Reviewed'), findsOneWidget);
    expect(find.text('Mark reviewed'), findsNothing);
    expect((await repo.getById('quiet'))!.lastReviewedAt, env.clock.now());
  });

  testWidgets('failed progress save stays on its step and can be retried', (
    tester,
  ) async {
    final repo = FailingReviewRepository(env.db);
    await openReview(
      tester,
      overrides: [reviewRepositoryProvider.overrideWithValue(repo)],
    );
    await next(tester);
    expect(find.text('Step 1 of 7'), findsOneWidget);
    expect(
      find.text('Could not save your progress. Please try again.'),
      findsOneWidget,
    );
    expect((await repo.all()).single.currentStep, WeeklyReviewStep.capture);
    repo.fail = false;
    await next(tester);
    expect(find.text('Step 2 of 7'), findsOneWidget);
  });

  testWidgets('failed Finish leaves the session incomplete and allows retry', (
    tester,
  ) async {
    final repo = FailingReviewRepository(env.db)
      ..fail = false
      ..failFinish = true;
    await openReview(
      tester,
      step: WeeklyReviewStep.someday,
      overrides: [reviewRepositoryProvider.overrideWithValue(repo)],
    );
    await tester.tap(find.text('Finish review'));
    await tester.pumpAndSettle();
    expect(find.text('Step 7 of 7'), findsOneWidget);
    expect((await repo.all()).single.completedAt, isNull);
    repo.failFinish = false;
    await tester.tap(find.text('Finish review'));
    await tester.pumpAndSettle();
    expect((await repo.all()).single.completedAt, env.clock.now());
    expect(find.text('Weekly review'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets(
    'next-action write failure retains the draft in its dialog for retry',
    (tester) async {
      c = env.container();
      await c
          .read(projectRepositoryProvider)
          .upsert(
            Project(
              id: 'p',
              title: 'Launch',
              status: ProjectStatus.active,
              createdAt: env.clock.now(),
              updatedAt: env.clock.now(),
            ),
          );
      final items = FailingItemRepository(env.db, env.clock);
      await openReview(
        tester,
        step: WeeklyReviewStep.projects,
        overrides: [itemRepositoryProvider.overrideWithValue(items)],
      );
      await tester.tap(find.text('Add next action'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Email Sara');
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Add'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Email Sara'), findsOneWidget);
      expect(
        find.text('Could not save this change. Please try again.'),
        findsOneWidget,
      );
      expect(await items.allActive(), isEmpty);
      items.fail = false;
      await tester.tap(find.widgetWithText(FilledButton, 'Add'));
      await tester.pumpAndSettle();
      expect((await items.allActive()).single.title, 'Email Sara');
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('No next action defined'), findsNothing);
    },
  );

  testWidgets('completion Undo still works after leaving the review', (
    tester,
  ) async {
    c = env.container();
    await c
        .read(itemRepositoryProvider)
        .upsert(
          anItem(id: 'a', title: 'Send plan', status: ItemStatus.nextAction),
        );
    await openReview(tester, step: WeeklyReviewStep.actions);
    await tester.tap(find.byType(CompleteCircle));
    await tester.pumpAndSettle();
    expect(
      (await c.read(itemRepositoryProvider).getById('a'))!.status,
      ItemStatus.done,
    );
    router.pop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(
      (await c.read(itemRepositoryProvider).getById('a'))!.status,
      ItemStatus.nextAction,
    );
    expect(tester.takeException(), isNull);
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('loading failures are shown rather than an empty review list', (
    tester,
  ) async {
    await openReview(
      tester,
      step: WeeklyReviewStep.waiting,
      overrides: [
        reviewItemsProvider.overrideWith(
          (_) => Stream.error(StateError('read failed')),
        ),
      ],
    );
    expect(find.text("Couldn't load this"), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    expect(find.text('Nothing to review here.'), findsNothing);
  });

  testWidgets(
    'German project actions and footer fit a small screen with large text',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      c = env.container();
      await c
          .read(projectRepositoryProvider)
          .upsert(
            Project(
              id: 'p',
              title: 'A long project title for the review',
              status: ProjectStatus.active,
              createdAt: env.clock.now(),
              updatedAt: env.clock.now(),
            ),
          );
      // English entry point, then change locale after opening to exercise layout.
      await openReview(tester, step: WeeklyReviewStep.projects, textScale: 2);
      expect(tester.takeException(), isNull);
      router.pop();
      await tester.pumpAndSettle();
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: c,
          child: MaterialApp.router(
            theme: AppTheme.dark(),
            locale: const Locale('de'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: router,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(2)),
              child: child!,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      unawaited(router.push('/review/weekly'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
