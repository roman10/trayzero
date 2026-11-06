import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' show Rect;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/backup_files.dart';
import '../core/clock.dart';
import '../data/db/database.dart';
import '../data/providers.dart';
import '../data/repositories/area_repository.dart';
import '../data/repositories/attachment_repository.dart';
import '../data/repositories/context_repository.dart';
import '../data/repositories/item_repository.dart';
import '../data/repositories/project_repository.dart';
import '../data/repositories/review_repository.dart';
import '../data/repositories/tag_repository.dart';
import '../domain/entities/entities.dart';
import '../domain/tags.dart';

/// A portable JSON snapshot of user content. Native calendar ownership and
/// device preferences deliberately stay on the device that owns them.
class BackupService {
  BackupService({
    required this.database,
    required this.items,
    required this.projects,
    required this.contexts,
    required this.areas,
    required this.attachments,
    required this.reviews,
    required this.tags,
    required this.files,
    required this.clock,
  });
  final AppDatabase database;
  final ItemRepository items;
  final ProjectRepository projects;
  final ContextRepository contexts;
  final AreaRepository areas;
  final AttachmentRepository attachments;
  final ReviewRepository reviews;
  final TagRepository tags;
  final BackupFiles files;
  final Clock clock;
  Future<void> _importTail = Future.value();

  // v1–v4: tasks, projects, contexts, areas and recurrence.
  // v5: + attachment metadata/bytes and Review history.
  // v6: + current step of incomplete Weekly Reviews.
  // v7: + Item Today focus and Project last-reviewed time (ADR 0007).
  // v8: + tags and each Item's tag ids (ADR 0010).
  static const int formatVersion = 8;

  Future<Map<String, Object?>> export() async {
    late List<Item> allItems;
    late List<Attachment> allAttachments;
    late List<ReviewLog> allReviews;
    late List<GtdContext> allContexts;
    late List<Area> allAreas;
    late List<Tag> allTags;
    late Map<String, List<String>> itemTagIds;
    final allProjects = <Project>[];
    await database.transaction(() async {
      allItems = await items.allRestorable();
      for (final s in ProjectStatus.values) {
        allProjects.addAll(await projects.watchByStatus(s).first);
      }
      allContexts = await contexts.all();
      allAreas = await areas.watchAll().first;
      allAttachments = await attachments.allForItems(allItems.map((i) => i.id));
      allReviews = await reviews.all();
      allTags = await tags.all();
      itemTagIds = await tags.allItemTagIds();
    });
    final media = <Map<String, Object?>>[];
    for (final a in allAttachments) {
      // Missing files fail the export instead of silently producing an
      // apparently complete backup that cannot restore its attachments.
      final bytes = await files.readAttachment(a.path);
      media.add({
        'id': a.id,
        'itemId': a.itemId,
        'kind': a.kind.name,
        'name': a.name,
        'sizeBytes': bytes.length,
        'createdAt': a.createdAt.toIso8601String(),
        'extension':
            RegExp(r'\.[a-zA-Z0-9]{1,10}$').firstMatch(a.path)?.group(0) ?? '',
        'data': base64Encode(bytes),
      });
    }
    return {
      'version': formatVersion,
      'exportedAt': clock.now().toIso8601String(),
      'contexts': allContexts.map(_contextToJson).toList(),
      'areas': allAreas.map(_areaToJson).toList(),
      'projects': allProjects.map(_projectToJson).toList(),
      'tags': allTags.map(_tagToJson).toList(),
      'items': [
        for (final i in allItems)
          {..._itemToJson(i), 'tagIds': itemTagIds[i.id] ?? const <String>[]},
      ],
      'attachments': media,
      'reviews': allReviews.map(_reviewToJson).toList(),
    };
  }

  Future<File> exportToFile() async {
    final json = const JsonEncoder.withIndent('  ').convert(await export());
    final stamp = clock
        .now()
        .toIso8601String()
        .replaceAll(':', '-')
        .split('.')
        .first;
    return files.writeBackup('trayzero-backup-$stamp.json', json);
  }

  Future<void> shareBackup({Rect? sharePositionOrigin}) async {
    await files.shareBackup(
      await exportToFile(),
      sharePositionOrigin: sharePositionOrigin,
    );
  }

  /// Validate every row and every embedded file before the confirmation UI
  /// or restore changes anything. Versions 1–4 can omit the new sections.
  void validate(Map<String, Object?> raw) {
    _decode(raw);
  }

  Future<int> import(Map<String, Object?> raw) async {
    final previous = _importTail;
    final done = Completer<void>();
    _importTail = done.future;
    try {
      await previous;
      return await _restore(_decode(raw));
    } finally {
      done.complete();
    }
  }

