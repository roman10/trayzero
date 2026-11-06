import 'dart:convert';

import 'package:cleartray/application/automatic_folder_backup.dart';
import 'package:cleartray/application/providers.dart' show manageTagsProvider;
import 'package:cleartray/core/folder_backup.dart';
import 'package:cleartray/data/providers.dart';
import 'package:cleartray/domain/entities/entities.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/folder_backup_fake.dart';
import '../support/harness.dart';

void main() {
  test(
    'committed database changes schedule one complete portable snapshot',
    () async {
      final env = await TestEnv.create();
      addTearDown(env.dispose);
      final files = MemoryFolderBackupFiles()
        ..selection = const BackupFolder(
          handle: 'permission',
          label: 'Backups',
        );
      final container = env.container([
        folderBackupFilesProvider.overrideWithValue(files),
      ]);
      final controller = container.read(automaticFolderBackupProvider.notifier);
      await controller.chooseFolder();
      expect(files.snapshots, hasLength(1));
      await env.db.transaction(() async {
        await container
            .read(areaRepositoryProvider)
            .upsert(const Area(id: 'a', name: 'Home'));
        await container
            .read(itemRepositoryProvider)
            .upsert(
              Item(
                id: 'i',
                title: 'Saved together',
                status: ItemStatus.inbox,
                createdAt: env.clock.now(),
                updatedAt: env.clock.now(),
              ),
            );
      });
      await pumpEventQueue();
      env.clock.advance(const Duration(seconds: 5));
      await pumpEventQueue();
      expect(files.snapshots, hasLength(2));
      final restored = jsonDecode(files.snapshots.last) as Map;
      expect(restored['items'][0]['title'], 'Saved together');
      expect(restored['areas'][0]['name'], 'Home');
      expect(restored['attachments'], isEmpty);
      expect(restored['reviews'], isEmpty);
      // An aborted transaction must neither expose rows nor trigger a backup.
      try {
        await env.db.transaction(() async {
          await container
              .read(areaRepositoryProvider)
              .upsert(const Area(id: 'bad', name: 'Rolled back'));
          throw StateError('Abort');
        });
      } catch (_) {}
      await pumpEventQueue();
      env.clock.advance(const Duration(seconds: 5));
      await pumpEventQueue();
      expect(files.snapshots, hasLength(2));
    },
  );

  test(
    'tag-only edits and assignments save complete automatic snapshots',
    () async {
      final env = await TestEnv.create();
      addTearDown(env.dispose);
      final files = MemoryFolderBackupFiles()
        ..selection = const BackupFolder(
          handle: 'permission',
          label: 'Backups',
        );
      final container = env.container([
        folderBackupFilesProvider.overrideWithValue(files),
      ]);
      final items = container.read(itemRepositoryProvider);
      await items.upsert(anItem(id: 'i', title: 'Tagged item'));
      final originalUpdatedAt = (await items.getById('i'))!.updatedAt;
      final controller = container.read(automaticFolderBackupProvider.notifier);
      await controller.chooseFolder();
      final tags = container.read(manageTagsProvider);
      var savedCount = files.snapshots.length;

      Future<Map<String, dynamic>> savedSnapshot() async {
        await pumpEventQueue();
        env.clock.advance(const Duration(seconds: 5));
        await pumpEventQueue();
        expect(files.snapshots, hasLength(++savedCount));
        return jsonDecode(files.snapshots.last) as Map<String, dynamic>;
      }

      final client = (await tags.obtain('Client'))!;
      var snapshot = await savedSnapshot();
      expect(snapshot['tags'], [
        {'id': client.id, 'name': 'Client', 'isPerson': false},
      ]);

      await tags.rename(client.id, 'Customer');
      snapshot = await savedSnapshot();
      expect(snapshot['tags'][0]['name'], 'Customer');

      await tags.setPerson(client.id, true);
      snapshot = await savedSnapshot();
      expect(snapshot['tags'][0]['isPerson'], isTrue);

      await tags.setItemTags('i', [client.id]);
      snapshot = await savedSnapshot();
      expect(snapshot['items'][0]['tagIds'], [client.id]);
      expect((await items.getById('i'))!.updatedAt, originalUpdatedAt);

      await tags.setItemTags('i', []);
      snapshot = await savedSnapshot();
      expect(snapshot['items'][0]['tagIds'], isEmpty);

      // Failed transactions must not publish a backup of uncommitted tags.
      await expectLater(
        env.db.transaction(() async {
          await tags.rename(client.id, 'Rolled back');
          await tags.setItemTags('i', [client.id]);
          throw StateError('Abort');
        }),
        throwsStateError,
      );
      await pumpEventQueue();
      env.clock.advance(const Duration(seconds: 5));
      await pumpEventQueue();
      expect(files.snapshots, hasLength(savedCount));

      final target = (await tags.obtain('Work'))!;
      await tags.setItemTags('i', [client.id]);
      await savedSnapshot();
      await tags.merge(client.id, target.id);
      snapshot = await savedSnapshot();
      expect(snapshot['tags'], [
        {'id': target.id, 'name': 'Work', 'isPerson': true},
      ]);
      expect(snapshot['items'][0]['tagIds'], [target.id]);

      await tags.delete(target.id);
      snapshot = await savedSnapshot();
      expect(snapshot['tags'], isEmpty);
      expect(snapshot['items'][0]['tagIds'], isEmpty);
    },
  );
}
