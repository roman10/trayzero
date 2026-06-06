import 'dart:io';

import 'package:cleartray/core/notification_intent.dart';
import 'package:cleartray/infrastructure/pending_notification_intents.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

/// The journal is the only durable link between the headless tap
/// isolate (which has no DI / DB and may be killed the instant the
/// callback returns) and the next foreground launch (which actually
/// completes the item). These tests pin every property that matters:
/// round-trip, ordering, single-shot drain, and resilience to a
/// half-written file.
void main() {
  late Directory tmp;
  late File file;
  late PendingNotificationIntents store;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('pending_intents_test_');
    file = File(p.join(tmp.path, 'journal.jsonl'));
    store = PendingNotificationIntents(file: file);
  });

  tearDown(() async {
    if (await tmp.exists()) await tmp.delete(recursive: true);
  });

  /// A synthetic Done event for an item. The payload string is what
  /// the OS round-trips back to the app at tap time, so we encode it
  /// the same way [LocalNotificationScheduler.schedule] would.
  ({String? payload, String? actionId, int? id}) doneEvent({
    required String itemId,
    int notifId = 555,
  }) =>
      (
        payload: NotificationPayload(
          kind: NotificationKind.due,
          itemId: itemId,
          title: 'Due: thing',
          body: '',
        ).encode(),
        actionId: NotificationAction.done.id,
        id: notifId,
      );

  test('drain on a missing file returns empty', () async {
    expect(await file.exists(), isFalse);
    expect(await store.drain(), isEmpty);
  });

  test('append + drain round-trips one event verbatim', () async {
    final ev = doneEvent(itemId: 'i1');

    await store.append(ev);
    final out = await store.drain();

    expect(out, hasLength(1));
    expect(out.single.payload, ev.payload);
    expect(out.single.actionId, NotificationAction.done.id);
    expect(out.single.id, 555);
  });

  test('drain preserves append order across many events', () async {
    for (var i = 0; i < 5; i++) {
      await store.append(doneEvent(itemId: 'i$i', notifId: i));
    }

    final out = await store.drain();

    expect(out.map((e) => e.id), [0, 1, 2, 3, 4]);
    for (var i = 0; i < 5; i++) {
      final decoded = NotificationPayload.tryDecode(out[i].payload)!;
      expect(decoded.itemId, 'i$i');
    }
  });

  test('drain deletes the file so a second drain returns empty', () async {
    await store.append(doneEvent(itemId: 'i1'));

    expect(await store.drain(), hasLength(1));
    expect(await file.exists(), isFalse,
        reason: 'leaving the file would replay the same intent forever');
    expect(await store.drain(), isEmpty);
  });

  test('an append after a drain starts a fresh file', () async {
    await store.append(doneEvent(itemId: 'i1'));
    await store.drain();

    await store.append(doneEvent(itemId: 'i2'));
    final out = await store.drain();

    expect(out, hasLength(1));
    expect(NotificationPayload.tryDecode(out.single.payload)!.itemId, 'i2');
  });

  test('corrupt / partial lines are skipped, valid lines preserved',
      () async {
    // Simulate a torn write: a half-flushed entry sandwiched between
    // good ones. The journal must keep going — losing one intent is
    // better than refusing to drain the rest.
    await store.append(doneEvent(itemId: 'good-1'));
    await file.writeAsString('{not valid json\n',
        mode: FileMode.append, flush: true);
    await file.writeAsString('\n', mode: FileMode.append, flush: true);
    await file.writeAsString('[1,2,3]\n', // valid JSON but not an object
        mode: FileMode.append, flush: true);
    await store.append(doneEvent(itemId: 'good-2'));

    final out = await store.drain();

    expect(out.map((e) => NotificationPayload.tryDecode(e.payload)!.itemId),
        ['good-1', 'good-2']);
  });

  test('append creates the parent directory on first write', () async {
    final nested = File(p.join(tmp.path, 'a', 'b', 'c', 'journal.jsonl'));
    final s = PendingNotificationIntents(file: nested);
    expect(await nested.parent.exists(), isFalse);

    await s.append(doneEvent(itemId: 'i1'));

    expect(await nested.exists(), isTrue);
    expect(await s.drain(), hasLength(1));
  });

  test('events with null fields encode + decode without loss', () async {
    // Defensive: a body tap would have null actionId; the journal is
    // never used for body taps today, but the codec must not corrupt
    // null fields silently — that would mask future bugs.
    await store.append((payload: null, actionId: null, id: null));

    final out = await store.drain();

    expect(out, hasLength(1));
    expect(out.single.payload, isNull);
    expect(out.single.actionId, isNull);
    expect(out.single.id, isNull);
  });
}
