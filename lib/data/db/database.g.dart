// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ItemsTable extends Items with TableInfo<$ItemsTable, ItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ItemStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('inbox'),
      ).withConverter<ItemStatus>($ItemsTable.$converterstatus);
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contextIdMeta = const VerificationMeta(
    'contextId',
  );
  @override
  late final GeneratedColumn<String> contextId = GeneratedColumn<String>(
    'context_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dueAtMeta = const VerificationMeta('dueAt');
  @override
  late final GeneratedColumn<DateTime> dueAt = GeneratedColumn<DateTime>(
    'due_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deferUntilMeta = const VerificationMeta(
    'deferUntil',
  );
  @override
  late final GeneratedColumn<DateTime> deferUntil = GeneratedColumn<DateTime>(
    'defer_until',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _waitingOnMeta = const VerificationMeta(
    'waitingOn',
  );
  @override
  late final GeneratedColumn<String> waitingOn = GeneratedColumn<String>(
    'waiting_on',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Energy?, String> energy =
      GeneratedColumn<String>(
        'energy',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Energy?>($ItemsTable.$converterenergyn);
  static const VerificationMeta _timeEstimateMinutesMeta =
      const VerificationMeta('timeEstimateMinutes');
  @override
  late final GeneratedColumn<int> timeEstimateMinutes = GeneratedColumn<int>(
    'time_estimate_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isTwoMinMeta = const VerificationMeta(
    'isTwoMin',
  );
  @override
  late final GeneratedColumn<bool> isTwoMin = GeneratedColumn<bool>(
    'is_two_min',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_two_min" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ItemStatus?, String>
  previousStatus = GeneratedColumn<String>(
    'previous_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<ItemStatus?>($ItemsTable.$converterpreviousStatusn);
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _projectSortOrderMeta = const VerificationMeta(
    'projectSortOrder',
  );
  @override
  late final GeneratedColumn<int> projectSortOrder = GeneratedColumn<int>(
    'project_sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  late final GeneratedColumnWithTypeConverter<Recurrence?, String> recurrence =
      GeneratedColumn<String>(
        'recurrence',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Recurrence?>($ItemsTable.$converterrecurrencen);
  static const VerificationMeta _recurrenceIntervalMeta =
      const VerificationMeta('recurrenceInterval');
  @override
  late final GeneratedColumn<int> recurrenceInterval = GeneratedColumn<int>(
    'recurrence_interval',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _recurrenceUntilMeta = const VerificationMeta(
    'recurrenceUntil',
  );
  @override
  late final GeneratedColumn<DateTime> recurrenceUntil =
      GeneratedColumn<DateTime>(
        'recurrence_until',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _recurrenceCountMeta = const VerificationMeta(
    'recurrenceCount',
  );
  @override
  late final GeneratedColumn<int> recurrenceCount = GeneratedColumn<int>(
    'recurrence_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recurrenceDoneCountMeta =
      const VerificationMeta('recurrenceDoneCount');
  @override
  late final GeneratedColumn<int> recurrenceDoneCount = GeneratedColumn<int>(
    'recurrence_done_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _recurrenceByWeekdaysMeta =
      const VerificationMeta('recurrenceByWeekdays');
  @override
  late final GeneratedColumn<String> recurrenceByWeekdays =
      GeneratedColumn<String>(
        'recurrence_by_weekdays',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _recurrenceMonthlyWeekMeta =
      const VerificationMeta('recurrenceMonthlyWeek');
  @override
  late final GeneratedColumn<int> recurrenceMonthlyWeek = GeneratedColumn<int>(
    'recurrence_monthly_week',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recurrenceMonthlyWeekdayMeta =
      const VerificationMeta('recurrenceMonthlyWeekday');
  @override
  late final GeneratedColumn<int> recurrenceMonthlyWeekday =
      GeneratedColumn<int>(
        'recurrence_monthly_weekday',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _calendarEventIdMeta = const VerificationMeta(
    'calendarEventId',
  );
  @override
  late final GeneratedColumn<String> calendarEventId = GeneratedColumn<String>(
    'calendar_event_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _searchTextMeta = const VerificationMeta(
    'searchText',
  );
  @override
  late final GeneratedColumn<String> searchText = GeneratedColumn<String>(
    'search_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    notes,
    status,
    projectId,
    contextId,
    dueAt,
    deferUntil,
    waitingOn,
    energy,
    timeEstimateMinutes,
    isTwoMin,
    createdAt,
    updatedAt,
    completedAt,
    previousStatus,
    sortOrder,
    projectSortOrder,
    recurrence,
    recurrenceInterval,
    recurrenceUntil,
    recurrenceCount,
    recurrenceDoneCount,
    recurrenceByWeekdays,
    recurrenceMonthlyWeek,
    recurrenceMonthlyWeekday,
    calendarEventId,
    searchText,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'items';
  @override
  VerificationContext validateIntegrity(
    Insertable<ItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    }
    if (data.containsKey('context_id')) {
      context.handle(
        _contextIdMeta,
        contextId.isAcceptableOrUnknown(data['context_id']!, _contextIdMeta),
      );
    }
    if (data.containsKey('due_at')) {
      context.handle(
        _dueAtMeta,
        dueAt.isAcceptableOrUnknown(data['due_at']!, _dueAtMeta),
      );
    }
    if (data.containsKey('defer_until')) {
      context.handle(
        _deferUntilMeta,
        deferUntil.isAcceptableOrUnknown(data['defer_until']!, _deferUntilMeta),
      );
    }
    if (data.containsKey('waiting_on')) {
      context.handle(
        _waitingOnMeta,
        waitingOn.isAcceptableOrUnknown(data['waiting_on']!, _waitingOnMeta),
      );
    }
    if (data.containsKey('time_estimate_minutes')) {
      context.handle(
        _timeEstimateMinutesMeta,
        timeEstimateMinutes.isAcceptableOrUnknown(
          data['time_estimate_minutes']!,
          _timeEstimateMinutesMeta,
        ),
      );
    }
    if (data.containsKey('is_two_min')) {
      context.handle(
        _isTwoMinMeta,
        isTwoMin.isAcceptableOrUnknown(data['is_two_min']!, _isTwoMinMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('project_sort_order')) {
      context.handle(
        _projectSortOrderMeta,
        projectSortOrder.isAcceptableOrUnknown(
          data['project_sort_order']!,
          _projectSortOrderMeta,
        ),
      );
    }
    if (data.containsKey('recurrence_interval')) {
      context.handle(
        _recurrenceIntervalMeta,
        recurrenceInterval.isAcceptableOrUnknown(
          data['recurrence_interval']!,
          _recurrenceIntervalMeta,
        ),
      );
    }
    if (data.containsKey('recurrence_until')) {
      context.handle(
        _recurrenceUntilMeta,
        recurrenceUntil.isAcceptableOrUnknown(
          data['recurrence_until']!,
          _recurrenceUntilMeta,
        ),
      );
    }
    if (data.containsKey('recurrence_count')) {
      context.handle(
        _recurrenceCountMeta,
        recurrenceCount.isAcceptableOrUnknown(
          data['recurrence_count']!,
          _recurrenceCountMeta,
        ),
      );
    }
    if (data.containsKey('recurrence_done_count')) {
      context.handle(
        _recurrenceDoneCountMeta,
        recurrenceDoneCount.isAcceptableOrUnknown(
          data['recurrence_done_count']!,
          _recurrenceDoneCountMeta,
        ),
      );
    }
    if (data.containsKey('recurrence_by_weekdays')) {
      context.handle(
        _recurrenceByWeekdaysMeta,
        recurrenceByWeekdays.isAcceptableOrUnknown(
          data['recurrence_by_weekdays']!,
          _recurrenceByWeekdaysMeta,
        ),
      );
    }
    if (data.containsKey('recurrence_monthly_week')) {
      context.handle(
        _recurrenceMonthlyWeekMeta,
        recurrenceMonthlyWeek.isAcceptableOrUnknown(
          data['recurrence_monthly_week']!,
          _recurrenceMonthlyWeekMeta,
        ),
      );
    }
    if (data.containsKey('recurrence_monthly_weekday')) {
      context.handle(
        _recurrenceMonthlyWeekdayMeta,
        recurrenceMonthlyWeekday.isAcceptableOrUnknown(
          data['recurrence_monthly_weekday']!,
          _recurrenceMonthlyWeekdayMeta,
        ),
      );
    }
    if (data.containsKey('calendar_event_id')) {
      context.handle(
        _calendarEventIdMeta,
        calendarEventId.isAcceptableOrUnknown(
          data['calendar_event_id']!,
          _calendarEventIdMeta,
        ),
      );
    }
    if (data.containsKey('search_text')) {
      context.handle(
        _searchTextMeta,
        searchText.isAcceptableOrUnknown(data['search_text']!, _searchTextMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ItemRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      status: $ItemsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      ),
      contextId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}context_id'],
      ),
      dueAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_at'],
      ),
      deferUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}defer_until'],
      ),
      waitingOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}waiting_on'],
      ),
      energy: $ItemsTable.$converterenergyn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}energy'],
        ),
      ),
      timeEstimateMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_estimate_minutes'],
      ),
      isTwoMin: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_two_min'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      previousStatus: $ItemsTable.$converterpreviousStatusn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}previous_status'],
        ),
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      projectSortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}project_sort_order'],
      )!,
      recurrence: $ItemsTable.$converterrecurrencen.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}recurrence'],
        ),
      ),
      recurrenceInterval: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recurrence_interval'],
      )!,
      recurrenceUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}recurrence_until'],
      ),
      recurrenceCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recurrence_count'],
      ),
      recurrenceDoneCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recurrence_done_count'],
      )!,
      recurrenceByWeekdays: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurrence_by_weekdays'],
      ),
      recurrenceMonthlyWeek: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recurrence_monthly_week'],
      ),
      recurrenceMonthlyWeekday: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recurrence_monthly_weekday'],
      ),
      calendarEventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}calendar_event_id'],
      ),
      searchText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}search_text'],
      )!,
    );
  }

  @override
  $ItemsTable createAlias(String alias) {
    return $ItemsTable(attachedDatabase, alias);
  }

  static TypeConverter<ItemStatus, String> $converterstatus =
      const ItemStatusConverter();
  static TypeConverter<Energy, String> $converterenergy =
      const EnergyConverter();
  static TypeConverter<Energy?, String?> $converterenergyn =
      NullAwareTypeConverter.wrap($converterenergy);
  static TypeConverter<ItemStatus, String> $converterpreviousStatus =
      const ItemStatusConverter();
  static TypeConverter<ItemStatus?, String?> $converterpreviousStatusn =
      NullAwareTypeConverter.wrap($converterpreviousStatus);
  static TypeConverter<Recurrence, String> $converterrecurrence =
      const RecurrenceConverter();
  static TypeConverter<Recurrence?, String?> $converterrecurrencen =
      NullAwareTypeConverter.wrap($converterrecurrence);
}

