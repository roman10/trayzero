import 'dart:io';

import 'package:cleartray/core/id_generator.dart';
import 'package:cleartray/infrastructure/device_backup_files.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory root;
  late DeviceBackupFiles files;
  setUp(() async {
    root = await Directory.systemTemp.createTemp('trayzero-backup-test-');
    files = DeviceBackupFiles(
      ids: FixedIdGenerator(['unique', 'unique']),
      documentsDirectory: () async => root,
      temporaryDirectory: () async => root,
    );
  });
  tearDown(() => root.delete(recursive: true));

  test(
    'restored media round-trips and exclusive creation preserves existing bytes',
    () async {
      final path = await files.writeAttachment([0, 255, 3], extension: '.png');
      expect(await files.readAttachment(path), [0, 255, 3]);
      await expectLater(
        files.writeAttachment([9], extension: '.png'),
        throwsA(isA<FileSystemException>()),
      );
      expect(await files.readAttachment(path), [0, 255, 3]);
      await files.deleteAttachment(path);
      expect(await File(p.join(root.path, path)).exists(), isFalse);
    },
  );

  test(
    'absolute, traversal and unsafe extension paths cannot reach outside attachments',
    () async {
      final outside = File(p.join(root.path, 'private.txt'));
      await outside.writeAsString('private');
      for (final path in [
        outside.path,
        'attachments/../private.txt',
        '../private.txt',
      ]) {
        await expectLater(files.readAttachment(path), throwsFormatException);
        await expectLater(files.deleteAttachment(path), throwsFormatException);
      }
      await expectLater(
        files.writeAttachment([1], extension: '/../private.txt'),
        throwsFormatException,
      );
      expect(await outside.readAsString(), 'private');
    },
  );

  test('a symlink to an external file is not exported', () async {
    final outside = File(p.join(root.path, 'private.txt'));
    await outside.writeAsString('private');
    await Directory(p.join(root.path, 'attachments')).create();
    await Link(
      p.join(root.path, 'attachments', 'link.txt'),
    ).create(outside.path);
    await expectLater(
      files.readAttachment('attachments/link.txt'),
      throwsFormatException,
    );
  });

  test('JSON is flushed to the requested backup file', () async {
    final backup = await files.writeBackup('snapshot.json', '{"version":5}');
    expect(await backup.readAsString(), '{"version":5}');
  });
}
