#!/usr/bin/env bash
#
# Build a RevenueCat-, Play Billing-, and Play Core-free FOSS APK (for IzzyOnDroid and other
# FOSS channels).
#
# DEFAULT BUILDS ARE UNAFFECTED. `flutter build appbundle` (Play), Xcode Archive
# (App Store), `flutter run`, Android Studio — keep the normal platform billing gateways.
#
# Applies the FOSS source transform, builds a release APK, and restores
# the input files via an EXIT trap even on failure or Ctrl-C.
#
# Usage:  ./tool/build_foss_apk.sh [extra flutter build args]
# Output: build/app/outputs/flutter-apk/app-release.apk
set -euo pipefail

cd "$(dirname "$0")/.."   # -> mobile/

PUBSPEC="pubspec.yaml"
LOCKFILE="pubspec.lock"
BILLING_PROVIDER="lib/infrastructure/billing_providers.dart"
REVIEW="lib/infrastructure/in_app_review_prompter.dart"
GRADLE_PROPS="android/gradle.properties"
OUT="build/app/outputs/flutter-apk/app-release.apk"

BAK_DIR="$(mktemp -d)"

restore() {
  cp "$BAK_DIR/pubspec.yaml" "$PUBSPEC"
  cp "$BAK_DIR/pubspec.lock" "$LOCKFILE"
  cp "$BAK_DIR/billing_providers.dart" "$BILLING_PROVIDER"
  cp "$BAK_DIR/review.dart" "$REVIEW"
  cp "$BAK_DIR/gradle.properties" "$GRADLE_PROPS"
  rm -rf "$BAK_DIR"
  # Return deps/lockfile to the default state.
  flutter pub get >/dev/null
  echo "==> Restored default pubspec.yaml + billing provider + review adapter + gradle.properties."
}
trap restore EXIT

echo "==> Backing up originals…"
cp "$PUBSPEC" "$BAK_DIR/pubspec.yaml"
cp "$LOCKFILE" "$BAK_DIR/pubspec.lock"
cp "$BILLING_PROVIDER" "$BAK_DIR/billing_providers.dart"
cp "$REVIEW" "$BAK_DIR/review.dart"
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
if unzip -p "$OUT" 'classes*.dex' | grep -ai 'revenuecat' >/dev/null; then
  echo "!! FAIL: RevenueCat classes found in $OUT" >&2
  exit 1
fi
echo "==> OK: no RevenueCat code in APK."

echo "==> Verifying APK contains no Google Play Billing classes or permission…"
if unzip -p "$OUT" 'classes*.dex' | grep -aE 'com/android/billingclient|com.android.vending.BILLING' >/dev/null ||
   unzip -p "$OUT" AndroidManifest.xml | tr -d '\000' | grep -a 'com.android.vending.BILLING' >/dev/null; then
  echo "!! FAIL: Google Play Billing found in $OUT" >&2
  exit 1
fi
echo "==> OK: no Google Play Billing in APK."

echo "==> Verifying APK contains no Play Core review classes…"
if unzip -p "$OUT" 'classes*.dex' | grep -a 'com/google/android/play/core/review' >/dev/null; then
  echo "!! FAIL: Google Play Core review classes found in $OUT" >&2
  exit 1
fi
echo "==> OK: no Play Core review code in APK."

# Stamp a clear, distinct artifact name; restore() still runs after this.
echo
echo "FOSS APK built: mobile/$OUT"
echo "(rename to trayzero-vX.Y.Z-foss.apk before publishing)"
