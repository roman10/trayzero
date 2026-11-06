import 'package:cleartray/domain/entities/entities.dart';
import 'package:cleartray/features/common/localized_due_label.dart';
import 'package:cleartray/features/common/localized_recurrence.dart';
import 'package:cleartray/l10n/gen/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import '../support/harness.dart' show anItem;

void main() {
  setUpAll(() => initializeDateFormatting());
  late String? previousLocale;
  setUp(() {
    previousLocale = Intl.defaultLocale;
    Intl.defaultLocale = 'en';
  });
  tearDown(() => Intl.defaultLocale = previousLocale);

  AppLocalizations labels(String language) =>
      lookupAppLocalizations(Locale(language));

  test('German weekly descriptions sort weekdays and use Monday-based IDs', () {
    const rule = RecurrenceRule(
      frequency: Recurrence.weekly,
      interval: 2,
      byWeekdays: {7, 1, 3},
    );
    expect(
      rule.localizedDescription(labels('de')),
      'Alle 2 Wochen: Mo, Mi, So',
    );
    expect(rule.localizedShortLabel(labels('de')), 'Alle 2 Wochen');
    expect(
      const RecurrenceRule(
        frequency: Recurrence.daily,
      ).localizedShortLabel(labels('de')),
      'Täglich',
    );
  });

  test(
    'monthly descriptions include first through fifth and last weekdays',
    () {
      final l10n = labels('de');
      const ordinals = {
        1: 'ersten',
        2: 'zweiten',
        3: 'dritten',
        4: 'vierten',
        5: 'fünften',
        -1: 'letzten',
      };
      for (final entry in ordinals.entries) {
        final rule = RecurrenceRule(
          frequency: Recurrence.monthly,
          monthlyWeek: entry.key,
          monthlyWeekday: DateTime.tuesday,
        );
        expect(
          rule.localizedDescription(l10n),
          'Jeden Monat am ${entry.value} Dienstag',
        );
      }
      const fifthTuesday = RecurrenceRule(
        frequency: Recurrence.monthly,
        monthlyWeek: 5,
        monthlyWeekday: DateTime.tuesday,
      );
      expect(fifthTuesday.localizedDescription(labels('ja')), '毎月の第5火曜日');
    },
  );

  test('Russian intervals and counts follow singular, few and many rules', () {
    final l10n = labels('ru');
    const cases = {
      1: 'день',
      2: 'дня',
      5: 'дней',
      21: 'день',
      22: 'дня',
      25: 'дней',
    };
    for (final entry in cases.entries) {
      expect(
        Recurrence.daily.localizedInterval(l10n, entry.key),
        'Раз в ${entry.key} ${entry.value}',
      );
    }
    expect(l10n.recurrenceCountSummary('План', 21), 'План · 21 повторение');
    expect(l10n.recurrenceCountSummary('План', 22), 'План · 22 повторения');
    expect(l10n.recurrenceCountSummary('План', 25), 'План · 25 повторений');
  });

  test(
    'Traditional Chinese weekdays do not fall back to Simplified Chinese',
    () {
      final traditional = lookupAppLocalizations(
        const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
      );
      expect(localizedWeekday(1, traditional, short: true), '週一');
      expect(localizedWeekday(1, labels('zh'), short: true), '周一');
    },
  );

  test(
    'end conditions and due dates use app language despite global English',
    () {
      final l10n = labels('de');
      final item = anItem(
        recurrence: Recurrence.monthly,
        recurrenceUntil: DateTime(2026, 5, 20),
      );
      expect(
        item.localizedRecurrenceSummary(l10n),
        'Jeden Monat · bis 20. Mai 2026',
      );
      final now = DateTime(2026, 5, 16, 12);
      expect(
        localizedDueChipLabel(DateTime(2026, 5, 14), now, l10n),
        'Überfällig · 2 T.',
      );
      expect(
        localizedDueChipLabel(DateTime(2026, 5, 16), now, l10n),
        'Heute fällig',
      );
      expect(
        localizedDueChipLabel(DateTime(2026, 5, 16, 8, 30), now, l10n),
        'Heute fällig, 08:30',
      );
      expect(
        localizedDueChipLabel(DateTime(2026, 5, 20), now, l10n),
        '20. Mai',
      );
      expect(
        localizedDueChipLabel(DateTime(2026, 5, 20, 9, 5), now, l10n),
        '20. Mai 09:05',
      );
    },
  );

  for (final locale in AppLocalizations.supportedLocales) {
    test('all cadences and summaries resolve in $locale', () {
      final l10n = lookupAppLocalizations(locale);
      for (final frequency in Recurrence.values) {
        for (final interval in [1, 2, 21]) {
          final item = anItem(
            recurrence: frequency,
            recurrenceInterval: interval,
            recurrenceCount: 5,
          );
          final text = item.localizedRecurrenceSummary(l10n);
          expect(text, contains('5'));
          expect(text, isNot(contains('{')));
          if (locale.languageCode != 'en') {
            expect(text, isNot(contains('Every')));
          }
        }
      }
    });
  }
}
