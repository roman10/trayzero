import '../entities/entities.dart';
import 'import_plan.dart';
import 'import_values.dart';

/// TaskPaper text and plain lists (ADR 0008): OmniFocus "Copy as
/// TaskPaper", Things' copied to-dos, or any outline.
///
/// - `- task`, `* task`, `• task`, `- [ ] task` are tasks (`[x]` / `✓` are
///   done); `Name:` is a project; any other line is a note on the line
///   above. Nesting is by tabs or a consistent number of spaces.
/// - Top level: a `Name:` line or a task with children is a Project
///   (OmniFocus writes projects as tasks with children); a `Name:` line
///   whose children are all such projects is a folder; a lone task goes to
///   the Inbox.
/// - Inside a Project, nested `Name:` lines are headings and tasks with
///   children are action groups. Both become notes on the tasks beneath.
/// - Text with no task or project line at all is a plain list: each
///   unindented line is an Inbox task.
///
/// OmniFocus parameters per Omni's TaskPaper reference: `@due`, `@defer`
/// (`@start`), `@done`, `@dropped`, `@tags(a, b)`, `@context`,
/// `@estimate`, `@repeat-rule`, `@flagged`. Bare `@word` tags are kept as
/// written, so `@phone` reads as a context.
ImportPlan parseTaskPaper(
  String text, {
  required ImportSourceApp source,
  required DateTime now,
}) {
  final nodes = _outline(text);
  if (nodes.isEmpty) throw const ImportFormatException(ImportFailure.noTasks);
  final builder = ImportPlanBuilder();
  final mapper = _Mapper(builder, now);
  for (final node in nodes) {
    switch (node.kind) {
      case _LineKind.note:
        break;
      case _LineKind.task when node.tasksAndProjects.isEmpty:
        mapper.task(node, project: null, context: const []);
      case _LineKind.task || _LineKind.project:
        final children = node.tasksAndProjects;
        final isFolder = node.kind == _LineKind.project &&
            children.isNotEmpty &&
            children.every((c) => c.kind == _LineKind.task && c.hasTasks);
        if (isFolder) {
          for (final p in children) {
            mapper.project(p, folder: node.title);
          }
        } else {
          mapper.project(node);
        }
    }
  }
  return builder.build(source);
}

enum _LineKind { task, project, note }

final class _Node {
  _Node(this.kind, this.title, this.params, {this.done = false});
  final _LineKind kind;
  final String title;
  final List<(String, String?)> params;
  final bool done;
  final notes = <String>[];
  final children = <_Node>[];

  Iterable<_Node> get tasksAndProjects =>
      children.where((c) => c.kind != _LineKind.note);
  bool get hasTasks => tasksAndProjects.isNotEmpty;
}

final _taskPrefix = RegExp(
  r'^(?:[-*•+–]\s+(?:\[( |x|X)\]\s+)?|\[( |x|X)\]\s+|([☐☑✓✔])\s*)',
);
final _param = RegExp(
  r'(?<=^|\s)@([\p{L}\p{N}_-]+)(?:\(([^)]*)\))?',
  unicode: true,
);

