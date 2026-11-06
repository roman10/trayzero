# ADR 0004 — Interactive and resumable Weekly Review

- Status: Accepted
- Date: 2026-10-13

## Context

The seven-step Weekly Review displayed instructions without the lists or
actions needed to follow them. Leaving lost the current step, and Projects
could be reviewed only by exiting the wizard.

## Decision

Keep the seven steps and put live canonical lists inside them. Capture creates
Inbox Items; Inbox processing, Item editing, and Project detail open above the
Review and return to it. Next Actions include future deferred work. Calendar
Review includes missed commitments and today through the next 14 days.

Start or resume the latest incomplete weekly Review in a database transaction.
Persist the destination step before displaying it. Leaving never completes a
Review; Finish stamps the same row once. Store stable enum names rather than
step indices. Database v11 adds `current_step` with a `capture` default; backup
v6 includes it and older backups default to Capture.

Use the shared domain Project movement policy. Stalled active Projects appear
first and offer Add next action, On hold, and Done. Waiting or scheduled work
counts as movement. Status updates change only status and timestamp; they
cannot overwrite the outcome or recreate a deleted Project.

Keep persistence and mutations in application use cases and repositories.
The feature controller derives review lists and owns persisted navigation.
Show load/write failures, keep the current step on failed navigation, and retain
next-action dialog text on failed creation so users can retry.

## Validation

Cover real schema migration and reopening, backup round trips and old backups,
overlapping starts, canonical filtering, and Project movement. Exercise the
router-backed capture/process/edit/repair/resume/finish flow in widget tests,
including failed saves, Undo after leaving, and a narrow layout with large text.
