import 'dart:io';

import 'package:archive/archive.dart';
import 'package:sqlite3/sqlite3.dart';

/// Build a real SQLite file from a synthetic, inspectable schema. Mutations
/// allow tests to emulate version changes and unusual source data.
List<int> thingsFixture({void Function(Database)? modify}) {
  final directory = Directory.systemTemp.createTempSync('things-fixture-');
  final path = '${directory.path}/main.sqlite';
  final db = sqlite3.open(path);
  try {
    db.execute(
      File('test/fixtures/import/things_schema.sql').readAsStringSync(),
    );
    modify?.call(db);
  } finally {
    db.dispose();
  }
  try {
    return File(path).readAsBytesSync();
  } finally {
    directory.deleteSync(recursive: true);
  }
}

List<int> thingsZip(Map<String, List<int>> files) {
  final archive = Archive();
  for (final entry in files.entries) {
    archive.addFile(ArchiveFile(entry.key, entry.value.length, entry.value));
  }
  return ZipEncoder().encode(archive);
}
