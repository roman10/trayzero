import 'package:drift/drift.dart';

import '../../domain/entities/entities.dart';

class ItemStatusConverter extends TypeConverter<ItemStatus, String> {
  const ItemStatusConverter();
  @override
  ItemStatus fromSql(String fromDb) =>
      ItemStatus.values.firstWhere((e) => e.name == fromDb,
          orElse: () => ItemStatus.inbox);
  @override
  String toSql(ItemStatus value) => value.name;
}

class EnergyConverter extends TypeConverter<Energy, String> {
  const EnergyConverter();
  @override
  Energy fromSql(String fromDb) =>
      Energy.values.firstWhere((e) => e.name == fromDb,
          orElse: () => Energy.medium);
  @override
  String toSql(Energy value) => value.name;
}

class ProjectStatusConverter extends TypeConverter<ProjectStatus, String> {
  const ProjectStatusConverter();
  @override
  ProjectStatus fromSql(String fromDb) =>
      ProjectStatus.values.firstWhere((e) => e.name == fromDb,
          orElse: () => ProjectStatus.active);
  @override
  String toSql(ProjectStatus value) => value.name;
}

class ReviewTypeConverter extends TypeConverter<ReviewType, String> {
  const ReviewTypeConverter();
  @override
  ReviewType fromSql(String fromDb) =>
      ReviewType.values.firstWhere((e) => e.name == fromDb,
          orElse: () => ReviewType.weekly);
  @override
  String toSql(ReviewType value) => value.name;
}

class RecurrenceConverter extends TypeConverter<Recurrence, String> {
  const RecurrenceConverter();
  @override
  Recurrence fromSql(String fromDb) =>
      Recurrence.values.firstWhere((e) => e.name == fromDb,
          orElse: () => Recurrence.daily);
  @override
  String toSql(Recurrence value) => value.name;
}

@DataClassName('ItemRow')
class Items extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get notes => text().nullable()();
  TextColumn get status =>
      text().map(const ItemStatusConverter())
          .withDefault(const Constant('inbox'))();
  TextColumn get projectId => text().nullable()();
  TextColumn get contextId => text().nullable()();
  DateTimeColumn get dueAt => dateTime().nullable()();
  DateTimeColumn get deferUntil => dateTime().nullable()();
  TextColumn get waitingOn => text().nullable()();
  TextColumn get energy =>
      text().map(const EnergyConverter()).nullable()();
  IntColumn get timeEstimateMinutes => integer().nullable()();
  BoolColumn get isTwoMin =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  TextColumn get previousStatus =>
      text().map(const ItemStatusConverter()).nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  /// Manual order within the owning project (isolated from [sortOrder], the
  /// Do/Engage key). Non-nullable with a `0` default so the v8→v9
  /// `addColumn` backfills every existing row to `0` — equivalent to the
  /// pre-feature `createdAt`-only project ordering until the first reorder.
  IntColumn get projectSortOrder => integer().withDefault(const Constant(0))();
  TextColumn get recurrence =>
      text().map(const RecurrenceConverter()).nullable()();
  IntColumn get recurrenceInterval =>
      integer().withDefault(const Constant(1))();

  /// Recurrence end condition. [recurrenceUntil] stops the series after this
  /// date; [recurrenceCount] caps total occurrences; [recurrenceDoneCount]
  /// tracks how many have completed so the cap can be enforced. Both caps
  /// null = repeats indefinitely.
  DateTimeColumn get recurrenceUntil => dateTime().nullable()();
  IntColumn get recurrenceCount => integer().nullable()();
  IntColumn get recurrenceDoneCount =>
      integer().withDefault(const Constant(0))();

  /// Structured pattern qualifiers. [recurrenceByWeekdays] is a CSV of
  /// weekday ints (1=Mon..7=Sun) for weekly rules; null/empty = anchor's
  /// own weekday. [recurrenceMonthlyWeek] (1..5 or -1=last) +
  /// [recurrenceMonthlyWeekday] express "Nth weekday of month"; both null =
  /// day-of-month. See domain RecurrenceRule.
  TextColumn get recurrenceByWeekdays => text().nullable()();
  IntColumn get recurrenceMonthlyWeek => integer().nullable()();
  IntColumn get recurrenceMonthlyWeekday => integer().nullable()();

  /// Platform event id of the calendar event this item is mirrored to, if
  /// any. Owned by the calendar-sync feature; lets mirror-out update the
  /// same event in place instead of duplicating it on every run.
  TextColumn get calendarEventId => text().nullable()();

  /// Derived, normalised "title\nnotes" for accent/case-insensitive search
  /// (see core/search_text.dart). Never read back into the `Item` entity —
  /// a persistence concern only. Kept in sync exclusively via
  /// `ItemMapper.toCompanion()`, which recomputes it on every upsert; the
  /// partial updates (markCompleted/reopen/setCalendarEventId) don't touch
  /// title/notes, so they correctly leave this untouched.
  TextColumn get searchText => text().withDefault(const Constant(''))();

  /// When the Item was committed to Today (ADR 0007). In Today while this
  /// falls on the current local day; an earlier day means carried over.
  DateTimeColumn get focusedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('ProjectRow')
class Projects extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get outcome => text().nullable()();
  TextColumn get areaId => text().nullable()();
  TextColumn get status =>
      text().map(const ProjectStatusConverter())
          .withDefault(const Constant('active'))();
  DateTimeColumn get dueAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  /// Last time the Project was marked reviewed in the Weekly Review.
  DateTimeColumn get lastReviewedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('ContextRow')
class Contexts extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get icon => text().withDefault(const Constant('label'))();
  IntColumn get color =>
      integer().withDefault(const Constant(0xFF6750A4))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('AreaRow')
class Areas extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('AttachmentRow')
class Attachments extends Table {
  TextColumn get id => text()();
  TextColumn get itemId => text()();
  TextColumn get kind => text()(); // image | audio | file
  TextColumn get path => text()(); // relative to app docs dir
  TextColumn get name => text().nullable()(); // optional display name
  IntColumn get sizeBytes => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('ReviewRow')
class Reviews extends Table {
  TextColumn get id => text()();
  TextColumn get type =>
      text().map(const ReviewTypeConverter())();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get currentStep => text().withDefault(const Constant('capture'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Native calendar ownership, retained independently of the Item row.
@DataClassName('CalendarMirrorRow')
class CalendarMirrors extends Table {
  TextColumn get calendarId => text()();
  TextColumn get eventId => text()();
  TextColumn get itemId => text()();
  BoolColumn get isCurrent => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {calendarId, eventId};
}

/// Free-form labels (ADR 0010). Names are unique ignoring case; enforced by
/// the repository with Unicode lowercase (SQLite NOCASE is ASCII-only).
@DataClassName('TagRow')
class Tags extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();

  /// A person: the tag also keeps an Agenda.
  BoolColumn get isPerson => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Item ↔ Tag links. Both sides cascade, so deleting an Item or a Tag never
/// leaves a dangling link.
@DataClassName('ItemTagRow')
@TableIndex(name: 'item_tags_tag_id', columns: {#tagId})
class ItemTags extends Table {
  TextColumn get itemId =>
      text().references(Items, #id, onDelete: KeyAction.cascade)();
  TextColumn get tagId =>
      text().references(Tags, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column<Object>> get primaryKey => {itemId, tagId};
}

/// Device-local history of successful imports; omitted from portable backups.
@DataClassName('ImportBatchRow')
@TableIndex(name: 'import_batches_fingerprint', columns: {#fingerprint})
class ImportBatches extends Table {
  TextColumn get id => text()();
  TextColumn get fingerprint => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
