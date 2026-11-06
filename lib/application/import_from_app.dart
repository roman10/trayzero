import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';

import '../core/clock.dart';
import '../core/id_generator.dart';
import '../core/things_snapshot_reader.dart';
import '../data/repositories/area_repository.dart';
import '../domain/import/things_parser.dart';
import '../data/db/database.dart';
import '../data/repositories/context_repository.dart';
import '../data/repositories/item_repository.dart';
import '../data/repositories/import_history_repository.dart';
import '../data/repositories/project_repository.dart';
import '../data/repositories/tag_repository.dart';
import '../domain/entities/entities.dart';
import '../domain/import/import_plan.dart';
import '../domain/import/google_tasks_parser.dart';
import '../domain/import/import_resolution.dart';
import '../domain/import/nirvana_parser.dart';
import '../domain/import/taskpaper_parser.dart';
import '../domain/import/ticktick_parser.dart';
import '../domain/import/todoist_parser.dart';
import 'batch_delete_items.dart';

/// What one import created, so it can be undone exactly (ADR 0008).
final class ImportReceipt {
  const ImportReceipt({
    required this.itemIds,
    required this.projectIds,
    required this.contextIds,
    this.tagIds = const [],
    this.areaIds = const [],
    this.remindersFailed = false,
    this.batchId,
  });

  final List<String> itemIds;
  final String? batchId;

  /// Projects and Contexts this import created (not merged ones).
  final List<String> projectIds;
  final List<String> contextIds;

  /// Tags this import created (ADR 0010).
  final List<String> tagIds;
  final List<String> areaIds;

  /// Rows are committed but some reminders could not be scheduled; the
  /// launch re-arm will retry them.
  final bool remindersFailed;
}

/// Imports another app's export: decode → parse (pure, `domain/import/`) →
/// preview → one-transaction write → optional Undo (ADR 0008).
final class ImportFromApp {
  ImportFromApp({
    required AppDatabase database,
    ThingsSnapshotReader? thingsReader,
    required ItemRepository items,
    required ProjectRepository projects,
    required ContextRepository contexts,
    required TagRepository tags,
    required IdGenerator ids,
    required Clock clock,
    required BatchDeleteItems deleteItems,
    Future<void> Function(Item item)? reconcileReminders,
    int dueMinutesOfDay = 540,
  }) : _database = database,
       _thingsReader = thingsReader,
       _areas = AreaRepository(database),
       _items = items,
       _projects = projects,
       _contexts = contexts,
       _tags = tags,
       _ids = ids,
       _clock = clock,
       _deleteItems = deleteItems,
       _reconcileReminders = reconcileReminders,
       _dueMinutesOfDay = dueMinutesOfDay;

  final AppDatabase _database;
  final ThingsSnapshotReader? _thingsReader;
  final AreaRepository _areas;
  final ItemRepository _items;
  final ProjectRepository _projects;
  final ContextRepository _contexts;
  final TagRepository _tags;
  final IdGenerator _ids;
  final Clock _clock;
  final BatchDeleteItems _deleteItems;
  final Future<void> Function(Item item)? _reconcileReminders;
  final int _dueMinutesOfDay;

  /// Upper bound on a ZIP's uncompressed CSV content; a Todoist backup is
  /// far smaller, so anything larger is treated as unreadable.
  static const maxZipBytes = 50 * 1024 * 1024;

  /// Decodes a picked file and parses it as [source]. Throws
  /// [ImportFormatException] when it is not that source's export or holds
  /// nothing to import.
  ImportPlan parseFile(
    ImportSourceApp source, {
    required String fileName,
    required List<int> bytes,
  }) {
    return _fingerprinted(
      _parseFile(source, fileName: fileName, bytes: bytes),
      // Todoist derives its project name from the filename. Other sources
      // should still warn when an identical export has been renamed.
      jsonEncode([
        source.name,
        source == ImportSourceApp.todoist && !_isZip(bytes)
            ? todoistProjectName(fileName)
            : '',
        sha256.convert(bytes).toString(),
      ]),
    );
  }

