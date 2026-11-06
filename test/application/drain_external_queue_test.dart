import 'dart:async';

import 'package:cleartray/application/capture_item.dart';
import 'package:cleartray/application/complete_item.dart';
import 'package:cleartray/application/drain_external_queue.dart';
import 'package:cleartray/application/save_item.dart';
import 'package:cleartray/core/clock.dart';
import 'package:cleartray/core/home_widget_bridge.dart';
import 'package:cleartray/core/id_generator.dart';
import 'package:cleartray/data/db/database.dart';
import 'package:cleartray/data/repositories/item_repository.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';

class _QueueBridge implements HomeWidgetBridge {
  final queues = <ExternalQueue>[];
  int takes = 0;
  Completer<void>? gate;

  @override
  Future<ExternalQueue> takeQueue() async {
    takes++;
    await gate?.future;
    return queues.isEmpty ? const ExternalQueue() : queues.removeAt(0);
  }

  @override
  Future<void> init() async {}
  @override
  Future<void> publishInboxCount(int count) async {}
  @override
  Future<void> publishToday(TodayWidgetSnapshot snapshot) async {}
  @override
  Stream<Uri> get widgetTaps => const Stream.empty();
  @override
  Stream<void> get queueChanged => const Stream.empty();
  @override
  Future<void> checkPendingLaunch() async {}
}

class _SeqIds extends IdGenerator {
  int _n = 0;
  @override
  String newId() => 'new-${++_n}';
}

/// Widget completions and Siri captures queued outside the app (ADR 0009).
void main() {
  late AppDatabase db;
  late FakeClock clock;
  late ItemRepository items;
  late _QueueBridge bridge;
  late DrainExternalQueue drain;
  final created = DateTime(2026, 10, 20, 8);

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    clock = FakeClock(DateTime(2026, 10, 26, 18));
    items = ItemRepository(db, clock);
    bridge = _QueueBridge();
    final scheduler = FakeNotificationScheduler();
    final ids = _SeqIds();
    final save = SaveItem(items: items, scheduler: scheduler, clock: clock);
    drain = DrainExternalQueue(
      bridge: bridge,
      items: items,
      completeItem: CompleteItem(
        items: items,
        scheduler: scheduler,
        clock: clock,
        ids: ids,
        saveItem: save,
      ),
      captureItem: CaptureItem(items: items, clock: clock, ids: ids),
    );
  });
  tearDown(() => db.close());

  Item item(String id, {ItemStatus status = ItemStatus.nextAction}) => Item(
    id: id,
    title: id,
    status: status,
    createdAt: created,
    updatedAt: created,
  );

  test('completes at the tap time, not the drain time', () async {
    await items.upsert(item('a'));
    final tap = DateTime(2026, 10, 26, 9, 30);
    bridge.queues.add(ExternalQueue(completions: [(id: 'a', at: tap)]));
    await drain();
    final done = (await items.getById('a'))!;
    expect(done.status, ItemStatus.done);
    expect(done.completedAt, tap);
  });

  test('a tap time in the future is clamped to now', () async {
    await items.upsert(item('a'));
    bridge.queues.add(
      ExternalQueue(
        completions: [(id: 'a', at: clock.now().add(const Duration(days: 1)))],
      ),
    );
    await drain();
    expect((await items.getById('a'))!.completedAt, clock.now());
  });

  test(
    'skips deleted, done, and trashed Items without a second successor',
    () async {
      await items.upsert(
        item('r').copyWith(
          recurrence: Recurrence.daily,
          deferUntil: DateTime(2026, 10, 26),
        ),
      );
      await items.upsert(item('t', status: ItemStatus.trashed));
      final tap = DateTime(2026, 10, 26, 9);
      bridge.queues.add(
        ExternalQueue(
          completions: [
            (id: 'gone', at: tap),
            (id: 'r', at: tap),
            (id: 'r', at: tap), // Duplicate tap / notification Done.
            (id: 't', at: tap),
          ],
        ),
      );
      await drain();
      expect((await items.getById('r'))!.status, ItemStatus.done);
      expect((await items.getById('t'))!.status, ItemStatus.trashed);
      final open = await items.watchByStatus(ItemStatus.nextAction).first;
      expect(open, hasLength(1), reason: 'exactly one recurrence successor');
    },
  );

  test('captures land raw in the Inbox; long text keeps notes', () async {
    final long = 'x' * 130;
    bridge.queues.add(
      ExternalQueue(
        captures: [
          (text: '  call mom tomorrow @phone  ', at: clock.now()),
          (text: '   ', at: clock.now()),
          (text: long, at: clock.now()),
        ],
      ),
    );
    await drain();
    final inbox = await items.watchInbox().first;
    expect(inbox, hasLength(2));
    final short = inbox.firstWhere((i) => i.notes == null);
    expect(short.title, 'call mom tomorrow @phone');
    expect(short.deferUntil, isNull, reason: 'not run through the parser');
    final split = inbox.firstWhere((i) => i.notes != null);
    expect(split.title, '${'x' * 117}…');
    expect(split.notes, long);
  });

  test('long-text title never splits an emoji surrogate pair', () async {
    // 116 ASCII units, then an emoji whose pair straddles the 117-unit cut.
    final text = '${'x' * 116}😀${'y' * 20}';
    bridge.queues.add(ExternalQueue(captures: [(text: text, at: clock.now())]));
    await drain();
    final item = (await items.watchInbox().first).single;
    expect(item.title, '${'x' * 116}…');
    expect(item.notes, text);
  });

  test('overlapping drains coalesce into one run plus one re-run', () async {
    bridge.gate = Completer<void>();
    final first = drain();
    final second = drain();
    final third = drain();
    bridge.gate!.complete();
    await Future.wait([first, second, third]);
    expect(bridge.takes, 2);
  });
}
