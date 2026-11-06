# ADR 0009 — Capture from anywhere and the interactive Today widget

- Status: Accepted
- Date: 2026-10-26

## Context

Capture is supposed to take under a second from anywhere (plan §1). Today the
only system entry points are the Inbox widget and the share sheet. ADR 0007
added Today focus, but the list is only visible inside the app. This ADR adds
system capture entry points on both platforms and a home-screen widget for
Today's focused Items.

Two constraints shape the design:

- The Drift database lives in the app sandbox, not in the App Group.
  Extensions and background entry points cannot write it safely.
- Mutations must run through the existing use cases (`CompleteItem`,
  `CaptureItem`) so recurrence rollover, reminder teardown, and invariants
  stay in one place.

## Decision

### 1. Entry points

| Surface | Android | iOS |
|---|---|---|
| Quick capture | Quick Settings tile "Capture to Trayzero"; launcher shortcut *Capture* | App Intent *Open Quick Capture*; Control Center control (iOS 18) |
| Capture without opening the app | — (the tile opens the sheet in under a second) | App Intent *Add to Inbox* with a text parameter, from Siri, Shortcuts, Spotlight, or the Action button |
| Today | Launcher shortcut *Today*; Today widget | App Intent *Show Today*; Today widget (iOS 17) |
| Process | Launcher shortcut *Process inbox* | — (Shortcuts can open the app) |

`AppShortcutsProvider` registers the three intents so their phrases appear
in Shortcuts and Spotlight without setup. Phrases include the app name, as
Siri requires.

Android launcher shortcuts are **dynamic** and published from `MainActivity`
at launch. Static `shortcuts.xml` entries were rejected for two reasons: the
debug build's `.debug` application id would need a hard-coded target
package, and static shortcuts launch with `CLEAR_TASK`, which would destroy
the running Flutter engine. Dynamic shortcuts attach to the current launcher
entry (ADR 0005 icon aliases). Shortcuts are republished after an icon
change, and their labels follow the system language.

### 2. One link funnel

Every entry point resolves to a `cleartray://` link:

- `capture`
- `inbox`
- `today`
- `plan`
- `process`
- `item?id=<id>`

The links reach Dart through one `HomeWidgetBridge.widgetTaps` stream.
`app/app_links.dart` maps each link to a router location with the existing
`openDeepLink` anchoring. `today`, `plan`, and Today widget rows are anchored
on the Do tab with the Today view selected. Closing the plan or an Item
therefore returns to Today, not the Inbox. Unknown links open the Inbox, as
before.

- **Android.** Launches use home_widget's launch action. It already
  preserves the cold-start intent (`99b31dc`). Tile, shortcut, and widget
  `PendingIntent`s target `MainActivity` directly. Its empty task affinity
  makes Android reuse the existing task, and `singleTop` delivers
  `onNewIntent` rather than starting a second engine. `MainActivity` also
  converts external `VIEW cleartray://…` intents to the launch action, so
  typed or pasted links still work.
- **iOS.** `SceneDelegate` claims `cleartray://` URLs, both at scene
  connection (cold start) and in `openURLContexts` (warm start). It passes
  them to `LaunchLinkRelay`, which holds a link until Dart asks for it over
  `app.cleartray/launch_link`, then pushes later links directly. App Intents
  that open the app write `pending_launch_url` to the App Group and post an
  in-process notification. The relay picks up the link whether the intent ran
  in the app process or in the widget extension (the control). Dart also
  asks again on every resume.
- **Flutter's built-in deep linking is disabled** on both platforms
  (`flutter_deeplinking_enabled` / `FlutterDeepLinkingEnabled`). With it on,
  the engine pushed `cleartray://capture` to go_router as a route. Because
  the link has an empty path, go_router treated it as `/`, which matches no
  route. On a warm start that navigation could land after the bridge
  navigation and leave the error page. The app has no web or universal
  links, so nothing else depends on it.

### 3. Queues instead of background database access

The **Add to Inbox** intent and the widget checkbox write small JSON queues
to shared storage. On iOS this is App Group `UserDefaults`; on Android it is
home_widget's `SharedPreferences`. The app drains the queues through the
normal use cases:

- `inbox_captures`: `[{"text", "at"}]`
- `today_completions`: `[{"id", "at"}]`

`DrainExternalQueue` runs at startup, on every resume, and when native code
signals `queueChanged`. Android signals while the Flutter engine is alive,
so a widget tap with the app in the background applies immediately. On iOS,
the in-app Add to Inbox intent signals too. The drain removes only the
entries it read: it reads the key again just before writing and drops only
matching entries. A write that arrives during the drain is therefore kept.

A home_widget background Dart callback that completes the Item directly was
rejected:

- It opens a second Drift connection. Drift stream invalidation does not
  cross connections, so a running app would show stale lists.
- It needs notification, time-zone, and settings bootstrap in a headless
  engine for every tap.
- It has no iOS equivalent, because the database is not in the App Group.

One queue design serves both platforms and keeps every mutation in the main
isolate.

**Completion semantics.** A queued completion carries the tap time, and
`CompleteItem` accepts it as the completion instant (clamped to now). An
"every N days after completion" recurrence therefore advances from when the
user tapped, not from when the app next ran. Failure modes:

- *Item deleted since the tap:* skipped.
- *Already done or trashed* (completed in the app or from a notification):
  skipped, so no second recurrence successor is created.
- *Edited since the tap:* still completed. The tap expressed intent for that
  Item, and the user could only edit it after opening the app, which drains
  first.
