import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kThemeMode = 'theme_mode';
const _kOnboardingComplete = 'onboarding_complete_v1';
const _kSeededSample = 'seeded_sample_v1';
const _kWeeklyReviewReminder = 'weekly_review_reminder_enabled';
const _kLeadTimeMinutes = 'reminder_lead_time_minutes';
const _kDeferSurfaceMinutes = 'defer_surface_minutes';
const _kHapticsEnabled = 'haptics_enabled';
const _kCrashReportingEnabled = 'crash_reporting_enabled';
const _kBackupReminderEnabled = 'backup_reminder_enabled';
const _kNotificationPrimed = 'notification_primed_v1';
const _kCalendarSyncEnabled = 'calendar_sync_enabled';
const _kCalendarSyncCalendarId = 'calendar_sync_calendar_id';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Must be overridden in ProviderScope');
});

class ThemeModeController extends StateNotifier<ThemeMode> {
  ThemeModeController(this._prefs) : super(_load(_prefs));
  final SharedPreferences _prefs;

  static ThemeMode _load(SharedPreferences p) {
    final s = p.getString(_kThemeMode);
    return switch (s) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    await _prefs.setString(_kThemeMode, mode.name);
  }
}

final themeModeProvider =
    StateNotifierProvider<ThemeModeController, ThemeMode>((ref) {
  return ThemeModeController(ref.watch(sharedPreferencesProvider));
});

class OnboardingController extends StateNotifier<bool> {
  OnboardingController(this._prefs)
      : super(_prefs.getBool(_kOnboardingComplete) ?? false);
  final SharedPreferences _prefs;

  Future<void> complete() async {
    state = true;
    await _prefs.setBool(_kOnboardingComplete, true);
  }

  Future<void> reset() async {
    state = false;
    await _prefs.setBool(_kOnboardingComplete, false);
  }
}

final onboardingCompleteProvider =
    StateNotifierProvider<OnboardingController, bool>((ref) {
  return OnboardingController(ref.watch(sharedPreferencesProvider));
});

final sampleSeededProvider = Provider<bool>((ref) =>
    ref.watch(sharedPreferencesProvider).getBool(_kSeededSample) ?? false);

Future<void> markSampleSeeded(SharedPreferences prefs) =>
    prefs.setBool(_kSeededSample, true);

final weeklyReviewReminderProvider =
    StateNotifierProvider<_BoolPref, bool>((ref) {
  return _BoolPref(
    prefs: ref.watch(sharedPreferencesProvider),
    key: _kWeeklyReviewReminder,
    defaultValue: true,
  );
});

/// Minutes before an item's due time to fire an extra "Soon:" reminder
/// (a GTD tickler). 0 means off; defaults to 60 (a one-hour heads-up) so a
/// fresh install warns ahead of the deadline rather than only at it. The
/// launch re-arm ([RearmItemReminders]) reconciles every active dated item
/// against this value, so changing it (or the default) takes effect for
/// existing items on the next launch — no per-item re-save needed.
final reminderLeadTimeProvider =
    StateNotifierProvider<_IntPref, int>((ref) {
  return _IntPref(
    prefs: ref.watch(sharedPreferencesProvider),
    key: _kLeadTimeMinutes,
    defaultValue: 60,
  );
});

/// Minutes since local midnight at which a no-time deferred item fires its
/// "Ready:" reminder (default 09:00 = 540). The item itself becomes visible
/// in Next Actions at the start of its defer day regardless; only the nudge
/// is bound to this hour. Applies to items saved after the change.
final deferSurfaceMinutesProvider =
    StateNotifierProvider<_IntPref, int>((ref) {
  return _IntPref(
    prefs: ref.watch(sharedPreferencesProvider),
    key: _kDeferSurfaceMinutes,
    defaultValue: 540,
  );
});

final hapticsEnabledProvider =
    StateNotifierProvider<_BoolPref, bool>((ref) {
  return _BoolPref(
    prefs: ref.watch(sharedPreferencesProvider),
    key: _kHapticsEnabled,
    defaultValue: true,
  );
});

final crashReportingEnabledProvider =
    StateNotifierProvider<_BoolPref, bool>((ref) {
  return _BoolPref(
    prefs: ref.watch(sharedPreferencesProvider),
    key: _kCrashReportingEnabled,
    defaultValue: false, // Privacy-first: opt-in only.
  );
});

final backupReminderEnabledProvider =
    StateNotifierProvider<_BoolPref, bool>((ref) {
  return _BoolPref(
    prefs: ref.watch(sharedPreferencesProvider),
    key: _kBackupReminderEnabled,
    defaultValue: false,
  );
});

/// Whether the one-time pre-permission rationale ("Turn on reminders?") has
/// been shown. Set true the moment it is displayed — on *either* Continue or
/// Not now — so we never re-nag; Settings → Reminders stays the always-on
/// recovery path. Default false (never shown).
final notificationPrimedProvider =
    StateNotifierProvider<_BoolPref, bool>((ref) {
  return _BoolPref(
    prefs: ref.watch(sharedPreferencesProvider),
    key: _kNotificationPrimed,
    defaultValue: false,
  );
});

final calendarSyncEnabledProvider =
    StateNotifierProvider<_BoolPref, bool>((ref) {
  return _BoolPref(
    prefs: ref.watch(sharedPreferencesProvider),
    key: _kCalendarSyncEnabled,
    defaultValue: false,
  );
});

class _StringPref extends StateNotifier<String?> {
  _StringPref({required this.prefs, required this.key})
      : super(prefs.getString(key));
  final SharedPreferences prefs;
  final String key;
  Future<void> set(String? v) async {
    state = v;
    if (v == null) {
      await prefs.remove(key);
    } else {
      await prefs.setString(key, v);
    }
  }
}

final calendarSyncCalendarIdProvider =
    StateNotifierProvider<_StringPref, String?>((ref) {
  return _StringPref(
    prefs: ref.watch(sharedPreferencesProvider),
    key: _kCalendarSyncCalendarId,
  );
});

class _BoolPref extends StateNotifier<bool> {
  _BoolPref({
    required this.prefs,
    required this.key,
    required bool defaultValue,
  }) : super(prefs.getBool(key) ?? defaultValue);

  final SharedPreferences prefs;
  final String key;

  Future<void> set(bool v) async {
    state = v;
    await prefs.setBool(key, v);
  }
}

class _IntPref extends StateNotifier<int> {
  _IntPref({
    required this.prefs,
    required this.key,
    required int defaultValue,
  }) : super(prefs.getInt(key) ?? defaultValue);

  final SharedPreferences prefs;
  final String key;

  Future<void> set(int v) async {
    state = v;
    await prefs.setInt(key, v);
  }
}

/// Per-section expand/collapse state for the Settings screen, persisted
/// across launches. Defaults to expanded so first-time users see every
/// option without hunting.
class SettingsSectionExpandedController extends StateNotifier<bool> {
  SettingsSectionExpandedController({
    required this.prefs,
    required this.section,
  }) : super(prefs.getBool('settings_section_${section}_expanded') ?? true);

  final SharedPreferences prefs;
  final String section;

  Future<void> set(bool v) async {
    state = v;
    await prefs.setBool('settings_section_${section}_expanded', v);
  }
}

final settingsSectionExpandedProvider = StateNotifierProvider.family<
    SettingsSectionExpandedController, bool, String>(
  (ref, section) => SettingsSectionExpandedController(
    prefs: ref.watch(sharedPreferencesProvider),
    section: section,
  ),
);
