import 'package:flutter_test/flutter_test.dart';
import 'package:cleartray/core/search_text.dart';

void main() {
  group('normalizeForSearch', () {
    test('folds case and Latin diacritics to a common form', () {
      for (final s in ['Café', 'CAFÉ', 'café', 'cafe']) {
        expect(normalizeForSearch(s), 'cafe', reason: '"$s"');
      }
    });

    test('handles accented Latin scripts users actually type', () {
      expect(normalizeForSearch('São Paulo'), 'sao paulo');
      expect(normalizeForSearch('Đà Nẵng'), 'da nang'); // Vietnamese
      expect(normalizeForSearch('Žluťoučký'), 'zlutoucky'); // Czech
      expect(normalizeForSearch('Łódź'), 'lodz'); // Polish
      expect(normalizeForSearch('Müller'), 'muller'); // German
    });

    test('non-Latin scripts pass through unchanged (CJK substring kept)',
        () {
      expect(normalizeForSearch('买牛奶'), '买牛奶');
    });

    test('empty and whitespace-only input is safe', () {
      expect(normalizeForSearch(''), '');
      expect(normalizeForSearch('   '), '   ');
    });
  });

  group('isSearchableQuery', () {
    test('Latin needs at least two characters', () {
      expect(isSearchableQuery(''), isFalse);
      expect(isSearchableQuery('a'), isFalse);
      expect(isSearchableQuery('ab'), isTrue);
    });

    test('a single CJK character is searchable (one char is a word)', () {
      expect(isSearchableQuery('知'), isTrue); // Chinese
      expect(isSearchableQuery('ア'), isTrue); // Katakana
      expect(isSearchableQuery('한'), isTrue); // Hangul
    });

    test('trims before measuring', () {
      expect(isSearchableQuery('  知  '), isTrue);
      expect(isSearchableQuery('  a  '), isFalse);
      expect(isSearchableQuery('   '), isFalse);
    });
  });

  group('searchTextFor', () {
    test('folds the joined title and notes', () {
      expect(searchTextFor('Café', 'São note'), 'cafe\nsao note');
    });

    test('null notes joins against an empty string', () {
      expect(searchTextFor('Café', null), 'cafe\n');
    });

    test('newline separator prevents matching across the title/notes seam',
        () {
      // "x\ny" must not contain the cross-boundary substring "xy".
      expect(searchTextFor('ax', 'yb').contains('xy'), isFalse);
    });
  });
}
