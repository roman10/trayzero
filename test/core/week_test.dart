import 'package:cleartray/core/week.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('startOfWeek', () {
    test('returns the Monday of a mid-week day at local midnight', () {
      // 2026-05-14 is a Thursday.
      final r = startOfWeek(DateTime(2026, 5, 14, 16, 42));
      expect(r, DateTime(2026, 5, 11)); // Monday
      expect(r.hour, 0);
      expect(r.minute, 0);
      expect(r.second, 0);
    });

    test('returns the same day (midnight) when given a Monday', () {
      final r = startOfWeek(DateTime(2026, 5, 11, 23, 59, 59));
      expect(r, DateTime(2026, 5, 11));
    });

    test('returns the preceding Monday when given a Sunday', () {
      // 2026-05-17 is a Sunday — the week started 6 days earlier.
      final r = startOfWeek(DateTime(2026, 5, 17, 8));
      expect(r, DateTime(2026, 5, 11));
    });

    test('crosses a month boundary correctly', () {
      // 2026-06-02 is a Tuesday; its week starts Mon 2026-06-01.
      expect(startOfWeek(DateTime(2026, 6, 2)), DateTime(2026, 6, 1));
      // 2026-03-01 is a Sunday; its week started Mon 2026-02-23.
      expect(startOfWeek(DateTime(2026, 3, 1)), DateTime(2026, 2, 23));
    });

    test('strips the time component for any input', () {
      final r = startOfWeek(DateTime(2026, 5, 13, 13, 37, 7, 123));
      expect(r, DateTime(2026, 5, 11));
      expect(r.isAtSameMomentAs(DateTime(2026, 5, 11, 0, 0, 0)), isTrue);
    });
  });
}
