import '../core/apple_reminders_gateway.dart';
import '../domain/entities/entities.dart';
import '../domain/import/import_plan.dart';
import '../domain/import/import_values.dart';

/// Reads selected lists without writing to either store. The resulting plan
/// uses the same preview, transaction, reminder reconciliation and Undo as files.
class PrepareAppleRemindersImport {
  const PrepareAppleRemindersImport(this.gateway);
  final AppleRemindersGateway gateway;

  Future<ImportPlan> call(
    List<AppleRemindersList> lists,
    Set<String> selected,
  ) async {
    final byId = {for (final list in lists) list.id: list};
    if (selected.isEmpty || !selected.every(byId.containsKey)) {
      throw const AppleRemindersException(AppleRemindersFailure.listsChanged);
    }
    final reminders = await gateway.readReminders(selected);
    final builder = ImportPlanBuilder();
    final seen = <String>{};
    for (final reminder in reminders) {
      if (!selected.contains(reminder.listId) || !seen.add(reminder.id)) {
        continue;
      }
      if (reminder.completed) {
        builder.warn(ImportWarning.completedSkipped);
        continue;
      }
      final title = reminder.title.trim();
      if (title.isEmpty) {
        builder.warn(ImportWarning.unreadableRows);
        continue;
      }
      final list = byId[reminder.listId]!;
      final notes = <String?>[
        reminder.notes,
        reminder.url,
        'List: ${list.title}',
        if (list.account.isNotEmpty) 'Account: ${list.account}',
      ];
      DateTime? date(String? raw, String label) {
        if (raw == null || raw.isEmpty) return null;
        final parsed = parseAbsoluteDate(raw);
        if (parsed == null) {
          notes.add('$label: $raw');
          builder.warn(ImportWarning.unparsedDate);
        }
        return parsed;
      }

      final due = date(reminder.due, 'Due');
      final start = date(reminder.start, 'Start');
      ImportedRepeat? repeat;
      if (reminder.recurrenceRules.isNotEmpty) {
        final rule = reminder.recurrenceRules.singleOrNull;
        repeat = rule == null ? null : _parseRepeat(rule, due ?? start);
        if (repeat == null) {
          notes.add('Repeats: ${reminder.recurrenceRules.join(' / ')}');
          builder.warn(ImportWarning.repeatInNotes);
        }
      }
      if (reminder.hasAlarms || reminder.priority != 0) {
        builder.warn(ImportWarning.notImported);
      }
      final status = specialListStatus(list.title);
      builder.add(
        ImportedItem(
          title: title,
          notes: joinNotes(notes),
          status: status ?? ItemStatus.nextAction,
          project: status == null ? builder.project(list.title) : null,
          dueAt: due,
          dueIsDateOnly: reminder.dueIsDateOnly,
          deferUntil: start,
          repeat: repeat,
        ),
      );
    }
    if (!builder.hasItems) {
      throw const ImportFormatException(ImportFailure.noTasks);
    }
    return builder.build(ImportSourceApp.appleReminders);
  }
}

/// EventKit can express intersections and skipped dates that Trayzero's
/// clamping recurrence policy cannot. Keep those rules intact in notes.
ImportedRepeat? _parseRepeat(String raw, DateTime? anchor) {
  if (anchor == null) return null;
  final parts = <String, String>{};
  for (final part in raw.toUpperCase().split(';')) {
    final pair = part.split('=');
    if (pair.length != 2 || parts.containsKey(pair.first)) return null;
    parts[pair.first] = pair.last;
  }
  // COUNT includes already completed source occurrences. Timed UNTIL would
  // be truncated by the shared parser; neither can be transferred exactly.
  if (parts.containsKey('COUNT') ||
      parts.containsKey('UNTIL') ||
      parts.containsKey('BYSETPOS')) {
    return null;
  }
  final frequency = parts['FREQ'];
  final monthDay = parts['BYMONTHDAY'];
  final byDay = parts['BYDAY'];
  if (parts.containsKey('BYMONTH') && frequency != 'YEARLY') return null;
  if (monthDay != null && frequency != 'MONTHLY' && frequency != 'YEARLY') {
    return null;
  }
  if (monthDay != null && byDay != null) return null;
  if (frequency == 'WEEKLY' &&
      (int.tryParse(parts['INTERVAL'] ?? '1') ?? 1) > 1 &&
      parts.containsKey('WKST') &&
      parts['WKST'] != 'MO') {
    return null;
  }
  if (frequency == 'MONTHLY') {
    if (byDay == null && anchor.day > 28) return null;
    if (byDay != null &&
        !RegExp(r'^(?:[1-4]|-1)(MO|TU|WE|TH|FR|SA|SU)$').hasMatch(byDay)) {
      return null;
    }
  }
  if (frequency == 'YEARLY' && anchor.month == 2 && anchor.day == 29) {
    return null;
  }
  return parseRRule(raw, anchor: anchor);
}
