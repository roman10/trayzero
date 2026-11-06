# Trayzero

A free, private, **local-first** task manager that follows David Allen's
**Getting Things Done (GTD)** method end to end — Capture → Clarify → Organize →
Reflect → Engage. Your tasks live on your device, with no Trayzero account or ads.

- **Website:** <https://trayzero.app>
- **App Store (iOS):** <https://apps.apple.com/app/id6771756447>
- **Google Play (Android):** search "Trayzero" (package `app.cleartray`)
- **Video tutorials:** [Trayzero on YouTube](https://www.youtube.com/@trayzeroapp)
- **Privacy policy:** <https://trayzero.app/privacy>

Built with Flutter, so one codebase ships to both iOS and Android. (App store
identifiers and the package id are `app.cleartray` for historical reasons — the
app was renamed from "Cleartray" to "Trayzero".)

## Features

- **Capture** — floating capture button on every screen, share-sheet intake from
  any app, voice-to-text, and a home-screen widget for one-tap "add to inbox".
  **Add & continue** saves one Item, clears its title and notes, and returns
  focus to the next capture. **Add to inbox** saves and closes the sheet.
  A saved-item count confirms additions; closing the sheet keeps saved Items.
- **Clarify** — a card-stack *Process Inbox* flow that walks each item through
  the full GTD decision tree (actionable? two-minute rule? delegate? project?).
- **Organize** — the canonical lists (Inbox, Next Actions, Projects, Waiting For,
  Someday/Maybe, Calendar, Reference), real Projects with status + next-action
  warnings, extensible `@`-contexts, and Areas of Responsibility.
- **Reflect** — an interactive, resumable Weekly Review with live lists, Inbox
  processing, Item editing/completion, and stalled-Project repair.
- **Engage** — filter next actions by context, energy, and time available.
- **Reminders** — local notifications with action buttons (Done / Snooze / Move
  to Next Actions) that survive reboots; opt-in two-way system-calendar sync.
- **Attachments** — photos and voice memos on any item.
- **Privacy** — tasks are stored locally in SQLite. Standard builds use
  RevenueCat for purchase checks and purchase analytics. Crash reporting is off
  by default and requires a configured Sentry DSN. Portable JSON backups include
  attachments and Review history. Older JSON backups remain supported.
  Restore validates before writing, merges by id, and refreshes reminders.
  Appearance preferences and native calendar associations stay on the device.
- **Import from other apps** — Settings → Data → Import from another app.
  Todoist CSV/ZIP, TickTick CSV, Nirvana CSV/JSON, OmniFocus TaskPaper,
  Google Tasks Takeout JSON, [Things 3 exports](docs/things-import.md), and
  plain text are supported. On iOS, Apple Reminders imports selected lists
  directly from the device with preview and Undo. This copies open reminders;
  the source stays unchanged. Apple tags, flags, attachments and subtask
  structure are not copied. See [the mapping and limits](docs/adr/0011-apple-reminders-import.md).
- **Automatic backups** — opt in to save portable JSON snapshots to a selected
  folder after changes, keeping the latest ten backups from this device. Shows
  the last successful save and supports Back up now. A separate folder-sync tool
  can replicate the files; importing on another device remains manual. Mobile
  termination can interrupt a save, so startup/resume retries missed changes.

## Import from Microsoft To Do

Settings → Data → Import from another app → Microsoft To Do offers a one-time,
read-only import with preview and Undo. Lists, open tasks, checklist steps,
notes, categories and dates are mapped into the existing GTD lists. Completed
work is skipped; recurrence is retained in notes. Repeating an import can
create duplicate tasks. Microsoft credentials/tokens are not stored.

The Trayzero Microsoft Entra public client ID is included in normal builds.
Override it with `--dart-define=MICROSOFT_TODO_CLIENT_ID=<public-client-id>`;
an explicitly empty value disables this importer. See
[setup and mapping](docs/adr/0012-microsoft-todo-import.md).

## Tech stack

- **Flutter 3.44.0** (Dart `^3.11.4`)
- **Riverpod** for state management + DI
- **Drift** over SQLite for local persistence
- **go_router** for navigation
- **flutter_local_notifications**, **device_calendar**, **speech_to_text**,
  **home_widget**, **purchases_flutter** (RevenueCat) for platform features

## Getting started

```bash
# 1. Install Flutter 3.44.0 (https://docs.flutter.dev/get-started/install), then:
flutter pub get --enforce-lockfile

# 2. Run code generation (Drift database + Riverpod providers).
#    Required before the first run and after touching generated code.
dart run build_runner build --delete-conflicting-outputs

# 3. Run on a connected device or simulator.
flutter run
```

In-app purchases (voluntary tips + a "supporter" subscription) are wired through
RevenueCat with **public** SDK keys baked in as defaults, so a plain
`flutter run`/`flutter build` works with billing enabled. If the keys are
overridden with empty values, the app falls back to a disabled billing gateway
and runs identically with the Support section showing "unavailable" — nothing
touches the stores.

### Platform builds

- Android debug APK — `flutter build apk --debug`.
- iOS simulator build — `flutter build ios --simulator --debug`. Device
  builds require your own signing team and an App Group for the extensions.
  See [iOS extensions](ios/EXTENSIONS.md).
- FOSS Android APK — `bash tool/build_foss_apk.sh`. This build omits the
  RevenueCat and Google Play in-app review SDKs.

If Xcode 27.2 reports a Flutter framework architecture error on Apple silicon,
build for arm64 after generating the simulator configuration and installing pods:

```bash
flutter build ios --simulator --debug --config-only
(cd ios && pod install)
xcodebuild -workspace ios/Runner.xcworkspace -scheme Runner -configuration Debug \
  -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' \
  ARCHS=arm64 CODE_SIGNING_ALLOWED=NO
```

## Testing

The [import fixtures](test/fixtures/import/README.md) document the sample data.

```bash
flutter test --concurrency=1  # unit + widget tests
flutter analyze         # static analysis + custom lints
```

Tests mirror the layer they cover (`test/domain`, `test/data`,
`test/application`, `test/widget`, `test/integration`).

Device-level checks live in `integration_test/`. For example, run
`flutter test integration_test/folder_backup_native_test.dart -d <device-id>`
on Android or iOS. To test Android reminders with R8 enabled, run
`bash tool/ci_android_native.sh emulator-5554` with only a disposable Android
emulator connected. On macOS, `bash tool/ci_ios_native.sh` creates an isolated
simulator for the iOS native checks.

## Project structure

Strict layered architecture — dependencies point inward only
(`features`/`app` → `application` → `data` → `domain`; platform code sits behind
`core` ports implemented in `infrastructure`). The domain layer is pure Dart with
no Flutter imports.

See [`CONTEXT.md`](CONTEXT.md) for the domain language, layer rules, and
conventions — read it before contributing.

## Contributing

UI labels live in the ARB files for all ten supported languages. Recurrence
summaries, item-card metadata, and dates use the shared presentation formatters
in `features/common/`; domain recurrence rules retain their pure Dart date math.
Use complete ICU phrases for plural counts and word order, and format dates in
the app's selected language. After editing translations, run `flutter gen-l10n`
and commit its generated files. The localization tests exercise recurrence
controls and populated item cards on a compact phone at 3x text.

Issues and pull requests are welcome. Before opening a PR:

- Read [`CONTEXT.md`](CONTEXT.md) and keep the layer rules intact.
- Run `flutter analyze` and `flutter test` — both must pass.
- Match the surrounding code style; keep changes focused.

## License

Copyright © 2026 Liu Feipeng.

Trayzero is free software licensed under the **GNU General Public License v3.0**
(GPLv3) — see the [`LICENSE`](LICENSE) file. In short: you may use, study, share,
and modify the code, but any distributed derivative must also be released under
the GPLv3.

Outside contributions are accepted under the Developer Certificate of Origin
(sign commits with `git commit -s`).

## Trademark / attribution

Trayzero is an independent app inspired by the *Getting Things Done* methodology.
It is **not** affiliated with, endorsed by, or sponsored by the David Allen
Company. "Getting Things Done" and "GTD" are trademarks of the David Allen
Company.
