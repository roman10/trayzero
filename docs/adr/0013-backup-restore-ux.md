# ADR 0013 — Backup discovery and restore from a backup folder

- Status: Accepted
- Date: 2026-11-04

## Context

ADR 0006 added opt-in automatic backups to a folder the user picks. Two gaps
remain. People do not find the feature (it lives under More → Backup &
restore), and a backup that cannot be restored easily is not much of a
backup: restore meant exporting nothing, finding the JSON file in a document
picker, and choosing it by name. Nothing warned when backups quietly stopped.

The positioning stays "your backup, your cloud". Trayzero writes files to a
folder; a cloud or sync app the user already trusts (iCloud Drive, Google
Drive, Syncthing) carries them between devices. This is backup, not sync, and
the UI says so.

## Decision

- **Restore from backup folder.** A screen lists the Trayzero backup files in
  a folder with date and item count; tapping one shows the existing import
  confirmation and restores through `ImportBackup`, so merge semantics are
  unchanged (matching ids are updated, omitted rows are not deleted). It opens
  on the folder automatic backups already use, or the user picks one.
  Reached from Backup & restore and from onboarding.
- **Native read support instead of the file picker.** The two native adapters
  gained `listSnapshots` and `readSnapshot` beside `writeSnapshot`. Android
  lists children of the persisted SAF tree URI with `DocumentsContract`; iOS
  resolves the security-scoped bookmark and lists/reads under
  `NSFileCoordinator`. This is a small extension of code that already holds the
  folder grant, and it avoids making people hunt for a file by name. The
  `file_picker` single-file restore stays as the manual path. Reads accept only
  names matching `trayzero-(auto|backup)-*.json`; the iOS read refuses path
  separators and non-matching names so a caller cannot escape the folder.
  iCloud Drive placeholders (`.name.icloud`) are listed under their real name
  and downloaded by the coordinated read.
- **Temporary grants.** A folder chosen only to restore from reuses the
  existing picker, which on Android persists a grant. The restore controller
  releases it when the screen closes unless it is the folder automatic backups
  use.
- **Counts are read, not guessed.** Each listed file is read and inspected
  once (newest 30 shown, sequentially, so the list appears immediately and
  counts fill in). Unreadable or non-Trayzero JSON is flagged and not
  tappable.
- **Onboarding.** The first onboarding page has a secondary text action,
  "Coming from another device? Restore a backup", inside the scrollable page
  so large text cannot push Next off screen. A successful restore completes
  onboarding and skips the sample project.
- **One-time enable prompt.** A dismissible card above the Inbox list appears
  once there are at least 20 kept items (not trashed, excluding project
  umbrella rows), no backup folder was ever chosen, and the prompt has not
  been dismissed. Both buttons retire it permanently (`backup_prompt_done_v1`);
  cancelling the folder picker does not, because nothing was decided. 20 items
  rather than "first inbox zero": inbox zero is a rare moment for many
  users, and the store-review prompt already claims it. A count measures
  data worth protecting directly and cannot collide with other prompts.
- **Health.** `evaluateBackupHealth` returns off / ok / failed / stale. Stale
  means no confirmation of an up-to-date snapshot for more than 7 days. To
  avoid false alarms when nothing changed (an unchanged check writes no file),
  an unchanged check records `lastVerified` (at most every 12 hours) alongside
  `lastSuccess`. Failed is the existing in-session failure flag; a failure from
  a previous session surfaces as stale after 7 days because the last attempt
  result is deliberately not persisted. Stale is shown quietly: the More hub
  row subtitle and a dot, and a repair hint on the Backup screen (the Change
  folder row is the repair). The loud error banner stays reserved for an
  actual failure.

## Consequences

- The folder adapters now need read access to the folder, not only write. No
  new Android permission or iOS entitlement is required; the existing grants
  cover it.
- Folder restore does not make backups a sync: two devices writing to one
  folder produce separate snapshot histories, and restoring is an explicit,
  merging, manual action.
- A backup file written by a newer app version is rejected by the shared
  import path with its existing message, shown as unreadable in the list.
- `FolderBackupFiles` gained two methods; test doubles implement them.

## Validation

- Unit: health evaluation and the 7-day boundary, filename timestamp parsing,
  prompt gate, verification recording (including preference failure), folder
  restore controller (ordering, previews, unreadable files, failure and
  recovery, restore merge, temporary grant release).
- Widget: prompt thresholds, dismiss/enable/cancel/persistence, More hub and
  Backup screen stale indicators, onboarding entry and full restore flow,
  configured-folder shortcut, empty and failed folder states. Existing 3x
  German onboarding test covers the new action.
- `RunnerTests.testFolderBackupListsAndReadsOnlyTrayzeroSnapshots` exercises
  the iOS list/read helpers against a temporary directory.
- Needs a device: Android SAF listing and reading on real providers (local
  storage, Google Drive, Syncthing-Fork), iOS security-scoped listing/reading
  on iCloud Drive including not-yet-downloaded placeholders, the Android grant
  release after a restore-only folder choice, and a restore into a fresh
  install from onboarding.
