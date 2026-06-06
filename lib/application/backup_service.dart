import 'dart:convert';
import 'dart:io';
import 'dart:ui' show Rect;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data/providers.dart';
import '../core/clock.dart';
import '../data/repositories/area_repository.dart';
import '../data/repositories/context_repository.dart';
import '../data/repositories/item_repository.dart';
import '../data/repositories/project_repository.dart';
import '../domain/entities/entities.dart';

class BackupService {
  BackupService({
    required this.items,
    required this.projects,
    required this.contexts,
    required this.areas,
    required this.clock,
  });
  final ItemRepository items;
  final ProjectRepository projects;
  final ContextRepository contexts;
  final AreaRepository areas;
  final Clock clock;

  // v1: items, projects, contexts.
  // v2: + areas, + recurrence on items.
  // v3: + recurrence end conditions (until / count / doneCount).
  // v4: + structured recurrence (byWeekdays / monthlyWeek / monthlyWeekday).
  static const int formatVersion = 4;

  Future<Map<String, Object?>> export() async {
    final allItems = await items.allActive();
    final allProjects = <Project>[];
    // We don't have allProjects directly — read via stream's first emission
    // would be flaky; query through DB by listing all statuses.
    for (final s in ProjectStatus.values) {
      final list = await projects.watchByStatus(s).first;
      allProjects.addAll(list);
    }
    final allContexts = await contexts.all();
    final allAreas = await areas.watchAll().first;
    return {
      'version': formatVersion,
      'exportedAt': clock.now().toIso8601String(),
      'contexts': allContexts.map(_contextToJson).toList(),
      'areas': allAreas.map(_areaToJson).toList(),
      'projects': allProjects.map(_projectToJson).toList(),
      'items': allItems.map(_itemToJson).toList(),
    };
  }

  Future<File> exportToFile() async {
    final json = const JsonEncoder.withIndent('  ').convert(await export());
    final dir = await getTemporaryDirectory();
    final stamp =
        clock.now().toIso8601String().replaceAll(':', '-').split('.').first;
    final file = File(p.join(dir.path, 'cleartray-backup-$stamp.json'));
    await file.writeAsString(json);
    return file;
  }

  Future<void> shareBackup({Rect? sharePositionOrigin}) async {
    final file = await exportToFile();
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Trayzero backup',
      // Required by share_plus on iPad and, since iOS 26, on iPhone too:
      // UIActivityViewController now always has a popover controller, so a
      // non-empty origin within the root view must be supplied or the native
      // side throws PlatformException. The UI passes the tapped tile's rect.
      sharePositionOrigin: sharePositionOrigin,
    );
  }

  /// Restore from a previously-exported JSON map. Existing rows with the
  /// same id are upserted.
  Future<int> import(Map<String, Object?> raw) async {
    final fallback = clock.now();
    final ctxs = (raw['contexts'] as List? ?? [])
        .cast<Map<String, Object?>>()
        .map(_contextFromJson)
        .toList();
    final ars = (raw['areas'] as List? ?? [])
        .cast<Map<String, Object?>>()
        .map(_areaFromJson)
        .toList();
    final projs = (raw['projects'] as List? ?? [])
        .cast<Map<String, Object?>>()
        .map((m) => _projectFromJson(m, fallback))
        .toList();
    final itms = (raw['items'] as List? ?? [])
        .cast<Map<String, Object?>>()
        .map((m) => _itemFromJson(m, fallback))
        .toList();
    // Batched: a large import (thousands of Google tasks) one row at a
    // time is unacceptably slow. Order preserved so FKs resolve.
    await contexts.upsertAll(ctxs);
    await areas.upsertAll(ars);
    await projects.upsertAll(projs);
    await items.upsertAll(itms);
    return ctxs.length + ars.length + projs.length + itms.length;
  }
}

final backupServiceProvider = Provider<BackupService>((ref) => BackupService(
      items: ref.watch(itemRepositoryProvider),
      projects: ref.watch(projectRepositoryProvider),
      contexts: ref.watch(contextRepositoryProvider),
      areas: ref.watch(areaRepositoryProvider),
      clock: ref.watch(clockProvider),
    ));

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
      recurrenceByWeekdays: (m['recurrenceByWeekdays'] as List?)
              ?.map((e) => e as int)
              .toList() ??
          const [],
      recurrenceMonthlyWeek: m['recurrenceMonthlyWeek'] as int?,
      recurrenceMonthlyWeekday: m['recurrenceMonthlyWeekday'] as int?,
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
    };

Project _projectFromJson(Map<String, Object?> m, DateTime fallback) => Project(
      id: m['id']! as String,
      title: m['title']! as String,
      outcome: m['outcome'] as String?,
      areaId: m['areaId'] as String?,
      status: ProjectStatus.values
          .byName((m['status'] as String?) ?? 'active'),
      dueAt: _parseDate(m['dueAt']),
      createdAt: _parseDate(m['createdAt']) ?? fallback,
      updatedAt: _parseDate(m['updatedAt']) ?? fallback,
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

DateTime? _parseDate(Object? v) {
  if (v is! String) return null;
  return DateTime.tryParse(v);
}
