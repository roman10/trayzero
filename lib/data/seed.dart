import '../core/clock.dart';
import '../core/id_generator.dart';
import '../domain/entities/entities.dart';
import 'repositories/context_repository.dart';
import 'repositories/item_repository.dart';
import 'repositories/project_repository.dart';

/// Seeds the default GTD contexts on first launch.
Future<void> seedDefaultContextsIfEmpty(
  ContextRepository repo,
  IdGenerator ids,
) async {
  final existing = await repo.all();
  if (existing.isNotEmpty) return;
  final defaults = <GtdContext>[
    GtdContext(
      id: ids.newId(),
      name: '@phone',
      icon: 'phone',
      color: 0xFF1E88E5,
      sortOrder: 0,
    ),
    GtdContext(
      id: ids.newId(),
      name: '@computer',
      icon: 'computer',
      color: 0xFF6D4C41,
      sortOrder: 1,
    ),
    GtdContext(
      id: ids.newId(),
      name: '@errands',
      icon: 'shopping_bag',
      color: 0xFFE53935,
      sortOrder: 2,
    ),
    GtdContext(
      id: ids.newId(),
      name: '@home',
      icon: 'home',
      color: 0xFF43A047,
      sortOrder: 3,
    ),
    GtdContext(
      id: ids.newId(),
      name: '@office',
      icon: 'business_center',
      color: 0xFF8E24AA,
      sortOrder: 4,
    ),
    GtdContext(
      id: ids.newId(),
      name: '@anywhere',
      icon: 'public',
      color: 0xFF00897B,
      sortOrder: 5,
    ),
    GtdContext(
      id: ids.newId(),
      name: '@waiting',
      icon: 'hourglass_top',
      color: 0xFFFB8C00,
      sortOrder: 6,
    ),
  ];
  for (final c in defaults) {
    await repo.upsert(c);
  }
}

/// Optional sample data for first-run onboarding.
Future<void> seedSampleProject({
  required ProjectRepository projects,
  required ItemRepository items,
  required ContextRepository contexts,
  required IdGenerator ids,
  required Clock clock,
}) async {
  final now = clock.now();
  final ctxs = await contexts.all();
  final computer = ctxs.firstWhere(
    (c) => c.name == '@computer',
    orElse: () => ctxs.first,
  );

  final projectId = ids.newId();
  await projects.upsert(
    Project(
      id: projectId,
      title: 'Get the most out of GTD',
      outcome:
          'Capture inbox to zero daily and run a Weekly Review every Friday.',
      status: ProjectStatus.active,
      createdAt: now,
      updatedAt: now,
    ),
  );

  await items.upsert(
    Item(
      id: ids.newId(),
      title: 'Read the GTD primer in Settings',
      status: ItemStatus.nextAction,
      projectId: projectId,
      contextId: computer.id,
      energy: Energy.low,
      timeEstimateMinutes: 10,
      createdAt: now,
      updatedAt: now,
    ),
  );

  await items.upsert(
    Item(
      id: ids.newId(),
      title: 'Empty my email inbox into here',
      status: ItemStatus.inbox,
      createdAt: now,
      updatedAt: now,
    ),
  );

  await items.upsert(
    Item(
      id: ids.newId(),
      title: 'Schedule a recurring Friday Weekly Review',
      status: ItemStatus.nextAction,
      projectId: projectId,
      contextId: computer.id,
      energy: Energy.low,
      timeEstimateMinutes: 5,
      createdAt: now,
      updatedAt: now,
    ),
  );
}
