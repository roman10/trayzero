# ADR 0002 — Riverpod for DI and per-feature controllers

- Status: Accepted
- Date: 2026-05-16

## Context

The app uses Riverpod for dependency injection and state. Two
inconsistencies exist:

- DI wiring is spread across several `providers.dart` files, and
  `app/providers.dart` had become a junk drawer mixing the database
  provider, repository providers, and canonical read-model streams — a
  file nearly every screen imports, creating wide coupling.
- Only 3 of ~16 features (`settings`, `item_edit`, `process`) have a
  controller. Others (`engage`, `review`, `projects`, …) declare ad-hoc
  top-level `StateProvider`s inside screen files and run logic inline in
  `build()`, so the logic is only reachable through widget tests and the
  screens balloon.

## Decision

1. **DI placement follows the layer that owns the dependency:**
   - `data/providers.dart` — database + repository providers.
   - `application/providers.dart` — use-case providers and canonical
     read-model stream providers.
   - `infrastructure/providers.dart` — port → adapter overrides.
   - `app/` wires composition only (overrides at startup), not concrete
     repositories.
2. **Derivation / shared state gets a `<feature>_controller.dart`.**
   Concretely, the following are prohibited in a screen file and must move
   into a controller + a read-model provider:
   - ad-hoc top-level `StateProvider`s declared in a screen file;
   - filtering, grouping, sorting or other derivation performed inside
     `build()`.
   Such logic must be a pure, Riverpod-free function (unit-testable
   without a widget pump) exposed via a read-model `Provider`.
3. **Ephemeral widget-only state stays in the `State` class.** Text editing
   controllers, focus nodes, wizard/page indices, expansion toggles and
   similar transient view state are legitimately widget-local and must NOT
   be promoted to controllers — that adds indirection with no testable
   payoff. A feature whose only state is ephemeral needs no controller.

## Consequences

- The provider dependency graph reflects the layer rules in ADR 0001.
- New features have one obvious state pattern to follow.
- Migration is incremental: providers can be moved file-by-file (re-export
  shims avoid a big-bang import churn); controllers added per feature as
  screens are touched.
- Applied: `engage` (EngageFilterController + applyEngageFilter) and
  `projects` (groupProjects + projectSectionsProvider) — the only screens
  that had the prohibited pattern — were converted with unit tests.
  `review`/`search` were assessed and intentionally left screen-local
  (ephemeral state only); see rule 3.

### Known follow-ups (out of scope here)

Some screens call repositories directly for writes (e.g.
`projects_screen` creating a project, the weekly-review wizard inserting a
review). That is a use-case-extraction concern, not state management, and
is tracked separately from this ADR.
