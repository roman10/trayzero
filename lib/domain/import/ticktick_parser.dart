import '../entities/entities.dart';
import 'csv.dart';
import 'import_plan.dart';
import 'import_values.dart';

/// TickTick web backup CSV (ADR 0008). The file opens with a few preamble
/// rows (export date, version, a status legend) before the header row that
/// names `Folder Name`, `List Name`, and `Title`; columns are read by name
/// because TickTick has inserted new ones over time.
///
/// TickTick's single task date is stored as the start date, with the due
/// date equal to it (or after it for a time range). One date is therefore
/// the due date; a range keeps its start as the start date.
ImportPlan parseTickTick(String text) {
  final rows = parseCsv(text);
  final headerAt = rows.indexWhere((r) {
    final names = r.map(normalizeHeader).toSet();
    return names.containsAll(['foldername', 'listname', 'title']);
  });
  if (headerAt < 0) {
    throw const ImportFormatException(ImportFailure.unrecognized);
  }
  final table = CsvTable(rows[headerAt], rows.sublist(headerAt + 1));
  final builder = ImportPlanBuilder();

  final titleById = <String, String>{
    for (final row in table.rows)
      if (table.cell(row, 'taskId').isNotEmpty &&
          table.cell(row, 'Title').isNotEmpty)
        table.cell(row, 'taskId'): table.cell(row, 'Title'),
  };

  for (final row in table.rows) {
    final title = table.cell(row, 'Title');
    if (title.isEmpty) {
      builder.warn(ImportWarning.unreadableRows);
      continue;
    }
    final state = table.cell(row, 'Status');
    if (state.isNotEmpty && state != '0') {
      builder.warn(ImportWarning.completedSkipped);
      continue;
    }

    final listName = table.cell(row, 'List Name');
    final special = listName.isEmpty
        ? ItemStatus.inbox
        : specialListStatus(listName);
    final project = special == null ? builder.project(listName) : null;
    var status = special ?? ItemStatus.nextAction;
    if (table.cell(row, 'Kind').toUpperCase() == 'NOTE') {
      status = ItemStatus.reference;
    }

    final notes = <String?>[table.cell(row, 'Content')];
    final folder = table.cell(row, 'Folder Name');
    final column = table.cell(row, 'Column Name');
    if (folder.isNotEmpty) notes.add('Folder: $folder');
    if (column.isNotEmpty) notes.add('Section: $column');
    if (folder.isNotEmpty || column.isNotEmpty) {
      builder.warn(ImportWarning.sectionsInNotes);
    }
    final parent = titleById[table.cell(row, 'parentId')];
    if (parent != null) {
      notes.add('Subtask of: $parent');
      builder.warn(ImportWarning.subtasksFlattened);
    }

    final allDay = table.cell(row, 'Is All Day').toLowerCase() == 'true';
    final floating = table.cell(row, 'Is Floating').toLowerCase() == 'true';
    DateTime? read(String column) {
      final raw = table.cell(row, column);
      if (raw.isEmpty) return null;
      // All-day and floating dates describe wall time, not an instant.
      // Applying the export offset can otherwise move them to another day.
      final value = allDay || floating
          ? raw.replaceFirst(
              RegExp(r'(Z|[+-]\d{2}:?\d{2})$', caseSensitive: false),
              '',
            )
          : raw;
      final d = parseAbsoluteDate(value);
      if (d == null) {
        notes.add('$column: $raw');
        builder.warn(ImportWarning.unparsedDate);
        return null;
      }
      return allDay ? DateTime(d.year, d.month, d.day) : d;
    }

    final start = read('Start Date');
    final due = read('Due Date');
    final DateTime? dueAt;
    final DateTime? deferUntil;
    if (start != null && due != null && start.isBefore(due)) {
      dueAt = due;
      deferUntil = start;
    } else {
      dueAt = due ?? start;
      deferUntil = null;
    }

    ImportedRepeat? repeat;
    final rule = table.cell(row, 'Repeat');
    if (rule.isNotEmpty) {
      final anchor = dueAt ?? deferUntil;
      repeat = anchor == null ? null : parseRRule(rule, anchor: anchor);
      if (repeat == null) {
        notes.add('Repeats: $rule');
        builder.warn(ImportWarning.repeatInNotes);
      }
    }
    final priority = table.cell(row, 'Priority');
    if (priority.isNotEmpty && priority != '0') {
      builder.warn(ImportWarning.notImported);
    }

    builder.add(
      ImportedItem(
        title: title,
        status: status,
        notes: joinNotes(notes),
        project: project,
        tags: [
          for (final t in table.cell(row, 'Tags').split(','))
            if (t.trim().isNotEmpty) t.trim(),
        ],
        dueAt: dueAt,
        deferUntil: deferUntil,
        repeat: repeat,
      ),
    );
  }
  return builder.build(ImportSourceApp.tickTick);
}
