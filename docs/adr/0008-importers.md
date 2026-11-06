# ADR 0008 — Importing from other task apps

- Status: Accepted (tag mapping amended by ADR 0010)
- Date: 2026-10-26

## Context

People switching to Trayzero leave years of lists behind in Todoist,
TickTick, Nirvana, OmniFocus, or Things. Today the only import paths are a
Trayzero backup and a Google Tasks Takeout file, both through the backup
restore flow, which upserts rows by id and cannot merge names, preview what
will be created, or be undone. Retyping a working system is the biggest
switching cost, and a careless import that floods the Inbox or invents dozens
of contexts is worse than none.

## Decision

Add **Settings → Data → Import from another app**: a dedicated screen that
lists the sources with a one-line "how to export" hint each, reads one file
(or pasted text), shows a preview, writes everything in one transaction, and
offers **Undo import** on the result.

### Formats

Only formats a user can produce today without scripts. Sources whose format
could not be pinned down from public documentation are marked best-effort.

| Source | Accepted input | Confidence |
|---|---|---|
| Todoist | Project CSV (project menu → Export as CSV), or the backup ZIP of per-project CSVs (Settings → Backups). Columns per Todoist's published CSV template (`TYPE, CONTENT, DESCRIPTION, PRIORITY, INDENT, AUTHOR, RESPONSIBLE, DATE, DATE_LANG, TIMEZONE, DURATION, DURATION_UNIT, DEADLINE, …`). The project name comes from the file name. | Documented |
| TickTick | Web backup CSV (Settings → Account → Generate backup). Preamble lines are skipped until the `Folder Name`, `List Name`, `Title` header; columns are read by name. | Community-verified (open-source migrators) |
| OmniFocus | Edit → Copy as TaskPaper, pasted or saved as a text file. Parameters per Omni's TaskPaper reference (`@due`, `@defer`, `@done`, `@tags`, `@context`, `@estimate`, `@repeat-rule`, `@flagged`, …). OmniFocus's CSV export is not supported: its column values are undocumented and it is Mac-only. | Documented |
| Things 3 | A user-exported `main.sqlite`, or ZIP of the exported database bundle (including its WAL if present). See [structured Things import](../things-import.md) for instructions, mapping, and schema limits. | Export documented; database schema best-effort |
| Plain text / TaskPaper | Copied to-dos, TaskPaper, or one-task-per-line lists. Remains a fallback for Things and other apps. | Best-effort |
| Nirvana | CSV or JSON from Account → Data Export. Nirvana does not document the file layout, so fields are matched by name against Nirvana's API field model (`type, state, parentid, name, note, tags, energy, etime, waitingfor, startdate, duedate, completed, cancelled`), case-insensitively, numeric or word state values. A file without a recognizable name and state column is rejected with a clear message rather than guessed at. | Best-effort |

Google Tasks Takeout is also available on the dedicated import screen (see the 2026-11-03 amendment below). The existing backup import path remains available for compatibility.

### Mapping

