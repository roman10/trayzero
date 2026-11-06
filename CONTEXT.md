# Context

Trayzero — a GTD (Getting Things Done) productivity app. Flutter + Riverpod,
local-first (Drift/SQLite), with native calendar mirroring and notifications.
(App store identifier and package id remain `app.cleartray`.)

## Product name and compatibility

Use **Trayzero** (one word, capital T) in visible copy, exported filenames,
store listings, and documentation. The name was changed from Cleartray on
2026-05-29.

Keep the established identifiers unchanged: `app.cleartray` and its extension
bundle IDs, `group.app.cleartray`, `cleartray://` deep links, native widget
provider names and kinds, notification IDs, the `cleartray.sqlite` database
filename, and the internal Dart package `cleartray`. Existing installs,
widgets, reminders, links, and stored data depend on these identifiers.

## Domain language

Use these terms exactly; they match the code.

- **Item** — the universal capture entity. Everything the user records starts
  as an Item in the inbox and is moved to a canonical list during Clarify.
- **ItemStatus** — where an Item lives: `inbox`, `nextAction`, `project`,
  `waiting`, `someday`, `reference`, `calendar`, `done`, `trashed`.
  `project` is an umbrella row representing the Project itself; real Project
  metadata lives on the **Project** entity, and next-actions link to it via
  `Item.projectId`.
- **Project** — a multi-step outcome. **ProjectStatus**: `active`, `onHold`,
  `someday`, `done`, `dropped`.
- **GtdContext** — the "@context" an action can be done in (e.g. @home).
- **Area** — an Area of Responsibility grouping projects/items.
- **Review** — a reflection session. **ReviewType**: `daily`, `weekly`.
  A Weekly Review stores a stable **WeeklyReviewStep** (`capture`, `inbox`,
  `actions`, `waiting`, `projects`, `calendar`, `someday`). Leaving preserves
  the incomplete session; only Finish sets `completedAt`. Review includes
  deferred Next Actions, and Projects with waiting or scheduled work count
  as moving; only active Projects without movement need repair.
- **Attachment** — a file/link attached to an Item.
- **Recurrence / RecurrenceRule / RecurrencePolicy** — repeating actions.
  `Recurrence` is the cadence (`daily`/`weekly`/`monthly`/`yearly`); the rule
  carries interval, end condition (until date / count), and structured
  patterns (by-weekday, monthly Nth-weekday). On completion a recurring Item
  is cloned with shifted dates by the policy.
- **Energy** — `low` / `medium` / `high`, for filtering "what can I do now".

The five GTD steps structure the UX: **Capture → Clarify → Organize →
Reflect → Engage**.

## Architecture & layer rules

Strict layered (Clean-ish) architecture. Dependencies point **inward only**:

```
features ─┐
          ├─► application ─► data ─► domain
app ──────┘                    ▲
core  ◄─ (ports) ◄─ infrastructure
```

- **`domain/`** — entities + recurrence logic. Pure Dart. **No Flutter, no
  imports from any other layer.**
- **`data/`** — Drift database, repositories, mappers. Depends on `domain`
  (+ `core` ports). Owns persistence; exposes repositories.
- **`application/`** — use-case classes (one verb each: `capture_item`,
  `complete_item`, …) and their Riverpod providers. Depends on `domain`,
  `data`, `core`. **Must not import from `features/`.**
- **`infrastructure/`** — device adapters that implement `core` ports
  (calendar gateway, notification scheduler, id generator, time zone).
- **`core/`** — cross-cutting ports/abstractions (`Clock`, `IdGenerator`,
  `Result`, `CalendarGateway`, `NotificationScheduler`). No layer deps.
- **`features/`** — UI: one folder per feature, each a screen plus a
  controller for non-trivial state. Depends on `application`, `domain`, and
  app-level providers. **A feature must not import another feature** (shared
  UI goes in `features/common/`); shared services belong in `application/`.
- **`app/`** — composition root: router, theme, app widget, provider wiring.

### Hard rules (enforced by review; see ADR-0001)

1. No layer imports a layer "outward" of it.
2. `application/` never imports `features/`.
3. No `features/<a>` imports `features/<b>` (use `features/common/` or lift
   the logic into `application/`).
4. Anything device/platform-specific is a `core` port + `infrastructure`
   implementation, injected via Riverpod — never called directly from UI or
   application code.

## Conventions

- User-visible UI copy belongs in the ARB localization files, including enum
  labels and dates formatted for the selected app language. Keep domain enums
  independent of Flutter; map them to localized labels in presentation code.
- Preserve the system text scaler. Use wrapping and scrolling rather than a
  global font-size cap. Check core flows on a compact phone at 2x–3x text,
  including translated copy and forms with the keyboard open.
- State management: Riverpod. No ad-hoc top-level `StateProvider`s in
  screen files and no filtering/grouping/sorting in `build()` — that
  derivation moves into a `<feature>_controller.dart` as a pure function
  exposed via a read-model provider. Ephemeral widget-only state (text
  controllers, wizard indices, toggles) stays in the `State` class. See
  ADR-0002.
- One use-case = one file = one class in `application/`.
- Tests mirror the layer (`test/domain`, `test/data`, `test/application`,
  `test/widget`, `test/integration`).
