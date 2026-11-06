import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../core/apple_reminders_gateway.dart';

class MethodChannelAppleRemindersGateway implements AppleRemindersGateway {
  const MethodChannelAppleRemindersGateway();
  static const _channel = MethodChannel('app.cleartray/apple_reminders');

  @override
  bool get supported => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  Future<List<Object?>> _read(String method, [Object? arguments]) async {
    if (!supported) {
      throw const AppleRemindersException(AppleRemindersFailure.unavailable);
    }
    try {
      final response = _channel.invokeListMethod<Object?>(method, arguments);
      // A person may take time to answer the system permission prompt.
      final value = await (method == 'requestLists'
          ? response
          : response.timeout(const Duration(seconds: 30)));
      if (value == null) {
        throw const FormatException('Missing Reminders response');
      }
      return value;
    } on PlatformException catch (e) {
      throw AppleRemindersException(switch (e.code) {
        'permission_denied' => AppleRemindersFailure.denied,
        'lists_changed' => AppleRemindersFailure.listsChanged,
        _ => AppleRemindersFailure.unavailable,
      });
    }
  }

  @override
  Future<List<AppleRemindersList>> requestLists() async => [
    for (final raw in await _read('requestLists'))
      if (raw is Map)
        AppleRemindersList(
          id: raw['id'] as String,
          title: raw['title'] as String,
          account: raw['account'] as String,
        )
      else
        throw const FormatException('Invalid Reminders list'),
  ];

  @override
  Future<List<AppleReminder>> readReminders(Set<String> listIds) async {
    // An empty selection must never mean "all lists" on the native side.
    if (listIds.isEmpty) return const [];
    return [
      for (final raw in await _read('readReminders', {
        'listIds': listIds.toList(),
      }))
        if (raw is Map)
          AppleReminder(
            id: raw['id'] as String,
            listId: raw['listId'] as String,
            title: raw['title'] as String,
            notes: raw['notes'] as String?,
            url: raw['url'] as String?,
            completed: raw['completed'] as bool,
            due: raw['due'] as String?,
            start: raw['start'] as String?,
            dueIsDateOnly: raw['dueIsDateOnly'] as bool,
            recurrenceRules: (raw['recurrenceRules'] as List).cast<String>(),
            hasAlarms: raw['hasAlarms'] as bool,
            priority: raw['priority'] as int,
          )
        else
          throw const FormatException('Invalid reminder'),
    ];
  }
}
