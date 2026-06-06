import 'package:cleartray/application/open_notification_settings.dart';
import 'package:cleartray/core/result.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';

void main() {
  late FakeSystemSettings settings;
  late OpenNotificationSettings open;

  setUp(() {
    settings = FakeSystemSettings();
    open = OpenNotificationSettings(settings: settings);
  });

  test('returns Ok(true) and opens settings once when launch succeeds',
      () async {
    settings.result = true;

    final r = await open();

    expect(r, isA<Ok<bool, String>>());
    expect((r as Ok).value, isTrue);
    expect(settings.openCount, 1);
  });

  test('returns Ok(false) when the launch fails', () async {
    settings.result = false;

    final r = await open();

    expect((r as Ok).value, isFalse);
    expect(settings.openCount, 1);
  });
}
