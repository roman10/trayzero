import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/clock.dart';

/// A changing wall-clock value for date-dependent read models and labels.
/// Refresh exactly at the next local midnight rather than polling the UI.
/// Resume refreshes immediately after suspension or a device clock change.
class CurrentTime extends AutoDisposeNotifier<DateTime> {
  void Function()? _cancelRefresh;

  @override
  DateTime build() {
    final clock = ref.watch(clockProvider);
    ref.onDispose(() => _cancelRefresh?.call());
    final now = clock.now();
    _schedule(now);
    return now;
  }

  void refresh() {
    final now = ref.read(clockProvider).now();
    state = now;
    _schedule(now);
  }

  void _schedule(DateTime now) {
    _cancelRefresh?.call();
    final midnight = now.isUtc
        ? DateTime.utc(now.year, now.month, now.day + 1)
        : DateTime(now.year, now.month, now.day + 1);
    _cancelRefresh = ref.read(clockProvider).scheduleAt(midnight, refresh);
  }
}

final currentTimeProvider = NotifierProvider.autoDispose<CurrentTime, DateTime>(
  CurrentTime.new,
);
