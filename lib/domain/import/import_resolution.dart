import '../entities/entities.dart';
import '../item_invariants.dart';
import '../tags.dart';
import 'import_plan.dart';
import 'import_values.dart';

/// Turns an [ImportPlan] into the rows to write, against the user's
/// existing Contexts and Projects (ADR 0008). Pure: the use case runs it for
/// the preview and again inside the write transaction, so names created in
/// between still merge.
///
/// - Contexts and Projects merge by name, case-insensitively (a leading `@`
///   is ignored for Contexts); nothing is duplicated.
/// - A tag shaped `agenda: Name` (ADR 0010) becomes a person tag "Name".
/// - Otherwise a tag becomes the Item's Context when the source wrote it as
///   `@name`, when it matches an existing Context, or when it is a common
///   context word. Only the first such tag is used.
/// - Every other tag becomes a tag (without a leading `@`), merged with
///   existing tags by name, ignoring case.
/// - An open action with a due date becomes a Calendar Item, because a Next
///   Action cannot hold one (GTD Option A).
/// - A date-only due date lands at [dueMinutesOfDay], as quick capture does.
ResolvedImport resolveImport(
  ImportPlan plan, {
  required List<GtdContext> existingContexts,
  required List<Project> existingProjects,
  List<Tag> existingTags = const [],
  List<Area> existingAreas = const [],
  required String Function() newId,
  required DateTime now,
  int dueMinutesOfDay = 540,
}) {
  final warnings = Map<ImportWarning, int>.of(plan.warnings);
  void warn(ImportWarning w) =>
      warnings.update(w, (n) => n + 1, ifAbsent: () => 1);

  final contextsByKey = {
    for (final c in existingContexts) normalizeContextName(c.name): c,
  };
  final existingContextKeys = contextsByKey.keys.toSet();
  final newContexts = <GtdContext>[];
  var nextSort =
      existingContexts.fold(-1, (m, c) => c.sortOrder > m ? c.sortOrder : m) +
      1;

  final areasByKey = {for (final a in existingAreas) normalizeName(a.name): a};
  final newAreas = <Area>[];
  String? areaIdFor(String? name) {
    if (name == null || name.trim().isEmpty) return null;
    return areasByKey.putIfAbsent(normalizeName(name), () {
      final area = Area(id: newId(), name: name.trim());
      newAreas.add(area);
      return area;
    }).id;
  }

  final projectsByKey = {
    for (final p in existingProjects) normalizeName(p.title): p,
  };
  final newProjects = <Project>[];
  for (final p in plan.projects) {
    final key = normalizeName(p.title);
    if (projectsByKey.containsKey(key)) continue;
    final created = Project(
      id: newId(),
      title: p.title,
      outcome: p.outcome,
      areaId: areaIdFor(p.area),
      dueAt: p.dueAt,
      status: p.status,
      createdAt: now,
      updatedAt: now,
    );
    projectsByKey[key] = created;
    newProjects.add(created);
  }

  final tagsByKey = {for (final t in existingTags) tagKey(t.name): t};
  final newTags = <Tag>[];
  String? tagIdFor(String raw, {bool isPerson = false}) {
    final name = cleanTagName(raw);
    if (name == null) return null;
    return tagsByKey.putIfAbsent(tagKey(name), () {
      final tag = Tag(id: newId(), name: name, isPerson: isPerson);
      newTags.add(tag);
      return tag;
    }).id;
  }

  final items = <Item>[];
  final itemTagIds = <String, List<String>>{};
  final projectOrder = <String, int>{};
  for (final (index, src) in plan.items.indexed) {
    final notes = <String?>[src.notes];
    String? contextId;
    final tagIds = <String>{};
    for (final tag in src.tags) {
      final key = normalizeContextName(tag);
      if (key.isEmpty) continue;
      final person = agendaPersonName(tag);
      if (person != null) {
        final id = tagIdFor(person, isPerson: true);
        if (id != null) tagIds.add(id);
        continue;
      }
      final isContext =
          tag.startsWith('@') ||
          existingContextKeys.contains(key) ||
          commonContextWords.contains(key);
      if (contextId != null || !isContext) {
        final id = tagIdFor(tag);
        if (id != null) tagIds.add(id);
        continue;
      }
      var ctx = contextsByKey[key];
      if (ctx == null) {
        ctx = GtdContext(
          id: newId(),
          name: '@${tag.replaceFirst(RegExp(r'^@+\s*'), '').trim()}',
          icon: 'label',
          color: 0xFF546E7A,
          sortOrder: nextSort++,
        );
        contextsByKey[key] = ctx;
        newContexts.add(ctx);
      }
      contextId = ctx.id;
    }

    var status = src.status;
    if (status == ItemStatus.nextAction && src.dueAt != null) {
      status = ItemStatus.calendar;
      warn(ImportWarning.datedToCalendar);
    }
    final due = src.dueAt;
    final dueAt = due != null && (src.dueIsDateOnly ?? isDateOnly(due))
        ? DateTime(
            due.year,
            due.month,
            due.day,
            dueMinutesOfDay ~/ 60,
            dueMinutesOfDay % 60,
          )
        : due;
    final projectId = src.project == null
        ? null
        : projectsByKey[normalizeName(src.project!)]?.id;
    final repeat = (dueAt ?? src.deferUntil) == null ? null : src.repeat;
    // Later rows sort below earlier ones in lists ordered newest first.
    final created = now.subtract(Duration(milliseconds: index));
    final id = newId();
    if (tagIds.isNotEmpty) itemTagIds[id] = tagIds.toList();
    items.add(
      enforceItemInvariants(
        Item(
          id: id,
          title: src.title,
          notes: joinNotes(notes),
          status: status,
          projectId: projectId,
          contextId: contextId,
          dueAt: dueAt,
          deferUntil: src.deferUntil,
          waitingOn: src.waitingOn,
          energy: src.energy,
          timeEstimateMinutes: src.timeEstimateMinutes,
          createdAt: src.createdAt ?? created,
          updatedAt: src.updatedAt ?? src.createdAt ?? created,
          completedAt: src.completedAt,
          projectSortOrder: projectId == null
              ? 0
              : projectOrder.update(projectId, (n) => n + 1, ifAbsent: () => 0),
          recurrence: repeat?.frequency,
          recurrenceInterval: repeat?.interval ?? 1,
          recurrenceByWeekdays: repeat?.byWeekdays ?? const [],
          recurrenceMonthlyWeek: repeat?.monthlyWeek,
          recurrenceMonthlyWeekday: repeat?.monthlyWeekday,
          recurrenceUntil: repeat?.until,
          recurrenceCount: repeat?.count,
        ),
      ),
    );
  }

  final usedProjectIds = {for (final i in items) ?i.projectId};
  final usedContextIds = {for (final i in items) ?i.contextId};
  final usedTagIds = {for (final ids in itemTagIds.values) ...ids};
  return ResolvedImport(
    items: items,
    itemTagIds: itemTagIds,
    newAreas: newAreas,
    existingAreasUsed: [
      for (final a in existingAreas)
        if (newProjects.any((p) => p.areaId == a.id)) a,
    ],
    newProjects: newProjects,
    newContexts: newContexts,
    newTags: newTags,
    existingTagsUsed: sortTags(
      existingTags.where((t) => usedTagIds.contains(t.id)),
    ),
    mergedProjects: [
      for (final p in existingProjects)
        if (usedProjectIds.contains(p.id)) p,
    ],
    existingContextsUsed: [
      for (final c in existingContexts)
        if (usedContextIds.contains(c.id)) c,
    ],
    warnings: Map.unmodifiable(warnings),
  );
}

