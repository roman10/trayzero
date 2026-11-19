import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_review.dart';

class SharedPreferencesReviewPromptStore implements ReviewPromptStore {
  SharedPreferencesReviewPromptStore(this._prefs);
  final SharedPreferences _prefs;

  static const _firstSessionKey = 'review_prompt_first_session_ms';
  static const _activeDaysKey = 'review_prompt_active_days';
  static const _lastPromptKey = 'review_prompt_last_ms';
  static const _attemptsKey = 'review_prompt_attempts_ms';
  static const _promptsKey = 'review_prompt_count';

  @override
  ReviewPromptState load() => ReviewPromptState(
    firstSessionAt: _date(_firstSessionKey),
    activeDays: (_prefs.getStringList(_activeDaysKey) ?? const <String>[])
        .toSet(),
    lastPromptAt: _date(_lastPromptKey),
    prompts: _int(_promptsKey),
    promptAttempts: _attempts(),
  );

  List<DateTime> _attempts() {
    final saved = _prefs.getStringList(_attemptsKey);
    if (saved != null) {
      return [
        for (final value in saved)
          if (int.tryParse(value) case final ms?)
            DateTime.fromMillisecondsSinceEpoch(ms),
      ];
    }
    // Legacy versions kept only a count and last date. Treat the latest
    // three attempts as occurring on that date to avoid over-prompting.
    final last = _date(_lastPromptKey);
    return last == null ? [] : List.filled(_int(_promptsKey).clamp(0, 3), last);
  }

  int _int(String key) {
    final value = _prefs.get(key);
    return value is int ? value : 0;
  }

  DateTime? _date(String key) {
    final value = _prefs.get(key);
    return value is int ? DateTime.fromMillisecondsSinceEpoch(value) : null;
  }

  @override
  Future<void> save(ReviewPromptState state) async {
    final writes = [
      _prefs.setStringList(_attemptsKey, [
        for (final at in state.promptAttempts) '${at.millisecondsSinceEpoch}',
      ]),
      _prefs.setStringList(_activeDaysKey, state.activeDays.toList()),
      _prefs.setInt(_promptsKey, state.prompts),
      if (state.firstSessionAt != null)
        _prefs.setInt(
          _firstSessionKey,
          state.firstSessionAt!.millisecondsSinceEpoch,
        ),
      if (state.lastPromptAt != null)
        _prefs.setInt(
          _lastPromptKey,
          state.lastPromptAt!.millisecondsSinceEpoch,
        ),
    ];
    if ((await Future.wait(writes)).contains(false)) {
      throw StateError('Could not persist review prompt state');
    }
  }
}
