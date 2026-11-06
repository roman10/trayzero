import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/appearance_preferences.dart';

/// Optimistic UI with ordered writes and independent rollback for each field.
/// An older failed write must never undo a newer selection or the other field.
class AppearanceController extends StateNotifier<AppearancePreferences> {
  AppearanceController(this._store) : super(_store.load()) {
    _saved = state;
  }

  final AppearancePreferencesStore _store;
  late AppearancePreferences _saved;
  Future<void> _writes = Future.value();
  int _modeRevision = 0;
  int _paletteRevision = 0;

  Future<bool> setMode(AppearanceMode mode) {
    final revision = ++_modeRevision;
    state = state.copyWith(mode: mode);
    return _write(
      () => _store.saveMode(mode),
      () => _saved = _saved.copyWith(mode: mode),
      () {
        if (mounted && revision == _modeRevision) {
          state = state.copyWith(mode: _saved.mode);
        }
      },
    );
  }

  Future<bool> setPalette(AppPalette palette) {
    final revision = ++_paletteRevision;
    state = state.copyWith(palette: palette);
    return _write(
      () => _store.savePalette(palette),
      () => _saved = _saved.copyWith(palette: palette),
      () {
        if (mounted && revision == _paletteRevision) {
          state = state.copyWith(palette: _saved.palette);
        }
      },
    );
  }

  Future<bool> _write(
    Future<void> Function() persist,
    void Function() remember,
    void Function() rollback,
  ) {
    final result = _writes.then((_) async {
      try {
        await persist();
        remember();
        return true;
      } on Object {
        rollback();
        return false;
      }
    });
    _writes = result.then((_) {});
    return result;
  }
}

final appearanceProvider =
    StateNotifierProvider<AppearanceController, AppearancePreferences>((ref) {
      return AppearanceController(
        ref.watch(appearancePreferencesStoreProvider),
      );
    });
