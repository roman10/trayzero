import '../core/result.dart';
import '../core/system_settings.dart';

/// Deep-links to this app's OS settings page so the user can flip a
/// permanently-denied notification permission. The feature layer never
/// imports `permission_handler` directly — it goes through this use case,
/// which keeps the recovery path testable.
final class OpenNotificationSettings {
  OpenNotificationSettings({required SystemSettings settings})
      : _settings = settings;

  final SystemSettings _settings;

  Future<Result<bool, String>> call() async {
    try {
      return Ok(await _settings.openAppSettings());
    } on Object catch (e) {
      return Err(e.toString());
    }
  }
}
