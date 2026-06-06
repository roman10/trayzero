# iOS Extensions — Xcode wiring

The Swift / plist / storyboard / entitlements source files for both extensions
are committed under `ios/CleartrayInboxWidget/` and `ios/ShareExtension/` and
are **already attached** to `Runner.xcodeproj` via
`ios/scripts/add_extensions.rb`, which uses the `xcodeproj` Ruby gem
(bundled with CocoaPods) to mutate the pbxproj.

## Quick reference

If `Runner.xcodeproj/project.pbxproj` is ever regenerated from scratch
(e.g. `flutter create .` over an existing project, or someone deletes the
extension targets in Xcode), re-attach by running:

```bash
cd mobile
/usr/bin/ruby ios/scripts/add_extensions.rb
flutter clean && flutter build ios --no-codesign --debug
```

The script is idempotent — running it on a project that already has the
targets just refreshes build settings and is a no-op for files/phases.

> **System ruby (`/usr/bin/ruby`) is required** — Homebrew Ruby 4.x cannot
> load the xcodeproj gem installed under the 3.4.0 gem dir.

## What the script does

1. Adds `CODE_SIGN_ENTITLEMENTS = Runner/Runner.entitlements` to Runner so the
   host app declares the `group.app.cleartray` App Group.
2. Creates the **`CleartrayInboxWidget`** app-extension target
   (`app.cleartray.CleartrayInboxWidget`, iOS 16.0 deployment, Swift 5),
   attaches `CleartrayInboxWidget.swift`, `Info.plist`,
   `CleartrayInboxWidget.entitlements`, and links `WidgetKit` + `SwiftUI`.
3. Creates the **`ShareExtension`** app-extension target
   (`app.cleartray.ShareExtension`, iOS 14.0 deployment, Swift 5 — 14.0 because
   `ShareViewController.swift` uses `UTType`), attaches
   `ShareViewController.swift`, `MainInterface.storyboard`, `Info.plist`,
   `ShareExtension.entitlements`, and links `Social`, `MobileCoreServices`,
   `UniformTypeIdentifiers`, and `UIKit`.
4. Adds both as target dependencies of Runner and embeds them via a new
   `Embed App Extensions` copy-files phase. The phase is inserted **before**
   `Thin Binary` to avoid a build-graph cycle (Thin Binary thins the embedded
   binaries; if Embed App Extensions runs after it, the .appex copy ends up
   depending on Info.plist which depends on the .appex).

## Apple Developer registration (still manual)

The App Group `group.app.cleartray` has to exist in the Apple Developer
console for code-signed builds. With **automatic signing** in Xcode this
happens on first build; with **manual signing** you must create it under
*Certificates, Identifiers & Profiles → Identifiers → App Groups* and add it
to all three App IDs (`app.cleartray`, `app.cleartray.CleartrayInboxWidget`,
`app.cleartray.ShareExtension`).

## Verify

```bash
cd mobile
flutter clean
flutter build ios --no-codesign --debug
```

Expected: build succeeds and
`build/ios/iphoneos/Runner.app/PlugIns/{CleartrayInboxWidget,ShareExtension}.appex`
both exist. Run on a device:

- Add the **Cleartray Inbox** widget to the home screen → live inbox count.
- Open Safari → Share → **Add to Cleartray** → host app opens with the
  shared text/URL pre-filled in the capture sheet.

## Historical note (kept for reference)

The original procedure was to add both targets through Xcode's
**File → New → Target** wizard. The wizard is no longer needed; the script
above does the equivalent edits and is reproducible. The wizard-based
procedure is preserved below in case something blocks the script.

### Legacy: wizard-based wiring

## 1. Add the App Group

1. Open `ios/Runner.xcworkspace` in Xcode.
2. Select the `Runner` project → `Runner` target → **Signing & Capabilities**.
3. `+ Capability` → **App Groups**.
4. `+` → enter **`group.app.cleartray`** → Apple Developer console will create
   it automatically (or assign the existing one).
5. Confirm `Runner.entitlements` (already in the repo at `ios/Runner/`) is the
   selected entitlements file.

## 2. Add the WidgetKit extension target

1. **File → New → Target** → iOS → **Widget Extension**.
2. Product Name: **`CleartrayInboxWidget`**. Uncheck _Include Configuration
   Intent_. Bundle Identifier: `app.cleartray.CleartrayInboxWidget`.
3. Xcode auto-creates a `CleartrayInboxWidget/` group with template files. **Delete
   them from the target** (move to Trash) and instead drag in the existing
   files from `ios/CleartrayInboxWidget/`:
   - `CleartrayInboxWidget.swift`
   - `Info.plist`
   - `CleartrayInboxWidget.entitlements`
4. Target → **Signing & Capabilities** → `+ Capability` → **App Groups** →
   tick `group.app.cleartray`. Confirm the entitlements file is the one in the
   repo.
5. Target → **Build Settings**:
   - Set **iOS Deployment Target** to 16.0 (WidgetKit interactive widgets).
   - Set **Swift Language Version** to 5.

## 3. Add the Share extension target

1. **File → New → Target** → iOS → **Share Extension**.
2. Product Name: **`ShareExtension`**. Bundle Identifier:
   `app.cleartray.ShareExtension`.
3. Replace the template files with the existing files from
   `ios/ShareExtension/`:
   - `ShareViewController.swift`
   - `Info.plist`
   - `MainInterface.storyboard`
   - `ShareExtension.entitlements`
4. Target → **Signing & Capabilities** → `+ Capability` → **App Groups** →
   tick `group.app.cleartray`.

## 4. Verify

```bash
cd mobile
flutter clean
flutter build ios --no-codesign --debug
```

Expected: build succeeds. Run on a device / simulator:

- Add the **Cleartray Inbox** widget to the home screen → it should show the live
  inbox count from the running app.
- Open Safari → Share → **Add to Cleartray** → host app should open with the URL
  pre-filled in the capture sheet.

## 5. Troubleshooting

- `No App Group entitlement found` → the Widget / Share target's entitlements
  file is wrong or the App Group was created in a different Apple Dev team.
- Widget shows `0` even though the inbox isn't empty → the host app and the
  widget extension must share the same App Group ID **`group.app.cleartray`**.
- Share extension opens but host app doesn't pick up the text → the
  `ShareKey` / URL scheme used by `receive_sharing_intent` must match. The
  Swift code uses `ShareMedia-app.cleartray` which is the plugin's expected
  default for bundle id `app.cleartray`.
