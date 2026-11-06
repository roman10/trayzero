import 'package:cleartray/domain/entities/entities.dart';
import 'package:cleartray/features/common/localized_recurrence.dart';
import 'package:cleartray/features/item_edit/recurrence_section.dart';
import 'package:cleartray/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

void main() {
  late TestEnv env;
  setUp(() async => env = await TestEnv.create());
  tearDown(() => env.dispose());

  for (final locale in AppLocalizations.supportedLocales) {
    for (final cadence in [Recurrence.weekly, Recurrence.monthly]) {
      testWidgets('$locale $cadence controls work on a compact phone at 3x', (
        tester,
      ) async {
        await tester.binding.setSurfaceSize(const Size(360, 640));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        var interval = 2;
        var count = 10;
        var week = 5;
        var weekday = DateTime.tuesday;
        var days = <int>[];
        await pumpApp(
          tester,
          Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IntervalStepper(
                      recurrence: cadence,
                      interval: interval,
                      onChanged: (value) => setState(() => interval = value),
                    ),
                    RecurrencePatternEditor(
                      recurrence: cadence,
                      byWeekdays: days,
                      monthlyWeek: week,
                      monthlyWeekday: weekday,
                      onWeekdaysChanged: (value) =>
                          setState(() => days = value),
                      onDayOfMonth: () {},
                      onNthWeekday: (w, d) => setState(() {
                        week = w;
                        weekday = d;
                      }),
                    ),
                    RecurrenceEndPicker(
                      until: null,
                      count: count,
                      onNever: () {},
                      onUntil: (_) {},
                      onCount: (value) => setState(() => count = value),
                    ),
                  ],
                ),
              ),
            ),
          ),
          env: env,
          locale: locale,
          textScaler: const TextScaler.linear(3),
        );
        await tester.pumpAndSettle();
        final l10n = AppLocalizations.of(
          tester.element(find.byType(IntervalStepper)),
        );
        expect(find.text(cadence.localizedInterval(l10n, 2)), findsOneWidget);
        await tester.ensureVisible(find.byTooltip(l10n.increaseRepeatInterval));
        await tester.tap(find.byTooltip(l10n.increaseRepeatInterval));
        await tester.pumpAndSettle();
        expect(interval, 3);
        expect(find.text(cadence.localizedInterval(l10n, 3)), findsOneWidget);
        if (cadence == Recurrence.weekly) {
          final monday = find.widgetWithText(
            FilterChip,
            localizedWeekday(1, l10n, short: true),
          );
          await tester.ensureVisible(monday);
          await tester.tap(monday);
          await tester.pumpAndSettle();
          expect(days, [1]);
        } else {
          final ordinal = find.byType(DropdownButton<int>).first;
          await tester.ensureVisible(ordinal);
          await tester.tap(ordinal);
          await tester.pumpAndSettle();
          final last = find.text(l10n.repeatLast);
          await tester.scrollUntilVisible(
            last,
            150,
            scrollable: find.byType(Scrollable).last,
          );
          await tester.pumpAndSettle();
          await tester.tap(last);
          await tester.pumpAndSettle();
          expect(week, -1);
          expect(weekday, DateTime.tuesday);
        }
        await tester.ensureVisible(find.byTooltip(l10n.increaseRepeatCount));
        await tester.tap(find.byTooltip(l10n.increaseRepeatCount));
        await tester.pumpAndSettle();
        expect(count, 11);
        expect(find.text(l10n.repeatAfterOccurrences(11)), findsOneWidget);
        expect(tester.takeException(), null);
      });
    }
  }

  for (final until in [DateTime(2020, 1, 1), DateTime(2050, 1, 1)]) {
    testWidgets(
      'an existing end date outside the picker range is editable: $until',
      (tester) async {
        await pumpApp(
          tester,
          Scaffold(
            body: RecurrenceEndPicker(
              until: until,
              count: null,
              onNever: () {},
              onUntil: (_) {},
              onCount: (_) {},
            ),
          ),
          env: env,
        );
        await tester.tap(find.text('On date'));
        await tester.pumpAndSettle();
        final dialog = tester.widget<DatePickerDialog>(
          find.byType(DatePickerDialog),
        );
        final expected = until.isBefore(env.clock.now())
            ? env.clock.now()
            : env.clock.now().add(const Duration(days: 365 * 10));
        expect(dialog.initialDate, DateUtils.dateOnly(expected));
        expect(tester.takeException(), null);
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
      },
    );
  }
}
