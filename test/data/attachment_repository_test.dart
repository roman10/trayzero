// path_provider_platform_interface + plugin_platform_interface are pulled in
// transitively by path_provider; they are imported here only to mock the
// platform channel in tests.
// ignore_for_file: depend_on_referenced_packages

import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:cleartray/core/clock.dart';
import 'package:cleartray/core/id_generator.dart';
import 'package:cleartray/data/db/database.dart';
import 'package:cleartray/data/repositories/attachment_repository.dart';
import 'package:cleartray/domain/entities/entities.dart';

/// Routes `getApplicationDocumentsDirectory()` to a per-test temp directory.
class _FakePathProvider extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  _FakePathProvider(this.docsPath);
  final String docsPath;

  @override
  Future<String?> getApplicationDocumentsPath() async => docsPath;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late AttachmentRepository repo;
  late Directory docsDir;
  late Directory sourceDir;
  late FakeClock clock;
  late FixedIdGenerator ids;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    clock = FakeClock(DateTime(2026, 5, 14, 9));
    ids = FixedIdGenerator(['att-1', 'att-2', 'att-3']);
    repo = AttachmentRepository(db, clock, ids);
    docsDir = Directory.systemTemp.createTempSync('att_docs_');
    sourceDir = Directory.systemTemp.createTempSync('att_src_');
    PathProviderPlatform.instance = _FakePathProvider(docsDir.path);
  });

  tearDown(() async {
    await db.close();
    if (docsDir.existsSync()) docsDir.deleteSync(recursive: true);
    if (sourceDir.existsSync()) sourceDir.deleteSync(recursive: true);
  });

  File makeSource(String name, String content) {
    final f = File(p.join(sourceDir.path, name));
    f.writeAsStringSync(content);
    return f;
  }

  test('attach copies the file into the docs attachments folder and inserts a row',
      () async {
    final src = makeSource('photo.png', 'binary-bytes');
    final a = await repo.attach(
      itemId: 'item-1',
      kind: AttachmentKind.image,
      source: src,
      originalName: 'photo.png',
    );

    expect(a.id, 'att-1');
    expect(a.itemId, 'item-1');
    expect(a.kind, AttachmentKind.image);
    expect(a.name, 'photo.png');
    expect(a.path, p.join('attachments', 'item-1', 'att-1.png'));
    expect(a.sizeBytes, 'binary-bytes'.length);
    expect(a.createdAt, DateTime(2026, 5, 14, 9));

    // Physical copy exists under docs dir.
    final copied = File(p.join(docsDir.path, a.path));
    expect(copied.existsSync(), isTrue);
    expect(copied.readAsStringSync(), 'binary-bytes');
  });

  test('attached row is visible to watchForItem', () async {
    final src = makeSource('a.txt', 'hello');
    await repo.attach(
      itemId: 'item-1',
      kind: AttachmentKind.file,
      source: src,
    );
    final list = await repo.watchForItem('item-1').first;
    expect(list.length, 1);
    expect(list.single.id, 'att-1');
  });

  test('watchForItem only returns attachments for the given item', () async {
    await repo.attach(
        itemId: 'item-1',
        kind: AttachmentKind.file,
        source: makeSource('a.txt', 'a'));
    await repo.attach(
        itemId: 'item-2',
        kind: AttachmentKind.file,
        source: makeSource('b.txt', 'b'));
    final list = await repo.watchForItem('item-1').first;
    expect(list.map((x) => x.itemId), ['item-1']);
  });

  test('watchForItem orders attachments by createdAt ascending', () async {
    await repo.attach(
        itemId: 'item-1',
        kind: AttachmentKind.file,
        source: makeSource('first.txt', '1'));
    clock.advance(const Duration(minutes: 5));
    await repo.attach(
        itemId: 'item-1',
        kind: AttachmentKind.file,
        source: makeSource('second.txt', '2'));
    final list = await repo.watchForItem('item-1').first;
    expect(list.map((x) => x.id), ['att-1', 'att-2']);
  });

  test('getForItem returns the persisted attachments', () async {
    await repo.attach(
        itemId: 'item-1',
        kind: AttachmentKind.audio,
        source: makeSource('voice.m4a', 'audio'));
    final list = await repo.getForItem('item-1');
    expect(list.length, 1);
    expect(list.single.kind, AttachmentKind.audio);
  });

  test('delete removes the row and the physical file', () async {
    final a = await repo.attach(
        itemId: 'item-1',
        kind: AttachmentKind.file,
        source: makeSource('a.txt', 'data'));
    final copied = File(p.join(docsDir.path, a.path));
    expect(copied.existsSync(), isTrue);

    await repo.delete(a);

    expect(copied.existsSync(), isFalse);
    expect(await repo.getForItem('item-1'), isEmpty);
  });

  test('delete tolerates an already-missing file', () async {
    final a = await repo.attach(
        itemId: 'item-1',
        kind: AttachmentKind.file,
        source: makeSource('a.txt', 'data'));
    File(p.join(docsDir.path, a.path)).deleteSync();
    // Should not throw even though the physical file is gone.
    await repo.delete(a);
    expect(await repo.getForItem('item-1'), isEmpty);
  });

  test('absolutePathOf resolves the relative path against the docs dir',
      () async {
    final a = await repo.attach(
        itemId: 'item-1',
        kind: AttachmentKind.file,
        source: makeSource('a.txt', 'data'));
    final abs = await repo.absolutePathOf(a);
    expect(abs, p.join(docsDir.path, a.path));
  });

  test('attach falls back to a file with no extension cleanly', () async {
    final a = await repo.attach(
        itemId: 'item-1',
        kind: AttachmentKind.file,
        source: makeSource('NOEXT', 'x'));
    expect(a.path, p.join('attachments', 'item-1', 'att-1'));
    expect(File(p.join(docsDir.path, a.path)).existsSync(), isTrue);
  });

  test('watchSummaries counts per item and per kind', () async {
    ids = FixedIdGenerator(['a', 'b', 'c', 'd']);
    repo = AttachmentRepository(db, clock, ids);
    await repo.attach(
        itemId: 'item-1',
        kind: AttachmentKind.image,
        source: makeSource('1.png', '1'));
    await repo.attach(
        itemId: 'item-1',
        kind: AttachmentKind.image,
        source: makeSource('2.png', '2'));
    await repo.attach(
        itemId: 'item-1',
        kind: AttachmentKind.audio,
        source: makeSource('3.m4a', '3'));
    await repo.attach(
        itemId: 'item-2',
        kind: AttachmentKind.file,
        source: makeSource('4.txt', '4'));

    final map = await repo.watchSummaries().first;
    expect(map['item-1']!.images, 2);
    expect(map['item-1']!.audio, 1);
    expect(map['item-1']!.files, 0);
    expect(map['item-1']!.total, 3);
    expect(map['item-2']!.files, 1);
    expect(map.containsKey('item-3'), isFalse);
  });

  test('watchSummaries drops an item once its attachments are deleted',
      () async {
    final a = await repo.attach(
        itemId: 'item-1',
        kind: AttachmentKind.image,
        source: makeSource('1.png', '1'));
    expect((await repo.watchSummaries().first).containsKey('item-1'), isTrue);
    await repo.delete(a);
    expect((await repo.watchSummaries().first).containsKey('item-1'), isFalse);
  });
}
