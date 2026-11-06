import '../entities/entities.dart';
import 'csv.dart';
import 'import_plan.dart';
import 'import_values.dart';

/// Todoist project CSV export, or the CSV files of a Todoist backup ZIP
/// (ADR 0008). Each file is one Todoist project, named by the file name
/// (`Work [2203306141].csv` → "Work"). Columns follow Todoist's published
/// template; only `TYPE` and `CONTENT` are required.
///
/// `DATE` is Todoist's due date. When the task also has a `DEADLINE`, the
/// deadline is the due date and `DATE` becomes the start date. Labels are
/// written inline in `CONTENT` as `@label`.
ImportPlan parseTodoist(
  List<({String name, String text})> files, {
  required DateTime now,
}) {
  final builder = ImportPlanBuilder();
  var recognized = false;
  for (final file in files) {
    final rows = parseCsv(file.text);
    if (rows.isEmpty) continue;
    final table = CsvTable(rows.first, rows.skip(1).toList());
    if (!table.has('TYPE') || !table.has('CONTENT')) continue;
    recognized = true;
    _parseProject(builder, table, todoistProjectName(file.name), now);
  }
  if (!recognized) throw const ImportFormatException(ImportFailure.unrecognized);
  return builder.build(ImportSourceApp.todoist);
}

/// `Exports/Work [2203306141].csv` → `Work`.
String todoistProjectName(String fileName) {
  final base = fileName.split(RegExp(r'[/\\]')).last;
  return base
      .replaceFirst(RegExp(r'\.csv$', caseSensitive: false), '')
      .replaceFirst(RegExp(r'\s*\[\d+\]$'), '')
      .trim();
}

final _label = RegExp(r'(?<=^|\s)@([^\s@]+)', unicode: true);

class _Task {
  _Task(this.title);
  final String title;
  final notes = <String?>[];
  final tags = <String>[];
  String? priority;
  bool assigned = false;
  DateTime? dueAt;
  DateTime? deferUntil;
  ImportedRepeat? repeat;
  int? minutes;
}

void _parseProject(
  ImportPlanBuilder builder,
  CsvTable table,
  String projectName,
  DateTime now,
) {
  final special = specialListStatus(projectName);
  final project = projectName.isEmpty || special != null
      ? null
      : builder.project(projectName);
  final status = special ?? ItemStatus.nextAction;

  final tasks = <_Task>[];
  // Titles of the open task at each indent level, for subtask notes.
  final parents = <int, String>{};
  String? section;
  for (final row in table.rows) {
    final type = table.cell(row, 'TYPE').toLowerCase();
    // Todoist includes project settings such as view_style in meta rows.
    // They are not tasks and must not affect task/comment nesting or warnings.
    if (type == 'meta') continue;
    final content = table.cell(row, 'CONTENT');
    if (type == 'section') {
      section = content.isEmpty ? null : content;
      parents.clear();
      continue;
    }
    if (type == 'note') {
      if (tasks.isNotEmpty && content.isNotEmpty) tasks.last.notes.add(content);
      continue;
    }
    if (type != 'task') {
      if (type.isNotEmpty || content.isNotEmpty) {
        builder.warn(ImportWarning.unreadableRows);
      }
      continue;
    }
    final tags = [for (final m in _label.allMatches(content)) m.group(1)!];
    final title = content
        .replaceAll(_label, ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (title.isEmpty) {
      builder.warn(ImportWarning.unreadableRows);
      continue;
    }
    final task = _Task(title)..tags.addAll(tags);
    task.notes.add(table.cell(row, 'DESCRIPTION'));
    if (section != null) {
      task.notes.add('Section: $section');
      builder.warn(ImportWarning.sectionsInNotes);
    }
    final indent = int.tryParse(table.cell(row, 'INDENT')) ?? 1;
    final parent = indent > 1 ? parents[indent - 1] : null;
    if (parent != null) {
      task.notes.add('Subtask of: $parent');
      builder.warn(ImportWarning.subtasksFlattened);
    }
    parents
      ..removeWhere((level, _) => level >= indent)
      ..[indent] = title;
    task.priority = table.cell(row, 'PRIORITY');
    task.assigned = table.cell(row, 'RESPONSIBLE').isNotEmpty;
    _readDates(builder, table, row, task, now);
    final duration = table.cell(row, 'DURATION');
    if (duration.isNotEmpty && duration.toLowerCase() != 'none') {
      task.minutes = parseMinutes(duration);
    }
    tasks.add(task);
  }

  _countPriorities(builder, tasks);
  for (final t in tasks) {
    builder.add(
      ImportedItem(
        title: t.title,
        status: status,
        notes: joinNotes(t.notes),
        project: project,
        tags: t.tags,
        dueAt: t.dueAt,
        deferUntil: t.deferUntil,
        timeEstimateMinutes: t.minutes,
        repeat: t.repeat,
      ),
    );
  }
}

void _readDates(
  ImportPlanBuilder builder,
  CsvTable table,
  List<String> row,
  _Task task,
  DateTime now,
) {
  final dateText = table.cell(row, 'DATE');
  final deadlineText = table.cell(row, 'DEADLINE');
  DateTime? deadline;
  if (deadlineText.isNotEmpty) {
    deadline = parseExportDate(deadlineText, now: now);
    if (deadline == null) {
      task.notes.add('Deadline: $deadlineText');
      builder.warn(ImportWarning.unparsedDate);
    }
  }
  DateTime? date;
  if (dateText.isNotEmpty) {
    final every = parseEveryPhrase(dateText);
    if (every != null) {
      final first = firstOccurrence(every.repeat, now);
      date = every.time == null
          ? first
          : DateTime(
              first.year,
              first.month,
              first.day,
              every.time!.hour,
              every.time!.minute,
            );
      task.repeat = every.repeat;
    } else {
      date = parseExportDate(dateText, now: now);
      if (date == null) {
        final repeating = dateText.toLowerCase().contains('every');
        task.notes.add('${repeating ? 'Repeats' : 'Date'}: $dateText');
        builder.warn(
          repeating ? ImportWarning.repeatInNotes : ImportWarning.unparsedDate,
        );
      }
    }
  }
  if (deadline != null) {
    task
      ..dueAt = deadline
      ..deferUntil = date;
  } else {
    task.dueAt = date;
  }
}

/// Counts tasks with an assignee or a priority, neither of which Trayzero
/// has. Todoist's priority numbering is not stable across export versions,
/// so the unprioritized value is taken to be the most common one.
void _countPriorities(ImportPlanBuilder builder, List<_Task> tasks) {
  final counts = <String, int>{};
  for (final t in tasks) {
    final p = t.priority;
    if (p != null && p.isNotEmpty) {
      counts.update(p, (n) => n + 1, ifAbsent: () => 1);
    }
  }
  final common = counts.isEmpty
      ? null
      : counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  bool prioritized(_Task t) =>
      counts.length > 1 && (t.priority ?? '').isNotEmpty && t.priority != common;
  builder.warn(
    ImportWarning.notImported,
    tasks.where((t) => t.assigned || prioritized(t)).length,
  );
}
