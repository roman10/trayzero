// Run from mobile/: dart run tool/generate_app_icons.dart
// Uses the existing image dev dependency; no native image tool is required.
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:image/image.dart' as img;

void main(List<String> arguments) {
  final androidOnly = arguments.contains('--android-only');
  final source = File(
    'lib/core/appearance_preferences.dart',
  ).readAsStringSync();
  final amber = RegExp(
    r'const trayzeroSeedArgb = (0x[0-9A-F]+);',
  ).firstMatch(source)!.group(1)!;
  final colors = <String, int>{
    for (final match in RegExp(
      r"\w+\('([a-z]+)', (0x[0-9A-F]+|trayzeroSeedArgb)\)",
    ).allMatches(source))
      match.group(1)!: int.parse(
        match.group(2) == 'trayzeroSeedArgb' ? amber : match.group(2)!,
      ),
  };
  final previewDir = Directory('assets/icon/app-icons')
    ..createSync(recursive: true);
  for (final entry in colors.entries) {
    final primary = entry.key == 'amber';
    if (androidOnly && primary) continue;
    final base = primary
        ? img.decodePng(
            File('assets/icon/trayzero-1024.png').readAsBytesSync(),
          )!
        : render(entry.value);
    if (!primary) generateAndroid(base, entry.key, entry.value);
    if (androidOnly) continue;
    File('${previewDir.path}/${entry.key}.png').writeAsBytesSync(
      img.encodePng(img.copyResize(base, width: 128, height: 128)),
    );
    final set = Directory(
      'ios/Runner/Assets.xcassets/${primary ? 'AppIcon' : 'AppIcon-${entry.key}'}.appiconset',
    )..createSync(recursive: true);
    // Replace the old per-size primary set with Xcode's universal 1024 format.
    // actool generates the device-specific renditions, including older iOS.
    if (primary) {
      for (final file in set.listSync().whereType<File>()) {
        if (file.path.endsWith('.png')) file.deleteSync();
      }
    }
    File('${set.path}/icon.png').writeAsBytesSync(img.encodePng(base));
    File(
      '${set.path}/icon-dark.png',
    ).writeAsBytesSync(img.encodePng(render(entry.value, dark: true)));
    File(
      '${set.path}/icon-tinted.png',
    ).writeAsBytesSync(img.encodePng(render(0xFF808080, dark: true)));
    File('${set.path}/Contents.json').writeAsStringSync(
      '${const JsonEncoder.withIndent('  ').convert({
        'images': [
          for (final appearance in ['', 'dark', 'tinted']) {
              'filename': appearance.isEmpty ? 'icon.png' : 'icon-$appearance.png',
              'idiom': 'universal',
              'platform': 'ios',
              'size': '1024x1024',
              if (appearance.isNotEmpty) 'appearances': [
                  {'appearance': 'luminosity', 'value': appearance},
                ],
            },
        ],
        'info': {'author': 'xcode', 'version': 1},
      })}\n',
    );
  }
}

// Same sunrise geometry as trayzero-source.svg. All pixels are opaque;
// cool palettes use neutral light for the sun instead of an amber fill.
img.Image render(int argb, {bool dark = false}) {
  final rgb = [(argb >> 16) & 255, (argb >> 8) & 255, argb & 255];
  final image = img.Image(width: 1024, height: 1024, numChannels: 3);
  for (var y = 0; y < 1024; y++) {
    final factor = dark ? 0.12 + 0.28 * y / 1023 : 0.30 + 0.70 * y / 1023;
    for (var x = 0; x < 1024; x++) {
      final pixel = rgb.map((c) => c * factor).toList();
      void blend(double alpha) {
        for (var c = 0; c < 3; c++) {
          pixel[c] = pixel[c] * (1 - alpha) + 255 * alpha;
        }
      }

      if (y < 640) {
        final distance = math.sqrt(math.pow(x - 512, 2) + math.pow(y - 640, 2));
        if (distance < 420) blend(0.06);
        if (distance < 340) blend(0.10);
        // Smooth the edge with analytic 1px coverage.
        blend((260.5 - distance).clamp(0.0, 1.0) * 0.94);
      }
      if (y >= 640 && y < 643) blend(0.30);
      image.setPixelRgb(
        x,
        y,
        pixel[0].round(),
        pixel[1].round(),
        pixel[2].round(),
      );
    }
  }
  return image;
}

// Keep Android launcher resources bundled, so changing an icon needs no
// downloads, new permissions, or runtime bitmap generation.
void generateAndroid(img.Image base, String id, int color) {
  const densities = {
    'mdpi': 1.0,
    'hdpi': 1.5,
    'xhdpi': 2.0,
    'xxhdpi': 3.0,
    'xxxhdpi': 4.0,
  };
  const root = 'android/app/src/main/res';
  for (final entry in densities.entries) {
    for (final (kind, size, name) in [
      ('mipmap', (48 * entry.value).round(), 'ic_launcher_$id'),
      ('drawable', (108 * entry.value).round(), 'ic_launcher_${id}_foreground'),
    ]) {
      final dir = Directory('$root/$kind-${entry.key}')
        ..createSync(recursive: true);
      File('${dir.path}/$name.png').writeAsBytesSync(
        img.encodePng(img.copyResize(base, width: size, height: size)),
      );
    }
  }
  final background = [16, 8, 0]
      .map(
        (shift) => (((color >> shift) & 255) * 0.85)
            .round()
            .toRadixString(16)
            .padLeft(2, '0'),
      )
      .join();
  File('$root/values/ic_launcher_$id.xml').writeAsStringSync(
    '''<?xml version="1.0" encoding="utf-8"?>
<resources><color name="ic_launcher_${id}_background">#$background</color></resources>
''',
  );
  File('$root/mipmap-anydpi-v26/ic_launcher_$id.xml').writeAsStringSync(
    '''<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_${id}_background"/>
    <foreground><inset android:drawable="@drawable/ic_launcher_${id}_foreground" android:inset="16%"/></foreground>
    <monochrome android:drawable="@drawable/ic_launcher_monochrome"/>
</adaptive-icon>
''',
  );
}
