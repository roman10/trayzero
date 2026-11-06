import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:cleartray/application/providers.dart';
import 'package:cleartray/domain/import/import_plan.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';
import '../support/things_fixture.dart';

List<int> fixture(String name) =>
    File('test/fixtures/import/$name').readAsBytesSync();

List<int> zip(String name, List<int> bytes) => ZipEncoder().encode(
  Archive()..addFile(ArchiveFile(name, bytes.length, bytes)),
);

void main() {
  // Expected totals are an explicit oracle, independent of the parser output.
  final cases =
      <
        ({
          ImportSourceApp source,
          String name,
          List<int> Function() bytes,
          int total,
        })
      >[
        (
          source: ImportSourceApp.todoist,
          name: 'todoist_garage.csv',
          bytes: () => fixture('todoist_garage.csv'),
          total: 6,
        ),
        (
          source: ImportSourceApp.todoist,
          name: 'todoist_official_template.csv',
          bytes: () => fixture('todoist_official_template.csv'),
          total: 4,
        ),
        (
          source: ImportSourceApp.todoist,
          name: 'todoist.zip',
          bytes: () => zip('Garage.csv', fixture('todoist_garage.csv')),
          total: 6,
        ),
        (
          source: ImportSourceApp.tickTick,
          name: 'ticktick_backup.csv',
          bytes: () => fixture('ticktick_backup.csv'),
          total: 7,
        ),
        (
          source: ImportSourceApp.nirvana,
          name: 'nirvana_export.csv',
          bytes: () => fixture('nirvana_export.csv'),
          total: 7,
        ),
        (
          source: ImportSourceApp.nirvana,
          name: 'nirvana_export.json',
          bytes: () => fixture('nirvana_export.json'),
          total: 2,
        ),
        (
          source: ImportSourceApp.omniFocus,
          name: 'omnifocus.taskpaper',
          bytes: () => fixture('omnifocus.taskpaper'),
          // The Outline action group contributes its two children, not a task.
          total: 8,
        ),
        (
          source: ImportSourceApp.plainText,
          name: 'things_copy.txt',
          bytes: () => fixture('things_copy.txt'),
          total: 3,
        ),
        (
          source: ImportSourceApp.googleTasks,
          name: 'google_tasks.json',
          bytes: () => fixture('google_tasks.json'),
          total: 2,
        ),
        (
          source: ImportSourceApp.things,
          name: 'main.sqlite',
          bytes: thingsFixture,
          total: 3,
        ),
        (
          source: ImportSourceApp.things,
          name: 'things.zip',
          bytes: () => zip(
            'Things Database.thingsdatabase/main.sqlite',
            thingsFixture(),
          ),
          total: 3,
        ),
      ];

  for (final sample in cases) {
    test(
      '${sample.source.name}/${sample.name}: preview, persist, duplicate, Undo',
      () async {
        final env = await TestEnv.create(now: DateTime(2026, 11, 4, 10));
        addTearDown(env.dispose);
        final importer = env.container().read(importFromAppProvider);
        // Existing user data must survive both imports and both Undos.
        await importer(
          importer.parseText(ImportSourceApp.plainText, 'Existing QA task'),
        );
        Future<Map<String, List<Map<String, Object?>>>> snapshot() async => {
          for (final table in [
            'items',
            'projects',
            'contexts',
            'tags',
            'areas',
            'item_tags',
            'import_batches',
          ])
            table: [
              for (final row
                  in await env.db
                      .customSelect('SELECT * FROM $table ORDER BY rowid')
                      .get())
                row.data,
            ],
        };
        final baseline = await snapshot();
        final plan = importer.parseFile(
          sample.source,
          fileName: sample.name,
          bytes: sample.bytes(),
        );
        final preview = await importer.preview(plan);
        expect(preview.total, sample.total);
        if (sample.name == 'todoist_official_template.csv') {
          expect(
            preview.warnings,
            isNot(contains(ImportWarning.unreadableRows)),
          );
        }
        expect(await importer.wasImported(plan), isFalse);
        expect(await snapshot(), baseline, reason: 'Preview must be read-only');

        final first = await importer(plan);
        expect(first.itemIds, hasLength(sample.total));
        expect(first.remindersFailed, isFalse);
        expect(await importer.wasImported(plan), isTrue);
        final firstSnapshot = await snapshot();
        expect(firstSnapshot['items'], hasLength(sample.total + 1));
        final persistedStatusCounts = <String, int>{};
        for (final row in firstSnapshot['items']!) {
          if (!first.itemIds.contains(row['id'])) continue;
          final status = row['status'] as String;
          persistedStatusCounts.update(status, (n) => n + 1, ifAbsent: () => 1);
        }
        expect(persistedStatusCounts, {
          for (final entry in preview.byStatus.entries)
            entry.key.name: entry.value,
        });

        final second = await importer(plan);
        expect(
          second.itemIds.toSet().intersection(first.itemIds.toSet()),
          isEmpty,
        );
        expect(second.projectIds, isEmpty);
        expect(second.contextIds, isEmpty);
        expect(second.tagIds, isEmpty);
        expect(second.areaIds, isEmpty);
        expect(
          await env.db.select(env.db.items).get(),
          hasLength(2 * sample.total + 1),
        );
        await importer.undo(second);
        expect(await snapshot(), firstSnapshot);
        expect(await importer.wasImported(plan), isTrue);
        await importer.undo(first);
        expect(
          await snapshot(),
          baseline,
          reason: 'Undo must restore pre-existing data exactly',
        );
        expect(await importer.wasImported(plan), isFalse);
      },
    );
  }

  test(
    'generated 1000-task Todoist CSV preserves every quoted Unicode note and title',
    () async {
      final env = await TestEnv.create(now: DateTime(2026, 11, 4, 10));
      addTearDown(env.dispose);
      final importer = env.container().read(importFromAppProvider);
      final csv = StringBuffer('TYPE,CONTENT,DESCRIPTION,PRIORITY,INDENT\r\n');
      for (var i = 0; i < 1000; i++) {
        csv.writeln('task,"QA $i 日本語, café","Line $i\nSay ""hello""",4,1');
      }
      final plan = importer.parseFile(
        ImportSourceApp.todoist,
        fileName: 'QA generated.csv',
        bytes: utf8.encode(csv.toString()),
      );
      expect((await importer.preview(plan)).total, 1000);
      final receipt = await importer(plan);
      final rows = await env.db.select(env.db.items).get();
      expect(rows, hasLength(1000));
      final notesByTitle = {for (final row in rows) row.title: row.notes};
      for (var i = 0; i < 1000; i++) {
        expect(notesByTitle['QA $i 日本語, café'], 'Line $i\nSay "hello"');
      }
      await importer.undo(receipt);
      expect(await env.db.select(env.db.items).get(), isEmpty);
      expect(await env.db.select(env.db.projects).get(), isEmpty);
      expect(await importer.wasImported(plan), isFalse);
    },
  );
}
