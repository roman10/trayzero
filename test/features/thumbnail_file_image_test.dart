import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:cleartray/features/common/thumbnail_file_image.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final dimensions in [(800, 600), (600, 800), (800, 800), (40, 30)]) {
    test('decodes $dimensions proportionally for a 168px thumbnail', () async {
      final directory = await Directory.systemTemp.createTemp('thumbnail_test');
      addTearDown(() => directory.delete(recursive: true));
      final recorder = ui.PictureRecorder();
      ui.Canvas(
        recorder,
      ).drawPaint(ui.Paint()..color = const ui.Color(0xff123456));
      final picture = recorder.endRecording();
      final source = await picture.toImage(dimensions.$1, dimensions.$2);
      picture.dispose();
      final bytes = await source.toByteData(format: ui.ImageByteFormat.png);
      source.dispose();
      final file = await File(
        '${directory.path}/image.png',
      ).writeAsBytes(bytes!.buffer.asUint8List());
      final stream = ThumbnailFileImage(
        file,
        pixelSize: 168,
      ).resolve(ImageConfiguration.empty);
      final result = Completer<ImageInfo>();
      final listener = ImageStreamListener(
        (info, _) => result.complete(info),
        onError: (Object error, StackTrace? stack) =>
            result.completeError(error, stack),
      );
      stream.addListener(listener);
      final info = await result.future;
      stream.removeListener(listener);
      final expected = switch (dimensions) {
        (800, 600) => (224, 168),
        (600, 800) => (168, 224),
        (800, 800) => (168, 168),
        _ => (40, 30),
      };
      expect((info.image.width, info.image.height), expected);
      info.dispose();
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
    });
  }

  test('cache keys separate decode sizes and original viewer images', () {
    final file = File('/attachment.png');
    final thumbnail = ThumbnailFileImage(file, pixelSize: 168);
    expect(thumbnail, ThumbnailFileImage(file, pixelSize: 168));
    expect(thumbnail, isNot(ThumbnailFileImage(file, pixelSize: 112)));
    expect(thumbnail, isNot(FileImage(file)));
    expect(FileImage(file), isNot(thumbnail));
  });
}
