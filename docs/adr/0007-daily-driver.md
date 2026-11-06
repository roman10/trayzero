# ADR 0007 — Daily driver: Today focus, quick-capture parsing, project review, review prompt

- Status: Accepted
- Date: 2026-10-26

## Context

Trayzero covers the full GTD loop, but daily use still has friction:
the Do tab is a flat Next Actions list with no way to commit to a short list
for today; capture accepts only a plain title, so context, project, and dates
are re-entered during Clarify; the Weekly Review flags Projects without a next
action but not Projects that have quietly stopped moving; and nothing asks
happy users for a store rating. This release addresses those four gaps without
adding a navigation destination or a paid gate.

## Decision

### 1. Today focus and the daily plan

**Model.** `items.focused_at` (nullable timestamp, schema v12) records when an
Item was committed to today. An Item is *in Today* when `focused_at` falls on
the current local day. When `focused_at` falls on an earlier day, the Item is
*carried over*: it is still visible, never silently dropped, and awaits a
decision. Midnight rollover therefore needs no background job; the existing
`currentTimeProvider` midnight tick moves today's focus to carry-over.

Only Next Actions (including Project actions and deferred ones), Waiting For,
and Calendar Items can be focused. The persistence invariant
(`enforceItemInvariants`) clears focus when an Item moves to Inbox, Someday,
Reference, Trash, or becomes a Project row. Done keeps its stamp so Undo
restores focus and Today can count "done today". A recurrence successor is a
new commitment and is not focused. Focus writes are targeted column updates
that do not stamp `updatedAt` or touch reminders. Focus is daily planning
state, not an edit.

**Placement.** The Do tab gains a two-segment switch: *Today* and *Next
actions*. The bottom navigation stays at five tabs. *Next actions* is
unchanged except for a star on each card. The same star appears wherever
focusable Items are listed: Project detail and the Review tab's Waiting For and
Calendar lists (starring a future Calendar Item is still meaningful). Calendar
Items due today or overdue, shown in the Do tab's Calendar band, carry no star:
they are on Today by definition. The switch keeps each label on
one line and scrolls sideways at large text sizes instead of wrapping. The last selected segment is
remembered on the device, and the default is *Next actions*, so existing users
and users who never plan see no change. *Today* shows:

1. a "Plan your day" card until today's plan is done. While carry-over
   remains, the card also says "N from earlier need a decision" (there is no
   separate banner, since Start my day resolves both). Band Items are not
   counted as carry-over;
2. the Calendar band (the hard landscape: Calendar Items due today or
   overdue), headed by one line with a count. GTD puts the calendar first,
   and these items are part of today by definition, so they have no star;
3. the focused Items, with complete, star, and open actions, plus a
   "N done today" line. The count also includes Calendar Items due today and
   completed today, even if never focused, without double-counting. Calendar
   Items are recognised by `previousStatus` (completion overwrites the status),
   so a completed Waiting follow-up with a due date is not counted.

Context, energy, and time filters stay on *Next actions*. A short list does
not need them. The empty state says "Nothing focused yet" and offers *Plan
today*.

**Daily plan (`/today/plan`, about two minutes).** This is one scrolling
screen, not a wizard. It has these sections:

1. *From earlier*: carry-over Items, each with a star; *Keep all*.
2. *Calendar*: Calendar Items due today or overdue, read-only with an "On
   Today" label and no star. Tapping opens the Item. They are not counted in
   the focused total and never appear under *From earlier*.
3. *Waiting follow-ups*: Waiting Items whose follow-up date (defer, else due)
   is today or earlier.
4. *Available from today*: Next Actions whose defer date is today and has
   passed.
5. *Next actions*: every other available Next Action.

Stars write immediately, so leaving without finishing loses nothing. The
carry-over set is captured when the screen opens, so rows do not jump while
the user taps them. *Start my day* clears focus from carry-over Items that were
not kept and records a completed `Reviews` row of type `daily`. That type
already exists, so the table does not change. A snackbar offers Undo, which
restores the cleared focus. The plan screen says "Items you don't keep go back
to their lists" before the user commits.