class ItemRow extends DataClass implements Insertable<ItemRow> {
  final String id;
  final String title;
  final String? notes;
  final ItemStatus status;
  final String? projectId;
  final String? contextId;
  final DateTime? dueAt;
  final DateTime? deferUntil;
  final String? waitingOn;
  final Energy? energy;
  final int? timeEstimateMinutes;
  final bool isTwoMin;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;
  final ItemStatus? previousStatus;
  final int sortOrder;

  /// Manual order within the owning project (isolated from [sortOrder], the
  /// Do/Engage key). Non-nullable with a `0` default so the v8→v9
  /// `addColumn` backfills every existing row to `0` — equivalent to the
  /// pre-feature `createdAt`-only project ordering until the first reorder.
  final int projectSortOrder;
  final Recurrence? recurrence;
  final int recurrenceInterval;

  /// Recurrence end condition. [recurrenceUntil] stops the series after this
  /// date; [recurrenceCount] caps total occurrences; [recurrenceDoneCount]
  /// tracks how many have completed so the cap can be enforced. Both caps
  /// null = repeats indefinitely.
  final DateTime? recurrenceUntil;
  final int? recurrenceCount;
  final int recurrenceDoneCount;

  /// Structured pattern qualifiers. [recurrenceByWeekdays] is a CSV of
  /// weekday ints (1=Mon..7=Sun) for weekly rules; null/empty = anchor's
  /// own weekday. [recurrenceMonthlyWeek] (1..5 or -1=last) +
  /// [recurrenceMonthlyWeekday] express "Nth weekday of month"; both null =
  /// day-of-month. See domain RecurrenceRule.
  final String? recurrenceByWeekdays;
  final int? recurrenceMonthlyWeek;
  final int? recurrenceMonthlyWeekday;

  /// Platform event id of the calendar event this item is mirrored to, if
  /// any. Owned by the calendar-sync feature; lets mirror-out update the
  /// same event in place instead of duplicating it on every run.
  final String? calendarEventId;

