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
  static const VerificationMeta _focusedAtMeta = const VerificationMeta(
    'focusedAt',
  );
  @override
  late final GeneratedColumn<DateTime> focusedAt = GeneratedColumn<DateTime>(
    'focused_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
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
    focusedAt,
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
    if (data.containsKey('focused_at')) {
      context.handle(
        _focusedAtMeta,
        focusedAt.isAcceptableOrUnknown(data['focused_at']!, _focusedAtMeta),
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
      focusedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}focused_at'],
      ),
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

  /// When the Item was committed to Today (ADR 0007). In Today while this
  /// falls on the current local day; an earlier day means carried over.
  final DateTime? focusedAt;
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
    this.focusedAt,
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
    if (!nullToAbsent || focusedAt != null) {
      map['focused_at'] = Variable<DateTime>(focusedAt);
    }
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
      focusedAt: focusedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(focusedAt),
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
      focusedAt: serializer.fromJson<DateTime?>(json['focusedAt']),
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
      'focusedAt': serializer.toJson<DateTime?>(focusedAt),
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
    Value<DateTime?> focusedAt = const Value.absent(),
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
    focusedAt: focusedAt.present ? focusedAt.value : this.focusedAt,
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
      focusedAt: data.focusedAt.present ? data.focusedAt.value : this.focusedAt,
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
          ..write('searchText: $searchText, ')
          ..write('focusedAt: $focusedAt')
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
    focusedAt,
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
          other.searchText == this.searchText &&
          other.focusedAt == this.focusedAt);
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
  final Value<DateTime?> focusedAt;
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
    this.focusedAt = const Value.absent(),
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
    this.focusedAt = const Value.absent(),
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
    Expression<DateTime>? focusedAt,
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
      if (focusedAt != null) 'focused_at': focusedAt,
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
    Value<DateTime?>? focusedAt,
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
      focusedAt: focusedAt ?? this.focusedAt,
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
    if (focusedAt.present) {
      map['focused_at'] = Variable<DateTime>(focusedAt.value);
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
          ..write('focusedAt: $focusedAt, ')
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
  static const VerificationMeta _lastReviewedAtMeta = const VerificationMeta(
    'lastReviewedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastReviewedAt =
      GeneratedColumn<DateTime>(
        'last_reviewed_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
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
    lastReviewedAt,
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
    if (data.containsKey('last_reviewed_at')) {
      context.handle(
        _lastReviewedAtMeta,
        lastReviewedAt.isAcceptableOrUnknown(
          data['last_reviewed_at']!,
          _lastReviewedAtMeta,
        ),
      );
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
      lastReviewedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_reviewed_at'],
      ),
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

  /// Last time the Project was marked reviewed in the Weekly Review.
  final DateTime? lastReviewedAt;
  const ProjectRow({
    required this.id,
    required this.title,
    this.outcome,
    this.areaId,
    required this.status,
    this.dueAt,
    required this.createdAt,
    required this.updatedAt,
    this.lastReviewedAt,
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
    if (!nullToAbsent || lastReviewedAt != null) {
      map['last_reviewed_at'] = Variable<DateTime>(lastReviewedAt);
    }
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
      lastReviewedAt: lastReviewedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReviewedAt),
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
      lastReviewedAt: serializer.fromJson<DateTime?>(json['lastReviewedAt']),
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
      'lastReviewedAt': serializer.toJson<DateTime?>(lastReviewedAt),
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
    Value<DateTime?> lastReviewedAt = const Value.absent(),
  }) => ProjectRow(
    id: id ?? this.id,
    title: title ?? this.title,
    outcome: outcome.present ? outcome.value : this.outcome,
    areaId: areaId.present ? areaId.value : this.areaId,
    status: status ?? this.status,
    dueAt: dueAt.present ? dueAt.value : this.dueAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    lastReviewedAt: lastReviewedAt.present
        ? lastReviewedAt.value
        : this.lastReviewedAt,
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
      lastReviewedAt: data.lastReviewedAt.present
          ? data.lastReviewedAt.value
          : this.lastReviewedAt,
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
          ..write('updatedAt: $updatedAt, ')
          ..write('lastReviewedAt: $lastReviewedAt')
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
    lastReviewedAt,
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
          other.updatedAt == this.updatedAt &&
          other.lastReviewedAt == this.lastReviewedAt);
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
  final Value<DateTime?> lastReviewedAt;
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
    this.lastReviewedAt = const Value.absent(),
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
    this.lastReviewedAt = const Value.absent(),
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
    Expression<DateTime>? lastReviewedAt,
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
      if (lastReviewedAt != null) 'last_reviewed_at': lastReviewedAt,
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
    Value<DateTime?>? lastReviewedAt,
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
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
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
    if (lastReviewedAt.present) {
      map['last_reviewed_at'] = Variable<DateTime>(lastReviewedAt.value);
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
          ..write('lastReviewedAt: $lastReviewedAt, ')
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
  static const VerificationMeta _currentStepMeta = const VerificationMeta(
    'currentStep',
  );
  @override
  late final GeneratedColumn<String> currentStep = GeneratedColumn<String>(
    'current_step',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('capture'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    startedAt,
    completedAt,
    notes,
    currentStep,
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
    if (data.containsKey('current_step')) {
      context.handle(
        _currentStepMeta,
        currentStep.isAcceptableOrUnknown(
          data['current_step']!,
          _currentStepMeta,
        ),
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
      currentStep: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}current_step'],
      )!,
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
  final String currentStep;
  const ReviewRow({
    required this.id,
    required this.type,
    required this.startedAt,
    this.completedAt,
    this.notes,
    required this.currentStep,
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
    map['current_step'] = Variable<String>(currentStep);
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
      currentStep: Value(currentStep),
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
      currentStep: serializer.fromJson<String>(json['currentStep']),
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
      'currentStep': serializer.toJson<String>(currentStep),
    };
  }

  ReviewRow copyWith({
    String? id,
    ReviewType? type,
    DateTime? startedAt,
    Value<DateTime?> completedAt = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    String? currentStep,
  }) => ReviewRow(
    id: id ?? this.id,
    type: type ?? this.type,
    startedAt: startedAt ?? this.startedAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    notes: notes.present ? notes.value : this.notes,
    currentStep: currentStep ?? this.currentStep,
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
      currentStep: data.currentStep.present
          ? data.currentStep.value
          : this.currentStep,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReviewRow(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('notes: $notes, ')
          ..write('currentStep: $currentStep')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, type, startedAt, completedAt, notes, currentStep);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReviewRow &&
          other.id == this.id &&
          other.type == this.type &&
          other.startedAt == this.startedAt &&
          other.completedAt == this.completedAt &&
          other.notes == this.notes &&
          other.currentStep == this.currentStep);
}

class ReviewsCompanion extends UpdateCompanion<ReviewRow> {
  final Value<String> id;
  final Value<ReviewType> type;
  final Value<DateTime> startedAt;
  final Value<DateTime?> completedAt;
  final Value<String?> notes;
  final Value<String> currentStep;
  final Value<int> rowid;
  const ReviewsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.currentStep = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReviewsCompanion.insert({
    required String id,
    required ReviewType type,
    required DateTime startedAt,
    this.completedAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.currentStep = const Value.absent(),
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
    Expression<String>? currentStep,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (notes != null) 'notes': notes,
      if (currentStep != null) 'current_step': currentStep,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReviewsCompanion copyWith({
    Value<String>? id,
    Value<ReviewType>? type,
    Value<DateTime>? startedAt,
    Value<DateTime?>? completedAt,
    Value<String?>? notes,
    Value<String>? currentStep,
    Value<int>? rowid,
  }) {
    return ReviewsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
      currentStep: currentStep ?? this.currentStep,
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
    if (currentStep.present) {
      map['current_step'] = Variable<String>(currentStep.value);
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
          ..write('currentStep: $currentStep, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CalendarMirrorsTable extends CalendarMirrors
    with TableInfo<$CalendarMirrorsTable, CalendarMirrorRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CalendarMirrorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _calendarIdMeta = const VerificationMeta(
    'calendarId',
  );
  @override
  late final GeneratedColumn<String> calendarId = GeneratedColumn<String>(
    'calendar_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
    'event_id',
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
  static const VerificationMeta _isCurrentMeta = const VerificationMeta(
    'isCurrent',
  );
  @override
  late final GeneratedColumn<bool> isCurrent = GeneratedColumn<bool>(
    'is_current',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_current" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    calendarId,
    eventId,
    itemId,
    isCurrent,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'calendar_mirrors';
  @override
  VerificationContext validateIntegrity(
    Insertable<CalendarMirrorRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('calendar_id')) {
      context.handle(
        _calendarIdMeta,
        calendarId.isAcceptableOrUnknown(data['calendar_id']!, _calendarIdMeta),
      );
    } else if (isInserting) {
      context.missing(_calendarIdMeta);
    }
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('is_current')) {
      context.handle(
        _isCurrentMeta,
        isCurrent.isAcceptableOrUnknown(data['is_current']!, _isCurrentMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {calendarId, eventId};
  @override
  CalendarMirrorRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CalendarMirrorRow(
      calendarId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}calendar_id'],
      )!,
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      isCurrent: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_current'],
      )!,
    );
  }

  @override
  $CalendarMirrorsTable createAlias(String alias) {
    return $CalendarMirrorsTable(attachedDatabase, alias);
  }
}

class CalendarMirrorRow extends DataClass
    implements Insertable<CalendarMirrorRow> {
  final String calendarId;
  final String eventId;
  final String itemId;
  final bool isCurrent;
  const CalendarMirrorRow({
    required this.calendarId,
    required this.eventId,
    required this.itemId,
    required this.isCurrent,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['calendar_id'] = Variable<String>(calendarId);
    map['event_id'] = Variable<String>(eventId);
    map['item_id'] = Variable<String>(itemId);
    map['is_current'] = Variable<bool>(isCurrent);
    return map;
  }

  CalendarMirrorsCompanion toCompanion(bool nullToAbsent) {
    return CalendarMirrorsCompanion(
      calendarId: Value(calendarId),
      eventId: Value(eventId),
      itemId: Value(itemId),
      isCurrent: Value(isCurrent),
    );
  }

  factory CalendarMirrorRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CalendarMirrorRow(
      calendarId: serializer.fromJson<String>(json['calendarId']),
      eventId: serializer.fromJson<String>(json['eventId']),
      itemId: serializer.fromJson<String>(json['itemId']),
      isCurrent: serializer.fromJson<bool>(json['isCurrent']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'calendarId': serializer.toJson<String>(calendarId),
      'eventId': serializer.toJson<String>(eventId),
      'itemId': serializer.toJson<String>(itemId),
      'isCurrent': serializer.toJson<bool>(isCurrent),
    };
  }

  CalendarMirrorRow copyWith({
    String? calendarId,
    String? eventId,
    String? itemId,
    bool? isCurrent,
  }) => CalendarMirrorRow(
    calendarId: calendarId ?? this.calendarId,
    eventId: eventId ?? this.eventId,
    itemId: itemId ?? this.itemId,
    isCurrent: isCurrent ?? this.isCurrent,
  );
  CalendarMirrorRow copyWithCompanion(CalendarMirrorsCompanion data) {
    return CalendarMirrorRow(
      calendarId: data.calendarId.present
          ? data.calendarId.value
          : this.calendarId,
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      isCurrent: data.isCurrent.present ? data.isCurrent.value : this.isCurrent,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CalendarMirrorRow(')
          ..write('calendarId: $calendarId, ')
          ..write('eventId: $eventId, ')
          ..write('itemId: $itemId, ')
          ..write('isCurrent: $isCurrent')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(calendarId, eventId, itemId, isCurrent);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CalendarMirrorRow &&
          other.calendarId == this.calendarId &&
          other.eventId == this.eventId &&
          other.itemId == this.itemId &&
          other.isCurrent == this.isCurrent);
}

class CalendarMirrorsCompanion extends UpdateCompanion<CalendarMirrorRow> {
  final Value<String> calendarId;
  final Value<String> eventId;
  final Value<String> itemId;
  final Value<bool> isCurrent;
  final Value<int> rowid;
  const CalendarMirrorsCompanion({
    this.calendarId = const Value.absent(),
    this.eventId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.isCurrent = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CalendarMirrorsCompanion.insert({
    required String calendarId,
    required String eventId,
    required String itemId,
    this.isCurrent = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : calendarId = Value(calendarId),
       eventId = Value(eventId),
       itemId = Value(itemId);
  static Insertable<CalendarMirrorRow> custom({
    Expression<String>? calendarId,
    Expression<String>? eventId,
    Expression<String>? itemId,
    Expression<bool>? isCurrent,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (calendarId != null) 'calendar_id': calendarId,
      if (eventId != null) 'event_id': eventId,
      if (itemId != null) 'item_id': itemId,
      if (isCurrent != null) 'is_current': isCurrent,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CalendarMirrorsCompanion copyWith({
    Value<String>? calendarId,
    Value<String>? eventId,
    Value<String>? itemId,
    Value<bool>? isCurrent,
    Value<int>? rowid,
  }) {
    return CalendarMirrorsCompanion(
      calendarId: calendarId ?? this.calendarId,
      eventId: eventId ?? this.eventId,
      itemId: itemId ?? this.itemId,
      isCurrent: isCurrent ?? this.isCurrent,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (calendarId.present) {
      map['calendar_id'] = Variable<String>(calendarId.value);
    }
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (isCurrent.present) {
      map['is_current'] = Variable<bool>(isCurrent.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CalendarMirrorsCompanion(')
          ..write('calendarId: $calendarId, ')
          ..write('eventId: $eventId, ')
          ..write('itemId: $itemId, ')
          ..write('isCurrent: $isCurrent, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, TagRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _isPersonMeta = const VerificationMeta(
    'isPerson',
  );
  @override
  late final GeneratedColumn<bool> isPerson = GeneratedColumn<bool>(
    'is_person',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_person" IN (0, 1))',
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
  @override
  List<GeneratedColumn> get $columns => [id, name, isPerson, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<TagRow> instance, {
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
    if (data.containsKey('is_person')) {
      context.handle(
        _isPersonMeta,
        isPerson.isAcceptableOrUnknown(data['is_person']!, _isPersonMeta),
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
  TagRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TagRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      isPerson: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_person'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }
}

class TagRow extends DataClass implements Insertable<TagRow> {
  final String id;
  final String name;

  /// A person: the tag also keeps an Agenda.
  final bool isPerson;
  final DateTime createdAt;
  const TagRow({
    required this.id,
    required this.name,
    required this.isPerson,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['is_person'] = Variable<bool>(isPerson);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(
      id: Value(id),
      name: Value(name),
      isPerson: Value(isPerson),
      createdAt: Value(createdAt),
    );
  }

  factory TagRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TagRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      isPerson: serializer.fromJson<bool>(json['isPerson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'isPerson': serializer.toJson<bool>(isPerson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  TagRow copyWith({
    String? id,
    String? name,
    bool? isPerson,
    DateTime? createdAt,
  }) => TagRow(
    id: id ?? this.id,
    name: name ?? this.name,
    isPerson: isPerson ?? this.isPerson,
    createdAt: createdAt ?? this.createdAt,
  );
  TagRow copyWithCompanion(TagsCompanion data) {
    return TagRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      isPerson: data.isPerson.present ? data.isPerson.value : this.isPerson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TagRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isPerson: $isPerson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, isPerson, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TagRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.isPerson == this.isPerson &&
          other.createdAt == this.createdAt);
}

class TagsCompanion extends UpdateCompanion<TagRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<bool> isPerson;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.isPerson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TagsCompanion.insert({
    required String id,
    required String name,
    this.isPerson = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<TagRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<bool>? isPerson,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (isPerson != null) 'is_person': isPerson,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TagsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<bool>? isPerson,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return TagsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      isPerson: isPerson ?? this.isPerson,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (isPerson.present) {
      map['is_person'] = Variable<bool>(isPerson.value);
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
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isPerson: $isPerson, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ItemTagsTable extends ItemTags
    with TableInfo<$ItemTagsTable, ItemTagRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES items (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<String> tagId = GeneratedColumn<String>(
    'tag_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tags (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [itemId, tagId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'item_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<ItemTagRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
        _tagIdMeta,
        tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {itemId, tagId};
  @override
  ItemTagRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ItemTagRow(
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      tagId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag_id'],
      )!,
    );
  }

  @override
  $ItemTagsTable createAlias(String alias) {
    return $ItemTagsTable(attachedDatabase, alias);
  }
}

class ItemTagRow extends DataClass implements Insertable<ItemTagRow> {
  final String itemId;
  final String tagId;
  const ItemTagRow({required this.itemId, required this.tagId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['item_id'] = Variable<String>(itemId);
    map['tag_id'] = Variable<String>(tagId);
    return map;
  }

  ItemTagsCompanion toCompanion(bool nullToAbsent) {
    return ItemTagsCompanion(itemId: Value(itemId), tagId: Value(tagId));
  }

  factory ItemTagRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ItemTagRow(
      itemId: serializer.fromJson<String>(json['itemId']),
      tagId: serializer.fromJson<String>(json['tagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'itemId': serializer.toJson<String>(itemId),
      'tagId': serializer.toJson<String>(tagId),
    };
  }

  ItemTagRow copyWith({String? itemId, String? tagId}) =>
      ItemTagRow(itemId: itemId ?? this.itemId, tagId: tagId ?? this.tagId);
  ItemTagRow copyWithCompanion(ItemTagsCompanion data) {
    return ItemTagRow(
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ItemTagRow(')
          ..write('itemId: $itemId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(itemId, tagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ItemTagRow &&
          other.itemId == this.itemId &&
          other.tagId == this.tagId);
}

class ItemTagsCompanion extends UpdateCompanion<ItemTagRow> {
  final Value<String> itemId;
  final Value<String> tagId;
  final Value<int> rowid;
  const ItemTagsCompanion({
    this.itemId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItemTagsCompanion.insert({
    required String itemId,
    required String tagId,
    this.rowid = const Value.absent(),
  }) : itemId = Value(itemId),
       tagId = Value(tagId);
  static Insertable<ItemTagRow> custom({
    Expression<String>? itemId,
    Expression<String>? tagId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (itemId != null) 'item_id': itemId,
      if (tagId != null) 'tag_id': tagId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItemTagsCompanion copyWith({
    Value<String>? itemId,
    Value<String>? tagId,
    Value<int>? rowid,
  }) {
    return ItemTagsCompanion(
      itemId: itemId ?? this.itemId,
      tagId: tagId ?? this.tagId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<String>(tagId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemTagsCompanion(')
          ..write('itemId: $itemId, ')
          ..write('tagId: $tagId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ImportBatchesTable extends ImportBatches
    with TableInfo<$ImportBatchesTable, ImportBatchRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImportBatchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fingerprintMeta = const VerificationMeta(
    'fingerprint',
  );
  @override
  late final GeneratedColumn<String> fingerprint = GeneratedColumn<String>(
    'fingerprint',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, fingerprint];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'import_batches';
  @override
  VerificationContext validateIntegrity(
    Insertable<ImportBatchRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('fingerprint')) {
      context.handle(
        _fingerprintMeta,
        fingerprint.isAcceptableOrUnknown(
          data['fingerprint']!,
          _fingerprintMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fingerprintMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ImportBatchRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImportBatchRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      fingerprint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fingerprint'],
      )!,
    );
  }

  @override
  $ImportBatchesTable createAlias(String alias) {
    return $ImportBatchesTable(attachedDatabase, alias);
  }
}

class ImportBatchRow extends DataClass implements Insertable<ImportBatchRow> {
  final String id;
  final String fingerprint;
  const ImportBatchRow({required this.id, required this.fingerprint});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['fingerprint'] = Variable<String>(fingerprint);
    return map;
  }

  ImportBatchesCompanion toCompanion(bool nullToAbsent) {
    return ImportBatchesCompanion(
      id: Value(id),
      fingerprint: Value(fingerprint),
    );
  }

  factory ImportBatchRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImportBatchRow(
      id: serializer.fromJson<String>(json['id']),
      fingerprint: serializer.fromJson<String>(json['fingerprint']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'fingerprint': serializer.toJson<String>(fingerprint),
    };
  }

  ImportBatchRow copyWith({String? id, String? fingerprint}) => ImportBatchRow(
    id: id ?? this.id,
    fingerprint: fingerprint ?? this.fingerprint,
  );
  ImportBatchRow copyWithCompanion(ImportBatchesCompanion data) {
    return ImportBatchRow(
      id: data.id.present ? data.id.value : this.id,
      fingerprint: data.fingerprint.present
          ? data.fingerprint.value
          : this.fingerprint,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImportBatchRow(')
          ..write('id: $id, ')
          ..write('fingerprint: $fingerprint')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, fingerprint);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImportBatchRow &&
          other.id == this.id &&
          other.fingerprint == this.fingerprint);
}

class ImportBatchesCompanion extends UpdateCompanion<ImportBatchRow> {
  final Value<String> id;
  final Value<String> fingerprint;
  final Value<int> rowid;
  const ImportBatchesCompanion({
    this.id = const Value.absent(),
    this.fingerprint = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ImportBatchesCompanion.insert({
    required String id,
    required String fingerprint,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       fingerprint = Value(fingerprint);
  static Insertable<ImportBatchRow> custom({
    Expression<String>? id,
    Expression<String>? fingerprint,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fingerprint != null) 'fingerprint': fingerprint,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ImportBatchesCompanion copyWith({
    Value<String>? id,
    Value<String>? fingerprint,
    Value<int>? rowid,
  }) {
    return ImportBatchesCompanion(
      id: id ?? this.id,
      fingerprint: fingerprint ?? this.fingerprint,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (fingerprint.present) {
      map['fingerprint'] = Variable<String>(fingerprint.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImportBatchesCompanion(')
          ..write('id: $id, ')
          ..write('fingerprint: $fingerprint, ')
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
  late final $CalendarMirrorsTable calendarMirrors = $CalendarMirrorsTable(
    this,
  );
  late final $TagsTable tags = $TagsTable(this);
  late final $ItemTagsTable itemTags = $ItemTagsTable(this);
  late final $ImportBatchesTable importBatches = $ImportBatchesTable(this);
  late final Index itemTagsTagId = Index(
    'item_tags_tag_id',
    'CREATE INDEX item_tags_tag_id ON item_tags (tag_id)',
  );
  late final Index importBatchesFingerprint = Index(
    'import_batches_fingerprint',
    'CREATE INDEX import_batches_fingerprint ON import_batches (fingerprint)',
  );
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
    calendarMirrors,
    tags,
    itemTags,
    importBatches,
    itemTagsTagId,
    importBatchesFingerprint,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'items',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('item_tags', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tags',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('item_tags', kind: UpdateKind.delete)],
    ),
  ]);
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
      Value<DateTime?> focusedAt,
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
      Value<DateTime?> focusedAt,
      Value<int> rowid,
    });

final class $$ItemsTableReferences
    extends BaseReferences<_$AppDatabase, $ItemsTable, ItemRow> {
  $$ItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ItemTagsTable, List<ItemTagRow>>
  _itemTagsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.itemTags,
    aliasName: $_aliasNameGenerator(db.items.id, db.itemTags.itemId),
  );

  $$ItemTagsTableProcessedTableManager get itemTagsRefs {
    final manager = $$ItemTagsTableTableManager(
      $_db,
      $_db.itemTags,
    ).filter((f) => f.itemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_itemTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

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

  ColumnFilters<DateTime> get focusedAt => $composableBuilder(
    column: $table.focusedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> itemTagsRefs(
    Expression<bool> Function($$ItemTagsTableFilterComposer f) f,
  ) {
    final $$ItemTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.itemTags,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemTagsTableFilterComposer(
            $db: $db,
            $table: $db.itemTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
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

  ColumnOrderings<DateTime> get focusedAt => $composableBuilder(
    column: $table.focusedAt,
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

  GeneratedColumn<DateTime> get focusedAt =>
      $composableBuilder(column: $table.focusedAt, builder: (column) => column);

  Expression<T> itemTagsRefs<T extends Object>(
    Expression<T> Function($$ItemTagsTableAnnotationComposer a) f,
  ) {
    final $$ItemTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.itemTags,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.itemTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
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
          (ItemRow, $$ItemsTableReferences),
          ItemRow,
          PrefetchHooks Function({bool itemTagsRefs})
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
                Value<DateTime?> focusedAt = const Value.absent(),
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
                focusedAt: focusedAt,
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
                Value<DateTime?> focusedAt = const Value.absent(),
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
                focusedAt: focusedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$ItemsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({itemTagsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (itemTagsRefs) db.itemTags],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (itemTagsRefs)
                    await $_getPrefetchedData<ItemRow, $ItemsTable, ItemTagRow>(
                      currentTable: table,
                      referencedTable: $$ItemsTableReferences
                          ._itemTagsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ItemsTableReferences(db, table, p0).itemTagsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.itemId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
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
      (ItemRow, $$ItemsTableReferences),
      ItemRow,
      PrefetchHooks Function({bool itemTagsRefs})
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
      Value<DateTime?> lastReviewedAt,
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
      Value<DateTime?> lastReviewedAt,
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

  ColumnFilters<DateTime> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
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

  ColumnOrderings<DateTime> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
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

  GeneratedColumn<DateTime> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => column,
  );
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
                Value<DateTime?> lastReviewedAt = const Value.absent(),
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
                lastReviewedAt: lastReviewedAt,
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
                Value<DateTime?> lastReviewedAt = const Value.absent(),
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
                lastReviewedAt: lastReviewedAt,
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
      Value<String> currentStep,
      Value<int> rowid,
    });
typedef $$ReviewsTableUpdateCompanionBuilder =
    ReviewsCompanion Function({
      Value<String> id,
      Value<ReviewType> type,
      Value<DateTime> startedAt,
      Value<DateTime?> completedAt,
      Value<String?> notes,
      Value<String> currentStep,
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

  ColumnFilters<String> get currentStep => $composableBuilder(
    column: $table.currentStep,
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

  ColumnOrderings<String> get currentStep => $composableBuilder(
    column: $table.currentStep,
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

  GeneratedColumn<String> get currentStep => $composableBuilder(
    column: $table.currentStep,
    builder: (column) => column,
  );
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
                Value<String> currentStep = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReviewsCompanion(
                id: id,
                type: type,
                startedAt: startedAt,
                completedAt: completedAt,
                notes: notes,
                currentStep: currentStep,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required ReviewType type,
                required DateTime startedAt,
                Value<DateTime?> completedAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> currentStep = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReviewsCompanion.insert(
                id: id,
                type: type,
                startedAt: startedAt,
                completedAt: completedAt,
                notes: notes,
                currentStep: currentStep,
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
typedef $$CalendarMirrorsTableCreateCompanionBuilder =
    CalendarMirrorsCompanion Function({
      required String calendarId,
      required String eventId,
      required String itemId,
      Value<bool> isCurrent,
      Value<int> rowid,
    });
typedef $$CalendarMirrorsTableUpdateCompanionBuilder =
    CalendarMirrorsCompanion Function({
      Value<String> calendarId,
      Value<String> eventId,
      Value<String> itemId,
      Value<bool> isCurrent,
      Value<int> rowid,
    });

class $$CalendarMirrorsTableFilterComposer
    extends Composer<_$AppDatabase, $CalendarMirrorsTable> {
  $$CalendarMirrorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get calendarId => $composableBuilder(
    column: $table.calendarId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCurrent => $composableBuilder(
    column: $table.isCurrent,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CalendarMirrorsTableOrderingComposer
    extends Composer<_$AppDatabase, $CalendarMirrorsTable> {
  $$CalendarMirrorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get calendarId => $composableBuilder(
    column: $table.calendarId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCurrent => $composableBuilder(
    column: $table.isCurrent,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CalendarMirrorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CalendarMirrorsTable> {
  $$CalendarMirrorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get calendarId => $composableBuilder(
    column: $table.calendarId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get eventId =>
      $composableBuilder(column: $table.eventId, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<bool> get isCurrent =>
      $composableBuilder(column: $table.isCurrent, builder: (column) => column);
}

class $$CalendarMirrorsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CalendarMirrorsTable,
          CalendarMirrorRow,
          $$CalendarMirrorsTableFilterComposer,
          $$CalendarMirrorsTableOrderingComposer,
          $$CalendarMirrorsTableAnnotationComposer,
          $$CalendarMirrorsTableCreateCompanionBuilder,
          $$CalendarMirrorsTableUpdateCompanionBuilder,
          (
            CalendarMirrorRow,
            BaseReferences<
              _$AppDatabase,
              $CalendarMirrorsTable,
              CalendarMirrorRow
            >,
          ),
          CalendarMirrorRow,
          PrefetchHooks Function()
        > {
  $$CalendarMirrorsTableTableManager(
    _$AppDatabase db,
    $CalendarMirrorsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CalendarMirrorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CalendarMirrorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CalendarMirrorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> calendarId = const Value.absent(),
                Value<String> eventId = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<bool> isCurrent = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CalendarMirrorsCompanion(
                calendarId: calendarId,
                eventId: eventId,
                itemId: itemId,
                isCurrent: isCurrent,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String calendarId,
                required String eventId,
                required String itemId,
                Value<bool> isCurrent = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CalendarMirrorsCompanion.insert(
                calendarId: calendarId,
                eventId: eventId,
                itemId: itemId,
                isCurrent: isCurrent,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CalendarMirrorsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CalendarMirrorsTable,
      CalendarMirrorRow,
      $$CalendarMirrorsTableFilterComposer,
      $$CalendarMirrorsTableOrderingComposer,
      $$CalendarMirrorsTableAnnotationComposer,
      $$CalendarMirrorsTableCreateCompanionBuilder,
      $$CalendarMirrorsTableUpdateCompanionBuilder,
      (
        CalendarMirrorRow,
        BaseReferences<_$AppDatabase, $CalendarMirrorsTable, CalendarMirrorRow>,
      ),
      CalendarMirrorRow,
      PrefetchHooks Function()
    >;
typedef $$TagsTableCreateCompanionBuilder =
    TagsCompanion Function({
      required String id,
      required String name,
      Value<bool> isPerson,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$TagsTableUpdateCompanionBuilder =
    TagsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<bool> isPerson,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$TagsTableReferences
    extends BaseReferences<_$AppDatabase, $TagsTable, TagRow> {
  $$TagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ItemTagsTable, List<ItemTagRow>>
  _itemTagsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.itemTags,
    aliasName: $_aliasNameGenerator(db.tags.id, db.itemTags.tagId),
  );

  $$ItemTagsTableProcessedTableManager get itemTagsRefs {
    final manager = $$ItemTagsTableTableManager(
      $_db,
      $_db.itemTags,
    ).filter((f) => f.tagId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_itemTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TagsTableFilterComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableFilterComposer({
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

  ColumnFilters<bool> get isPerson => $composableBuilder(
    column: $table.isPerson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> itemTagsRefs(
    Expression<bool> Function($$ItemTagsTableFilterComposer f) f,
  ) {
    final $$ItemTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.itemTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemTagsTableFilterComposer(
            $db: $db,
            $table: $db.itemTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableOrderingComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableOrderingComposer({
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

  ColumnOrderings<bool> get isPerson => $composableBuilder(
    column: $table.isPerson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableAnnotationComposer({
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

  GeneratedColumn<bool> get isPerson =>
      $composableBuilder(column: $table.isPerson, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> itemTagsRefs<T extends Object>(
    Expression<T> Function($$ItemTagsTableAnnotationComposer a) f,
  ) {
    final $$ItemTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.itemTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.itemTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TagsTable,
          TagRow,
          $$TagsTableFilterComposer,
          $$TagsTableOrderingComposer,
          $$TagsTableAnnotationComposer,
          $$TagsTableCreateCompanionBuilder,
          $$TagsTableUpdateCompanionBuilder,
          (TagRow, $$TagsTableReferences),
          TagRow,
          PrefetchHooks Function({bool itemTagsRefs})
        > {
  $$TagsTableTableManager(_$AppDatabase db, $TagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<bool> isPerson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TagsCompanion(
                id: id,
                name: name,
                isPerson: isPerson,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<bool> isPerson = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => TagsCompanion.insert(
                id: id,
                name: name,
                isPerson: isPerson,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$TagsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({itemTagsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (itemTagsRefs) db.itemTags],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (itemTagsRefs)
                    await $_getPrefetchedData<TagRow, $TagsTable, ItemTagRow>(
                      currentTable: table,
                      referencedTable: $$TagsTableReferences._itemTagsRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$TagsTableReferences(db, table, p0).itemTagsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.tagId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TagsTable,
      TagRow,
      $$TagsTableFilterComposer,
      $$TagsTableOrderingComposer,
      $$TagsTableAnnotationComposer,
      $$TagsTableCreateCompanionBuilder,
      $$TagsTableUpdateCompanionBuilder,
      (TagRow, $$TagsTableReferences),
      TagRow,
      PrefetchHooks Function({bool itemTagsRefs})
    >;
typedef $$ItemTagsTableCreateCompanionBuilder =
    ItemTagsCompanion Function({
      required String itemId,
      required String tagId,
      Value<int> rowid,
    });
typedef $$ItemTagsTableUpdateCompanionBuilder =
    ItemTagsCompanion Function({
      Value<String> itemId,
      Value<String> tagId,
      Value<int> rowid,
    });

final class $$ItemTagsTableReferences
    extends BaseReferences<_$AppDatabase, $ItemTagsTable, ItemTagRow> {
  $$ItemTagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ItemsTable _itemIdTable(_$AppDatabase db) => db.items.createAlias(
    $_aliasNameGenerator(db.itemTags.itemId, db.items.id),
  );

  $$ItemsTableProcessedTableManager get itemId {
    final $_column = $_itemColumn<String>('item_id')!;

    final manager = $$ItemsTableTableManager(
      $_db,
      $_db.items,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_itemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TagsTable _tagIdTable(_$AppDatabase db) =>
      db.tags.createAlias($_aliasNameGenerator(db.itemTags.tagId, db.tags.id));

  $$TagsTableProcessedTableManager get tagId {
    final $_column = $_itemColumn<String>('tag_id')!;

    final manager = $$TagsTableTableManager(
      $_db,
      $_db.tags,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tagIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ItemTagsTableFilterComposer
    extends Composer<_$AppDatabase, $ItemTagsTable> {
  $$ItemTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$ItemsTableFilterComposer get itemId {
    final $$ItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableFilterComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableFilterComposer get tagId {
    final $$TagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableFilterComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ItemTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $ItemTagsTable> {
  $$ItemTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$ItemsTableOrderingComposer get itemId {
    final $$ItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableOrderingComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableOrderingComposer get tagId {
    final $$TagsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableOrderingComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ItemTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ItemTagsTable> {
  $$ItemTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$ItemsTableAnnotationComposer get itemId {
    final $$ItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableAnnotationComposer get tagId {
    final $$TagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableAnnotationComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ItemTagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ItemTagsTable,
          ItemTagRow,
          $$ItemTagsTableFilterComposer,
          $$ItemTagsTableOrderingComposer,
          $$ItemTagsTableAnnotationComposer,
          $$ItemTagsTableCreateCompanionBuilder,
          $$ItemTagsTableUpdateCompanionBuilder,
          (ItemTagRow, $$ItemTagsTableReferences),
          ItemTagRow,
          PrefetchHooks Function({bool itemId, bool tagId})
        > {
  $$ItemTagsTableTableManager(_$AppDatabase db, $ItemTagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItemTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItemTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItemTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> itemId = const Value.absent(),
                Value<String> tagId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) =>
                  ItemTagsCompanion(itemId: itemId, tagId: tagId, rowid: rowid),
          createCompanionCallback:
              ({
                required String itemId,
                required String tagId,
                Value<int> rowid = const Value.absent(),
              }) => ItemTagsCompanion.insert(
                itemId: itemId,
                tagId: tagId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ItemTagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({itemId = false, tagId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (itemId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.itemId,
                                referencedTable: $$ItemTagsTableReferences
                                    ._itemIdTable(db),
                                referencedColumn: $$ItemTagsTableReferences
                                    ._itemIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (tagId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.tagId,
                                referencedTable: $$ItemTagsTableReferences
                                    ._tagIdTable(db),
                                referencedColumn: $$ItemTagsTableReferences
                                    ._tagIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ItemTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ItemTagsTable,
      ItemTagRow,
      $$ItemTagsTableFilterComposer,
      $$ItemTagsTableOrderingComposer,
      $$ItemTagsTableAnnotationComposer,
      $$ItemTagsTableCreateCompanionBuilder,
      $$ItemTagsTableUpdateCompanionBuilder,
      (ItemTagRow, $$ItemTagsTableReferences),
      ItemTagRow,
      PrefetchHooks Function({bool itemId, bool tagId})
    >;
typedef $$ImportBatchesTableCreateCompanionBuilder =
    ImportBatchesCompanion Function({
      required String id,
      required String fingerprint,
      Value<int> rowid,
    });
typedef $$ImportBatchesTableUpdateCompanionBuilder =
    ImportBatchesCompanion Function({
      Value<String> id,
      Value<String> fingerprint,
      Value<int> rowid,
    });

class $$ImportBatchesTableFilterComposer
    extends Composer<_$AppDatabase, $ImportBatchesTable> {
  $$ImportBatchesTableFilterComposer({
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

  ColumnFilters<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ImportBatchesTableOrderingComposer
    extends Composer<_$AppDatabase, $ImportBatchesTable> {
  $$ImportBatchesTableOrderingComposer({
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

  ColumnOrderings<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ImportBatchesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ImportBatchesTable> {
  $$ImportBatchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => column,
  );
}

class $$ImportBatchesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ImportBatchesTable,
          ImportBatchRow,
          $$ImportBatchesTableFilterComposer,
          $$ImportBatchesTableOrderingComposer,
          $$ImportBatchesTableAnnotationComposer,
          $$ImportBatchesTableCreateCompanionBuilder,
          $$ImportBatchesTableUpdateCompanionBuilder,
          (
            ImportBatchRow,
            BaseReferences<_$AppDatabase, $ImportBatchesTable, ImportBatchRow>,
          ),
          ImportBatchRow,
          PrefetchHooks Function()
        > {
  $$ImportBatchesTableTableManager(_$AppDatabase db, $ImportBatchesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImportBatchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImportBatchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImportBatchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> fingerprint = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ImportBatchesCompanion(
                id: id,
                fingerprint: fingerprint,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String fingerprint,
                Value<int> rowid = const Value.absent(),
              }) => ImportBatchesCompanion.insert(
                id: id,
                fingerprint: fingerprint,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ImportBatchesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ImportBatchesTable,
      ImportBatchRow,
      $$ImportBatchesTableFilterComposer,
      $$ImportBatchesTableOrderingComposer,
      $$ImportBatchesTableAnnotationComposer,
      $$ImportBatchesTableCreateCompanionBuilder,
      $$ImportBatchesTableUpdateCompanionBuilder,
      (
        ImportBatchRow,
        BaseReferences<_$AppDatabase, $ImportBatchesTable, ImportBatchRow>,
      ),
      ImportBatchRow,
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
  $$CalendarMirrorsTableTableManager get calendarMirrors =>
      $$CalendarMirrorsTableTableManager(_db, _db.calendarMirrors);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$ItemTagsTableTableManager get itemTags =>
      $$ItemTagsTableTableManager(_db, _db.itemTags);
  $$ImportBatchesTableTableManager get importBatches =>
      $$ImportBatchesTableTableManager(_db, _db.importBatches);
}
