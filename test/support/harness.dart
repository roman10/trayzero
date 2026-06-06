/// Shared test harness — collapses the per-test `_wrap()` / `setUp()`
/// boilerplate that was duplicated across every widget test.
///
/// One import gets you: an in-memory database, mocked SharedPreferences, a
/// [FakeClock], a [FixedIdGenerator], a [FakeNotificationScheduler], the
/// Riverpod overrides wiring them in, a `pumpApp()` helper, and entity
/// builders. The test doubles are re-exported here so callers need a single
/// `import '../support/harness.dart';` rather than chasing them across
/// `core/` and `support/fakes.dart`.
library;

import 'package:cleartray/application/providers.dart';
import 'package:cleartray/app/theme.dart';
import 'package:cleartray/core/calendar_gateway.dart';
import 'package:cleartray/core/clock.dart';
import 'package:cleartray/core/id_generator.dart';
import 'package:cleartray/core/notification_scheduler.dart';
import 'package:cleartray/core/system_settings.dart';
import 'package:cleartray/data/db/database.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:cleartray/features/settings/settings_controller.dart'
    show sharedPreferencesProvider;
import 'package:cleartray/l10n/gen/app_localizations.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes.dart';

export 'package:cleartray/core/clock.dart' show Clock, FakeClock;
export 'package:cleartray/core/id_generator.dart'
    show IdGenerator, FixedIdGenerator;

export 'fakes.dart'
    show FakeNotificationScheduler, FakeCalendarGateway, FakeSystemSettings;

/// A fully wired, in-memory test environment. Create one per test in
/// `setUp`, [dispose] it in `tearDown`.
///
/// ```dart
/// late TestEnv env;
/// setUp(() async => env = await TestEnv.create());
/// tearDown(() => env.dispose());
/// ```
class TestEnv {
  TestEnv._({
    required this.db,
    required this.prefs,
    required this.clock,
    required this.ids,
    required this.scheduler,
    required this.calendar,
    required this.systemSettings,
  });

  /// [now] fixes the [FakeClock]; [idQueue] seeds the [FixedIdGenerator];
  /// [prefsValues] seeds mock SharedPreferences.
  static Future<TestEnv> create({
    DateTime? now,
    List<String> idQueue = const [],
    Map<String, Object> prefsValues = const {},
  }) async {
    SharedPreferences.setMockInitialValues(prefsValues);
    return TestEnv._(
      db: AppDatabase.forTesting(NativeDatabase.memory()),
      prefs: await SharedPreferences.getInstance(),
      clock: FakeClock(now ?? DateTime(2026, 5, 14, 9)),
      ids: FixedIdGenerator(idQueue),
      scheduler: FakeNotificationScheduler(),
      calendar: FakeCalendarGateway(),
      systemSettings: FakeSystemSettings(),
    );
  }

  final AppDatabase db;
  final SharedPreferences prefs;
  final FakeClock clock;
  final FixedIdGenerator ids;
  final FakeNotificationScheduler scheduler;
  final FakeCalendarGateway calendar;
  final FakeSystemSettings systemSettings;

  /// The default provider overrides. Pass [extra] to add or replace any.
  List<Override> overrides([List<Override> extra = const []]) => [
        databaseProvider.overrideWithValue(db),
        sharedPreferencesProvider.overrideWithValue(prefs),
        clockProvider.overrideWithValue(clock),
        idGeneratorProvider.overrideWithValue(ids),
        notificationSchedulerProvider.overrideWithValue(scheduler),
        calendarGatewayProvider.overrideWithValue(calendar),
        systemSettingsProvider.overrideWithValue(systemSettings),
        ...extra,
      ];

  /// A standalone container (no widget tree) for use-case / provider tests.
  ProviderContainer container([List<Override> extra = const []]) {
    final c = ProviderContainer(overrides: overrides(extra));
    addTearDown(c.dispose);
    return c;
  }

  Future<void> dispose() async => db.close();
}

/// Pumps [child] inside a [MaterialApp] wired to [env]'s providers.
/// Pass [extraOverrides] to override additional providers for the test.
Future<void> pumpApp(
  WidgetTester tester,
  Widget child, {
  required TestEnv env,
  List<Override> extraOverrides = const [],
  ThemeData? theme,
}) async {
  final container = ProviderContainer(overrides: env.overrides(extraOverrides));
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: theme ?? AppTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    ),
  );
}

// ---- Entity builders --------------------------------------------------------

var _builderSeq = 0;

/// Builds an [Item] with sane defaults so tests only specify what matters.
Item anItem({
  String? id,
  String title = 'Test item',
  ItemStatus status = ItemStatus.inbox,
  String? notes,
  String? projectId,
  String? contextId,
  DateTime? dueAt,
  DateTime? deferUntil,
  String? waitingOn,
  bool isTwoMin = false,
  DateTime? completedAt,
  ItemStatus? previousStatus,
  Recurrence? recurrence,
  int recurrenceInterval = 1,
  DateTime? recurrenceUntil,
  int? recurrenceCount,
  int recurrenceDoneCount = 0,
  List<int> recurrenceByWeekdays = const [],
  int? recurrenceMonthlyWeek,
  int? recurrenceMonthlyWeekday,
  String? calendarEventId,
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  final ts = createdAt ?? DateTime(2026, 5, 14, 9);
  return Item(
    id: id ?? 'item-${_builderSeq++}',
    title: title,
    status: status,
    notes: notes,
    projectId: projectId,
    contextId: contextId,
    dueAt: dueAt,
    deferUntil: deferUntil,
    waitingOn: waitingOn,
    isTwoMin: isTwoMin,
    completedAt: completedAt,
    previousStatus: previousStatus,
    recurrence: recurrence,
    recurrenceInterval: recurrenceInterval,
    recurrenceUntil: recurrenceUntil,
    recurrenceCount: recurrenceCount,
    recurrenceDoneCount: recurrenceDoneCount,
    recurrenceByWeekdays: recurrenceByWeekdays,
    recurrenceMonthlyWeek: recurrenceMonthlyWeek,
    recurrenceMonthlyWeekday: recurrenceMonthlyWeekday,
    calendarEventId: calendarEventId,
    createdAt: ts,
    updatedAt: updatedAt ?? ts,
  );
}
