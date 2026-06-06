import '../entities/entities.dart';

/// Pure domain function: given a completed recurring item, produce the next
/// scheduled instance. Returns null for non-recurring inputs, when the
/// series has reached its end condition (see [Item.recurrenceUntil] /
/// [Item.recurrenceCount]), and when the item has no anchor date —
/// recurrence shifts the due/defer date forward, so with neither there is
/// nothing to advance and the series cannot meaningfully continue.
///
/// The date math itself lives in [Item.recurrenceRule]
/// ([RecurrenceRule.nextAfter]); this function owns only the rollover
/// policy: end-condition enforcement and field carry-over. It has no DB /
/// IO dependencies — the `CompleteItem` use case supplies a fresh id and
/// the completion timestamp; the rest is deterministic.
Item? nextRecurrenceOf(
  Item completed, {
  required DateTime completedAt,
  required String newId,
}) {
  final rule = completed.recurrenceRule;
  if (rule == null) return null;

  // Count cap: this completion is occurrence number (doneCount + 1). If
  // that already is the last allowed occurrence, the series ends here.
  final cap = completed.recurrenceCount;
  if (cap != null && completed.recurrenceDoneCount + 1 >= cap) return null;

  final nextDueAt =
      completed.dueAt == null ? null : rule.nextAfter(completed.dueAt!);
  final nextDeferUntil = completed.deferUntil == null
      ? null
      : rule.nextAfter(completed.deferUntil!);

  // No anchor: recurrence works by shifting the due (else defer) date
  // forward. With neither, there is nothing to advance — a spawned clone
  // would carry no date and just reappear in the same list, indefinitely.
  // The series ends here regardless of any count cap.
  final nextAnchor = nextDueAt ?? nextDeferUntil;
  if (nextAnchor == null) return null;

  // Until-date cap: stop once the next occurrence's anchor would fall after
  // the end date (inclusive of the whole end day).
  final until = completed.recurrenceUntil;
  if (until != null) {
    final endOfUntilDay =
        DateTime(until.year, until.month, until.day, 23, 59, 59);
    if (nextAnchor.isAfter(endOfUntilDay)) return null;
  }

  final nextStatus = completed.status == ItemStatus.done
      ? ItemStatus.nextAction
      : completed.status;

  // GTD Option A: a next action's only date anchor is `deferUntil`. If the
  // series is anchored on `dueAt` but spawns a next action, fold the advanced
  // date into `deferUntil` so the tickler-driven series survives — the same
  // move the v7→v8 migration makes, applied here at rollover time. Without
  // this the persistence invariant would strip the spawned `dueAt` and the
  // series would silently die.
  final spawnsNextAction = nextStatus == ItemStatus.nextAction;
  final spawnedDueAt = spawnsNextAction ? null : nextDueAt;
  final spawnedDeferUntil =
      spawnsNextAction ? (nextDeferUntil ?? nextDueAt) : nextDeferUntil;

  return Item(
    id: newId,
    title: completed.title,
    notes: completed.notes,
    status: nextStatus,
    projectId: completed.projectId,
    contextId: completed.contextId,
    dueAt: spawnedDueAt,
    deferUntil: spawnedDeferUntil,
    waitingOn: completed.waitingOn,
    energy: completed.energy,
    timeEstimateMinutes: completed.timeEstimateMinutes,
    isTwoMin: completed.isTwoMin,
    createdAt: completedAt,
    updatedAt: completedAt,
    sortOrder: completed.sortOrder,
    // Keep the spawned occurrence in its project slot, mirroring sortOrder.
    projectSortOrder: completed.projectSortOrder,
    recurrence: completed.recurrence,
    recurrenceInterval: completed.recurrenceInterval,
    recurrenceUntil: completed.recurrenceUntil,
    recurrenceCount: completed.recurrenceCount,
    recurrenceDoneCount: completed.recurrenceDoneCount + 1,
    recurrenceByWeekdays: completed.recurrenceByWeekdays,
    recurrenceMonthlyWeek: completed.recurrenceMonthlyWeek,
    recurrenceMonthlyWeekday: completed.recurrenceMonthlyWeekday,
    // Keep the mirrored calendar series with the live instance: the system
    // calendar already holds the whole recurring event, so the next
    // instance must update that same event rather than spawn a duplicate.
    calendarEventId: completed.calendarEventId,
  );
}
