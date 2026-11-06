import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/apple_reminders_gateway.dart';
import 'prepare_apple_reminders_import.dart';
import '../core/app_review.dart';
import '../core/clock.dart';
import '../core/things_snapshot_reader.dart';
import '../core/due_status.dart';
import '../core/home_widget_bridge.dart';
import '../core/id_generator.dart';
import '../core/notification_scheduler.dart';
import '../core/result.dart';
import '../core/system_settings.dart';
import '../core/week.dart';
import '../data/providers.dart';
import '../domain/entities/entities.dart';
import '../domain/tags.dart';
import '../features/settings/settings_controller.dart';
import 'backup_service.dart';
import 'add_agenda_item.dart';
import 'add_project_next_action.dart';
import 'change_project_status.dart';
import 'start_weekly_review.dart';
import 'save_weekly_review_step.dart';
import 'finish_weekly_review.dart';
import 'batch_delete_items.dart';
import 'capture_item.dart';
import 'check_exact_alarm_permission.dart';
import 'check_notification_permission.dart';
import 'complete_item.dart';
import 'convert_to_project.dart';
import 'current_time.dart';
import 'delete_item.dart';
import 'drain_external_queue.dart';
import 'export_backup.dart';
import 'finish_daily_review.dart';
import 'import_backup.dart';
import 'import_from_app.dart';
import 'purge_trash.dart';
import 'restore_trashed_item.dart';
import 'trash_item.dart';
import 'undo_process_decision.dart';
import 'mark_project_reviewed.dart';
import 'manage_tags.dart';
import 'maybe_request_app_review.dart';
import 'move_item_to_next_actions.dart';
import 'move_item_to_project.dart';
import 'open_notification_settings.dart';
import 'process_inbox_decision.dart';
import 'rearm_item_reminders.dart';
import 'restore_item_reminders.dart';
import 'rearm_standing_reminders.dart';
import 'reorder_project_actions.dart';
import 'request_exact_alarm_permission.dart';
import 'request_notification_permission.dart';
import 'save_item.dart';
import 'schedule_backup_reminder.dart';
import 'schedule_weekly_review_reminder.dart';
import 'set_today_focus.dart';
import 'skip_inbox_item.dart';
import 'sweep_stale_item_notifications.dart';

/// Re-export the data-layer DI so features depend on a single
/// application-facing facade rather than reaching into data/ directly.
export '../data/providers.dart';

final startWeeklyReviewProvider = Provider<StartWeeklyReview>(
  (ref) => StartWeeklyReview(
    reviews: ref.watch(reviewRepositoryProvider),
    clock: ref.watch(clockProvider),
    ids: ref.watch(idGeneratorProvider),
  ),
);
final saveWeeklyReviewStepProvider = Provider<SaveWeeklyReviewStep>(
  (ref) => SaveWeeklyReviewStep(ref.watch(reviewRepositoryProvider)),
);
final finishWeeklyReviewProvider = Provider<FinishWeeklyReview>(
  (ref) => FinishWeeklyReview(
    reviews: ref.watch(reviewRepositoryProvider),
    clock: ref.watch(clockProvider),
  ),
);
final incompleteWeeklyReviewProvider = StreamProvider<ReviewLog?>(
  (ref) => ref.watch(reviewRepositoryProvider).watchIncompleteWeekly(),
);
final reviewItemsProvider = StreamProvider.autoDispose<List<Item>>(
  (ref) => ref.watch(itemRepositoryProvider).watchActiveForReview(),
);
final addProjectNextActionProvider = Provider<AddProjectNextAction>(
  (ref) => AddProjectNextAction(
    projects: ref.watch(projectRepositoryProvider),
    saveItem: ref.watch(saveItemProvider),
    clock: ref.watch(clockProvider),
    ids: ref.watch(idGeneratorProvider),
  ),
);
final changeProjectStatusProvider = Provider<ChangeProjectStatus>(
  (ref) => ChangeProjectStatus(
    projects: ref.watch(projectRepositoryProvider),
    clock: ref.watch(clockProvider),
  ),
);

