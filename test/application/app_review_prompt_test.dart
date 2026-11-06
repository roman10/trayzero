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

  @override
  Future<bool> isAvailable() async => available;

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
    sessions: 10,
  );

  group('shouldPromptForReview', () {
    test('allows a seasoned user who was never asked', () {
      expect(shouldPromptForReview(ready, now), isTrue);
    });

    test('never in the first sessions or the first week', () {
      expect(shouldPromptForReview(const ReviewPromptState(), now), isFalse);
      expect(
        shouldPromptForReview(ready.copyWith(sessions: 4), now),
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

    test('respects the cooldown and the lifetime cap', () {
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
          ),
          now,
        ),
        isFalse,
      );
    });
  });

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

  test('sessions persist across launches in SharedPreferences', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final clock = FakeClock(now);
    final record = RecordAppSession(
      store: SharedPreferencesReviewPromptStore(prefs),
      clock: clock,
    );
    await record();
    clock.advance(const Duration(days: 3));
    await record();
    final state = SharedPreferencesReviewPromptStore(prefs).load();
    expect(state.sessions, 2);
    expect(state.firstSessionAt, now);
    expect(state.prompts, 0);
    expect(state.lastPromptAt, isNull);
  });
}
