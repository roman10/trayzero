import 'dart:io';

import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations.dart';

/// A single image to show in the full-screen viewer. Carries an already-resolved
/// absolute [path] so the viewer stays dumb (no Riverpod, no repo, no async).
class ViewerImage {
  const ViewerImage({required this.path, required this.heroTag, this.name});

  final String path;
  final String? name;

  /// Shared-element tag; matches the thumbnail's [Hero] tag for the open/close
  /// transition. Use the attachment id.
  final String heroTag;
}

/// Opens a full-screen, zoomable image viewer. Swipe between [images] when an
/// item has several photos. Returns when the viewer is dismissed.
Future<void> showImageViewer(
  BuildContext context, {
  required List<ViewerImage> images,
  int initialIndex = 0,
}) {
  return Navigator.of(context, rootNavigator: true).push(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) =>
          _ImageViewerScreen(images: images, initialIndex: initialIndex),
    ),
  );
}

class _ImageViewerScreen extends StatefulWidget {
  const _ImageViewerScreen({required this.images, required this.initialIndex});

  final List<ViewerImage> images;
  final int initialIndex;

  @override
  State<_ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<_ImageViewerScreen> {
  late final PageController _controller =
      PageController(initialPage: widget.initialIndex);
  late int _index = widget.initialIndex;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final current = widget.images[_index];
    final showCounter = widget.images.length > 1;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: l10n.imageViewerClose,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          showCounter
              ? l10n.imageViewerCounter(_index + 1, widget.images.length)
              : (current.name ?? ''),
          style: const TextStyle(fontSize: 15),
        ),
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: widget.images.length,
        onPageChanged: (i) => setState(() => _index = i),
        itemBuilder: (_, i) {
          final img = widget.images[i];
          return InteractiveViewer(
            minScale: 1,
            maxScale: 4,
            child: Center(
              child: Hero(
                tag: img.heroTag,
                child: Image.file(
                  File(img.path),
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.broken_image_outlined,
                    color: Colors.white54,
                    size: 64,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
