# ADR 0005 — Native icon appearance

- Status: Accepted
- Date: 2026-10-16

## Decision

Extend the device-local appearance choices in ADR 0003 to native surfaces:

- Android gets a monochrome sunrise adaptive-icon layer for system theming and
  a separate white-on-transparent notification glyph. The launcher/system owns
  final tinting; the in-app palette does not override a user's system theme.
- Android notification accents use the OS-selected app icon palette at scheduling
  time, independently of App color. Keep the standard monochrome glyph and no
  large icon. Headless Snooze uses a derived cache of the last confirmed native
  icon selection because its engine has no app icon channel. This cache never
  drives launcher selection and is not part of task backups. Existing notifications
  retain styling until rescheduled;
  normal startup re-arming refreshes future reminders. Never cancel alarms or
  change Snooze times solely to recolor them. Icon/cache read failures fall
  back to amber and must not block delivery.
- App icon selection is separate from App color. Offer the seven existing
  palette names, with amber restoring the original brand icon. Read the OS's
  current selection; the notification fallback cache is never authoritative. No
  automatic startup changes, task-backup entries, or per-notification picker.
- OPPO/ColorOS may replace the notification glyph with the original package
  icon even when the requested accent matches the selected launcher icon. Accept
  this system behavior; do not use private APIs or custom notification layouts.
- iOS uses bundled alternate app icon sets and the public UIKit API. The user
  explicitly selects an icon because iOS shows a system alert. Include dark
  and tinted artwork; system appearance can override colors. Notification
  identity remains system-owned; do not promise a separately colored header.
- Platform operations sit behind a core port and infrastructure adapter. The
  application controller waits for native success, rejects overlapping changes,
  and preserves the previous selection on failure. Unsupported hosts hide the
  picker. Translated, scrollable previews support large text.
- Android keeps MainActivity enabled permanently. Seven theme-only launcher
  activities forward to it, preserving the original component names and Flutter
  tooling's launch discovery. Each declares the corresponding icon splash theme.
  Enable the selected entry
  atomically on Android 13+, or enable-before-disable with rollback on older
  versions. Keep component names stable across updates. An INFO entry on
  MainActivity makes PackageManager return a stable notification launch target,
  preserving notification PendingIntents across icon switches. Widgets, sharing,
  and cleartray:// links continue to target the original MainActivity.

- Native launch backgrounds are neutral `#FAFAFA` / `#121212`, following system
  light/dark appearance rather than the in-app mode. Android uses bundled sunrise
  glyphs in the selected icon palette and AndroidX SplashScreen. Routing entries
  never draw content: they transfer the system splash to MainActivity. If an icon
  change introduces a different launcher entry while Flutter is alive, bring its
  existing task forward and remove the temporary routing task, preserving one
  Flutter engine and the application task affinity shared with AppAuth. Routing
  activities relinquish task identity to MainActivity so notifications and deep
  links reuse that host instead of creating a second Flutter engine. Flutter's
  existing first-frame gate ends it; no extra screen or minimum display time.
  Direct notification/widget/deep-link launches start with a neutral fallback,
  then native initialization selects the OS icon theme. The earliest system
  window on those paths may remain neutral.
- iOS keeps a static launch storyboard with a dynamic background color asset and
  gray sunrise light/dark images. Alternate icons do not change this artwork.
  Never read runtime preferences or add a second Flutter splash to customize it.

## Assets and validation

Run `dart run tool/generate_launch_assets.dart` from `mobile/` to regenerate
Android splash glyphs/themes and neutral iOS launch images.

Run `dart run tool/generate_app_icons.dart` from `mobile/` to regenerate the
icon previews, iOS catalogs, and Android launcher assets.
Use `--android-only` to leave iOS assets untouched. The original sunrise artwork
remains the primary icon. The generator uses the existing `image` dev dependency.

Validate the platform channel, controller success/failure/concurrency, palette
independence, and translated picker layout. Build native binaries to verify
asset compilation. Run `integration_test/app_icon_test.dart` only on disposable
devices: it switches the installed test app's icon to cyan. On iOS, acknowledge
its system alert. Relaunch with `--dart-define=ICON_VERIFY_ONLY=true` to check
that the OS retained cyan across termination and installation. Check launcher and
notification appearance on physical iOS and Android devices before release,
including system tinting, relaunch, and app upgrades. Native UI caching is not
covered by mocked Dart tests.

For Android native checks, explicitly align the test variant's AndroidX
libraries with `-PnativeTestBuildType=debug` when assembling both the debug
app and its instrumentation APK. Run the `app.cleartray.AppIconManagerTest`
class only on a disposable device, using an explicit `adb -s` serial. It
checks every icon choice, one launcher entry, the stable notification/deep-link
entrypoint, the packaged notification glyph, light/dark splash resources, and
Flutter host reuse after an icon change. Exercise API 24 and API 33+
to cover the sequential and atomic switching paths respectively.

Launcher workspace placement and cached artwork after an app upgrade depend
on the launcher; verify upgrades from the original MainActivity launcher on
physical devices before publishing.
