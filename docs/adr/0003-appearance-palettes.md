# ADR 0003 — Curated app color palettes

- Status: Accepted
- Date: 2026-10-07

## Context

A client requested the ability to change Trayzero's colors. The Flutter UI
already uses one seeded Material 3 theme builder and a separate GTD semantic
color extension. Personalization should work equally on Android and iOS,
preserve workflow meaning, and avoid a growing collection of duplicated themes.

## Decision and implementation plan

1. Offer seven free palettes: Trayzero amber (default), blue, cyan, teal, green, violet,
   and rose. Keep Display mode (System / Light / Dark) independent of the palette.
2. Add an App color sheet under Appearance. Named swatches show the generated
   primary color, selection has a checkmark and accessible selected state,
   and the preview uses the shared task-card widget. Apply and save on tap;
   dismissing or pressing Done keeps the selection. Amber restores the default.
3. Keep stable storage IDs in plain Dart. The application controller owns shared
   appearance state; a core preference port has a SharedPreferences adapter in
   infrastructure. The app root composes dependencies and maps preferences to
   Flutter themes. Preserve `theme_mode`, add `app_palette`, and fall back to
   System / amber for missing, unknown, or incorrectly typed values.
4. Load preferences before the first Flutter frame. Order writes, preserve the
   latest selection during rapid taps, and roll back a failed save independently
   of the other appearance field. Changes must preserve navigation and drafts.
5. Retain GTD category hues and context color identity. Correct custom chip and
   workflow foregrounds against their actual alpha-composited backgrounds.
   Use at least 4.5:1 for small text and 3:1 for meaningful icons. Fix the Waiting
   on chip to use the GTD waiting role instead of the theme tertiary role.
6. Keep native home-screen widgets amber. Launcher and launch appearance are
   extended by ADR 0005.
   Explain the widget scope in the picker. Preferences remain device-local and
   outside the task backup format, consistent with existing appearance settings.
7. Validate storage compatibility, write ordering/failures, all seven palettes in
   light/dark, custom chip contrast, translated/large-text picker layouts,
   accessible controls, immediate updates, and navigation/draft preservation.
   Review the diff and resolve high-confidence issues before committing.

## Consequences

- One builder defines component styling for every palette; no new package or
  database migration is needed.
- The palette controls interface accents and surface tints. Category colors
  retain their meaning; readable foreground tones may adjust to the surface.
- The default seeded theme remains unchanged. Some previously low-contrast
  custom chip foregrounds are corrected, including in the default palette.
- System follows device brightness, not wallpaper-derived colors.
- Arbitrary colors, per-category editors, matching native widgets, and supporter
  palette packs remain separate future decisions. No speculative infrastructure
  for those features is added now.

Native icon selection and notification accents are extended by
[ADR 0005](0005-native-icon-appearance.md).
