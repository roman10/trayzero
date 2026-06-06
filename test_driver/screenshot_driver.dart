// Companion driver for `integration_test/screenshots_test.dart`.
//
// `IntegrationTestWidgetsFlutterBinding.takeScreenshot()` only buffers PNG
// bytes on the device side — they reach disk only when the driver writes
// them. This file is that driver. It saves each capture under
// `docs/play-store-listing/screenshots/<name>.png`.
//
// Output must be a strict 9:16 (1080×1920) — Play Console rejects anything
// outside 16:9/9:16. The right way to get that is to make the emulator render
// 1080×1920 *natively* (see the wm-size step below) so the app reflows: the
// bottom navigation bar pins to the visible bottom and the top app bar stays.
// At 1080×1920 [_cropToPlayAspectRatio] is a no-op and the capture is saved
// as-is.
//
// Do NOT rely on the center-crop to convert a 1080×2400 (9:20) capture: that
// trims 240 px off the bottom, which is exactly where the bottom nav bar
// renders — the screenshots come out with the nav bar cut off. The crop is
// kept only as a defensive fallback for an over-tall capture.
//
// Run with:
//
//   cd mobile
//   # Force a true 9:16 display first (default Medium Phone API 36.1 is 9:20):
//   adb -s <emulator-id> shell wm size 1080x1920
//   flutter drive \
//     --driver=test_driver/screenshot_driver.dart \
//     --target=integration_test/screenshots_test.dart \
//     --profile \
//     -d <emulator-id>
//   adb -s <emulator-id> shell wm size reset   # restore the emulator

import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:integration_test/integration_test_driver_extended.dart';

const int _playWidth = 1080;
const int _playHeight = 1920;

Future<void> main() => integrationDriver(
  onScreenshot:
      (String name, List<int> bytes, [Map<String, Object?>? args]) async {
        final dir = Directory('docs/play-store-listing/screenshots');
        if (!dir.existsSync()) {
          dir.createSync(recursive: true);
        }
        final file = File('${dir.path}/$name.png');
        final cropped = _cropToPlayAspectRatio(bytes);
        await file.writeAsBytes(cropped, flush: true);
        // ignore: avoid_print
        print('[screenshot] wrote ${file.path} (${cropped.length} bytes)');
        return true;
      },
);

/// Center-crops the raw capture to Play's required 1080×1920 (9:16).
///
/// If the source already matches, returns the bytes unchanged. Anything
/// narrower than 1080 px or shorter than 1920 px is left alone too — Play
/// will surface the size problem in its own UI and we'd rather see that
/// than silently upscale.
List<int> _cropToPlayAspectRatio(List<int> bytes) {
  final input = bytes is Uint8List ? bytes : Uint8List.fromList(bytes);
  final decoded = img.decodePng(input);
  if (decoded == null) return bytes;
  if (decoded.width == _playWidth && decoded.height == _playHeight) {
    return bytes;
  }
  if (decoded.width < _playWidth || decoded.height < _playHeight) {
    return bytes;
  }
  final cropped = img.copyCrop(
    decoded,
    x: (decoded.width - _playWidth) ~/ 2,
    y: (decoded.height - _playHeight) ~/ 2,
    width: _playWidth,
    height: _playHeight,
  );
  return img.encodePng(cropped);
}