  ImportPlan _parseFile(
    ImportSourceApp source, {
    required String fileName,
    required List<int> bytes,
  }) {
    if (source == ImportSourceApp.things) {
      final reader = _thingsReader;
      if (reader == null) throw StateError('Things reader is not configured');
      return _checked(parseThings(reader.read(bytes)));
    }
    if (_isZip(bytes)) {
      if (source != ImportSourceApp.todoist) {
        throw const ImportFormatException(ImportFailure.unrecognized);
      }
      return _checked(parseTodoist(_zipCsvFiles(bytes), now: _clock.now()));
    }
    final text = decodeImportText(bytes);
    if (source == ImportSourceApp.todoist) {
      return _checked(
        parseTodoist([(name: fileName, text: text)], now: _clock.now()),
      );
    }
    return _parseText(source, text);
  }

  /// Parses pasted or decoded text as [source].
  ImportPlan parseText(ImportSourceApp source, String text) => _fingerprinted(
    _parseText(source, text),
    jsonEncode([source.name, '', sha256.convert(utf8.encode(text)).toString()]),
  );

  ImportPlan _parseText(ImportSourceApp source, String text) {
    if (text.trim().isEmpty) {
      throw const ImportFormatException(ImportFailure.noTasks);
    }
    final now = _clock.now();
    return _checked(switch (source) {
      ImportSourceApp.todoist => parseTodoist([
        (name: '', text: text),
      ], now: now),
      ImportSourceApp.appleReminders || ImportSourceApp.things =>
        throw const ImportFormatException(ImportFailure.unrecognized),
      ImportSourceApp.googleTasks => parseGoogleTasks(text, now: now),
      ImportSourceApp.microsoftToDo => throw const ImportFormatException(
        ImportFailure.unrecognized,
      ),
      ImportSourceApp.tickTick => parseTickTick(text),
      ImportSourceApp.nirvana => parseNirvana(text),
      ImportSourceApp.omniFocus || ImportSourceApp.plainText => parseTaskPaper(
        text,
        source: source,
        now: now,
      ),
    });
  }

  static ImportPlan _fingerprinted(ImportPlan plan, String input) => ImportPlan(
    source: plan.source,
    projects: plan.projects,
    items: plan.items,
    warnings: plan.warnings,
    fingerprint: sha256.convert(utf8.encode(input)).toString(),
  );

  Future<bool> wasImported(ImportPlan plan) async =>
      plan.fingerprint != null &&
      await ImportHistoryRepository(_database).contains(plan.fingerprint!);

  /// Counts and names what [plan] would create, without writing.
  Future<ImportPreview> preview(ImportPlan plan) async =>
      (await _resolve(plan)).preview;

  /// Writes [plan] in one transaction, then reconciles reminders.
  Future<ImportReceipt> call(ImportPlan plan) async {
    late ResolvedImport resolved;
    final batchId = plan.fingerprint == null ? null : _ids.newId();
    await _database.transaction(() async {
      // Re-resolved inside the transaction so names created since the
      // preview still merge instead of duplicating.
      resolved = await _resolve(plan);
      for (final area in resolved.newAreas) {
        await _areas.upsert(area);
      }
      await _contexts.upsertAll(resolved.newContexts);
      await _projects.upsertAll(resolved.newProjects);
      await _items.upsertAll(resolved.items);
      await _tags.upsertAll(resolved.newTags, createdAt: _clock.now());
      await _tags.replaceItemTags(resolved.itemTagIds);
      if (batchId != null) {
        await ImportHistoryRepository(
          _database,
        ).record(batchId, plan.fingerprint!);
      }
    });
    var remindersFailed = false;
    for (final item in resolved.items) {
      if (item.dueAt == null && item.deferUntil == null) continue;
      try {
        await _reconcileReminders?.call(item);
      } catch (_) {
        // Rows are committed; the launch re-arm heals missed reminders.
        remindersFailed = true;
      }
    }
    return ImportReceipt(
      itemIds: [for (final i in resolved.items) i.id],
      areaIds: [for (final a in resolved.newAreas) a.id],
      batchId: batchId,
      projectIds: [for (final p in resolved.newProjects) p.id],
      contextIds: [for (final c in resolved.newContexts) c.id],
      tagIds: [for (final t in resolved.newTags) t.id],
      remindersFailed: remindersFailed,
    );
  }