  Future<int> _restore(_BackupSnapshot snapshot) async {
    final staged = <Attachment>[];
    final oldFiles = <String>[];
    try {
      for (final a in snapshot.attachments) {
        final path = await files.writeAttachment(
          a.bytes,
          extension: a.extension,
        );
        staged.add(a.attachmentAt(path));
      }
      await database.transaction(() async {
        for (final a in staged) {
          final old = await attachments.getById(a.id);
          if (old != null) oldFiles.add(old.path);
        }
        await contexts.upsertAll(snapshot.contexts);
        await areas.upsertAll(snapshot.areas);
        await projects.upsertAll(snapshot.projects);
        final plan = planTagRestore(snapshot.tags, await tags.all());
        await tags.upsertAll(plan.upserts, createdAt: clock.now());
        // An in-place restore keeps this device's native event association;
        // portable backups never import another device's calendar ids.
        final restoredItems = <Item>[];
        for (final i in snapshot.items) {
          final existing = await items.getById(i.id);
          restoredItems.add(
            i.copyWith(calendarEventId: existing?.calendarEventId),
          );
        }
        await items.upsertAll(restoredItems);
        // v8+ Items carry their exact tag set; older backups leave tags as
        // they are.
        await tags.replaceItemTags({
          for (final MapEntry(key: itemId, value: ids)
              in snapshot.itemTagIds.entries)
            itemId: ids.map((id) => plan.idMap[id]!),
        });
        await attachments.upsertAll(staged);
        await reviews.upsertAll(snapshot.reviews);
      });
    } catch (_) {
      for (final a in staged) {
        await _discard(a.path);
      }
      rethrow;
    }
    // Old files are retired only after the new rows and files are committed.
    for (final path in oldFiles) {
      await _discard(path);
    }
    return snapshot.contexts.length +
        snapshot.areas.length +
        snapshot.projects.length +
        snapshot.tags.length +
        snapshot.items.length +
        staged.length +
        snapshot.reviews.length;
  }

  Future<void> _discard(String path) async {
    try {
      await files.deleteAttachment(path);
    } catch (_) {
      // Best-effort retirement of an unreferenced file must not turn a
      // successfully committed restore into an apparent failed import.
    }
  }

  _BackupSnapshot _decode(Map<String, Object?> raw) {
    final version = raw['version'];
    if (version != null &&
        (version is! int || version < 1 || version > formatVersion)) {
      throw const FormatException('Unsupported backup format version');
    }
    final now = clock.now();
    final itms = _rows(raw, 'items').map((m) => _itemFromJson(m, now)).toList();
    final media = _rows(
      raw,
      'attachments',
    ).map((m) => _AttachmentBackup.fromJson(m, now)).toList();
    final itemIds = itms.map((i) => i.id).toSet();
    if (media.any((a) => !itemIds.contains(a.itemId))) {
      throw const FormatException('An attachment has no Item in this backup');
    }
    final tagRows = _rows(raw, 'tags').map(_tagFromJson).toList();
    final tagIds = tagRows.map((t) => t.id).toSet();
    final itemTagIds = <String, List<String>>{};
    for (final m in _rows(raw, 'items')) {
      final ids = m['tagIds'];
      if (ids == null) continue;
      if (ids is! List ||
          ids.any((id) => id is! String || !tagIds.contains(id))) {
        throw const FormatException('An Item has a tag not in this backup');
      }
      itemTagIds[m['id']! as String] = ids.cast<String>();
    }
    return _BackupSnapshot(
      items: itms,
      tags: tagRows,
      itemTagIds: itemTagIds,
      contexts: _rows(raw, 'contexts').map(_contextFromJson).toList(),
      areas: _rows(raw, 'areas').map(_areaFromJson).toList(),
      projects: _rows(
        raw,
        'projects',
      ).map((m) => _projectFromJson(m, now)).toList(),
      attachments: media,
      reviews: _rows(
        raw,
        'reviews',
      ).map((m) => _reviewFromJson(m, now)).toList(),
    );
  }
}

final backupServiceProvider = Provider<BackupService>(
  (ref) => BackupService(
    database: ref.watch(databaseProvider),
    items: ref.watch(itemRepositoryProvider),
    projects: ref.watch(projectRepositoryProvider),
    contexts: ref.watch(contextRepositoryProvider),
    areas: ref.watch(areaRepositoryProvider),
    attachments: ref.watch(attachmentRepositoryProvider),
    reviews: ref.watch(reviewRepositoryProvider),
    tags: ref.watch(tagRepositoryProvider),
    files: ref.watch(backupFilesProvider),
    clock: ref.watch(clockProvider),
  ),
);

