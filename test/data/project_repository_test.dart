import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cleartray/data/db/database.dart';
import 'package:cleartray/data/repositories/project_repository.dart';
import 'package:cleartray/domain/entities/entities.dart';

void main() {
  late AppDatabase db;
  late ProjectRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = ProjectRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  Project project(
    String id, {
    String title = 'Project',
    ProjectStatus status = ProjectStatus.active,
    String? areaId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final now = DateTime(2026, 5, 14, 9);
    return Project(
      id: id,
      title: title,
      status: status,
      areaId: areaId,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
    );
  }

  test('upserting a project makes it visible to watchAll', () async {
    await repo.upsert(project('a', title: 'Launch website'));
    final all = await repo.watchAll().first;
    expect(all.length, 1);
    expect(all.single.title, 'Launch website');
  });

  test('upsert with an existing id updates rather than duplicates', () async {
    await repo.upsert(project('a', title: 'Original'));
    await repo.upsert(project('a', title: 'Renamed'));
    final all = await repo.watchAll().first;
    expect(all.length, 1);
    expect(all.single.title, 'Renamed');
  });

  test('watchAll orders by status ascending then updatedAt descending',
      () async {
    // status enum order: active(0), onHold(1), someday(2), done(3), dropped(4)
    await repo.upsert(project('hold',
        status: ProjectStatus.onHold, updatedAt: DateTime(2026, 5, 14, 12)));
    await repo.upsert(project('active-old',
        status: ProjectStatus.active, updatedAt: DateTime(2026, 5, 13)));
    await repo.upsert(project('active-new',
        status: ProjectStatus.active, updatedAt: DateTime(2026, 5, 14, 15)));
    final all = await repo.watchAll().first;
    expect(all.map((p) => p.id), ['active-new', 'active-old', 'hold']);
  });

  test('watchByStatus returns only matching status, newest first', () async {
    await repo.upsert(project('a',
        status: ProjectStatus.active, updatedAt: DateTime(2026, 5, 13)));
    await repo.upsert(project('b',
        status: ProjectStatus.active, updatedAt: DateTime(2026, 5, 14)));
    await repo.upsert(project('c', status: ProjectStatus.done));
    final active = await repo.watchByStatus(ProjectStatus.active).first;
    expect(active.map((p) => p.id), ['b', 'a']);
  });

  test('getById returns the project or null when missing', () async {
    await repo.upsert(project('a', title: 'Find me'));
    expect((await repo.getById('a'))?.title, 'Find me');
    expect(await repo.getById('missing'), isNull);
  });

  test('delete removes the project from watchAll', () async {
    await repo.upsert(project('a'));
    await repo.delete('a');
    final all = await repo.watchAll().first;
    expect(all, isEmpty);
  });

  test('round-trips areaId through persistence', () async {
    await repo.upsert(project('a', areaId: 'area-1'));
    expect((await repo.getById('a'))?.areaId, 'area-1');
  });
}
