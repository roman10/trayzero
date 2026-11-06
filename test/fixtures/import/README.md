# Import fixture provenance

Last checked: 2026-11-04. These fixtures contain example/QA tasks, not a user's
export. Passing them does not certify the latest source app's full export schema.

| Fixture | Origin and purpose |
|---|---|
| `todoist_official_template.csv` | Unmodified public Todoist CSV template, downloaded 2026-11-04 from the attachment linked by [Todoist's CSV guide](https://www.todoist.com/help/account-and-billing/security/import-or-export-a-project-as-a-csv-file-in-todoist-YC8YvN): [attachment](https://get.todoist.help/hc/article_attachments/21672045045916). SHA-256 `4bd51e7a6ae9a47101d209294aa524fdac824857db981b77d9aab02a617c2692`. Four tasks; metadata row, comment, nested tasks, natural-language dates/repeats, durations and deadlines. This is a vendor example, not an authenticated export. |
| `todoist_garage.csv` | Synthetic project CSV using documented columns; BOM, CRLF, Unicode, multiline descriptions, sections, labels, subtasks, recurrence and invalid dates. |
| `ticktick_backup.csv` | Synthetic backup with modeled preamble/header, statuses, parent IDs, notes, recurrence and all-day/floating flags. Checked against the [Vikunja migration implementation](https://github.com/go-vikunja/vikunja/blob/main/pkg/modules/migration/ticktick/ticktick.go) in the earlier audit; not a fresh TickTick export. TickTick's [help page](https://help.ticktick.com/articles/7055781405648748544) does not supply a downloadable schema fixture. |
| `nirvana_export.csv`, `nirvana_export.json` | Synthetic field-model examples. [Nirvana documents export formats](https://www.nirvanahq.com/help/how-to/export-data), not their field schema. No current authenticated export verified; compatibility remains best-effort. XML is unsupported. |
| `omnifocus.taskpaper` | Synthetic outline based on [Omni's TaskPaper reference](https://support.omnigroup.com/omnifocus-taskpaper-reference/). Includes projects, folders, notes, contexts, nested action groups, dates and skipped completed/dropped tasks. Eight imported tasks; action-group headings are not separate tasks. |
| `things_schema.sql` | Synthetic inspectable SQLite schema/data; field provenance is noted in the SQL. `support/things_fixture.dart` generates temporary real SQLite and ZIP inputs. [Things documents database export](https://culturedcode.com/things/support/articles/2982272/), not a stable database schema. |
| `things_copy.txt` | Synthetic plain text with CRLF, an indented note and Unicode. Exercises the plain-text fallback, not the Things database importer. |
| `google_tasks.json` | Synthetic Takeout-shaped list/tasks with parent relationship, date-only due value and completed timestamp. [Google's task resource](https://developers.google.com/workspace/tasks/reference/rest/v1/tasks) documents due-date semantics, not a guarantee of every Takeout variant. |
| `microsoft_todo_graph.json` | Synthetic Graph response example. Gateway tests additionally use in-memory HTTP responses for pagination, checklist reads, failures, retry and cancellation. Live sign-in results are recorded separately. |
| `binary.bin` | Deliberately invalid input for rejection tests. |

`test/application/importer_matrix_test.dart` additionally generates a 1,000-task
Todoist CSV in memory with quoted commas, multiline notes, doubled quotes and
Unicode. It checks every persisted title/note and Undo; it is a correctness
check, not a device performance benchmark. CSV/ZIP and SQLite/ZIP wrappers are
generated during tests so no opaque archive needs manual upkeep.

For future real exports, record source version, export date/platform and
sanitization steps here. Keep schema/layout intact, replace personal content,
and add explicit expected values before treating the file as compatibility
evidence. Never commit OAuth tokens, account identifiers or private task data.
