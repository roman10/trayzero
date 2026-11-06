import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

import '../../domain/entities/entities.dart';
import 'backfill_search_text.dart';
import 'migrate_next_action_due_dates.dart';
import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [
  Items, Projects, Contexts, Areas, Attachments, Reviews, CalendarMirrors,
  Tags, ItemTags, ImportBatches,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 14;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          // v13 → v14: local import history, committed with imported rows.
          if (from < 14) {
            await m.createTable(importBatches);
            await m.createIndex(importBatchesFingerprint);
          }
          // v12 → v13: tags, people, and Agendas (ADR 0010). New tables
          // only; no existing row changes.
          if (from < 13) {
            await m.createTable(tags);
            await m.createTable(itemTags);
            await m.createIndex(itemTagsTagId);
          }
          // v11 → v12: Today focus and per-project review (ADR 0007). Pure
          // additive nullable columns, hoisted with the other column adds so
          // the full-row item helpers below see every current column.
          if (from < 12) {
            await m.addColumn(items, items.focusedAt);
            await m.addColumn(projects, projects.lastReviewedAt);
          }
          // v10 → v11: persist a resumable Weekly Review step.
          if (from < 11) await m.addColumn(reviews, reviews.currentStep);
          if (from < 10) await m.createTable(calendarMirrors);
          // v8 → v9: per-project manual action order. Pure additive column
          // with a `0` default — SQLite ADD COLUMN does not rewrite the
          // table, so every existing row is preserved and reads back `0`,
          // which (with the `projectSortOrder ASC, createdAt ASC` ordering)
          // reproduces the previous createdAt-only project order exactly.
          //
          // Hoisted above every block below: the v6→v7 / v7→v8 helpers do a
          // full-row `select(items)` that maps through the *current*
          // generated `ItemRow`, so every column the build knows about —
          // including this one — must already exist before they run. A user
          // upgrading straight from ≤v8 runs those helpers in the same pass,
          // so the column has to be added first.
          if (from < 9) {
            await m.addColumn(items, items.projectSortOrder);
          }
          // v1 → v2: recurring actions + attachments.
          if (from < 2) {
            await m.addColumn(items, items.recurrence);
            await m.addColumn(items, items.recurrenceInterval);
            await m.createTable(attachments);
          }
          // v2 → v3: remember the pre-completion status so reopening an
          // item restores it to the list it came from.
          if (from < 3) {
            await m.addColumn(items, items.previousStatus);
          }
          // v3 → v4: remember the mirrored calendar event id so calendar
          // sync can update events in place instead of duplicating them.
          if (from < 4) {
            await m.addColumn(items, items.calendarEventId);
          }
          // v4 → v5: recurrence end conditions (until-date / count cap and
          // the completed-occurrence counter that enforces the cap).
          if (from < 5) {
            await m.addColumn(items, items.recurrenceUntil);
            await m.addColumn(items, items.recurrenceCount);
            await m.addColumn(items, items.recurrenceDoneCount);
          }
          // v5 → v6: structured recurrence (weekly by-weekday, monthly
          // Nth-weekday). Existing rows have null qualifiers and keep their
          // original simple cadence behaviour.
          if (from < 6) {
            await m.addColumn(items, items.recurrenceByWeekdays);
            await m.addColumn(items, items.recurrenceMonthlyWeek);
            await m.addColumn(items, items.recurrenceMonthlyWeekday);
          }
          // v6 → v7: derived normalised search column for accent/case-
          // insensitive search. Backfill so existing rows stay searchable
          // immediately instead of waiting until each is next edited.
          if (from < 7) {
            await m.addColumn(items, items.searchText);
            await backfillSearchText(this);
          }
          // v7 → v8: GTD Option A — a next action's only date anchor is
          // `deferUntil`. No schema change; retire stray `dueAt` values from
          // existing next actions (moved to `deferUntil` when free).
          if (from < 8) {
            await migrateNextActionDueDates(this);
          }
          if (from < 10) {
            // Bind legacy ownership to the saved selection before it can
            // change; retain it even if its Item is deleted before syncing.
            await customStatement(
              'INSERT INTO calendar_mirrors '
              '(calendar_id, event_id, item_id, is_current) '
              "SELECT '', calendar_event_id, MIN(id), 1 FROM items "
              'WHERE calendar_event_id IS NOT NULL GROUP BY calendar_event_id',
            );
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'cleartray.sqlite'));
    final cachebase = (await getTemporaryDirectory()).path;
    sqlite3.tempDirectory = cachebase;
    return NativeDatabase.createInBackground(file);
  });
}
