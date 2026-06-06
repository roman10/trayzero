import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cleartray/app/theme.dart';
import 'package:cleartray/features/common/notes_text.dart';

void main() {
  Future<Linkify> pump(
    WidgetTester tester,
    String text, {
    int? maxLines,
    TextOverflow? overflow,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: NotesText(
            text: text,
            maxLines: maxLines,
            overflow: overflow,
            baseStyle: const TextStyle(fontSize: 13),
          ),
        ),
      ),
    );
    return tester.widget<Linkify>(find.byType(Linkify));
  }

  testWidgets('feeds notes through a URL + email Linkify', (tester) async {
    const notes =
        'See https://example.com or mail someone@example.com about it';
    final linkify = await pump(tester, notes);

    expect(linkify.text, notes);
    expect(
      linkify.linkifiers.map((l) => l.runtimeType),
      containsAll(<Type>[UrlLinkifier, EmailLinkifier]),
    );
  });

  testWidgets('styles links in the theme primary colour, underlined',
      (tester) async {
    final linkify = await pump(tester, 'go https://example.com now');

    final scheme = AppTheme.light().colorScheme;
    expect(linkify.linkStyle?.color, scheme.primary);
    expect(linkify.linkStyle?.decoration, TextDecoration.underline);
    // Plain text keeps the caller's base style.
    expect(linkify.style?.fontSize, 13);
  });

  testWidgets('respects the OS text scale (not Linkify\'s hardcoded 1.0)',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(1.5)),
          child: Scaffold(
            body: NotesText(
              text: 'scaled https://example.com note',
              baseStyle: TextStyle(fontSize: 13),
            ),
          ),
        ),
      ),
    );

    final linkify = tester.widget<Linkify>(find.byType(Linkify));
    expect(linkify.textScaleFactor, closeTo(1.5, 0.001));
  });

  testWidgets('passes maxLines and overflow through for card truncation',
      (tester) async {
    final linkify = await pump(
      tester,
      'long https://example.com note',
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );

    expect(linkify.maxLines, 2);
    expect(linkify.overflow, TextOverflow.ellipsis);
  });
}