/// Parses lines into a forest by indentation.
List<_Node> _outline(String text) {
  final lines = text
      .replaceFirst('﻿', '')
      .replaceAll('\r\n', '\n')
      .replaceAll('\r', '\n')
      .split('\n');
  final spaceUnit = lines
      .map((l) => RegExp(r'^ +').firstMatch(l)?.group(0)?.length ?? 0)
      .where((n) => n > 0)
      .fold<int?>(null, (m, n) => m == null || n < m ? n : m);
  final structured = lines.any((l) {
    final t = l.trim();
    return _taskPrefix.hasMatch(t) || _isProjectLine(t);
  });

  final roots = <_Node>[];
  // A `Name:` heading sits half a level up, so tasks written flush under
  // it (common in plain lists) still belong to it.
  final stack = <(double, _Node)>[];
  // Headings whose children were indented; such a block ends at the next
  // line written as shallow as the heading itself.
  final indentedHeadings = <_Node, int>{};
  for (final raw in lines) {
    if (raw.trim().isEmpty) continue;
    final lead = RegExp(r'^[\t ]*').firstMatch(raw)!.group(0)!;
    final depth = '\t'.allMatches(lead).length +
        (spaceUnit == null ? 0 : (lead.replaceAll('\t', '').length ~/ spaceUnit));
    final line = raw.trim();
    final closing = stack.indexWhere(
      (e) => (indentedHeadings[e.$2] ?? -1) >= depth,
    );
    final closedBlock = closing >= 0;
    if (closedBlock) stack.removeRange(closing, stack.length);
    var node = _classify(line, structured: structured || depth > 0);
    if (node.kind == _LineKind.note && closedBlock && stack.isEmpty) {
      // `Garden:` / indented tasks / `Call Mom`: the unmarked line after
      // the block is a task of its own, not a note on the heading.
      node = _classify(line, structured: false);
    }
    if (node.kind == _LineKind.note) {
      // A note belongs to the nearest item above it at the same or a
      // shallower depth (TaskPaper indents notes; plain lists may not).
      final owner = stack.lastWhere(
        (e) => e.$1 <= depth,
        orElse: () => stack.isEmpty ? (-1.0, _orphan) : stack.first,
      );
      if (!identical(owner.$2, _orphan)) owner.$2.notes.add(line);
      continue;
    }
    final level = node.kind == _LineKind.project ? depth - 0.5 : depth * 1.0;
    while (stack.isNotEmpty && stack.last.$1 >= level) {
      stack.removeLast();
    }
    if (stack.isEmpty) {
      roots.add(node);
    } else {
      final parent = stack.last;
      parent.$2.children.add(node);
      final parentDepth = (parent.$1 + 0.5).floor();
      if (parent.$2.kind == _LineKind.project && depth > parentDepth) {
        indentedHeadings[parent.$2] = parentDepth;
      }
    }
    stack.add((level, node));
  }
  return roots;
}

/// Sink for notes that precede every item; they are dropped.
final _orphan = _Node(_LineKind.note, '', const []);

bool _isProjectLine(String line) =>
    !_taskPrefix.hasMatch(line) &&
    line.replaceAll(_param, '').trimRight().endsWith(':') &&
    line.replaceAll(_param, '').trim().length > 1;

_Node _classify(String line, {required bool structured}) {
  final task = _taskPrefix.firstMatch(line);
  if (task != null || !structured) {
    final mark = task?.group(1) ?? task?.group(2) ?? task?.group(3);
    final done = mark != null && mark != ' ' && mark != '☐';
    final body = task == null ? line : line.substring(task.end);
    return _Node(_LineKind.task, _strip(body), _params(body), done: done);
  }
  if (_isProjectLine(line)) {
    final body = line.replaceAll(_param, '').trim();
    return _Node(
      _LineKind.project,
      body.substring(0, body.length - 1).trim(),
      _params(line),
    );
  }
  return _Node(_LineKind.note, line, const []);
}

List<(String, String?)> _params(String text) => [
  for (final m in _param.allMatches(text))
    (m.group(1)!.toLowerCase(), m.group(2)?.trim()),
];

String _strip(String text) =>
    text.replaceAll(_param, ' ').replaceAll(RegExp(r'\s+'), ' ').trim();

bool _closed(_Node n) =>
    n.done ||
    n.params.any((p) => const {'done', 'dropped', 'cancelled'}.contains(p.$1));

final class _Mapper {
  _Mapper(this.builder, this.now);
  final ImportPlanBuilder builder;
  final DateTime now;

  void project(_Node node, {String? folder}) {
    if (_closed(node)) {
      builder.warn(ImportWarning.completedSkipped, _openTaskCount(node));
      return;
    }
    final special = specialListStatus(node.title);
    String? project;
    if (special == null) {
      project = builder.project(
        node.title,
        outcome: joinNotes([...node.notes, if (folder != null) 'Folder: $folder']),
        status: _projectStatus(node),
      );
    }
    _children(node, project: project, status: special, context: const []);
  }

  void _children(
    _Node parent, {
    required String? project,
    required ItemStatus? status,
    required List<String> context,
  }) {
    for (final child in parent.tasksAndProjects) {
      if (child.kind == _LineKind.project || child.hasTasks) {
        if (_closed(child)) {
          builder.warn(
            ImportWarning.completedSkipped,
            _openTaskCount(child),
          );
          continue;
        }
        _children(
          child,
          project: project,
          status: status,
          context: [
            ...context,
            child.kind == _LineKind.project
                ? 'Section: ${child.title}'
                : 'Subtask of: ${child.title}',
          ],
        );
      } else {
        task(child, project: project, status: status, context: context);
      }
    }
  }

