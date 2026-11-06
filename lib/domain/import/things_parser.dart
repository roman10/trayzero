import '../entities/entities.dart';
import 'import_plan.dart';

/// Maps validated tables copied from a Things export. Pure Dart: no SQLite,
/// device, file-path, or Flutter dependencies.
ImportPlan parseThings(Map<String, List<Map<String, Object?>>> snapshot) {
  final builder = ImportPlanBuilder();
  String text(Map<String, Object?> row, String key) =>
      row[key] is String ? (row[key] as String).trim() : '';
  final tasks = {for (final r in snapshot['TMTask']!) text(r, 'uuid'): r};
  final areas = {
    for (final r in snapshot['TMArea']!) text(r, 'uuid'): text(r, 'title'),
  };
  final tags = {
    for (final r in snapshot['TMTag']!) text(r, 'uuid'): text(r, 'title'),
  };
  final taskTags = <String, List<String>>{};
  for (final r in snapshot['TMTaskTag']!) {
    final name = tags[text(r, 'tags')];
    if (name != null && name.isNotEmpty) {
      taskTags.putIfAbsent(text(r, 'tasks'), () => []).add(name);
    }
  }
  final checklist = <String, List<Map<String, Object?>>>{};
  for (final r in snapshot['TMChecklistItem']!) {
    checklist.putIfAbsent(text(r, 'task'), () => []).add(r);
  }
  for (final rows in checklist.values) {
    rows.sort(
      (a, b) =>
          ((a['index'] as num?) ?? 0).compareTo((b['index'] as num?) ?? 0),
    );
  }
  bool closed(Map<String, Object?> r) => r['status'] != 0 || r['trashed'] != 0;
  bool template(Map<String, Object?> r) =>
      r['rt1_recurrenceRule'] != null || r['recurrenceRule'] != null;
  Map<String, Object?>? heading(Map<String, Object?> r) =>
      tasks[text(r, r.containsKey('heading') ? 'heading' : 'actionGroup')];
  Map<String, Object?>? project(Map<String, Object?> r) {
    final direct = tasks[text(r, 'project')];
    if (direct?['type'] == 1) return direct;
    final h = heading(r);
    final parent = h == null ? null : tasks[text(h, 'project')];
    return parent?['type'] == 1 ? parent : null;
  }

  bool hasChecklistDetails(Map<String, Object?> r) =>
      (checklist[text(r, 'uuid')] ?? const <Map<String, Object?>>[]).any(
        (entry) => text(entry, 'title').isNotEmpty,
      );

  List<String> metadata(Map<String, Object?> r) {
    final notes = <String>[if (text(r, 'notes').isNotEmpty) text(r, 'notes')];
    for (final c in checklist[text(r, 'uuid')] ?? <Map<String, Object?>>[]) {
      final title = text(c, 'title');
      if (title.isNotEmpty) {
        notes.add('${c['status'] == 0 ? '[ ]' : '[x]'} $title');
      }
    }
    if (hasChecklistDetails(r)) {
      builder.warn(ImportWarning.detailsInNotes);
    }
    final rule =
        r['repeater'] ?? r['rt1_recurrenceRule'] ?? r['recurrenceRule'];
    if (rule != null ||
        text(r, 'rt1_repeatingTemplate').isNotEmpty ||
        text(r, 'repeatingTemplate').isNotEmpty) {
      // Native recurrence blobs have no stable interchange specification.
      notes.add('Things: repeating task; recreate its repeat schedule.');
      builder.warn(ImportWarning.thingsRecurrence);
    }
    if (r['reminderTime'] != null || r['alarmTimeOffset'] != null) {
      builder.warn(ImportWarning.sourceReminders);
    }
    return notes;
  }

  DateTime? date(Map<String, Object?> r, String key, List<String> notes) {
    final raw = r[key];
    if (raw == null || raw == 0) return null;
    DateTime? result;
    if (raw is num && raw.isFinite) {
      if (r.containsKey('deadline')) {
        final value = raw.toInt();
        final year = value >> 16,
            month = (value >> 12) & 15,
            day = (value >> 7) & 31;
        if (year >= 1 &&
            year <= 9999 &&
            month >= 1 &&
            month <= 12 &&
            day >= 1) {
          final d = DateTime(year, month, day);
          if (d.day == day && (value & 127) == 0 && raw == value) result = d;
        }
      } else if (raw > 0 && raw < 253402300800) {
        final d = DateTime.fromMillisecondsSinceEpoch(
          (raw * 1000).round(),
        ).toLocal();
        result = DateTime(d.year, d.month, d.day);
      }
    }
    if (result == null) {
      notes.add('Things $key: $raw');
      builder.warn(ImportWarning.unparsedDate);
    }
    return result;
  }

  final projectNames = <String, String>{};
  final projectStarts = <String, DateTime>{};
  for (final r in snapshot['TMTask']!.where((r) => r['type'] == 1)) {
    if (closed(r)) continue;
    if (template(r)) {
      builder.warn(ImportWarning.thingsRecurrence);
      continue;
    }
    final title = text(r, 'title');
    if (title.isEmpty) {
      builder.warn(ImportWarning.unreadableRows);
      continue;
    }
    final notes = metadata(r);
    final start = date(r, 'startDate', notes);
    if (start != null) projectStarts[text(r, 'uuid')] = start;
    if (start != null) {
      notes.add('Things start: ${start.toIso8601String().split('T').first}');
    }
    final due = date(
      r,
      r.containsKey('deadline') ? 'deadline' : 'dueDate',
      notes,
    );
    projectNames[text(r, 'uuid')] = builder.project(
      title,
      outcome: joinNotes(notes),
      status: r['start'] == 2 ? ProjectStatus.someday : ProjectStatus.active,
      area: areas[text(r, 'area')],
      dueAt: due,
    );
  }
  final ordered = [...snapshot['TMTask']!]
    ..sort(
      (a, b) =>
          ((a['index'] as num?) ?? 0).compareTo((b['index'] as num?) ?? 0),
    );
  for (final r in ordered.where((r) => r['type'] == 0)) {
    final p = project(r), h = heading(r);
    if (closed(r) || (p != null && closed(p)) || (h != null && closed(h))) {
      builder.warn(ImportWarning.completedSkipped);
      continue;
    }
    if (template(r) || (p != null && template(p))) {
      builder.warn(ImportWarning.thingsRecurrence);
      continue;
    }
    final title = text(r, 'title');
    if (title.isEmpty) {
      builder.warn(ImportWarning.unreadableRows);
      continue;
    }
    final notes = metadata(r);
    if (h != null && text(h, 'title').isNotEmpty) {
      notes.add('Section: ${text(h, 'title')}');
      builder.warn(ImportWarning.sectionsInNotes);
    }
    final area = areas[text(r, 'area')];
    if (area != null && area.isNotEmpty) {
      notes.add('Area: $area');
      // This warning counts source tasks, not the number of note blocks.
      if (!hasChecklistDetails(r)) {
        builder.warn(ImportWarning.detailsInNotes);
      }
    }
    final ownStart = date(r, 'startDate', notes);
    final parentStart = p == null ? null : projectStarts[text(p, 'uuid')];
    final start =
        parentStart != null &&
            (ownStart == null || parentStart.isAfter(ownStart))
        ? parentStart
        : ownStart;
    final due = date(
      r,
      r.containsKey('deadline') ? 'deadline' : 'dueDate',
      notes,
    );
    final someday = r['start'] == 2 || p?['start'] == 2;
    builder.add(
      ImportedItem(
        title: title,
        notes: joinNotes(notes),
        project: p == null ? null : projectNames[text(p, 'uuid')],
        status: someday
            ? ItemStatus.someday
            : (r['start'] == 0 && p == null
                  ? ItemStatus.inbox
                  : ItemStatus.nextAction),
        tags: {
          ...?taskTags[text(r, 'uuid')],
          if (p != null) ...?taskTags[text(p, 'uuid')],
          if (h != null) ...?taskTags[text(h, 'uuid')],
        }.toList(),
        dueAt: due,
        deferUntil: start,
      ),
    );
  }
  return builder.build(ImportSourceApp.things);
}
