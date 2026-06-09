#!/usr/bin/env bash
#
# Single source of truth for the FOSS source transform.
#
# Mutates the working tree IN PLACE (no backup, no revert, idempotent). Two
# callers must stay identical to avoid drift:
#   1. tool/build_foss_apk.sh — backs up + restores around this call.
#   2. F-Droid prebuild — runs in a throwaway checkout of the PUBLIC repo, so
#      no restore is needed.
#
# WARNING: do NOT run this bare in the monorepo — it edits tracked files. Only
# tool/build_foss_apk.sh (which restores) or a disposable checkout should call it.
#
# Transform:
#   a. Remove the `purchases_flutter:` dependency line from pubspec.yaml.
#   b. Swap the RevenueCat gateway for the inert stub (no purchases_flutter import).
#   c. Append the F-Droid dependenciesInfo toggle to android/gradle.properties.
#
# Run from the mobile/ root (pubspec.yaml in CWD). In the F-Droid public-repo
# build, that root IS the repo root.
set -euo pipefail

PUBSPEC="pubspec.yaml"
GATEWAY="lib/infrastructure/revenuecat_billing_gateway.dart"
STUB="tool/foss/revenuecat_billing_gateway_stub.dart"
GRADLE_PROPS="android/gradle.properties"

echo "==> [strip] removing purchases_flutter dependency…"
# -i.tmp suffix form is portable across BSD (macOS) and GNU sed.
sed -i.tmp '/^[[:space:]]*purchases_flutter:/d' "$PUBSPEC" && rm -f "$PUBSPEC.tmp"

echo "==> [strip] swapping in inert billing stub…"
cp "$STUB" "$GATEWAY"

echo "==> [strip] enabling F-Droid dependenciesInfo toggle…"
# Equivalent of passing -Pfdroid, but survives Flutter's own gradle invocation
# (whose args we don't control in F-Droid's build: step). See app/build.gradle.kts.
if ! grep -q '^org.gradle.project.fdroid=' "$GRADLE_PROPS"; then
  printf '\n# F-Droid build: drop AGP Google dependency-info block (see app/build.gradle.kts).\norg.gradle.project.fdroid=true\n' >> "$GRADLE_PROPS"
fi
