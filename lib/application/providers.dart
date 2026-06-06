import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/clock.dart';
import '../core/due_status.dart';
import '../core/id_generator.dart';
import '../core/notification_scheduler.dart';
import '../core/result.dart';
import '../core/system_settings.dart';
import '../core/week.dart';
import '../data/providers.dart';
import '../domain/entities/entities.dart';
import '../features/settings/settings_controller.dart';
import 'backup_service.dart';
import 'batch_delete_items.dart';
import 'capture_item.dart';
import 'check_exact_alarm_permission.dart';
import 'check_notification_permission.dart';
import 'complete_item.dart';
import 'convert_to_project.dart';
import 'delete_item.dart';
import 'export_backup.dart';
import 'import_backup.dart';
import 'move_item_to_next_actions.dart';
import 'move_item_to_project.dart';
import 'open_notification_settings.dart';
import 'process_inbox_decision.dart';
import 'rearm_item_reminders.dart';
import 'rearm_standing_reminders.dart';
import 'reorder_project_actions.dart';
import 'request_exact_alarm_permission.dart';
import 'request_notification_permission.dart';
import 'save_item.dart';
import 'schedule_backup_reminder.dart';
import 'schedule_weekly_review_reminder.dart';
import 'skip_inbox_item.dart';
import 'sweep_stale_item_notifications.dart';

/// Re-export the data-layer DI so features depend on a single
/// application-facing facade rather than reaching into data/ directly.
export '../data/providers.dart';

final captureItemProvider = Provider<CaptureItem>(
  (ref) => CaptureItem(
    items: ref.watch(itemRepositoryProvider),
    clock: ref.watch(clockProvider),
    ids: ref.watch(idGeneratorProvider),
  ),
);

final saveItemProvider = Provider<SaveItem>(
  (ref) => SaveItem(
    items: ref.watch(itemRepositoryProvider),
    scheduler: ref.watch(notificationSchedulerProvider),
    clock: ref.watch(clockProvider),
    leadTimeMinutes: ref.watch(reminderLeadTimeProvider),
    deferSurfaceMinutes: ref.watch(deferSurfaceMinutesProvider),
  ),
);

final completeItemProvider = Provider<CompleteItem>(
  (ref) => CompleteItem(
    items: ref.watch(itemRepositoryProvider),
    scheduler: ref.watch(notificationSchedulerProvider),
    clock: ref.watch(clockProvider),
    ids: ref.watch(idGeneratorProvider),
    saveItem: ref.watch(saveItemProvider),
  ),
);

final reopenItemProvider = Provider<ReopenItem>(
  (ref) => ReopenItem(
    items: ref.watch(itemRepositoryProvider),
    clock: ref.watch(clockProvider),
  ),
);

final undoCompleteProvider = Provider<UndoComplete>(
  (ref) => UndoComplete(
    items: ref.watch(itemRepositoryProvider),
    clock: ref.watch(clockProvider),
    scheduler: ref.watch(notificationSchedulerProvider),
  ),
);

final deleteItemProvider = Provider<DeleteItem>(
  (ref) => DeleteItem(
    items: ref.watch(itemRepositoryProvider),
    attachments: ref.watch(attachmentRepositoryProvider),
    scheduler: ref.watch(notificationSchedulerProvider),
  ),
);

final batchDeleteItemsProvider = Provider<BatchDeleteItems>(
  (ref) => BatchDeleteItems(
    items: ref.watch(itemRepositoryProvider),
    attachments: ref.watch(attachmentRepositoryProvider),
    scheduler: ref.watch(notificationSchedulerProvider),
  ),
);

final skipInboxItemProvider = Provider<SkipInboxItem>(
  (ref) => SkipInboxItem(
    items: ref.watch(itemRepositoryProvider),
    clock: ref.watch(clockProvider),
  ),
);

final convertToProjectProvider = Provider<ConvertToProject>(
  (ref) => ConvertToProject(
    projects: ref.watch(projectRepositoryProvider),
    saveItem: ref.watch(saveItemProvider),
    clock: ref.watch(clockProvider),
    ids: ref.watch(idGeneratorProvider),
  ),
);

final moveItemToProjectProvider = Provider<MoveItemToProject>(
  (ref) => MoveItemToProject(saveItem: ref.watch(saveItemProvider)),
);

final moveItemToNextActionsProvider = Provider<MoveItemToNextActions>(
  (ref) => MoveItemToNextActions(
    items: ref.watch(itemRepositoryProvider),
    saveItem: ref.watch(saveItemProvider),
  ),
);

final reorderProjectActionsProvider = Provider<ReorderProjectActions>(
  (ref) => ReorderProjectActions(
    items: ref.watch(itemRepositoryProvider),
    clock: ref.watch(clockProvider),
  ),
);

final processInboxDecisionProvider = Provider<ProcessInboxDecisionUseCase>(
  (ref) => ProcessInboxDecisionUseCase(
    saveItem: ref.watch(saveItemProvider),
    deleteItem: ref.watch(deleteItemProvider),
    completeItem: ref.watch(completeItemProvider),
    convertToProject: ref.watch(convertToProjectProvider),
  ),
);

