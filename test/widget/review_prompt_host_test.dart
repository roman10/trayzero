import 'dart:async';

import 'package:cleartray/application/maybe_request_app_review.dart';
import 'package:cleartray/application/review_prompt_scheduler.dart';
import 'package:cleartray/core/app_review.dart';
import 'package:cleartray/core/clock.dart';
import 'package:cleartray/features/common/review_prompt_host.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _Prompter extends AppReviewPrompter {
  int requests = 0;
  Completer<bool>? availability;
  @override
  Future<bool> isAvailable() async =>
      availability == null ? true : availability!.future;
  @override
  Future<void> requestReview() async {
    requests++;
  }
}

void main() {
  late _Prompter prompter;
  late ProviderContainer container;
  late GoRouter router;
  late ReviewPromptScheduler scheduler;
  late FakeClock clock;
  late InMemoryReviewPromptStore store;

  Future<void> boot(WidgetTester tester, {bool eligible = true}) async {
    prompter = _Prompter();
    clock = FakeClock(DateTime(2026, 11, 13));
    store = InMemoryReviewPromptStore(
      eligible
          ? ReviewPromptState(
              firstSessionAt: DateTime(2026, 10, 1),
              activeDays: {
                '2026-10-1',
                '2026-10-2',
                '2026-10-3',
                '2026-10-4',
                '2026-10-5',
              },
            )
          : const ReviewPromptState(),
    );
    container = ProviderContainer(
      overrides: [
        appReviewPrompterProvider.overrideWithValue(prompter),
        reviewPromptStoreProvider.overrideWithValue(store),
        clockProvider.overrideWithValue(clock),
      ],
    );
    scheduler = container.read(reviewPromptSchedulerProvider);
    router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: Text('Home')),
        ),
        GoRoute(
          path: '/other',
          builder: (_, _) => const Scaffold(body: Text('Other')),
        ),
      ],
    );
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox());
      router.dispose();
      container.dispose();
    });
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
          builder: (_, child) =>
              ReviewPromptHost(router: router, child: child!),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  void schedule({Future<void>? settled, bool Function()? relevant}) =>
      scheduler.schedule(
        ReviewMoment.inboxZero,
        settled: settled ?? Future.value(),
        isRelevant: relevant ?? () => true,
      );

  testWidgets('records the launch day when the host mounts', (tester) async {
    await boot(tester, eligible: false);
    expect(store.load().firstSessionAt, clock.now());
    expect(store.load().activeDays, {'2026-11-13'});
  });

  testWidgets('waits for feedback, then a quiet second', (tester) async {
    await boot(tester);
    final feedback = Completer<void>();
    schedule(settled: feedback.future);
    await tester.pump(const Duration(seconds: 10));
    expect(prompter.requests, 0);
    feedback.complete();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 999));
    expect(prompter.requests, 0);
    await tester.pump(const Duration(milliseconds: 1));
    expect(prompter.requests, 1);
  });

  for (final action in ['touch', 'keyboard', 'navigation', 'background']) {
    testWidgets('$action cancels a pending opportunity', (tester) async {
      await boot(tester);
      final feedback = Completer<void>();
      schedule(settled: feedback.future);
      switch (action) {
        case 'touch':
          await tester.tap(find.text('Home'));
        case 'keyboard':
          await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
        case 'navigation':
          router.go('/other');
          await tester.pumpAndSettle();
        case 'background':
          tester.binding.handleAppLifecycleStateChanged(
            AppLifecycleState.paused,
          );
      }
      feedback.complete();
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      expect(prompter.requests, 0);
      expect(store.load().prompts, 0);
      if (action == 'background') {
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
      }
    });
  }

  testWidgets('cancels while the store availability check is pending', (
    tester,
  ) async {
    await boot(tester);
    prompter.availability = Completer<bool>();
    schedule();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Home'));
    prompter.availability!.complete(true);
    await tester.pump();
    expect(prompter.requests, 0);
    expect(store.load().prompts, 0);
  });

  testWidgets('new completions while inactive do not request a review', (
    tester,
  ) async {
    await boot(tester);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    schedule();
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    expect(prompter.requests, 0);
    expect(store.load().prompts, 0);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump(const Duration(seconds: 2));
    expect(prompter.requests, 0);
    schedule();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(prompter.requests, 1);
  });

  testWidgets('revalidates the milestone before requesting', (tester) async {
    await boot(tester);
    var relevant = true;
    schedule(relevant: () => relevant);
    await tester.pump();
    relevant = false;
    await tester.pump(const Duration(seconds: 2));
    expect(prompter.requests, 0);
  });

  testWidgets('foreground interaction and resume count distinct dates', (
    tester,
  ) async {
    await boot(tester);
    await store.save(const ReviewPromptState());
    await tester.tap(find.text('Home'));
    await tester.pump();
    await tester.tap(find.text('Home'));
    await tester.pump();
    expect(store.load().activeDays, hasLength(1));
    clock.advance(const Duration(days: 1));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(store.load().activeDays, hasLength(2));
    clock.advance(const Duration(days: 1));
    await tester.tap(find.text('Home'));
    await tester.pump();
    expect(store.load().activeDays, hasLength(3));
  });
}
