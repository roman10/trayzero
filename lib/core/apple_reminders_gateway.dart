import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Read-only snapshot of a list available through the system Reminders store.
class AppleRemindersList {
  const AppleRemindersList({
    required this.id,
    required this.title,
    this.account = '',
  });
  final String id;
  final String title;
  final String account;
}

/// Values returned by public EventKit APIs. Dates use ISO 8601; date-only
/// values deliberately have no timezone or time component.
class AppleReminder {
  const AppleReminder({
    required this.id,
    required this.listId,
    required this.title,
    this.notes,
    this.url,
    this.completed = false,
    this.due,
    this.start,
    this.dueIsDateOnly = false,
    this.recurrenceRules = const [],
    this.hasAlarms = false,
    this.priority = 0,
  });
  final String id;
  final String listId;
  final String title;
  final String? notes;
  final String? url;
  final bool completed;
  final String? due;
  final String? start;
  final bool dueIsDateOnly;
  final List<String> recurrenceRules;
  final bool hasAlarms;
  final int priority;
}

enum AppleRemindersFailure { denied, unavailable, listsChanged }

class AppleRemindersException implements Exception {
  const AppleRemindersException(this.failure);
  final AppleRemindersFailure failure;
}

/// No write/delete operations: importing and undoing never modify the source.
abstract class AppleRemindersGateway {
  bool get supported;

  /// Requests access only when explicitly invoked by the user.
  Future<List<AppleRemindersList>> requestLists();
  Future<List<AppleReminder>> readReminders(Set<String> listIds);
}

class UnsupportedAppleRemindersGateway implements AppleRemindersGateway {
  const UnsupportedAppleRemindersGateway();
  @override
  bool get supported => false;
  @override
  Future<List<AppleRemindersList>> requestLists() async =>
      throw const AppleRemindersException(AppleRemindersFailure.unavailable);
  @override
  Future<List<AppleReminder>> readReminders(Set<String> listIds) async =>
      throw const AppleRemindersException(AppleRemindersFailure.unavailable);
}

final appleRemindersGatewayProvider = Provider<AppleRemindersGateway>(
  (ref) => const UnsupportedAppleRemindersGateway(),
);
