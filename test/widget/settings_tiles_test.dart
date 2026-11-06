import 'dart:ui' show SemanticsAction, SemanticsActionEvent;

import 'package:cleartray/features/settings/settings_tiles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'settings action semantics stay within their row beside a switch',
    (tester) async {
      final semantics = tester.ensureSemantics();

      tester.view.physicalSize = const Size(375, 667);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var exports = 0;
      var switches = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: Scaffold(
            body: ListView(
              children: [
                SettingsGroup(
                  label: 'Back up',
                  children: [
                    SettingsSwitchRow(
                      icon: Icons.folder,
                      title: 'Automatic backups',
                      subtitle: 'Save snapshots to a folder',
                      value: false,
                      onChanged: (_) => switches++,
                    ),
                    SettingsRow(
                      key: const ValueKey('export'),
                      icon: Icons.ios_share,
                      title: 'Export a copy',
                      subtitle: 'Share a backup file once',
                      chevron: false,
                      onTap: () => exports++,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
      final export = tester.getSemantics(find.text('Export a copy'));
      final row = tester.getRect(find.byKey(const ValueKey('export')));
      expect(export.label, 'Export a copy\nShare a backup file once');
      expect(export.rect.size, row.size);
      expect(export.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
      // iOS automation (and accessibility pointer interaction) targets the
      // accessibility frame's center, so it must hit Export, not the switch.
      var exportFrame = export.rect;
      for (var node = export; node.parent != null; node = node.parent!) {
        if (node.transform != null) {
          exportFrame = MatrixUtils.transformRect(node.transform!, exportFrame);
        }
      }
      expect(exportFrame, row);
      await tester.tapAt(exportFrame.center);
      await tester.pump();
      expect(exports, 1);
      expect(switches, 0);
      tester.binding.performSemanticsAction(
        SemanticsActionEvent(
          nodeId: export.id,
          viewId: tester.view.viewId,
          type: SemanticsAction.tap,
        ),
      );
      await tester.pump();
      expect(exports, 2);
      expect(switches, 0);
      final header = tester.getSemantics(find.text('Back up'));
      expect(header.label, 'Back up');
      expect(header.getSemanticsData().hasAction(SemanticsAction.tap), isFalse);
      semantics.dispose();
    },
  );
}
