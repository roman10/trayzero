import 'package:cleartray/core/calendar_gateway.dart';
import 'package:cleartray/application/calendar_connection_controller.dart';
import 'package:cleartray/data/repositories/item_repository.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

class CountingCalendar extends FakeCalendarGateway {
  int writes = 0;
  @override
  Future<String?> upsertEvent(CalendarEventDraft draft) {
    writes++;
    return super.upsertEvent(draft);
  }
}

void main() {
  test(
    'real database edits trigger automatic publication without a bookkeeping loop',
    () async {
      final env = await TestEnv.create();
      final gateway = CountingCalendar();
      final container = env.container([
        calendarGatewayProvider.overrideWithValue(gateway),
      ]);
      final controller = container.read(calendarConnectionProvider.notifier);
      final items = ItemRepository(env.db, env.clock);
      Future<void> settle() async {
        for (var i = 0; i < 40; i++) {
          await Future<void>.delayed(Duration.zero);
        }
      }

      await items.upsert(
        anItem(
          id: 'scheduled',
          status: ItemStatus.calendar,
          dueAt: env.clock.now().add(const Duration(days: 1)),
        ),
      );
      await settle();
      await controller.connect(env.calendar.calendars.first);
      await settle();
      final id = gateway.events.keys.single;
      await items.upsert(
        (await items.getById('scheduled'))!.copyWith(title: 'Updated in app'),
      );
      await settle();
      env.clock.advance(const Duration(seconds: 1));
      await settle();
      expect(gateway.events[id]!.title, '[Trayzero] Updated in app');
      expect(controller.state.pending, isFalse);
      expect(controller.state.busy, isFalse);
      expect(gateway.writes, 2);
      env.clock.advance(const Duration(minutes: 1));
      await settle();
      expect(gateway.events.keys, [id]);
      expect(gateway.writes, 2);
      expect(controller.state.pending, isFalse);
      await items.markCompleted('scheduled', env.clock.now());
      await settle();
      env.clock.advance(const Duration(seconds: 1));
      await settle();
      expect(gateway.events, isEmpty);
      container.dispose();
      await env.dispose();
    },
  );
}
