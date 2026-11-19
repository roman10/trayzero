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
  int reads = 0;
  bool failAcknowledgment = false;
  Completer<void>? gate;

  @override
  Future<ExternalQueue> readQueue() async {
    reads++;
    await gate?.future;
    return queues.isEmpty ? const ExternalQueue() : queues.first;
  }

  @override
  Future<void> acknowledgeQueue({
    List<String> completionReceipts = const [],
    List<String> captureReceipts = const [],
  }) async {
    if (failAcknowledgment) {
      throw StateError('Failed to persist acknowledgment');
    }
    final queue = queues.first;
    final remaining = ExternalQueue(
      completions: queue.completions
          .where((entry) => !completionReceipts.contains(entry.receipt))
          .toList(),
      captures: queue.captures
          .where((entry) => !captureReceipts.contains(entry.receipt))
          .toList(),
    );
    if (remaining.isEmpty) {
      queues.removeAt(0);
    } else {
      queues[0] = remaining;
    }
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
  late Future<void> Function() publishToday;
  final created = DateTime(2026, 10, 20, 8);

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    clock = FakeClock(DateTime(2026, 10, 26, 18));
    items = ItemRepository(db, clock);
    bridge = _QueueBridge();
    publishToday = () async {};
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
      publishTodayAfterCompletion: () => publishToday(),
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
    bridge.queues.add(
      ExternalQueue(completions: [(receipt: 'a1', id: 'a', at: tap)]),
    );
    await drain();
    final done = (await items.getById('a'))!;
    expect(done.status, ItemStatus.done);
    expect(done.completedAt, tap);
  });

  test('a tap time in the future is clamped to now', () async {
    await items.upsert(item('a'));
    bridge.queues.add(
      ExternalQueue(
        completions: [
          (
            receipt: 'a1',
            id: 'a',
            at: clock.now().add(const Duration(days: 1)),
          ),
        ],
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
            (receipt: '1', id: 'gone', at: tap),
            (receipt: '2', id: 'r', at: tap),
            (
              receipt: '3',
              id: 'r',
              at: tap,
            ), // Duplicate tap / notification Done.
            (receipt: '4', id: 't', at: tap),
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
          (receipt: '1', text: '  call mom tomorrow @phone  ', at: clock.now()),
          (receipt: '2', text: '   ', at: clock.now()),
          (receipt: '3', text: long, at: clock.now()),
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
    bridge.queues.add(
      ExternalQueue(captures: [(receipt: '1', text: text, at: clock.now())]),
    );
    await drain();
    final item = (await items.watchInbox().first).single;
    expect(item.title, '${'x' * 116}…');
    expect(item.notes, text);
  });

  test(
    'keeps a failed completion queued and acknowledges successful actions',
    () async {
      await items.upsert(item('retry'));
      await items.upsert(item('works'));
      await db.customStatement("""
      CREATE TRIGGER reject_widget_completion BEFORE UPDATE ON items
      WHEN NEW.id = 'retry' AND NEW.status = 'done'
      BEGIN
        SELECT RAISE(ABORT, 'temporary completion failure');
      END
    """);
      final at = clock.now();
      bridge.queues.add(
        ExternalQueue(
          completions: [
            (receipt: 'retry1', id: 'retry', at: at),
            (receipt: 'works1', id: 'works', at: at),
          ],
          captures: [(receipt: 'capture1', text: 'milk', at: at)],
        ),
      );
      publishToday = () async {
        expect((await items.getById('works'))!.status, ItemStatus.done);
        expect(bridge.queues.first.completions, hasLength(2));
      };

      await drain();

      expect(bridge.queues.single.completions.map((entry) => entry.id), [
        'retry',
      ]);
      expect(bridge.queues.single.captures, isEmpty);
      expect((await items.getById('retry'))!.status, ItemStatus.nextAction);
      expect((await items.watchInbox().first).single.title, 'milk');

      await db.customStatement('DROP TRIGGER reject_widget_completion');
      publishToday = () async {};
      await drain();
      expect(bridge.queues, isEmpty);
      expect((await items.getById('retry'))!.status, ItemStatus.done);
    },
  );

  test('does not duplicate captures when acknowledgment fails', () async {
    final at = clock.now();
    bridge.queues.add(
      ExternalQueue(
        captures: [
          (receipt: 'capture1', text: 'milk', at: at),
          (receipt: 'capture2', text: 'milk', at: at),
        ],
      ),
    );
    bridge.failAcknowledgment = true;
    await drain();
    final inbox = await items.watchInbox().first;
    expect(
      inbox,
      hasLength(2),
      reason: 'distinct taps may have identical text',
    );
    expect(bridge.queues.single.captures, hasLength(2));

    bridge.failAcknowledgment = false;
    await drain();
    final retried = await items.watchInbox().first;
    expect(retried.map((item) => item.id), inbox.map((item) => item.id));
    expect(
      retried.map((item) => item.createdAt),
      inbox.map((item) => item.createdAt),
    );
    expect(bridge.queues, isEmpty);
  });

  test('overlapping drains coalesce into one run plus one re-run', () async {
    bridge.gate = Completer<void>();
    final first = drain();
    final second = drain();
    final third = drain();
    bridge.gate!.complete();
    await Future.wait([first, second, third]);
    expect(bridge.reads, 2);
  });
}
