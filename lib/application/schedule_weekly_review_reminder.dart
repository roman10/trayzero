import '../core/clock.dart';
import '../core/notification_intent.dart';
import '../core/notification_scheduler.dart';

/// Notification id reserved for the weekly review nudge. Kept stable so
/// toggling the setting off cancels the same reminder that was scheduled.
const int weeklyReviewReminderId = 990001;

/// Scheduling the next Friday 4 PM reminder.
final class ScheduleWeeklyReviewReminder {
  ScheduleWeeklyReviewReminder({
    required NotificationScheduler scheduler,
    required Clock clock,
  })  : _scheduler = scheduler,
        _clock = clock;

  final NotificationScheduler _scheduler;
  final Clock _clock;

  static const _title = 'Weekly review time';
  static const _body =
      'Run through your inbox, lists and projects to keep your system '
      'trustworthy.';

  Future<void> call() => _scheduler.schedule(
        id: weeklyReviewReminderId,
        at: _nextFriday4pm(_clock.now()),
        title: _title,
        body: _body,
        repeat: ScheduleRepeat.weekly,
        payload: const NotificationPayload(
          kind: NotificationKind.weeklyReview,
          title: _title,
          body: _body,
        ).encode(),
      );
}

/// Cancels the same reminder. Separate use case to keep responsibilities
/// one-per-class.
final class CancelWeeklyReviewReminder {
  CancelWeeklyReviewReminder({required NotificationScheduler scheduler})
      : _scheduler = scheduler;
  final NotificationScheduler _scheduler;

  Future<void> call() => _scheduler.cancel(weeklyReviewReminderId);
}

/// Next Friday at 16:00, jumping a week if the current moment already
/// passed 16:00 on Friday. Pure helper kept here for unit-testability.
DateTime _nextFriday4pm(DateTime now) {
  var d = now;
  while (d.weekday != DateTime.friday) {
    d = d.add(const Duration(days: 1));
  }
  d = DateTime(d.year, d.month, d.day, 16);
  if (!d.isAfter(now)) d = d.add(const Duration(days: 7));
  return d;
}
