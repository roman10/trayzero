import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_icon.dart';
import '../core/appearance_preferences.dart';

class AppIconController extends StateNotifier<AsyncValue<AppIconState>> {
  AppIconController(this._gateway) : super(const AsyncLoading()) {
    unawaited(reload());
  }
  final AppIconGateway _gateway;

  Future<void> reload() async {
    if (state.isLoading && state.hasValue) return;
    final loaded = await AsyncValue.guard(_gateway.load);
    if (mounted) state = loaded;
  }

  Future<bool> select(AppPalette palette) async {
    final previous = state.valueOrNull;
    if (state.isLoading || previous == null || !previous.supported) {
      return false;
    }
    if (previous.palette == palette) return true;
    state = const AsyncLoading<AppIconState>().copyWithPrevious(state);
    try {
      final actual = await _gateway.setIcon(palette);
      if (mounted) state = AsyncData(actual);
      return actual.supported && actual.palette == palette;
    } catch (_) {
      if (mounted) state = AsyncData(previous);
      return false;
    }
  }
}

final appIconControllerProvider =
    StateNotifierProvider<AppIconController, AsyncValue<AppIconState>>(
      (ref) => AppIconController(ref.watch(appIconGatewayProvider)),
    );
