import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'maybe_request_app_review.dart';
import 'providers.dart';

/// Waits for completion feedback/Undo, then a quiet second. Interaction,
/// navigation, and backgrounding cancel the opportunity rather than defer it.
class ReviewPromptScheduler {
  ReviewPromptScheduler(this.request);
  final MaybeRequestAppReview request;
  int _generation = 0;
  Timer? _timer;
  bool _foreground = true;

  void setForeground(bool foreground) {
    _foreground = foreground;
    cancel();
  }

  void cancel() {
    _generation++;
    _timer?.cancel();
    _timer = null;
  }

  void schedule(
    ReviewMoment moment, {
    required Future<void> settled,
    required bool Function() isRelevant,
  }) {
    cancel();
    if (!_foreground) return;
    final generation = _generation;
    bool valid() => _foreground && generation == _generation && isRelevant();
    unawaited(() async {
      try {
        await settled;
        if (!valid()) return;
        _timer = Timer(const Duration(seconds: 1), () {
          _timer = null;
          if (valid()) unawaited(request(moment, isRelevant: valid));
        });
      } catch (_) {
        // Completion feedback and store requests are best effort.
      }
    }());
  }
}

final reviewPromptSchedulerProvider = Provider<ReviewPromptScheduler>((ref) {
  final scheduler = ReviewPromptScheduler(
    ref.watch(maybeRequestAppReviewProvider),
  );
  ref.onDispose(scheduler.cancel);
  return scheduler;
});