- *Corrupt entry:* dropped, like the notification journal.
- *App never opened:* the completion waits. Until then, a pending reminder
  for that Item can still fire; completing from the notification is
  idempotent. This is accepted. Native code cannot cancel
  flutter_local_notifications alarms without duplicating its id scheme.

**Siri text lands raw in the Inbox.** It is not run through the
quick-capture parser:

- ADR 0007's "never surprise" rule relies on the chip preview that lets the
  user keep words as text. Siri gives no such preview, and parsing would
  strip date words from the title out of sight.
- Dictation never produces the `@` or `#` sigils.
- Capture is not Clarify. "Buy milk tomorrow" is a complete Inbox Item and
  is clarified later.

Text over 120 characters keeps the first 117 characters plus an ellipsis as
the title and the full text as notes, like a shared item. Entry points that
open the capture sheet (tile, shortcut, control, *Open Quick Capture*)
parse with the usual chip preview.

### 4. Today widget

**Data flow.** The app publishes `today_snapshot`, a JSON object with these
fields:

- `v`: the snapshot version;
- `day`: the local date;
- `items`: up to 8 objects with `id` and `title`;
- `more`: the number of focused Items not listed;
- `done`: the number of focused Items done today.

It is built by the pure `buildTodayWidgetSnapshot` from `focusedItemsProvider`
and the clock, and published whenever the JSON changes. That happens on
focus, completion, edit, and the midnight tick. Items are listed in
focus order. The hard-landscape band is not added: the widget shows the
user's commitments, matching the Today list.

**Optimistic state.** Native code renders the snapshot with the pending
completion queue applied. A queued row shows a filled check and dimmed
title, and `done` counts it. When the app drains and republishes, the row
disappears. Completion from the widget is final. Accidental taps are
reversible in the app (Done list → reopen). Undo on a small home-screen row
was judged more confusing than useful.

**Rollover.** When `day` is not the widget's current local date, the
snapshot is stale. Every listed Item is now carry-over from an earlier day,
not today's focus, so the widget shows the empty state. iOS schedules a
timeline entry at the next local midnight. Android re-renders on its
30-minute update period and whenever the app publishes. A device time-zone
change is handled the same way, because the comparison uses the widget's
local date.

**Layout.**

- *Header:* "Today" and "N done".
- *Rows:* a checkbox (complete) and the title (opens the Item).
- *Footer:* "+N more" (opens Today).
- *Empty state:* "Nothing focused yet", or "All done for today" when
  something was done, plus a **Plan your day** button that opens the daily
  plan.

On Android, the RemoteViews layout uses five fixed row slots. It avoids
`Space` (see `63789df`) and uses an `ImageView` checkbox, because
`CompoundButton` needs API 31. Row actions are explicit broadcasts to a
**non-exported** receiver, so other apps cannot complete Items. On iOS the
widget requires iOS 17, for `Button(intent:)`. It supports the medium size
(3 rows) and large size (8 rows); a small widget is too narrow for a
checkbox list. The Inbox widget keeps its kind and behavior. It gains
`containerBackground` so iOS 17 and later render it correctly.

**Appearance.** The existing Inbox widget does not follow the selected app
color or icon, so neither does the Today widget. It uses a system light or
dark surface with the brand accent. Following the app color would need the
palette exported to native code; that is left for later.

## Localization

Native surfaces use native string resources in the ten app locales:

- Android: `values-*/strings.xml`, with `values-zh` (Simplified) and
  `values-zh-rTW`/`-rHK` (Traditional).
- iOS: `*.lproj/Localizable.strings` in Runner and the widget extension, and
  `AppShortcuts.strings` for Siri phrases. Runner's `CFBundleLocalizations`
  gains `ru`.

These surfaces follow the **system** language, not the in-app language
override. They sit beside the launcher, Control Center, and Siri, which do
the same. Publishing translated strings in the snapshot was rejected: it
needs a second copy of every string for the case where the app has never
run. Dart gains no new user-facing strings.

## Accessibility

- Checkbox targets are at least 44pt or 48dp, and each is labelled
  "Complete <title>". Rows are labelled with the title.
- iOS widget text uses Dynamic Type styles; Android uses `sp` sizes.
- The tile, shortcuts, and control have text labels and monochrome icons.

## Self-review

- *Simplest?* Every entry point is a link or a queue entry. No new database
  access paths, no headless engines, and no new Dart dependency.
- *Could a widget tap be lost?* Only to a torn write, as with the
  notification journal. Drains remove matched entries, not the whole key.
- *Could it double-complete?* Already-done Items are skipped, and the
  repository completion is transactional.
- *Maintainability.* Shared Swift lives in `ios/TrayzeroShared`, and
  `add_extensions.rb` attaches every native file. The snapshot builder,
  queue drain, and link mapping are pure Dart with unit tests.
- *Descoped.* Android "add without opening the app" (no system text-entry
  surface fits), widget color following the app palette, and widget-side
  undo.

## Validation

- Unit tests cover:
  - the snapshot builder: order, cap, done count, carry-over exclusion, and
    the day stamp;
  - the queue drain: missing, done, and trashed Items, the tap-time
    completion stamp, raw capture, and long-text split;
  - link resolution;
  - the bridge's JSON round trip and partial removal over mocked channels.
- Builds: `flutter build apk --debug` and `flutter build ios --no-codesign
  --debug`.
- Emulator checks: the tile, shortcuts, widget completion with the app dead
  and alive, and cold and warm link routing.
- Real-device checks (not covered here):
  - Siri phrase discovery and *Add to Inbox* with the app terminated;
  - interactive widget timing;
  - the Control Center control;
  - OEM launcher shortcut behavior.
