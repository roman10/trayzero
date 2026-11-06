import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_review.dart';

class SharedPreferencesReviewPromptStore implements ReviewPromptStore {
  SharedPreferencesReviewPromptStore(this._prefs);
  final SharedPreferences _prefs;

  static const _firstSessionKey = 'review_prompt_first_session_ms';
  static const _sessionsKey = 'review_prompt_sessions';
  static const _lastPromptKey = 'review_prompt_last_ms';
  static const _promptsKey = 'review_prompt_count';

  @override
  ReviewPromptState load() => ReviewPromptState(
    firstSessionAt: _date(_firstSessionKey),
    sessions: _int(_sessionsKey),
    lastPromptAt: _date(_lastPromptKey),
    prompts: _int(_promptsKey),
  );

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
      _prefs.setInt(_sessionsKey, state.sessions),
      _prefs.setInt(_promptsKey, state.prompts),
      if (state.firstSessionAt != null)
        _prefs.setInt(
          _firstSessionKey,
          state.firstSessionAt!.millisecondsSinceEpoch,
        ),
      if (state.lastPromptAt != null)
        _prefs.setInt(_lastPromptKey, state.lastPromptAt!.millisecondsSinceEpoch),
    ];
    if ((await Future.wait(writes)).contains(false)) {
      throw StateError('Could not persist review prompt state');
    }
  }
}
