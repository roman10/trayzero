import 'dart:convert';
import 'dart:io';

import 'package:cleartray/application/backup_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

void main() {
  test(
    'Duo showcase backup round-trips media and review without duplicate IDs',
    () async {
      final env = await TestEnv.create();
      addTearDown(env.dispose);
      final service = env.container().read(backupServiceProvider);
      final raw =
          jsonDecode(
                File(
                  '../docs/app-store-listing/iphone-duo-2026-11-05/fixtures/showcase-backup.json',
                ).readAsStringSync(),
              )
              as Map<String, dynamic>;
      expect(await service.import(raw), 19);
      for (var attempt = 0; attempt < 2; attempt++) {
        final exported = await service.export();
        expect(exported['items'], hasLength(12));
        expect(exported['projects'], hasLength(5));
        final media = (exported['attachments'] as List).single as Map;
        expect(
          base64Decode(media['data'] as String),
          File(
            '../docs/app-store-listing/iphone-duo-2026-11-05/fixtures/Trip notes.txt',
          ).readAsBytesSync(),
        );
        final review = (exported['reviews'] as List).single as Map;
        expect(review['currentStep'], 'projects');
        expect(review['completedAt'], isNull);
        if (attempt == 0) expect(await service.import(raw), 19);
      }
    },
  );
}
