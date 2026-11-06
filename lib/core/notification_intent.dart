import 'dart:convert';

/// What kind of reminder a notification represents. Drives which action
/// buttons it carries and where a body tap navigates.
enum NotificationKind { due, soon, ready, weeklyReview, backup }

/// Stable wire ids for each kind. Deliberately NOT `enum.name`: a payload
/// string is persisted by the OS the moment a notification is scheduled and
/// may be delivered days later, so renaming the enum must never change how
/// an already-scheduled notification decodes.
const _kindWire = <NotificationKind, String>{
  NotificationKind.due: 'due',
  NotificationKind.soon: 'soon',
  NotificationKind.ready: 'ready',
  NotificationKind.weeklyReview: 'wrev',
  NotificationKind.backup: 'bkup',
};

/// The structured intent carried in a notification's `payload` string.
///
/// [title] and [body] are duplicated into the payload on purpose: a Snooze
/// tap is handled in a background isolate with no database, so the only way
/// to re-post identical content is to read it back off the payload itself.
class NotificationPayload {
  const NotificationPayload({
    required this.kind,
    this.itemId,
    required this.title,
    required this.body,
    this.snoozedUntil,
  });

  final NotificationKind kind;

  /// The domain item this notification is about; null for standing
  /// reminders (weekly review, backup) which are not item-scoped.
  final String? itemId;
  final String title;
  final String body;

  /// User-requested alert override, persisted with the OS request so startup
  /// healing can distinguish a Snooze from an obsolete original reminder.
  /// Item dates and recurrence anchors remain unchanged.
  final DateTime? snoozedUntil;

  String encode() => jsonEncode({
    'k': _kindWire[kind],
    if (itemId != null) 'id': itemId,
    't': title,
    'b': body,
    if (snoozedUntil != null)
      'snoozedUntil': snoozedUntil!.toUtc().toIso8601String(),
  });

  /// Decodes a payload string, returning null for anything malformed or
  /// produced by an older build with an unknown kind — callers treat a null
  /// as "just open the app", never as an error.
  static NotificationPayload? tryDecode(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      NotificationKind? kind;
      for (final e in _kindWire.entries) {
        if (e.value == decoded['k']) {
          kind = e.key;
          break;
        }
      }
      if (kind == null) return null;
      return NotificationPayload(
        kind: kind,
        itemId: decoded['id'] as String?,
        title: (decoded['t'] as String?) ?? '',
        body: (decoded['b'] as String?) ?? '',
        snoozedUntil: decoded['snoozedUntil'] is String
            ? DateTime.tryParse(decoded['snoozedUntil'] as String)
            : null,
      );
    } catch (_) {
      return null;
    }
  }
}

/// A user-tappable action button under a notification. [id] is the stable
/// string the OS round-trips back to us in the response — never reuse or
/// repurpose one, an in-flight notification may still carry the old meaning.
enum NotificationAction {
  /// Re-arm the same notification one day out. Headless — the OS hands
  /// the tap to the background isolate, which reschedules and exits
  /// without ever bringing the app to the foreground.
  snooze('snooze', 'Snooze 1 day', foreground: false),

  /// Mark the item complete. Headless: there's nothing for the user to
  /// see or confirm, so opening the app would be a pointless interrupt.
  /// The background isolate can't safely run [CompleteItem] itself (no
  /// DI / DB), so it journals the tap; the next foreground launch
  /// drains the journal and runs the full use case (recurrence
  /// rollover, reminder teardown) for each entry. The in-app undo
  /// snackbar doesn't fire on a journaled completion — there's no UI
  /// alive when the tap happens — but Reopen from the completed list
  /// still works because `previousStatus` is captured the same way.
  done('done', 'Mark done', foreground: false),

  /// Triage a just-surfaced "Ready:" item into Next Actions. Headless
  /// for the same reason as [done] — pure mutation, no follow-up screen.
  moveToNextActions('next', 'Move to Next Actions', foreground: false),

  /// Open the Weekly Review screen. The whole point of the action is to
  /// put the user there, so it has to bring the app forward.
  startReview('start_review', 'Start review', foreground: true),

  /// Open Settings where the user can take/share a backup. Foreground
  /// for the same reason as [startReview] — the action exists to land
  /// the user on a screen.
  backupNow('backup_now', 'Back up now', foreground: true);

  const NotificationAction(this.id, this.label, {required this.foreground});

  final String id;
  final String label;

  /// Whether tapping this action brings the app to the foreground.
  /// Headless actions (snooze, done, moveToNextActions) never open the
  /// app — Snooze reschedules in place, the mutation actions are
  /// journaled for the next launch to apply.
  final bool foreground;

  static NotificationAction? fromId(String? id) {
    if (id == null) return null;
    for (final a in NotificationAction.values) {
      if (a.id == id) return a;
    }
    return null;
  }
}

