import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Store rating prompt port (ADR 0007). The store adapter wraps the
/// platform's in-app review sheet; FOSS builds ship an inert stub, and the
/// default here is a no-op so tests never touch a platform channel.
abstract class AppReviewPrompter {
  const AppReviewPrompter();

  /// Whether the platform can show the in-app review sheet now.
  Future<bool> isAvailable();

  /// Asks the OS to show its review sheet. The OS may decide not to.
  Future<void> requestReview();
}

class NoopAppReviewPrompter extends AppReviewPrompter {
  const NoopAppReviewPrompter();
  @override
  Future<bool> isAvailable() async => false;
  @override
  Future<void> requestReview() async {}
}

/// Persisted rate-limiting state for the review prompt.
class ReviewPromptState {
  const ReviewPromptState({
    this.firstSessionAt,
    this.sessions = 0,
    this.lastPromptAt,
    this.prompts = 0,
  });

  final DateTime? firstSessionAt;
  final int sessions;
  final DateTime? lastPromptAt;
  final int prompts;

  ReviewPromptState copyWith({
    DateTime? firstSessionAt,
    int? sessions,
    DateTime? lastPromptAt,
    int? prompts,
  }) => ReviewPromptState(
    firstSessionAt: firstSessionAt ?? this.firstSessionAt,
    sessions: sessions ?? this.sessions,
    lastPromptAt: lastPromptAt ?? this.lastPromptAt,
    prompts: prompts ?? this.prompts,
  );
}

abstract class ReviewPromptStore {
  ReviewPromptState load();
  Future<void> save(ReviewPromptState state);
}

/// Default for tests and previews; `main()` overrides it with the
/// SharedPreferences-backed store.
class InMemoryReviewPromptStore implements ReviewPromptStore {
  InMemoryReviewPromptStore([this._state = const ReviewPromptState()]);
  ReviewPromptState _state;
  @override
  ReviewPromptState load() => _state;
  @override
  Future<void> save(ReviewPromptState state) async => _state = state;
}

final appReviewPrompterProvider = Provider<AppReviewPrompter>(
  (ref) => const NoopAppReviewPrompter(),
);

final reviewPromptStoreProvider = Provider<ReviewPromptStore>(
  (ref) => InMemoryReviewPromptStore(),
);
