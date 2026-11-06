# ADR 0010 — Tags, people, and Agendas

- Status: Accepted
- Date: 2026-10-27

## Context

An Item has exactly one Context, the GTD "where or with what" that drives the
Do-tab filter. Users also want labels that cut across lists (`tax-2026`,
`kitchen`, `blog`) and, above all, GTD's **Agendas**: the running list of
things to raise with a specific person or at a standing meeting. Today they
fake both with Contexts (`@Agenda-Alice`), which floods the Do filter, or with
words in the title. The importers (ADR 0008) already meet real tags in every
source and park them in notes because Trayzero has nowhere to put them.

The user's constraint is explicit: tags must be pleasant and must not clutter
the app for people who never use them.

## Decision

### 1. Tags sit beside Contexts; Contexts are unchanged

Two options were weighed:

- **Generalize Contexts into tags** (an Item has many tags, some of which are
  "context" tags). This rewrites every user's data, turns the Do filter from a
  single-choice "where am I?" question into a multi-select, and blurs the GTD
  concept the app teaches.
- **Add tags as a separate, optional, many-to-many label** and keep the single
  Context. Existing data, the Do filter, Process Inbox, quick capture `@`, and
  the importers' context rules are untouched.

We choose the second. A Context answers "can I do this here, now?" and stays
the primary Engage filter. A Tag is free-form metadata the user may never
touch. A person is a Tag with a **person** flag; people get Agendas.

A person tag and a Context may share a name (`@Alice` and `Alice`); they are
different things (`@Alice` is a place to work, the person tag is someone to
talk to) and the app never merges them.

### 2. Model

Schema version 12 becomes 13:

- `tags`: `id`, `name`, `is_person` (default false), `created_at`.
- `item_tags`: `item_id` → `items.id` and `tag_id` → `tags.id`, both
  `ON DELETE CASCADE`, primary key `(item_id, tag_id)`, index on `tag_id`.