  void task(
    _Node node, {
    required String? project,
    required List<String> context,
    ItemStatus? status,
  }) {
    if (_closed(node)) {
      builder.warn(ImportWarning.completedSkipped);
      return;
    }
    if (node.title.isEmpty) {
      builder.warn(ImportWarning.unreadableRows);
      return;
    }
    if (context.any((c) => c.startsWith('Subtask of:'))) {
      builder.warn(ImportWarning.subtasksFlattened);
    } else if (context.isNotEmpty) {
      builder.warn(ImportWarning.sectionsInNotes);
    }
    final notes = <String?>[...node.notes, ...context];
    final tags = <String>[];
    DateTime? dueAt, deferUntil;
    String? rule;
    int? minutes;
    var unmapped = false;

    DateTime? date(String key, String? raw) {
      if (raw == null || raw.isEmpty) return null;
      final d = parseExportDate(raw, now: now);
      if (d == null) {
        notes.add('$key: $raw');
        builder.warn(ImportWarning.unparsedDate);
      }
      return d;
    }

    for (final (key, value) in node.params) {
      switch (key) {
        case 'due':
          dueAt = date('Due', value);
        case 'defer' || 'start':
          deferUntil = date('Defer', value);
        case 'tags':
          tags.addAll(
            (value ?? '').split(',').map((t) => t.trim()).where((t) => t.isNotEmpty),
          );
        case 'context':
          if (value != null && value.isNotEmpty) tags.add('@$value');
        case 'estimate':
          minutes = parseMinutes(value ?? '');
        case 'repeat-rule':
          rule = value;
        case 'flagged' || 'priority':
          unmapped = true;
        case 'parallel' ||
            'autodone' ||
            'repeat-method' ||
            'repeat-anchor-date' ||
            'repeat-schedule-type' ||
            'planned' ||
            'hold' ||
            'on-hold' ||
            'status':
          break;
        default:
          if (value == null) {
            tags.add('@$key');
          } else {
            notes.add('$key: $value');
          }
      }
    }
    ImportedRepeat? repeat;
    if (rule != null && rule.isNotEmpty) {
      final anchor = dueAt ?? deferUntil;
      repeat = anchor == null ? null : parseRRule(rule, anchor: anchor);
      if (repeat == null) {
        notes.add('Repeats: $rule');
        builder.warn(ImportWarning.repeatInNotes);
      }
    }
    if (unmapped) builder.warn(ImportWarning.notImported);
    builder.add(
      ImportedItem(
        title: node.title,
        status: status ?? (project == null ? ItemStatus.inbox : ItemStatus.nextAction),
        notes: joinNotes(notes),
        project: project,
        tags: _dedupe(tags),
        dueAt: dueAt,
        deferUntil: deferUntil,
        timeEstimateMinutes: minutes,
        repeat: repeat,
      ),
    );
  }
}

/// On-hold is not a documented TaskPaper parameter; recognize the common
/// spellings and otherwise import as active (ADR 0008).
ProjectStatus _projectStatus(_Node node) {
  for (final (key, value) in node.params) {
    final v = (value ?? '').toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
    if (key == 'hold' || key == 'on-hold') return ProjectStatus.onHold;
    if (key == 'status' && (v == 'onhold' || v == 'paused' || v == 'hold')) {
      return ProjectStatus.onHold;
    }
  }
  return ProjectStatus.active;
}

int _openTaskCount(_Node node) => node.tasksAndProjects.fold(
  0,
  (n, c) => n + (c.hasTasks ? _openTaskCount(c) : (_closed(c) ? 0 : 1)),
);

/// One tag per name; a source-marked `@context` wins over a plain tag of
/// the same name (OmniFocus writes both `@context(x)` and `@tags(x)`).
List<String> _dedupe(List<String> tags) {
  final seen = <String>{};
  return [
    for (final t in [
      ...tags.where((t) => t.startsWith('@')),
      ...tags.where((t) => !t.startsWith('@')),
    ])
      if (seen.add(normalizeContextName(t))) t,
  ];
}
