import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/gen/app_localizations.dart';
import 'settings_tiles.dart';

const trayzeroSupportEmail = 'support@trayzero.app';

Uri trayzeroRatingUrl(TargetPlatform platform) => Uri.parse(
  platform == TargetPlatform.iOS || platform == TargetPlatform.macOS
      ? 'https://apps.apple.com/app/id6771756447?action=write-review'
      : 'https://play.google.com/store/apps/details?id=app.cleartray',
);

final externalLinkLauncherProvider = Provider<Future<bool> Function(Uri)>(
  (ref) =>
      (uri) => launchUrl(uri, mode: LaunchMode.externalApplication),
);

/// Both actions are always available, independent of automatic prompt quotas.
class FeedbackSettingsRows extends ConsumerWidget {
  const FeedbackSettingsRows({super.key});

  Future<void> _open(
    BuildContext context,
    WidgetRef ref,
    Uri uri, {
    bool feedback = false,
  }) async {
    var opened = false;
    try {
      opened = await ref.read(externalLinkLauncherProvider)(uri);
    } catch (_) {
      // Fall through to an actionable fallback when no mail app is installed.
    }
    if (opened || !context.mounted) return;
    final l = AppLocalizations.of(context);
    if (feedback) {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l.sendFeedback),
          content: const SelectableText(trayzeroSupportEmail),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l.ok),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.moreCouldntOpenLink)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return Column(
      children: [
        SettingsRow(
          icon: Icons.star_outline,
          title: l.rateTrayzero,
          onTap: () =>
              _open(context, ref, trayzeroRatingUrl(defaultTargetPlatform)),
        ),
        SettingsRow(
          icon: Icons.mail_outline,
          title: l.sendFeedback,
          onTap: () => _open(
            context,
            ref,
            Uri(
              scheme: 'mailto',
              path: trayzeroSupportEmail,
              query: 'subject=${Uri.encodeComponent('Trayzero feedback')}',
            ),
            feedback: true,
          ),
        ),
      ],
    );
  }
}
