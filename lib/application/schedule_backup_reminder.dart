import '../core/clock.dart';
import '../core/notification_intent.dart';
import '../core/notification_scheduler.dart';

const int backupReminderId = 990002;

final class ScheduleBackupReminder {
  ScheduleBackupReminder({
    required NotificationScheduler scheduler,
    required Clock clock,
  })  : _scheduler = scheduler,
        _clock = clock;

  final NotificationScheduler _scheduler;
  final Clock _clock;

  static const _title = 'Back up your Trayzero data';
  static const _body =
      'Settings → Export backup → save to iCloud Drive or Google Drive.';

  Future<void> call() => _scheduler.schedule(
        id: backupReminderId,
        at: _nextSunday9am(_clock.now()),
        title: _title,
        body: _body,
        repeat: ScheduleRepeat.weekly,
        payload: const NotificationPayload(
          kind: NotificationKind.backup,
          title: _title,
          body: _body,
        ).encode(),
      );
}

final class CancelBackupReminder {
  CancelBackupReminder({required NotificationScheduler scheduler})
      : _scheduler = scheduler;
  final NotificationScheduler _scheduler;

  Future<void> call() => _scheduler.cancel(backupReminderId);
}

DateTime _nextSunday9am(DateTime now) {
  var d = now;
  while (d.weekday != DateTime.sunday) {
    d = d.add(const Duration(days: 1));
  }
  d = DateTime(d.year, d.month, d.day, 9);
  if (!d.isAfter(now)) d = d.add(const Duration(days: 7));
  return d;
}
