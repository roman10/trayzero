import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'appearance_preferences.dart';

class AppIconState {
  const AppIconState({
    required this.supported,
    this.palette = AppPalette.amber,
  });
  final bool supported;
  final AppPalette palette;
}

/// The OS owns icon selection. It is independent of in-app appearance and is
/// never exported in task backups or replayed automatically at startup. Android
/// keeps a derived notification-only fallback for headless scheduling.
abstract class AppIconGateway {
  Future<AppIconState> load();
  Future<AppIconState> setIcon(AppPalette palette);
}

class UnsupportedAppIconGateway implements AppIconGateway {
  const UnsupportedAppIconGateway();
  @override
  Future<AppIconState> load() async => const AppIconState(supported: false);
  @override
  Future<AppIconState> setIcon(AppPalette palette) async => load();
}

final appIconGatewayProvider = Provider<AppIconGateway>(
  (ref) => const UnsupportedAppIconGateway(),
);
