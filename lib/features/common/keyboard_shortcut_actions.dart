import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/gen/app_localizations.dart';

const searchShortcut = SingleActivator(
  LogicalKeyboardKey.keyF,
  meta: true,
  includeRepeats: false,
);

const captureShortcut = SingleActivator(
  LogicalKeyboardKey.keyN,
  meta: true,
  includeRepeats: false,
);

String? _shortcutHint(BuildContext context, SingleActivator shortcut) {
  final platform = Theme.of(context).platform;
  if (platform != TargetPlatform.iOS && platform != TargetPlatform.macOS) {
    return null;
  }

  final media = MediaQuery.of(context);
  final scale = math.max(1.0, media.textScaler.scale(12) / 12);
  // Leave room for the glyph in the fixed-height capture button and preserve
  // the compact controls on narrow windows and short landscape phones.
  if (scale > 2 || media.size.shortestSide < 600 * scale) return null;
  return '⌘${shortcut.trigger.keyLabel}';
}

class SearchShortcutButton extends StatelessWidget {
  const SearchShortcutButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final hint = _shortcutHint(context, searchShortcut);
    const icon = Icon(Icons.search);
    return IconButton(
      tooltip: AppLocalizations.of(context).search,
      onPressed: onPressed,
      icon: hint == null
          ? icon
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [icon, const SizedBox(width: 4), _Glyph(hint)],
            ),
    );
  }
}

class CaptureShortcutButton extends StatelessWidget {
  const CaptureShortcutButton({
    required this.heroTag,
    required this.onPressed,
    this.extended = false,
    super.key,
  });

  final String heroTag;
  final VoidCallback onPressed;
  final bool extended;

  @override
  Widget build(BuildContext context) {
    final capture = AppLocalizations.of(context).capture;
    final hint = _shortcutHint(context, captureShortcut);
    const icon = Icon(Icons.add);

    return extended
        ? FloatingActionButton.extended(
            heroTag: heroTag,
            onPressed: onPressed,
            icon: icon,
            label: hint == null
                ? Text(capture)
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(capture),
                      const SizedBox(width: 8),
                      _Glyph(hint),
                    ],
                  ),
          )
        : FloatingActionButton(
            heroTag: heroTag,
            onPressed: onPressed,
            tooltip: capture,
            child: hint == null
                ? icon
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [icon, _Glyph(hint)],
                  ),
          );
  }
}

class _Glyph extends StatelessWidget {
  const _Glyph(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Semantics(
    hint: text,
    excludeSemantics: true,
    child: Text(
      text,
      textDirection: TextDirection.ltr,
      style: const TextStyle(fontSize: 12, height: 1),
    ),
  );
}
