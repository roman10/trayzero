import 'package:cleartray/domain/entities/entities.dart';
import 'package:cleartray/domain/import/csv.dart';
import 'package:cleartray/domain/import/import_plan.dart';
import 'package:cleartray/domain/import/import_values.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseCsv', () {
    test('strips a BOM and handles CRLF, LF and lone CR', () {
      expect(parseCsv('﻿a,b\r\n1,2\n3,4\r5,6'), [
        ['a', 'b'],
        ['1', '2'],
        ['3', '4'],
        ['5', '6'],
      ]);
    });

    test('quoted delimiters, doubled quotes and line breaks', () {
      expect(parseCsv('x,"a, ""b""\r\nc\rd",y\n'), [
        ['x', 'a, "b"\nc\nd', 'y'],
      ]);
    });

    test('keeps empty fields and drops blank lines', () {
      expect(parseCsv('a,,c\n\n\n,,\n'), [
        ['a', '', 'c'],
        ['', '', ''],
      ]);
    });

    test('detects a semicolon delimiter from the header', () {
      expect(parseCsv('Name;Note\n"a;b";Größe'), [
        ['Name', 'Note'],
        ['a;b', 'Größe'],
      ]);
    });

    test('an unterminated quote takes the rest of the input', () {
      expect(parseCsv('a,"open\nstill open'), [
        ['a', 'open\nstill open'],
      ]);
    });

    test('CsvTable matches headers loosely and tolerates short rows', () {
      final t = CsvTable(['Due Date', 'TITLE'], [
        ['2026-01-01'],
      ]);
      expect(t.has('due_date'), isTrue);
      expect(t.cell(t.rows.single, 'DUEDATE'), '2026-01-01');
      expect(t.cell(t.rows.single, 'title'), '');
      expect(t.cell(t.rows.single, 'missing'), '');
    });
  });

  group('dates', () {
    final now = DateTime(2026, 10, 26, 10);

    test('absolute forms', () {
      expect(parseAbsoluteDate('2026-10-28'), DateTime(2026, 10, 28));
      expect(parseAbsoluteDate('20261028'), DateTime(2026, 10, 28));
      expect(parseAbsoluteDate('2026/10/28'), DateTime(2026, 10, 28));
      expect(
        parseAbsoluteDate('2026-10-28 17:05'),
        DateTime(2026, 10, 28, 17, 5),
      );
      expect(parseAbsoluteDate('2026-10-28 5pm'), DateTime(2026, 10, 28, 17));
      expect(
        parseAbsoluteDate('2026-10-28T09:00:00Z'),
        DateTime.utc(2026, 10, 28, 9).toLocal(),
      );
      expect(
        parseAbsoluteDate('2026-10-28T09:00:00+0800'),
        DateTime.utc(2026, 10, 28, 1).toLocal(),
      );
      expect(
        parseAbsoluteDate('2026-10-28T09:00:00.000-05:30'),
        DateTime.utc(2026, 10, 28, 14, 30).toLocal(),
      );
    });

    test('rejects impossible or foreign values', () {
      expect(parseAbsoluteDate('2026-02-30'), isNull);
      expect(parseAbsoluteDate('2026-10-28 25:00'), isNull);
      expect(parseAbsoluteDate('tomorrow'), isNull);
      expect(parseAbsoluteDate(''), isNull);
    });

    test('Todoist month-name dates use the current year', () {
      expect(parseExportDate('Mar 15', now: now), DateTime(2026, 3, 15));
      expect(parseExportDate('15 March 2027', now: now), DateTime(2027, 3, 15));
      expect(
        parseExportDate('Oct 28, 2026 5pm', now: now),
        DateTime(2026, 10, 28, 17),
      );
      expect(
        parseExportDate('oct 28 at 17:30', now: now),
        DateTime(2026, 10, 28, 17, 30),
      );
      expect(parseExportDate('Mar 15 5', now: now), isNull);
      expect(parseExportDate('next Thursday -3d', now: now), isNull);
    });
  });

  group('repeats', () {
    test('RRULE with weekdays, count and until', () {
      final r = parseRRule('RRULE:FREQ=WEEKLY;INTERVAL=2;BYDAY=FR,MO;COUNT=5')!;
      expect(r.frequency, Recurrence.weekly);
      expect(r.interval, 2);
      expect(r.byWeekdays, [1, 5]);
      expect(r.count, 5);
      final u = parseRRule('FREQ=DAILY;UNTIL=20261231T000000Z')!;
      expect(u.until, DateTime(2026, 12, 31));
    });

    test('RRULE nth weekday of the month', () {
      final r = parseRRule('FREQ=MONTHLY;BYDAY=-1FR')!;
      expect((r.monthlyWeek, r.monthlyWeekday), (-1, DateTime.friday));
      final p = parseRRule('FREQ=MONTHLY;BYDAY=TU;BYSETPOS=2')!;
      expect((p.monthlyWeek, p.monthlyWeekday), (2, DateTime.tuesday));
    });

    test('RRULE month day must restate the anchor', () {
      final anchor = DateTime(2026, 11, 15);
      expect(parseRRule('FREQ=MONTHLY;BYMONTHDAY=15', anchor: anchor), isNotNull);
      expect(parseRRule('FREQ=MONTHLY;BYMONTHDAY=1,15', anchor: anchor), isNull);
      expect(parseRRule('FREQ=MONTHLY;BYMONTHDAY=15'), isNull);
    });

    test('RRULE with unknown parts is not mapped', () {
      expect(parseRRule('FREQ=DAILY;TT_SKIP=WEEKEND'), isNull);
      expect(parseRRule('FREQ=HOURLY'), isNull);
      expect(parseRRule('FREQ=WEEKLY;INTERVAL=0'), isNull);
      expect(parseRRule('garbage'), isNull);
    });

    test('English every-phrases', () {
      expect(parseEveryPhrase('every day')!.repeat.frequency, Recurrence.daily);
      expect(parseEveryPhrase('Every 3 Weeks')!.repeat.interval, 3);
      expect(parseEveryPhrase('every other month')!.repeat.interval, 2);
      expect(parseEveryPhrase('every weekday')!.repeat.byWeekdays, [1, 2, 3, 4, 5]);
      expect(parseEveryPhrase('every mon, fri')!.repeat.byWeekdays, [1, 5]);
      final at = parseEveryPhrase('every monday at 9am')!;
      expect(at.repeat.byWeekdays, [1]);
      expect((at.time!.hour, at.time!.minute), (9, 0));
      expect(parseEveryPhrase('every 2nd tue'), isNull);
      expect(parseEveryPhrase('every! day'), isNull);
      expect(parseEveryPhrase('every day starting jan 5'), isNull);
    });

    test('first occurrence lands on the next listed weekday', () {
      const r = ImportedRepeat(frequency: Recurrence.weekly, byWeekdays: [3]);
      expect(firstOccurrence(r, DateTime(2026, 10, 26, 10)), DateTime(2026, 10, 28));
    });
  });

  test('minutes', () {
    expect(parseMinutes('45'), 45);
    expect(parseMinutes('1h30m'), 90);
    expect(parseMinutes('1.5h'), 90);
    expect(parseMinutes('2 hours'), 120);
    expect(parseMinutes('30min'), 30);
    expect(parseMinutes('3w'), isNull);
    expect(parseMinutes('0'), isNull);
  });

  test('special list names, including localized Inbox names', () {
    expect(specialListStatus('Inbox'), ItemStatus.inbox);
    expect(specialListStatus('Eingang'), ItemStatus.inbox);
    expect(specialListStatus('收集箱'), ItemStatus.inbox);
    expect(specialListStatus('Someday / Maybe'), ItemStatus.someday);
    expect(specialListStatus('Waiting For'), ItemStatus.waiting);
    expect(specialListStatus('Garage'), isNull);
  });
}