A daily-review reminder notification was considered and deferred. The
existing review and backup reminders hard-code English copy and support only
weekly repeats. Adding a daily repeat, routing, a Settings toggle, and re-arm
logic for an off-by-default nudge is not the simplest version of this release.

### 2. Natural-language quick capture

`domain/quick_capture_parser.dart` is pure Dart with no I/O. It recognizes:

- `@word`: an existing Context. The match ignores case and a leading `@`.
  An exact match wins; otherwise it requires a unique prefix.
- `#word`: an existing active Project. Matching ignores case, spaces, and
  punctuation. An exact match wins; otherwise it requires a unique prefix of
  at least two characters, else a unique word start of at least three
  (`#garage` finds "Clean the garage").
- English dates:
  - `today`, `tonight`, `tomorrow`, `tmrw`, and `tmr`;
  - full weekday names, with optional `this` or `next`;
  - `next week`, `next month`, `this weekend`, and `weekend`;
  - `in N days`, `in N weeks`, `in N months`, and `in a week`;
  - month-name dates such as `Oct 28`, `28 October`, and `oct 28th, 2027`;
  - ISO dates such as `2026-10-28`.

An optional leading `on` is consumed with the date.

A date is a **start (defer) date by default**. This follows GTD: most dates
mean "not before", and the hard landscape is reserved for real deadlines. Use
`due <date>`, `by <date>`, or a trailing `!` (for example, `friday!`) to mark a
**due date**. The parser applies the first recognized token of each kind.
Later tokens of the same kind stay as text. If removing the tokens would leave
an empty title, the parser recognizes nothing.

Captured Items **still land in the Inbox**. Capture is not Clarify: the user
has not yet decided whether the Item is actionable, takes less than two
minutes, or is a Project. The parsed fields are saved on the Inbox Item and
pre-fill Clarify:

- Process Inbox preselects the parsed Context and Project.
- The Defer step offers "Use start date <date>" or "Use due date <date>" as a
  one-tap choice.
- *Do it ASAP* clears a captured start date.

Captured dates arm reminders through the normal reconciliation, just as the
launch re-arm already would. A captured due date has no time, so it lands at
the "Deferred items remind me at" hour rather than midnight. Item cards show a
"Starts <date>" chip for any future start date, so a dated Inbox Item is never
silently dated.

**Never surprise.** The title field highlights recognized spans while the user
types. A chip row below the field states each interpretation, such as
"Starts Tue, Oct 28", "Due Fri, Oct 31", "@phone", or "Project: Garage". Each
chip has a delete action, "Keep as text", that puts the words back into the
saved title and keeps them unrecognized while the user continues typing.

**Locales.** Date keywords are English-only and active only when the app
language is English. `@` and `#` work in every language because they use
language-neutral sigils and match only existing names. A non-English title is
never changed unless it contains such a sigil.

### 3. Per-project review in the Weekly Review

`projects.last_reviewed_at` (nullable, v12) records review. The Projects step
of the Weekly Review flags two conditions:

- **No next action.** This uses the existing movement policy, under which
  Waiting and Calendar work count as movement.
- **No activity in 14 days.** An active Project is flagged when no Item linked
  to it has been created, edited, or completed in the last 14 days. Activity
  is the latest `updatedAt` across the Project's Items, or the Project's
  creation date if it has no Items.

Flagged Projects sort first: stalled, then inactive, then the rest. The sort
does not depend on review state, so cards do not jump when the user marks one.
Each card shows "Last reviewed <date>" or "Not reviewed yet" and a *Mark
reviewed* button. After the user taps the button, the card shows "Reviewed"
for the rest of the session, because `last_reviewed_at` is now at or after the
session's start. A header shows "Reviewed X of Y". Marking a Project reviewed
does not stamp `updatedAt`, so the Projects list order is unchanged. The
release has no per-project cadence and no threshold setting.

