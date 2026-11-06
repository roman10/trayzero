import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/gen/app_localizations.dart';

/// Public legal pages, linked from Support and About so the app's purchase
/// flow links to them (required for auto-renewable subscriptions on iOS).
const String kPrivacyPolicyUrl = 'https://trayzero.app/privacy';
const String kTermsOfUseUrl = 'https://trayzero.app/terms';

/// Opens a legal page externally; mirrors [NotesText]'s launch idiom and
/// shows a snackbar if the URL can't be opened.
Future<void> openLegalUrl(BuildContext context, String url) async {
  final messenger = ScaffoldMessenger.of(context);
  final message = AppLocalizations.of(context).moreCouldntOpenLink;
  try {
    final ok = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!ok) {
      messenger.showSnackBar(SnackBar(content: Text(message)));
    }
  } catch (_) {
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }
}

/// "Privacy policy · Terms of use" link pair.
class LegalLinksRow extends StatelessWidget {
  const LegalLinksRow({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        TextButton(
          onPressed: () => openLegalUrl(context, kPrivacyPolicyUrl),
          child: Text(l10n.legalPrivacyPolicy),
        ),
        const Text('·'),
        TextButton(
          onPressed: () => openLegalUrl(context, kTermsOfUseUrl),
          child: Text(l10n.legalTermsOfUse),
        ),
      ],
    );
  }
}
