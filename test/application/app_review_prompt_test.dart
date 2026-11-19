import 'dart:async';

import 'package:cleartray/application/maybe_request_app_review.dart';
import 'package:cleartray/core/app_review.dart';
import 'package:cleartray/core/clock.dart';
import 'package:cleartray/infrastructure/shared_preferences_review_prompt_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Prompter extends AppReviewPrompter {
  _Prompter({this.available = true, this.fail = false});
  final bool available;
  final bool fail;
  int requests = 0;
  Completer<bool>? availability;

  @override
  Future<bool> isAvailable() async =>
      availability == null ? available : availability!.future;

  @override
  Future<void> requestReview() async {
    requests++;
    if (fail) throw StateError('store unavailable');
  }
}

void main() {
  final now = DateTime(2026, 10, 26);
  final ready = ReviewPromptState(
    firstSessionAt: now.subtract(const Duration(days: 30)),
    activeDays: {'2026-9-1', '2026-9-2', '2026-9-3', '2026-9-4', '2026-9-5'},
  );

  group('shouldPromptForReview', () {
    test('allows a seasoned user who was never asked', () {
      expect(shouldPromptForReview(ready, now), isTrue);
    });

    test('never in the first active days or the first week', () {
      expect(shouldPromptForReview(const ReviewPromptState(), now), isFalse);
      expect(
        shouldPromptForReview(
          ready.copyWith(
            activeDays: {'2026-9-1', '2026-9-2', '2026-9-3', '2026-9-4'},
          ),
          now,
        ),
        isFalse,
      );
      expect(
        shouldPromptForReview(
          ready.copyWith(firstSessionAt: now.subtract(const Duration(days: 6))),
          now,
        ),
        isFalse,
      );
    });

    test('respects the cooldown and rolling yearly cap', () {
      expect(
        shouldPromptForReview(
          ready.copyWith(
            lastPromptAt: now.subtract(const Duration(days: 119)),
            prompts: 1,
          ),
          now,
        ),
        isFalse,
      );
      expect(
        shouldPromptForReview(
          ready.copyWith(
            lastPromptAt: now.subtract(const Duration(days: 120)),
            prompts: 1,
          ),
          now,
        ),
        isTrue,
      );
      expect(
        shouldPromptForReview(
          ready.copyWith(
            lastPromptAt: now.subtract(const Duration(days: 400)),
            prompts: 3,
            promptAttempts: [
              now.subtract(const Duration(days: 360)),
              now.subtract(const Duration(days: 240)),
              now.subtract(const Duration(days: 120)),
            ],
          ),
          now,
        ),
        isFalse,
      );
    });
  });

  test('old attempts expire at 365 days; lifetime count does not block', () {
    final state = ready.copyWith(
      prompts: 20,
      lastPromptAt: now.subtract(const Duration(days: 125)),
      promptAttempts: [
        365,
        245,
        125,
      ].map((days) => now.subtract(Duration(days: days))).toList(),
    );
    expect(
      shouldPromptForReview(
        state,
        now.subtract(const Duration(milliseconds: 1)),
      ),
      isFalse,
    );
    expect(shouldPromptForReview(state, now), isTrue);
  });

  test('concurrent requests consume only one attempt', () async {
    final prompter = _Prompter()..availability = Completer<bool>();
    final store = InMemoryReviewPromptStore(ready);
    final use = MaybeRequestAppReview(
      prompter: prompter,
      store: store,
      clock: FakeClock(now),
    );
    final first = use(ReviewMoment.inboxZero);
    expect(await use(ReviewMoment.todayFinished), isFalse);
    prompter.availability!.complete(true);
    expect(await first, isTrue);
    expect(store.load().promptAttempts, [now]);
    expect(prompter.requests, 1);
  });

  test(
    'attempt history survives persistence and old attempts are pruned',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final store = SharedPreferencesReviewPromptStore(prefs);
      final recent = now.subtract(const Duration(days: 120));
      await store.save(
        ready.copyWith(
          prompts: 10,
          lastPromptAt: recent,
          promptAttempts: [now.subtract(const Duration(days: 400)), recent],
        ),
      );
      final use = MaybeRequestAppReview(
        prompter: _Prompter(),
        store: store,
        clock: FakeClock(now),
      );
      expect(await use(ReviewMoment.todayFinished), isTrue);
      final restored = SharedPreferencesReviewPromptStore(prefs).load();
      expect(restored.promptAttempts, [recent, now]);
      expect(restored.prompts, 11);
    },
  );

  test(
    'legacy lifetime cap migrates conservatively and eventually expires',
    () async {
      SharedPreferences.setMockInitialValues({
        'review_prompt_first_session_ms':
            ready.firstSessionAt!.millisecondsSinceEpoch,
        'review_prompt_active_days': ready.activeDays.toList(),
        'review_prompt_last_ms': now
            .subtract(const Duration(days: 120))
            .millisecondsSinceEpoch,
        'review_prompt_count': 3,
      });
      final prefs = await SharedPreferences.getInstance();
      final state = SharedPreferencesReviewPromptStore(prefs).load();
      expect(state.promptAttempts, hasLength(3));
      expect(shouldPromptForReview(state, now), isFalse);
      expect(
        shouldPromptForReview(state, now.add(const Duration(days: 245))),
        isTrue,
      );
    },
  );

  group('MaybeRequestAppReview', () {
    test('asks once, records the attempt, then cools down', () async {
      final prompter = _Prompter();
      final store = InMemoryReviewPromptStore(ready);
      final use = MaybeRequestAppReview(
        prompter: prompter,
        store: store,
        clock: FakeClock(now),
      );
      expect(await use(ReviewMoment.weeklyReviewFinished), isTrue);
      expect(prompter.requests, 1);
      expect(store.load().prompts, 1);
      expect(store.load().lastPromptAt, now);
      expect(await use(ReviewMoment.inboxZero), isFalse);
      expect(prompter.requests, 1);
    });

    test('does nothing when the platform cannot show a review', () async {
      final prompter = _Prompter(available: false);
      final store = InMemoryReviewPromptStore(ready);
      final use = MaybeRequestAppReview(
        prompter: prompter,
        store: store,
        clock: FakeClock(now),
      );
      expect(await use(ReviewMoment.inboxZero), isFalse);
      expect(prompter.requests, 0);
      expect(store.load().prompts, 0);
    });

    test('a store failure never reaches the caller', () async {
      final prompter = _Prompter(fail: true);
      final use = MaybeRequestAppReview(
        prompter: prompter,
        store: InMemoryReviewPromptStore(ready),
        clock: FakeClock(now),
      );
      expect(await use(ReviewMoment.inboxZero), isFalse);
    });

    test('the FOSS no-op prompter never prompts', () async {
      final use = MaybeRequestAppReview(
        prompter: const NoopAppReviewPrompter(),
        store: InMemoryReviewPromptStore(ready),
        clock: FakeClock(now),
      );
      expect(await use(ReviewMoment.inboxZero), isFalse);
    });
  });

  test(
    'relaunches on one date count once, including concurrent calls',
    () async {
      final store = InMemoryReviewPromptStore();
      final clock = FakeClock(DateTime(2026, 10, 26, 23, 59));
      final record = RecordAppActiveDay(store: store, clock: clock);
      await Future.wait(List.generate(10, (_) => record()));
      expect(store.load().activeDays, hasLength(1));
      clock.advance(const Duration(minutes: 2));
      await record();
      expect(store.load().activeDays, hasLength(2));
      clock.advance(const Duration(days: -1));
      await record();
      expect(store.load().activeDays, hasLength(2));
      for (var i = 0; i < 10; i++) {
        clock.advance(const Duration(days: 1));
        await record();
      }
      expect(store.load().activeDays, hasLength(5));
    },
  );

  test(
    'legacy launch count is not active days; cooldown history is preserved',
    () async {
      final first = now.subtract(const Duration(days: 30));
      final last = now.subtract(const Duration(days: 10));
      SharedPreferences.setMockInitialValues({
        'review_prompt_first_session_ms': first.millisecondsSinceEpoch,
        'review_prompt_sessions': 100,
        'review_prompt_last_ms': last.millisecondsSinceEpoch,
        'review_prompt_count': 2,
      });
      final prefs = await SharedPreferences.getInstance();
      final store = SharedPreferencesReviewPromptStore(prefs);
      await RecordAppActiveDay(store: store, clock: FakeClock(now))();
      final state = SharedPreferencesReviewPromptStore(prefs).load();
      expect(state.activeDays, hasLength(1));
      expect(state.firstSessionAt, first);
      expect(state.lastPromptAt, last);
      expect(state.prompts, 2);
      expect(shouldPromptForReview(state, now), isFalse);
    },
  );

  test(
    'distinct active days persist across launches in SharedPreferences',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final clock = FakeClock(now);
      final record = RecordAppActiveDay(
        store: SharedPreferencesReviewPromptStore(prefs),
        clock: clock,
      );
      await record();
      clock.advance(const Duration(days: 3));
      await record();
      final state = SharedPreferencesReviewPromptStore(prefs).load();
      expect(state.activeDays, hasLength(2));
      expect(state.firstSessionAt, now);
      expect(state.prompts, 0);
      expect(state.lastPromptAt, isNull);
    },
  );
}