### 4. In-app review prompt

The `core` port `AppReviewPrompter` has a no-op default. Its infrastructure
adapter wraps `in_app_review`. On Android, that plugin depends on Google Play
Core (`com.google.android.play:review`), which F-Droid rejects. The FOSS
transform (`tool/foss/strip.sh`) therefore handles it the same way as
RevenueCat:

- It removes the `in_app_review:` dependency.
- It replaces the adapter with an inert stub.

`build_foss_apk.sh` backs up and restores the adapter and checks that the
built APK contains no Play Core review classes.

`shouldPromptForReview` is a pure policy. A prompt is allowed only when all of
these are true:

- at least 5 app launches have been recorded;
- at least 7 days have passed since the first recorded launch;
- at least 120 days have passed since the previous prompt;
- fewer than 3 prompts have been shown in total;
- the platform reports that review is available.

Prompts follow a meaningful success:

- finishing a Weekly Review;
- reaching Inbox Zero after processing at least 5 Items in one session.

State is stored in SharedPreferences behind a `ReviewPromptStore` port. The OS
applies its own quotas on top of this policy.

## Data and backup

Schema version 11 becomes 12. Version 12 adds `items.focused_at` and
`projects.last_reviewed_at` with `addColumn`, so existing rows read as null.
Backup format version 6 becomes 7, and version 7 exports both fields. Older
backups import with both fields null. Daily plans are ordinary `Reviews`
rows, which are already in the backup.

## Self-review

- *New Today tab?* Rejected. Today is part of Engage, and a sixth tab would
  crowd small phones and translated labels.
- *Boolean star that persists until cleared?* Rejected. Stale stars rot into
  a second Next Actions list. A day-stamped focus expires on its own, and the
  carry-over banner makes sure nothing disappears silently.
- *Auto-include deferred-to-today Items in Today?* Rejected. GTD defer means
  "not before", not "do today". Today holds only Items the user committed to,
  plus the hard landscape. Newly available Items appear as plan suggestions.
- *Route parsed captures directly to Next Actions?* Rejected. That would skip
  Clarify. Pre-filling Clarify saves the same typing and keeps the Inbox
  trustworthy.
- *Default dates to due?* Rejected. That would push discretionary work onto
  the hard landscape and create false urgency.
- *Default the Do tab to Today?* Rejected for now. It would change existing
  users' landing view, and users who never plan would land on an empty screen.

## Accessibility and localization

- Stars, chips, and plan rows have 48dp targets and localized tooltips or
  semantics, such as "Add to Today" and "Remove from Today". Plan rows expose
  toggled state.
- Layouts wrap at large text sizes; nothing sets a fixed height.
- All new copy is in the ten ARB locales. Date chips use the selected app
  locale's date format.

## Validation

- Unit tests cover:
  - the parser: keywords, ranges, `due`/`by`/`!`, the empty-title guard,
    dismissed tokens, prefix and ambiguity rules, and non-English no-op;
  - focus logic and its invariant;
  - the Today and plan read models;
  - stalled and inactive detection;
  - the review-prompt policy and use case.
- The real v11 → v12 migration is tested, along with backup v7 round trips
  and v6 import.
- Widget tests cover the Today segment, the plan screen, capture chips with
  undo, and the review project card.

Review follow-up: ordinary saves (`ItemRepository.upsert`,
`ProjectRepository.upsert`) no longer write `focused_at` or
`last_reviewed_at` to an existing row, so an edit screen's stale copy cannot
undo a star or review mark made elsewhere meanwhile. Only `setFocusedAt` and
`markReviewed` write them; the focus invariant still clears focus when an edit
moves an Item to a status that cannot hold it, and backup restore
(`upsertAll`) still writes both. The capture date chip decides whether to show
the year from the app clock rather than the system clock.
