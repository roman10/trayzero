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
#   a. Swap the billing provider for an inert provider.
#   b. Remove the in_app_review dependency and stub its adapter.
#   c. Set the F-Droid property to exclude Play Billing and AGP metadata.
#
# Run from the mobile/ root (pubspec.yaml in CWD). In the F-Droid public-repo
# build, that root IS the repo root.
set -euo pipefail

PUBSPEC="pubspec.yaml"
BILLING_PROVIDER="lib/infrastructure/billing_providers.dart"
BILLING_STUB="tool/foss/billing_providers_stub.dart"
REVIEW="lib/infrastructure/in_app_review_prompter.dart"
REVIEW_STUB="tool/foss/in_app_review_prompter_stub.dart"
GRADLE_PROPS="android/gradle.properties"

# -i.tmp suffix form is portable across BSD (macOS) and GNU sed.
echo "==> [strip] removing in_app_review dependency (Google Play Core)…"
sed -i.tmp '/^[[:space:]]*in_app_review:/d' "$PUBSPEC" && rm -f "$PUBSPEC.tmp"

echo "==> [strip] disabling billing provider…"
cp "$BILLING_STUB" "$BILLING_PROVIDER"

echo "==> [strip] swapping in inert in-app review stub…"
cp "$REVIEW_STUB" "$REVIEW"

echo "==> [strip] selecting F-Droid build without Play Billing…"
# Equivalent of passing -Pfdroid, but survives Flutter's own gradle invocation
# (whose args we don't control in F-Droid's build: step). See app/build.gradle.kts.
if ! grep -q '^fdroid=' "$GRADLE_PROPS"; then
  printf '\n# F-Droid build: drop AGP Google dependency-info block (see app/build.gradle.kts).\nfdroid=true\n' >> "$GRADLE_PROPS"
fi
