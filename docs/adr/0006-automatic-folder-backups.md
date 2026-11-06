# ADR 0006 — Automatic backups to a selected folder

- Status: Accepted
- Date: 2026-10-16

## Context

Users want portable JSON backups written automatically to a folder they can
replicate with a tool such as Syncthing. Manual share-sheet export requires
interaction for every backup. Mobile termination callbacks cannot guarantee
that a final export runs.

## Decision

- Add an opt-in Automatic folder backups control under Settings → Data.
  Selecting a folder enables backups and writes the first snapshot. Canceling
  leaves the existing configuration intact. Disabling retains the folder and
  last-success timestamp for later use. Import remains the existing manual flow.
- Observe committed changes to Items, Projects, Contexts, Areas, Attachments,
  and Reviews. Debounce for five seconds, with a one-minute maximum delay while
  edits continue. Try to flush when backgrounded, and compare content on startup
  and resume to recover changes committed before process death. No background
  scheduler, exit guarantee, or always-running service is introduced.
- Reuse the complete portable backup format, including attachment bytes and
  Review history. Compare SHA-256 over portable content with sections sorted by
  id and `exportedAt` excluded. Unchanged data does not create another snapshot;
  Back up now explicitly forces one. Missing attachment files fail the export.
- Serialize configuration and writes. Changes during an export schedule a
  follow-up. Persist configuration as one SharedPreferences value, check save
  results, and preserve the last successful timestamp/fingerprint on failure.
- Android uses a persisted Storage Access Framework tree URI. iOS uses a
  security-scoped folder bookmark and coordinated writes, with a short native
  background task to let an in-flight save finish where possible. Handles are
  opaque and never converted to filesystem paths. Providers must support file
  creation, writing, and renaming. Revoked/stale permissions surface an error
  and can be repaired by choosing the folder again.
- Native adapters write a hidden temporary file and publish it with a unique
  timestamped JSON filename only after the write closes. They prune only after
  publication succeeds, keeping ten completed snapshots from this installation.
  Retention matches an exact filename pattern; unrelated files and other
  installations' histories remain untouched. Cleanup failure is shown separately
  from backup failure because the new complete snapshot already exists.
- Retention ownership uses a random installation identifier stored outside OS
  cloud/device backups, so migrating a phone does not clone another device's
  pruning identity. Filenames also have a random suffix to avoid collisions.
- Localize controls, dates, and error/recovery text in all ten languages. Keep
  system text scaling, show the folder, last success, and Back up now action.

## Consequences

This is backup replication and manual device transfer. It introduces no file
watcher, automatic import, merge policy, or deletion synchronization. Existing
restore semantics still apply: matching ids are updated and omitted rows are
not deleted. Native calendar associations and device preferences remain local.

Folder replication depends on a separate sync tool being able to access the
selected location. iOS availability depends on the installed Files provider.
Choosing a provider does not guarantee its files have reached another device.

## Validation

- Controller tests cover opt-in, cancellation, persistence failure rollback,
  debounce/deadline, startup comparison, disable/background behavior, export and
  folder failures, resume retry, concurrent edits, and cleanup warnings.
- Widget checks exercise selection/disable and all supported languages on a
  320 × 640 surface with 3× text. Existing backup restore tests continue to cover
  complete attachment and Review round trips.
- `integration_test/folder_backup_native_test.dart` exercises the real picker
  and writes twelve snapshots. Run on a disposable emulator/simulator and select
  a dedicated empty folder. Add unrelated and other-device files to that folder
  to confirm they survive and exactly ten current-device JSON files remain.
  Use a retained QA installation (`flutter run` or a manually installed test
  binary) and relaunch the same app to reuse the saved folder after process
  death. Android additionally revokes the grant and checks that a subsequent
  write fails. `flutter test` uninstalls its test app, so it only covers the
  initial selection/publication phase. This test intentionally requires selecting a folder
  on its first run.
- iOS RunnerTests cover coordinated publication, retention ownership, valid
  JSON, newest-snapshot preservation, temporary-file cleanup, and failed writes.
  Real iCloud/third-party providers, permission removal, offline destinations,
  large media backups, and background expiration still need hardware checks
  before a store release.

Implementation verification on 2026-10-16: 811 Dart/widget tests passed; static
analysis reported no issues. Android debug builds and real SAF selection,
publication/retention, retained-app restart, and revoked-grant checks passed on
an isolated API 36 emulator. The iOS simulator app build and native RunnerTests
passed, including coordinated retention and failed-write preservation. The local
Xcode compiler probe needed a temporary output-replay wrapper to avoid a host
pipe deadlock; the wrapper preserved the compiler arguments, output, and exit
status and is not included in the app or repository.

Review follow-up: automatic requests arriving during an active write are coalesced
into a follow-up comparison, so pausing does not drop newer edits. Background
edits during a write also receive a follow-up without relying on foreground
debounce timers. Covered by a lifecycle/write-race regression test.
