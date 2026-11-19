import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Store rating prompt port (ADR 0007). The store adapter wraps the
/// platform's in-app review sheet; FOSS builds ship an inert stub, and the
/// default here is a no-op so tests never touch a platform channel.
abstract class AppReviewPrompter {
  const AppReviewPrompter();

  /// Whether the platform supports in-app review. Availability does not
  /// guarantee that the store will display the sheet.
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
    this.activeDays = const {},
    this.lastPromptAt,
    this.prompts = 0,
    this.promptAttempts = const [],
  });

  final DateTime? firstSessionAt;

  /// Local calendar dates; only the first five are needed for eligibility.
  final Set<String> activeDays;
  final DateTime? lastPromptAt;

  /// Lifetime attempt count retained for compatibility, not eligibility.
  final int prompts;
  final List<DateTime> promptAttempts;

  ReviewPromptState copyWith({
    DateTime? firstSessionAt,
    Set<String>? activeDays,
    DateTime? lastPromptAt,
    int? prompts,
    List<DateTime>? promptAttempts,
  }) => ReviewPromptState(
    firstSessionAt: firstSessionAt ?? this.firstSessionAt,
    activeDays: activeDays ?? this.activeDays,
    lastPromptAt: lastPromptAt ?? this.lastPromptAt,
    prompts: prompts ?? this.prompts,
    promptAttempts: promptAttempts ?? this.promptAttempts,
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
