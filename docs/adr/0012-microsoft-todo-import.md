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

Trayzero's public client is registered in the owner's Default Directory:

- Application (client) ID: `a17f0981-ccba-4ff6-9445-2e09297f88c8`
- Directory (tenant) ID: `c3c0a340-c120-419e-8706-d0acf25d26db`
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

Verified locally: 1,113 unit/widget tests, the new parser tests under
`TZ=America/Los_Angeles`, `flutter analyze`, Android debug APK, and iOS simulator
builds through both CocoaPods and the existing Swift Package Manager setup.
AppAuth 2.1.0 is pinned in both existing SPM lockfiles. The local SDK's unrelated
Xcode project compatibility rewrites were discarded.

Live personal-account sign-in was verified in the iOS 18.5 simulator on
2026-11-03: email-code authentication returned to Trayzero, the native PKCE code
exchange succeeded, and the read-only Graph import finished with "No open tasks
found to import" for this account. No local tasks were added. An earlier browser
attempt returned `AADSTS900561` (GET on a POST-only endpoint); restarting the
authorization session resolved it without a code change. Its cause is not known.
Physical Android/iOS sign-in and populated personal/work accounts still need
release verification.
The publisher is currently unverified. The portal warns that end-user consent
for new multitenant apps can be blocked; work/school rollout needs verification
or administrator approval according to the customer's tenant policy. Publisher
verification requires a verified custom domain and a matching Partner Center
account, and has not been completed by this setup.

Registration configuration validation: 57 focused Microsoft import tests passed,
including the production provider wiring; five auth tests also passed with an
explicitly empty client-ID override. `flutter analyze` passed, and default-ID
Android debug and iOS simulator builds succeeded. SDK-generated Xcode/lockfile
churn was discarded.

Follow-up review on 2026-11-03 also fixed two data/retry issues, with regression
coverage: adjacent HTML blocks and table cells retain separators in task notes;
`Retry-After` accepts HTTP dates as well as seconds, including long, expired,
and malformed values. Integration retains Google Tasks duplicate warnings,
structured Things import, and Apple Reminders list selection/disposal guards.
The source-list widget test now allows enough scrolling for all importers at
2× text size on a compact phone. This ADR uses 0012 because 0011 was assigned
to Apple Reminders before the Microsoft branch merged.

Final combined Dart validation: 1,177 tests passed; `flutter analyze` reported
no issues.

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

Validation:

- A new native regression test failed against the old APK's empty host affinity
  and passed against the fixed APK. It checks host, all seven launchers, both
  AppAuth activities, and callback resolution/isolation between debug/release.
- Seven native tests passed on the emulator, including icon switching, host
  reuse and notification/deep-link entrypoints. An initial host-resume timeout
  passed on both an isolated rerun and the subsequent complete seven-test run.
- Both merged debug and release manifests inherit the shared affinity for all
  ten host/launcher/AppAuth activities. Debug and instrumentation APKs built.
- 57 focused Microsoft importer Dart tests passed.
- On the connected physical phone, the separate debug install completed
  personal-account sign-in, returned to the original authorization activity in
  the same task, read Graph and displayed a four-task import preview. Browser
  cancellation and subsequent sign-in were also checked. No import was
  confirmed; the existing release install and its data were left untouched.

Physical work/school-account and release-build sign-in remain release checks.
