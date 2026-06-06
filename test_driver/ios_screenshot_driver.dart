// iOS App Store companion driver for `integration_test/screenshots_test.dart`.
//
// Same target test as the Play harness — it just drives the router and asks the
// integration_test binding to buffer a PNG at each storefront screen. This
// driver writes those PNGs to disk, into per-device-class folders under the
// repo-root `docs/app-store-listing/screenshots/`.
//
// Unlike the Android driver (`screenshot_driver.dart`), this one does NOT crop:
// the iOS simulators render at exactly the sizes App Store Connect wants, so we
// save the raw capture and just route it to the right folder by image width:
//
//   • iPhone 6.9" (iPhone 16 Pro Max) → 1320×2868  → screenshots/iphone-6.9/
//   • iPad 13"    (iPad Pro 13" M4)   → 2064×2752  → screenshots/ipad-13/
//
// (iPhone 15 Pro Max / 16 Plus render 1290×2796 — also a valid 6.9" upload —
//  and iPad Pro 12.9" renders 2048×2732 — also a valid 13" upload. The width
//  threshold below classifies all of them correctly.)
//
// Run once per device, from `mobile/`:
//
//   flutter drive \
//     --driver=test_driver/ios_screenshot_driver.dart \
//     --target=integration_test/screenshots_test.dart \
//     --profile \
//     -d "iPhone 16 Pro Max"
//
//   flutter drive \
//     --driver=test_driver/ios_screenshot_driver.dart \
//     --target=integration_test/screenshots_test.dart \
//     --profile \
//     -d "iPad Pro 13-inch (M4)"

import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:integration_test/integration_test_driver_extended.dart';

// Anything wider than this is an iPad; anything narrower is an iPhone.
// iPhone 6.9"/6.7" widths are 1290–1320; iPad 13"/12.9" widths are 2048–2064.
const int _ipadWidthThreshold = 1600;

Future<void> main() => integrationDriver(
  onScreenshot:
      (String name, List<int> bytes, [Map<String, Object?>? args]) async {
        final bucket = _bucketFor(bytes);
        final dir = Directory('../docs/app-store-listing/screenshots/$bucket');
        if (!dir.existsSync()) {
          dir.createSync(recursive: true);
        }
        final file = File('${dir.path}/$name.png');
        await file.writeAsBytes(bytes, flush: true);
        // ignore: avoid_print
        print('[screenshot] wrote ${file.path} (${bytes.length} bytes)');
        return true;
      },
);

/// Classifies a capture into `iphone-6.9` or `ipad-13` by decoded width.
/// Falls back to `unknown` if the PNG can't be decoded, so a mis-sized capture
/// surfaces as a stray folder rather than silently landing in the wrong set.
String _bucketFor(List<int> bytes) {
  final input = bytes is Uint8List ? bytes : Uint8List.fromList(bytes);
  final decoded = img.decodePng(input);
  if (decoded == null) return 'unknown';
  return decoded.width >= _ipadWidthThreshold ? 'ipad-13' : 'iphone-6.9';
}
