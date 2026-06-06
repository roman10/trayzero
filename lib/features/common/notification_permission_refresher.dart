import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';

/// Invalidates [notificationPermissionStatusProvider] whenever the app
/// returns to the foreground, so a permission the user toggled in the OS
/// settings app is reflected in-app on return (no polling). Wraps the app
/// child, mirroring how `ShareIntentListener` is composed in `app.dart`.
class NotificationPermissionRefresher extends ConsumerStatefulWidget {
  const NotificationPermissionRefresher({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<NotificationPermissionRefresher> createState() =>
      _NotificationPermissionRefresherState();
}

class _NotificationPermissionRefresherState
    extends ConsumerState<NotificationPermissionRefresher> {
  late final AppLifecycleListener _listener;

  @override
  void initState() {
    super.initState();
    _listener = AppLifecycleListener(
      onResume: () => ref.invalidate(notificationPermissionStatusProvider),
    );
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