final requestNotificationPermissionProvider =
    Provider<RequestNotificationPermission>(
      (ref) => RequestNotificationPermission(
        scheduler: ref.watch(notificationSchedulerProvider),
      ),
    );

final checkNotificationPermissionProvider =
    Provider<CheckNotificationPermission>(
      (ref) => CheckNotificationPermission(
        scheduler: ref.watch(notificationSchedulerProvider),
      ),
    );

final checkExactAlarmPermissionProvider = Provider<CheckExactAlarmPermission>(
  (ref) => CheckExactAlarmPermission(
    scheduler: ref.watch(notificationSchedulerProvider),
  ),
);

final openNotificationSettingsProvider = Provider<OpenNotificationSettings>(
  (ref) =>
      OpenNotificationSettings(settings: ref.watch(systemSettingsProvider)),
);

final requestExactAlarmPermissionProvider =
    Provider<RequestExactAlarmPermission>(
      (ref) => RequestExactAlarmPermission(
        scheduler: ref.watch(notificationSchedulerProvider),
      ),
    );

/// Reactive notification-permission status for display surfaces (the
/// Settings tile). Invalidated on app resume so a grant made in the OS
/// settings app is reflected when the user returns. Reads fail-open
/// (granted) so a transient read error never shows a false "blocked".
final notificationPermissionStatusProvider =
    FutureProvider.autoDispose<NotificationPermission>((ref) async {
      final res = await ref.watch(checkNotificationPermissionProvider).call();
      return switch (res) {
        Ok(:final value) => value,
        Err() => NotificationPermission.granted,
      };
    });

final scheduleWeeklyReviewReminderProvider =
    Provider<ScheduleWeeklyReviewReminder>(
      (ref) => ScheduleWeeklyReviewReminder(
        scheduler: ref.watch(notificationSchedulerProvider),
        clock: ref.watch(clockProvider),
      ),
    );

final cancelWeeklyReviewReminderProvider = Provider<CancelWeeklyReviewReminder>(
  (ref) => CancelWeeklyReviewReminder(
    scheduler: ref.watch(notificationSchedulerProvider),
  ),
);

final scheduleBackupReminderProvider = Provider<ScheduleBackupReminder>(
  (ref) => ScheduleBackupReminder(
    scheduler: ref.watch(notificationSchedulerProvider),
    clock: ref.watch(clockProvider),
  ),
);

final cancelBackupReminderProvider = Provider<CancelBackupReminder>(
  (ref) =>
      CancelBackupReminder(scheduler: ref.watch(notificationSchedulerProvider)),
);

/// Re-arms the enabled standing reminders on launch (see
/// [RearmStandingReminders]). Read once from `main()` after notifications
/// init; not watched by the UI.
final rearmStandingRemindersProvider = Provider<RearmStandingReminders>(
  (ref) => RearmStandingReminders(
    scheduleWeeklyReview: ref.watch(scheduleWeeklyReviewReminderProvider),
    scheduleBackup: ref.watch(scheduleBackupReminderProvider),
    weeklyReviewEnabled: ref.watch(weeklyReviewReminderProvider),
    backupEnabled: ref.watch(backupReminderEnabledProvider),
  ),
);

/// Re-arms every active dated item's reminder on launch (see
/// [RearmItemReminders]) — heals a restored backup / Google Tasks import and
/// any OEM-wiped alarm. Read once from `main()` after notifications init,
/// off the critical path; not watched by the UI.
final rearmItemRemindersProvider = Provider<RearmItemReminders>(
  (ref) => RearmItemReminders(
    items: ref.watch(itemRepositoryProvider),
    scheduler: ref.watch(notificationSchedulerProvider),
    clock: ref.watch(clockProvider),
    leadTimeMinutes: ref.watch(reminderLeadTimeProvider),
    deferSurfaceMinutes: ref.watch(deferSurfaceMinutesProvider),
  ),
);

/// Foreground sweep of stale "Soon:" / "Ready:" notifications (see
/// [SweepStaleItemNotifications]). The iOS counterpart of Android's
/// `timeoutAfter`-based auto-dismiss. Read from `main()` and from the
/// app's resume hook; not watched by the UI.
final sweepStaleItemNotificationsProvider =
    Provider<SweepStaleItemNotifications>(
  (ref) => SweepStaleItemNotifications(
    items: ref.watch(itemRepositoryProvider),
    scheduler: ref.watch(notificationSchedulerProvider),
    clock: ref.watch(clockProvider),
  ),
);

final exportBackupProvider = Provider<ExportBackup>(
  (ref) => ExportBackup(backup: ref.watch(backupServiceProvider)),
);

final importBackupProvider = Provider<ImportBackup>(
  (ref) => ImportBackup(backup: ref.watch(backupServiceProvider)),
);

