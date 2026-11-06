import 'dart:convert';

import 'package:html/dom.dart' as html;
import 'package:html/parser.dart' as html_parser;
import 'package:timezone/timezone.dart' as tz;

import '../entities/entities.dart';
import 'import_plan.dart';
import 'import_values.dart';

/// Maps a fully fetched Graph snapshot; does not authenticate or write data.
ImportPlan parseMicrosoftTodo(List<Map<String, Object?>> lists) {
  final builder = ImportPlanBuilder();
  for (final list in lists) {
    final name = _string(list['displayName']);
    final tasks = list['tasks'];
    if (name == null || tasks is! List) {
      throw const ImportFormatException(ImportFailure.unrecognized);
    }
    final listStatus = list['wellknownListName'] == 'defaultList'
        ? ItemStatus.inbox
        : specialListStatus(name);
    String? project;
    for (final raw in tasks) {
      if (raw is! Map) {
        builder.warn(ImportWarning.unreadableRows);
        continue;
      }
      if (raw['status'] == 'completed') {
        builder.warn(ImportWarning.completedSkipped);
        continue;
      }
      final title = _string(raw['title']);
      if (title == null) {
        builder.warn(ImportWarning.unreadableRows);
        continue;
      }
      if (listStatus == null) project ??= builder.project(name);
      final status = switch (raw['status']) {
        'waitingOnOthers' => ItemStatus.waiting,
        'deferred' => ItemStatus.someday,
        _ => listStatus ?? ItemStatus.nextAction,
      };
      final notes = <String?>[];
      final unknownStatus = !const {
        'notStarted',
        'inProgress',
        'waitingOnOthers',
        'deferred',
      }.contains(raw['status']);
      if (unknownStatus) {
        notes.add('Status: ${raw['status'] ?? 'unknown'}');
      }
      final body = raw['body'];
      if (body is Map) {
        final content = _string(body['content']);
        if (content != null) {
          notes.add(
            body['contentType'] == 'html' ? _plainHtml(content) : content,
          );
        }
      }
      DateTime? date(String key) {
        final value = raw[key];
        if (value == null) return null;
        final parsed = _date(value);
        if (parsed == null) {
          notes.add('$key: ${jsonEncode(value)}');
          builder.warn(ImportWarning.unparsedDate);
        }
        return parsed;
      }

      final due = date('dueDateTime');
      final start = date('startDateTime');
      if (raw['recurrence'] != null) {
        notes.add('Repeats: ${jsonEncode(raw['recurrence'])}');
        builder.warn(ImportWarning.repeatInNotes);
      }
      if (raw['importance'] != null && raw['importance'] != 'normal') {
        builder.warn(ImportWarning.notImported);
      }
      if (raw['hasAttachments'] == true ||
          raw['isReminderOn'] == true ||
          unknownStatus) {
        builder.warn(ImportWarning.sourceDetailsNotImported);
      }
      final tags = <String>[
        if (raw['categories'] is List)
          for (final value in raw['categories'] as List) ?_string(value),
      ];
      builder.add(
        ImportedItem(
          title: title,
          status: status,
          project: project,
          notes: joinNotes(notes),
          tags: tags,
          dueAt: due,
          deferUntil: start,
        ),
      );
      final steps = raw['checklistItems'];
      if (steps is! List) {
        // The gateway must supply a complete array, including when empty.
        throw const ImportFormatException(ImportFailure.unrecognized);
      }
      for (final step in steps) {
        if (step is! Map || _string(step['displayName']) == null) {
          builder.warn(ImportWarning.unreadableRows);
          continue;
        }
        if (step['isChecked'] == true) {
          builder.warn(ImportWarning.completedSkipped);
          continue;
        }
        builder.add(
          ImportedItem(
            title: _string(step['displayName'])!,
            // Dates belong to the parent, not to each checklist step.
            status: status,
            project: project,
            tags: tags,
            notes: 'Subtask of: $title',
          ),
        );
        builder.warn(ImportWarning.subtasksFlattened);
      }
    }
  }
  final plan = builder.build(ImportSourceApp.microsoftToDo);
  if (plan.items.isEmpty) {
    throw const ImportFormatException(ImportFailure.noTasks);
  }
  return plan;
}

