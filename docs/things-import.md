# Structured Things 3 import

Implemented on 2026-11-03. Settings → Data → Import from another app → Things 3.

## Plan and architecture

1. Read a user-exported SQLite snapshot through a core port and infrastructure
   adapter. Open only a private temporary copy, in SQLite read-only mode.
2. Validate recognized Things tables/columns, copy values, close the database,
   and remove temporary files even when parsing fails.
3. Map rows in pure Dart into the shared ImportPlan. Reuse preview, name merging,
   transactional writes, reminder reconciliation, and Undo.
4. Test both date layouts, organization, malformed files, WAL recovery,
   transactional rollback, selective Undo, and the screen at 2× text size.

No Trayzero schema or backup-format change is required. Other importers retain
existing behavior; imported projects may now carry an Area and deadline.

## Export instructions

Cultured Code documents [database export on Mac and iOS](https://culturedcode.com/things/support/articles/2982272/).

- Mac: quit Things, copy its `Things Database.thingsdatabase` bundle, and either
  select the `main.sqlite` inside the copy or compress the bundle to a ZIP.
  Current installations keep the bundle under
  `~/Library/Group Containers/JLMPQHK86H.com.culturedcode.ThingsMac/ThingsData-xxxxx/`.
- iPhone/iPad: Things → Settings → General → Diagnostics → Enter Code →
  `491348` → Send Things Database. Save to Files. Tap the exported `.aar` to
  unpack it, then compress the resulting database folder to ZIP in Files.
  Choose that ZIP in Trayzero. A directly accessible `main.sqlite` also works.

The importer does not directly unpack Apple Archive `.aar` files. ZIP archives
must contain exactly one `main.sqlite`; the reader also copies its adjacent
`main.sqlite-wal`. Shared-memory sidecars are not reused. Keep all snapshot
files together when compressing; choosing a bare SQLite file omits any external
WAL. Never copy a running Mac database piecemeal.

## Mapping and limitations

| Things | Trayzero |
|---|---|
| Open to-do in Inbox | Inbox Item |
| Open Anytime / scheduled to-do | Next Action; start date becomes deferUntil |
| Open task with a deadline | Calendar Item (shared import rule); due dates use the configured reminder hour |
| Someday task or task in a Someday project | Someday Item |
| Project | Project, with notes as outcome and deadline preserved |
| Project Area | Area, merged by normalized name; associated with newly created Projects |
| Standalone task Area | Area name retained in notes (Items have no Area field) |
| Heading / legacy action group | Parent Project membership plus section name in notes |
| Checklist | Ordered `[ ]` / `[x]` lines in parent notes, retaining checked state |
| Tags | Shared Context/Tag mapping; project and heading tags inherited by tasks |
| Project start | Kept in outcome; children defer until the later of their own and project start |
| Completed, cancelled, trashed work | Skipped, including open children of closed Projects or trashed headings |
| Recurrence | Templates skipped; existing instances retained with a note to recreate recurrence and a preview warning |
| Source reminder settings | Not migrated; counted warning. Trayzero schedules its own notifications for imported dates |

Areas without imported Projects are not created. Existing Projects with the same
normalized name are reused without changing their metadata, as for other
sources. Tasks receive fresh IDs; importing the same export repeatedly can
create duplicate tasks. The shared preview warns for previously imported identical
input on this device, including a renamed Things file. Undo removes only its
batch from import history. Undo removes this import's Items and its newly created,
unused Projects, Areas, Contexts, and Tags, retaining resources used elsewhere.

This is a migration of open work, not a full archival restore. Things' native
recurrence, tag hierarchy, task history, Today/Evening selection, source reminder
settings, and attachments are not reconstructed. Project-level tags without
children have no native equivalent. No live Things database or Things Cloud is
accessed.

## Compatibility evidence and tests

The export procedure is official; the SQLite schema is private. Schema evidence:
[things.py reader](https://github.com/thingsapi/things.py/blob/main/things/database.py)
and its [current](https://github.com/thingsapi/things.py/tree/main/tests) and
[2022](https://github.com/thingsapi/things.py/tree/main/tests/db2022) public test
databases. Both public samples were exercised locally: each imported the expected 15 open
tasks, including WAL-only changes. These are example layouts, not a guarantee
for every Things release.

Current layouts use packed calendar dates in `startDate` / `deadline` and a
`heading` link. Older layouts use Unix timestamps in `startDate` / `dueDate`
and an `actionGroup` link. Detection uses column names, never numeric guesses.
Invalid dates are retained in notes with a warning; unfamiliar required schemas
are rejected rather than interpreted as plain text. Files are limited to 50 MiB,
including the selected ZIP database and WAL after decompression.

Automated tests create inspectable synthetic SQLite files from
`test/fixtures/import/things_schema.sql`. They cover real SQLite and ZIP
input, WAL-only updates, both date formats, inherited tags and project starts,
closed ancestors, recurrence templates, invalid dates, duplicate-name merging,
preview without writes, rollback, Undo retaining shared Areas, and large-text
UI preview → import → Undo. No third-party personal data is checked into this
repository.

```sh
flutter test test/domain/import test/application/import_from_app_test.dart \
  test/application/things_import_test.dart \
  test/infrastructure/sqlite_things_snapshot_reader_test.dart \
  test/widget/app_import_screen_test.dart
flutter analyze
```
