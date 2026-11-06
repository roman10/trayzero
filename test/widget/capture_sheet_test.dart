import 'dart:async';

import 'package:cleartray/application/providers.dart';
import 'package:cleartray/core/dictation.dart';
import 'package:cleartray/data/repositories/item_repository.dart';
import 'package:cleartray/data/repositories/tag_repository.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:cleartray/features/capture/capture_sheet.dart';
import 'package:cleartray/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

class ControlledItemRepository extends ItemRepository {
  ControlledItemRepository(super.db, super.clock);
  final attempts = <Item>[];
  Completer<void>? gate;
  bool fail = false;

  @override
  Future<void> upsert(Item item) async {
    attempts.add(item);
    await gate?.future;
    if (fail) throw StateError('write failed');
    await super.upsert(item);
  }
}

class FakeDictation implements Dictation {
  int starts = 0;
  int stops = 0;
  int cancels = 0;
  bool available = true;
  bool failStart = false;
  bool failCancel = false;
  Completer<bool>? startGate;
  Completer<void>? cancelGate;
  void Function(String)? onText;
  void Function()? onStopped;
  void Function()? onError;

  @override
  Future<bool> start({
    required void Function(String text) onText,
    required void Function() onStopped,
    required void Function() onError,
  }) async {
    starts++;
    this.onText = onText;
    this.onStopped = onStopped;
    this.onError = onError;
    if (failStart) throw StateError('speech failed');
    return startGate == null ? available : await startGate!.future;
  }

  @override
  Future<void> stop() async {
    stops++;
    onStopped?.call();
  }

  @override
  Future<void> cancel() async {
    cancels++;
    await cancelGate?.future;
    if (failCancel) throw StateError('cancel failed');
  }
}