  /// Derived, normalised "title\nnotes" for accent/case-insensitive search
  /// (see core/search_text.dart). Never read back into the `Item` entity —
  /// a persistence concern only. Kept in sync exclusively via
  /// `ItemMapper.toCompanion()`, which recomputes it on every upsert; the
  /// partial updates (markCompleted/reopen/setCalendarEventId) don't touch
  /// title/notes, so they correctly leave this untouched.
  final String searchText;
  const ItemRow({
    required this.id,
    required this.title,
    this.notes,
    required this.status,
    this.projectId,
    this.contextId,
    this.dueAt,
    this.deferUntil,
    this.waitingOn,
    this.energy,
    this.timeEstimateMinutes,
    required this.isTwoMin,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
    this.previousStatus,
    required this.sortOrder,
    required this.projectSortOrder,
    this.recurrence,
    required this.recurrenceInterval,
    this.recurrenceUntil,
    this.recurrenceCount,
    required this.recurrenceDoneCount,
    this.recurrenceByWeekdays,
    this.recurrenceMonthlyWeek,
    this.recurrenceMonthlyWeekday,
    this.calendarEventId,
    required this.searchText,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    {
      map['status'] = Variable<String>(
        $ItemsTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || projectId != null) {
      map['project_id'] = Variable<String>(projectId);
    }
    if (!nullToAbsent || contextId != null) {
      map['context_id'] = Variable<String>(contextId);
    }
    if (!nullToAbsent || dueAt != null) {
      map['due_at'] = Variable<DateTime>(dueAt);
    }
    if (!nullToAbsent || deferUntil != null) {
      map['defer_until'] = Variable<DateTime>(deferUntil);
    }
    if (!nullToAbsent || waitingOn != null) {
      map['waiting_on'] = Variable<String>(waitingOn);
    }
    if (!nullToAbsent || energy != null) {
      map['energy'] = Variable<String>(
        $ItemsTable.$converterenergyn.toSql(energy),
      );
    }
    if (!nullToAbsent || timeEstimateMinutes != null) {
      map['time_estimate_minutes'] = Variable<int>(timeEstimateMinutes);
    }
    map['is_two_min'] = Variable<bool>(isTwoMin);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || previousStatus != null) {
      map['previous_status'] = Variable<String>(
        $ItemsTable.$converterpreviousStatusn.toSql(previousStatus),
      );
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['project_sort_order'] = Variable<int>(projectSortOrder);
    if (!nullToAbsent || recurrence != null) {
      map['recurrence'] = Variable<String>(
        $ItemsTable.$converterrecurrencen.toSql(recurrence),
      );
    }
    map['recurrence_interval'] = Variable<int>(recurrenceInterval);
    if (!nullToAbsent || recurrenceUntil != null) {
      map['recurrence_until'] = Variable<DateTime>(recurrenceUntil);
    }
    if (!nullToAbsent || recurrenceCount != null) {
      map['recurrence_count'] = Variable<int>(recurrenceCount);
    }
    map['recurrence_done_count'] = Variable<int>(recurrenceDoneCount);
    if (!nullToAbsent || recurrenceByWeekdays != null) {
      map['recurrence_by_weekdays'] = Variable<String>(recurrenceByWeekdays);
    }
    if (!nullToAbsent || recurrenceMonthlyWeek != null) {
      map['recurrence_monthly_week'] = Variable<int>(recurrenceMonthlyWeek);
    }
    if (!nullToAbsent || recurrenceMonthlyWeekday != null) {
      map['recurrence_monthly_weekday'] = Variable<int>(
        recurrenceMonthlyWeekday,
      );
    }
    if (!nullToAbsent || calendarEventId != null) {
      map['calendar_event_id'] = Variable<String>(calendarEventId);
    }
    map['search_text'] = Variable<String>(searchText);
    return map;
  }

  ItemsCompanion toCompanion(bool nullToAbsent) {
    return ItemsCompanion(
      id: Value(id),
      title: Value(title),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      status: Value(status),
      projectId: projectId == null && nullToAbsent
          ? const Value.absent()
          : Value(projectId),
      contextId: contextId == null && nullToAbsent
          ? const Value.absent()
          : Value(contextId),
      dueAt: dueAt == null && nullToAbsent
          ? const Value.absent()
          : Value(dueAt),
      deferUntil: deferUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(deferUntil),
      waitingOn: waitingOn == null && nullToAbsent
          ? const Value.absent()
          : Value(waitingOn),
      energy: energy == null && nullToAbsent
          ? const Value.absent()
          : Value(energy),
      timeEstimateMinutes: timeEstimateMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(timeEstimateMinutes),
      isTwoMin: Value(isTwoMin),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      previousStatus: previousStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(previousStatus),
      sortOrder: Value(sortOrder),
      projectSortOrder: Value(projectSortOrder),
      recurrence: recurrence == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrence),
      recurrenceInterval: Value(recurrenceInterval),
      recurrenceUntil: recurrenceUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceUntil),
      recurrenceCount: recurrenceCount == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceCount),
      recurrenceDoneCount: Value(recurrenceDoneCount),
      recurrenceByWeekdays: recurrenceByWeekdays == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceByWeekdays),
      recurrenceMonthlyWeek: recurrenceMonthlyWeek == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceMonthlyWeek),
      recurrenceMonthlyWeekday: recurrenceMonthlyWeekday == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceMonthlyWeekday),
      calendarEventId: calendarEventId == null && nullToAbsent
          ? const Value.absent()
          : Value(calendarEventId),
      searchText: Value(searchText),
    );
  }

  factory ItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ItemRow(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      notes: serializer.fromJson<String?>(json['notes']),
      status: serializer.fromJson<ItemStatus>(json['status']),
      projectId: serializer.fromJson<String?>(json['projectId']),
      contextId: serializer.fromJson<String?>(json['contextId']),
      dueAt: serializer.fromJson<DateTime?>(json['dueAt']),
      deferUntil: serializer.fromJson<DateTime?>(json['deferUntil']),
      waitingOn: serializer.fromJson<String?>(json['waitingOn']),
      energy: serializer.fromJson<Energy?>(json['energy']),
      timeEstimateMinutes: serializer.fromJson<int?>(
        json['timeEstimateMinutes'],
      ),
      isTwoMin: serializer.fromJson<bool>(json['isTwoMin']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      previousStatus: serializer.fromJson<ItemStatus?>(json['previousStatus']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      projectSortOrder: serializer.fromJson<int>(json['projectSortOrder']),
      recurrence: serializer.fromJson<Recurrence?>(json['recurrence']),
      recurrenceInterval: serializer.fromJson<int>(json['recurrenceInterval']),
      recurrenceUntil: serializer.fromJson<DateTime?>(json['recurrenceUntil']),
      recurrenceCount: serializer.fromJson<int?>(json['recurrenceCount']),
      recurrenceDoneCount: serializer.fromJson<int>(
        json['recurrenceDoneCount'],
      ),
      recurrenceByWeekdays: serializer.fromJson<String?>(
        json['recurrenceByWeekdays'],
      ),
      recurrenceMonthlyWeek: serializer.fromJson<int?>(
        json['recurrenceMonthlyWeek'],
      ),
      recurrenceMonthlyWeekday: serializer.fromJson<int?>(
        json['recurrenceMonthlyWeekday'],
      ),
      calendarEventId: serializer.fromJson<String?>(json['calendarEventId']),
      searchText: serializer.fromJson<String>(json['searchText']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'notes': serializer.toJson<String?>(notes),
      'status': serializer.toJson<ItemStatus>(status),
      'projectId': serializer.toJson<String?>(projectId),
      'contextId': serializer.toJson<String?>(contextId),
      'dueAt': serializer.toJson<DateTime?>(dueAt),
      'deferUntil': serializer.toJson<DateTime?>(deferUntil),
      'waitingOn': serializer.toJson<String?>(waitingOn),
      'energy': serializer.toJson<Energy?>(energy),
      'timeEstimateMinutes': serializer.toJson<int?>(timeEstimateMinutes),
      'isTwoMin': serializer.toJson<bool>(isTwoMin),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'previousStatus': serializer.toJson<ItemStatus?>(previousStatus),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'projectSortOrder': serializer.toJson<int>(projectSortOrder),
      'recurrence': serializer.toJson<Recurrence?>(recurrence),
      'recurrenceInterval': serializer.toJson<int>(recurrenceInterval),
      'recurrenceUntil': serializer.toJson<DateTime?>(recurrenceUntil),
      'recurrenceCount': serializer.toJson<int?>(recurrenceCount),
      'recurrenceDoneCount': serializer.toJson<int>(recurrenceDoneCount),
      'recurrenceByWeekdays': serializer.toJson<String?>(recurrenceByWeekdays),
      'recurrenceMonthlyWeek': serializer.toJson<int?>(recurrenceMonthlyWeek),
      'recurrenceMonthlyWeekday': serializer.toJson<int?>(
        recurrenceMonthlyWeekday,
      ),
      'calendarEventId': serializer.toJson<String?>(calendarEventId),
      'searchText': serializer.toJson<String>(searchText),
    };
  }

  ItemRow copyWith({
    String? id,
    String? title,
    Value<String?> notes = const Value.absent(),
    ItemStatus? status,
    Value<String?> projectId = const Value.absent(),
    Value<String?> contextId = const Value.absent(),
    Value<DateTime?> dueAt = const Value.absent(),
    Value<DateTime?> deferUntil = const Value.absent(),
    Value<String?> waitingOn = const Value.absent(),
    Value<Energy?> energy = const Value.absent(),
    Value<int?> timeEstimateMinutes = const Value.absent(),
    bool? isTwoMin,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> completedAt = const Value.absent(),
    Value<ItemStatus?> previousStatus = const Value.absent(),
    int? sortOrder,
    int? projectSortOrder,
    Value<Recurrence?> recurrence = const Value.absent(),
    int? recurrenceInterval,
    Value<DateTime?> recurrenceUntil = const Value.absent(),
    Value<int?> recurrenceCount = const Value.absent(),
    int? recurrenceDoneCount,
    Value<String?> recurrenceByWeekdays = const Value.absent(),
    Value<int?> recurrenceMonthlyWeek = const Value.absent(),
    Value<int?> recurrenceMonthlyWeekday = const Value.absent(),
    Value<String?> calendarEventId = const Value.absent(),
    String? searchText,
  }) => ItemRow(
    id: id ?? this.id,
    title: title ?? this.title,
    notes: notes.present ? notes.value : this.notes,
    status: status ?? this.status,
    projectId: projectId.present ? projectId.value : this.projectId,
    contextId: contextId.present ? contextId.value : this.contextId,
    dueAt: dueAt.present ? dueAt.value : this.dueAt,
    deferUntil: deferUntil.present ? deferUntil.value : this.deferUntil,
    waitingOn: waitingOn.present ? waitingOn.value : this.waitingOn,
    energy: energy.present ? energy.value : this.energy,
    timeEstimateMinutes: timeEstimateMinutes.present
        ? timeEstimateMinutes.value
        : this.timeEstimateMinutes,
    isTwoMin: isTwoMin ?? this.isTwoMin,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    previousStatus: previousStatus.present
        ? previousStatus.value
        : this.previousStatus,
    sortOrder: sortOrder ?? this.sortOrder,
    projectSortOrder: projectSortOrder ?? this.projectSortOrder,
    recurrence: recurrence.present ? recurrence.value : this.recurrence,
    recurrenceInterval: recurrenceInterval ?? this.recurrenceInterval,
    recurrenceUntil: recurrenceUntil.present
        ? recurrenceUntil.value
        : this.recurrenceUntil,
    recurrenceCount: recurrenceCount.present
        ? recurrenceCount.value
        : this.recurrenceCount,
    recurrenceDoneCount: recurrenceDoneCount ?? this.recurrenceDoneCount,
    recurrenceByWeekdays: recurrenceByWeekdays.present
        ? recurrenceByWeekdays.value
        : this.recurrenceByWeekdays,
    recurrenceMonthlyWeek: recurrenceMonthlyWeek.present
        ? recurrenceMonthlyWeek.value
        : this.recurrenceMonthlyWeek,
    recurrenceMonthlyWeekday: recurrenceMonthlyWeekday.present
        ? recurrenceMonthlyWeekday.value
        : this.recurrenceMonthlyWeekday,
    calendarEventId: calendarEventId.present
        ? calendarEventId.value
        : this.calendarEventId,
    searchText: searchText ?? this.searchText,
  );
  ItemRow copyWithCompanion(ItemsCompanion data) {
    return ItemRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      notes: data.notes.present ? data.notes.value : this.notes,
      status: data.status.present ? data.status.value : this.status,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      contextId: data.contextId.present ? data.contextId.value : this.contextId,
      dueAt: data.dueAt.present ? data.dueAt.value : this.dueAt,
      deferUntil: data.deferUntil.present
          ? data.deferUntil.value
          : this.deferUntil,
      waitingOn: data.waitingOn.present ? data.waitingOn.value : this.waitingOn,
      energy: data.energy.present ? data.energy.value : this.energy,
      timeEstimateMinutes: data.timeEstimateMinutes.present
          ? data.timeEstimateMinutes.value
          : this.timeEstimateMinutes,
      isTwoMin: data.isTwoMin.present ? data.isTwoMin.value : this.isTwoMin,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      previousStatus: data.previousStatus.present
          ? data.previousStatus.value
          : this.previousStatus,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      projectSortOrder: data.projectSortOrder.present
          ? data.projectSortOrder.value
          : this.projectSortOrder,
      recurrence: data.recurrence.present
          ? data.recurrence.value
          : this.recurrence,
      recurrenceInterval: data.recurrenceInterval.present
          ? data.recurrenceInterval.value
          : this.recurrenceInterval,
      recurrenceUntil: data.recurrenceUntil.present
          ? data.recurrenceUntil.value
          : this.recurrenceUntil,
      recurrenceCount: data.recurrenceCount.present
          ? data.recurrenceCount.value
          : this.recurrenceCount,
      recurrenceDoneCount: data.recurrenceDoneCount.present
          ? data.recurrenceDoneCount.value
          : this.recurrenceDoneCount,
      recurrenceByWeekdays: data.recurrenceByWeekdays.present
          ? data.recurrenceByWeekdays.value
          : this.recurrenceByWeekdays,
      recurrenceMonthlyWeek: data.recurrenceMonthlyWeek.present
          ? data.recurrenceMonthlyWeek.value
          : this.recurrenceMonthlyWeek,
      recurrenceMonthlyWeekday: data.recurrenceMonthlyWeekday.present
          ? data.recurrenceMonthlyWeekday.value
          : this.recurrenceMonthlyWeekday,
      calendarEventId: data.calendarEventId.present
          ? data.calendarEventId.value
          : this.calendarEventId,
      searchText: data.searchText.present
          ? data.searchText.value
          : this.searchText,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ItemRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('status: $status, ')
          ..write('projectId: $projectId, ')
          ..write('contextId: $contextId, ')
          ..write('dueAt: $dueAt, ')
          ..write('deferUntil: $deferUntil, ')
          ..write('waitingOn: $waitingOn, ')
          ..write('energy: $energy, ')
          ..write('timeEstimateMinutes: $timeEstimateMinutes, ')
          ..write('isTwoMin: $isTwoMin, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('previousStatus: $previousStatus, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('projectSortOrder: $projectSortOrder, ')
          ..write('recurrence: $recurrence, ')
          ..write('recurrenceInterval: $recurrenceInterval, ')
          ..write('recurrenceUntil: $recurrenceUntil, ')
          ..write('recurrenceCount: $recurrenceCount, ')
          ..write('recurrenceDoneCount: $recurrenceDoneCount, ')
          ..write('recurrenceByWeekdays: $recurrenceByWeekdays, ')
          ..write('recurrenceMonthlyWeek: $recurrenceMonthlyWeek, ')
          ..write('recurrenceMonthlyWeekday: $recurrenceMonthlyWeekday, ')
          ..write('calendarEventId: $calendarEventId, ')
          ..write('searchText: $searchText')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    title,
    notes,
    status,
    projectId,
    contextId,
    dueAt,
    deferUntil,
    waitingOn,
    energy,
    timeEstimateMinutes,
    isTwoMin,
    createdAt,
    updatedAt,
    completedAt,
    previousStatus,
    sortOrder,
    projectSortOrder,
    recurrence,
    recurrenceInterval,
    recurrenceUntil,
    recurrenceCount,
    recurrenceDoneCount,
    recurrenceByWeekdays,
    recurrenceMonthlyWeek,
    recurrenceMonthlyWeekday,
    calendarEventId,
    searchText,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ItemRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.notes == this.notes &&
          other.status == this.status &&
          other.projectId == this.projectId &&
          other.contextId == this.contextId &&
          other.dueAt == this.dueAt &&
          other.deferUntil == this.deferUntil &&
          other.waitingOn == this.waitingOn &&
          other.energy == this.energy &&
          other.timeEstimateMinutes == this.timeEstimateMinutes &&
          other.isTwoMin == this.isTwoMin &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.completedAt == this.completedAt &&
          other.previousStatus == this.previousStatus &&
          other.sortOrder == this.sortOrder &&
          other.projectSortOrder == this.projectSortOrder &&
          other.recurrence == this.recurrence &&
          other.recurrenceInterval == this.recurrenceInterval &&
          other.recurrenceUntil == this.recurrenceUntil &&
          other.recurrenceCount == this.recurrenceCount &&
          other.recurrenceDoneCount == this.recurrenceDoneCount &&
          other.recurrenceByWeekdays == this.recurrenceByWeekdays &&
          other.recurrenceMonthlyWeek == this.recurrenceMonthlyWeek &&
          other.recurrenceMonthlyWeekday == this.recurrenceMonthlyWeekday &&
          other.calendarEventId == this.calendarEventId &&
          other.searchText == this.searchText);
}

class ItemsCompanion extends UpdateCompanion<ItemRow> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> notes;
  final Value<ItemStatus> status;
  final Value<String?> projectId;
  final Value<String?> contextId;
  final Value<DateTime?> dueAt;
  final Value<DateTime?> deferUntil;
  final Value<String?> waitingOn;
  final Value<Energy?> energy;
  final Value<int?> timeEstimateMinutes;
  final Value<bool> isTwoMin;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> completedAt;
  final Value<ItemStatus?> previousStatus;
  final Value<int> sortOrder;
  final Value<int> projectSortOrder;
  final Value<Recurrence?> recurrence;
  final Value<int> recurrenceInterval;
  final Value<DateTime?> recurrenceUntil;
  final Value<int?> recurrenceCount;
  final Value<int> recurrenceDoneCount;
  final Value<String?> recurrenceByWeekdays;
  final Value<int?> recurrenceMonthlyWeek;
  final Value<int?> recurrenceMonthlyWeekday;
  final Value<String?> calendarEventId;
  final Value<String> searchText;
  final Value<int> rowid;
  const ItemsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.notes = const Value.absent(),
    this.status = const Value.absent(),
    this.projectId = const Value.absent(),
    this.contextId = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.deferUntil = const Value.absent(),
    this.waitingOn = const Value.absent(),
    this.energy = const Value.absent(),
    this.timeEstimateMinutes = const Value.absent(),
    this.isTwoMin = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.previousStatus = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.projectSortOrder = const Value.absent(),
    this.recurrence = const Value.absent(),
    this.recurrenceInterval = const Value.absent(),
    this.recurrenceUntil = const Value.absent(),
    this.recurrenceCount = const Value.absent(),
    this.recurrenceDoneCount = const Value.absent(),
    this.recurrenceByWeekdays = const Value.absent(),
    this.recurrenceMonthlyWeek = const Value.absent(),
    this.recurrenceMonthlyWeekday = const Value.absent(),
    this.calendarEventId = const Value.absent(),
    this.searchText = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItemsCompanion.insert({
    required String id,
    required String title,
    this.notes = const Value.absent(),
    this.status = const Value.absent(),
    this.projectId = const Value.absent(),
    this.contextId = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.deferUntil = const Value.absent(),
    this.waitingOn = const Value.absent(),
    this.energy = const Value.absent(),
    this.timeEstimateMinutes = const Value.absent(),
    this.isTwoMin = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.completedAt = const Value.absent(),
    this.previousStatus = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.projectSortOrder = const Value.absent(),
    this.recurrence = const Value.absent(),
    this.recurrenceInterval = const Value.absent(),
    this.recurrenceUntil = const Value.absent(),
    this.recurrenceCount = const Value.absent(),
    this.recurrenceDoneCount = const Value.absent(),
    this.recurrenceByWeekdays = const Value.absent(),
    this.recurrenceMonthlyWeek = const Value.absent(),
    this.recurrenceMonthlyWeekday = const Value.absent(),
    this.calendarEventId = const Value.absent(),
    this.searchText = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ItemRow> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? notes,
    Expression<String>? status,
    Expression<String>? projectId,
    Expression<String>? contextId,
    Expression<DateTime>? dueAt,
    Expression<DateTime>? deferUntil,
    Expression<String>? waitingOn,
    Expression<String>? energy,
    Expression<int>? timeEstimateMinutes,
    Expression<bool>? isTwoMin,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? completedAt,
    Expression<String>? previousStatus,
    Expression<int>? sortOrder,
    Expression<int>? projectSortOrder,
    Expression<String>? recurrence,
    Expression<int>? recurrenceInterval,
    Expression<DateTime>? recurrenceUntil,
    Expression<int>? recurrenceCount,
    Expression<int>? recurrenceDoneCount,
    Expression<String>? recurrenceByWeekdays,
    Expression<int>? recurrenceMonthlyWeek,
    Expression<int>? recurrenceMonthlyWeekday,
    Expression<String>? calendarEventId,
    Expression<String>? searchText,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (notes != null) 'notes': notes,
      if (status != null) 'status': status,
      if (projectId != null) 'project_id': projectId,
      if (contextId != null) 'context_id': contextId,
      if (dueAt != null) 'due_at': dueAt,
      if (deferUntil != null) 'defer_until': deferUntil,
      if (waitingOn != null) 'waiting_on': waitingOn,
      if (energy != null) 'energy': energy,
      if (timeEstimateMinutes != null)
        'time_estimate_minutes': timeEstimateMinutes,
      if (isTwoMin != null) 'is_two_min': isTwoMin,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (previousStatus != null) 'previous_status': previousStatus,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (projectSortOrder != null) 'project_sort_order': projectSortOrder,
      if (recurrence != null) 'recurrence': recurrence,
      if (recurrenceInterval != null) 'recurrence_interval': recurrenceInterval,
      if (recurrenceUntil != null) 'recurrence_until': recurrenceUntil,
      if (recurrenceCount != null) 'recurrence_count': recurrenceCount,
      if (recurrenceDoneCount != null)
        'recurrence_done_count': recurrenceDoneCount,
      if (recurrenceByWeekdays != null)
        'recurrence_by_weekdays': recurrenceByWeekdays,
      if (recurrenceMonthlyWeek != null)
        'recurrence_monthly_week': recurrenceMonthlyWeek,
      if (recurrenceMonthlyWeekday != null)
        'recurrence_monthly_weekday': recurrenceMonthlyWeekday,
      if (calendarEventId != null) 'calendar_event_id': calendarEventId,
      if (searchText != null) 'search_text': searchText,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String?>? notes,
    Value<ItemStatus>? status,
    Value<String?>? projectId,
    Value<String?>? contextId,
    Value<DateTime?>? dueAt,
    Value<DateTime?>? deferUntil,
    Value<String?>? waitingOn,
    Value<Energy?>? energy,
    Value<int?>? timeEstimateMinutes,
    Value<bool>? isTwoMin,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? completedAt,
    Value<ItemStatus?>? previousStatus,
    Value<int>? sortOrder,
    Value<int>? projectSortOrder,
    Value<Recurrence?>? recurrence,
    Value<int>? recurrenceInterval,
    Value<DateTime?>? recurrenceUntil,
    Value<int?>? recurrenceCount,
    Value<int>? recurrenceDoneCount,
    Value<String?>? recurrenceByWeekdays,
    Value<int?>? recurrenceMonthlyWeek,
    Value<int?>? recurrenceMonthlyWeekday,
    Value<String?>? calendarEventId,
    Value<String>? searchText,
    Value<int>? rowid,
  }) {
    return ItemsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      projectId: projectId ?? this.projectId,
      contextId: contextId ?? this.contextId,
      dueAt: dueAt ?? this.dueAt,
      deferUntil: deferUntil ?? this.deferUntil,
      waitingOn: waitingOn ?? this.waitingOn,
      energy: energy ?? this.energy,
      timeEstimateMinutes: timeEstimateMinutes ?? this.timeEstimateMinutes,
      isTwoMin: isTwoMin ?? this.isTwoMin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      previousStatus: previousStatus ?? this.previousStatus,
      sortOrder: sortOrder ?? this.sortOrder,
      projectSortOrder: projectSortOrder ?? this.projectSortOrder,
      recurrence: recurrence ?? this.recurrence,
      recurrenceInterval: recurrenceInterval ?? this.recurrenceInterval,
      recurrenceUntil: recurrenceUntil ?? this.recurrenceUntil,
      recurrenceCount: recurrenceCount ?? this.recurrenceCount,
      recurrenceDoneCount: recurrenceDoneCount ?? this.recurrenceDoneCount,
      recurrenceByWeekdays: recurrenceByWeekdays ?? this.recurrenceByWeekdays,
      recurrenceMonthlyWeek:
          recurrenceMonthlyWeek ?? this.recurrenceMonthlyWeek,
      recurrenceMonthlyWeekday:
          recurrenceMonthlyWeekday ?? this.recurrenceMonthlyWeekday,
      calendarEventId: calendarEventId ?? this.calendarEventId,
      searchText: searchText ?? this.searchText,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $ItemsTable.$converterstatus.toSql(status.value),
      );
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (contextId.present) {
      map['context_id'] = Variable<String>(contextId.value);
    }
    if (dueAt.present) {
      map['due_at'] = Variable<DateTime>(dueAt.value);
    }
    if (deferUntil.present) {
      map['defer_until'] = Variable<DateTime>(deferUntil.value);
    }
    if (waitingOn.present) {
      map['waiting_on'] = Variable<String>(waitingOn.value);
    }
    if (energy.present) {
      map['energy'] = Variable<String>(
        $ItemsTable.$converterenergyn.toSql(energy.value),
      );
    }
    if (timeEstimateMinutes.present) {
      map['time_estimate_minutes'] = Variable<int>(timeEstimateMinutes.value);
    }
    if (isTwoMin.present) {
      map['is_two_min'] = Variable<bool>(isTwoMin.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (previousStatus.present) {
      map['previous_status'] = Variable<String>(
        $ItemsTable.$converterpreviousStatusn.toSql(previousStatus.value),
      );
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (projectSortOrder.present) {
      map['project_sort_order'] = Variable<int>(projectSortOrder.value);
    }
    if (recurrence.present) {
      map['recurrence'] = Variable<String>(
        $ItemsTable.$converterrecurrencen.toSql(recurrence.value),
      );
    }
    if (recurrenceInterval.present) {
      map['recurrence_interval'] = Variable<int>(recurrenceInterval.value);
    }
    if (recurrenceUntil.present) {
      map['recurrence_until'] = Variable<DateTime>(recurrenceUntil.value);
    }
    if (recurrenceCount.present) {
      map['recurrence_count'] = Variable<int>(recurrenceCount.value);
    }
    if (recurrenceDoneCount.present) {
      map['recurrence_done_count'] = Variable<int>(recurrenceDoneCount.value);
    }
    if (recurrenceByWeekdays.present) {
      map['recurrence_by_weekdays'] = Variable<String>(
        recurrenceByWeekdays.value,
      );
    }
    if (recurrenceMonthlyWeek.present) {
      map['recurrence_monthly_week'] = Variable<int>(
        recurrenceMonthlyWeek.value,
      );
    }
    if (recurrenceMonthlyWeekday.present) {
      map['recurrence_monthly_weekday'] = Variable<int>(
        recurrenceMonthlyWeekday.value,
      );
    }
    if (calendarEventId.present) {
      map['calendar_event_id'] = Variable<String>(calendarEventId.value);
    }
    if (searchText.present) {
      map['search_text'] = Variable<String>(searchText.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('status: $status, ')
          ..write('projectId: $projectId, ')
          ..write('contextId: $contextId, ')
          ..write('dueAt: $dueAt, ')
          ..write('deferUntil: $deferUntil, ')
          ..write('waitingOn: $waitingOn, ')
          ..write('energy: $energy, ')
          ..write('timeEstimateMinutes: $timeEstimateMinutes, ')
          ..write('isTwoMin: $isTwoMin, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('previousStatus: $previousStatus, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('projectSortOrder: $projectSortOrder, ')
          ..write('recurrence: $recurrence, ')
          ..write('recurrenceInterval: $recurrenceInterval, ')
          ..write('recurrenceUntil: $recurrenceUntil, ')
          ..write('recurrenceCount: $recurrenceCount, ')
          ..write('recurrenceDoneCount: $recurrenceDoneCount, ')
          ..write('recurrenceByWeekdays: $recurrenceByWeekdays, ')
          ..write('recurrenceMonthlyWeek: $recurrenceMonthlyWeek, ')
          ..write('recurrenceMonthlyWeekday: $recurrenceMonthlyWeekday, ')
          ..write('calendarEventId: $calendarEventId, ')
          ..write('searchText: $searchText, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProjectsTable extends Projects
    with TableInfo<$ProjectsTable, ProjectRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _outcomeMeta = const VerificationMeta(
    'outcome',
  );
  @override
  late final GeneratedColumn<String> outcome = GeneratedColumn<String>(
    'outcome',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _areaIdMeta = const VerificationMeta('areaId');
  @override
  late final GeneratedColumn<String> areaId = GeneratedColumn<String>(
    'area_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ProjectStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('active'),
      ).withConverter<ProjectStatus>($ProjectsTable.$converterstatus);
  static const VerificationMeta _dueAtMeta = const VerificationMeta('dueAt');
  @override
  late final GeneratedColumn<DateTime> dueAt = GeneratedColumn<DateTime>(
    'due_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    outcome,
    areaId,
    status,
    dueAt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'projects';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProjectRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('outcome')) {
      context.handle(
        _outcomeMeta,
        outcome.isAcceptableOrUnknown(data['outcome']!, _outcomeMeta),
      );
    }
    if (data.containsKey('area_id')) {
      context.handle(
        _areaIdMeta,
        areaId.isAcceptableOrUnknown(data['area_id']!, _areaIdMeta),
      );
    }
    if (data.containsKey('due_at')) {
      context.handle(
        _dueAtMeta,
        dueAt.isAcceptableOrUnknown(data['due_at']!, _dueAtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProjectRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProjectRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      outcome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}outcome'],
      ),
      areaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}area_id'],
      ),
      status: $ProjectsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      dueAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ProjectsTable createAlias(String alias) {
    return $ProjectsTable(attachedDatabase, alias);
  }

  static TypeConverter<ProjectStatus, String> $converterstatus =
      const ProjectStatusConverter();
}

class ProjectRow extends DataClass implements Insertable<ProjectRow> {
  final String id;
  final String title;
  final String? outcome;
  final String? areaId;
  final ProjectStatus status;
  final DateTime? dueAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ProjectRow({
    required this.id,
    required this.title,
    this.outcome,
    this.areaId,
    required this.status,
    this.dueAt,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || outcome != null) {
      map['outcome'] = Variable<String>(outcome);
    }
    if (!nullToAbsent || areaId != null) {
      map['area_id'] = Variable<String>(areaId);
    }
    {
      map['status'] = Variable<String>(
        $ProjectsTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || dueAt != null) {
      map['due_at'] = Variable<DateTime>(dueAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ProjectsCompanion toCompanion(bool nullToAbsent) {
    return ProjectsCompanion(
      id: Value(id),
      title: Value(title),
      outcome: outcome == null && nullToAbsent
          ? const Value.absent()
          : Value(outcome),
      areaId: areaId == null && nullToAbsent
          ? const Value.absent()
          : Value(areaId),
      status: Value(status),
      dueAt: dueAt == null && nullToAbsent
          ? const Value.absent()
          : Value(dueAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ProjectRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProjectRow(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      outcome: serializer.fromJson<String?>(json['outcome']),
      areaId: serializer.fromJson<String?>(json['areaId']),
      status: serializer.fromJson<ProjectStatus>(json['status']),
      dueAt: serializer.fromJson<DateTime?>(json['dueAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'outcome': serializer.toJson<String?>(outcome),
      'areaId': serializer.toJson<String?>(areaId),
      'status': serializer.toJson<ProjectStatus>(status),
      'dueAt': serializer.toJson<DateTime?>(dueAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ProjectRow copyWith({
    String? id,
    String? title,
    Value<String?> outcome = const Value.absent(),
    Value<String?> areaId = const Value.absent(),
    ProjectStatus? status,
    Value<DateTime?> dueAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ProjectRow(
    id: id ?? this.id,
    title: title ?? this.title,
    outcome: outcome.present ? outcome.value : this.outcome,
    areaId: areaId.present ? areaId.value : this.areaId,
    status: status ?? this.status,
    dueAt: dueAt.present ? dueAt.value : this.dueAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ProjectRow copyWithCompanion(ProjectsCompanion data) {
    return ProjectRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      outcome: data.outcome.present ? data.outcome.value : this.outcome,
      areaId: data.areaId.present ? data.areaId.value : this.areaId,
      status: data.status.present ? data.status.value : this.status,
      dueAt: data.dueAt.present ? data.dueAt.value : this.dueAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProjectRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('outcome: $outcome, ')
          ..write('areaId: $areaId, ')
          ..write('status: $status, ')
          ..write('dueAt: $dueAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    outcome,
    areaId,
    status,
    dueAt,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProjectRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.outcome == this.outcome &&
          other.areaId == this.areaId &&
          other.status == this.status &&
          other.dueAt == this.dueAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ProjectsCompanion extends UpdateCompanion<ProjectRow> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> outcome;
  final Value<String?> areaId;
  final Value<ProjectStatus> status;
  final Value<DateTime?> dueAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ProjectsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.outcome = const Value.absent(),
    this.areaId = const Value.absent(),
    this.status = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProjectsCompanion.insert({
    required String id,
    required String title,
    this.outcome = const Value.absent(),
    this.areaId = const Value.absent(),
    this.status = const Value.absent(),
    this.dueAt = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ProjectRow> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? outcome,
    Expression<String>? areaId,
    Expression<String>? status,
    Expression<DateTime>? dueAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (outcome != null) 'outcome': outcome,
      if (areaId != null) 'area_id': areaId,
      if (status != null) 'status': status,
      if (dueAt != null) 'due_at': dueAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProjectsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String?>? outcome,
    Value<String?>? areaId,
    Value<ProjectStatus>? status,
    Value<DateTime?>? dueAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ProjectsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      outcome: outcome ?? this.outcome,
      areaId: areaId ?? this.areaId,
      status: status ?? this.status,
      dueAt: dueAt ?? this.dueAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (outcome.present) {
      map['outcome'] = Variable<String>(outcome.value);
    }
    if (areaId.present) {
      map['area_id'] = Variable<String>(areaId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $ProjectsTable.$converterstatus.toSql(status.value),
      );
    }
    if (dueAt.present) {
      map['due_at'] = Variable<DateTime>(dueAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('outcome: $outcome, ')
          ..write('areaId: $areaId, ')
          ..write('status: $status, ')
          ..write('dueAt: $dueAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ContextsTable extends Contexts
    with TableInfo<$ContextsTable, ContextRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContextsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('label'),
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0xFF6750A4),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, icon, color, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contexts';
  @override
  VerificationContext validateIntegrity(
    Insertable<ContextRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ContextRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContextRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $ContextsTable createAlias(String alias) {
    return $ContextsTable(attachedDatabase, alias);
  }
}

class ContextRow extends DataClass implements Insertable<ContextRow> {
  final String id;
  final String name;
  final String icon;
  final int color;
  final int sortOrder;
  const ContextRow({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['icon'] = Variable<String>(icon);
    map['color'] = Variable<int>(color);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  ContextsCompanion toCompanion(bool nullToAbsent) {
    return ContextsCompanion(
      id: Value(id),
      name: Value(name),
      icon: Value(icon),
      color: Value(color),
      sortOrder: Value(sortOrder),
    );
  }

  factory ContextRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContextRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      icon: serializer.fromJson<String>(json['icon']),
      color: serializer.fromJson<int>(json['color']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'icon': serializer.toJson<String>(icon),
      'color': serializer.toJson<int>(color),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  ContextRow copyWith({
    String? id,
    String? name,
    String? icon,
    int? color,
    int? sortOrder,
  }) => ContextRow(
    id: id ?? this.id,
    name: name ?? this.name,
    icon: icon ?? this.icon,
    color: color ?? this.color,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  ContextRow copyWithCompanion(ContextsCompanion data) {
    return ContextRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      icon: data.icon.present ? data.icon.value : this.icon,
      color: data.color.present ? data.color.value : this.color,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContextRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, icon, color, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContextRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.icon == this.icon &&
          other.color == this.color &&
          other.sortOrder == this.sortOrder);
}

class ContextsCompanion extends UpdateCompanion<ContextRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> icon;
  final Value<int> color;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const ContextsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ContextsCompanion.insert({
    required String id,
    required String name,
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<ContextRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? icon,
    Expression<int>? color,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ContextsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? icon,
    Value<int>? color,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return ContextsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContextsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AreasTable extends Areas with TableInfo<$AreasTable, AreaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AreasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'areas';
  @override
  VerificationContext validateIntegrity(
    Insertable<AreaRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AreaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AreaRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $AreasTable createAlias(String alias) {
    return $AreasTable(attachedDatabase, alias);
  }
}

class AreaRow extends DataClass implements Insertable<AreaRow> {
  final String id;
  final String name;
  const AreaRow({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  AreasCompanion toCompanion(bool nullToAbsent) {
    return AreasCompanion(id: Value(id), name: Value(name));
  }

  factory AreaRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AreaRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  AreaRow copyWith({String? id, String? name}) =>
      AreaRow(id: id ?? this.id, name: name ?? this.name);
  AreaRow copyWithCompanion(AreasCompanion data) {
    return AreaRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AreaRow(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AreaRow && other.id == this.id && other.name == this.name);
}

class AreasCompanion extends UpdateCompanion<AreaRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> rowid;
  const AreasCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AreasCompanion.insert({
    required String id,
    required String name,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<AreaRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AreasCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? rowid,
  }) {
    return AreasCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AreasCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AttachmentsTable extends Attachments
    with TableInfo<$AttachmentsTable, AttachmentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttachmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    itemId,
    kind,
    path,
    name,
    sizeBytes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attachments';
  @override
  VerificationContext validateIntegrity(
    Insertable<AttachmentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AttachmentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AttachmentRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AttachmentsTable createAlias(String alias) {
    return $AttachmentsTable(attachedDatabase, alias);
  }
}

class AttachmentRow extends DataClass implements Insertable<AttachmentRow> {
  final String id;
  final String itemId;
  final String kind;
  final String path;
  final String? name;
  final int? sizeBytes;
  final DateTime createdAt;
  const AttachmentRow({
    required this.id,
    required this.itemId,
    required this.kind,
    required this.path,
    this.name,
    this.sizeBytes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['item_id'] = Variable<String>(itemId);
    map['kind'] = Variable<String>(kind);
    map['path'] = Variable<String>(path);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || sizeBytes != null) {
      map['size_bytes'] = Variable<int>(sizeBytes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AttachmentsCompanion toCompanion(bool nullToAbsent) {
    return AttachmentsCompanion(
      id: Value(id),
      itemId: Value(itemId),
      kind: Value(kind),
      path: Value(path),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      sizeBytes: sizeBytes == null && nullToAbsent
          ? const Value.absent()
          : Value(sizeBytes),
      createdAt: Value(createdAt),
    );
  }

  factory AttachmentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AttachmentRow(
      id: serializer.fromJson<String>(json['id']),
      itemId: serializer.fromJson<String>(json['itemId']),
      kind: serializer.fromJson<String>(json['kind']),
      path: serializer.fromJson<String>(json['path']),
      name: serializer.fromJson<String?>(json['name']),
      sizeBytes: serializer.fromJson<int?>(json['sizeBytes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'itemId': serializer.toJson<String>(itemId),
      'kind': serializer.toJson<String>(kind),
      'path': serializer.toJson<String>(path),
      'name': serializer.toJson<String?>(name),
      'sizeBytes': serializer.toJson<int?>(sizeBytes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  AttachmentRow copyWith({
    String? id,
    String? itemId,
    String? kind,
    String? path,
    Value<String?> name = const Value.absent(),
    Value<int?> sizeBytes = const Value.absent(),
    DateTime? createdAt,
  }) => AttachmentRow(
    id: id ?? this.id,
    itemId: itemId ?? this.itemId,
    kind: kind ?? this.kind,
    path: path ?? this.path,
    name: name.present ? name.value : this.name,
    sizeBytes: sizeBytes.present ? sizeBytes.value : this.sizeBytes,
    createdAt: createdAt ?? this.createdAt,
  );
  AttachmentRow copyWithCompanion(AttachmentsCompanion data) {
    return AttachmentRow(
      id: data.id.present ? data.id.value : this.id,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      kind: data.kind.present ? data.kind.value : this.kind,
      path: data.path.present ? data.path.value : this.path,
      name: data.name.present ? data.name.value : this.name,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AttachmentRow(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('kind: $kind, ')
          ..write('path: $path, ')
          ..write('name: $name, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, itemId, kind, path, name, sizeBytes, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AttachmentRow &&
          other.id == this.id &&
          other.itemId == this.itemId &&
          other.kind == this.kind &&
          other.path == this.path &&
          other.name == this.name &&
          other.sizeBytes == this.sizeBytes &&
          other.createdAt == this.createdAt);
}

class AttachmentsCompanion extends UpdateCompanion<AttachmentRow> {
  final Value<String> id;
  final Value<String> itemId;
  final Value<String> kind;
  final Value<String> path;
  final Value<String?> name;
  final Value<int?> sizeBytes;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const AttachmentsCompanion({
    this.id = const Value.absent(),
    this.itemId = const Value.absent(),
    this.kind = const Value.absent(),
    this.path = const Value.absent(),
    this.name = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AttachmentsCompanion.insert({
    required String id,
    required String itemId,
    required String kind,
    required String path,
    this.name = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       itemId = Value(itemId),
       kind = Value(kind),
       path = Value(path),
       createdAt = Value(createdAt);
  static Insertable<AttachmentRow> custom({
    Expression<String>? id,
    Expression<String>? itemId,
    Expression<String>? kind,
    Expression<String>? path,
    Expression<String>? name,
    Expression<int>? sizeBytes,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (itemId != null) 'item_id': itemId,
      if (kind != null) 'kind': kind,
      if (path != null) 'path': path,
      if (name != null) 'name': name,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AttachmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? itemId,
    Value<String>? kind,
    Value<String>? path,
    Value<String?>? name,
    Value<int?>? sizeBytes,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return AttachmentsCompanion(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      kind: kind ?? this.kind,
      path: path ?? this.path,
      name: name ?? this.name,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttachmentsCompanion(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('kind: $kind, ')
          ..write('path: $path, ')
          ..write('name: $name, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReviewsTable extends Reviews with TableInfo<$ReviewsTable, ReviewRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReviewsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ReviewType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ReviewType>($ReviewsTable.$convertertype);
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    startedAt,
    completedAt,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reviews';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReviewRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReviewRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReviewRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      type: $ReviewsTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $ReviewsTable createAlias(String alias) {
    return $ReviewsTable(attachedDatabase, alias);
  }

  static TypeConverter<ReviewType, String> $convertertype =
      const ReviewTypeConverter();
}

class ReviewRow extends DataClass implements Insertable<ReviewRow> {
  final String id;
  final ReviewType type;
  final DateTime startedAt;
  final DateTime? completedAt;
  final String? notes;
  const ReviewRow({
    required this.id,
    required this.type,
    required this.startedAt,
    this.completedAt,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['type'] = Variable<String>($ReviewsTable.$convertertype.toSql(type));
    }
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  ReviewsCompanion toCompanion(bool nullToAbsent) {
    return ReviewsCompanion(
      id: Value(id),
      type: Value(type),
      startedAt: Value(startedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory ReviewRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReviewRow(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<ReviewType>(json['type']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<ReviewType>(type),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  ReviewRow copyWith({
    String? id,
    ReviewType? type,
    DateTime? startedAt,
    Value<DateTime?> completedAt = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) => ReviewRow(
    id: id ?? this.id,
    type: type ?? this.type,
    startedAt: startedAt ?? this.startedAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    notes: notes.present ? notes.value : this.notes,
  );
  ReviewRow copyWithCompanion(ReviewsCompanion data) {
    return ReviewRow(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReviewRow(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, type, startedAt, completedAt, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReviewRow &&
          other.id == this.id &&
          other.type == this.type &&
          other.startedAt == this.startedAt &&
          other.completedAt == this.completedAt &&
          other.notes == this.notes);
}

class ReviewsCompanion extends UpdateCompanion<ReviewRow> {
  final Value<String> id;
  final Value<ReviewType> type;
  final Value<DateTime> startedAt;
  final Value<DateTime?> completedAt;
  final Value<String?> notes;
  final Value<int> rowid;
  const ReviewsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReviewsCompanion.insert({
    required String id,
    required ReviewType type,
    required DateTime startedAt,
    this.completedAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       startedAt = Value(startedAt);
  static Insertable<ReviewRow> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? completedAt,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReviewsCompanion copyWith({
    Value<String>? id,
    Value<ReviewType>? type,
    Value<DateTime>? startedAt,
    Value<DateTime?>? completedAt,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return ReviewsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $ReviewsTable.$convertertype.toSql(type.value),
      );
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReviewsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ItemsTable items = $ItemsTable(this);
  late final $ProjectsTable projects = $ProjectsTable(this);
  late final $ContextsTable contexts = $ContextsTable(this);
  late final $AreasTable areas = $AreasTable(this);
  late final $AttachmentsTable attachments = $AttachmentsTable(this);
  late final $ReviewsTable reviews = $ReviewsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    items,
    projects,
    contexts,
    areas,
    attachments,
    reviews,
  ];
}

typedef $$ItemsTableCreateCompanionBuilder =
    ItemsCompanion Function({
      required String id,
      required String title,
      Value<String?> notes,
      Value<ItemStatus> status,
      Value<String?> projectId,
      Value<String?> contextId,
      Value<DateTime?> dueAt,
      Value<DateTime?> deferUntil,
      Value<String?> waitingOn,
      Value<Energy?> energy,
      Value<int?> timeEstimateMinutes,
      Value<bool> isTwoMin,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> completedAt,
      Value<ItemStatus?> previousStatus,
      Value<int> sortOrder,
      Value<int> projectSortOrder,
      Value<Recurrence?> recurrence,
      Value<int> recurrenceInterval,
      Value<DateTime?> recurrenceUntil,
      Value<int?> recurrenceCount,
      Value<int> recurrenceDoneCount,
      Value<String?> recurrenceByWeekdays,
      Value<int?> recurrenceMonthlyWeek,
      Value<int?> recurrenceMonthlyWeekday,
      Value<String?> calendarEventId,
      Value<String> searchText,
      Value<int> rowid,
    });
typedef $$ItemsTableUpdateCompanionBuilder =
    ItemsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String?> notes,
      Value<ItemStatus> status,
      Value<String?> projectId,
      Value<String?> contextId,
      Value<DateTime?> dueAt,
      Value<DateTime?> deferUntil,
      Value<String?> waitingOn,
      Value<Energy?> energy,
      Value<int?> timeEstimateMinutes,
      Value<bool> isTwoMin,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> completedAt,
      Value<ItemStatus?> previousStatus,
      Value<int> sortOrder,
      Value<int> projectSortOrder,
      Value<Recurrence?> recurrence,
      Value<int> recurrenceInterval,
      Value<DateTime?> recurrenceUntil,
      Value<int?> recurrenceCount,
      Value<int> recurrenceDoneCount,
      Value<String?> recurrenceByWeekdays,
      Value<int?> recurrenceMonthlyWeek,
      Value<int?> recurrenceMonthlyWeekday,
      Value<String?> calendarEventId,
      Value<String> searchText,
      Value<int> rowid,
    });

class $$ItemsTableFilterComposer extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ItemStatus, ItemStatus, String> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contextId => $composableBuilder(
    column: $table.contextId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deferUntil => $composableBuilder(
    column: $table.deferUntil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get waitingOn => $composableBuilder(
    column: $table.waitingOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Energy?, Energy, String> get energy =>
      $composableBuilder(
        column: $table.energy,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get timeEstimateMinutes => $composableBuilder(
    column: $table.timeEstimateMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isTwoMin => $composableBuilder(
    column: $table.isTwoMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ItemStatus?, ItemStatus, String>
  get previousStatus => $composableBuilder(
    column: $table.previousStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get projectSortOrder => $composableBuilder(
    column: $table.projectSortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Recurrence?, Recurrence, String>
  get recurrence => $composableBuilder(
    column: $table.recurrence,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get recurrenceInterval => $composableBuilder(
    column: $table.recurrenceInterval,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recurrenceUntil => $composableBuilder(
    column: $table.recurrenceUntil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recurrenceCount => $composableBuilder(
    column: $table.recurrenceCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recurrenceDoneCount => $composableBuilder(
    column: $table.recurrenceDoneCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recurrenceByWeekdays => $composableBuilder(
    column: $table.recurrenceByWeekdays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recurrenceMonthlyWeek => $composableBuilder(
    column: $table.recurrenceMonthlyWeek,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recurrenceMonthlyWeekday => $composableBuilder(
    column: $table.recurrenceMonthlyWeekday,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get calendarEventId => $composableBuilder(
    column: $table.calendarEventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get searchText => $composableBuilder(
    column: $table.searchText,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contextId => $composableBuilder(
    column: $table.contextId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deferUntil => $composableBuilder(
    column: $table.deferUntil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get waitingOn => $composableBuilder(
    column: $table.waitingOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get energy => $composableBuilder(
    column: $table.energy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeEstimateMinutes => $composableBuilder(
    column: $table.timeEstimateMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isTwoMin => $composableBuilder(
    column: $table.isTwoMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get previousStatus => $composableBuilder(
    column: $table.previousStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get projectSortOrder => $composableBuilder(
    column: $table.projectSortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurrence => $composableBuilder(
    column: $table.recurrence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recurrenceInterval => $composableBuilder(
    column: $table.recurrenceInterval,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recurrenceUntil => $composableBuilder(
    column: $table.recurrenceUntil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recurrenceCount => $composableBuilder(
    column: $table.recurrenceCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recurrenceDoneCount => $composableBuilder(
    column: $table.recurrenceDoneCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurrenceByWeekdays => $composableBuilder(
    column: $table.recurrenceByWeekdays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recurrenceMonthlyWeek => $composableBuilder(
    column: $table.recurrenceMonthlyWeek,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recurrenceMonthlyWeekday => $composableBuilder(
    column: $table.recurrenceMonthlyWeekday,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get calendarEventId => $composableBuilder(
    column: $table.calendarEventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get searchText => $composableBuilder(
    column: $table.searchText,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ItemStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<String> get contextId =>
      $composableBuilder(column: $table.contextId, builder: (column) => column);

  GeneratedColumn<DateTime> get dueAt =>
      $composableBuilder(column: $table.dueAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deferUntil => $composableBuilder(
    column: $table.deferUntil,
    builder: (column) => column,
  );

  GeneratedColumn<String> get waitingOn =>
      $composableBuilder(column: $table.waitingOn, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Energy?, String> get energy =>
      $composableBuilder(column: $table.energy, builder: (column) => column);

  GeneratedColumn<int> get timeEstimateMinutes => $composableBuilder(
    column: $table.timeEstimateMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isTwoMin =>
      $composableBuilder(column: $table.isTwoMin, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<ItemStatus?, String> get previousStatus =>
      $composableBuilder(
        column: $table.previousStatus,
        builder: (column) => column,
      );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<int> get projectSortOrder => $composableBuilder(
    column: $table.projectSortOrder,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Recurrence?, String> get recurrence =>
      $composableBuilder(
        column: $table.recurrence,
        builder: (column) => column,
      );

  GeneratedColumn<int> get recurrenceInterval => $composableBuilder(
    column: $table.recurrenceInterval,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get recurrenceUntil => $composableBuilder(
    column: $table.recurrenceUntil,
    builder: (column) => column,
  );

  GeneratedColumn<int> get recurrenceCount => $composableBuilder(
    column: $table.recurrenceCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get recurrenceDoneCount => $composableBuilder(
    column: $table.recurrenceDoneCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recurrenceByWeekdays => $composableBuilder(
    column: $table.recurrenceByWeekdays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get recurrenceMonthlyWeek => $composableBuilder(
    column: $table.recurrenceMonthlyWeek,
    builder: (column) => column,
  );

  GeneratedColumn<int> get recurrenceMonthlyWeekday => $composableBuilder(
    column: $table.recurrenceMonthlyWeekday,
    builder: (column) => column,
  );

  GeneratedColumn<String> get calendarEventId => $composableBuilder(
    column: $table.calendarEventId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get searchText => $composableBuilder(
    column: $table.searchText,
    builder: (column) => column,
  );
}

class $$ItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ItemsTable,
          ItemRow,
          $$ItemsTableFilterComposer,
          $$ItemsTableOrderingComposer,
          $$ItemsTableAnnotationComposer,
          $$ItemsTableCreateCompanionBuilder,
          $$ItemsTableUpdateCompanionBuilder,
          (ItemRow, BaseReferences<_$AppDatabase, $ItemsTable, ItemRow>),
          ItemRow,
          PrefetchHooks Function()
        > {
  $$ItemsTableTableManager(_$AppDatabase db, $ItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<ItemStatus> status = const Value.absent(),
                Value<String?> projectId = const Value.absent(),
                Value<String?> contextId = const Value.absent(),
                Value<DateTime?> dueAt = const Value.absent(),
                Value<DateTime?> deferUntil = const Value.absent(),
                Value<String?> waitingOn = const Value.absent(),
                Value<Energy?> energy = const Value.absent(),
                Value<int?> timeEstimateMinutes = const Value.absent(),
                Value<bool> isTwoMin = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<ItemStatus?> previousStatus = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> projectSortOrder = const Value.absent(),
                Value<Recurrence?> recurrence = const Value.absent(),
                Value<int> recurrenceInterval = const Value.absent(),
                Value<DateTime?> recurrenceUntil = const Value.absent(),
                Value<int?> recurrenceCount = const Value.absent(),
                Value<int> recurrenceDoneCount = const Value.absent(),
                Value<String?> recurrenceByWeekdays = const Value.absent(),
                Value<int?> recurrenceMonthlyWeek = const Value.absent(),
                Value<int?> recurrenceMonthlyWeekday = const Value.absent(),
                Value<String?> calendarEventId = const Value.absent(),
                Value<String> searchText = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ItemsCompanion(
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
                recurrenceByWeekdays: recurrenceByWeekdays,
                recurrenceMonthlyWeek: recurrenceMonthlyWeek,
                recurrenceMonthlyWeekday: recurrenceMonthlyWeekday,
                calendarEventId: calendarEventId,
                searchText: searchText,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String?> notes = const Value.absent(),
                Value<ItemStatus> status = const Value.absent(),
                Value<String?> projectId = const Value.absent(),
                Value<String?> contextId = const Value.absent(),
                Value<DateTime?> dueAt = const Value.absent(),
                Value<DateTime?> deferUntil = const Value.absent(),
                Value<String?> waitingOn = const Value.absent(),
                Value<Energy?> energy = const Value.absent(),
                Value<int?> timeEstimateMinutes = const Value.absent(),
                Value<bool> isTwoMin = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> completedAt = const Value.absent(),
                Value<ItemStatus?> previousStatus = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> projectSortOrder = const Value.absent(),
                Value<Recurrence?> recurrence = const Value.absent(),
                Value<int> recurrenceInterval = const Value.absent(),
                Value<DateTime?> recurrenceUntil = const Value.absent(),
                Value<int?> recurrenceCount = const Value.absent(),
                Value<int> recurrenceDoneCount = const Value.absent(),
                Value<String?> recurrenceByWeekdays = const Value.absent(),
                Value<int?> recurrenceMonthlyWeek = const Value.absent(),
                Value<int?> recurrenceMonthlyWeekday = const Value.absent(),
                Value<String?> calendarEventId = const Value.absent(),
                Value<String> searchText = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ItemsCompanion.insert(
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
                recurrenceByWeekdays: recurrenceByWeekdays,
                recurrenceMonthlyWeek: recurrenceMonthlyWeek,
                recurrenceMonthlyWeekday: recurrenceMonthlyWeekday,
                calendarEventId: calendarEventId,
                searchText: searchText,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ItemsTable,
      ItemRow,
      $$ItemsTableFilterComposer,
      $$ItemsTableOrderingComposer,
      $$ItemsTableAnnotationComposer,
      $$ItemsTableCreateCompanionBuilder,
      $$ItemsTableUpdateCompanionBuilder,
      (ItemRow, BaseReferences<_$AppDatabase, $ItemsTable, ItemRow>),
      ItemRow,
      PrefetchHooks Function()
    >;
typedef $$ProjectsTableCreateCompanionBuilder =
    ProjectsCompanion Function({
      required String id,
      required String title,
      Value<String?> outcome,
      Value<String?> areaId,
      Value<ProjectStatus> status,
      Value<DateTime?> dueAt,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$ProjectsTableUpdateCompanionBuilder =
    ProjectsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String?> outcome,
      Value<String?> areaId,
      Value<ProjectStatus> status,
      Value<DateTime?> dueAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$ProjectsTableFilterComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get areaId => $composableBuilder(
    column: $table.areaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ProjectStatus, ProjectStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get areaId => $composableBuilder(
    column: $table.areaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get outcome =>
      $composableBuilder(column: $table.outcome, builder: (column) => column);

  GeneratedColumn<String> get areaId =>
      $composableBuilder(column: $table.areaId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ProjectStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get dueAt =>
      $composableBuilder(column: $table.dueAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ProjectsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProjectsTable,
          ProjectRow,
          $$ProjectsTableFilterComposer,
          $$ProjectsTableOrderingComposer,
          $$ProjectsTableAnnotationComposer,
          $$ProjectsTableCreateCompanionBuilder,
          $$ProjectsTableUpdateCompanionBuilder,
          (
            ProjectRow,
            BaseReferences<_$AppDatabase, $ProjectsTable, ProjectRow>,
          ),
          ProjectRow,
          PrefetchHooks Function()
        > {
  $$ProjectsTableTableManager(_$AppDatabase db, $ProjectsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> outcome = const Value.absent(),
                Value<String?> areaId = const Value.absent(),
                Value<ProjectStatus> status = const Value.absent(),
                Value<DateTime?> dueAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProjectsCompanion(
                id: id,
                title: title,
                outcome: outcome,
                areaId: areaId,
                status: status,
                dueAt: dueAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String?> outcome = const Value.absent(),
                Value<String?> areaId = const Value.absent(),
                Value<ProjectStatus> status = const Value.absent(),
                Value<DateTime?> dueAt = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ProjectsCompanion.insert(
                id: id,
                title: title,
                outcome: outcome,
                areaId: areaId,
                status: status,
                dueAt: dueAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProjectsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProjectsTable,
      ProjectRow,
      $$ProjectsTableFilterComposer,
      $$ProjectsTableOrderingComposer,
      $$ProjectsTableAnnotationComposer,
      $$ProjectsTableCreateCompanionBuilder,
      $$ProjectsTableUpdateCompanionBuilder,
      (ProjectRow, BaseReferences<_$AppDatabase, $ProjectsTable, ProjectRow>),
      ProjectRow,
      PrefetchHooks Function()
    >;
typedef $$ContextsTableCreateCompanionBuilder =
    ContextsCompanion Function({
      required String id,
      required String name,
      Value<String> icon,
      Value<int> color,
      Value<int> sortOrder,
      Value<int> rowid,
    });
typedef $$ContextsTableUpdateCompanionBuilder =
    ContextsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> icon,
      Value<int> color,
      Value<int> sortOrder,
      Value<int> rowid,
    });

class $$ContextsTableFilterComposer
    extends Composer<_$AppDatabase, $ContextsTable> {
  $$ContextsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ContextsTableOrderingComposer
    extends Composer<_$AppDatabase, $ContextsTable> {
  $$ContextsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ContextsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContextsTable> {
  $$ContextsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$ContextsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ContextsTable,
          ContextRow,
          $$ContextsTableFilterComposer,
          $$ContextsTableOrderingComposer,
          $$ContextsTableAnnotationComposer,
          $$ContextsTableCreateCompanionBuilder,
          $$ContextsTableUpdateCompanionBuilder,
          (
            ContextRow,
            BaseReferences<_$AppDatabase, $ContextsTable, ContextRow>,
          ),
          ContextRow,
          PrefetchHooks Function()
        > {
  $$ContextsTableTableManager(_$AppDatabase db, $ContextsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContextsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContextsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContextsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContextsCompanion(
                id: id,
                name: name,
                icon: icon,
                color: color,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String> icon = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContextsCompanion.insert(
                id: id,
                name: name,
                icon: icon,
                color: color,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ContextsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ContextsTable,
      ContextRow,
      $$ContextsTableFilterComposer,
      $$ContextsTableOrderingComposer,
      $$ContextsTableAnnotationComposer,
      $$ContextsTableCreateCompanionBuilder,
      $$ContextsTableUpdateCompanionBuilder,
      (ContextRow, BaseReferences<_$AppDatabase, $ContextsTable, ContextRow>),
      ContextRow,
      PrefetchHooks Function()
    >;
typedef $$AreasTableCreateCompanionBuilder =
    AreasCompanion Function({
      required String id,
      required String name,
      Value<int> rowid,
    });
typedef $$AreasTableUpdateCompanionBuilder =
    AreasCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> rowid,
    });

class $$AreasTableFilterComposer extends Composer<_$AppDatabase, $AreasTable> {
  $$AreasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AreasTableOrderingComposer
    extends Composer<_$AppDatabase, $AreasTable> {
  $$AreasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AreasTableAnnotationComposer
    extends Composer<_$AppDatabase, $AreasTable> {
  $$AreasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$AreasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AreasTable,
          AreaRow,
          $$AreasTableFilterComposer,
          $$AreasTableOrderingComposer,
          $$AreasTableAnnotationComposer,
          $$AreasTableCreateCompanionBuilder,
          $$AreasTableUpdateCompanionBuilder,
          (AreaRow, BaseReferences<_$AppDatabase, $AreasTable, AreaRow>),
          AreaRow,
          PrefetchHooks Function()
        > {
  $$AreasTableTableManager(_$AppDatabase db, $AreasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AreasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AreasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AreasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AreasCompanion(id: id, name: name, rowid: rowid),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<int> rowid = const Value.absent(),
              }) => AreasCompanion.insert(id: id, name: name, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AreasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AreasTable,
      AreaRow,
      $$AreasTableFilterComposer,
      $$AreasTableOrderingComposer,
      $$AreasTableAnnotationComposer,
      $$AreasTableCreateCompanionBuilder,
      $$AreasTableUpdateCompanionBuilder,
      (AreaRow, BaseReferences<_$AppDatabase, $AreasTable, AreaRow>),
      AreaRow,
      PrefetchHooks Function()
    >;
typedef $$AttachmentsTableCreateCompanionBuilder =
    AttachmentsCompanion Function({
      required String id,
      required String itemId,
      required String kind,
      required String path,
      Value<String?> name,
      Value<int?> sizeBytes,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$AttachmentsTableUpdateCompanionBuilder =
    AttachmentsCompanion Function({
      Value<String> id,
      Value<String> itemId,
      Value<String> kind,
      Value<String> path,
      Value<String?> name,
      Value<int?> sizeBytes,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$AttachmentsTableFilterComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AttachmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AttachmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AttachmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttachmentsTable,
          AttachmentRow,
          $$AttachmentsTableFilterComposer,
          $$AttachmentsTableOrderingComposer,
          $$AttachmentsTableAnnotationComposer,
          $$AttachmentsTableCreateCompanionBuilder,
          $$AttachmentsTableUpdateCompanionBuilder,
          (
            AttachmentRow,
            BaseReferences<_$AppDatabase, $AttachmentsTable, AttachmentRow>,
          ),
          AttachmentRow,
          PrefetchHooks Function()
        > {
  $$AttachmentsTableTableManager(_$AppDatabase db, $AttachmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttachmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttachmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttachmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> path = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<int?> sizeBytes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttachmentsCompanion(
                id: id,
                itemId: itemId,
                kind: kind,
                path: path,
                name: name,
                sizeBytes: sizeBytes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String itemId,
                required String kind,
                required String path,
                Value<String?> name = const Value.absent(),
                Value<int?> sizeBytes = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => AttachmentsCompanion.insert(
                id: id,
                itemId: itemId,
                kind: kind,
                path: path,
                name: name,
                sizeBytes: sizeBytes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AttachmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttachmentsTable,
      AttachmentRow,
      $$AttachmentsTableFilterComposer,
      $$AttachmentsTableOrderingComposer,
      $$AttachmentsTableAnnotationComposer,
      $$AttachmentsTableCreateCompanionBuilder,
      $$AttachmentsTableUpdateCompanionBuilder,
      (
        AttachmentRow,
        BaseReferences<_$AppDatabase, $AttachmentsTable, AttachmentRow>,
      ),
      AttachmentRow,
      PrefetchHooks Function()
    >;
typedef $$ReviewsTableCreateCompanionBuilder =
    ReviewsCompanion Function({
      required String id,
      required ReviewType type,
      required DateTime startedAt,
      Value<DateTime?> completedAt,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$ReviewsTableUpdateCompanionBuilder =
    ReviewsCompanion Function({
      Value<String> id,
      Value<ReviewType> type,
      Value<DateTime> startedAt,
      Value<DateTime?> completedAt,
      Value<String?> notes,
      Value<int> rowid,
    });

class $$ReviewsTableFilterComposer
    extends Composer<_$AppDatabase, $ReviewsTable> {
  $$ReviewsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ReviewType, ReviewType, String> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReviewsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReviewsTable> {
  $$ReviewsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReviewsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReviewsTable> {
  $$ReviewsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ReviewType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$ReviewsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReviewsTable,
          ReviewRow,
          $$ReviewsTableFilterComposer,
          $$ReviewsTableOrderingComposer,
          $$ReviewsTableAnnotationComposer,
          $$ReviewsTableCreateCompanionBuilder,
          $$ReviewsTableUpdateCompanionBuilder,
          (ReviewRow, BaseReferences<_$AppDatabase, $ReviewsTable, ReviewRow>),
          ReviewRow,
          PrefetchHooks Function()
        > {
  $$ReviewsTableTableManager(_$AppDatabase db, $ReviewsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReviewsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReviewsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReviewsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<ReviewType> type = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReviewsCompanion(
                id: id,
                type: type,
                startedAt: startedAt,
                completedAt: completedAt,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required ReviewType type,
                required DateTime startedAt,
                Value<DateTime?> completedAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReviewsCompanion.insert(
                id: id,
                type: type,
                startedAt: startedAt,
                completedAt: completedAt,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReviewsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReviewsTable,
      ReviewRow,
      $$ReviewsTableFilterComposer,
      $$ReviewsTableOrderingComposer,
      $$ReviewsTableAnnotationComposer,
      $$ReviewsTableCreateCompanionBuilder,
      $$ReviewsTableUpdateCompanionBuilder,
      (ReviewRow, BaseReferences<_$AppDatabase, $ReviewsTable, ReviewRow>),
      ReviewRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ItemsTableTableManager get items =>
      $$ItemsTableTableManager(_db, _db.items);
  $$ProjectsTableTableManager get projects =>
      $$ProjectsTableTableManager(_db, _db.projects);
  $$ContextsTableTableManager get contexts =>
      $$ContextsTableTableManager(_db, _db.contexts);
  $$AreasTableTableManager get areas =>
      $$AreasTableTableManager(_db, _db.areas);
  $$AttachmentsTableTableManager get attachments =>
      $$AttachmentsTableTableManager(_db, _db.attachments);
  $$ReviewsTableTableManager get reviews =>
      $$ReviewsTableTableManager(_db, _db.reviews);
}
