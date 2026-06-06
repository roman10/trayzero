import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/clock.dart';
import '../core/id_generator.dart' show idGeneratorProvider;
import 'db/database.dart';
import 'repositories/area_repository.dart';
import 'repositories/attachment_repository.dart';
import 'repositories/context_repository.dart';
import 'repositories/item_repository.dart';
import 'repositories/project_repository.dart';
import 'repositories/review_repository.dart';

/// Database + repository wiring. Owned by the data layer; consumed by the
/// application layer (and, via the application facade, by features).
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final itemRepositoryProvider = Provider<ItemRepository>((ref) => ItemRepository(
      ref.watch(databaseProvider),
      ref.watch(clockProvider),
    ));

final projectRepositoryProvider = Provider<ProjectRepository>(
    (ref) => ProjectRepository(ref.watch(databaseProvider)));

final contextRepositoryProvider = Provider<ContextRepository>(
    (ref) => ContextRepository(ref.watch(databaseProvider)));

final reviewRepositoryProvider = Provider<ReviewRepository>(
    (ref) => ReviewRepository(ref.watch(databaseProvider)));

final areaRepositoryProvider = Provider<AreaRepository>(
    (ref) => AreaRepository(ref.watch(databaseProvider)));

final attachmentRepositoryProvider =
    Provider<AttachmentRepository>((ref) => AttachmentRepository(
          ref.watch(databaseProvider),
          ref.watch(clockProvider),
          ref.watch(idGeneratorProvider),
        ));