/// The action buttons a given kind's notification should carry, in display
/// order. Android shows these inline; iOS exposes them on long-press via the
/// matching category.
///
/// Due/Soon are about work that is (nearly) actionable now, so they lead
/// with Done. Ready (a deferred item just surfacing) wants triage, not
/// completion, so it leads with "Move to Next Actions". The standing nudges
/// lead with their primary call to action.
///
/// Soon deliberately does NOT carry Snooze: Soon is *already* an early
/// advance warning, and snooze is dispatched from a background isolate
/// with no DB / no `dueAt` to clamp against (see
/// [NotificationAction.snooze]). Snoozing a "Soon: X" 30 min before its
/// Due would re-post a stale "upcoming" banner the next day, after Due
/// has already fired — there's no clean way to prevent that without
/// leaking item state into the payload. Removing the button eliminates
/// the whole bug class; Done stays for the case where the user finished
/// the task before its deadline. Due/Ready snooze remain because their
/// re-posts land at the same id and are replaced/cancelled by the
/// item-lifecycle paths ([CompleteItem], [DeleteItem],
/// [reconcileItemReminders]).
List<NotificationAction> actionsForKind(NotificationKind kind) {
  switch (kind) {
    case NotificationKind.soon:
      return const [NotificationAction.done];
    case NotificationKind.due:
      return const [NotificationAction.done, NotificationAction.snooze];
    case NotificationKind.ready:
      return const [
        NotificationAction.moveToNextActions,
        NotificationAction.snooze,
      ];
    case NotificationKind.weeklyReview:
      return const [NotificationAction.startReview, NotificationAction.snooze];
    case NotificationKind.backup:
      return const [NotificationAction.backupNow, NotificationAction.snooze];
  }
}

/// One day past [now], same wall-clock time. Snooze must be decidable in a
/// background isolate that has no clock or database beyond the value passed
/// in, so the rule is intentionally trivial and pure.
DateTime snoozeTarget(DateTime now) => now.add(const Duration(days: 1));

/// Where a body tap on a [payload]'s notification should navigate.
String routeForPayload(NotificationPayload payload) {
  switch (payload.kind) {
    case NotificationKind.due:
    case NotificationKind.soon:
    case NotificationKind.ready:
      return payload.itemId != null ? '/item/${payload.itemId}' : '/inbox';
    case NotificationKind.weeklyReview:
      return '/review';
    case NotificationKind.backup:
      return '/settings';
  }
}

/// What the app must do in response to a notification interaction. Pure:
/// the platform layer turns OS callbacks into [NotificationPayload] + action
/// id, this decides, and the wiring layer performs the effect.
sealed class NotificationDecision {
  const NotificationDecision();
}

/// Navigate to [location] (a go_router path). Result of a body tap.
class OpenScreen extends NotificationDecision {
  const OpenScreen(this.location);
  final String location;
}

/// Re-post [payload]'s notification at [at] with the same content and
/// buttons. Result of the Snooze action.
class RescheduleAt extends NotificationDecision {
  const RescheduleAt(this.payload, this.at);
  final NotificationPayload payload;
  final DateTime at;
}

/// Complete the item through the normal use case (recurrence rollover,
/// reminder teardown, undo). Result of the Done action.
class CompleteItemDecision extends NotificationDecision {
  const CompleteItemDecision(this.itemId);
  final String itemId;
}

/// Triage the item into Next Actions. Result of the "Move to Next Actions"
/// action on a Ready: notification.
class MoveToNextActionsDecision extends NotificationDecision {
  const MoveToNextActionsDecision(this.itemId);
  final String itemId;
}

/// Decide what a notification response means. [actionId] is null when the
/// notification body itself was tapped; an unrecognised id (e.g. an action
/// removed in a newer build, still live on an old scheduled notification) is
/// treated as a body tap so the worst case is "the app just opens".
///
/// The same body-tap fallback also applies to a known action id that the
/// current build no longer offers for this kind (e.g. Snooze on Soon after
/// it was retired): an in-flight notification scheduled before the change
/// can still carry the old button, and honouring it would re-open the
/// exact bug class the retirement closed.
NotificationDecision decideNotificationResponse({
  required NotificationPayload payload,
  required String? actionId,
  required DateTime now,
}) {
  // Item-scoped actions need an id; a payload should always carry one for
  // the kinds that offer them, but never trust it — fall back to merely
  // opening so a malformed payload can't strand the user.
  NotificationDecision itemScoped(NotificationDecision Function(String) make) {
    final id = payload.itemId;
    return id == null ? OpenScreen(routeForPayload(payload)) : make(id);
  }

  final action = NotificationAction.fromId(actionId);
  // A known action whose button has since been removed from this kind's
  // `actionsForKind` set is treated identically to an unknown id —
  // body-tap fallback. Same reason as the unknown-id case (see doc).
  if (action != null && !actionsForKind(payload.kind).contains(action)) {
    return OpenScreen(routeForPayload(payload));
  }

  switch (action) {
    case NotificationAction.snooze:
      final at = snoozeTarget(now);
      return RescheduleAt(
        NotificationPayload(
          kind: payload.kind,
          itemId: payload.itemId,
          title: payload.title,
          body: payload.body,
          snoozedUntil: at,
        ),
        at,
      );
    case NotificationAction.done:
      return itemScoped(CompleteItemDecision.new);
    case NotificationAction.moveToNextActions:
      return itemScoped(MoveToNextActionsDecision.new);
    // startReview / backupNow are pure navigation to the kind's own route;
    // null is a body tap, same thing.
    case NotificationAction.startReview:
    case NotificationAction.backupNow:
    case null:
      return OpenScreen(routeForPayload(payload));
  }
}
