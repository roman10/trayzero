// path_provider interfaces are pulled in transitively; imported only to keep
// the harness happy. The viewer itself is provider-free.
import 'dart:convert';
import 'dart:io';

import 'package:cleartray/app/theme.dart';
import 'package:cleartray/features/common/image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

// A 1x1 transparent PNG so Image.file has real bytes to decode in tests.
const _pngBase64 =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==';

class _Host extends StatelessWidget {
  const _Host(this.images);
  final List<ViewerImage> images;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => showImageViewer(context, images: images),
          child: const Text('open'),
        ),
      ),
    );
  }
}

void main() {
  late TestEnv env;
  late Directory dir;
  late List<ViewerImage> images;

  setUp(() async {
    env = await TestEnv.create();
    dir = Directory.systemTemp.createTempSync('viewer_');
    final bytes = base64Decode(_pngBase64);
    images = [
      for (var i = 0; i < 2; i++)
        ViewerImage(
          path: (File('${dir.path}/img$i.png')..writeAsBytesSync(bytes)).path,
          name: 'img$i',
          heroTag: 'tag$i',
        ),
    ];
  });

  tearDown(() {
    env.dispose();
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  testWidgets('opens a full-screen viewer with a page counter and dismisses', (
    tester,
  ) async {
    await pumpApp(tester, _Host(images), env: env);

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.byType(PageView), findsOneWidget);
    expect(find.text('1 / 2'), findsOneWidget);

    // Close pops the viewer.
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(find.byType(PageView), findsNothing);
  });

  for (final brightness in Brightness.values) {
    for (final multiple in [false, true]) {
      testWidgets(
        'title stays readable on black in $brightness with multiple=$multiple',
        (tester) async {
          await pumpApp(
            tester,
            _Host(multiple ? images : [images.first]),
            env: env,
            theme: brightness == Brightness.light
                ? AppTheme.light()
                : AppTheme.dark(),
          );
          await tester.tap(find.text('open'));
          await tester.pumpAndSettle();

          final title = find.text(multiple ? '1 / 2' : images.first.name!);
          final paragraph = tester.renderObject<RenderParagraph>(title);
          final renderedColor = paragraph.text.style!.color!;
          final appBar = tester.widget<AppBar>(find.byType(AppBar));
          expect(appBar.backgroundColor, Colors.black);
          expect(
            renderedColor.contrastAgainst(appBar.backgroundColor!),
            greaterThanOrEqualTo(4.5),
          );
        },
      );
    }
  }
}
