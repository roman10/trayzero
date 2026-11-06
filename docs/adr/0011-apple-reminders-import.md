# ADR 0011 — One-time Apple Reminders import

- Status: Accepted
- Date: 2026-11-03

## Context and plan

Apple Reminders users need an on-device migration path without preparing an
export. Extend ADR 0008's source list with an iOS-only native source, request
permission on an explicit tap, select lists, prepare an ImportPlan, and reuse
the preview → transaction → Undo flow. Keep the source store read-only.

Implement behind a core gateway and a registered iOS EventKit method channel.
Test application mapping and database behavior, channel contracts, permission
and selection states, native serialization, and compact-screen accessibility.
Review date precision, partial failures, and asynchronous disposal before commit.

## Decision

- Apple Reminders appears only on iOS. No request is made on startup or when
  merely visiting the source screen. Choose lists requests Reminders access:
  full access on iOS 17+, legacy reminder access on iOS 15–16. Both privacy
  purpose keys are present. The plugin contains no source-store write methods.
- No list is preselected. Lists show their account name. Only selected list
  identifiers are queried; empty or missing identifiers never mean all lists.
  Revoked permissions, unavailable lists, and failed reads produce recoverable
  errors. Reload lists starts a fresh selection; Back from preview retains it.
- Import open reminders returned by public EventKit APIs. Skip completed and
  untitled rows with existing counted warnings. Deduplicate returned reminder
  IDs within a snapshot. Empty selections or selections with no open tasks
  never create projects or write rows.
- An ordinary list becomes a Project using ADR 0008's name merging. Recognized
  Inbox, Waiting and Someday names use their GTD destinations. Identically
  named lists can merge; source list and account remain in each Item's notes.
  Empty lists are not imported.
- Preserve titles, notes, URLs, due dates and start dates. An ordinary dated
  action becomes Calendar as in ADR 0008. Date-only deadlines use the user's
  configured reminder hour. Native dates carry an explicit date-only flag so
  an actual midnight deadline keeps its time. File parsers retain their
  existing date-only heuristic.
- Serialize recurrence rules without dropping qualifiers. Map a single rule
  only when the shared parser can represent it exactly and a date anchor
  exists. Keep other rules in notes with a warning. In particular, retain
  UNTIL boundaries and COUNT-limited rules as text: the shared parser
  has a date-only end boundary and EventKit does not expose how much of a
  source occurrence count has already elapsed. Also retain intersections,
  non-Monday interval-week boundaries, and month-end/leap-day/fifth-weekday
  rules whose skipped occurrences would instead be clamped by Trayzero.
- Explain limitations before import: Apple tags, flags, attachments and subtask
  structure are not copied, nor are priorities and original alerts. Reminders
  available through EventKit are imported flat; this is not a full-fidelity
  Reminders backup. Trayzero schedules its own reminders using existing rules.
- Import is a one-time copy. Repeating an import can duplicate tasks; both the
  selection and preview screens say so. Undo affects only the local import
  receipt and never changes Apple reminders.
- All new Flutter copy is translated into the ten supported ARB locales.

No schema change, Apple account login, network service, background sync,
private Apple APIs, or new package dependency is required.

## Validation

- Application tests cover filtering and deduplication, metadata, empty/stale
  selection, completed-only input, supported and unsupported recurrence, invalid
  dates, date-only versus timed midnight deadlines, time zones, project merging,
  a read-only preview, commit, and Undo retaining pre-existing rows.
- Method-channel tests cover request/response contracts, denied/revoked access,
  unavailable/stale lists, unsupported platforms, empty selections, and malformed
  responses failing visibly rather than pretending no data exists.
- Widget/controller tests cover no unsolicited permission request, selected-list
  import and Undo, Back retaining the selection, permission recovery, empty/stale
  lists, no tasks, platform visibility, disposal during a permission request,
  duplicate taps, and a 360×640 screen at 3× text.
- Runner XCTest tests serialize EventKit reminder fields, date-only and timed
  midnight values with a UTC+8 timezone, and complex recurrence qualifiers
  without saving or reading anyone's reminders.
- Run Flutter static analysis, the relevant import tests, an iOS simulator build,
  and RunnerTests on an isolated simulator. Real-device/iCloud migration still
  needs manual verification; mocks and serialization tests cannot prove every
  provider's EventKit coverage or the real permission dialog experience.

## Sources

- [Apple: EKReminder](https://developer.apple.com/documentation/eventkit/ekreminder)
- [Apple: fetchReminders](https://developer.apple.com/documentation/eventkit/ekeventstore/fetchreminders(matching:completion:))
- [Apple: full reminder access](https://developer.apple.com/documentation/eventkit/ekeventstore/requestfullaccesstoreminders(completion:))
- [Apple: Reminders privacy key](https://developer.apple.com/documentation/bundleresources/information-property-list/nsremindersfullaccessusagedescription)

## Verified on 2026-11-03

- `flutter analyze --no-pub`: no issues.
- Targeted import regression suite: 105 tests passed (including 20 new Flutter
  tests for this feature).
- `flutter build ios --simulator --debug --no-codesign`: succeeded.
- `xcodebuild test` on an isolated iOS 18.5 simulator: 5 RunnerTests passed,
  including 4 new Apple Reminders native tests. The temporary simulator was
  removed afterward.
- `plutil -lint` for Info.plist and project.pbxproj, plus `git diff --check`: passed.

Review fixes: preserve explicitly timed midnight deadlines, reject recurrence
conversions that change meaning, retain account provenance, guard asynchronous
controller completion after disposal, and avoid timing out a person while they
answer the permission prompt. Build-generated dependency and project churn was
excluded from the change.


## Follow-up review

File picking now enters the busy state before awaiting the platform picker,
blocks competing file/paste/native actions, restores the previous state on
cancel, handles picker errors, and ignores results after disposal. Three
regression tests exercise these paths. Native permission failures inspect the
current authorization status even when EventKit returns an error, so denied or
restricted access still shows Settings recovery; an XCTest covers that case.

Follow-up validation: 27 focused Flutter tests and 6 native XCTest tests passed.
After integrating local main's Google Tasks and Things changes, 141 import and
migration tests plus 6 dedicated Things application tests passed; static
analysis reported no issues. All ten localization files retain main's existing
values and the eight Apple-specific strings. Project/plist validation and diff
checks also passed.
