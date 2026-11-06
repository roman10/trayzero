import '../entities/entities.dart';

/// Source-neutral result of parsing another app's export (ADR 0008). Each
/// parser in `domain/import/` turns its format into an [ImportPlan]; the
/// resolver then applies merge and context rules against existing names.
/// Nothing here touches storage.

/// Apps the importer reads. OmniFocus and plain text share the TaskPaper
/// parser; the source only changes defaults and copy.
enum ImportSourceApp {
  todoist,
  tickTick,
  nirvana,
  omniFocus,
  plainText,
  appleReminders,
  things,
  googleTasks,
  microsoftToDo,
}

/// Things the preview reports as counts so the user knows what was not
/// carried over as-is. Localized by the UI.
enum ImportWarning {
  /// Source checklist or Area information retained in notes.
  detailsInNotes,

  /// Things recurrence cannot be reconstructed from its private blobs.
  thingsRecurrence,

  /// Source reminder settings must be recreated.
  sourceReminders,

  /// Completed, dropped, trashed, or cancelled tasks that were skipped.
  completedSkipped,

  /// Open actions with a due date that land in Calendar (set by the
  /// resolver: Next Actions cannot hold a due date).
  datedToCalendar,

  /// Dates that could not be read and were kept as text in notes.
  unparsedDate,

  /// Repeat rules that could not be mapped and were kept in notes.
  repeatInNotes,

  /// Subtasks or action groups flattened into separate actions.
  subtasksFlattened,

  /// Section, heading, or folder names kept in notes.
  sectionsInNotes,

  /// Items whose priority, flag, or assignee has no Trayzero equivalent.
  notImported,

  /// Tasks with source attachments, reminder settings or statuses not migrated.
  sourceDetailsNotImported,

  /// Rows or records without a usable title, skipped.
  unreadableRows,
}

/// Why a file could not be turned into a plan at all.
enum ImportFailure {
  /// Not this source's export format.
  unrecognized,

  /// Readable, but holds no open task to import.
  noTasks,

  /// Not text or a usable ZIP (binary, corrupt, or too large).
  unreadable,
}

final class ImportFormatException implements Exception {
  const ImportFormatException(this.failure);
  final ImportFailure failure;

  @override
  String toString() => 'ImportFormatException(${failure.name})';
}

/// A repeat rule that maps exactly onto Trayzero's recurrence fields.
final class ImportedRepeat {
  const ImportedRepeat({
    required this.frequency,
    this.interval = 1,
    this.byWeekdays = const [],
    this.monthlyWeek,
    this.monthlyWeekday,
    this.until,
    this.count,
  });

  final Recurrence frequency;
  final int interval;
  final List<int> byWeekdays;
  final int? monthlyWeek;
  final int? monthlyWeekday;
  final DateTime? until;
  final int? count;
}

final class ImportedProject {
  const ImportedProject({
    required this.title,
    this.outcome,
    this.status = ProjectStatus.active,
    this.area,
    this.dueAt,
  });

  final String title;
  final String? outcome;
  final ProjectStatus status;
  final String? area;
  final DateTime? dueAt;
}

/// One task to create. [project] names an [ImportedProject] in the same
/// plan. [tags] keep their source spelling; a leading `@` means the source
/// itself wrote the tag as a context.
final class ImportedItem {
  const ImportedItem({
    required this.title,
    this.status = ItemStatus.nextAction,
    this.notes,
    this.project,
    this.tags = const [],
    this.dueAt,
    this.dueIsDateOnly,
    this.deferUntil,
    this.waitingOn,
    this.energy,
    this.timeEstimateMinutes,
    this.repeat,
    this.createdAt,
    this.updatedAt,
    this.completedAt,
  });

  final String title;
  final ItemStatus status;
  final String? notes;
  final String? project;
  final List<String> tags;
  final DateTime? dueAt;

