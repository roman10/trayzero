import 'entities/entities.dart';
import 'today_focus.dart';

/// An explicit filing decision reopens completed work. Calendar commitments
/// require a date; callers must obtain it before changing the destination.
Item changeItemStatus(Item item, ItemStatus status, {DateTime? dueAt}) {
  final due = dueAt ?? item.dueAt;
  if (status == ItemStatus.calendar && due == null) {
    throw ArgumentError('Calendar items require a due date');
  }
  return enforceItemInvariants(
    item.copyWith(
      status: status,
      dueAt: dueAt,
      // Next Actions cannot carry a hard date. Preserve a repeating item's
      // only anchor as a tickler, as recurrence rollover does, so filing it
      // here cannot silently terminate the series on its next completion.
      deferUntil: status == ItemStatus.nextAction && item.recurrence != null
          ? (item.deferUntil ?? due)
          : null,
      clearCompletedAt:
          status != ItemStatus.done && status != ItemStatus.trashed,
      clearPreviousStatus:
          status != ItemStatus.done && status != ItemStatus.trashed,
    ),
  );
}

/// GTD Option A: a next action's only date anchor is `deferUntil`.
///
/// A next action is discretionary in timing — it lives off the calendar, so it
/// never carries a hard `dueAt` (that belongs to the `calendar` hard
/// landscape). Enforced here, at the persistence narrow waist, so every write
/// path — item edit, inbox processing, bulk status change, recurrence rollover
/// — converges on the same rule rather than each remembering it. Pure and
/// idempotent: a well-formed item is returned unchanged.
Item enforceStatusDateInvariant(Item item) =>
    item.status == ItemStatus.nextAction && item.dueAt != null
    ? item.copyWith(clearDueAt: true)
    : item;

/// Every persistence invariant, applied at the write chokepoints
/// (`ItemRepository.upsert`, `SaveItem`, reminder re-arm). Adds the Today
/// focus rule (ADR 0007): moving an Item to Inbox, Someday, Reference, Trash,
/// or a Project row drops its focus, so it can never linger in Today.
Item enforceItemInvariants(Item item) {
  final dated = enforceStatusDateInvariant(item);
  return dated.focusedAt != null && !canHoldFocus(dated.status)
      ? dated.copyWith(clearFocusedAt: true)
      : dated;
}
