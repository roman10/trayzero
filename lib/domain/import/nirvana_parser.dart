import 'dart:convert';

import '../entities/entities.dart';
import 'csv.dart';
import 'import_plan.dart';
import 'import_values.dart';

/// Nirvana data export, CSV or JSON (ADR 0008). Best-effort: Nirvana does
/// not document the file layout, so records are read by field name against
/// Nirvana's API task model (`type`, `state`, `parentid`, `name`, `note`,
/// `tags`, `energy`, `etime`, `waitingfor`, `startdate`, `duedate`,
/// `recurring`, `completed`, `cancelled`, `deleted`), ignoring case and
/// punctuation. `state` may be the API number or its word. A file without a
/// name and a state or type field is rejected rather than guessed at.
ImportPlan parseNirvana(String text) {
  final records = _records(text);
  if (records == null ||
      records.isEmpty ||
      !records.any((r) => r.containsKey('name')) ||
      !records.any((r) => r.containsKey('state') || r.containsKey('type'))) {
    throw const ImportFormatException(ImportFailure.unrecognized);
  }
  final builder = ImportPlanBuilder();

  // Containers first, so tasks can resolve their parent by id or by name.
  final containers = <String, _Container>{};
  for (final r in records) {
    final kind = _kind(r['type']);
    if (kind == _Kind.task) continue;
    final name = (r['name'] ?? '').trim();
    if (name.isEmpty) continue;
    final state = _state(r['state']);
    final closed = _closed(r) || state.closed;
    final container = _Container(
      name: name,
      isReferenceList: kind == _Kind.referenceList,
      closed: closed,
      status: switch (state) {
        _State.someday => ProjectStatus.someday,
        _State.later => ProjectStatus.onHold,
        _ => ProjectStatus.active,
      },
      outcome: r['note'],
    );
    final id = r['id'];
    if (id != null && id.isNotEmpty) containers[id] = container;
    containers.putIfAbsent(normalizeName(name), () => container);
  }

  for (final r in records) {
    if (_kind(r['type']) != _Kind.task) continue;
    final title = (r['name'] ?? '').trim();
    if (title.isEmpty) {
      builder.warn(ImportWarning.unreadableRows);
      continue;
    }
    final state = _state(r['state']);
    if (_closed(r) || state.closed) {
      builder.warn(ImportWarning.completedSkipped);
      continue;
    }
    final notes = <String?>[r['note']];
    final parentRef = (r['parentid'] ?? r['parent'] ?? r['project'] ?? '')
        .trim();
    final container = parentRef.isEmpty
        ? null
        : containers[parentRef] ?? containers[normalizeName(parentRef)];
    String? project;
    var status = state.itemStatus;
    if (container != null && !container.closed) {
      if (container.isReferenceList) {
        status = ItemStatus.reference;
        notes.add('List: ${container.name}');
        builder.warn(ImportWarning.sectionsInNotes);
      } else if (status != ItemStatus.inbox) {
        project = builder.project(
          container.name,
          outcome: container.outcome,
          status: container.status,
        );
      }
    } else if (container == null &&
        parentRef.isNotEmpty &&
        !_looksLikeId(parentRef) &&
        status != ItemStatus.inbox) {
      // CSV exports may name the parent project instead of its id.
      project = builder.project(parentRef);
    }

    DateTime? date(String key) {
      final raw = (r[key] ?? '').trim();
      if (raw.isEmpty || raw == '0') return null;
      final d = parseAbsoluteDate(raw);
      if (d == null) {
        notes.add('$key: $raw');
        builder.warn(ImportWarning.unparsedDate);
      }
      return d;
    }

    var deferUntil = date('startdate');
    final dueAt = date('duedate');
    ImportedRepeat? repeat;
    final recurring = (r['recurring'] ?? '').trim();
    if (recurring.isNotEmpty && recurring != '0') {
      final parsed = _recurring(recurring);
      if (parsed == null || (dueAt == null && parsed.next == null && deferUntil == null)) {
        notes.add('Repeats: $recurring');
        builder.warn(ImportWarning.repeatInNotes);
      } else {
        repeat = parsed.repeat;
        if (dueAt == null) deferUntil ??= parsed.next;
      }
    }

    final waitingFor = (r['waitingfor'] ?? '').trim();
    if (waitingFor.isNotEmpty && status == ItemStatus.nextAction) {
      status = ItemStatus.waiting;
    }
    builder.add(
      ImportedItem(
        title: title,
        status: status,
        notes: joinNotes(notes),
        project: project,
        tags: [
          for (final t in (r['tags'] ?? '').split(','))
            if (t.trim().isNotEmpty) t.trim(),
        ],
        dueAt: dueAt,
        deferUntil: deferUntil,
        waitingOn: waitingFor.isEmpty ? null : waitingFor,
        energy: _energy(r['energy']),
        timeEstimateMinutes: parseMinutes(r['etime'] ?? ''),
        repeat: repeat,
      ),
    );
  }
  return builder.build(ImportSourceApp.nirvana);
}