  /// Native sources can distinguish midnight from a date without a time.
  /// Null preserves the text importers’ existing heuristic.
  final bool? dueIsDateOnly;
  final DateTime? deferUntil;
  final String? waitingOn;
  final Energy? energy;
  final int? timeEstimateMinutes;
  final ImportedRepeat? repeat;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;
}

final class ImportPlan {
  const ImportPlan({
    required this.source,
    required this.projects,
    required this.items,
    required this.warnings,
    this.fingerprint,
  });

  /// Source and input content hash, attached by the application decoder.
  final String? fingerprint;
  final ImportSourceApp source;
  final List<ImportedProject> projects;
  final List<ImportedItem> items;
  final Map<ImportWarning, int> warnings;
}

/// Accumulates a plan while a parser walks its input. Projects with the same
/// name inside one file merge (first spelling wins); warnings are counted.
final class ImportPlanBuilder {
  final _projects = <String, ImportedProject>{};
  final _items = <ImportedItem>[];
  final _warnings = <ImportWarning, int>{};

  void warn(ImportWarning warning, [int count = 1]) {
    if (count <= 0) return;
    _warnings.update(warning, (n) => n + count, ifAbsent: () => count);
  }

  /// Registers a Project and returns the canonical title items must use.
  String project(
    String title, {
    String? outcome,
    ProjectStatus status = ProjectStatus.active,
    String? area,
    DateTime? dueAt,
  }) {
    final key = normalizeName(title);
    final existing = _projects[key];
    if (existing == null) {
      _projects[key] = ImportedProject(
        title: title.trim(),
        outcome: _blankToNull(outcome),
        status: status,
        area: _blankToNull(area),
        dueAt: dueAt,
      );
      return title.trim();
    }
    if (existing.outcome == null && _blankToNull(outcome) != null) {
      _projects[key] = ImportedProject(
        title: existing.title,
        outcome: outcome!.trim(),
        status: existing.status,
        area: existing.area,
        dueAt: existing.dueAt,
      );
    }
    return existing.title;
  }

  void add(ImportedItem item) => _items.add(item);

  bool get hasItems => _items.isNotEmpty;

  ImportPlan build(ImportSourceApp source) => ImportPlan(
    source: source,
    projects: List.unmodifiable(_projects.values),
    items: List.unmodifiable(_items),
    warnings: Map.unmodifiable(_warnings),
  );
}

/// Joins non-empty note parts with blank lines; null when nothing remains.
String? joinNotes(Iterable<String?> parts) {
  final kept = [
    for (final p in parts)
      if (p != null && p.trim().isNotEmpty) p.trim(),
  ];
  return kept.isEmpty ? null : kept.join('\n\n');
}

String? _blankToNull(String? s) =>
    (s == null || s.trim().isEmpty) ? null : s.trim();

/// Case-insensitive, whitespace-collapsed key for merging names.
String normalizeName(String name) =>
    name.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();

/// Context key: [normalizeName] without leading `@` signs.
String normalizeContextName(String name) =>
    normalizeName(name).replaceFirst(RegExp(r'^@+\s*'), '');

/// The GTD list a source list or project name stands for, or null for an
/// ordinary Project. Covers the default Inbox name in each app language.
ItemStatus? specialListStatus(String name) {
  final key = normalizeName(name).replaceAll(RegExp(r'[\s/&+\-_.]'), '');
  return switch (key) {
    'inbox' ||
    'eingang' ||
    'posteingang' ||
    'bandejadeentrada' ||
    'entrada' ||
    'boîtederéception' ||
    'caixadeentrada' ||
    'входящие' ||
    '收集箱' ||
    '收件箱' ||
    'インボックス' ||
    '受信箱' ||
    '수신함' ||
    '받은편지함' => ItemStatus.inbox,
    'someday' ||
    'maybe' ||
    'somedaymaybe' ||
    'somedaymaybes' => ItemStatus.someday,
    'waiting' || 'waitingfor' || 'waitingon' => ItemStatus.waiting,
    _ => null,
  };
}
