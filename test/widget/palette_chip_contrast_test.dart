import 'package:cleartray/app/theme.dart';
import 'package:cleartray/core/appearance_preferences.dart';
import 'package:cleartray/data/repositories/context_repository.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:cleartray/features/common/gtd_workflow_diagram.dart';
import 'package:cleartray/features/common/item_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

// Derive the rendered backdrop from widget layers rather than repeating the
// implementation's choice of surface. This catches wrong assumptions about
// highlighted stage cards and selected item cards.
Color renderedBackground(Element element, Color surface) {
  final colors = <Color>[];
  element.visitAncestorElements((ancestor) {
    final widget = ancestor.widget;
    if (widget is Container) {
      final decoration = widget.decoration;
      final color =
          widget.color ??
          (decoration is BoxDecoration ? decoration.color : null);
      if (color != null) colors.add(color);
    }
    if (widget is Material && widget.color != null) colors.add(widget.color!);
    return true;
  });
  return colors.reversed.fold(
    surface,
    (backdrop, fill) => Color.alphaBlend(fill, backdrop),
  );
}

void expectReadableText(WidgetTester tester, Finder within, Color surface) {
  var checked = 0;
  for (final element
      in find.descendant(of: within, matching: find.byType(Text)).evaluate()) {
    final text = element.widget as Text;
    final foreground = text.style?.color;
    if (foreground == null) continue;
    final background = renderedBackground(element, surface);
    expect(
      foreground.contrastAgainst(background),
      greaterThanOrEqualTo(4.5),
      reason: '${text.data}: $foreground on $background',
    );
    checked++;
  }
  expect(checked, greaterThan(0));
}

void main() {
  late TestEnv env;
  setUp(() async {
    env = await TestEnv.create();
    await ContextRepository(env.db).upsert(
      const GtdContext(
        id: 'pale',
        name: '@home',
        icon: 'home',
        color: 0xFFFFE082,
      ),
    );
  });
  tearDown(() => env.dispose());

  for (final palette in AppPalette.values) {
    for (final brightness in Brightness.values) {
      testWidgets(
        '${palette.id} ${brightness.name}: actual metadata and GTD chips stay readable',
        (tester) async {
          final theme = brightness == Brightness.dark
              ? AppTheme.dark(palette: palette)
              : AppTheme.light(palette: palette);
          for (final selected in [false, true]) {
            await pumpApp(
              tester,
              Scaffold(
                body: ItemCard(
                  item: Item(
                    status: ItemStatus.nextAction,
                    createdAt: env.clock.now(),
                    updatedAt: env.clock.now(),
                    id: 'contrast',
                    title: 'Task',
                    contextId: 'pale',
                    energy: Energy.high,
                    timeEstimateMinutes: 15,
                    waitingOn: 'Alex',
                    dueAt: env.clock.now().subtract(const Duration(days: 1)),
                    recurrence: Recurrence.weekly,
                  ),
                  selectionMode: selected,
                  selected: selected,
                ),
              ),
              env: env,
              theme: theme,
            );
            await tester.pumpAndSettle();
            expectReadableText(
              tester,
              find.byType(ItemCard),
              theme.colorScheme.surface,
            );
          }
          for (final stage in [null, ...GtdStage.values]) {
            await pumpApp(
              tester,
              Scaffold(
                body: SingleChildScrollView(
                  child: GtdWorkflowDiagram(highlight: stage),
                ),
              ),
              env: env,
              theme: theme,
            );
            await tester.pumpAndSettle();
            expectReadableText(
              tester,
              find.byType(GtdWorkflowDiagram),
              theme.colorScheme.surface,
            );
          }
        },
      );
    }
  }
}
