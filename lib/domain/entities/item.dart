import '../recurrence/recurrence_rule.dart';
import 'enums.dart';

/// The universal capture entity. Everything the user records starts life
/// as an [Item] in the inbox and is moved to a canonical list during Clarify.
class Item {
  const Item({
    required this.id,
    required this.title,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
    this.projectId,
    this.contextId,
    this.dueAt,
    this.deferUntil,
    this.waitingOn,
    this.energy,
    this.timeEstimateMinutes,
    this.isTwoMin = false,
    this.completedAt,
    this.previousStatus,
    this.sortOrder = 0,
    this.projectSortOrder = 0,
    this.recurrence,
    this.recurrenceInterval = 1,
    this.recurrenceUntil,
    this.recurrenceCount,
    this.recurrenceDoneCount = 0,
    this.recurrenceByWeekdays = const [],
    this.recurrenceMonthlyWeek,
    this.recurrenceMonthlyWeekday,
    this.calendarEventId,
  });

  final String id;
  final String title;
  final String? notes;
  final ItemStatus status;
  final String? projectId;
  final String? contextId;
  final DateTime? dueAt;
  final DateTime? deferUntil;
  final String? waitingOn;
  final Energy? energy;
  final int? timeEstimateMinutes;
  final bool isTwoMin;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;

  /// The status this item held immediately before being completed. Set by
  /// `markCompleted`, cleared by `reopen`. Used to restore the item to the
  /// list it came from when a completion is undone.
  final ItemStatus? previousStatus;
  final int sortOrder;

  /// Manual order of this action *within its project*, isolated from
  /// [sortOrder] (the Do/Engage screen's key). Default `0` for every row;
  /// `watchForProject` orders by `projectSortOrder ASC, createdAt ASC`, so an
  /// all-zero project keeps its original creation order until the user drags
  /// to reorder. Meaningless for items with no [projectId].
  final int projectSortOrder;
  final Recurrence? recurrence;
  final int recurrenceInterval;

  /// End condition for the recurrence. At most one is meaningful at a time:
  /// [recurrenceUntil] stops the series once the next occurrence would fall
  /// after this date; [recurrenceCount] caps the total number of
  /// occurrences. Both null means the series repeats indefinitely.
  /// Invariant: both are null whenever [recurrence] is null.
  final DateTime? recurrenceUntil;
  final int? recurrenceCount;

  /// Number of occurrences completed *before* this instance, so this
  /// instance is occurrence number `recurrenceDoneCount + 1`. Advanced by
  /// one on each rollover; used to enforce [recurrenceCount].
  final int recurrenceDoneCount;

  /// Weekly pattern qualifier: weekdays the task repeats on
  /// (`DateTime.monday`(1)..`DateTime.sunday`(7)). Empty = the anchor's own
  /// weekday. Only meaningful when [recurrence] is weekly.
  final List<int> recurrenceByWeekdays;

  /// Monthly pattern qualifier: which week (1..5, or -1 = "last") and which
  /// weekday, e.g. "2nd Tuesday" / "last Friday". Both null = day-of-month.
  /// Only meaningful when [recurrence] is monthly.
  final int? recurrenceMonthlyWeek;
  final int? recurrenceMonthlyWeekday;

  /// The structured pattern for this item, or null when non-recurring. The
  /// single source of recurrence date math (see [RecurrenceRule]).
  RecurrenceRule? get recurrenceRule => recurrence == null
      ? null
      : RecurrenceRule(
          frequency: recurrence!,
          interval: recurrenceInterval,
          byWeekdays: recurrenceByWeekdays.toSet(),
          monthlyWeek: recurrenceMonthlyWeek,
          monthlyWeekday: recurrenceMonthlyWeekday,
        );

  /// Platform event id of the calendar event this item is mirrored to.
  /// Set by calendar sync's mirror-out; null when the item is not mirrored.
  final String? calendarEventId;

  Item copyWith({
    String? title,
    String? notes,
    ItemStatus? status,
    String? projectId,
    bool clearProject = false,
    String? contextId,
    bool clearContext = false,
    DateTime? dueAt,
    bool clearDueAt = false,
    DateTime? deferUntil,
    bool clearDeferUntil = false,
    String? waitingOn,
    bool clearWaitingOn = false,
    Energy? energy,
    bool clearEnergy = false,
    int? timeEstimateMinutes,
    bool clearTimeEstimate = false,
    bool? isTwoMin,
    DateTime? updatedAt,
    DateTime? completedAt,
    bool clearCompletedAt = false,
    ItemStatus? previousStatus,
    bool clearPreviousStatus = false,
    int? sortOrder,
    int? projectSortOrder,
    Recurrence? recurrence,
    bool clearRecurrence = false,
    int? recurrenceInterval,
    DateTime? recurrenceUntil,
    bool clearRecurrenceUntil = false,
    int? recurrenceCount,
    bool clearRecurrenceCount = false,
    int? recurrenceDoneCount,
    List<int>? recurrenceByWeekdays,
    int? recurrenceMonthlyWeek,
    int? recurrenceMonthlyWeekday,
    bool clearRecurrenceMonthlyNth = false,
    String? calendarEventId,
    bool clearCalendarEventId = false,
  }) {
    return Item(
      id: id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      projectId: clearProject ? null : (projectId ?? this.projectId),
      contextId: clearContext ? null : (contextId ?? this.contextId),
      dueAt: clearDueAt ? null : (dueAt ?? this.dueAt),
      deferUntil: clearDeferUntil ? null : (deferUntil ?? this.deferUntil),
      waitingOn: clearWaitingOn ? null : (waitingOn ?? this.waitingOn),
      energy: clearEnergy ? null : (energy ?? this.energy),
      timeEstimateMinutes: clearTimeEstimate
          ? null
          : (timeEstimateMinutes ?? this.timeEstimateMinutes),
      isTwoMin: isTwoMin ?? this.isTwoMin,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt:
          clearCompletedAt ? null : (completedAt ?? this.completedAt),
      previousStatus: clearPreviousStatus
          ? null
          : (previousStatus ?? this.previousStatus),
      sortOrder: sortOrder ?? this.sortOrder,
      projectSortOrder: projectSortOrder ?? this.projectSortOrder,
      recurrence: clearRecurrence ? null : (recurrence ?? this.recurrence),
      recurrenceInterval: recurrenceInterval ?? this.recurrenceInterval,
      // Invariant: no end condition can outlive the recurrence itself.
      recurrenceUntil: clearRecurrence || clearRecurrenceUntil
          ? null
          : (recurrenceUntil ?? this.recurrenceUntil),
      recurrenceCount: clearRecurrence || clearRecurrenceCount
          ? null
          : (recurrenceCount ?? this.recurrenceCount),
      recurrenceDoneCount:
          clearRecurrence ? 0 : (recurrenceDoneCount ?? this.recurrenceDoneCount),
      recurrenceByWeekdays: clearRecurrence
          ? const []
          : (recurrenceByWeekdays ?? this.recurrenceByWeekdays),
      recurrenceMonthlyWeek: clearRecurrence || clearRecurrenceMonthlyNth
          ? null
          : (recurrenceMonthlyWeek ?? this.recurrenceMonthlyWeek),
      recurrenceMonthlyWeekday: clearRecurrence || clearRecurrenceMonthlyNth
          ? null
          : (recurrenceMonthlyWeekday ?? this.recurrenceMonthlyWeekday),
      calendarEventId: clearCalendarEventId
          ? null
          : (calendarEventId ?? this.calendarEventId),
    );
  }
}
