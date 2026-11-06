import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Keeps a selected result visible after a source list becomes a narrower
/// workspace. Lazy lists seek by bounded offset search until the item builds;
/// variable-height text remains free to wrap at the user's text size.
class WorkspaceScrollController extends ScrollController {
  WorkspaceScrollController({super.initialScrollOffset});

  final _keys = <String, GlobalKey>{};
  Map<String, int> _indices = {};
  String? _selected;
  int _signature = 0;
  bool _disposed = false;
  bool _seeking = false;
  int _generation = 0;
  (Size, double, TextDirection, bool)? _viewport;

  void viewportChanged(
    Size size,
    double textScale,
    TextDirection direction,
    bool active,
  ) {
    final viewport = (size, textScale, direction, active);
    if (_viewport == viewport) return;
    _viewport = viewport;
    _generation++;
    _seeking = false;
    revealSelection();
  }

  GlobalKey itemKey(String id) => _keys.putIfAbsent(id, GlobalKey.new);

  void prepare(String? selected, List<String> ids) {
    final signature = Object.hashAll(ids);
    if (_selected == selected && _signature == signature) return;
    _selected = selected;
    _signature = signature;
    _indices = selected == null
        ? {}
        : {for (var i = 0; i < ids.length; i++) ids[i]: i};
    _keys.removeWhere((id, _) => !_indices.containsKey(id));
    _generation++;
    _seeking = false;
    revealSelection();
  }

  void revealSelection() {
    final selected = _selected;
    if (_disposed ||
        _seeking ||
        selected == null ||
        !_indices.containsKey(selected)) {
      return;
    }
    _seeking = true;
    final generation = _generation;
    var lower = 0.0;
    double? aboveSelection;
    var attempts = 0;
    void seek(Duration _) {
      if (_disposed || generation != _generation) return;
      if (_viewport?.$4 == false ||
          !hasClients ||
          !position.hasContentDimensions ||
          attempts++ >= 24) {
        _seeking = false;
        return;
      }
      final target = _keys[selected]?.currentContext?.findRenderObject();
      if (target != null && target.attached) {
        final viewport = RenderAbstractViewport.of(target);
        final start = viewport.getOffsetToReveal(target, 0).offset;
        final end = viewport.getOffsetToReveal(target, 1).offset;
        final offset = start < position.pixels
            ? start
            : end > position.pixels
            ? end
            : position.pixels;
        final clamped = offset.clamp(
          position.minScrollExtent,
          position.maxScrollExtent,
        );
        if (clamped != position.pixels) position.jumpTo(clamped);
        _seeking = false;
        return;
      }
      final built = _keys.entries
          .where((entry) => entry.value.currentContext != null)
          .map((entry) => _indices[entry.key])
          .whereType<int>()
          .toList();
      if (built.isEmpty) {
        _seeking = false;
        return;
      }
      final index = _indices[selected]!;
      if (index > built.reduce(math.max)) {
        lower = position.pixels;
      } else if (index < built.reduce(math.min)) {
        aboveSelection = position.pixels;
      } else {
        _seeking = false;
        return;
      }
      // Sliver estimates may grow as new rows are measured.
      final upper = math.min(
        aboveSelection ?? position.maxScrollExtent,
        position.maxScrollExtent,
      );
      final next = ((lower + upper) / 2).clamp(0.0, position.maxScrollExtent);
      if ((next - position.pixels).abs() < .5) {
        _seeking = false;
        return;
      }
      position.jumpTo(next);
      WidgetsBinding.instance.addPostFrameCallback(seek);
    }

    WidgetsBinding.instance.addPostFrameCallback(seek);
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

class WorkspaceListViewport extends StatelessWidget {
  const WorkspaceListViewport({
    required this.controller,
    required this.child,
    super.key,
  });
  final WorkspaceScrollController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      controller.viewportChanged(
        constraints.biggest,
        MediaQuery.textScalerOf(context).scale(14),
        Directionality.of(context),
        TickerMode.valuesOf(context).enabled,
      );
      return child;
    },
  );
}
