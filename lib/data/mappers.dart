import 'package:drift/drift.dart' show Value;

import '../core/search_text.dart';
import '../domain/entities/entities.dart';
import 'db/database.dart';

extension ItemRowMapper on ItemRow {
  Item toEntity() => Item(
        id: id,
        title: title,
        notes: notes,
        status: status,
        projectId: projectId,
        contextId: contextId,
        dueAt: dueAt,
        deferUntil: deferUntil,
        waitingOn: waitingOn,
        energy: energy,
        timeEstimateMinutes: timeEstimateMinutes,
        isTwoMin: isTwoMin,
        createdAt: createdAt,
        updatedAt: updatedAt,
        completedAt: completedAt,
        previousStatus: previousStatus,
        sortOrder: sortOrder,
        projectSortOrder: projectSortOrder,
        recurrence: recurrence,
        recurrenceInterval: recurrenceInterval,
        recurrenceUntil: recurrenceUntil,
        recurrenceCount: recurrenceCount,
        recurrenceDoneCount: recurrenceDoneCount,
        recurrenceByWeekdays: _weekdaysFromCsv(recurrenceByWeekdays),
        recurrenceMonthlyWeek: recurrenceMonthlyWeek,
        recurrenceMonthlyWeekday: recurrenceMonthlyWeekday,
        calendarEventId: calendarEventId,
        focusedAt: focusedAt,
      );
}

/// Weekly by-weekday is stored as a CSV of ints ("1,3,5"); null/empty CSV
/// maps to an empty list (anchor's own weekday).
List<int> _weekdaysFromCsv(String? csv) {
  if (csv == null || csv.isEmpty) return const [];
  return csv.split(',').map(int.parse).toList();
}

String? _weekdaysToCsv(List<int> days) =>
    days.isEmpty ? null : days.join(',');

extension ItemMapper on Item {
  ItemsCompanion toCompanion() => ItemsCompanion(
        id: Value(id),
        title: Value(title),
        notes: Value(notes),
        status: Value(status),
        projectId: Value(projectId),
        contextId: Value(contextId),
        dueAt: Value(dueAt),
        deferUntil: Value(deferUntil),
        waitingOn: Value(waitingOn),
        energy: Value(energy),
        timeEstimateMinutes: Value(timeEstimateMinutes),
        isTwoMin: Value(isTwoMin),
        createdAt: Value(createdAt),
        updatedAt: Value(updatedAt),
        completedAt: Value(completedAt),
        previousStatus: Value(previousStatus),
        sortOrder: Value(sortOrder),
        projectSortOrder: Value(projectSortOrder),
        recurrence: Value(recurrence),
        recurrenceInterval: Value(recurrenceInterval),
        recurrenceUntil: Value(recurrenceUntil),
        recurrenceCount: Value(recurrenceCount),
        recurrenceDoneCount: Value(recurrenceDoneCount),
        recurrenceByWeekdays: Value(_weekdaysToCsv(recurrenceByWeekdays)),
        recurrenceMonthlyWeek: Value(recurrenceMonthlyWeek),
        recurrenceMonthlyWeekday: Value(recurrenceMonthlyWeekday),
        calendarEventId: Value(calendarEventId),
        focusedAt: Value(focusedAt),
        // Derived, persistence-only: recomputed on every upsert so it can
        // never drift from title/notes. See core/search_text.dart.
        searchText: Value(searchTextFor(title, notes)),
      );
}

extension ProjectRowMapper on ProjectRow {
  Project toEntity() => Project(
        id: id,
        title: title,
        outcome: outcome,
        areaId: areaId,
        status: status,
        dueAt: dueAt,
        createdAt: createdAt,
        updatedAt: updatedAt,
        lastReviewedAt: lastReviewedAt,
      );
}

extension ProjectMapper on Project {
  ProjectsCompanion toCompanion() => ProjectsCompanion(
        id: Value(id),
        title: Value(title),
        outcome: Value(outcome),
        areaId: Value(areaId),
        status: Value(status),
        dueAt: Value(dueAt),
        createdAt: Value(createdAt),
        updatedAt: Value(updatedAt),
        lastReviewedAt: Value(lastReviewedAt),
      );
}

extension ContextRowMapper on ContextRow {
  GtdContext toEntity() => GtdContext(
        id: id,
        name: name,
        icon: icon,
        color: color,
        sortOrder: sortOrder,
      );
}

extension ContextMapper on GtdContext {
  ContextsCompanion toCompanion() => ContextsCompanion(
        id: Value(id),
        name: Value(name),
        icon: Value(icon),
        color: Value(color),
        sortOrder: Value(sortOrder),
      );
}

extension AreaRowMapper on AreaRow {
  Area toEntity() => Area(id: id, name: name);
}

extension AttachmentRowMapper on AttachmentRow {
  Attachment toEntity() => Attachment(
        id: id,
        itemId: itemId,
        kind: AttachmentKind.values.firstWhere(
          (k) => k.name == kind,
          orElse: () => AttachmentKind.file,
        ),
        path: path,
        name: name,
        sizeBytes: sizeBytes,
        createdAt: createdAt,
      );
}

extension AttachmentMapper on Attachment {
  AttachmentsCompanion toCompanion() => AttachmentsCompanion(
        id: Value(id),
        itemId: Value(itemId),
        kind: Value(kind.name),
        path: Value(path),
        name: Value(name),
        sizeBytes: Value(sizeBytes),
        createdAt: Value(createdAt),
      );
}

extension AreaMapper on Area {
  AreasCompanion toCompanion() =>
      AreasCompanion(id: Value(id), name: Value(name));
}

extension ReviewRowMapper on ReviewRow {
  ReviewLog toEntity() => ReviewLog(
        id: id,
        type: type,
        startedAt: startedAt,
        completedAt: completedAt,
        notes: notes,
        currentStep: WeeklyReviewStep.values.firstWhere(
          (step) => step.name == currentStep,
          orElse: () => WeeklyReviewStep.capture,
        ),
      );
}

extension TagRowMapper on TagRow {
  Tag toEntity() => Tag(id: id, name: name, isPerson: isPerson);
}
