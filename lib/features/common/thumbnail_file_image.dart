import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

/// Decodes only the pixels needed to cover a square thumbnail.
///
/// The shorter edge is bounded by [pixelSize], preserving the source aspect
/// ratio and avoiding upscaling small images. The size is part of the cache key
/// so thumbnails cannot reuse the viewer's full-resolution decoded image.
class ThumbnailFileImage extends FileImage {
  const ThumbnailFileImage(super.file, {required this.pixelSize})
    : assert(pixelSize > 0);

  final int pixelSize;

  @override
  ImageStreamCompleter loadImage(FileImage key, ImageDecoderCallback decode) {
    return super.loadImage(
      key,
      (buffer, {getTargetSize}) => decode(
        buffer,
        getTargetSize: (width, height) {
          final shorterEdge = math.min(width, height);
          final targetEdge = math.min(pixelSize, shorterEdge);
          return ui.TargetImageSize(
            width: (width * targetEdge + shorterEdge - 1) ~/ shorterEdge,
            height: (height * targetEdge + shorterEdge - 1) ~/ shorterEdge,
          );
        },
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ThumbnailFileImage &&
      other.runtimeType == runtimeType &&
      other.file.path == file.path &&
      other.scale == scale &&
      other.pixelSize == pixelSize;

  @override
  int get hashCode => Object.hash(runtimeType, file.path, scale, pixelSize);
}
