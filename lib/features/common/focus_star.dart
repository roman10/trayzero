import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../core/clock.dart';
import '../../domain/entities/entities.dart';
import '../../domain/today_focus.dart';
import '../../l10n/gen/app_localizations.dart';
import '../settings/settings_controller.dart';

/// The Today star on an item card (ADR 0007). The visible icon is [iconSize]
/// but the tap target is a [targetSize] square, like [CompleteCircle].
class FocusStar extends ConsumerWidget {
  const FocusStar({
    required this.title,
    required this.focused,
    required this.onToggle,
    super.key,
  });

  static const double iconSize = 22;
  static const double targetSize = 48;

  final String title;
  final bool focused;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    void toggle() {
      if (ref.read(hapticsEnabledProvider)) {
        unawaited(HapticFeedback.selectionClick());
      }
      onToggle();
    }

    return Tooltip(
      message: focused ? l.focusRemoveTooltip : l.focusAddTooltip,
      excludeFromSemantics: true,
      child: Semantics(
        label: focused ? l.focusRemoveItem(title) : l.focusAddItem(title),
        button: true,
        toggled: focused,
        // iOS bridges toggled semantics through a native switch, which needs
        // an explicit enabled state as well as the accessibility tap action.
        enabled: true,
        excludeSemantics: true,
        onTap: toggle,
        child: InkResponse(
          radius: targetSize / 2,
          onTap: toggle,
          child: SizedBox.square(
            dimension: targetSize,
            child: Icon(
              focused ? Icons.star_rounded : Icons.star_outline_rounded,
              size: iconSize,
              color: focused ? scheme.primary : scheme.outline,
            ),
          ),
        ),
      ),
    );
  }
}

/// Flips [item]'s Today star: stars it unless it is already focused today.
/// A carried-over Item is re-committed to today. Failures surface as a
/// snackbar; lists re-render from the database, so nothing needs rollback.
Future<void> toggleTodayFocus(
  BuildContext context,
  WidgetRef ref,
  Item item,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final error = AppLocalizations.of(context).focusError;
  final focused = !isFocusedToday(item, ref.read(clockProvider).now());
  try {
    await ref.read(setTodayFocusProvider).call([item], focused: focused);
  } catch (_) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(error)));
  }
}