void main() {
  late TestEnv env;
  late ControlledItemRepository items;
  late FakeDictation dictation;
  int sessionsCreated = 0;
  Item? captured;

  setUp(() async {
    env = await TestEnv.create();
    items = ControlledItemRepository(env.db, env.clock);
    dictation = FakeDictation();
    sessionsCreated = 0;
    captured = null;
  });
  tearDown(() => env.dispose());

  Future<void> openCapture(
    WidgetTester tester, {
    String? initialText,
    Locale? locale,
    TextScaler? textScaler,
  }) async {
    await pumpApp(
      tester,
      Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              captured = await showCaptureSheet(
                context,
                initialText: initialText,
              );
            },
            child: const Text('Open capture'),
          ),
        ),
      ),
      env: env,
      locale: locale,
      textScaler: textScaler,
      extraOverrides: [
        itemRepositoryProvider.overrideWithValue(items),
        dictationFactoryProvider.overrideWithValue(() {
          sessionsCreated++;
          return dictation;
        }),
      ],
    );
    await tester.tap(find.text('Open capture'));
    await tester.pumpAndSettle();
  }

  Finder getTitle() => find.byType(TextField).first;
  Finder getNotes() => find.byType(TextField).last;
  Finder iconButton(String tooltip) => find.byWidgetPredicate(
    (widget) => widget is IconButton && widget.tooltip == tooltip,
  );

  testWidgets('opening and typing never initializes speech', (tester) async {
    await openCapture(tester, initialText: 'Shared idea');
    await tester.enterText(getNotes(), 'Extra detail');
    expect(sessionsCreated, 0);
    expect(dictation.starts, 0);
    expect(find.byTooltip('Dictate'), findsOneWidget);
    await tester.tap(find.text('Add to inbox'));
    await tester.pumpAndSettle();
    expect(captured!.title, 'Shared idea');
    expect(captured!.notes, 'Extra detail');
    expect(captured!.status, ItemStatus.inbox);
    expect(sessionsCreated, 0);
  });

  testWidgets('rapid taps and keyboard submission persist only one item', (
    tester,
  ) async {
    items.gate = Completer<void>();
    await openCapture(tester);
    await tester.enterText(getTitle(), '  Buy groceries  ');
    await tester.enterText(getNotes(), '  Milk and bread  ');
    final save = tester
        .widget<FilledButton>(find.byType(FilledButton))
        .onPressed!;
    final submit = tester.widget<TextField>(getTitle()).onSubmitted!;
    save();
    save();
    submit('Buy groceries');
    await tester.pump();
    expect(items.attempts, hasLength(1));
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      null,
    );
    expect(tester.widget<TextField>(getTitle()).enabled, false);
    expect(tester.widget<TextField>(getNotes()).enabled, false);

    // Back, barrier taps, and drag must not dismiss an unresolved write.
    await tester.binding.handlePopRoute();
    await tester.tapAt(const Offset(10, 10));
    await tester.drag(find.text('Brain dump'), const Offset(0, 400));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(CaptureSheet), findsOneWidget);

    items.gate!.complete();
    await tester.pumpAndSettle();
    final inbox = await items.allActive();
    expect(inbox, hasLength(1));
    expect(inbox.single.title, 'Buy groceries');
    expect(inbox.single.notes, 'Milk and bread');
    expect(captured!.id, inbox.single.id);
    expect(find.text('Open capture'), findsOneWidget);
    expect(tester.takeException(), null);
  });

  testWidgets('failed save preserves the draft and can be retried', (
    tester,
  ) async {
    items.fail = true;
    await openCapture(tester, initialText: 'Keep this idea');
    await tester.enterText(getNotes(), 'Important details');
    await tester.tap(find.text('Add to inbox'));
    await tester.pumpAndSettle();
    expect(
      find.text("Couldn't save your changes. Please try again."),
      findsOneWidget,
    );
    expect(
      tester.widget<TextField>(getTitle()).controller!.text,
      'Keep this idea',
    );
    expect(
      tester.widget<TextField>(getNotes()).controller!.text,
      'Important details',
    );
    expect(await items.allActive(), isEmpty);
    expect(tester.takeException(), null);

    items.fail = false;
    await tester.tap(find.text('Add to inbox'));
    await tester.pumpAndSettle();
    expect((await items.allActive()).single.notes, 'Important details');
    expect(captured!.title, 'Keep this idea');
  });

  testWidgets(
    'empty capture stays open without writing or initializing speech',
    (tester) async {
      await openCapture(tester, initialText: '   ');
      await tester.tap(find.text('Add to inbox'));
      await tester.pump();
      expect(find.text('Enter something to capture'), findsOneWidget);
      expect(items.attempts, isEmpty);
      expect(sessionsCreated, 0);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
    },
  );

  testWidgets('microphone starts lazily and receives results and stop status', (
    tester,
  ) async {
    await openCapture(tester);
    await tester.tap(find.byTooltip('Dictate'));
    await tester.pumpAndSettle();
    expect(dictation.starts, 1);
    expect(sessionsCreated, 1);
    dictation.onText!('Call the dentist');
    await tester.pump();
    expect(
      tester.widget<TextField>(getTitle()).controller!.text,
      'Call the dentist',
    );
    expect(find.byTooltip('Stop dictation'), findsOneWidget);
    dictation.onStopped!();
    await tester.pump();
    expect(find.byTooltip('Dictate'), findsOneWidget);
    await tester.tap(find.byTooltip('Dictate'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Stop dictation'));
    await tester.pumpAndSettle();
    expect(dictation.stops, 1);
    expect(dictation.starts, 2);
    expect(sessionsCreated, 1);
  });

  for (final throws in [false, true]) {
    testWidgets('unavailable speech (throws: $throws) still permits typing', (
      tester,
    ) async {
      dictation.available = false;
      dictation.failStart = throws;
      await openCapture(tester, initialText: 'Typed draft');
      await tester.tap(find.byTooltip('Dictate'));
      await tester.pumpAndSettle();
      expect(
        find.text('Dictation is unavailable. You can still type your capture.'),
        findsOneWidget,
      );
      expect(
        tester.widget<TextField>(getTitle()).controller!.text,
        'Typed draft',
      );
      await tester.tap(find.text('Add to inbox'));
      await tester.pumpAndSettle();
      expect(captured!.title, 'Typed draft');
      expect(tester.takeException(), null);
    });
  }

  testWidgets('repeated microphone taps cannot overlap a pending start', (
    tester,
  ) async {
    dictation.startGate = Completer<bool>();
    await openCapture(tester);
    final start = tester.widget<IconButton>(iconButton('Dictate')).onPressed!;
    start();
    start();
    await tester.pump();
    expect(dictation.starts, 1);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      null,
    );
    dictation.startGate!.complete(true);
    await tester.pumpAndSettle();
    expect(find.byTooltip('Stop dictation'), findsOneWidget);
  });

  testWidgets(
    'closing during speech startup ignores late results and failures',
    (tester) async {
      dictation.startGate = Completer<bool>();
      await openCapture(tester);
      await tester.tap(find.byTooltip('Dictate'));
      await tester.pump();
      await tester.tap(find.byTooltip('Cancel'));
      await tester.pumpAndSettle();
      dictation.onText!('Late result');
      dictation.onStopped!();
      dictation.onError!();
      dictation.startGate!.completeError(
        StateError('late initialization error'),
      );
      await tester.pumpAndSettle();
      expect(dictation.cancels, 1);
      expect(tester.takeException(), null);
      expect(find.byType(CaptureSheet), findsNothing);
      expect(items.attempts, isEmpty);
    },
  );

  testWidgets(
    'saving stops speech and late recognition cannot change the draft',
    (tester) async {
      items.gate = Completer<void>();
      dictation.failCancel = true;
      await openCapture(tester);
      await tester.tap(find.byTooltip('Dictate'));
      await tester.pumpAndSettle();
      dictation.onText!('Original speech');
      await tester.tap(find.text('Add to inbox'));
      await tester.pump();
      dictation.onText!('Late speech');
      dictation.onError!();
      await tester.pump();
      expect(items.attempts.single.title, 'Original speech');
      expect(
        tester.widget<TextField>(getTitle()).controller!.text,
        'Original speech',
      );
      expect(dictation.cancels, 1);
      items.gate!.complete();
      await tester.pumpAndSettle();
      expect(captured!.title, 'Original speech');
      expect(tester.takeException(), null);
    },
  );

  testWidgets('forced disposal during a write never accesses a disposed ref', (
    tester,
  ) async {
    items.gate = Completer<void>();
    await openCapture(tester, initialText: 'Persist this');
    await tester.tap(find.text('Add to inbox'));
    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());
    items.gate!.complete();
    await tester.pumpAndSettle();
    expect((await items.allActive()).single.title, 'Persist this');
    expect(tester.takeException(), null);
  });

  testWidgets('idle capture can still be dismissed by tapping outside', (
    tester,
  ) async {
    await openCapture(tester);
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(find.byType(CaptureSheet), findsNothing);
    expect(captured, null);
    expect(items.attempts, isEmpty);
  });

  testWidgets(
    'Add & continue saves distinct items, clears fields and refocuses',
    (tester) async {
      await openCapture(tester, initialText: '  First thought  ');
      await tester.enterText(getNotes(), '  First note  ');
      await tester.tap(find.text('Add & continue'));
      await tester.pumpAndSettle();
      expect(find.byType(CaptureSheet), findsOneWidget);
      expect(tester.widget<TextField>(getTitle()).controller!.text, isEmpty);
      expect(tester.widget<TextField>(getNotes()).controller!.text, isEmpty);
      expect(tester.widget<TextField>(getTitle()).focusNode!.hasFocus, true);
      expect(find.text('1 item added to inbox'), findsOneWidget);
      expect(captured, null);
      expect(sessionsCreated, 0);

      await tester.enterText(getTitle(), 'Second thought');
      await tester.tap(find.text('Add & continue'));
      await tester.pumpAndSettle();
      expect(find.text('2 items added to inbox'), findsOneWidget);
      await tester.enterText(getTitle(), 'Final thought');
      await tester.tap(find.text('Add to inbox'));
      await tester.pumpAndSettle();
      expect(find.byType(CaptureSheet), findsNothing);
      expect(items.attempts.map((item) => item.title), [
        'First thought',
        'Second thought',
        'Final thought',
      ]);
      expect(items.attempts.map((item) => item.id).toSet(), hasLength(3));
      expect(items.attempts.first.notes, 'First note');
      expect(items.attempts[1].notes, null);
      expect(items.attempts.last.notes, null);
      expect(await items.allActive(), hasLength(3));
      expect(captured!.id, items.attempts.last.id);
    },
  );

  testWidgets(
    'continuation and terminal saves cannot overlap or dismiss a pending write',
    (tester) async {
      items.gate = Completer<void>();
      await openCapture(tester, initialText: 'Save once');
      final addMore = tester
          .widget<OutlinedButton>(find.byType(OutlinedButton))
          .onPressed!;
      final finish = tester
          .widget<FilledButton>(find.byType(FilledButton))
          .onPressed!;
      final submit = tester.widget<TextField>(getTitle()).onSubmitted!;
      addMore();
      addMore();
      finish();
      submit('Save once');
      await tester.pump();
      expect(items.attempts, hasLength(1));
      expect(
        tester.widget<TextField>(getTitle()).controller!.text,
        'Save once',
      );
      expect(
        tester.widget<OutlinedButton>(find.byType(OutlinedButton)).onPressed,
        null,
      );
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        null,
      );
      expect(tester.widget<IconButton>(iconButton('Cancel')).onPressed, null);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.tapAt(const Offset(10, 10));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(CaptureSheet), findsOneWidget);
      items.gate!.complete();
      await tester.pumpAndSettle();
      expect(await items.allActive(), hasLength(1));
      expect(tester.widget<TextField>(getTitle()).controller!.text, isEmpty);
      expect(find.text('1 item added to inbox'), findsOneWidget);
      expect(find.byType(CaptureSheet), findsOneWidget);
      await tester.tap(find.byTooltip('Done'));
      await tester.pumpAndSettle();
      expect(captured!.id, items.attempts.single.id);
    },
  );

  testWidgets(
    'failed continuation preserves the draft and count, then retry succeeds',
    (tester) async {
      await openCapture(tester, initialText: 'Already saved');
      await tester.tap(find.text('Add & continue'));
      await tester.pumpAndSettle();
      items.fail = true;
      await tester.enterText(getTitle(), 'Keep this draft');
      await tester.enterText(getNotes(), 'Keep these notes');
      await tester.tap(find.text('Add & continue'));
      await tester.pumpAndSettle();
      expect(
        find.text("Couldn't save your changes. Please try again."),
        findsOneWidget,
      );
      expect(
        tester.widget<TextField>(getTitle()).controller!.text,
        'Keep this draft',
      );
      expect(
        tester.widget<TextField>(getNotes()).controller!.text,
        'Keep these notes',
      );
      expect(find.text('1 item added to inbox'), findsOneWidget);
      expect(await items.allActive(), hasLength(1));
      items.fail = false;
      await tester.tap(find.text('Add & continue'));
      await tester.pumpAndSettle();
      expect(find.text('2 items added to inbox'), findsOneWidget);
      expect(
        find.text("Couldn't save your changes. Please try again."),
        findsNothing,
      );
      expect(tester.widget<TextField>(getTitle()).controller!.text, isEmpty);
      expect(await items.allActive(), hasLength(2));
      await tester.tap(find.byTooltip('Done'));
      await tester.pumpAndSettle();
    },
  );

  for (final dismissal in ['close', 'back', 'barrier']) {
    testWidgets(
      'continued captures survive $dismissal and return the last saved item',
      (tester) async {
        await openCapture(tester, initialText: 'Persist this');
        await tester.tap(find.text('Add & continue'));
        await tester.pumpAndSettle();
        await tester.enterText(getTitle(), 'Unsaved draft');
        switch (dismissal) {
          case 'close':
            await tester.tap(find.byTooltip('Done'));
          case 'back':
            await tester.binding.handlePopRoute();
          case 'barrier':
            await tester.tapAt(const Offset(10, 10));
        }
        await tester.pumpAndSettle();
        expect(find.byType(CaptureSheet), findsNothing);
        expect((await items.allActive()).single.title, 'Persist this');
        expect(captured!.id, items.attempts.single.id);
      },
    );
  }

  testWidgets('empty continuation preserves notes and does not save', (
    tester,
  ) async {
    await openCapture(tester, initialText: '   ');
    await tester.enterText(getNotes(), 'Note without a title');
    await tester.tap(find.text('Add & continue'));
    await tester.pump();
    expect(items.attempts, isEmpty);
    expect(
      tester.widget<TextField>(getNotes()).controller!.text,
      'Note without a title',
    );
    expect(find.text('Enter something to capture'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.tap(find.byTooltip('Cancel'));
    await tester.pumpAndSettle();
    // The typed notes are not thrown away without confirmation.
    expect(find.text('Discard this capture?'), findsOneWidget);
    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();
    expect(captured, null);
  });

  testWidgets(
    'late speech cannot overwrite the next draft, and cleanup precedes restart',
    (tester) async {
      dictation.cancelGate = Completer<void>();
      await openCapture(tester);
      await tester.tap(find.byTooltip('Dictate'));
      await tester.pumpAndSettle();
      final oldText = dictation.onText!;
      final oldStopped = dictation.onStopped!;
      final oldError = dictation.onError!;
      oldText('First voice capture');
      await tester.tap(find.text('Add & continue'));
      await tester.pumpAndSettle();
      await tester.enterText(getTitle(), 'Next typed draft');
      oldText('Late old recognition');
      oldError();
      await tester.pump();
      expect(
        tester.widget<TextField>(getTitle()).controller!.text,
        'Next typed draft',
      );
      expect(
        find.text('Dictation is unavailable. You can still type your capture.'),
        findsNothing,
      );
      await tester.tap(find.byTooltip('Dictate'));
      await tester.pump();
      expect(dictation.starts, 1);
      expect(sessionsCreated, 1);
      dictation.cancelGate!.complete();
      await tester.pumpAndSettle();
      expect(dictation.starts, 2);
      expect(sessionsCreated, 2);
      oldStopped();
      oldError();
      oldText('Still stale');
      await tester.pump();
      expect(find.byTooltip('Stop dictation'), findsOneWidget);
      expect(
        tester.widget<TextField>(getTitle()).controller!.text,
        'Next typed draft',
      );
      dictation.onText!('New voice capture');
      await tester.tap(find.text('Add to inbox'));
      await tester.pumpAndSettle();
      expect(items.attempts.map((item) => item.title), [
        'First voice capture',
        'Next typed draft New voice capture',
      ]);
      expect(tester.takeException(), null);
    },
  );

  testWidgets('capture actions share widths and heights when labels fit', (
    tester,
  ) async {
    await openCapture(tester);
    final more = tester.getRect(find.byType(OutlinedButton));
    final finish = tester.getRect(find.byType(FilledButton));
    expect(more.top, finish.top);
    expect(more.size, finish.size);
    expect(finish.left - more.right, 12);
    expect(more.height, greaterThanOrEqualTo(48));
  });

  for (final locale in AppLocalizations.supportedLocales) {
    testWidgets(
      'Add & continue remains usable in $locale at 3x with the keyboard open',
      (tester) async {
        tester.view.physicalSize = const Size(360, 640);
        tester.view.devicePixelRatio = 1;
        tester.view.viewInsets = const FakeViewPadding(bottom: 280);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetViewInsets);
        await openCapture(
          tester,
          initialText: 'First idea',
          locale: locale,
          textScaler: const TextScaler.linear(3),
        );
        final l10n = AppLocalizations.of(
          tester.element(find.byType(CaptureSheet)),
        );
        final more = find.widgetWithText(
          OutlinedButton,
          l10n.captureAddContinue,
        );
        final finish = find.widgetWithText(FilledButton, l10n.captureSubmit);
        await tester.ensureVisible(more);
        await tester.pumpAndSettle();
        final moreRect = tester.getRect(more);
        final finishRect = tester.getRect(finish);
        expect(moreRect.width, finishRect.width);
        expect(moreRect.bottom, lessThan(finishRect.top));
        await tester.tap(more);
        await tester.pumpAndSettle();
        expect(find.text(l10n.captureAddedCount(1)), findsOneWidget);
        expect(tester.widget<TextField>(getTitle()).focusNode!.hasFocus, true);
        await tester.enterText(getTitle(), 'Second idea');
        await tester.pumpAndSettle();
        await tester.ensureVisible(finish);
        await tester.pumpAndSettle();
        await tester.tap(finish);
        await tester.pumpAndSettle();
        expect(items.attempts.map((item) => item.title), [
          'First idea',
          'Second idea',
        ]);
        expect(tester.takeException(), null);
      },
    );
  }

  testWidgets('save and speech errors stay usable with the keyboard open', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 640);
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    items.fail = true;
    dictation.available = false;
    await openCapture(tester, initialText: 'Keep the draft');
    await tester.tap(find.byTooltip('Dictate'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Add to inbox'));
    await tester.tap(find.text('Add to inbox'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), null);
    expect(
      find.text("Couldn't save your changes. Please try again."),
      findsOneWidget,
    );
    await tester.ensureVisible(find.text('Add to inbox'));
    items.fail = false;
    await tester.tap(find.text('Add to inbox'));
    await tester.pumpAndSettle();
    expect(captured!.title, 'Keep the draft');
    expect(tester.takeException(), null);
  });

  group('quick-capture parsing (ADR 0007)', () {
    setUp(() async {
      final c = env.container();
      await c.read(contextRepositoryProvider).upsert(
        const GtdContext(id: 'c-phone', name: '@phone', icon: 'phone', color: 0),
      );
      await c.read(projectRepositoryProvider).upsert(
        Project(
          id: 'p-garage',
          title: 'Clean the garage',
          status: ProjectStatus.active,
          createdAt: env.clock.now(),
          updatedAt: env.clock.now(),
        ),
      );
    });

    testWidgets('shows what was recognized and saves it on the Inbox Item', (
      tester,
    ) async {
      await openCapture(tester);
      expect(
        find.textContaining('Tip: add @context, #project'),
        findsOneWidget,
      );
      await tester.enterText(getTitle(), 'Call Bob @phone #garage due friday');
      await tester.pumpAndSettle();
      expect(find.text('@phone'), findsOneWidget);
      expect(find.text('Project: Clean the garage'), findsOneWidget);
      expect(find.text('Due Fri, May 15'), findsOneWidget);
      expect(find.textContaining('Tip:'), findsNothing);

      await tester.tap(find.text('Add to inbox'));
      await tester.pumpAndSettle();
      expect(captured!.title, 'Call Bob');
      expect(captured!.status, ItemStatus.inbox);
      expect(captured!.contextId, 'c-phone');
      expect(captured!.projectId, 'p-garage');
      expect(captured!.dueAt, DateTime(2026, 5, 15, 9));
      expect(captured!.deferUntil, isNull);
    });

    testWidgets('"Keep as text" undoes a recognition', (tester) async {
      await openCapture(tester);
      await tester.enterText(getTitle(), 'Plan friday standup');
      await tester.pumpAndSettle();
      expect(find.text('Starts Fri, May 15'), findsOneWidget);

      await tester.tap(find.byTooltip('Keep as text'));
      await tester.pumpAndSettle();
      expect(find.text('Starts Fri, May 15'), findsNothing);

      // Still kept as text while the user keeps typing.
      await tester.enterText(getTitle(), 'Plan friday standup notes');
      await tester.pumpAndSettle();
      expect(find.byType(InputChip), findsNothing);

      await tester.tap(find.text('Add to inbox'));
      await tester.pumpAndSettle();
      expect(captured!.title, 'Plan friday standup notes');
      expect(captured!.deferUntil, isNull);
    });

    testWidgets('+tag shows a chip and saves the tag', (tester) async {
      final tags = TagRepository(env.db);
      await tags.upsert(
        const Tag(id: 't-alice', name: 'Alice', isPerson: true),
        createdAt: DateTime(2026, 5, 1),
      );
      await openCapture(tester);
      await tester.enterText(getTitle(), 'Ask about budget +alice +garden');
      await tester.pumpAndSettle();
      expect(find.widgetWithText(InputChip, 'Alice'), findsOneWidget);
      expect(find.widgetWithText(InputChip, 'New tag: garden'), findsOneWidget);

      await tester.tap(find.text('Add to inbox'));
      await tester.pumpAndSettle();
      expect(captured!.title, 'Ask about budget');
      final all = await tags.all();
      expect(all.map((t) => t.name), ['Alice', 'garden']);
      expect(
        (await tags.tagIdsFor(captured!.id)).toSet(),
        {for (final t in all) t.id},
      );
    });

    testWidgets('dates are not parsed in other languages', (tester) async {
      await openCapture(tester, locale: const Locale('de'));
      await tester.enterText(getTitle(), 'Bob anrufen tomorrow @phone');
      await tester.pumpAndSettle();
      expect(find.byType(InputChip), findsOneWidget);
      await tester.ensureVisible(find.text('In den Posteingang'));
      await tester.tap(find.text('In den Posteingang'));
      await tester.pumpAndSettle();
      expect(captured!.title, 'Bob anrufen tomorrow');
      expect(captured!.contextId, 'c-phone');
      expect(captured!.deferUntil, isNull);
    });
  });

  group('date chips follow the app clock', () {
    setUp(() async {
      await env.dispose();
      env = await TestEnv.create(now: DateTime(2031, 3, 3, 9));
      items = ControlledItemRepository(env.db, env.clock);
    });

    testWidgets('omit the year for dates in the app clock year', (
      tester,
    ) async {
      await openCapture(tester);
      await tester.enterText(getTitle(), 'Plan standup tomorrow');
      await tester.pumpAndSettle();
      expect(find.text('Starts Tue, Mar 4'), findsOneWidget);
    });
  });

  group('discard guard', () {
    Finder sheetTitle() => find.text('Brain dump');

    testWidgets('an empty sheet closes at once from the close button and barrier',
        (tester) async {
      await openCapture(tester);
      await tester.tap(find.byTooltip('Cancel'));
      await tester.pumpAndSettle();
      expect(sheetTitle(), findsNothing);
      expect(find.text('Discard this capture?'), findsNothing);

      await tester.tap(find.text('Open capture'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(10, 10)); // scrim above the sheet
      await tester.pumpAndSettle();
      expect(sheetTitle(), findsNothing);
      expect(find.text('Discard this capture?'), findsNothing);
    });

    testWidgets('typed text asks first; Keep editing keeps the sheet and text',
        (tester) async {
      await openCapture(tester);
      await tester.enterText(getTitle(), 'Precious idea');
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Discard this capture?'), findsOneWidget);

      await tester.tap(find.text('Keep editing'));
      await tester.pumpAndSettle();
      expect(find.text('Discard this capture?'), findsNothing);
      expect(sheetTitle(), findsOneWidget);
      expect(
        tester.widget<TextField>(getTitle()).controller!.text,
        'Precious idea',
      );
    });

    testWidgets('barrier tap and system back go through the same prompt',
        (tester) async {
      await openCapture(tester);
      await tester.enterText(getNotes(), 'Only notes typed');
      await tester.pumpAndSettle();

      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      expect(find.text('Discard this capture?'), findsOneWidget);
      await tester.tap(find.text('Keep editing'));
      await tester.pumpAndSettle();
      expect(sheetTitle(), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Discard this capture?'), findsOneWidget);
      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();
      expect(sheetTitle(), findsNothing);
      expect(items.attempts, isEmpty);
      expect(captured, isNull);
    });

    testWidgets('a saved sheet closes without asking', (tester) async {
      await openCapture(tester);
      await tester.enterText(getTitle(), 'Saved idea');
      await tester.tap(find.text('Add to inbox'));
      await tester.pumpAndSettle();
      expect(find.text('Discard this capture?'), findsNothing);
      expect(captured!.title, 'Saved idea');
    });
  });

  testWidgets('dictation appends to text typed before it started', (
    tester,
  ) async {
    await openCapture(tester);
    await tester.enterText(getTitle(), 'Call');
    await tester.tap(find.byTooltip('Dictate'));
    await tester.pumpAndSettle();

    dictation.onText!('the dentist');
    await tester.pump();
    expect(
      tester.widget<TextField>(getTitle()).controller!.text,
      'Call the dentist',
    );
    // Transcripts are cumulative within a session: it replaces only the
    // dictated part, never the prefix.
    dictation.onText!('the dentist tomorrow');
    await tester.pump();
    expect(
      tester.widget<TextField>(getTitle()).controller!.text,
      'Call the dentist tomorrow',
    );
  });

  test('appendDictation spaces only when needed', () {
    expect(appendDictation('', 'hello'), 'hello');
    expect(appendDictation('Call', 'hello'), 'Call hello');
    expect(appendDictation('Call ', 'hello'), 'Call hello');
    expect(appendDictation('Call\n', 'hello'), 'Call\nhello');
  });
}
