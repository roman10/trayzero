import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Opens the OS per-app settings screen so the user can flip a
/// permanently-denied permission (notifications today; calendar later —
/// kept off [NotificationScheduler] precisely so it can be reused).
///
/// Concrete impl: `lib/infrastructure/permission_handler_system_settings.dart`.
/// Tests use a fake that records the call. Mirrors the `Clock` /
/// `IdGenerator` micro-port precedent.
abstract class SystemSettings {
  /// Returns true if the settings screen was launched successfully.
  Future<bool> openAppSettings();
}

final systemSettingsProvider = Provider<SystemSettings>((ref) {
  throw UnimplementedError('systemSettingsProvider must be overridden');
});
