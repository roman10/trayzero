import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/gen/app_localizations.dart';
import '../settings/settings_controller.dart';

/// The round "mark done" control on an item card.
///
/// The visible ring is [diameter] wide, but the widget is a [targetSize]
/// square that captures taps across all of it, meeting the 48dp minimum touch
/// target. Tapping fills the ring, shows a check and (unless haptics are off in
/// settings) gives a selection click, then calls [onComplete] after
/// [feedbackDuration] so the confirmation is seen before the item leaves the
/// list.
class CompleteCircle extends ConsumerStatefulWidget {
  const CompleteCircle({
    required this.title,
    required this.onComplete,
    super.key,
  });

  static const double diameter = 24;
  static const double targetSize = 48;
  static const Duration feedbackDuration = Duration(milliseconds: 180);

  /// Title of the item being completed, for the accessibility label.
  final String title;
  final VoidCallback onComplete;

  @override
  ConsumerState<CompleteCircle> createState() => _CompleteCircleState();
}

class _CompleteCircleState extends ConsumerState<CompleteCircle> {
  bool _completing = false;

  Future<void> _complete() async {
    if (_completing) return;
    // Captured before the delay: the card may be rebuilt away meanwhile, but
    // the completion the user asked for must still happen.
    final onComplete = widget.onComplete;
    setState(() => _completing = true);
    if (ref.read(hapticsEnabledProvider)) {
      unawaited(HapticFeedback.selectionClick());
    }
    await Future<void>.delayed(CompleteCircle.feedbackDuration);
    onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final ringColor = _completing ? scheme.primary : scheme.outline;
    return Semantics(
      label: AppLocalizations.of(context).markItemDone(widget.title),
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _complete,
        child: SizedBox.square(
          dimension: CompleteCircle.targetSize,
          child: Center(
            child: AnimatedContainer(
              duration: CompleteCircle.feedbackDuration,
              width: CompleteCircle.diameter,
              height: CompleteCircle.diameter,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _completing ? scheme.primary : Colors.transparent,
                border: Border.all(color: ringColor, width: 1.5),
              ),
              child: _completing
                  ? Icon(Icons.check, size: 16, color: scheme.onPrimary)
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
