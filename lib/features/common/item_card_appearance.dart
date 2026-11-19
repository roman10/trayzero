import 'package:flutter/material.dart';

/// Shared visual language for task cards, including compact planning cards.
abstract final class ItemCardAppearance {
  static const padding = 14.0;
  static const borderWidth = 1.0;
  static const radius = BorderRadius.all(Radius.circular(16));
  static const titleStyle = TextStyle(
    fontSize: 15.5,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  static BoxDecoration decoration(
    ColorScheme scheme, {
    bool highlighted = false,
  }) => BoxDecoration(
    color: highlighted ? scheme.primaryContainer : scheme.surfaceContainerLow,
    borderRadius: radius,
    border: Border.all(
      color: highlighted
          ? scheme.primary
          : scheme.outlineVariant.withValues(alpha: 0.5),
      width: borderWidth,
    ),
  );
}
