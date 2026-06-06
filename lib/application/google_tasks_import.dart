/// Converts a Google Takeout `Tasks.json` export into a Trayzero v2 backup
/// map so it can flow through the normal import path (preview → confirm →
/// restore) without any separate UI.
///
/// Takeout shape:
/// `{"kind":"tasks#taskLists","items":[ {title,id,items:[task,…]} ]}`
///
/// Mapping (per product decision):
///  - Every Google task becomes one Trayzero item.
///  - Open tasks (`needsAction`) → Inbox; completed tasks → Done with their
///    completion date.
///  - Lists are NOT turned into projects/contexts; the source list name is
///    kept in the item's notes. Subtasks are flattened to top-level items
///    with the parent task's title recorded in notes (Trayzero has no
///    subtask hierarchy).
library;

/// True when [raw] looks like a Google Takeout Tasks export rather than a
/// Trayzero backup.
bool isGoogleTasksExport(Map<String, Object?> raw) {
  if (raw['kind'] == 'tasks#taskLists') return true;
  // Fallback heuristic: a Trayzero backup always carries `version`; a
  // Takeout export does not, and its `items` are task-list-shaped.
  if (raw.containsKey('version')) return false;
  final lists = raw['items'];
  if (lists is! List || lists.isEmpty) return false;
  return lists.every(
    (l) => l is Map && (l['kind'] == 'tasks#tasks' || l['items'] is List),
  );
}

/// Builds a Trayzero v2 backup map from a Takeout Tasks export. [fallback]
/// is used for tasks missing a usable timestamp.
Map<String, Object?> convertGoogleTasksExport(
  Map<String, Object?> raw, {
  required DateTime fallback,
}) {
  final fallbackIso = fallback.toUtc().toIso8601String();
  final items = <Map<String, Object?>>[];
  final lists = raw['items'];
  if (lists is List) {
    for (final rawList in lists) {
      if (rawList is! Map) continue;
      final listName = rawList['title'] as String?;
      final tasks = rawList['items'];
      if (tasks is! List) continue;

      // Resolve `parent` references to a title within this list.
      final titleById = <String, String>{};
      for (final t in tasks) {
        if (t is Map) {
          final id = t['id'];
          final title = t['title'];
          if (id is String && title is String) titleById[id] = title;
        }
      }

      for (final t in tasks) {
        if (t is! Map) continue;
        final task = t.cast<String, Object?>();
        final parent = task['parent'];
        items.add(_taskToItem(
          task,
          listName: listName,
          parentTitle: parent is String ? titleById[parent] : null,
          fallbackIso: fallbackIso,
          sortOrder: items.length,
        ));
      }
    }
  }

  return {
    'version': 2,
    'exportedAt': fallbackIso,
    'contexts': const <Object?>[],
    'areas': const <Object?>[],
    'projects': const <Object?>[],
    'items': items,
  };
}

Map<String, Object?> _taskToItem(
  Map<String, Object?> task, {
  required String? listName,
  required String? parentTitle,
  required String fallbackIso,
  required int sortOrder,
}) {
  final completed =
      task['status'] == 'completed' || task['completed'] != null;
  final created = _normDate(task['created']) ??
      _normDate(task['updated']) ??
      fallbackIso;
  final updated = _normDate(task['updated']) ?? created;

  final rawId = task['id'];
  final id = (rawId is String && rawId.isNotEmpty)
      ? 'gt-$rawId'
      : 'gt-$sortOrder';

  final title = (task['title'] as String?)?.trim();

  return {
    'id': id,
    'title': (title == null || title.isEmpty) ? '(untitled)' : title,
    'notes': _buildNotes(task['notes'], listName, parentTitle),
    'status': completed ? 'done' : 'inbox',
    'projectId': null,
    'contextId': null,
    'dueAt': _scheduledDate(task) ?? _normDate(task['due']),
    'deferUntil': null,
    'waitingOn': null,
    'energy': null,
    'timeEstimateMinutes': null,
    'isTwoMin': false,
    'createdAt': created,
    'updatedAt': updated,
    // Keep Done items dated so they surface in completed views even when
    // Google omitted the completion timestamp.
    'completedAt':
        completed ? (_normDate(task['completed']) ?? updated) : null,
    'previousStatus': null,
    'sortOrder': sortOrder,
    'recurrence': null,
    'recurrenceInterval': 1,
  };
}

/// Google scheduled-date shape: `"scheduled_time":[{"current":true,
/// "start":"...iso..."}]`. Prefer the entry flagged `current`, else first.
String? _scheduledDate(Map<String, Object?> task) {
  final sched = task['scheduled_time'];
  if (sched is! List || sched.isEmpty) return null;
  Map<Object?, Object?>? chosen;
  for (final e in sched) {
    if (e is Map) {
      if (e['current'] == true) {
        chosen = e;
        break;
      }
      chosen ??= e;
    }
  }
  return chosen == null ? null : _normDate(chosen['start']);
}

String? _buildNotes(Object? original, String? listName, String? parentTitle) {
  final parts = <String>[];
  if (original is String && original.trim().isNotEmpty) {
    parts.add(original.trim());
  }
  final meta = <String>[];
  if (listName != null && listName.isNotEmpty) meta.add('List: $listName');
  if (parentTitle != null && parentTitle.isNotEmpty) {
    meta.add('Subtask of: $parentTitle');
  }
  if (meta.isNotEmpty) parts.add(meta.join(' · '));
  return parts.isEmpty ? null : parts.join('\n\n');
}

/// Google uses RFC3339 (often with a trailing `Z` and microseconds).
/// Returns a normalised ISO-8601 string the backup importer can re-parse,
/// or null when absent/unparseable.
String? _normDate(Object? v) {
  if (v is! String || v.isEmpty) return null;
  return DateTime.tryParse(v)?.toIso8601String();
}