// ---- Canonical read-model streams -------------------------------------------
// Derived views over the repositories. Application-level read models the UI
// watches; the UI never queries repositories directly for these.

final areasProvider = StreamProvider<List<Area>>(
  (ref) => ref.watch(areaRepositoryProvider).watchAll(),
);

final attachmentsForItemProvider =
    StreamProvider.family<List<Attachment>, String>(
      (ref, id) => ref.watch(attachmentRepositoryProvider).watchForItem(id),
    );

/// App-wide map of itemId -> attachment counts, watched by list cards for the
/// media indicator. One stream instead of one per card.
final attachmentSummariesProvider =
    StreamProvider<Map<String, AttachmentSummary>>(
      (ref) => ref.watch(attachmentRepositoryProvider).watchSummaries(),
    );

final inboxItemsProvider = StreamProvider<List<Item>>(
  (ref) => ref.watch(itemRepositoryProvider).watchInbox(),
);

final inboxCountProvider = StreamProvider<int>(
  (ref) => ref.watch(itemRepositoryProvider).watchInboxCount(),
);

final nextActionsProvider = StreamProvider<List<Item>>(
  (ref) => ref.watch(itemRepositoryProvider).watchNextActions(),
);

final waitingForProvider = StreamProvider<List<Item>>(
  (ref) => ref.watch(itemRepositoryProvider).watchByStatus(ItemStatus.waiting),
);

final somedayProvider = StreamProvider<List<Item>>(
  (ref) => ref.watch(itemRepositoryProvider).watchByStatus(ItemStatus.someday),
);

final referenceProvider = StreamProvider<List<Item>>(
  (ref) =>
      ref.watch(itemRepositoryProvider).watchByStatus(ItemStatus.reference),
);

final completedThisWeekProvider = StreamProvider<List<Item>>((ref) {
  final since = startOfWeek(ref.watch(clockProvider).now());
  return ref.watch(itemRepositoryProvider).watchCompletedSince(since);
});

/// All active, non-trashed items that have a due date, ordered by dueAt.
/// Split below into past-due ("needs re-decision") vs upcoming so a passed
/// hard-landscape date prompts a conscious choice instead of silently
/// lingering in the Calendar list.
final _calendarSourceProvider = StreamProvider<List<Item>>(
  (ref) => ref.watch(itemRepositoryProvider).watchCalendar(),
);

/// Items whose due day is in the past — they need rescheduling, completing,
/// or dropping (GTD: a missed hard date is a decision, not a notification).
final pastDueItemsProvider = Provider<List<Item>>((ref) {
  final now = ref.watch(clockProvider).now();
  final all = ref.watch(_calendarSourceProvider).valueOrNull ?? const [];
  return all
      .where((i) => dueStatusOf(i.dueAt!, now).phase == DuePhase.overdue)
      .toList();
});

/// Today + upcoming due items — the live hard landscape.
final calendarItemsProvider = Provider<List<Item>>((ref) {
  final now = ref.watch(clockProvider).now();
  final all = ref.watch(_calendarSourceProvider).valueOrNull ?? const [];
  return all
      .where((i) => dueStatusOf(i.dueAt!, now).phase != DuePhase.overdue)
      .toList();
});

/// The hard-landscape band shown on the Do ("Engage") screen: calendar
/// items due today or already overdue. GTD's Engage step is "calendar
/// first, then next actions", so these surface on the same screen the user
/// picks work from — separate from, and unaffected by, the discretionary
/// context/energy/time filters. Upcoming calendar items stay on Review only.
///
/// Order: most-overdue first, then today. `_calendarSourceProvider` is
/// already sorted by `dueAt` ascending and every overdue date precedes
/// every today date, so a phase filter preserves that exact order.
final engageCalendarBandProvider = Provider<List<Item>>((ref) {
  final now = ref.watch(clockProvider).now();
  final all = ref.watch(_calendarSourceProvider).valueOrNull ?? const [];
  return all
      .where((i) => dueStatusOf(i.dueAt!, now).phase != DuePhase.upcoming)
      .toList();
});

final projectsProvider = StreamProvider<List<Project>>(
  (ref) => ref.watch(projectRepositoryProvider).watchAll(),
);

final activeProjectsProvider = StreamProvider<List<Project>>(
  (ref) =>
      ref.watch(projectRepositoryProvider).watchByStatus(ProjectStatus.active),
);

final contextsProvider = StreamProvider<List<GtdContext>>(
  (ref) => ref.watch(contextRepositoryProvider).watchAll(),
);

final projectItemsProvider = StreamProvider.family<List<Item>, String>(
  (ref, id) => ref.watch(itemRepositoryProvider).watchForProject(id),
);

/// Completion history for one project. Kept separate from
/// [projectItemsProvider] so the active lists (and the Projects screen's
/// per-tile `hasNext` check) never pay for done rows.
final completedProjectItemsProvider =
    StreamProvider.family<List<Item>, String>(
  (ref, id) => ref.watch(itemRepositoryProvider).watchCompletedForProject(id),
);
