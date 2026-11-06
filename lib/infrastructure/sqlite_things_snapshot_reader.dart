import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:sqlite3/sqlite3.dart';

import '../core/things_snapshot_reader.dart';
import '../domain/import/import_plan.dart';

/// Opens only a private temporary copy, with SQLite in read-only mode.
/// ZIP members are copied to fixed names, never extracted to supplied paths.
class SqliteThingsSnapshotReader implements ThingsSnapshotReader {
  static const maxBytes = 50 * 1024 * 1024;

  @override
  Map<String, List<Map<String, Object?>>> read(List<int> bytes) {
    if (bytes.length > maxBytes) {
      throw const ImportFormatException(ImportFailure.unreadable);
    }
    final files = <String, List<int>>{};
    if (bytes.length >= 4 && bytes[0] == 0x50 && bytes[1] == 0x4b) {
      try {
        if (bytes.length < 22) {
          throw const ImportFormatException(ImportFailure.unreadable);
        }
        final archive = ZipDecoder().decodeBytes(bytes);
        final candidates = archive.files
            .where(
              (f) =>
                  f.isFile &&
                  !f.name.startsWith('__MACOSX/') &&
                  f.name.split('/').last == 'main.sqlite',
            )
            .toList();
        if (candidates.length != 1) {
          throw const ImportFormatException(ImportFailure.unrecognized);
        }
        final main = candidates.single;
        final selected = archive.files.where(
          (f) =>
              f.isFile && (f.name == main.name || f.name == '${main.name}-wal'),
        );
        if (selected.fold<int>(0, (n, f) => n + f.size) > maxBytes) {
          throw const ImportFormatException(ImportFailure.unreadable);
        }
        for (final file in selected) {
          files[file.name == main.name ? 'main.sqlite' : 'main.sqlite-wal'] =
              file.content;
        }
      } on ImportFormatException {
        rethrow;
      } catch (_) {
        throw const ImportFormatException(ImportFailure.unreadable);
      }
    } else {
      files['main.sqlite'] = bytes;
    }
    final main = files['main.sqlite']!;
    if (main.length < 16 ||
        ascii.decode(main.take(16).toList(), allowInvalid: true) !=
            'SQLite format 3\u0000') {
      throw const ImportFormatException(ImportFailure.unrecognized);
    }
    final directory = Directory.systemTemp.createTempSync('trayzero-things-');
    Database? database;
    try {
      for (final entry in files.entries) {
        File('${directory.path}/${entry.key}').writeAsBytesSync(entry.value);
      }
      database = sqlite3.open(
        '${directory.path}/main.sqlite',
        mode: OpenMode.readOnly,
      );
      database.execute('PRAGMA query_only = ON');
      database.execute('PRAGMA trusted_schema = OFF');
      final tables = database
          .select("SELECT name FROM sqlite_master WHERE type = 'table'")
          .map((r) => r['name'] as String)
          .toSet();
      List<Map<String, Object?>> readTable(String name, Set<String> required) {
        if (!tables.contains(name)) {
          throw const ImportFormatException(ImportFailure.unrecognized);
        }
        final columns = database!
            .select('PRAGMA table_info("$name")')
            .map((r) => r['name'] as String)
            .toSet();
        if (!columns.containsAll(required)) {
          throw const ImportFormatException(ImportFailure.unrecognized);
        }
        return database
            .select('SELECT * FROM "$name"')
            .map((r) => Map<String, Object?>.from(r))
            .toList();
      }

      final tasks = readTable('TMTask', {
        'uuid',
        'title',
        'type',
        'status',
        'trashed',
        'start',
        'startDate',
        'project',
        'area',
        'notes',
        'index',
      });
      final taskColumns = database
          .select('PRAGMA table_info("TMTask")')
          .map((r) => r['name'])
          .toSet();
      if (!(taskColumns.containsAll({'deadline', 'heading'}) ||
          taskColumns.containsAll({'dueDate', 'actionGroup'}))) {
        throw const ImportFormatException(ImportFailure.unrecognized);
      }
      return {
        'TMTask': tasks,
        'TMArea': readTable('TMArea', {'uuid', 'title'}),
        'TMTag': readTable('TMTag', {'uuid', 'title'}),
        'TMTaskTag': readTable('TMTaskTag', {'tasks', 'tags'}),
        'TMChecklistItem': readTable('TMChecklistItem', {
          'task',
          'title',
          'status',
          'index',
        }),
      };
    } on ImportFormatException {
      rethrow;
    } on SqliteException {
      throw const ImportFormatException(ImportFailure.unreadable);
    } finally {
      database?.dispose();
      directory.deleteSync(recursive: true);
    }
  }
}
