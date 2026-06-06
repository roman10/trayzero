import 'package:permission_handler/permission_handler.dart' as ph;

import '../core/system_settings.dart';

/// Wraps `permission_handler`'s top-level `openAppSettings()`, which on both
/// Android and iOS deep-links to this app's OS settings page.
class PermissionHandlerSystemSettings implements SystemSettings {
  const PermissionHandlerSystemSettings();

  @override
  Future<bool> openAppSettings() => ph.openAppSettings();
}
