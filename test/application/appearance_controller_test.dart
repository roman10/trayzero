import 'dart:async';

import 'package:cleartray/application/appearance_controller.dart';
import 'package:cleartray/core/appearance_preferences.dart';
import 'package:flutter_test/flutter_test.dart';

class ControlledAppearanceStore implements AppearancePreferencesStore {
  ControlledAppearanceStore({this.saved = const AppearancePreferences()});
  AppearancePreferences saved;
  final writes = <String>[];
  final pending = <Completer<void>>[];

  @override
  AppearancePreferences load() => saved;

  Future<void> _wait(String value) {
    writes.add(value);
    final gate = Completer<void>();
    pending.add(gate);
    return gate.future;
  }

  @override
  Future<void> saveMode(AppearanceMode mode) async {
    await _wait(mode.id);
    saved = saved.copyWith(mode: mode);
  }

  @override
  Future<void> savePalette(AppPalette palette) async {
    await _wait(palette.id);
    saved = saved.copyWith(palette: palette);
  }
}

Future<void> flushWrites() => Future<void>.delayed(Duration.zero);

void main() {
  late ControlledAppearanceStore store;
  late AppearanceController controller;

  setUp(() {
    store = ControlledAppearanceStore();
    controller = AppearanceController(store);
  });
  tearDown(() {
    if (controller.mounted) controller.dispose();
  });

  test('loads appearance synchronously before the first frame', () {
    final loaded = AppearanceController(
      ControlledAppearanceStore(
        saved: const AppearancePreferences(
          mode: AppearanceMode.dark,
          palette: AppPalette.violet,
        ),
      ),
    );
    addTearDown(loaded.dispose);
    expect(loaded.state.mode, AppearanceMode.dark);
    expect(loaded.state.palette, AppPalette.violet);
  });

  test(
    'applies immediately and orders rapid writes; latest selection wins',
    () async {
      final first = controller.setPalette(AppPalette.blue);
      final second = controller.setPalette(AppPalette.rose);
      expect(controller.state.palette, AppPalette.rose);
      expect(store.saved.palette, AppPalette.amber);
      await flushWrites();
      expect(store.writes, ['blue']);
      store.pending[0].complete();
      await flushWrites();
      expect(store.writes, ['blue', 'rose']);
      expect(controller.state.palette, AppPalette.rose);
      store.pending[1].complete();
      expect(await first, isTrue);
      expect(await second, isTrue);
      expect(store.saved.palette, AppPalette.rose);
    },
  );

  test('an older failure cannot roll back a newer selection', () async {
    final first = controller.setPalette(AppPalette.blue);
    final second = controller.setPalette(AppPalette.green);
    await flushWrites();
    store.pending[0].completeError(StateError('disk failure'));
    await flushWrites();
    expect(controller.state.palette, AppPalette.green);
    store.pending[1].complete();
    expect(await first, isFalse);
    expect(await second, isTrue);
    expect(store.saved.palette, AppPalette.green);
  });

  test('latest failure restores the last successfully saved palette', () async {
    final first = controller.setPalette(AppPalette.blue);
    await flushWrites();
    store.pending[0].complete();
    await first;
    final failed = controller.setPalette(AppPalette.teal);
    await flushWrites();
    store.pending[1].completeError(StateError('disk failure'));
    expect(await failed, isFalse);
    expect(controller.state.palette, AppPalette.blue);
    expect(store.saved.palette, AppPalette.blue);
  });

  test('mode failure preserves a concurrent palette selection', () async {
    final mode = controller.setMode(AppearanceMode.dark);
    final palette = controller.setPalette(AppPalette.violet);
    await flushWrites();
    store.pending[0].completeError(StateError('disk failure'));
    await flushWrites();
    expect(controller.state.mode, AppearanceMode.system);
    expect(controller.state.palette, AppPalette.violet);
    store.pending[1].complete();
    expect(await mode, isFalse);
    expect(await palette, isTrue);
    expect(store.saved.mode, AppearanceMode.system);
    expect(store.saved.palette, AppPalette.violet);
  });

  test('an older mode failure does not undo a newer mode', () async {
    final first = controller.setMode(AppearanceMode.dark);
    final second = controller.setMode(AppearanceMode.light);
    await flushWrites();
    store.pending[0].completeError(StateError('disk failure'));
    await flushWrites();
    expect(controller.state.mode, AppearanceMode.light);
    store.pending[1].complete();
    expect(await first, isFalse);
    expect(await second, isTrue);
    expect(store.saved.mode, AppearanceMode.light);
  });

  test('pending failure is safe after provider disposal', () async {
    final pending = controller.setPalette(AppPalette.blue);
    await flushWrites();
    controller.dispose();
    store.pending[0].completeError(StateError('disk failure'));
    expect(await pending, isFalse);
  });
}
