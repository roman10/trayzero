# ADR 0012 — One-time Microsoft To Do import

- Status: Accepted
- Date: 2026-11-03

## Plan and decision

1. Add an injected Microsoft To Do gateway: system-browser OAuth authorization
   code + PKCE through AppAuth, requesting delegated `Tasks.Read` only. No
   client secret, refresh token, background sync, or stored access token.
2. Read all lists, tasks, and open tasks' checklist steps through Graph v1.0.
   Follow pagination, reject redirects/untrusted next links, bound retries and
   request time, and fail the entire read on any incomplete response.
3. Convert the snapshot with a pure Dart mapper. Feed the resulting ImportPlan
   into the existing preview → transaction → Undo flow. No writes before confirm.
4. Cover mapping, pagination, failures, cancellation, persistence/rollback and
   widget behavior; review and fix high-confidence findings before committing.

## Mapping

- The default Tasks list is Inbox even when its name is localized. Other lists
  become Projects, except recognized Inbox/Waiting/Someday names (ADR 0008).
- Completed tasks and checked steps are skipped and counted. Waiting tasks
  become Waiting For; deferred tasks become Someday. Checklist steps become
  separate Items in the same Project, with their parent's title in notes.
- Titles, text/HTML body, category tags, due and start dates are retained.
  Microsoft To Do midnight due/start values are calendar dates, retained at
  local midnight before the existing resolver applies the reminder hour.
  Timed UTC/offset or IANA-zone values are converted to local time; unsupported
  zones/dates stay in notes with a warning instead of guessing an offset.
- Recurrence stays in notes with a counted warning in this first version.
  Mapping Graph's full recurrence range semantics to completion-based cloning
  needs a separate fidelity decision. Importance, attachments, and source reminder
  settings are not migrated and receive warnings. Linked resources are not read
  in this version; links already present in task notes are retained.
- Existing Projects/Contexts/Tags merge by name. Tasks get new local IDs;
  repeating this import can duplicate tasks. The source hint explains this.
- The gateway is read-only. Cancel/dispose prevents late reads from reaching
  preview or writing. A failure on any page does not offer a partial import.

## Configuration and release verification

Trayzero's public client uses this Microsoft Entra configuration:

- Application (client) ID: `a17f0981-ccba-4ff6-9445-2e09297f88c8`
- Account audience: organizational and personal Microsoft accounts.
- Delegated Graph permission: `Tasks.Read` only; default `User.Read` removed.
- No client secret or tenant-wide admin consent.
- Home, terms and privacy links use `https://trayzero.app`.

The public client ID is included by default; it is not a secret. A build-time
override can select a different registration; an explicitly empty override
disables this importer. For another distribution, register a Microsoft Entra
**Mobile and desktop applications** public client
supporting **Accounts in any organizational directory and personal Microsoft
accounts**. Register the redirect `app.cleartray.microsoft://oauth/callback` and
Graph delegated `Tasks.Read`. Also register
`app.cleartray.microsoft.debug://oauth/callback` for debug builds; Android debug
and release installs use separate schemes so they can coexist. Do not create a
client secret. Build with:

```
flutter build apk --dart-define=MICROSOFT_TODO_CLIENT_ID=<application-client-id>
flutter build ipa --dart-define=MICROSOFT_TODO_CLIENT_ID=<application-client-id>
```

With an explicitly empty ID, the source explains that import is unavailable in
this build. No Microsoft request is made on launch. The same-account import is a
one-time read, not account linking. Organization policy may deny user consent.

Before release, test sign-in/cancel/return on physical Android and iOS devices
with personal and work accounts. Confirm pagination, date-only values in a
negative UTC offset, shared lists, completed/unchecked steps, denied consent,
expired tokens, and Undo. Unit/widget tests use documented synthetic Graph
responses, not a live Microsoft account or app registration.

## References

- [Graph lists and delegated permissions](https://learn.microsoft.com/en-us/graph/api/todo-list-lists?view=graph-rest-1.0)
- [Task fields and statuses](https://learn.microsoft.com/en-us/graph/api/resources/todotask?view=graph-rest-1.0)
- [Checklist items](https://learn.microsoft.com/en-us/graph/api/resources/checklistitem?view=graph-rest-1.0)
- [Date/time/zone](https://learn.microsoft.com/en-us/graph/api/resources/datetimetimezone?view=graph-rest-1.0)
- [AppAuth setup and PKCE](https://pub.dev/packages/flutter_appauth)

## Review and validation

High-confidence review fixes:

- Convert IANA timestamps through an ordinary Dart DateTime; timezone's
  `TZDateTime.toLocal()` uses its configured location, not the device zone.
- Parse source wall-clock components in UTC before applying the source zone,
  so a DST gap on the device cannot silently change a task's source time.
- Use distinct Android debug/release OAuth callbacks so coexisting installs
  cannot intercept each other's sign-in result.
- Count unsupported attachments/reminder settings/statuses separately from
  priorities so preview warnings describe the actual information loss.

Follow-up review on 2026-11-03 also fixed two data/retry issues, with regression
coverage: adjacent HTML blocks and table cells retain separators in task notes;
`Retry-After` accepts HTTP dates as well as seconds, including long, expired,
and malformed values. Integration retains Google Tasks duplicate warnings,
structured Things import, and Apple Reminders list selection/disposal guards.
The source-list widget test now allows enough scrolling for all importers at
2× text size on a compact phone. This ADR uses 0012 because 0011 was assigned
to Apple Reminders before the Microsoft branch merged.

## Android callback task correction — 2026-11-04

Reproduced the 1.0.6 sign-in stall on a physical Android phone. Microsoft's
Continue button reached `RedirectUriReceiverActivity`, but Android created a
new task and a new `AuthorizationManagementActivity` rather than resuming the
pending instance. AppAuth logged `No stored state - unable to handle response`;
the original browser/session remained open. The Flutter host and icon launchers
used an empty task affinity while AppAuth inherited the application affinity.

All eight native app entrypoints now inherit the default application affinity,
matching AppAuth's receiver and authorization activity. This includes the icon
launchers because they create the initial task before forwarding to Flutter.
Existing component names, callback schemes and launch modes are retained.
Debug/release use their respective application IDs as affinities, keeping their
sessions separate. This follows [AppAuth's redirect troubleshooting guidance](https://pub.dev/packages/flutter_appauth/versions/12.1.0#troubleshooting).

A native regression test covers the Flutter host, all seven icon launchers,
both AppAuth activities, and callback resolution for the separate debug and
release schemes.
