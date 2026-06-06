import 'package:diacritic/diacritic.dart';

/// Folds text for accent- and case-insensitive search. Latin diacritics are
/// stripped (café -> cafe); non-Latin scripts (CJK, etc.) pass through
/// unchanged, so exact-character substring search there is preserved.
///
/// Used for BOTH the stored `Items.searchText` column and the search query
/// so the two are always normalised identically and can never drift apart.
String normalizeForSearch(String input) =>
    removeDiacritics(input.toLowerCase());

/// The value persisted in `Items.searchText`. Title and notes are joined
/// with a newline so a query term cannot false-match across the boundary
/// (a user query never contains '\n').
String searchTextFor(String title, String? notes) =>
    normalizeForSearch('$title\n${notes ?? ''}');

/// Whether [query] is substantial enough to run a search. Latin needs two
/// characters (a one-letter query is almost always noise), but a single
/// CJK codepoint is frequently a whole word, so one such character counts.
/// The query is trimmed first — leading/trailing spaces never count.
///
/// The single source of truth for the "is the query long enough" gate, used
/// by both the results provider and the screen's empty-state hint so the two
/// can never disagree.
bool isSearchableQuery(String query) {
  final q = query.trim();
  return q.length >= 2 || (q.isNotEmpty && _hasCjk(q));
}

/// True if [s] contains any CJK codepoint — Hiragana/Katakana, CJK Unified
/// Ideographs (incl. Extension A), Hangul syllables, or CJK compatibility
/// ideographs — i.e. a script where one character can stand alone as a query.
bool _hasCjk(String s) => s.runes.any((r) =>
    (r >= 0x3040 && r <= 0x30FF) || // Hiragana + Katakana
    (r >= 0x3400 && r <= 0x4DBF) || // CJK Unified Ideographs Extension A
    (r >= 0x4E00 && r <= 0x9FFF) || // CJK Unified Ideographs
    (r >= 0xAC00 && r <= 0xD7AF) || // Hangul Syllables
    (r >= 0xF900 && r <= 0xFAFF)); // CJK Compatibility Ideographs
