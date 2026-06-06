# ADR 0001 — Layered architecture with inward-only dependencies

- Status: Accepted
- Date: 2026-05-16

## Context

The codebase already follows a layered structure (`domain`, `data`,
`application`, `infrastructure`, `core`, `features`, `app`) but the rules
were implicit and undocumented. One real violation had crept in:

- `application/export_backup.dart`, `import_backup.dart`, and
  `application/providers.dart` imported
  `features/settings/backup_service.dart` (application → features).

Separately, `calendar_sync_service` lived under `features/calendar_sync/`.
It is not a UI concern — it orchestrates repositories over a `core`
calendar-gateway port — so it belongs in `application/` even though no
illegal import existed (it was consumed only by its own feature screen).

Without a written rule, such drift keeps recurring and the layering — the
main thing keeping the app testable and navigable — erodes.

## Decision

Adopt and enforce the dependency rules documented in `CONTEXT.md`:

1. Dependencies point inward only:
   `features`/`app` → `application` → `data` → `domain`; `infrastructure`
   implements `core` ports; `core` has no layer dependencies.
2. `application/` must never import `features/`.
3. No feature imports another feature — shared UI lives in
   `features/common/`, shared services in `application/`/`infrastructure/`.
4. Platform/device access goes through a `core` port with an
   `infrastructure` implementation, injected via Riverpod.

The misplaced services are relocated out of `features/` into `application/`
(`backup_service`, `calendar_sync_service`), correcting the one real
violation and aligning the "services live in `application/`" convention.

## Consequences

- `domain` and `application` stay unit-testable without Flutter.
- Cross-feature reuse forces an explicit home (common/ or application/),
  preventing tangled feature graphs.
- A future import-boundary lint (e.g. `import_lint`) can mechanically
  enforce rules 1–3; until then they are checked in code review.