final captureItemProvider = Provider<CaptureItem>(
  (ref) => CaptureItem(
    items: ref.watch(itemRepositoryProvider),
    clock: ref.watch(clockProvider),
    ids: ref.watch(idGeneratorProvider),
    reconcileReminders: ref.watch(saveItemProvider).reconcileReminders,
    dueMinutesOfDay: ref.watch(deferSurfaceMinutesProvider),
    database: ref.watch(databaseProvider),
    tags: ref.watch(manageTagsProvider),
  ),
);

final manageTagsProvider = Provider<ManageTags>(
  (ref) => ManageTags(
    database: ref.watch(databaseProvider),
    tags: ref.watch(tagRepositoryProvider),
    clock: ref.watch(clockProvider),
    ids: ref.watch(idGeneratorProvider),
  ),
);

final addAgendaItemProvider = Provider<AddAgendaItem>(
  (ref) => AddAgendaItem(
    database: ref.watch(databaseProvider),
    items: ref.watch(itemRepositoryProvider),
    tags: ref.watch(tagRepositoryProvider),
    clock: ref.watch(clockProvider),
    ids: ref.watch(idGeneratorProvider),
  ),
);

final setTodayFocusProvider = Provider<SetTodayFocus>(
  (ref) => SetTodayFocus(
    items: ref.watch(itemRepositoryProvider),
    clock: ref.watch(clockProvider),
  ),
);

final finishDailyReviewProvider = Provider<FinishDailyReview>(
  (ref) => FinishDailyReview(
    database: ref.watch(databaseProvider),
    items: ref.watch(itemRepositoryProvider),
    reviews: ref.watch(reviewRepositoryProvider),
    clock: ref.watch(clockProvider),
    ids: ref.watch(idGeneratorProvider),
  ),
);

final markProjectReviewedProvider = Provider<MarkProjectReviewed>(
  (ref) => MarkProjectReviewed(
    projects: ref.watch(projectRepositoryProvider),
    clock: ref.watch(clockProvider),
  ),
);

final maybeRequestAppReviewProvider = Provider<MaybeRequestAppReview>(
  (ref) => MaybeRequestAppReview(
    prompter: ref.watch(appReviewPrompterProvider),
    store: ref.watch(reviewPromptStoreProvider),
    clock: ref.watch(clockProvider),
  ),
);

