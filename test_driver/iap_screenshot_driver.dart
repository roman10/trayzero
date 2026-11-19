// Driver for the IAP App Review screenshot capture in
// `integration_test/screenshots_test.dart` (the `IAP_SHOT` branch).
//
// `IntegrationTestWidgetsFlutterBinding.takeScreenshot()` only buffers PNG
// bytes on the device side; this driver writes them to disk. Output goes to
// `docs/app-store-listing/iap-review/<name>.png` (repo-root docs), kept
// separate from the storefront listing screenshots.
//
// The capture is raw — an iPhone SE (3rd gen) simulator renders 750×1334,
// which App Store Connect accepts as an IAP review screenshot. Run from
// `mobile/`:
//
//   flutter drive \
//     --driver=test_driver/iap_screenshot_driver.dart \
//     --target=integration_test/screenshots_test.dart \
//     --profile \
//     -d "iPhone SE (3rd generation)" \
//     --dart-define=IAP_SHOT=true

import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() => integrationDriver(
  onScreenshot:
      (String name, List<int> bytes, [Map<String, Object?>? args]) async {
        final dir = Directory('../docs/app-store-listing/iap-review');
        if (!dir.existsSync()) {
          dir.createSync(recursive: true);
        }
        final file = File('${dir.path}/$name.png');
        await file.writeAsBytes(bytes, flush: true);
        // ignore: avoid_print
        print('[iap-screenshot] wrote ${file.path} (${bytes.length} bytes)');
        return true;
      },
);