| Source concept | Trayzero |
|---|---|
| Todoist project file / TickTick list / Nirvana project / TaskPaper `Name:` line or top-level task with children | Project (active). A project note, where the source has one, becomes the outcome (a Project's only text field). |
| List or project named *Inbox* | Inbox |
| List or project named *Someday*, *Maybe*, *Someday/Maybe*; Nirvana Someday / Later | Someday Item; for a Nirvana project row, Project status *Someday* / *On hold* |
| OmniFocus on-hold project | Project *On hold*, best-effort: Omni's TaskPaper reference has no status parameter, so only `@hold`, `@on-hold`, or `@status(on hold)` is recognized; otherwise it imports as active |
| List or project named *Waiting*, *Waiting for*; Nirvana Waiting (`waitingfor` → waiting on) | Waiting For |
| TickTick note-kind task; Nirvana reference list | Reference |
| Todoist section, TickTick folder | Kept as a line in the Item's notes (`Section: …`, `Folder: …`) |
| Subtask (Todoist indent, TickTick parent, TaskPaper nesting) | Separate action in the same Project; parent title in notes |
| Tag / label that looks like a context | Context (first one per Item) |
| Other tags | Tags; `agenda: Name` becomes a person tag (ADR 0010; previously a notes line `Tags: …`) |
| Due / deadline date | `dueAt` |
| Start / defer / scheduled date | `deferUntil` |
| Recurrence | Mapped when unambiguous (daily/weekly/monthly/yearly with interval, weekdays, nth weekday, count, until) and the Item has a date; otherwise the rule text stays in notes |
| Duration / estimate | Time estimate (minutes) |
| Nirvana energy 1–3 | Energy low / medium / high |
| Completed, dropped, trashed, cancelled | Skipped |
| Priority, flag, assignee, reminders, attachments | Not imported (counted in the preview) |

**Contexts.** A tag becomes a Context when it is written as `@name` in the
source (TaskPaper, TickTick, Nirvana), when it matches an existing Context
(case-insensitive, ignoring a leading `@`), or when it is one of a small set of
common English context words (phone, calls, computer, email, errands, home,
office, online, agenda, anywhere). Todoist writes every label as `@label`,
so for Todoist only the second and third rules apply. OmniFocus
`@context(...)` is always a Context. New Contexts are created as `@name`.

**Dated actions land in Calendar.** Trayzero keeps due dates only on the hard
landscape (GTD Option A: a Next Action's only date is its start date). An open
action with a due date therefore becomes a Calendar Item rather than silently
losing the date; the preview states how many. Inbox, Waiting, and Someday
Items keep their due date in place.

**Merging.** Existing Contexts and Projects with the same name
(case-insensitive, whitespace-collapsed, leading `@` ignored for Contexts) are
reused, never duplicated, whatever their status. Names inside one file are
merged the same way, so a Todoist backup containing `Garage` twice yields one
Project.

**Date-only due dates** land at the "Deferred items remind me at" hour, as
quick capture does (ADR 0007), so a due reminder never fires at midnight.

### Flow

1. *Sources* — one card per source: name, hint, and a 48dp *Choose file*
   button; text sources (OmniFocus, Things/plain text) also offer *Paste
   text*. The system file picker accepts any file type, because Android's
   picker cannot filter `.csv`/`.taskpaper` reliably. A file that is not the
   chosen app's export, or holds no open task, explains why on that card.
2. *Preview* — total tasks to add; counts per list (Inbox, Next Actions,
   Waiting For, Calendar, Someday, Reference); Projects with action counts,
   each marked *New* or *Adds to existing*; Contexts split into new and
   existing; a "Good to know" list of counted warnings (skipped completed
   tasks, dates kept as text, tags kept in notes, flattened subtasks,
   unmapped repeats, ignored priorities, unreadable rows). Nothing is written
   yet. Back returns to the source list.
3. *Import* — one database transaction. Existing names are re-resolved
   inside the transaction, so a Context created meanwhile is still merged.
   Reminders are reconciled after commit (best effort; the launch re-arm heals
   any miss).
4. *Result* — "N tasks added" with **Undo import** and **Done**. Undo removes
   exactly the Items the import created (via the batch delete use case, which
   also cancels their reminders) and the Projects and Contexts it created,
   unless something else now references them.

Parsing is pure Dart in `domain/import/` (one parser per source, a shared
RFC 4180 CSV reader, and a pure resolver that applies merge and context rules
against existing names). The use case `application/import_from_app.dart`
decodes bytes (UTF-8/UTF-16 BOMs, ZIP), resolves, writes, and undoes. The
screen has a controller holding the flow state (ADR 0002). No schema change
and no new backup fields.

### Edge cases

- UTF-8 BOM, UTF-16 BOM, CRLF/CR line endings, quoted commas and newlines,
  doubled quotes, a semicolon-delimited CSV re-saved by a spreadsheet,
  unterminated quotes (rest of file is one field; the row is counted as
  unreadable if it lacks a title).
- Rows with no title are skipped and counted. A file with no importable task
  is an error, not an empty import.
- Unparseable dates are kept as text in notes and counted.
- Non-ASCII titles, tags, and file names pass through unchanged; name
  matching uses Unicode-aware lowercase.
- A ZIP without CSV files, a corrupt ZIP, or a ZIP larger than 50 MB
  uncompressed is rejected.
- In text outlines, a `Name:` heading owns tasks written flush beneath it
  (`Errands:` / `- Buy milk`), but once its tasks are indented, the next
  line at the heading's own depth closes it; an unmarked line there is a
  task of its own, not a note on the heading.
- Year-less Todoist dates (`Mar 15`) use the current year, so overdue tasks
  stay overdue rather than jumping a year ahead.

## Self-review

- *Reuse the backup restore path, as Google Tasks does?* Rejected. Restore
  upserts by id and cannot merge names, preview creations, or undo; importing
  another app twice would also duplicate everything with fresh ids either way,
  and Undo is the honest remedy.
- *Put everything in the Inbox?* Rejected. It discards the user's existing
  organization and turns a switch into weeks of re-clarifying. Only the source
  Inbox lands in the Inbox.
- *Dated actions as start dates instead of Calendar?* Considered (the v8
  migration did this for stray Next Action due dates). Rejected because the
  sources call these due dates and some are real deadlines; silently making
  them "not before" dates would drop urgency. The preview count makes the
  Calendar destination visible before anything is written.
- *Every tag a Context?* Rejected. Tags like `urgent` or `2024` would litter
  the Context list, which drives the Do-tab filter. Unmatched tags stay
  searchable in notes until a tags feature exists.
- *Per-row checkboxes in the preview?* Rejected for now: a long list is slow
  to review on a phone, and Undo makes a wrong import cheap.
- *Parse in an isolate?* Not needed: a few thousand rows parse in
  milliseconds; the write is the slow part and already shows progress.

## Accessibility and localization

All copy is in the ten ARB locales; brand names are not translated. Source
tiles and buttons are 48dp, nothing has a fixed height, and the preview is a
scrolling list that wraps at large text sizes. Counts use ICU plurals.

## Validation

The [test fixture manifest](../../test/fixtures/import/README.md) documents
the provenance and coverage of the importer samples.

- Unit tests per source with fixture files under `test/fixtures/import/`,
  covering BOM, CRLF, quoted commas, multiline fields, non-ASCII, malformed
  rows, unknown columns, completed rows, recurrence mapping, and dates.
- CSV reader tests for quoting and line-ending edge cases.
- Resolver tests for case-insensitive merging and context rules.
- Use-case tests against an in-memory database: one transaction, merge with
  existing names, reminders reconciled, Undo removing only what was created.
- Widget test for the source list → preview → import → undo flow.

## Amendment — 2026-11-03: Google Tasks and duplicate warnings

- Google Tasks has its own source card accepting an extracted Takeout
  `Tasks.json`, using the dedicated preview → transaction → Undo pipeline.
  Preserve its existing mapping: open tasks → Inbox, completed tasks → Done
  with completion dates, list and parent names in notes, no automatic Projects.
  Google source IDs are not reused here: Undo must remove only new rows.
  The legacy backup import remains upsert-based and retains its existing IDs.
- The dedicated flow fingerprints source + exact input bytes (pasted text uses
  UTF-8). Todoist CSV includes the derived project name because that changes
  its destination; ZIP filenames and other source filenames do not affect it.
  A preview warns when the input was successfully imported on this device.
  The warning allows another copy; it does not silently skip or overwrite tasks.
- Schema v14 adds device-local `import_batches`, committed with imported rows.
  Every batch has a separate ID so Undo removes only its history entry, keeping
  earlier successful imports detectable. History is excluded from portable
  backups. It does not recognize earlier versions' imports, legacy backup
  restores, modified/re-exported files, or imports on another device. Manual
  deletion of imported items does not erase historical import warnings.
- Things was initially labeled basic text import in this amendment. Structured
  database import is now available via the separate Things 3 source; see
  [structured Things import](../things-import.md). The earlier claim that Things
  has no export was incorrect:
  [Things documents database export on Mac and iOS, Shortcuts and AppleScript](https://culturedcode.com/things/support/articles/2982272/).

### Export compatibility evidence and remaining validation

Checked on 2026-11-03:

- [TickTick's current export help](https://help.ticktick.com/articles/7055781405648748544)
  specifies web Settings → Account → Backup & Import. Source hints now say web.
  Compared CSV columns, status values, date formats, parent IDs and RRULEs with
  [Vikunja's current TickTick importer](https://github.com/go-vikunja/vikunja/blob/main/pkg/modules/migration/ticktick/ticktick.go).
  Regressions cover new/reordered columns, child-before-parent rows, repeating
  tasks, Unicode/multiline content and offset-bearing all-day/floating dates.
  All-day/floating values preserve wall time rather than shifting with offsets.
- [Nirvana's current export help](https://www.nirvanahq.com/help/how-to/export-data)
  confirms CSV/XML/JSON exports and included history, but publishes no field
  schema. CSV and JSON parser fixtures remain synthetic examples of the modeled
  fields; XML remains unsupported. Existing tests cover projects, states,
  waiting, scheduled tasks, dates, recurrence, Unicode and completed rows.
- No authenticated TickTick/Nirvana session or fresh user export was available.
  These checks are not live-export certification. Keep Nirvana best-effort;
  before claiming current-version fidelity, obtain sanitized exports from both
  apps containing a project/list, subtasks, a completed task, recurrence, a due
  date, an all-day date, Unicode tags and multiline notes, and add provenance
  (source version/export date) to the fixtures.

### Google date-only correction — 2026-11-03

Google's [`due` field](https://developers.google.com/workspace/tasks/reference/rest/v1/tasks)
carries only a calendar date despite its RFC3339 encoding. Both the dedicated
Google importer and the legacy backup converter now share a date-only reader:
retain the written year/month/day as local time before any timezone conversion.
The dedicated resolver applies the existing date-only reminder hour; the legacy
converter retains its existing local-midnight representation. Invalid calendar
dates are rejected rather than normalized into a different day. Takeout
`scheduled_time.start` continues to take precedence and retains its instant,
as do created/updated/completed timestamps. The standalone Python conversion
tool also emits date-only due values without a UTC offset.

The bug was reproduced with `TZ=America/Los_Angeles`: November 3 midnight UTC
became November 2 at 16:00 in the dedicated parser. Regression tests cover both
import paths through persistence and preserve timed timestamps. This is an
import-time correction; no automatic rewrite of existing rows is performed,
because a stored timestamp cannot establish whether the source was date-only
or whether the user subsequently edited it.

## Amendment — 2026-11-03: two-step source UI

The single scrolling screen of per-source cards (each with its full hint
paragraph) is replaced by two pages:

1. `/settings/import` (`AppImportScreen`) is a grouped list — "Connect
   directly" (Apple Reminders, Microsoft To Do), "From an export file", and
   "Anything else" (plain text) — with one row per source: initials tile, name,
   one-line subtitle, and an "On device" / "Sign in" chip or a chevron. A footer
   links to `/settings/backup` for restoring a Trayzero backup (the Google Tasks
   mention was dropped from that screen's description; the code path remains).
2. `/settings/import/:source` (`AppImportSourceScreen`, enum `name` as the path
   parameter) shows the source's numbered steps (Things has iPhone/iPad and Mac
   variants, with a copyable `491348` code chip), a good-to-know note, and a
   pinned primary action (Choose file / Choose lists / Connect), plus Paste text
   for paste-capable sources. All later controller steps (Apple list choice,
   preview, importing, done, undoing, undone) render on this page, so errors and
   progress appear where the user acted. Finish goes to `/settings` past both
   pages; back from the preview or list choice returns to the source page.

Source copy lives in one table, `import_source_catalog.dart` (name, subtitle,
group, method, steps, note, paste support). A source without step strings falls
back to its legacy `importHint*` paragraph as a single step. The controller is
autoDispose, so entering a source page always starts from a clean state; its
`backToSources()` was renamed `reset()`. The state machine is otherwise
unchanged.
