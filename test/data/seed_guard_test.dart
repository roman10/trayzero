import 'package:cleartray/application/providers.dart';
import 'package:cleartray/data/seed.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

void main() {
  late TestEnv env;
  setUp(
    () async => env = await TestEnv.create(
      idQueue: [for (var i = 0; i < 10; i++) 'id-$i'],
    ),
  );
  tearDown(() => env.dispose());

  test('seedSampleProject does not crash with no contexts', () async {
    final c = env.container();
    final projects = c.read(projectRepositoryProvider);
    final items = c.read(itemRepositoryProvider);
    await seedSampleProject(
      projects: projects,
      items: items,
      contexts: c.read(contextRepositoryProvider),
      ids: env.ids,
      clock: env.clock,
      computerLabel: '@computer',
      projectTitle: 'Sample',
      projectOutcome: 'Outcome',
      readPrimerTitle: 'Read',
      emptyEmailTitle: 'Email',
      scheduleReviewTitle: 'Review',
    );
    final all = await projects.watchAll().first;
    expect(all, hasLength(1));
    final seeded = await items.watchForProject(all.single.id).first;
    expect(seeded, isNotEmpty);
    expect(seeded.every((i) => i.contextId == null), isTrue);
  });
}
