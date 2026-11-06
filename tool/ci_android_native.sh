#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
device="${1:?Pass the serial of a disposable Android emulator}"
case "$device" in
  emulator-*) ;;
  *) echo 'Native CI requires a disposable emulator, not a personal device.' >&2; exit 1 ;;
esac
export ANDROID_SERIAL="$device"
connected="$(adb devices | awk 'NR > 1 && $2 == "device" { print $1 }')"
if [ "$connected" != "$device" ]; then
  echo 'Connect only the disposable emulator before running native CI.' >&2
  exit 1
fi
backup="$(mktemp -d)"
cp pubspec.yaml pubspec.lock "$backup/"
cleanup() {
  cp "$backup/pubspec.yaml" pubspec.yaml
  cp "$backup/pubspec.lock" pubspec.lock
  flutter pub get --offline > /dev/null
  rm -rf "$backup"
}
trap cleanup EXIT

# Flutter excludes dev-only native plugins in release mode. Include the
# integration_test result bridge only in this isolated test build, retaining
# all locked package versions. Restore the production manifests on exit.
python3 - <<'PY'
from pathlib import Path
path = Path('pubspec.yaml')
text = path.read_text()
block = '  integration_test:\n    sdk: flutter\n'
if text.count(block) != 1 or block not in text.split('dev_dependencies:', 1)[1]:
    raise SystemExit('Expected integration_test as an SDK dev dependency')
text = text.replace(block, '', 1)
text = text.replace('\ndependencies:\n', '\ndependencies:\n' + block, 1)
path.write_text(text)
PY
flutter pub get --offline
export ORG_GRADLE_PROJECT_nativeTestBuildType=release
target="$PWD/integration_test/native_release_test.dart"
defines="$(printf %s 'CI_NATIVE_TEST=true' | base64 | tr -d '\n')"

# Build the test entrypoint with the same R8-enabled release configuration.
rm -f build/app/outputs/mapping/release/mapping.txt
flutter build apk --release --target "$target" --dart-define=CI_NATIVE_TEST=true
test -s build/app/outputs/mapping/release/mapping.txt
(
  cd android
  ./gradlew app:assembleReleaseAndroidTest \
    -PnativeTestBuildType=release -Ptarget="$target" -Pdart-defines="$defines"
)
adb -s "$device" install -r -g build/app/outputs/flutter-apk/app-release.apk
for permission in READ_CALENDAR WRITE_CALENDAR POST_NOTIFICATIONS; do
  adb -s "$device" shell pm grant app.cleartray "android.permission.$permission"
done

# The Gradle runner propagates JUnit failures. `adb shell am instrument` alone
# can exit zero even when the Dart tests failed, and flutter test needs a VM
# service unavailable in release mode.
(
  cd android
  ./gradlew app:connectedReleaseAndroidTest \
    -PnativeTestBuildType=release -Ptarget="$target" -Pdart-defines="$defines"
)
python3 tool/verify_native_results.py
