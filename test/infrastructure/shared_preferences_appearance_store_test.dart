import 'package:cleartray/core/appearance_preferences.dart';
import 'package:cleartray/infrastructure/shared_preferences_appearance_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockPreferences extends Mock implements SharedPreferences {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<SharedPreferencesAppearanceStore> load(
    Map<String, Object> values,
  ) async {
    SharedPreferences.setMockInitialValues(values);
    return SharedPreferencesAppearanceStore(
      await SharedPreferences.getInstance(),
    );
  }

  test('missing preferences use System and amber', () async {
    final state = (await load({})).load();
    expect(state.mode, AppearanceMode.system);
    expect(state.palette, AppPalette.amber);
  });

  test('existing light/dark/system choices remain compatible', () async {
    for (final mode in AppearanceMode.values) {
      final state = (await load({'theme_mode': mode.id})).load();
      expect(state.mode, mode);
      expect(state.palette, AppPalette.amber);
    }
  });

  test('unknown and incorrectly typed values safely fall back', () async {
    for (final values in [
      {'theme_mode': 'unknown', 'app_palette': 'unknown'},
      {'theme_mode': 12, 'app_palette': true},
    ]) {
      final state = (await load(values)).load();
      expect(state.mode, AppearanceMode.system);
      expect(state.palette, AppPalette.amber);
    }
  });

  test(
    'palette and mode persist independently across controller restarts',
    () async {
      final store = await load({'theme_mode': 'dark'});
      for (final palette in AppPalette.values) {
        await store.savePalette(palette);
        expect(store.load().palette, palette);
        expect(store.load().mode, AppearanceMode.dark);
      }
      await store.saveMode(AppearanceMode.system);
      final reloaded = SharedPreferencesAppearanceStore(
        await SharedPreferences.getInstance(),
      ).load();
      expect(reloaded.mode, AppearanceMode.system);
      expect(reloaded.palette, AppPalette.rose);
    },
  );

  test('a rejected storage write is surfaced to the controller', () async {
    final prefs = MockPreferences();
    when(
      () => prefs.setString('app_palette', 'blue'),
    ).thenAnswer((_) async => false);
    final store = SharedPreferencesAppearanceStore(prefs);
    await expectLater(store.savePalette(AppPalette.blue), throwsStateError);
  });
}
