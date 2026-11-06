/// A small RFC 4180 CSV reader for task-app exports (ADR 0008).
///
/// Tolerates what real exports and spreadsheet re-saves produce: a leading
/// byte-order mark, CRLF / LF / lone CR line endings, quoted fields holding
/// delimiters, doubled quotes, and line breaks, and a semicolon delimiter
/// (Excel in many European locales). An unterminated quote swallows the rest
/// of the input into one field rather than throwing; callers validate rows.
library;

/// Parses [text] into rows of fields. Blank lines are dropped. The delimiter
/// is a comma unless the first line has more semicolons than commas outside
/// quotes.
List<List<String>> parseCsv(String text) {
  final input = text.startsWith('﻿') ? text.substring(1) : text;
  final delimiter = _detectDelimiter(input);
  final rows = <List<String>>[];
  var row = <String>[];
  final field = StringBuffer();
  // Text after a closing quote is appended verbatim (lenient, like
  // spreadsheets); a quote inside an unquoted field is literal.
  var inQuotes = false;
  var i = 0;

  void endField() {
    row.add(field.toString());
    field.clear();
  }

  void endRow() {
    endField();
    if (!(row.length == 1 && row.single.isEmpty)) rows.add(row);
    row = <String>[];
  }

  while (i < input.length) {
    final c = input[i];
    if (inQuotes) {
      if (c == '"') {
        if (i + 1 < input.length && input[i + 1] == '"') {
          field.write('"');
          i += 2;
          continue;
        }
        inQuotes = false;
      } else if (c == '\r') {
        // Line breaks inside a field are normalized to `\n` for notes.
        field.write('\n');
        if (i + 1 < input.length && input[i + 1] == '\n') i++;
      } else {
        field.write(c);
      }
      i++;
      continue;
    }
    if (c == '"' && field.isEmpty) {
      inQuotes = true;
    } else if (c == delimiter) {
      endField();
    } else if (c == '\r') {
      endRow();
      if (i + 1 < input.length && input[i + 1] == '\n') i++;
    } else if (c == '\n') {
      endRow();
    } else {
      field.write(c);
    }
    i++;
  }
  if (field.isNotEmpty || row.isNotEmpty || inQuotes) endRow();
  return rows;
}

String _detectDelimiter(String input) {
  var commas = 0;
  var semicolons = 0;
  var inQuotes = false;
  for (var i = 0; i < input.length; i++) {
    final c = input[i];
    if (c == '"') {
      inQuotes = !inQuotes;
    } else if (!inQuotes) {
      if (c == '\n' || c == '\r') break;
      if (c == ',') commas++;
      if (c == ';') semicolons++;
    }
  }
  return semicolons > commas ? ';' : ',';
}

/// A parsed CSV table addressed by header name. Header matching ignores
/// case, surrounding spaces, and non-alphanumeric characters, so
/// `"Due Date"`, `DUEDATE`, and `due_date` are the same column.
final class CsvTable {
  CsvTable(List<String> header, this.rows)
    : _index = {
        for (var i = header.length - 1; i >= 0; i--)
          normalizeHeader(header[i]): i,
      };

  final List<List<String>> rows;
  final Map<String, int> _index;

  bool has(String column) => _index.containsKey(normalizeHeader(column));

  /// The trimmed value of [column] in [row], or `''` when the column is
  /// absent or the row is short.
  String cell(List<String> row, String column) {
    final i = _index[normalizeHeader(column)];
    if (i == null || i >= row.length) return '';
    return row[i].trim();
  }

  /// The first non-empty value among [columns].
  String first(List<String> row, List<String> columns) {
    for (final c in columns) {
      final v = cell(row, c);
      if (v.isNotEmpty) return v;
    }
    return '';
  }
}

String normalizeHeader(String name) =>
    name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
