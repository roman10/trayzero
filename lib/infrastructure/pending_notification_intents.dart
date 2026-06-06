import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../core/notification_scheduler.dart';

/// Append-only journal of notification actions whose effect couldn't run
/// at the moment of the tap.
///
/// Headless action buttons (Done / Move to Next Actions) are delivered to
/// a background isolate that has no Riverpod, no database, and may be
/// killed the instant the callback returns — running the full
/// [CompleteItem] / [MoveItemToNextActions] use case there would be
/// fragile. Instead the background handler appends one line per tap to
/// this journal; the next foreground launch drains it through
/// [HandleNotificationResponse] so the mutation runs through the normal
/// use case (recurrence rollover, reminder teardown, undo).
///
/// Format: JSON-Lines. One [NotificationActionEvent] per line, keys
/// shortened (`p` payload, `a` actionId, `i` id) to keep entries small.
/// Tearing a write (process killed mid-append) is tolerated: a partial
/// line fails to decode and is skipped on drain.
class PendingNotificationIntents {
  PendingNotificationIntents({required File file}) : _file = file;
  final File _file;

  /// Location under the app documents directory. Resolves identically
  /// from the main isolate and from the headless tap isolate — they
  /// share the app sandbox — provided plugin channels are wired (see
  /// [_ensurePluginChannels]).
  static Future<PendingNotificationIntents> defaultLocation() async {
    _ensurePluginChannels();
    final dir = await getApplicationDocumentsDirectory();
    return PendingNotificationIntents(
      file: File(p.join(dir.path, 'pending_notification_intents.jsonl')),
    );
  }

  /// Append one event. `flush: true` so a background isolate killed the
  /// moment this returns still durably enqueued the entry. Creates the
  /// parent directory on first write — fresh installs won't have it.
  Future<void> append(NotificationActionEvent event) async {
    await _file.parent.create(recursive: true);
    final line = jsonEncode({
      if (event.payload != null) 'p': event.payload,
      if (event.actionId != null) 'a': event.actionId,
      if (event.id != null) 'i': event.id,
    });
    await _file.writeAsString('$line\n', mode: FileMode.append, flush: true);
  }

  /// Read every queued event in append order and clear the journal.
  /// Malformed lines (a torn write from a killed isolate, a payload
  /// from a future build) are dropped silently — replaying a corrupt
  /// entry is worse than missing one tap whose notification already
  /// disappeared.
  Future<List<NotificationActionEvent>> drain() async {
    if (!await _file.exists()) return const [];
    final raw = await _file.readAsString();
    await _file.delete();
    final out = <NotificationActionEvent>[];
    for (final line in const LineSplitter().convert(raw)) {
      if (line.isEmpty) continue;
      try {
        final m = jsonDecode(line);
        if (m is! Map) continue;
        out.add((
          payload: m['p'] as String?,
          actionId: m['a'] as String?,
          id: m['i'] as int?,
        ));
      } catch (_) {
        // Skip corrupt line, keep draining the rest.
      }
    }
    return out;
  }
}

/// In a background isolate spawned by `flutter_local_notifications`, the
/// platform-channel registry is empty until the Dart plugin registrant
/// runs — without this, `path_provider` would `MissingPluginException`.
/// No-op when the registrant is already wired (foreground isolate, or a
/// second call from the same background isolate).
void _ensurePluginChannels() {
  try {
    DartPluginRegistrant.ensureInitialized();
  } catch (_) {
    // ensureInitialized is documented as safe to call repeatedly; on the
    // off chance a host swallowed the binding, fall through and let the
    // first platform call surface the real error.
  }
}
