import 'package:cleartray/core/apple_reminders_gateway.dart';

class FakeAppleRemindersGateway implements AppleRemindersGateway {
  @override
  bool supported = true;
  List<AppleRemindersList> lists = const [
    AppleRemindersList(id: 'home', title: 'Home', account: 'iCloud'),
    AppleRemindersList(id: 'inbox', title: 'Inbox', account: 'iCloud'),
    AppleRemindersList(id: 'work', title: 'Work', account: 'Exchange'),
  ];
  List<AppleReminder> reminders = const [];
  Object? error;
  int requests = 0;
  final reads = <Set<String>>[];
  Future<List<AppleRemindersList>> Function()? onRequest;

  @override
  Future<List<AppleRemindersList>> requestLists() async {
    requests++;
    if (error case final error?) throw error;
    return onRequest == null ? lists : onRequest!();
  }

  @override
  Future<List<AppleReminder>> readReminders(Set<String> listIds) async {
    reads.add({...listIds});
    if (error case final error?) throw error;
    return reminders;
  }
}
