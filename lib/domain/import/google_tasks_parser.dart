import 'dart:convert';

import '../entities/entities.dart';
import 'google_tasks_dates.dart';
import 'import_plan.dart';

/// Google Takeout Tasks.json. Preserve the legacy Google import mapping:
/// lists stay in notes, open tasks enter Inbox, completed tasks enter Done.
ImportPlan parseGoogleTasks(String text, {required DateTime now}) {
  final Object? raw;
  try {
    raw = jsonDecode(text);
  } on FormatException {
    throw const ImportFormatException(ImportFailure.unrecognized);
  }
  if (raw is! Map || raw.containsKey('version') || raw['items'] is! List) {
    throw const ImportFormatException(ImportFailure.unrecognized);
  }
  final lists = raw['items'] as List;
  if (raw['kind'] != 'tasks#taskLists' &&
      (lists.isEmpty || !lists.every((l) => l is Map && l['items'] is List))) {
    throw const ImportFormatException(ImportFailure.unrecognized);
  }
  final builder = ImportPlanBuilder();
  String? string(Object? v) =>
      v is String && v.trim().isNotEmpty ? v.trim() : null;
  for (final list in lists) {
    if (list is! Map || list['items'] is! List) {
      builder.warn(ImportWarning.unreadableRows);
      continue;
    }
    final tasks = list['items'] as List;
    final titles = <String, String>{
      for (final task in tasks)
        if (task is Map &&
            string(task['id']) != null &&
            string(task['title']) != null)
          string(task['id'])!: string(task['title'])!,
    };
    for (final task in tasks) {
      if (task is! Map) {
        builder.warn(ImportWarning.unreadableRows);
        continue;
      }
      if (task['deleted'] == true) {
        builder.warn(ImportWarning.completedSkipped);
        continue;
      }
      final notes = <String?>[string(task['notes'])];
      final meta = <String>[];
      final listName = string(list['title']);
      if (listName != null) meta.add('List: $listName');
      final parent = titles[string(task['parent'])];
      if (parent != null) {
        meta.add('Subtask of: $parent');
        builder.warn(ImportWarning.subtasksFlattened);
      }
      if (meta.isNotEmpty) notes.add(meta.join(' · '));
      DateTime? date(Object? raw, String label) {
        final value = string(raw);
        if (value == null) return null;
        final parsed = DateTime.tryParse(value)?.toLocal();
        if (parsed == null) {
          notes.add('$label: $value');
          builder.warn(ImportWarning.unparsedDate);
        }
        return parsed;
      }

      final scheduled = task['scheduled_time'];
      Map? current;
      if (scheduled is List) {
        for (final entry in scheduled.whereType<Map>()) {
          current ??= entry;
          if (entry['current'] == true) {
            current = entry;
            break;
          }
        }
      }
      final scheduledAt = date(current?['start'], 'Scheduled');
      DateTime? dueDate;
      if (scheduledAt == null) {
        final value = string(task['due']);
        dueDate = parseGoogleTasksDueDate(value);
        if (value != null && dueDate == null) {
          notes.add('Due: $value');
          builder.warn(ImportWarning.unparsedDate);
        }
      }
      final due = scheduledAt ?? dueDate;
      final updated = date(task['updated'], 'Updated');
      final created = date(task['created'], 'Created') ?? updated ?? now;
      final done = task['status'] == 'completed' || task['completed'] != null;
      final completed = done
          ? (date(task['completed'], 'Completed') ?? updated ?? created)
          : null;
      builder.add(
        ImportedItem(
          title: string(task['title']) ?? '(untitled)',
          notes: joinNotes(notes),
          status: done ? ItemStatus.done : ItemStatus.inbox,
          dueAt: due,
          createdAt: created,
          updatedAt: updated ?? created,
          completedAt: completed,
        ),
      );
    }
  }
  return builder.build(ImportSourceApp.googleTasks);
}