  /// Removes what [receipt] created: its Items (with their reminders and
  /// tag links), and its new Projects, Contexts, and tags unless something
  /// else now uses them.
  Future<void> undo(ImportReceipt receipt) async {
    await _deleteItems(receipt.itemIds);
    await _database.transaction(() async {
      if (receipt.batchId != null) {
        await ImportHistoryRepository(_database).remove(receipt.batchId!);
      }
      for (final id in receipt.projectIds) {
        if (!await _items.anyReferencing(projectId: id)) {
          await _projects.delete(id);
        }
      }
      for (final id in receipt.areaIds) {
        if (!(await _projects.watchAll().first).any((p) => p.areaId == id)) {
          await _areas.delete(id);
        }
      }
      for (final id in receipt.contextIds) {
        if (!await _items.anyReferencing(contextId: id)) {
          await _contexts.delete(id);
        }
      }
      for (final id in receipt.tagIds) {
        if (!await _tags.isUsed(id)) await _tags.delete(id);
      }
    });
  }

  Future<ResolvedImport> _resolve(ImportPlan plan) async => resolveImport(
    plan,
    existingContexts: await _contexts.all(),
    existingAreas: await _areas.watchAll().first,
    existingProjects: await _projects.watchAll().first,
    existingTags: await _tags.all(),
    newId: _ids.newId,
    now: _clock.now(),
    dueMinutesOfDay: _dueMinutesOfDay,
  );

  static ImportPlan _checked(ImportPlan plan) {
    if (plan.items.isEmpty && plan.projects.isEmpty) {
      throw const ImportFormatException(ImportFailure.noTasks);
    }
    return plan;
  }

  static bool _isZip(List<int> bytes) =>
      bytes.length >= 4 &&
      bytes[0] == 0x50 &&
      bytes[1] == 0x4B &&
      bytes[2] == 0x03 &&
      bytes[3] == 0x04;

  static List<({String name, String text})> _zipCsvFiles(List<int> bytes) {
    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(bytes);
    } on Object {
      throw const ImportFormatException(ImportFailure.unreadable);
    }
    final csv = archive.files.where(
      (f) =>
          f.isFile &&
          f.name.toLowerCase().endsWith('.csv') &&
          !f.name.startsWith('__MACOSX/'),
    );
    if (csv.fold<int>(0, (n, f) => n + f.size) > maxZipBytes) {
      throw const ImportFormatException(ImportFailure.unreadable);
    }
    final files = <({String name, String text})>[];
    for (final f in csv) {
      try {
        files.add((name: f.name, text: decodeImportText(f.content)));
      } on Object {
        throw const ImportFormatException(ImportFailure.unreadable);
      }
    }
    if (files.isEmpty) {
      throw const ImportFormatException(ImportFailure.unrecognized);
    }
    return files;
  }
}

/// Text from export bytes: UTF-16 when it starts with a UTF-16 byte-order
/// mark (spreadsheet "Unicode text"), otherwise lenient UTF-8. NUL bytes
/// mean a binary file and throw [ImportFailure.unreadable].
String decodeImportText(List<int> bytes) {
  String text;
  if (bytes.length >= 2 &&
      ((bytes[0] == 0xFF && bytes[1] == 0xFE) ||
          (bytes[0] == 0xFE && bytes[1] == 0xFF))) {
    final little = bytes[0] == 0xFF;
    final units = <int>[
      for (var i = 2; i + 1 < bytes.length; i += 2)
        little
            ? bytes[i] | (bytes[i + 1] << 8)
            : (bytes[i] << 8) | bytes[i + 1],
    ];
    text = String.fromCharCodes(units);
  } else {
    text = utf8.decode(bytes, allowMalformed: true);
  }
  if (text.startsWith('﻿')) text = text.substring(1);
  if (text.contains('\u0000')) {
    throw const ImportFormatException(ImportFailure.unreadable);
  }
  return text;
}