class _BackupSnapshot {
  const _BackupSnapshot({
    required this.items,
    required this.contexts,
    required this.areas,
    required this.projects,
    required this.attachments,
    required this.reviews,
    required this.tags,
    required this.itemTagIds,
  });
  final List<Item> items;
  final List<GtdContext> contexts;
  final List<Area> areas;
  final List<Project> projects;
  final List<_AttachmentBackup> attachments;
  final List<ReviewLog> reviews;
  final List<Tag> tags;

  /// Item id → tag ids, only for Items whose backup row lists them (v8+).
  final Map<String, List<String>> itemTagIds;
}

List<Map<String, Object?>> _rows(Map<String, Object?> raw, String key) {
  final value = raw[key];
  if (value == null) return [];
  if (value is! List) throw FormatException('Invalid $key section');
  final ids = <String>{};
  return value.map((row) {
    if (row is! Map<String, Object?> ||
        row['id'] is! String ||
        (row['id']! as String).isEmpty ||
        !ids.add(row['id']! as String)) {
      throw FormatException('Invalid or duplicate $key entry');
    }
    return row;
  }).toList();
}

class _AttachmentBackup {
  _AttachmentBackup.fromJson(Map<String, Object?> m, DateTime fallback)
    : id = m['id']! as String,
      itemId = m['itemId']! as String,
      kind = AttachmentKind.values.byName(m['kind']! as String),
      name = m['name'] as String?,
      createdAt = _parseDate(m['createdAt']) ?? fallback,
      extension = (m['extension'] as String?) ?? '',
      bytes = base64Decode(m['data']! as String) {
    if (extension.isNotEmpty &&
        !RegExp(r'^\.[a-zA-Z0-9]{1,10}$').hasMatch(extension)) {
      throw const FormatException('Invalid attachment extension');
    }
    if (m['sizeBytes'] != null && m['sizeBytes'] != bytes.length) {
      throw const FormatException(
        'Attachment bytes do not match the stored size',
      );
    }
  }
  final String id, itemId, extension;
  final String? name;
  final AttachmentKind kind;
  final DateTime createdAt;
  final List<int> bytes;
  Attachment attachmentAt(String path) => Attachment(
    id: id,
    itemId: itemId,
    kind: kind,
    path: path,
    name: name,
    sizeBytes: bytes.length,
    createdAt: createdAt,
  );
}

Map<String, Object?> _reviewToJson(ReviewLog r) => {
  'id': r.id,
  'type': r.type.name,
  'startedAt': r.startedAt.toIso8601String(),
  'completedAt': r.completedAt?.toIso8601String(),
  'notes': r.notes,
  'currentStep': r.currentStep.name,
};
ReviewLog _reviewFromJson(Map<String, Object?> m, DateTime fallback) =>
    ReviewLog(
      id: m['id']! as String,
      type: ReviewType.values.byName(m['type']! as String),
      startedAt: _parseDate(m['startedAt']) ?? fallback,
      completedAt: _parseDate(m['completedAt']),
      notes: m['notes'] as String?,
      currentStep: m['currentStep'] == null
          ? WeeklyReviewStep.capture
          : WeeklyReviewStep.values.byName(m['currentStep'] as String),
    );

// ---------- JSON helpers ----------

Map<String, Object?> _itemToJson(Item i) => {
  'id': i.id,
  'title': i.title,
  'notes': i.notes,
  'status': i.status.name,
  'projectId': i.projectId,
  'contextId': i.contextId,
  'dueAt': i.dueAt?.toIso8601String(),
  'deferUntil': i.deferUntil?.toIso8601String(),
  'waitingOn': i.waitingOn,
  'energy': i.energy?.name,
  'timeEstimateMinutes': i.timeEstimateMinutes,
  'isTwoMin': i.isTwoMin,
  'createdAt': i.createdAt.toIso8601String(),
  'updatedAt': i.updatedAt.toIso8601String(),
  'completedAt': i.completedAt?.toIso8601String(),
  'previousStatus': i.previousStatus?.name,
  'sortOrder': i.sortOrder,
  'projectSortOrder': i.projectSortOrder,
  'recurrence': i.recurrence?.name,
  'recurrenceInterval': i.recurrenceInterval,
  'recurrenceUntil': i.recurrenceUntil?.toIso8601String(),
  'recurrenceCount': i.recurrenceCount,
  'recurrenceDoneCount': i.recurrenceDoneCount,
  'recurrenceByWeekdays': i.recurrenceByWeekdays,
  'recurrenceMonthlyWeek': i.recurrenceMonthlyWeek,
  'recurrenceMonthlyWeekday': i.recurrenceMonthlyWeekday,
  'focusedAt': i.focusedAt?.toIso8601String(),
};

