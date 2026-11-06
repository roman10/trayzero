import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/clock.dart';
import '../../core/id_generator.dart';
import '../../domain/entities/entities.dart';
import '../db/database.dart';
import '../mappers.dart';

class AttachmentRepository {
  AttachmentRepository(this._db, this._clock, this._ids);
  final AppDatabase _db;
  final Clock _clock;
  final IdGenerator _ids;

  Stream<List<Attachment>> watchForItem(String itemId) {
    final query = _db.select(_db.attachments)
      ..where((t) => t.itemId.equals(itemId))
      ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]);
    return query
        .watch()
        .map((rows) => rows.map((r) => r.toEntity()).toList());
  }

  /// One grouped-count stream over the whole (small, sparse) attachments table,
  /// folded into per-item summaries. Cards do an O(1) map lookup instead of each
  /// opening its own stream. Re-emits whenever any attachment changes.
  Stream<Map<String, AttachmentSummary>> watchSummaries() {
    final count = _db.attachments.id.count();
    final query = _db.selectOnly(_db.attachments)
      ..addColumns([_db.attachments.itemId, _db.attachments.kind, count]);
    query.groupBy([_db.attachments.itemId, _db.attachments.kind]);
    return query.watch().map((rows) {
      final acc = <String, ({int images, int audio, int files})>{};
      for (final row in rows) {
        final itemId = row.read(_db.attachments.itemId);
        if (itemId == null) continue;
        final kind = row.read(_db.attachments.kind);
        final n = row.read(count) ?? 0;
        final cur = acc[itemId] ?? (images: 0, audio: 0, files: 0);
        acc[itemId] = switch (kind) {
          'image' => (images: cur.images + n, audio: cur.audio, files: cur.files),
          'audio' => (images: cur.images, audio: cur.audio + n, files: cur.files),
          _ => (images: cur.images, audio: cur.audio, files: cur.files + n),
        };
      }
      return {
        for (final e in acc.entries)
          e.key: AttachmentSummary(
            images: e.value.images,
            audio: e.value.audio,
            files: e.value.files,
          ),
      };
    });
  }

  Future<List<Attachment>> getForItem(String itemId) async {
    final rows = await (_db.select(_db.attachments)
          ..where((t) => t.itemId.equals(itemId)))
        .get();
    return rows.map((r) => r.toEntity()).toList();
  }

  Future<List<Attachment>> allForItems(Iterable<String> itemIds) async {
    final rows = await (_db.select(_db.attachments)
          ..where((t) => t.itemId.isIn(itemIds)))
        .get();
    return rows.map((r) => r.toEntity()).toList();
  }

  Future<void> upsertAll(List<Attachment> rows) async {
    if (rows.isEmpty) return;
    await _db.batch(
      (b) => b.insertAllOnConflictUpdate(
        _db.attachments,
        rows.map((r) => r.toCompanion()).toList(),
      ),
    );
  }

  Future<Attachment?> getById(String id) async {
    final row = await (_db.select(_db.attachments)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row?.toEntity();
  }

  /// Copies the source file into the app's documents `attachments/` folder
  /// and inserts a row. Returns the persisted [Attachment].
  Future<Attachment> attach({
    required String itemId,
    required AttachmentKind kind,
    required File source,
    String? originalName,
  }) async {
    final docs = await getApplicationDocumentsDirectory();
    final targetDir = Directory(p.join(docs.path, 'attachments', itemId));
    await targetDir.create(recursive: true);
    final ext = p.extension(source.path);
    final id = _ids.newId();
    final relativePath = p.join('attachments', itemId, '$id$ext');
    final absolutePath = p.join(docs.path, relativePath);
    await source.copy(absolutePath);
    final size = await File(absolutePath).length();
    final attachment = Attachment(
      id: id,
      itemId: itemId,
      kind: kind,
      path: relativePath,
      name: originalName,
      sizeBytes: size,
      createdAt: _clock.now(),
    );
    await _db
        .into(_db.attachments)
        .insertOnConflictUpdate(attachment.toCompanion());
    return attachment;
  }

  Future<void> delete(Attachment a) async {
    final docs = await getApplicationDocumentsDirectory();
    final f = File(p.join(docs.path, a.path));
    if (await f.exists()) {
      await f.delete();
    }
    await (_db.delete(_db.attachments)..where((t) => t.id.equals(a.id))).go();
  }

  /// Resolve the relative [Attachment.path] back to an absolute filesystem
  /// path. UI / playback widgets need the absolute form.
  Future<String> absolutePathOf(Attachment a) async {
    final docs = await getApplicationDocumentsDirectory();
    return p.join(docs.path, a.path);
  }
}