/// English context words recognized without an `@` (ADR 0008).
const commonContextWords = {
  'phone',
  'calls',
  'computer',
  'email',
  'errands',
  'home',
  'office',
  'online',
  'agenda',
  'anywhere',
};

/// The person named by an agenda tag such as `agenda: Alice`,
/// `Agendas/Alice`, or `@agenda-alice` (ADR 0010), else null. OmniFocus
/// writes nested tags as `Agendas : Alice`.
String? agendaPersonName(String tag) {
  final m = _agendaTag.firstMatch(tag.trim());
  return m == null ? null : cleanTagName(m.group(1)!);
}

final _agendaTag = RegExp(
  r'^@*\s*agendas?\s*[:/\-_.]\s*(.+)$',
  caseSensitive: false,
);

final class ResolvedImport {
  const ResolvedImport({
    required this.items,
    this.itemTagIds = const {},
    this.newAreas = const [],
    this.existingAreasUsed = const [],
    required this.newProjects,
    required this.newContexts,
    this.newTags = const [],
    this.existingTagsUsed = const [],
    required this.mergedProjects,
    required this.existingContextsUsed,
    required this.warnings,
  });

  final List<Item> items;
  final List<Area> newAreas;
  final List<Area> existingAreasUsed;

  /// Item id → tag ids for imported Items that carry tags.
  final Map<String, List<String>> itemTagIds;
  final List<Project> newProjects;
  final List<GtdContext> newContexts;

  /// Tags this import creates, and existing tags it reuses (ADR 0010).
  final List<Tag> newTags;
  final List<Tag> existingTagsUsed;

  /// Existing Projects that receive imported actions.
  final List<Project> mergedProjects;

  /// Existing Contexts assigned to imported Items.
  final List<GtdContext> existingContextsUsed;
  final Map<ImportWarning, int> warnings;

  ImportPreview get preview {
    final byStatus = <ItemStatus, int>{};
    final perProject = <String, int>{};
    for (final i in items) {
      byStatus.update(i.status, (n) => n + 1, ifAbsent: () => 1);
      if (i.projectId != null) {
        perProject.update(i.projectId!, (n) => n + 1, ifAbsent: () => 1);
      }
    }
    return ImportPreview(
      total: items.length,
      newAreas: [for (final a in newAreas) a.name],
      existingAreas: [for (final a in existingAreasUsed) a.name],
      byStatus: byStatus,
      projects: [
        for (final p in newProjects)
          (title: p.title, actions: perProject[p.id] ?? 0, isNew: true),
        for (final p in mergedProjects)
          (title: p.title, actions: perProject[p.id] ?? 0, isNew: false),
      ],
      newContexts: [for (final c in newContexts) c.name],
      existingContexts: [for (final c in existingContextsUsed) c.name],
      newTags: [for (final t in sortTags(newTags)) t.name],
      existingTags: [for (final t in existingTagsUsed) t.name],
      warnings: warnings,
    );
  }
}

/// What the preview screen shows before anything is written.
final class ImportPreview {
  const ImportPreview({
    required this.total,
    this.newAreas = const [],
    this.existingAreas = const [],
    required this.byStatus,
    required this.projects,
    required this.newContexts,
    required this.existingContexts,
    this.newTags = const [],
    this.existingTags = const [],
    required this.warnings,
  });

  final int total;
  final List<String> newAreas;
  final List<String> existingAreas;
  final Map<ItemStatus, int> byStatus;
  final List<({String title, int actions, bool isNew})> projects;
  final List<String> newContexts;
  final List<String> existingContexts;
  final List<String> newTags;
  final List<String> existingTags;
  final Map<ImportWarning, int> warnings;
}
