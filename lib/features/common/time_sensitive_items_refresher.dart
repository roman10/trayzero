import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/current_time.dart';

/// Catch up time-dependent lists immediately when returning to the app.
class TimeSensitiveItemsRefresher extends ConsumerStatefulWidget {
  const TimeSensitiveItemsRefresher({required this.child, super.key});
  final Widget child;

  @override
  ConsumerState<TimeSensitiveItemsRefresher> createState() =>
      _TimeSensitiveItemsRefresherState();
}

class _TimeSensitiveItemsRefresherState
    extends ConsumerState<TimeSensitiveItemsRefresher> {
  late final AppLifecycleListener _listener;

  @override
  void initState() {
    super.initState();
    _listener = AppLifecycleListener(
      onResume: () {
        ref.read(currentTimeProvider.notifier).refresh();
      },
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
