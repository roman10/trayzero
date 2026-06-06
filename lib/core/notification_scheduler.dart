import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tri-state OS notification authorization.
///
/// The middle state is the one a `bool` could never express and the whole
/// reason this enum exists:
/// - [denied] — not granted, but the OS *will* still show a prompt on the
///   next [NotificationScheduler.requestPermission]. Recoverable in-app.
/// - [permanentlyDenied] — requesting is a silent no-op; the only recourse
///   is the system Settings app (Android "Don't ask again" / second deny;
///   iOS once its one-and-only prompt has been answered "Don't allow").
enum NotificationPermission { granted, denied, permanentlyDenied }

extension NotificationPermissionX on NotificationPermission {
  bool get isGranted => this == NotificationPermission.granted;

  /// True when an in-app [NotificationScheduler.requestPermission] can still
  /// surface the OS prompt. False means route the user to system Settings.
  bool get canPrompt => this == NotificationPermission.denied;
}

/// A raw notification interaction surfaced by the OS while the app is alive
/// (or the response that cold-launched it). The port only *transports* this;
/// all decisioning lives in `notification_intent.dart`.
///
/// - [payload] is the string the notification was scheduled with.
/// - [actionId] is null when the body was tapped, else the action button id.
/// - [id] is the OS notification id, needed to re-post it on a Snooze.
typedef NotificationActionEvent = ({String? payload, String? actionId, int? id});

/// One delivered notification currently visible in the OS tray, as returned
/// by [NotificationScheduler.getActiveNotifications]. Only the bits the
/// foreground sweep needs are surfaced — the id to cancel, and the payload
/// it was scheduled with so the sweep can decide whether it's still fresh.
typedef ActiveNotification = ({int id, String? payload});

/// How often a scheduled notification re-fires.
///
/// Kept as a port-level enum (not `flutter_local_notifications`'
/// `DateTimeComponents`) so `core/` stays platform-agnostic — same reason
/// [NotificationPermission] exists instead of leaking `permission_handler`.
/// The concrete impl maps [weekly] to the plugin's day-of-week match.
enum ScheduleRepeat { once, weekly }

/// Platform-agnostic local-notification port.
///
/// The concrete impl lives in `lib/infrastructure/local_notification_scheduler.dart`
/// and wraps `flutter_local_notifications` (scheduling) + `permission_handler`
/// (authorization). Tests use a fake that records scheduled / cancelled ids
/// in memory.
abstract class NotificationScheduler {
  Future<void> init();

  /// Current authorization, WITHOUT showing any prompt.
  Future<NotificationPermission> permissionStatus();

  /// Triggers the OS permission prompt when possible and returns the
  /// resulting state. When already [NotificationPermission.permanentlyDenied]
  /// the OS shows nothing and the prior state is returned.
  Future<NotificationPermission> requestPermission();

  /// Whether the platform currently allows exact alarms.
  ///
  /// On Android this maps to `AlarmManager.canScheduleExactAlarms()`. On other
  /// platforms, where exact-alarm access is not a separate concept, it should
  /// return true.
  Future<bool> canScheduleExactAlarms();

  /// Requests access to exact alarms when the platform requires it.
  ///
  /// On Android 12+ this may open the OS special-access screen. On other
  /// platforms it should return true immediately.
  Future<bool> requestExactAlarmsPermission();

  /// Schedule a local notification at [at].
  ///
  /// [repeat] == [ScheduleRepeat.weekly] re-fires every week at the same
  /// weekday + time; [ScheduleRepeat.once] (default) is a single shot.
  /// Implementations should drop a one-shot request whose [at] is already in
  /// the past (a weekly anchor is always future, so it is unaffected).
  ///
  /// [payload] (see `notification_intent.dart`) is round-tripped back to the
  /// app on tap/action; when set, the impl also attaches the action buttons
  /// for the payload's kind.
  ///
  /// [timeoutAfter], when set, asks the OS to auto-dismiss the delivered
  /// notification this long after it posts. Used to retire early-warning
  /// kinds (Soon, Ready) the moment Due fires for the same item, so the
  /// tray never holds a stale "upcoming" banner next to the live "Due".
  /// Android maps this to `Notification.Builder.setTimeoutAfter`; iOS has
  /// no equivalent and impls should ignore it there (the foreground sweep
  /// covers iOS).
  Future<void> schedule({
    required int id,
    required DateTime at,
    required String title,
    required String body,
    String channelId,
    String channelName,
    ScheduleRepeat repeat,
    String? payload,
    Duration? timeoutAfter,
  });

  Future<void> cancel(int id);
  Future<void> cancelAll();

  /// Snapshot of every notification currently visible in the OS tray. Used
  /// by the foreground sweep to retire stale Soon/Ready notifications whose
  /// underlying item has moved on (Due already passed, item completed,
  /// item deleted). FLN supports this on Android 6+ and iOS 10+; on older
  /// platforms the impl should return an empty list rather than throw, so
  /// the sweep silently no-ops.
  Future<List<ActiveNotification>> getActiveNotifications();

  /// Taps and action buttons received while the app is running (or was
  /// resumed by the interaction). Broadcast; a late listener misses nothing
  /// it didn't cause. A Snooze that arrives while the app is *dead* is
  /// handled headlessly by the impl and never reaches this stream.
  Stream<NotificationActionEvent> get responses;

  /// The interaction that cold-launched the app from a terminated state, if
  /// any. Consumed once — a second call returns null.
  Future<NotificationActionEvent?> takeLaunchResponse();
}

/// Stable int notification id derived from an entity id string. Lifted from
/// the old [NotificationsService] so call sites can compute matching ids
/// without holding a scheduler instance.
int notificationIdFor(String s, [int salt = 0]) {
  var h = 0;
  for (var i = 0; i < s.length; i++) {
    h = 0x1fffffff & (h + s.codeUnitAt(i));
    h = 0x1fffffff & (h + ((0x0007ffff & h) << 10));
    h ^= h >> 6;
  }
  h = 0x1fffffff & (h + ((0x03ffffff & h) << 3));
  h ^= h >> 11;
  h = 0x1fffffff & (h + ((0x00003fff & h) << 15));
  return (h + salt).abs() % 0x7fffffff;
}

final notificationSchedulerProvider = Provider<NotificationScheduler>((ref) {
  throw UnimplementedError('notificationSchedulerProvider must be overridden');
});
