/// Where an item lives in the GTD system.
///
/// Every captured "thing" starts as [inbox] and is moved by the
/// Clarify step into one of the canonical lists.
enum ItemStatus {
  inbox,
  nextAction,
  project, // umbrella row representing the project itself; the [Project] row
  // carries the metadata. Use [Item.projectId] on next-actions to link them
  // to a project.
  waiting,
  someday,
  reference,
  calendar,
  done,
  trashed;

  String get label => switch (this) {
        ItemStatus.inbox => 'Inbox',
        ItemStatus.nextAction => 'Next Action',
        ItemStatus.project => 'Project',
        ItemStatus.waiting => 'Waiting For',
        ItemStatus.someday => 'Someday / Maybe',
        ItemStatus.reference => 'Reference',
        ItemStatus.calendar => 'Calendar',
        ItemStatus.done => 'Done',
        ItemStatus.trashed => 'Trash',
      };
}

enum Energy {
  low,
  medium,
  high;

  String get label => switch (this) {
        Energy.low => 'Low',
        Energy.medium => 'Medium',
        Energy.high => 'High',
      };
}

enum ProjectStatus {
  active,
  onHold,
  someday,
  done,
  dropped;

  String get label => switch (this) {
        ProjectStatus.active => 'Active',
        ProjectStatus.onHold => 'On Hold',
        ProjectStatus.someday => 'Someday',
        ProjectStatus.done => 'Done',
        ProjectStatus.dropped => 'Dropped',
      };
}

enum ReviewType { daily, weekly }

/// Stable identifiers persisted for a resumable Weekly Review.
enum WeeklyReviewStep {
  capture,
  inbox,
  actions,
  waiting,
  projects,
  calendar,
  someday,
}

/// Recurrence cadence for repeating actions. `null` on the item means
/// non-recurring. The instance is cloned with shifted dates on completion.
enum Recurrence {
  daily,
  weekly,
  monthly,
  yearly;

  String get label => switch (this) {
        Recurrence.daily => 'Daily',
        Recurrence.weekly => 'Weekly',
        Recurrence.monthly => 'Monthly',
        Recurrence.yearly => 'Yearly',
      };

  /// Singular unit noun for an interval phrase, e.g. "every 2 weeks".
  String get unitNoun => switch (this) {
        Recurrence.daily => 'day',
        Recurrence.weekly => 'week',
        Recurrence.monthly => 'month',
        Recurrence.yearly => 'year',
      };
}
