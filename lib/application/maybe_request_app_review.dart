import '../core/app_review.dart';
import '../core/clock.dart';

/// Success moments that may be followed by a store rating prompt.
enum ReviewMoment { weeklyReviewFinished, inboxZero, todayFinished }

const minActiveDaysBeforeReviewPrompt = 5;
const minDaysBeforeReviewPrompt = 7;
const reviewPromptCooldownDays = 120;
const maxReviewPrompts = 3;
const reviewPromptWindowDays = 365;

/// Pure rate limiter: never in the first active days or week of use, at most
/// once per cooldown, and three attempts per rolling year. The OS applies its
/// own quota on top.
bool shouldPromptForReview(ReviewPromptState state, DateTime now) {
  final first = state.firstSessionAt;
  if (first == null ||
      state.activeDays.length < minActiveDaysBeforeReviewPrompt) {
    return false;
  }
  if (now.difference(first).inDays < minDaysBeforeReviewPrompt) return false;
  if (recentReviewAttempts(state, now).length >= maxReviewPrompts) return false;
  final last = state.lastPromptAt;
  return last == null ||
      now.difference(last).inDays >= reviewPromptCooldownDays;
}

/// Keep future timestamps too: clock changes must not bypass the quota.
List<DateTime> recentReviewAttempts(ReviewPromptState state, DateTime now) =>
    state.promptAttempts
        .where(
          (at) =>
              now.difference(at) < const Duration(days: reviewPromptWindowDays),
        )
        .toList();

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
  bool _requesting = false;

  /// Returns whether the OS was asked to show the prompt.
  Future<bool> call(ReviewMoment moment, {bool Function()? isRelevant}) async {
    if (_requesting) return false;
    _requesting = true;
    try {
      final now = clock.now();
      final state = store.load();
      if (!shouldPromptForReview(state, now)) return false;
      if (!await prompter.isAvailable()) return false;
      if (isRelevant != null && !isRelevant()) return false;
      // Count the attempt before asking: the OS never reports whether it
      // displayed the sheet, and a crash mid-request must not re-prompt.
      await store.save(
        state.copyWith(
          lastPromptAt: now,
          prompts: state.prompts + 1,
          promptAttempts: [...recentReviewAttempts(state, now), now],
        ),
      );
      if (isRelevant != null && !isRelevant()) return false;
      await prompter.requestReview();
      return true;
    } catch (_) {
      return false;
    } finally {
      _requesting = false;
    }
  }
}

/// Records distinct local calendar dates, including resumes and interaction
/// across midnight. Legacy launch counts cannot establish active days.
final class RecordAppActiveDay {
  RecordAppActiveDay({required this.store, required this.clock});
  final ReviewPromptStore store;
  final Clock clock;
  Future<void> _pending = Future.value();

  Future<void> call() {
    // Serialize overlapping launch/resume/input callbacks.
    final result = _pending.then((_) async {
      final state = store.load();
      final now = clock.now();
      final local = now.toLocal();
      final day = '${local.year}-${local.month}-${local.day}';
      if (state.activeDays.contains(day) ||
          state.activeDays.length >= minActiveDaysBeforeReviewPrompt) {
        return;
      }
      await store.save(
        state.copyWith(
          firstSessionAt: state.firstSessionAt ?? now,
          activeDays: {...state.activeDays, day},
        ),
      );
    });
    _pending = result.catchError((Object _) {});
    return result;
  }
}
