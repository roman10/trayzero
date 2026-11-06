import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations.dart';

/// Shared "couldn't load" state for `AsyncValue.when(error:)` branches.
///
/// The raw exception is only written to the debug log; users get a calm,
/// localized message and (when [onRetry] is given) a Retry button.
class ErrorView extends StatefulWidget {
  const ErrorView({super.key, this.error, this.stackTrace, this.onRetry});

  final Object? error;
  final StackTrace? stackTrace;
  final VoidCallback? onRetry;

  @override
  State<ErrorView> createState() => _ErrorViewState();
}

class _ErrorViewState extends State<ErrorView> {
  @override
  void initState() {
    super.initState();
    if (widget.error != null) {
      debugPrint('ErrorView: ${widget.error}');
      if (widget.stackTrace != null) debugPrint('${widget.stackTrace}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 40,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              l.errorLoadTitle,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              l.errorLoadBody,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (widget.onRetry != null) ...[
              const SizedBox(height: 12),
              TextButton(onPressed: widget.onRetry, child: Text(l.retry)),
            ],
          ],
        ),
      ),
    );
  }
}