Item _itemFromJson(Map<String, Object?> m, DateTime fallback) => Item(
  id: m['id']! as String,
  title: m['title']! as String,
  notes: m['notes'] as String?,
  status: ItemStatus.values.byName((m['status'] as String?) ?? 'inbox'),
  projectId: m['projectId'] as String?,
  contextId: m['contextId'] as String?,
  dueAt: _parseDate(m['dueAt']),
  deferUntil: _parseDate(m['deferUntil']),
  waitingOn: m['waitingOn'] as String?,
  energy: m['energy'] == null
      ? null
      : Energy.values.byName(m['energy']! as String),
  timeEstimateMinutes: m['timeEstimateMinutes'] as int?,
  isTwoMin: (m['isTwoMin'] as bool?) ?? false,
  createdAt: _parseDate(m['createdAt']) ?? fallback,
  updatedAt: _parseDate(m['updatedAt']) ?? fallback,
  completedAt: _parseDate(m['completedAt']),
  previousStatus: m['previousStatus'] == null
      ? null
      : ItemStatus.values.byName(m['previousStatus']! as String),
  sortOrder: (m['sortOrder'] as int?) ?? 0,
  projectSortOrder: (m['projectSortOrder'] as int?) ?? 0,
  recurrence: m['recurrence'] == null
      ? null
      : Recurrence.values.byName(m['recurrence']! as String),
  recurrenceInterval: (m['recurrenceInterval'] as int?) ?? 1,
  // v3+ fields; pre-v3 backups omit them → indefinite recurrence.
  recurrenceUntil: _parseDate(m['recurrenceUntil']),
  recurrenceCount: m['recurrenceCount'] as int?,
  recurrenceDoneCount: (m['recurrenceDoneCount'] as int?) ?? 0,
  // v4+ structured qualifiers; absent in older backups.
  recurrenceByWeekdays:
      (m['recurrenceByWeekdays'] as List?)?.map((e) => e as int).toList() ??
      const [],
  recurrenceMonthlyWeek: m['recurrenceMonthlyWeek'] as int?,
  recurrenceMonthlyWeekday: m['recurrenceMonthlyWeekday'] as int?,
  // v7+; older backups restore without Today focus.
  focusedAt: _parseDate(m['focusedAt']),
);

Map<String, Object?> _areaToJson(Area a) => {'id': a.id, 'name': a.name};

Area _areaFromJson(Map<String, Object?> m) =>
    Area(id: m['id']! as String, name: m['name']! as String);

Map<String, Object?> _projectToJson(Project p) => {
  'id': p.id,
  'title': p.title,
  'outcome': p.outcome,
  'areaId': p.areaId,
  'status': p.status.name,
  'dueAt': p.dueAt?.toIso8601String(),
  'createdAt': p.createdAt.toIso8601String(),
  'updatedAt': p.updatedAt.toIso8601String(),
  'lastReviewedAt': p.lastReviewedAt?.toIso8601String(),
};

Project _projectFromJson(Map<String, Object?> m, DateTime fallback) => Project(
  id: m['id']! as String,
  title: m['title']! as String,
  outcome: m['outcome'] as String?,
  areaId: m['areaId'] as String?,
  status: ProjectStatus.values.byName((m['status'] as String?) ?? 'active'),
  dueAt: _parseDate(m['dueAt']),
  createdAt: _parseDate(m['createdAt']) ?? fallback,
  updatedAt: _parseDate(m['updatedAt']) ?? fallback,
  // v7+; older backups restore as never reviewed.
  lastReviewedAt: _parseDate(m['lastReviewedAt']),
);

Map<String, Object?> _contextToJson(GtdContext c) => {
  'id': c.id,
  'name': c.name,
  'icon': c.icon,
  'color': c.color,
  'sortOrder': c.sortOrder,
};

GtdContext _contextFromJson(Map<String, Object?> m) => GtdContext(
  id: m['id']! as String,
  name: m['name']! as String,
  icon: (m['icon'] as String?) ?? 'label',
  color: (m['color'] as int?) ?? 0xFF6750A4,
  sortOrder: (m['sortOrder'] as int?) ?? 0,
);

Map<String, Object?> _tagToJson(Tag t) => {
  'id': t.id,
  'name': t.name,
  'isPerson': t.isPerson,
};

Tag _tagFromJson(Map<String, Object?> m) {
  final name = cleanTagName(m['name']! as String);
  if (name == null) throw const FormatException('Invalid tag name');
  return Tag(
    id: m['id']! as String,
    name: name,
    isPerson: (m['isPerson'] as bool?) ?? false,
  );
}

DateTime? _parseDate(Object? v) {
  if (v == null) return null;
  final parsed = v is String ? DateTime.tryParse(v) : null;
  if (parsed == null) throw const FormatException('Invalid backup date');
  return parsed;
}
