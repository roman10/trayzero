import 'entities/entities.dart';

/// Whether an active project has movement defined, in the GTD sense.
///
/// - [healthy]: at least one next action exists (a step owned by the user
///   and parked on a context list).
/// - [awaiting]: no next action, but at least one waiting-for or scheduled
///   (calendar) item — the project is still in motion via another party
///   or a fixed date.
/// - [stalled]: nothing is moving the project forward. Someday/maybe and
///   reference items do not count, since they are explicitly deferred or
///   purely informational. Inbox items inside the project also don't count
///   — they haven't been clarified yet.
enum ProjectMovement { healthy, awaiting, stalled }

ProjectMovement projectMovement(Iterable<Item> items) {
  var hasAwaiting = false;
  for (final i in items) {
    switch (i.status) {
      case ItemStatus.nextAction:
        return ProjectMovement.healthy;
      case ItemStatus.waiting:
      case ItemStatus.calendar:
        hasAwaiting = true;
      case ItemStatus.inbox:
      case ItemStatus.project:
      case ItemStatus.someday:
      case ItemStatus.reference:
      case ItemStatus.done:
      case ItemStatus.trashed:
        break;
    }
  }
  return hasAwaiting ? ProjectMovement.awaiting : ProjectMovement.stalled;
}
