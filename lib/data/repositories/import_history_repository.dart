import '../db/database.dart';

/// Successful imports on this device. Each batch is separate so undoing a
/// repeated import leaves the earlier import's warning intact.
class ImportHistoryRepository {
  ImportHistoryRepository(this._db);
  final AppDatabase _db;

  Future<bool> contains(String fingerprint) async =>
      await (_db.select(_db.importBatches)
            ..where((t) => t.fingerprint.equals(fingerprint))
            ..limit(1))
          .getSingleOrNull() !=
      null;

  Future<void> record(String id, String fingerprint) async {
    await _db
        .into(_db.importBatches)
        .insert(
          ImportBatchesCompanion.insert(id: id, fingerprint: fingerprint),
        );
  }

  Future<void> remove(String id) async {
    await (_db.delete(_db.importBatches)..where((t) => t.id.equals(id))).go();
  }
}