The `Item` entity does **not** gain a tag list. Tags are loaded the way
attachment counts are: one app-wide `itemId → tagIds` stream that cards read.
Every existing item query, mapper, and invariant stays as it is, and an
ordinary item save can never clobber tags edited elsewhere (the same lesson as
ADR 0007's focus stamp). Tag writes are targeted and, like focus, do not stamp
`updatedAt`: labelling is organization, not an edit, and must not reorder
lists or count as Project activity.

**Names.** Trimmed, inner whitespace collapsed, leading `+ # @` removed, at
most 40 characters. Uniqueness is case-insensitive (Unicode lowercase,
enforced in the domain and repository; SQLite `NOCASE` is ASCII-only).
Creating a tag whose name exists returns the existing tag.

**Lifecycle.**

- *Rename* to a free name renames in place; a case-only change is allowed.
  Renaming onto another tag's name offers **Merge** instead.
- *Merge* moves every item link to the target (duplicates collapse), deletes
  the source, and the result is a person if either was.
- *Delete* removes the tag and its links; the Items stay. The confirmation
  states how many open Items use it.
- *Done and trashed Items keep their tags* (history; Undo restores them).
- *Recurring rollover* copies the completed Item's tags to its successor in
  the same transaction as the completion.
- Deleting an Item removes its links (cascade, plus an explicit delete so
  Drift streams notice).

### 3. Where tags appear (and where they do not)

| Surface | No tags exist | Tags exist |
|---|---|---|
| Item card | unchanged | up to two compact chips (`label` or `person` icon), then `+N`; nothing when the Item has none |
| Item edit | one small **Add tag** chip under Project | chips with remove buttons plus the **Add tag** chip |
| Process Inbox details | unchanged | an optional *Tags* row; never required, never blocks *File* |
| Do → Next actions filter | unchanged | one **Tag** chip at the end of the context row; tap opens a single-choice sheet |
| Search | unchanged | a query also matches Items whose tag name contains it |
| Review tab | unchanged | an **Agendas** bucket after Waiting For, only while a person tag exists |
| Capture | tip mentions `+tag` | `+tag` chips |
| More → Organization | **Tags & people** row | same |

**Tag picker** (shared, `features/common/tag_picker.dart`). A bottom sheet
with a search field that autofocuses. Typing filters the list; when no tag has
that name, the first row is *Create "name"*, and a second row *Create person
"name"*. Each row toggles membership immediately (the edit screen already
autosaves). People show a person icon. The sheet scrolls and wraps at large
text; rows are 48dp.

**Item edit wireframe.**

```
Project   [ Garage ▾ ]
[label Kitchen ×] [person Alice ×] [+ Add tag]
Dates ...
```

**Do filter.** The context row keeps `All contexts · @phone · @home …`. When
any tag exists one more chip, `⌂ Tag`, follows. Choosing a tag turns that chip
into `⌂ Kitchen` (selected); the sheet's *Any tag* clears it. It combines with
context, time, and energy by AND. Today has no filters (ADR 0007), so it has
no tag filter either.

### 4. Agendas

**Placement.** GTD treats Agendas as a list reviewed alongside Waiting For, and
the Review tab already holds the lists (Calendar, Waiting For, Someday,
Reference). An *Agendas* bucket placed right after Waiting For is therefore the
natural home and adds no tab, no Do segment, and no Settings switch. It exists
only while at least one person tag exists. A Do-tab segment was rejected
(Today/Next actions is the only switch there, and a third segment would crowd
small phones); people can still filter Next actions by a person tag.

**Bucket.** Collapsed: "Agendas · N people". Expanded: one 48dp row per person,
alphabetical, with the open-item count; tapping opens the person's agenda.

**Agenda screen** (`/agenda/:tagId`).

```
← Alice
[ Add something to discuss…            (+) ]
○ Ask about the Q3 budget
○ Return the drill               [label Garage]
Waiting on Alice
○ Signed lease                   ⏳ Waiting on Alice
```

- *Items*: open Items tagged with the person whose status is Inbox, Next
  Action, Waiting For, or Calendar — the actionable lists. Someday and
  Reference are not talking points; Done and Trash are history.
- *Add*: the field creates a Next Action tagged with the person (no Context),
  because the user has already clarified it as "discuss with Alice". The
  field stays focused for the next point.
- *Check off*: tapping the circle completes with the usual Undo snackbar, so a
  conversation can be worked through quickly. The person's own chip is hidden
  on these cards.
- *Waiting on*: Waiting For Items whose `waitingOn` names the person (the
  person's name appears in it as whole words, ignoring case, e.g. "Alice" or
  "Alice (accounting)") and that are not already tagged. Follow-ups belong in
  the conversation. This is matching only — nothing is written. Waiting For
  keeps its free-text field.
- *Empty*: "Nothing to discuss with Alice yet."
- A deleted person (stale link) shows "This person no longer exists."

The bucket count is the size of that same list.

### 5. Managing tags (More → Organization → Tags & people)

A list sorted by name: icon (person or label), name, "N open items". Tapping
a row opens an edit sheet: name, a **Person** switch with "Keeps an agenda of
things to discuss", **Save**, and **Delete**. *New tag* is a FAB. Rename
collisions show "“Kitchen” already exists. Merge “kitchen stuff” into it?".
Empty state: "Tags label items across lists. Mark a tag as a person to keep an
agenda of things to discuss with them. Tip: type +tag when capturing."

### 6. Quick capture: `+tag`

`+word` attaches a tag. `@` and `#` are taken, and `+` is what Todoist users
know for people. It works in every language. Rules:

- A `+` directly after a letter, digit, `+`, `@`, or `#` is text (`C++`); the
  word must start with a letter (`+1`, `+44 20…` stay text).
- The word matches an existing tag ignoring case, spaces, and punctuation
  (`+big-rocks` finds "Big Rocks"). Unlike `@` and `#` there is no prefix
  matching: an unknown word **creates** a tag, so a prefix would be a guess.
- Several tags per capture are allowed; a repeat of a tag already taken stays
  text.
- Chips: "Kitchen" (label icon) or "Alice" (person icon) for an existing tag,
  "New tag: groceries" for a new one, each with *Keep as text*.
- Date words right after `+` are not dates (`+tomorrow` is a tag).
- Siri / *Add to Inbox* stays raw text (ADR 0009).

### 7. Importers (amends ADR 0008)

Tags that do not become the Item's Context now become **tags** instead of a
`Tags:` notes line:

- A tag shaped `agenda: Name` / `agendas/Name` / `agenda-Name` (separators
  `: / - _ .`, case-insensitive) is a **person** tag "Name". This is checked
  before the context rules, so OmniFocus `@tags(Agendas : Alice)` is a person,
  not a Context. No other heuristic marks people: names alone are ambiguous.
- Extra context-looking tags (an Item can hold one Context) become tags
  without their `@`.
- Tags merge case-insensitively with existing tags and within the file.
- The preview lists new and existing tags (and people), like Contexts. The
  "kept in notes" warning is gone.
- **Undo** deletes the Items (their links cascade) and every tag the import
  created that nothing else uses now.

### 8. Backup

Format version 7 becomes 8: a `tags` section (`id`, `name`, `isPerson`) and a
`tagIds` list on each Item. Restore:

- A backup tag whose id exists locally is upserted (renamed if needed).
- A backup tag whose *name* matches a different local tag is mapped onto it
  (merged; person if either is), so restore never creates duplicates.
- An Item carrying `tagIds` gets exactly that set; an unknown id is a format
  error, checked before anything is written. An Item without the field (v1–v7
  backups) keeps its current tags.

The Today widget snapshot and the external queues do not change.

## Edge cases

- *Case-insensitive collision* on create, rename, capture, import, restore:
  always resolves to the existing tag.
- *Deleting a tag in use*: confirmation with the count; Items stay.
- *A person tag is deleted while its agenda is open*: the screen shows the
  not-found message.
- *Merge into a tag the Item already has*: the duplicate link collapses.
- *Tag name that is only a sigil or blank*: rejected (no tag is created).
- *Very long names*: capped at 40 characters; chips ellipsize.
- *Toggling person off*: the bucket drops the row; links stay.
- *Filtering by a tag that is then deleted*: the filter clears itself.

## Self-review

**What does a user who never uses tags see differently?** One *Tags & people*
row in More, one small *Add tag* chip in Item edit, and a capture tip that
mentions `+tag`. Cards, Do, Today, Review, Process Inbox, and Search look
exactly as before. The Do filter row, Process Inbox's Tags row, and the
Agendas bucket appear only once there is something to show.

- *Is a person flag on a tag simpler than a separate People entity?* Yes. One
  table, one picker, one filter; a person is just a tag that also has an
  agenda. A separate entity would duplicate rename/merge/delete and the
  picker.
- *Should agenda items be a special list or status?* No. They are ordinary
  Next Actions (or Waiting, Calendar …) with a person tag, so they also appear
  in Do and can carry a Project. GTD's "Agendas" is a filtered view, which is
  exactly this.
- *Tags on the Item entity?* Rejected: every query and mapper would need a
  join, and stale edit-screen copies could overwrite links.
- *Auto-link `waitingOn` to a person tag?* Rejected as a write: free text
  stays free text. Matching on the agenda screen gives the benefit without a
  migration or a second picker.
- *Multi-select tag filter in Do?* Rejected: one tag at a time answers the
  real question ("what's for Alice / the kitchen?") with one tap.
- *Colors per tag?* Deferred. Neutral chips keep cards calm; Contexts already
  carry color.
- *Maintainability.* Domain rules (`domain/tags.dart`) and the agenda read
  model are pure Dart with unit tests; writes go through `ManageTags` and
  `AddAgendaItem` in `application/`; screens hold only ephemeral state.

## Accessibility and localization

All new copy is in the ten ARB locales. Chips and picker rows are 48dp,
tag chips on cards have semantic labels ("Tag: Kitchen", "Person: Alice"), and
nothing has a fixed height; the Agenda and Tags screens are scrolling lists
tested at large text scale.

## Validation

- Unit tests: tag name normalization and keys, `waitingOn` matching, agenda
  read model, parser `+tag` rules, Engage tag filter, rename/merge/delete,
  rollover tag copy, cascade on Item delete, import tag and person mapping and
  Undo, backup v8 round trip, v7 import, merge-by-name on restore.
- Real v12 → v13 migration test.
- Widget tests: item card chips (and none without tags), tag picker
  create/toggle, Agendas bucket hidden/visible, agenda add and check-off, Tags
  screen rename-merge, Do tag filter chip, capture `+tag` chip with undo,
  large text.
