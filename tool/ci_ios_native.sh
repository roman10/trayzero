#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
runtime="${IOS_NATIVE_RUNTIME:-$(xcrun simctl list runtimes -j | python3 -c '
import json, sys
runtimes = [r for r in json.load(sys.stdin)["runtimes"]
            if r.get("isAvailable") and r["name"].startswith("iOS ")]
if not runtimes:
    raise SystemExit("No available iOS Simulator runtime")
print(max(runtimes, key=lambda r: tuple(map(int, r["version"].split("."))))["identifier"])
')}"
device="$(xcrun simctl create 'Trayzero native CI' \
  com.apple.CoreSimulator.SimDeviceType.iPhone-16 "$runtime")"
cleanup() {
  xcrun simctl shutdown "$device" || true
  xcrun simctl delete "$device"
}
trap cleanup EXIT
xcrun simctl boot "$device"
xcrun simctl bootstatus "$device" -b

# Install first so permissions can be granted without a native dialog that
# Flutter's widget tester cannot operate. This uses a new simulator only.
flutter build ios --simulator --debug \
  --target integration_test/native_release_test.dart --dart-define=CI_NATIVE_TEST=true
xcrun simctl install "$device" build/ios/iphonesimulator/Runner.app
xcrun simctl privacy "$device" grant calendar app.cleartray
flutter test integration_test/native_release_test.dart -d "$device" \
  --dart-define=CI_NATIVE_TEST=true --reporter expanded
