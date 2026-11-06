import 'package:cleartray/features/common/error_view.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/harness.dart';

void main() {
  late TestEnv env;
  setUp(() async => env = await TestEnv.create());
  tearDown(() => env.dispose());

  testWidgets('shows calm copy, never the raw exception', (tester) async {
    await pumpApp(
      tester,
      ErrorView(error: Exception('SqliteException(14): secret detail')),
      env: env,
    );
    expect(find.text("Couldn't load this"), findsOneWidget);
    expect(find.text('Your data is safe. Try again.'), findsOneWidget);
    expect(find.textContaining('Sqlite'), findsNothing);
    expect(find.text('Retry'), findsNothing);
  });

  testWidgets('Retry button calls onRetry', (tester) async {
    var retried = 0;
    await pumpApp(
      tester,
      ErrorView(error: 'boom', onRetry: () => retried++),
      env: env,
    );
    await tester.tap(find.text('Retry'));
    expect(retried, 1);
  });
}
