import '../core/clock.dart';
import '../core/id_generator.dart';
import '../domain/entities/entities.dart';
import 'repositories/context_repository.dart';
import 'repositories/item_repository.dart';
import 'repositories/project_repository.dart';

/// Seeds the default GTD contexts on first launch. Context display names are
/// passed in already localized so the seed matches the app's UI language.
Future<void> seedDefaultContextsIfEmpty(
  ContextRepository repo,
  IdGenerator ids, {
  required String phoneLabel,
  required String computerLabel,
  required String errandsLabel,
  required String homeLabel,
  required String officeLabel,
  required String anywhereLabel,
  required String waitingLabel,
}) async {
  final existing = await repo.all();
  if (existing.isNotEmpty) return;
  final defaults = <GtdContext>[
    GtdContext(
      id: ids.newId(),
      name: phoneLabel,
      icon: 'phone',
      color: 0xFF1E88E5,
      sortOrder: 0,
    ),
    GtdContext(
      id: ids.newId(),
      name: computerLabel,
      icon: 'computer',
      color: 0xFF6D4C41,
      sortOrder: 1,
    ),
    GtdContext(
      id: ids.newId(),
      name: errandsLabel,
      icon: 'shopping_bag',
      color: 0xFFE53935,
      sortOrder: 2,
    ),
    GtdContext(
      id: ids.newId(),
      name: homeLabel,
      icon: 'home',
      color: 0xFF43A047,
      sortOrder: 3,
    ),
    GtdContext(
      id: ids.newId(),
      name: officeLabel,
      icon: 'business_center',
      color: 0xFF8E24AA,
      sortOrder: 4,
    ),
    GtdContext(
      id: ids.newId(),
      name: anywhereLabel,
      icon: 'public',
      color: 0xFF00897B,
      sortOrder: 5,
    ),
    GtdContext(
      id: ids.newId(),
      name: waitingLabel,
      icon: 'hourglass_top',
      color: 0xFFFB8C00,
      sortOrder: 6,
    ),
  ];
  for (final c in defaults) {
    await repo.upsert(c);
  }
}

/// Optional sample data for first-run onboarding. All display strings are
/// passed in already localized. [computerLabel] must match the localized
/// name of the seeded "@computer" context so the sample actions attach to it.
Future<void> seedSampleProject({
  required ProjectRepository projects,
  required ItemRepository items,
  required ContextRepository contexts,
  required IdGenerator ids,
  required Clock clock,
  required String computerLabel,
  required String projectTitle,
  required String projectOutcome,
  required String readPrimerTitle,
  required String emptyEmailTitle,
  required String scheduleReviewTitle,
}) async {
  final now = clock.now();
  final ctxs = await contexts.all();
  // Prefer the localized @computer context, else any context; with none at
  // all (user deleted them) the sample actions are simply context-less.
  final computer =
      ctxs.where((c) => c.name == computerLabel).firstOrNull ??
      ctxs.firstOrNull;

  final projectId = ids.newId();
  await projects.upsert(
    Project(
      id: projectId,
      title: projectTitle,
      outcome: projectOutcome,
      status: ProjectStatus.active,
      createdAt: now,
      updatedAt: now,
    ),
  );

  await items.upsert(
    Item(
      id: ids.newId(),
      title: readPrimerTitle,
      status: ItemStatus.nextAction,
      projectId: projectId,
      contextId: computer?.id,
      energy: Energy.low,
      timeEstimateMinutes: 10,
      createdAt: now,
      updatedAt: now,
    ),
  );

  await items.upsert(
    Item(
      id: ids.newId(),
      title: emptyEmailTitle,
      status: ItemStatus.inbox,
      createdAt: now,
      updatedAt: now,
    ),
  );

  await items.upsert(
    Item(
      id: ids.newId(),
      title: scheduleReviewTitle,
      status: ItemStatus.nextAction,
      projectId: projectId,
      contextId: computer?.id,
      energy: Energy.low,
      timeEstimateMinutes: 5,
      createdAt: now,
      updatedAt: now,
    ),
  );
}
