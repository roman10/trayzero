import 'dart:io';

import 'package:cleartray/domain/import/import_plan.dart';
import 'package:cleartray/infrastructure/sqlite_things_snapshot_reader.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

import '../support/things_fixture.dart';

void main() {
  final reader = SqliteThingsSnapshotReader();
  Matcher failure(ImportFailure failure) => throwsA(
    isA<ImportFormatException>().having((e) => e.failure, 'failure', failure),
  );

  test('reads a standalone export without changing its input', () {
    final bytes = thingsFixture();
    final original = [...bytes];
    final snapshot = reader.read(bytes);
    expect(snapshot['TMTask'], hasLength(8));
    expect(snapshot['TMChecklistItem'], hasLength(2));
    expect(bytes, original);
  });

  test(
    'ZIP bundle resolves a nested database and ignores unrelated members',
    () {
      final result = reader.read(
        thingsZip({
          'Things Database.thingsdatabase/main.sqlite': thingsFixture(),
          '../ignored.txt': [1, 2, 3],
          '__MACOSX/main.sqlite': [1, 2, 3],
        }),
      );
      expect(result['TMTask']!, hasLength(8));
    },
  );

  test('ZIP keeps WAL transactions, not just the older main database', () {
    final directory = Directory.systemTemp.createTempSync('things-wal-test-');
    addTearDown(() => directory.deleteSync(recursive: true));
    final file = File('${directory.path}/main.sqlite')
      ..writeAsBytesSync(thingsFixture());
    final db = sqlite3.open(file.path);
    addTearDown(db.dispose);
    db.execute('PRAGMA journal_mode = WAL');
    db.execute('PRAGMA wal_autocheckpoint = 0');
    db.execute(
      "UPDATE TMTask SET title = 'Written to WAL' WHERE uuid = 'inbox'",
    );
    final result = reader.read(
      thingsZip({
        'export/main.sqlite': file.readAsBytesSync(),
        'export/main.sqlite-wal': File('${file.path}-wal').readAsBytesSync(),
      }),
    );
    expect(
      result['TMTask']!.singleWhere((r) => r['uuid'] == 'inbox')['title'],
      'Written to WAL',
    );
  });

  test('rejects non-database, ambiguous ZIP, and incomplete Things schema', () {
    expect(() => reader.read([1, 2, 3]), failure(ImportFailure.unrecognized));
    expect(
      () => reader.read(
        thingsZip({
          'Tasks.json': [1],
        }),
      ),
      failure(ImportFailure.unrecognized),
    );
    expect(
      () => reader.read(
        thingsZip({
          'a/main.sqlite': thingsFixture(),
          'b/main.sqlite': thingsFixture(),
        }),
      ),
      failure(ImportFailure.unrecognized),
    );
    expect(
      () => reader.read(
        thingsFixture(modify: (db) => db.execute('DROP TABLE TMTaskTag')),
      ),
      failure(ImportFailure.unrecognized),
    );
  });

  test('corrupt SQLite and corrupt ZIP are unreadable', () {
    final broken = thingsFixture();
    broken.fillRange(100, broken.length, 0);
    expect(() => reader.read(broken), failure(ImportFailure.unreadable));
    expect(
      () => reader.read([0x50, 0x4b, 3, 4, 0]),
      failure(ImportFailure.unreadable),
    );
  });
}