String? _string(Object? v) =>
    v is String && v.trim().isNotEmpty ? v.trim() : null;

String _plainHtml(String content) {
  final fragment = html_parser.parseFragment(content);
  for (final node in fragment.querySelectorAll('script, style')) {
    node.remove();
  }
  for (final link in fragment.querySelectorAll('a')) {
    final href = link.attributes['href'];
    if (href != null && href != link.text) {
      link.nodes.add(html.Text(' ($href)'));
    }
  }
  for (final br in fragment.querySelectorAll('br')) {
    br.replaceWith(html.Text('\n'));
  }
  // Table cells have no implicit text separator in the HTML DOM. Without
  // one a name and phone number, for example, would become a single word.
  for (final cell in fragment.querySelectorAll('td, th')) {
    if (cell.nextElementSibling != null) cell.nodes.add(html.Text('\t'));
  }
  for (final block in fragment.querySelectorAll(
    'p, div, li, h1, h2, h3, h4, h5, h6, tr, section, article, blockquote, pre',
  )) {
    // A suffix alone joins preceding inline text to this block's first word.
    final siblings = block.parentNode?.nodes;
    final index = siblings?.indexOf(block) ?? 0;
    final previous = index > 0 ? siblings![index - 1] : null;
    if (previous != null && !(previous.text ?? '').endsWith('\n')) {
      block.nodes.insert(0, html.Text('\n'));
    }
    block.nodes.add(html.Text('\n'));
  }
  return fragment.text!.trim();
}

DateTime? _date(Object value) {
  if (value is! Map) return null;
  final raw = _string(value['dateTime']);
  final zone = _string(value['timeZone']);
  if (raw == null) return null;
  // Graph's midnight To Do values represent calendar dates. Converting
  // midnight UTC to a negative offset would incorrectly move them a day back.
  final midnight = RegExp(
    r'^(\d{4}-\d{2}-\d{2})(?:T00:00:00(?:\.0+)?(?:Z|[+-]00:00)?)?$',
  ).firstMatch(raw);
  if (midnight != null) return parseAbsoluteDate(midnight.group(1)!);
  if (RegExp(r'(Z|[+-]\d{2}:?\d{2})$', caseSensitive: false).hasMatch(raw)) {
    return parseAbsoluteDate(raw);
  }
  // Parse the source wall-clock components in UTC first. Constructing an
  // ordinary local DateTime here would normalize a gap in the DEVICE's DST
  // rules before the SOURCE's time zone was even applied.
  final parsed = parseAbsoluteDate('${raw}Z')?.toUtc();
  if (parsed == null) return null;
  if (zone == 'UTC' || zone == 'Etc/UTC') return parsed.toLocal();
  if (zone == null) return null;
  try {
    final location = tz.getLocation(zone);
    final zoned = tz.TZDateTime(
      location,
      parsed.year,
      parsed.month,
      parsed.day,
      parsed.hour,
      parsed.minute,
      parsed.second,
    );
    if (zoned.year != parsed.year ||
        zoned.month != parsed.month ||
        zoned.day != parsed.day ||
        zoned.hour != parsed.hour ||
        zoned.minute != parsed.minute) {
      return null; // A nonexistent local time at a daylight-saving transition.
    }
    // TZDateTime.toLocal uses timezone's configured location, not the device
    // zone. Return an ordinary DateTime so persistence/UI use device time.
    return DateTime.fromMillisecondsSinceEpoch(zoned.millisecondsSinceEpoch);
  } on tz.LocationNotFoundException {
    return null;
  }
}
