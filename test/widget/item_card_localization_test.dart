import 'dart:async';

import 'package:cleartray/domain/entities/entities.dart';
import 'package:cleartray/features/common/item_card.dart';
import 'package:cleartray/features/common/localized_due_label.dart';
import 'package:cleartray/features/common/localized_entity_labels.dart';
import 'package:cleartray/features/common/localized_recurrence.dart';
import 'package:cleartray/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

void main() {
  late TestEnv env;
  setUp(() async => env = await TestEnv.create());
  tearDown(() => env.dispose());

  for (final locale in AppLocalizations.supportedLocales) {
    testWidgets(
      '$locale item-card metadata and actions follow app language at 3x',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(360, 640));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final item = anItem(
          title: 'User title',
          status: ItemStatus.calendar,
          isTwoMin: true,
          dueAt: env.clock.now().subtract(const Duration(days: 2)),
          recurrence: Recurrence.weekly,
          recurrenceInterval: 2,
          recurrenceByWeekdays: [3, 1],
          recurrenceUntil: DateTime(2026, 5, 20),
          waitingOn: 'Alex',
        ).copyWith(energy: Energy.high, timeEstimateMinutes: 15);
        await pumpApp(
          tester,
          Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ItemCard(
                  item: item,
                  onComplete: () {},
                  onDelete: () {},
                  onMoveToProject: () {},
                ),
              ),
            ),
          ),
          env: env,
          locale: locale,
          textScaler: const TextScaler.linear(3),
        );
        await tester.pumpAndSettle();
        final l10n = AppLocalizations.of(tester.element(find.byType(ItemCard)));
        expect(find.text('User title'), findsOneWidget);
        expect(find.text(l10n.minutesShort(2)), findsOneWidget);
        expect(find.text(l10n.minutesShort(15)), findsOneWidget);
        expect(
          find.text(l10n.itemEnergyLabel(Energy.high.localizedLabel(l10n))),
          findsOneWidget,
        );
        expect(find.text(l10n.waitingOnPerson('Alex')), findsOneWidget);
        expect(
          find.text(localizedDueChipLabel(item.dueAt!, env.clock.now(), l10n)),
          findsOneWidget,
        );
        expect(
          find.bySemanticsLabel(l10n.markItemDone('User title')),
          findsOneWidget,
        );
        final recurrence = find.text(
          item.recurrenceRule!.localizedShortLabel(l10n),
        );
        await tester.ensureVisible(recurrence);
        await tester.pumpAndSettle();
        await tester.tap(recurrence);
        await tester.pumpAndSettle();
        expect(
          find.text(item.localizedRecurrenceSummary(l10n)),
          findsOneWidget,
        );
        ScaffoldMessenger.of(
          tester.element(find.byType(ItemCard)),
        ).hideCurrentSnackBar();
        await tester.pumpAndSettle();

        // Open the real panes so their translated labels are actually laid out.
        final controller = Slidable.of(
          tester.element(find.text('User title')),
        )!;
        unawaited(controller.openEndActionPane());
        await tester.pumpAndSettle();
        expect(find.widgetWithText(SlidableAction, l10n.done), findsOneWidget);
        expect(
          find.widgetWithText(SlidableAction, l10n.delete),
          findsOneWidget,
        );
        unawaited(controller.close());
        await tester.pumpAndSettle();
        unawaited(controller.openStartActionPane());
        await tester.pumpAndSettle();
        expect(
          find.widgetWithText(SlidableAction, l10n.project),
          findsOneWidget,
        );
        expect(tester.takeException(), null);
      },
    );
  }

  for (final locale in [
    const Locale('de'),
    const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
  ]) {
    testWidgets(
      'selection accessibility label preserves user title in $locale',
      (tester) async {
        await pumpApp(
          tester,
          Scaffold(
            body: ItemCard(
              item: anItem(title: 'User title'),
              selectionMode: true,
              selected: true,
              onToggleSelected: () {},
            ),
          ),
          env: env,
          locale: locale,
        );
        await tester.pumpAndSettle();
        final l10n = AppLocalizations.of(tester.element(find.byType(ItemCard)));
        expect(
          find.bySemanticsLabel(
            RegExp('^${RegExp.escape(l10n.selectItem('User title'))}'),
          ),
          findsOneWidget,
        );
        expect(find.text('User title'), findsOneWidget);
      },
    );
  }
}
