# iOS release signing & App Store Connect setup

Release builds (`flutter build ipa --release`) need a distribution certificate
and a provisioning profile. The certificate is intentionally NOT in source
control. The Xcode project is pre-configured for automatic signing under team
`368WCFCZ65`; the one-time steps below create the Apple-side records the
project assumes exist.

Do these in order — App Store Connect first (so the name is reserved before
anyone else can grab it), then the App IDs, then the build.

## 1. Reserve the app name in App Store Connect (~5 min)

1. Sign in at <https://appstoreconnect.apple.com> → **My Apps** → **+** →
   **New App**.
2. Fill in:
   - Platform: **iOS**
   - Name: **Cleartray**
   - Primary language: **English (U.S.)**
   - Bundle ID: **`app.cleartray`** (pick from the dropdown — see §2 below
     if it's not listed yet)
   - SKU: any unique string, e.g. `cleartray-ios-001`
   - User Access: **Full Access**
3. Click **Create**. This both reserves the name globally and creates the
   App Store record that TestFlight + production builds attach to.

## 2. Register App IDs and the App Group (~5 min)

Open <https://developer.apple.com/account/resources>. Most of these get
auto-created the first time Xcode signs the matching target with the team
selected; do it manually only if Xcode hasn't.

**Identifiers** — confirm all three App IDs exist (create if missing):

| Identifier | Description | Capabilities |
|---|---|---|
| `app.cleartray` | Cleartray | App Groups, Push Notifications *(off, kept for future)* |
| `app.cleartray.ShareExtension` | Cleartray Share Extension | App Groups |
| `app.cleartray.CleartrayInboxWidget` | Cleartray Inbox Widget | App Groups |

**App Groups** — create `group.app.cleartray` if missing, then enable it on
all three identifiers above. The host app and both extensions share inbox
state and the share-intent payload through this group; the entitlements
files in `Runner/`, `ShareExtension/`, and `CleartrayInboxWidget/` already
declare it.

## 3. Distribution certificate + provisioning profiles (~5 min, one-time)

The Xcode project uses **automatic signing**, so the cert and profiles are
fetched on first archive:

1. Open `mobile/ios/Runner.xcworkspace` in Xcode.
2. For each of the three targets (`Runner`, `ShareExtension`,
   `CleartrayInboxWidget`): select target → **Signing & Capabilities** →
   confirm **Automatically manage signing** is checked and team
   `368WCFCZ65` is selected.
3. Set the active scheme to **Runner** and the destination to
   **Any iOS Device (arm64)**.
4. **Product → Archive**. On first run Xcode prompts for, then installs,
   the Apple Distribution certificate and matching provisioning profiles.
   Subsequent archives are silent.

If Xcode reports "No accounts" → **Xcode → Settings → Accounts → +** →
sign in with the Apple ID that owns team `368WCFCZ65`.

## 4. Build + upload

Two equivalent paths:

**Skill-driven (recommended):** run `/ios-testflight-release`. It runs
`flutter build ipa`, hands the IPA to Transporter, and enables the build
for TestFlight.

**Manual:**

```bash
cd mobile
flutter build ipa --release
# → build/ios/ipa/cleartray.ipa
```

Then upload via Transporter.app (App Store → drop the IPA → Deliver) or
`xcrun altool --upload-app -f build/ios/ipa/cleartray.ipa -t ios \
  --apiKey <KEY_ID> --apiIssuer <ISSUER_ID>`. App Store Connect takes a
few minutes to process the build, after which it appears under TestFlight.

## 5. Backup

Apple Distribution certificates can be re-issued from Apple Developer if
lost (unlike Android keystores, there is no irrecoverable state). The App
Store Connect API key + Transporter credentials are the credentials worth
storing in 1Password.

## Project state already in place

These don't need touching — recording for the next person:

- `ios/Runner.xcodeproj/project.pbxproj`: `DEVELOPMENT_TEAM = 368WCFCZ65`,
  `CODE_SIGN_STYLE = Automatic` on extensions, Runner inherits from
  `Flutter/Release.xcconfig`, `ENABLE_BITCODE = NO`, bundle IDs match §2.
- `ios/Runner/Runner.entitlements`, `ios/ShareExtension/ShareExtension.entitlements`,
  `ios/CleartrayInboxWidget/CleartrayInboxWidget.entitlements`: all declare
  `group.app.cleartray`.
- `ios/Runner/Info.plist`: usage descriptions for microphone, speech,
  camera, photo library, calendars (incl. iOS 17+ full-access key).
- `ios/Runner/PrivacyInfo.xcprivacy`: required-reason API declarations
  + opt-in crash/perf data via Sentry.
