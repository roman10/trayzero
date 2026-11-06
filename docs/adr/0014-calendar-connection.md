# ADR 0014 — Calendar connection and automatic publication

- Status: Accepted
- Date: 2026-11-05

## Context

The old Calendar sync switch exposed two manual actions, but its label implied
an ongoing connection. Disabling it did not explain what happened to existing
events. Native write failures could be reported as successful empty updates.

## Decision

Calendar connection is an explicit, device-local, one-way publishing feature.
Setup asks for permission only after Connect calendar, lists writable calendars
with account names, previews the scheduled item count, and requires confirmation.
Only active, dated Calendar items are published; ordinary task deadlines and
calendar imports are excluded.

A serialized application controller reconciles on launch/resume and debounces
committed changes by 600 ms while foregrounded. Its input fingerprint covers
published content, including recurrence, but excludes native event IDs and
updatedAt. Writing ownership does not trigger another update. Edits committed
during a slow native write schedule another reconciliation. There is no
promise of execution while the app is suspended or terminated. Permission is
checked without prompting during automatic runs.

Pausing retains the destination, native events, ownership and last successful
update. Changes remain pending. Changing the destination moves linked events
once while preserving the automatic-update setting, including a pause. Update
now is available while paused and does not enable automation. Resuming immediately reconciles. Configuration and
native operations share a queue, with a stop gate between native writes so
pause or disconnect can stop the remainder of an in-flight automatic run.
An already-started platform call may finish; its assigned ID is still recorded.

Status includes connected/paused/attention/removal pending, linked event count,
last successful update in the app locale, pending changes, progress and recovery
actions. A failed write or unconfirmed removal never advances last success.

Disconnect defaults to keeping events. Events and device-local links remain,
but no updates run; reconnect can reuse those links. The remove option deletes
only recorded native event IDs in their recorded calendars. It never identifies
ownership from event titles, deletes Trayzero Items, or touches unrelated
calendar events. Removal intent is persisted before deletion, and publishing is
stopped. Failed cleanup retains ownership and remains visible and retryable,
including after process death. The user may instead disconnect and keep the
remaining events. A successful disconnect persists an explicit empty connection
so legacy preferences cannot resurrect it.

The old manual setting migrates to a paused connection whenever a destination
was saved. An upgrade never silently enables automatic calendar writes.
Connection settings and ownership remain device-local, outside backups.

Import is separate: users choose a source, preview available events, select
individual events, and choose Inbox or Calendar. Imports are explicitly labeled
one-time copies. Source calendar, event ID and occurrence start scope their
identity. Previously imported events and publishing-owned events are excluded;
imports never round-trip into a duplicate published event. Native read failures
surface as errors rather than an empty list. The legacy #gtd service entry point
remains compatible, but the new UI does not require hashtags.

All new copy lives in the ten supported locale resources. The dialogs scroll
titles, choices and actions together to support compact devices and large text.

## Boundaries

This change does not introduce unrestricted bidirectional synchronization,
conflict resolution, background jobs, calendar creation, editable event duration,
or a new all-day/time distinction in the Item model. Native events retain the
existing one-hour duration. Trayzero remains authoritative for exported fields;
Update now can overwrite external edits. Completion, trashing, moving off
Calendar or clearing the date retains the existing native-event cleanup policy,
including past events; a repeating native series advances to the live instance.
The connection details explain these rules rather than promising the broader
history and external-edit behavior discussed in the concept.

## Validation

Application tests exercise publication, debounce, real database notifications,
no bookkeeping loop, concurrent edits, pause/resume, manual updates while paused,
permission loss, partial write failure, read-only/missing calendars, serialized
pause during an in-flight write, ownership-only removal, retry after restart,
keep/reconnect without duplicates and persistence failure before deletion.
Existing recurrence, switching and deletion ownership tests remain in place.

Widget tests cover intentional permission requests, setup failure/recovery,
writable calendar selection, pause explanations, keep-by-default disconnect,
permission recovery and all ten locales at 3x text on a 320-point-wide screen.
Native provider integration still requires device verification on iOS and
Android, particularly permission revocation and recurring-event updates.
