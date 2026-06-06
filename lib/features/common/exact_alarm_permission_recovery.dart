import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../core/result.dart';

/// Android exact alarms back reminders that need precise timing (especially
/// short-horizon reminders). When unavailable, Android may delay delivery by
/// batching alarms aggressively.
Future<bool> runExactAlarmPermissionRecovery(
  BuildContext context,
  WidgetRef ref,
) async {
  final messenger = ScaffoldMessenger.of(context);

  final statusRes = await ref.read(checkExactAlarmPermissionProvider).call();
  final allowed = switch (statusRes) {
    Ok(:final value) => value,
    Err() => null,
  };
  if (allowed == null) {
    _snack(messenger, 'Couldn’t open exact alarm settings.');
    return false;
  }
  if (allowed) {
    _snack(messenger, 'Precise reminder timing is already on.');
    return true;
  }

  final reqRes = await ref.read(requestExactAlarmPermissionProvider).call();
  final result = switch (reqRes) {
    Ok(:final value) => value,
    Err() => null,
  };
  switch (result) {
    case true:
      _snack(messenger, 'Precise reminder timing is on.');
    case false:
      _snack(
        messenger,
        'Precise reminder timing stays off. Short reminders may be delayed.',
      );
    case null:
      _snack(messenger, 'Couldn’t open exact alarm settings.');
  }
  return result ?? false;
}

void _snack(ScaffoldMessengerState messenger, String text) {
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));
}
