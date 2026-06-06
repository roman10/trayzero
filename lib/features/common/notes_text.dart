import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

/// Renders item notes as text with tappable URLs and email addresses.
///
/// Links are highlighted in the app's primary colour and underlined; tapping
/// one opens it externally (browser / mail composer). Non-link text uses
/// [baseStyle], so each card keeps its own font size and colour.
///
/// Link spans carry their own tap recognizers, so a tap on a link opens the
/// link while a tap elsewhere still bubbles to an enclosing card `InkWell`.
class NotesText extends StatelessWidget {
  const NotesText({
    required this.text,
    required this.baseStyle,
    this.maxLines,
    this.overflow,
    super.key,
  });

  final String text;
  final TextStyle baseStyle;
  final int? maxLines;
  final TextOverflow? overflow;

  Future<void> _open(BuildContext context, LinkableElement link) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final uri = Uri.parse(link.url);
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) {
        messenger.showSnackBar(
          const SnackBar(content: Text("Couldn't open link")),
        );
      }
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text("Couldn't open link")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // flutter_linkify's Linkify hardcodes textScaleFactor: 1.0, which would
    // make notes ignore the OS font-size setting (unlike the plain Text it
    // replaced). Derive the linear factor at the card's font size so links
    // scale with accessibility text settings like the rest of the app.
    final fontSize = baseStyle.fontSize ?? 14.0;
    final textScaleFactor =
        MediaQuery.textScalerOf(context).scale(fontSize) / fontSize;
    return Linkify(
      text: text,
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
      textScaleFactor: textScaleFactor,
      linkifiers: const [UrlLinkifier(), EmailLinkifier()],
      style: baseStyle,
      linkStyle: baseStyle.copyWith(
        color: scheme.primary,
        decoration: TextDecoration.underline,
        decorationColor: scheme.primary,
      ),
      onOpen: (link) => _open(context, link),
    );
  }
}
