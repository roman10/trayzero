import 'package:cleartray/app/app.dart';
import 'package:cleartray/app/router.dart';
import 'package:cleartray/application/providers.dart';
import 'package:cleartray/core/app_review.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:cleartray/core/notification_scheduler.dart';
import 'package:cleartray/features/common/item_card.dart';
import 'package:cleartray/features/engage/today_controller.dart';
import 'package:cleartray/features/process/process_inbox_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../support/harness.dart';

class _Prompter extends AppReviewPrompter {
  int requests = 0;
  @override
  Future<bool> isAvailable() async => true;
  @override
  Future<void> requestReview() async {
    requests++;
  }
}

void main() {
  late TestEnv env;
  late ProviderContainer container;
  late _Prompter prompter;

  Future<void> boot(
    WidgetTester tester, {
    bool weekly = false,
    int todayTasks = 0,
    bool planToday = true,
    bool lastCalendar = false,
  }) async {
    ReceiveSharingIntent.setMockValues(
      initialMedia: [],
      mediaStream: const Stream.empty(),
    );
    PackageInfo.setMockInitialValues(
      appName: 'Trayzero',
      packageName: 'app.cleartray',
      version: '1.0.8',
      buildNumber: '57',
      buildSignature: '',
    );
    env = await TestEnv.create(prefsValues: {'onboarding_complete_v1': true});
    prompter = _Prompter();
    container = env.container([
      appReviewPrompterProvider.overrideWithValue(prompter),
      reviewPromptStoreProvider.overrideWithValue(
        InMemoryReviewPromptStore(
          ReviewPromptState(
            firstSessionAt: env.clock.now().subtract(const Duration(days: 30)),
            activeDays: {'a', 'b', 'c', 'd', 'e'},
          ),
        ),
      ),
    ]);
    if (todayTasks > 0) {
      await container.read(doViewProvider.notifier).set(DoView.today);
      for (var i = 0; i < todayTasks; i++) {
        await container
            .read(itemRepositoryProvider)
            .upsert(
              anItem(
                id: 'task-$i',
                title: 'Task $i',
                status: lastCalendar && i == todayTasks - 1
                    ? ItemStatus.calendar
                    : ItemStatus.nextAction,
                dueAt: lastCalendar && i == todayTasks - 1
                    ? env.clock.now()
                    : null,
              ).copyWith(focusedAt: env.clock.now()),
            );
      }
      if (planToday) {
        await container.read(finishDailyReviewProvider)(notKept: []);
      }
    } else if (weekly) {
      final review = await container.read(startWeeklyReviewProvider)();
      await container.read(saveWeeklyReviewStepProvider)(
        review.id,
        WeeklyReviewStep.someday,
      );
    } else {
      for (var i = 0; i < 5; i++) {
        await container
            .read(itemRepositoryProvider)
            .upsert(anItem(id: 'item-$i', title: 'Item $i'));
      }
    }
    final router = container.read(routerProvider);
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox());
      router.dispose();
      container.dispose();
      await env.dispose();
      await tester.pump(const Duration(seconds: 3));
    });
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TrayzeroApp(),
      ),
    );
    router.go(
      todayTasks > 0
          ? '/do'
          : weekly
          ? '/review'
          : '/process',
    );
    await tester.pumpAndSettle();
  }

  Future<void> clearInbox(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      await tester.tap(find.text('No — keep as reference'));
      await tester.pumpAndSettle();
    }
    expect(find.text('Inbox zero!'), findsOneWidget);
    expect(prompter.requests, 0);
  }

  Future<void> finishToday(WidgetTester tester, int count) async {
    for (var i = 0; i < count; i++) {
      final card = tester.widget<ItemCard>(
        find.byWidgetPredicate((w) => w is ItemCard && w.item.id == 'task-$i'),
      );
      card.onComplete!();
      await tester.pumpAndSettle();
    }
  }

  testWidgets('Today asks after three planned tasks and Undo expires', (
    tester,
  ) async {
    await boot(tester, todayTasks: 3);
    await finishToday(tester, 3);
    expect(prompter.requests, 0);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));
    expect(prompter.requests, 1);
  });

  testWidgets('last Calendar completion can finish Today', (tester) async {
    await boot(tester, todayTasks: 3, lastCalendar: true);
    await finishToday(tester, 3);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));
    expect(prompter.requests, 1);
  });

  for (final reason in [
    'small plan',
    'unfinished',
    'undo',
    'switch view',
    'unplanned',
    'new task',
  ]) {
    testWidgets('Today does not ask after $reason', (tester) async {
      final count = reason == 'small plan' ? 1 : 3;
      await boot(tester, todayTasks: count, planToday: reason != 'unplanned');
      await finishToday(tester, reason == 'unfinished' ? 2 : count);
      if (reason == 'new task') {
        await container
            .read(itemRepositoryProvider)
            .upsert(
              anItem(
                id: 'new-task',
                status: ItemStatus.nextAction,
              ).copyWith(focusedAt: env.clock.now()),
            );
      } else if (reason == 'undo') {
        await tester.tap(find.text('Undo'));
      } else if (reason == 'switch view') {
        await tester.tap(find.text('Next actions').first);
      }
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 6));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));
      expect(prompter.requests, 0);
    });
  }

  testWidgets(
    'Weekly Review requests only after returning and completion feedback ends',
    (tester) async {
      await boot(tester, weekly: true);
      await tester.tap(find.text('Resume weekly review'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Finish review'));
      await tester.pumpAndSettle();
      expect(find.text('Step 7 of 7'), findsNothing);
      expect(find.text('Weekly review'), findsOneWidget);
      expect(prompter.requests, 0);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      expect(prompter.requests, 1);
    },
  );

  testWidgets('Inbox Zero waits for Undo to expire', (tester) async {
    await boot(tester);
    await clearInbox(tester);
    expect(find.text('Undo'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));
    expect(prompter.requests, 1);
  });

  testWidgets('permission recovery feedback is not interrupted by a rating', (
    tester,
  ) async {
    await boot(tester);
    for (var i = 0; i < 4; i++) {
      await tester.tap(find.text('No — keep as reference'));
      await tester.pumpAndSettle();
    }
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();
    env.scheduler.status = NotificationPermission.denied;
    final controller = container.read(processInboxControllerProvider.notifier);
    controller.setDefer(env.clock.now().add(const Duration(days: 1)));
    for (var i = 0; i < 5; i++) {
      controller.advance();
    }
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('File as next action'));
    await tester.tap(find.text('File as next action'));
    await tester.pumpAndSettle();
    expect(find.text('Turn on reminders?'), findsOneWidget);
    expect(prompter.requests, 0);
    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();
    expect(find.text('Inbox zero!'), findsOneWidget);
    expect(
      find.text(
        'Reminders stay off. You can enable them anytime in More → Reminders.',
      ),
      findsOneWidget,
    );
    await tester.pump(const Duration(seconds: 2));
    expect(prompter.requests, 0);
    await tester.pump(const Duration(seconds: 8));
    await tester.pumpAndSettle();
    expect(prompter.requests, 0);
    expect(container.read(reviewPromptStoreProvider).load().prompts, 0);
  });

  testWidgets('Undo cancels the Inbox Zero request', (tester) async {
    await boot(tester);
    await clearInbox(tester);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 8));
    expect(prompter.requests, 0);
    expect((await container.read(inboxItemsProvider.future)).length, 1);
  });
}
