import 'package:cleartray/domain/entities/entities.dart';
import 'package:cleartray/domain/import/import_plan.dart';
import 'package:cleartray/domain/import/import_resolution.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 10, 26, 10);
  var counter = 0;
  String newId() => 'id-${counter++}';
  setUp(() => counter = 0);

  const phone = GtdContext(
    id: 'c-phone',
    name: '@Phone',
    icon: 'phone',
    color: 0,
    sortOrder: 3,
  );
  final garage = Project(
    id: 'p-garage',
    title: 'Clean  the Garage',
    status: ProjectStatus.someday,
    createdAt: now,
    updatedAt: now,
  );

  ResolvedImport resolve(
    List<ImportedItem> items, {
    List<ImportedProject> projects = const [],
    Map<ImportWarning, int> warnings = const {},
  }) => resolveImport(
    ImportPlan(
      source: ImportSourceApp.todoist,
      projects: projects,
      items: items,
      warnings: warnings,
    ),
    existingContexts: const [phone],
    existingProjects: [garage],
    newId: newId,
    now: now,
  );

  test('projects merge case- and whitespace-insensitively', () {
    final r = resolve(
      [
        const ImportedItem(title: 'Sweep', project: 'clean the garage'),
        const ImportedItem(title: 'Paint', project: 'Kitchen'),
      ],
      projects: const [
        ImportedProject(title: 'clean the garage'),
        ImportedProject(title: 'Kitchen', outcome: 'Fresh walls'),
      ],
    );
    expect(r.newProjects.map((p) => (p.title, p.outcome)), [
      ('Kitchen', 'Fresh walls'),
    ]);
    expect(r.items.first.projectId, 'p-garage');
    expect(r.items.last.projectId, r.newProjects.single.id);
    expect(r.preview.projects, [
      (title: 'Kitchen', actions: 1, isNew: true),
      (title: 'Clean  the Garage', actions: 1, isNew: false),
    ]);
  });

  test('context rules: @-written, existing, or common word; one per item', () {
    final r = resolve(const [
      ImportedItem(title: 'A', tags: ['phone', 'urgent']),
      ImportedItem(title: 'B', tags: ['@Garten']),
      ImportedItem(title: 'C', tags: ['errands', '@garten', 'phone']),
      ImportedItem(title: 'D', tags: ['GARTEN']),
    ]);
    final [a, b, c, d] = r.items;
    String tagNames(Item i) => [
      for (final id in r.itemTagIds[i.id] ?? const <String>[])
        r.newTags.firstWhere((t) => t.id == id).name,
    ].join(', ');
    expect(a.contextId, 'c-phone');
    expect(a.notes, isNull);
    expect(tagNames(a), 'urgent');
    expect(r.newContexts.map((c) => c.name), ['@Garten', '@errands']);
    expect(r.newContexts.map((c) => c.sortOrder), [4, 5]);
    expect(b.contextId, r.newContexts.first.id);
    expect(c.contextId, r.newContexts.last.id);
    expect(c.notes, isNull);
    expect(tagNames(c), 'garten, phone');
    // Not a context word and not written with @, even though a new context
    // of that name exists only because of this import's earlier row.
    // Its tag merges with "@garten" above, ignoring case.
    expect(d.contextId, isNull);
    expect(tagNames(d), 'garten');
    expect(r.newTags.map((t) => t.name), ['urgent', 'garten', 'phone']);
    expect(r.newTags.any((t) => t.isPerson), isFalse);
    expect(r.preview.newContexts, ['@Garten', '@errands']);
    expect(r.preview.existingContexts, ['@Phone']);
  });

  test('agenda tags become people; existing tags are reused', () {
    counter = 0;
    final r = resolveImport(
      const ImportPlan(
        source: ImportSourceApp.omniFocus,
        projects: [],
        items: [
          ImportedItem(title: 'Budget', tags: ['Agendas : Alice', 'Kitchen']),
          ImportedItem(title: 'Drill', tags: ['agenda/alice', '@agenda-Bob']),
          ImportedItem(title: 'Plain', tags: ['Agenda']),
        ],
        warnings: {},
      ),
      existingContexts: const [phone],
      existingProjects: [garage],
      existingTags: const [Tag(id: 't-kitchen', name: 'kitchen')],
      newId: newId,
      now: now,
    );
    final [budget, drill, plain] = r.items;
    expect(budget.contextId, isNull);
    expect(
      r.newTags.map((t) => (t.name, t.isPerson)),
      [('Alice', true), ('Bob', true)],
    );
    final alice = r.newTags.first.id;
    expect(r.itemTagIds[budget.id], [alice, 't-kitchen']);
    expect(r.itemTagIds[drill.id], [alice, r.newTags[1].id]);
    // A bare "Agenda" names no one: it stays the usual context.
    expect(plain.contextId, r.newContexts.single.id);
    expect(r.itemTagIds[plain.id], isNull);
    expect(r.existingTagsUsed.map((t) => t.id), ['t-kitchen']);
    expect(r.preview.newTags, ['Alice', 'Bob']);
    expect(r.preview.existingTags, ['kitchen']);
  });

  test('dated next actions land in Calendar; date-only due gets the hour', () {
    final r = resolve([
      ImportedItem(title: 'Due', dueAt: DateTime(2026, 11, 3)),
      ImportedItem(title: 'Timed', dueAt: DateTime(2026, 11, 3, 15, 30)),
      ImportedItem(
        title: 'Inbox due',
        status: ItemStatus.inbox,
        dueAt: DateTime(2026, 11, 3),
      ),
      ImportedItem(title: 'Start', deferUntil: DateTime(2026, 11, 3)),
    ]);
    final [due, timed, inbox, start] = r.items;
    expect((due.status, due.dueAt), (ItemStatus.calendar, DateTime(2026, 11, 3, 9)));
    expect(timed.dueAt, DateTime(2026, 11, 3, 15, 30));
    expect(inbox.status, ItemStatus.inbox);
    expect(start.status, ItemStatus.nextAction);
    expect(r.warnings[ImportWarning.datedToCalendar], 2);
    expect(r.preview.byStatus, {
      ItemStatus.calendar: 2,
      ItemStatus.inbox: 1,
      ItemStatus.nextAction: 1,
    });
  });

  test('repeats need a date; source order is kept', () {
    final r = resolve(
      [
        ImportedItem(
          title: 'First',
          project: 'Kitchen',
          deferUntil: DateTime(2026, 11, 2),
          repeat: const ImportedRepeat(
            frequency: Recurrence.weekly,
            interval: 2,
            byWeekdays: [1],
          ),
        ),
        const ImportedItem(
          title: 'Second',
          project: 'Kitchen',
          repeat: ImportedRepeat(frequency: Recurrence.daily),
        ),
      ],
      projects: const [ImportedProject(title: 'Kitchen')],
    );
    final [first, second] = r.items;
    expect(first.recurrence, Recurrence.weekly);
    expect(first.recurrenceInterval, 2);
    expect(first.recurrenceByWeekdays, [1]);
    expect(second.recurrence, isNull);
    expect((first.projectSortOrder, second.projectSortOrder), (0, 1));
    expect(first.createdAt.isAfter(second.createdAt), isTrue);
  });

  test('plan warnings carry through', () {
    final r = resolve(
      const [ImportedItem(title: 'x')],
      warnings: const {ImportWarning.completedSkipped: 4},
    );
    expect(r.preview.warnings, {ImportWarning.completedSkipped: 4});
    expect(r.preview.total, 1);
  });
}
