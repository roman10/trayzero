#!/bin/sh
set -eu

# flutter drive leaves its test target in Generated.xcconfig. Never archive
# that entry point as the shipping app, even when Xcode is invoked directly.
if [ "${ACTION:-}" = "install" ]; then
  case "${FLUTTER_TARGET:-lib/main.dart}" in
    lib/main.dart|"${FLUTTER_APPLICATION_PATH:-$SRCROOT/..}/lib/main.dart") ;;
    *)
      echo "error: Refusing to archive FLUTTER_TARGET=${FLUTTER_TARGET}. Regenerate the iOS configuration with flutter build ios --config-only --release --target lib/main.dart, then archive again." >&2
      exit 1
      ;;
  esac
fi

exec /bin/sh "$FLUTTER_ROOT/packages/flutter_tools/bin/xcode_backend.sh" build
