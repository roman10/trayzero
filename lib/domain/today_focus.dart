import 'entities/entities.dart';

/// Today focus rules (ADR 0007). An Item is committed to Today by stamping
/// [Item.focusedAt]; the stamp's local calendar day decides whether it is in
/// Today or carried over from an earlier day. Pure, so the midnight rollover
/// is just a new `now`.

/// Statuses that can be committed to Today: actionable work the user owns or
/// tracks. Inbox is unclarified; Someday, Reference, and Trash are explicitly
/// not commitments. Done keeps its stamp so Undo restores focus.
bool canHoldFocus(ItemStatus status) => switch (status) {
  ItemStatus.nextAction ||
  ItemStatus.waiting ||
  ItemStatus.calendar ||
  ItemStatus.done => true,
  ItemStatus.inbox ||
  ItemStatus.project ||
  ItemStatus.someday ||
  ItemStatus.reference ||
  ItemStatus.trashed => false,
};

/// Whether the user can star [item] now (open and of a focusable status).
bool canFocus(Item item) =>
    item.completedAt == null &&
    item.status != ItemStatus.done &&
    canHoldFocus(item.status);

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Focused on the current local day.
bool isFocusedToday(Item item, DateTime now) {
  final at = item.focusedAt;
  return at != null && _sameDay(at.toLocal(), now.toLocal());
}

/// Focused on an earlier day and still open: awaiting a keep/clear decision.
bool isCarriedOver(Item item, DateTime now) {
  final at = item.focusedAt;
  if (at == null || !canFocus(item)) return false;
  final local = at.toLocal();
  final today = now.toLocal();
  return DateTime(local.year, local.month, local.day)
      .isBefore(DateTime(today.year, today.month, today.day));
}
