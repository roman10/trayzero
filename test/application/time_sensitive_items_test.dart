import 'package:cleartray/application/current_time.dart';
import 'package:cleartray/application/providers.dart';
import 'package:cleartray/core/clock.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:cleartray/features/common/time_sensitive_items_refresher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

/// Exercise the production Timer adapter with an independently advanced clock.
class _WallClock extends Clock {
  _WallClock(this.clock);
  final FakeClock clock;
  @override
  DateTime now() => clock.now();
}

void main() {
  late TestEnv env;
  setUp(() async => env = await TestEnv.create());
  tearDown(() => env.dispose());

  testWidgets('the production timer surfaces a defer between day refreshes', (
    tester,
  ) async {
    final c = env.container([
      clockProvider.overrideWithValue(_WallClock(env.clock)),
    ]);
    c.read(currentTimeProvider);
    env.clock.advance(const Duration(seconds: 20));
    await tester.runAsync(
      () => c
          .read(itemRepositoryProvider)
          .upsert(
            anItem(
              id: 'timed',
              status: ItemStatus.nextAction,
              deferUntil: env.clock.now().add(const Duration(seconds: 5)),
            ),
          ),
    );
    c.listen(nextActionsProvider, (_, _) {});
    await tester.pump(const Duration(milliseconds: 100));
    expect(c.read(nextActionsProvider).valueOrNull, isEmpty);
    env.clock.advance(const Duration(seconds: 5));
    await tester.pump(const Duration(seconds: 5));
    expect(c.read(nextActionsProvider).valueOrNull!.single.id, 'timed');
    c.dispose();
    await tester.pump(Duration.zero);
  });

  testWidgets(
    'an existing Next Actions subscription surfaces a defer without a write',
    (tester) async {
      final c = env.container();
      await tester.runAsync(
        () => c
            .read(itemRepositoryProvider)
            .upsert(
              anItem(
                id: 'deferred',
                status: ItemStatus.nextAction,
                deferUntil: env.clock.now().add(const Duration(seconds: 5)),
              ),
            ),
      );
      final sub = c.listen(nextActionsProvider, (_, _) {});
      await tester.pump(const Duration(milliseconds: 100));
      expect(c.read(nextActionsProvider).valueOrNull, isEmpty);

      env.clock.advance(const Duration(seconds: 5));
      await tester.pump(const Duration(seconds: 5));
      expect(c.read(nextActionsProvider).valueOrNull!.single.id, 'deferred');
      sub.close();
      c.dispose();
      await tester.pump(Duration.zero);
    },
  );

  test(
    'an existing Next Actions subscription uses the new time after a write',
    () async {
      final c = env.container();
      final repo = c.read(itemRepositoryProvider);
      final row = anItem(
        id: 'deferred',
        status: ItemStatus.nextAction,
        deferUntil: env.clock.now().add(const Duration(hours: 1)),
      );
      await repo.upsert(row);
      final emissions = <List<Item>>[];
      final sub = repo.watchNextActions().listen(emissions.add);
      await pumpEventQueue();
      expect(emissions.last, isEmpty);
      env.clock.advance(const Duration(hours: 2));
      await repo.upsert(row.copyWith(title: 'Edited later'));
      await pumpEventQueue();
      expect(emissions.last.single.id, 'deferred');
      await sub.cancel();
    },
  );

  testWidgets(
    'calendar bands and completion history roll over at midnight Monday',
    (tester) async {
      env.clock.setTo(DateTime(2026, 10, 18, 23, 59, 59));
      final c = env.container();
      final repo = c.read(itemRepositoryProvider);
      await tester.runAsync(() async {
        await repo.upsert(
          anItem(
            id: 'sunday',
            status: ItemStatus.calendar,
            dueAt: DateTime(2026, 10, 18, 12),
          ),
        );
        await repo.upsert(
          anItem(
            id: 'monday',
            status: ItemStatus.calendar,
            dueAt: DateTime(2026, 10, 19, 12),
          ),
        );
        await repo.upsert(
          anItem(
            id: 'last-week',
            status: ItemStatus.done,
            completedAt: DateTime(2026, 10, 18, 12),
          ),
        );
      });
      c.listen(engageCalendarBandProvider, (_, _) {});
      c.listen(pastDueItemsProvider, (_, _) {});
      c.listen(calendarItemsProvider, (_, _) {});
      c.listen(completedThisWeekProvider, (_, _) {});
      await tester.pump(const Duration(milliseconds: 100));
      expect(c.read(engageCalendarBandProvider).map((i) => i.id), ['sunday']);
      expect(c.read(pastDueItemsProvider), isEmpty);
      expect(
        c.read(completedThisWeekProvider).valueOrNull!.single.id,
        'last-week',
      );

      env.clock.advance(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(milliseconds: 100));
      expect(c.read(engageCalendarBandProvider).map((i) => i.id), [
        'sunday',
        'monday',
      ]);
      expect(c.read(pastDueItemsProvider).single.id, 'sunday');
      expect(c.read(calendarItemsProvider).single.id, 'monday');
      expect(c.read(completedThisWeekProvider).valueOrNull, isEmpty);
      c.dispose();
      await tester.pump(Duration.zero);
    },
  );

  testWidgets(
    'resume immediately catches up lists after suspension or a clock change',
    (tester) async {
      final c = env.container();
      await tester.runAsync(
        () => c
            .read(itemRepositoryProvider)
            .upsert(
              anItem(
                id: 'deferred',
                status: ItemStatus.nextAction,
                deferUntil: env.clock.now().add(const Duration(hours: 1)),
              ),
            ),
      );
      c.listen(nextActionsProvider, (_, _) {});
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: c,
          child: const MaterialApp(
            home: TimeSensitiveItemsRefresher(child: SizedBox()),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(c.read(nextActionsProvider).valueOrNull, isEmpty);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      env.clock.advance(const Duration(days: 2));
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump(const Duration(milliseconds: 100));
      expect(c.read(nextActionsProvider).valueOrNull!.single.id, 'deferred');
      expect(c.read(currentTimeProvider), env.clock.now());
      await tester.pumpWidget(const SizedBox());
      c.dispose();
      await tester.pump(Duration.zero);
    },
  );
}