/// Records as normalized-key → string maps, or null when [text] is neither
/// a CSV table nor a JSON list of objects.
List<Map<String, String>>? _records(String text) {
  final trimmed = text.trimLeft().replaceFirst('﻿', '');
  if (trimmed.startsWith('[') || trimmed.startsWith('{')) {
    final Object? decoded;
    try {
      decoded = jsonDecode(trimmed);
    } on FormatException {
      return null;
    }
    final list = decoded is List
        ? decoded
        : decoded is Map
        ? decoded.values.whereType<List>().firstOrNull
        : null;
    if (list == null) return null;
    return [
      for (final e in list)
        if (e is Map)
          {
            for (final MapEntry(:key, :value) in e.entries)
              if (value != null)
                normalizeHeader('$key'): value is String ? value : '$value',
          },
    ];
  }
  final rows = parseCsv(text);
  if (rows.length < 2) return null;
  final header = rows.first.map(normalizeHeader).toList();
  return [
    for (final row in rows.skip(1))
      {
        for (var i = 0; i < header.length && i < row.length; i++)
          header[i]: row[i],
      },
  ];
}

enum _Kind { task, project, referenceList }

_Kind _kind(String? raw) {
  final v = (raw ?? '').trim().toLowerCase();
  if (v == '1' || v == 'project') return _Kind.project;
  if (v == '2' || v.contains('reference')) return _Kind.referenceList;
  return _Kind.task;
}

enum _State {
  inbox,
  next,
  waiting,
  scheduled,
  someday,
  later,
  trashed,
  logged,
  recurring,
  active;

  bool get closed => this == trashed || this == logged;

  ItemStatus get itemStatus => switch (this) {
    inbox => ItemStatus.inbox,
    waiting => ItemStatus.waiting,
    someday || later => ItemStatus.someday,
    _ => ItemStatus.nextAction,
  };
}

_State _state(String? raw) {
  final v = (raw ?? '').trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  return switch (v) {
    '0' || 'inbox' => _State.inbox,
    '2' || 'waiting' || 'waitingfor' => _State.waiting,
    '3' || 'scheduled' => _State.scheduled,
    '4' || 'someday' => _State.someday,
    '5' || 'later' => _State.later,
    '6' || 'trash' || 'trashed' || '8' || 'deleted' => _State.trashed,
    '7' || 'logged' || 'logbook' || 'completed' || 'done' => _State.logged,
    '9' || 'recurring' => _State.recurring,
    '11' || 'active' => _State.active,
    _ => _State.next,
  };
}

/// Completed / cancelled / deleted carry a timestamp or flag when set.
bool _closed(Map<String, String> r) => ['completed', 'cancelled', 'deleted']
    .any((k) {
      final v = (r[k] ?? '').trim().toLowerCase();
      return v.isNotEmpty && v != '0' && v != 'false' && v != 'no';
    });

Energy? _energy(String? raw) =>
    switch ((raw ?? '').trim().toLowerCase()) {
      '1' || 'low' => Energy.low,
      '2' || 'med' || 'medium' => Energy.medium,
      '3' || 'high' => Energy.high,
      _ => null,
    };

bool _looksLikeId(String s) =>
    RegExp(r'^[0-9a-fA-F-]{16,}$').hasMatch(s);

/// Nirvana's recurring JSON:
/// `{"freq":"weekly","interval":1,"nextdate":"20120807",…}`.
({ImportedRepeat repeat, DateTime? next})? _recurring(String raw) {
  final Object? decoded;
  try {
    decoded = jsonDecode(raw);
  } on FormatException {
    return null;
  }
  if (decoded is! Map) return null;
  final frequency = switch ('${decoded['freq']}'.toLowerCase()) {
    'daily' => Recurrence.daily,
    'weekly' => Recurrence.weekly,
    'monthly' => Recurrence.monthly,
    'yearly' => Recurrence.yearly,
    _ => null,
  };
  final interval = int.tryParse('${decoded['interval'] ?? 1}');
  if (frequency == null || interval == null || interval < 1) return null;
  // Weekday / nth-day qualifiers are not documented; refuse rather than
  // drop them silently.
  const known = {'freq', 'interval', 'nextdate', 'paused', 'hasduedate'};
  if (decoded.keys.any((k) => !known.contains('$k'))) return null;
  final next = decoded['nextdate'];
  return (
    repeat: ImportedRepeat(frequency: frequency, interval: interval),
    next: next == null ? null : parseAbsoluteDate('$next'),
  );
}

final class _Container {
  const _Container({
    required this.name,
    required this.isReferenceList,
    required this.closed,
    required this.status,
    this.outcome,
  });

  final String name;
  final bool isReferenceList;
  final bool closed;
  final ProjectStatus status;
  final String? outcome;
}
