import '../core/app_review.dart';
import '../core/clock.dart';

/// Success moments that may be followed by a store rating prompt.
enum ReviewMoment { weeklyReviewFinished, inboxZero }

const minSessionsBeforeReviewPrompt = 5;
const minDaysBeforeReviewPrompt = 7;
const reviewPromptCooldownDays = 120;
const maxReviewPrompts = 3;

/// Pure rate limiter: never in the first sessions or days of use, at most
/// once per cooldown, and a small lifetime cap. The OS applies its own quota
/// on top.
bool shouldPromptForReview(ReviewPromptState state, DateTime now) {
  final first = state.firstSessionAt;
  if (first == null || state.sessions < minSessionsBeforeReviewPrompt) {
    return false;
  }
  if (now.difference(first).inDays < minDaysBeforeReviewPrompt) return false;
  if (state.prompts >= maxReviewPrompts) return false;
  final last = state.lastPromptAt;
  return last == null ||
      now.difference(last).inDays >= reviewPromptCooldownDays;
}

/// Shows the store rating prompt after a [ReviewMoment] when the policy
/// allows. Best effort: a store or preference failure never reaches the user.
final class MaybeRequestAppReview {
  MaybeRequestAppReview({
    required this.prompter,
    required this.store,
    required this.clock,
  });
  final AppReviewPrompter prompter;
  final ReviewPromptStore store;
  final Clock clock;

  /// Returns whether the OS was asked to show the prompt.
  Future<bool> call(ReviewMoment moment) async {
    try {
      final now = clock.now();
      final state = store.load();
      if (!shouldPromptForReview(state, now)) return false;
      if (!await prompter.isAvailable()) return false;
      // Count the attempt before asking: the OS never reports whether it
      // displayed the sheet, and a crash mid-request must not re-prompt.
      await store.save(
        state.copyWith(lastPromptAt: now, prompts: state.prompts + 1),
      );
      await prompter.requestReview();
      return true;
    } catch (_) {
      return false;
    }
  }
}

/// Counts an app launch for the review-prompt policy.
final class RecordAppSession {
  RecordAppSession({required this.store, required this.clock});
  final ReviewPromptStore store;
  final Clock clock;

  Future<void> call() async {
    final state = store.load();
    await store.save(
      state.copyWith(
        firstSessionAt: state.firstSessionAt ?? clock.now(),
        sessions: state.sessions + 1,
      ),
    );
  }
}
