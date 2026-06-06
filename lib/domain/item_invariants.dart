import 'entities/entities.dart';

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
