#!/usr/bin/env bash
#
# Build a RevenueCat-free FOSS APK (for IzzyOnDroid and other FOSS channels).
#
# DEFAULT BUILDS ARE UNAFFECTED. `flutter build appbundle` (Play), Xcode Archive
# (App Store), `flutter run`, Android Studio — all keep the real RevenueCat
# gateway. This script is the ONLY path that strips it.
#
# It temporarily (a) removes the `purchases_flutter` dependency from
# pubspec.yaml and (b) swaps the billing gateway for an inert stub, builds a
# release APK, then ALWAYS restores the originals via an EXIT trap — even on
# build failure or Ctrl-C. The working tree is left identical to how it started.
#
# Usage:  ./tool/build_foss_apk.sh [extra flutter build args]
# Output: build/app/outputs/flutter-apk/app-release.apk
set -euo pipefail

cd "$(dirname "$0")/.."   # -> mobile/

PUBSPEC="pubspec.yaml"
GATEWAY="lib/infrastructure/revenuecat_billing_gateway.dart"
GRADLE_PROPS="android/gradle.properties"
OUT="build/app/outputs/flutter-apk/app-release.apk"

BAK_DIR="$(mktemp -d)"

restore() {
  cp "$BAK_DIR/pubspec.yaml" "$PUBSPEC"
  cp "$BAK_DIR/gateway.dart" "$GATEWAY"
  cp "$BAK_DIR/gradle.properties" "$GRADLE_PROPS"
  rm -rf "$BAK_DIR"
  # Return deps/lockfile to the default (RevenueCat) state.
  flutter pub get >/dev/null
  echo "==> Restored default pubspec.yaml + billing gateway + gradle.properties."
}
trap restore EXIT

echo "==> Backing up originals…"
cp "$PUBSPEC" "$BAK_DIR/pubspec.yaml"
cp "$GATEWAY" "$BAK_DIR/gateway.dart"
cp "$GRADLE_PROPS" "$BAK_DIR/gradle.properties"

# Apply the FOSS source transform (shared with the F-Droid prebuild step so the
# two builds can't drift). Restored by the EXIT trap above.
echo "==> Applying FOSS strip (tool/foss/strip.sh)…"
bash "$(dirname "$0")/foss/strip.sh"

echo "==> flutter pub get…"
flutter pub get

echo "==> flutter build apk --release…"
flutter build apk --release "$@"

echo "==> Verifying APK contains no RevenueCat classes…"
if unzip -p "$OUT" 'classes*.dex' | grep -qa 'revenuecat'; then
  echo "!! FAIL: RevenueCat classes found in $OUT" >&2
  exit 1
fi
echo "==> OK: no RevenueCat code in APK."

# Stamp a clear, distinct artifact name; restore() still runs after this.
echo
echo "FOSS APK built: mobile/$OUT"
echo "(rename to trayzero-vX.Y.Z-foss.apk before publishing)"
