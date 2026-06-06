import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cleartray/data/db/database.dart';
import 'package:cleartray/data/repositories/area_repository.dart';
import 'package:cleartray/data/repositories/project_repository.dart';
import 'package:cleartray/domain/entities/entities.dart';

void main() {
  late AppDatabase db;
  late AreaRepository repo;
  late ProjectRepository projects;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = AreaRepository(db);
    projects = ProjectRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('upserting an area makes it visible to watchAll', () async {
    await repo.upsert(const Area(id: 'a', name: 'Work'));
    final all = await repo.watchAll().first;
    expect(all.length, 1);
    expect(all.single.name, 'Work');
  });

  test('upsert with an existing id updates rather than duplicates', () async {
    await repo.upsert(const Area(id: 'a', name: 'Work'));
    await repo.upsert(const Area(id: 'a', name: 'Career'));
    final all = await repo.watchAll().first;
    expect(all.length, 1);
    expect(all.single.name, 'Career');
  });

  test('watchAll orders by name ascending', () async {
    await repo.upsert(const Area(id: 'c', name: 'Personal'));
    await repo.upsert(const Area(id: 'a', name: 'Family'));
    await repo.upsert(const Area(id: 'b', name: 'Health'));
    final all = await repo.watchAll().first;
    expect(all.map((a) => a.name), ['Family', 'Health', 'Personal']);
  });

  test('getById returns the area or null when missing', () async {
    await repo.upsert(const Area(id: 'a', name: 'Work'));
    expect((await repo.getById('a'))?.name, 'Work');
    expect(await repo.getById('missing'), isNull);
  });

  test('delete removes the area from watchAll', () async {
    await repo.upsert(const Area(id: 'a', name: 'Work'));
    await repo.delete('a');
    expect(await repo.watchAll().first, isEmpty);
  });

  test('delete detaches projects that referenced the area', () async {
    final now = DateTime(2026, 5, 14, 9);
    await repo.upsert(const Area(id: 'area-1', name: 'Work'));
    await projects.upsert(Project(
      id: 'p1',
      title: 'Linked project',
      status: ProjectStatus.active,
      areaId: 'area-1',
      createdAt: now,
      updatedAt: now,
    ));
    await repo.delete('area-1');
    expect(await repo.getById('area-1'), isNull);
    // Project survives but its area reference is cleared.
    expect((await projects.getById('p1'))?.areaId, isNull);
  });

  test('deleting an area leaves projects of other areas untouched', () async {
    final now = DateTime(2026, 5, 14, 9);
    await repo.upsert(const Area(id: 'area-1', name: 'Work'));
    await repo.upsert(const Area(id: 'area-2', name: 'Home'));
    await projects.upsert(Project(
      id: 'p2',
      title: 'Home project',
      status: ProjectStatus.active,
      areaId: 'area-2',
      createdAt: now,
      updatedAt: now,
    ));
    await repo.delete('area-1');
    expect((await projects.getById('p2'))?.areaId, 'area-2');
  });
}
