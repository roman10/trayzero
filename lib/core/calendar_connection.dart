import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Device-local connection settings. Kept out of portable backups.
class CalendarConnectionSettings {
  const CalendarConnectionSettings({
    this.calendarId,
    this.calendarName,
    this.automatic = false,
    this.removing = false,
    this.lastSuccess,
    this.fingerprint,
  });

  final String? calendarId;
  final String? calendarName;
  final bool automatic;

  /// Removal intent survives process death. Publishing is disabled until done.
  final bool removing;
  final DateTime? lastSuccess;
  final String? fingerprint;
  bool get connected => calendarId != null;

  CalendarConnectionSettings copyWith({
    bool? automatic,
    bool? removing,
    DateTime? lastSuccess,
    String? fingerprint,
  }) => CalendarConnectionSettings(
    calendarId: calendarId,
    calendarName: calendarName,
    automatic: automatic ?? this.automatic,
    removing: removing ?? this.removing,
    lastSuccess: lastSuccess ?? this.lastSuccess,
    fingerprint: fingerprint ?? this.fingerprint,
  );
}

abstract class CalendarConnectionPreferences {
  CalendarConnectionSettings load();
  Future<void> save(CalendarConnectionSettings settings);
}

final calendarConnectionPreferencesProvider =
    Provider<CalendarConnectionPreferences>(
      (ref) => throw UnimplementedError('Override at bootstrap'),
    );
