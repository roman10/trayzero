# Trayzero

A free, private, **local-first** task manager that follows David Allen's
**Getting Things Done (GTD)** method end to end — Capture → Clarify → Organize →
Reflect → Engage. No account, no servers, no ads. Your data lives on your device.

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
- **Clarify** — a card-stack *Process Inbox* flow that walks each item through
  the full GTD decision tree (actionable? two-minute rule? delegate? project?).
- **Organize** — the canonical lists (Inbox, Next Actions, Projects, Waiting For,
  Someday/Maybe, Calendar, Reference), real Projects with status + next-action
  warnings, extensible `@`-contexts, and Areas of Responsibility.
- **Reflect** — a guided Weekly Review wizard (and daily review).
- **Engage** — filter next actions by context, energy, and time available.
- **Reminders** — local notifications with action buttons (Done / Snooze / Move
  to Next Actions) that survive reboots; opt-in two-way system-calendar sync.
- **Attachments** — photos and voice memos on any item.
- **Privacy** — 100% on-device (SQLite). No account, no analytics. Crash
  reporting is opt-in and off by default. JSON backup/restore — you own your data.

## Tech stack

- **Flutter** (Dart `^3.11.4`, Flutter `>=3.24`)
- **Riverpod** for state management + DI
- **Drift** over SQLite for local persistence
- **go_router** for navigation
- **flutter_local_notifications**, **device_calendar**, **speech_to_text**,
  **home_widget**, **purchases_flutter** (RevenueCat) for platform features

## Getting started

```bash
# 1. Install Flutter (https://docs.flutter.dev/get-started/install), then:
flutter pub get

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

## Testing

```bash
flutter test            # unit + widget tests
flutter analyze         # static analysis + custom lints
```

Tests mirror the layer they cover (`test/domain`, `test/data`,
`test/application`, `test/widget`, `test/integration`).

## Project structure

Strict layered architecture — dependencies point inward only
(`features`/`app` → `application` → `data` → `domain`; platform code sits behind
`core` ports implemented in `infrastructure`). The domain layer is pure Dart with
no Flutter imports.

See [`CONTEXT.md`](CONTEXT.md) for the domain language, layer rules, and
conventions — read it before contributing.

## Contributing

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