final recordAppSessionProvider = Provider<RecordAppSession>(
  (ref) => RecordAppSession(
    store: ref.watch(reviewPromptStoreProvider),
    clock: ref.watch(clockProvider),
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

/// Applies Today widget completions and Siri captures queued outside the
/// app (ADR 0009). One instance, so overlapping drains coalesce.
final drainExternalQueueProvider = Provider<DrainExternalQueue>(
  (ref) => DrainExternalQueue(
    bridge: ref.watch(homeWidgetBridgeProvider),
    items: ref.watch(itemRepositoryProvider),
    completeItem: ref.watch(completeItemProvider),
    captureItem: ref.watch(captureItemProvider),
  ),
);

final reopenItemProvider = Provider<ReopenItem>(
  (ref) => ReopenItem(
    items: ref.watch(itemRepositoryProvider),
    saveItem: ref.watch(saveItemProvider),
  ),
);

final undoCompleteProvider = Provider<UndoComplete>(
  (ref) => UndoComplete(
    items: ref.watch(itemRepositoryProvider),
    scheduler: ref.watch(notificationSchedulerProvider),
    saveItem: ref.watch(saveItemProvider),
  ),
);

final deleteItemProvider = Provider<DeleteItem>(
  (ref) => DeleteItem(
    items: ref.watch(itemRepositoryProvider),
    attachments: ref.watch(attachmentRepositoryProvider),
    scheduler: ref.watch(notificationSchedulerProvider),
  ),
);

final trashItemProvider = Provider<TrashItem>(
  (ref) => TrashItem(
    items: ref.watch(itemRepositoryProvider),
    scheduler: ref.watch(notificationSchedulerProvider),
    clock: ref.watch(clockProvider),
  ),
);

final restoreTrashedItemProvider = Provider<RestoreTrashedItem>(
  (ref) => RestoreTrashedItem(
    items: ref.watch(itemRepositoryProvider),
    saveItem: ref.watch(saveItemProvider),
  ),
);

final purgeTrashProvider = Provider<PurgeTrash>(
  (ref) => PurgeTrash(
    items: ref.watch(itemRepositoryProvider),
    deleteItem: ref.watch(deleteItemProvider),
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
    trashItem: ref.watch(trashItemProvider),
    completeItem: ref.watch(completeItemProvider),
    convertToProject: ref.watch(convertToProjectProvider),
  ),
);

final undoProcessDecisionProvider = Provider<UndoProcessDecision>(
  (ref) => UndoProcessDecision(
    saveItem: ref.watch(saveItemProvider),
    restoreTrashedItem: ref.watch(restoreTrashedItemProvider),
    undoComplete: ref.watch(undoCompleteProvider),
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
    scheduler: ref.watch(notificationSchedulerProvider),
    clock: ref.watch(clockProvider),
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
  (ref) => ImportBackup(
    backup: ref.watch(backupServiceProvider),
    reconcileReminders: RestoreItemReminders(
      items: ref.watch(itemRepositoryProvider),
      scheduler: ref.watch(notificationSchedulerProvider),
      clock: ref.watch(clockProvider),
      leadTimeMinutes: ref.watch(reminderLeadTimeProvider),
      deferSurfaceMinutes: ref.watch(deferSurfaceMinutesProvider),
    ).call,
  ),
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

final keptItemCountProvider = StreamProvider<int>(
  (ref) => ref.watch(itemRepositoryProvider).watchKeptCount(),
);

final _nextActionsSourceProvider = StreamProvider<List<Item>>(
  (ref) => ref.watch(itemRepositoryProvider).watchByStatus(ItemStatus.nextAction),
);

/// Keep the database subscription stable while the clock changes. Refresh
/// exactly at the next defer, and on clock ticks/resume, without a DB write.
final nextActionsProvider = Provider.autoDispose<AsyncValue<List<Item>>>((ref) {
  ref.watch(currentTimeProvider);
  // A database emission may arrive between clock ticks; use the actual
  // instant when filtering and scheduling its next transition.
  final now = ref.watch(clockProvider).now();
  final source = ref.watch(_nextActionsSourceProvider);
  return source.whenData((items) {
    DateTime? next;
    final available = <Item>[];
    for (final item in items) {
      final defer = item.deferUntil;
      if (defer == null || !defer.isAfter(now)) {
        available.add(item);
      } else if (next == null || defer.isBefore(next)) {
        next = defer;
      }
    }
    if (next != null) {
      final cancel = ref.read(clockProvider).scheduleAt(next, () {
        ref.read(currentTimeProvider.notifier).refresh();
      });
      ref.onDispose(cancel);
    }
    return available;
  });
});

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

final completedThisWeekProvider = StreamProvider.autoDispose<List<Item>>((ref) {
  final since = ref.watch(currentTimeProvider.select(startOfWeek));
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
final pastDueItemsProvider = Provider.autoDispose<List<Item>>((ref) {
  final now = ref.watch(currentTimeProvider);
  final all = ref.watch(_calendarSourceProvider).valueOrNull ?? const [];
  return all
      .where((i) => dueStatusOf(i.dueAt!, now).phase == DuePhase.overdue)
      .toList();
});

/// Today + upcoming due items — the live hard landscape.
final calendarItemsProvider = Provider.autoDispose<List<Item>>((ref) {
  final now = ref.watch(currentTimeProvider);
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
final engageCalendarBandProvider = Provider.autoDispose<List<Item>>((ref) {
  final now = ref.watch(currentTimeProvider);
  final all = ref.watch(_calendarSourceProvider).valueOrNull ?? const [];
  return all
      .where((i) => dueStatusOf(i.dueAt!, now).phase != DuePhase.upcoming)
      .toList();
});

/// Items finished since local midnight; Today counts those that were due
/// today as done even if never focused (calendar items are on Today by
/// definition).
final completedTodayProvider = StreamProvider.autoDispose<List<Item>>((ref) {
  final since = ref.watch(currentTimeProvider.select(_startOfDay));
  return ref.watch(itemRepositoryProvider).watchCompletedSince(since);
});

/// Items focused for Today, carried over from earlier days, or completed
/// today after being focused (ADR 0007). Re-queried at local midnight.
final focusedItemsProvider = StreamProvider.autoDispose<List<Item>>((ref) {
  final since = ref.watch(currentTimeProvider.select(_startOfDay));
  return ref.watch(itemRepositoryProvider).watchFocused(since: since);
});

DateTime _startOfDay(DateTime now) => DateTime(now.year, now.month, now.day);

/// Latest finished daily plan; Today offers the plan card until one exists
/// for the current day.
final latestDailyReviewProvider = StreamProvider<ReviewLog?>(
  (ref) => ref.watch(reviewRepositoryProvider).watchLatestCompletedDaily(),
);

/// Last action activity per Project id, for stalled-project detection.
final projectActivityProvider = StreamProvider.autoDispose<Map<String, DateTime>>(
  (ref) => ref.watch(itemRepositoryProvider).watchProjectActivity(),
);

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

/// Every tag, alphabetical (ADR 0010).
final tagsProvider = StreamProvider<List<Tag>>(
  (ref) => ref.watch(tagRepositoryProvider).watchAll(),
);

/// App-wide map of Item id → tag ids, watched by cards and filters. One
/// stream instead of one per card, like [attachmentSummariesProvider].
final itemTagIdsProvider = StreamProvider<Map<String, List<String>>>(
  (ref) => ref.watch(tagRepositoryProvider).watchItemTagIds(),
);

/// Open Items per tag id, for the Tags screen.
final tagOpenCountsProvider = StreamProvider.autoDispose<Map<String, int>>(
  (ref) => ref.watch(tagRepositoryProvider).watchOpenCounts(),
);

/// One Agenda per person tag (ADR 0010), built from the open Items. Empty
/// while no tag is a person, which hides the Review tab's Agendas bucket.
final agendasProvider = Provider.autoDispose<List<Agenda>>((ref) {
  final tags = ref.watch(tagsProvider).valueOrNull ?? const [];
  if (!tags.any((t) => t.isPerson)) return const [];
  return buildAgendas(
    tags: tags,
    items: ref.watch(reviewItemsProvider).valueOrNull ?? const [],
    itemTags: ref.watch(itemTagIdsProvider).valueOrNull ?? const {},
  );
});

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

final importFromAppProvider = Provider<ImportFromApp>(
  (ref) => ImportFromApp(
    thingsReader: ref.watch(thingsSnapshotReaderProvider),
    database: ref.watch(databaseProvider),
    items: ref.watch(itemRepositoryProvider),
    projects: ref.watch(projectRepositoryProvider),
    contexts: ref.watch(contextRepositoryProvider),
    tags: ref.watch(tagRepositoryProvider),
    ids: ref.watch(idGeneratorProvider),
    clock: ref.watch(clockProvider),
    deleteItems: ref.watch(batchDeleteItemsProvider),
    reconcileReminders: ref.watch(saveItemProvider).reconcileReminders,
    dueMinutesOfDay: ref.watch(deferSurfaceMinutesProvider),
  ),
);

final prepareAppleRemindersImportProvider = Provider<PrepareAppleRemindersImport>(
  (ref) => PrepareAppleRemindersImport(ref.watch(appleRemindersGatewayProvider)),
);
