import 'package:cleartray/features/common/localized_dates.dart';
import 'package:cleartray/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async => initializeDateFormatting());
  final en = lookupAppLocalizations(const Locale('en'));
  final now = DateTime(2026, 5, 14, 9);

  test('midnight defer shows weekday + date only', () {
    expect(
      localizedDeferLabel(DateTime(2026, 6, 5), en, now: now),
      'Fri, Jun 5',
    );
  });

  test('defer with a chosen time includes the time', () {
    final s = localizedDeferLabel(DateTime(2026, 6, 5, 14, 30), en, now: now);
    expect(s, startsWith('Fri, Jun 5'));
    expect(s, contains('2:30'));
  });

  test('year appears only when not the current year', () {
    expect(
      localizedDeferLabel(DateTime(2027, 1, 8), en, now: now),
      'Fri, Jan 8, 2027',
    );
  });

  test('isStartOfDay', () {
    expect(isStartOfDay(DateTime(2026, 6, 5)), isTrue);
    expect(isStartOfDay(DateTime(2026, 6, 5, 0, 1)), isFalse);
  });
}
