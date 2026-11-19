# Schema v14 fixture

`v14.sqlite` was created by opening `AppDatabase` from Trayzero commit
`5039d3a223b39d113787de51565a797314a320b4`, the parent of the v15 schema change.
The v14 Drift code created the tables, indexes, and schema version. The
synthetic records are listed in `v14_seed.sql`. They cover all ten tables and
include both null and populated values for every nullable column.

To regenerate the fixture, check out that revision in a separate directory,
run `flutter pub get --enforce-lockfile` from its `mobile` directory, and save
the following as `test/create_v14_fixture_test.dart` in that checkout.

```dart
import 'dart:io';

import 'package:cleartray/data/db/database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('create v14 fixture', () async {
    final file = File('v14.sqlite');
    expect(file.existsSync(), isFalse);
    final db = AppDatabase.forTesting(NativeDatabase(file));
    expect(db.schemaVersion, 14);
    await db.customSelect('SELECT 1').get();
    await db.close();
  });
}
```

Run `flutter test test/create_v14_fixture_test.dart` in the historical checkout,
then load `v14_seed.sql` into the new database with foreign keys enabled. Run
`PRAGMA foreign_key_check` and `PRAGMA integrity_check` before copying the
database into this directory.

The `mobile-ci` workflow runs `test/data/migration_test.dart` as part of the
standard Flutter suite. The test upgrades a temporary copy of the fixture.
