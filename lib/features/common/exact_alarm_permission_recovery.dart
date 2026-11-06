import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../core/result.dart';
import '../../l10n/gen/app_localizations.dart';

/// Android exact alarms back reminders that need precise timing (especially
/// short-horizon reminders). When unavailable, Android may delay delivery by
/// batching alarms aggressively.
Future<bool> runExactAlarmPermissionRecovery(
  BuildContext context,
  WidgetRef ref,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final l10n = AppLocalizations.of(context);

  final statusRes = await ref.read(checkExactAlarmPermissionProvider).call();
  final allowed = switch (statusRes) {
    Ok(:final value) => value,
    Err() => null,
  };
  if (allowed == null) {
    _snack(messenger, l10n.exactAlarmSettingsFailed);
    return false;
  }
  if (allowed) {
    _snack(messenger, l10n.exactAlarmAlreadyOn);
    return true;
  }

  final reqRes = await ref.read(requestExactAlarmPermissionProvider).call();
  final result = switch (reqRes) {
    Ok(:final value) => value,
    Err() => null,
  };
  switch (result) {
    case true:
      _snack(messenger, l10n.exactAlarmNowOn);
    case false:
      _snack(messenger, l10n.exactAlarmStaysOff);
    case null:
      _snack(messenger, l10n.exactAlarmSettingsFailed);
  }
  return result ?? false;
}

void _snack(ScaffoldMessengerState messenger, String text) {
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));
}
