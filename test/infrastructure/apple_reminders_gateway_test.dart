import 'package:cleartray/core/apple_reminders_gateway.dart';
import 'package:cleartray/infrastructure/method_channel_apple_reminders_gateway.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('app.cleartray/apple_reminders');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  const gateway = MethodChannelAppleRemindersGateway();
  setUp(() => debugDefaultTargetPlatformOverride = TargetPlatform.iOS);
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    messenger.setMockMethodCallHandler(channel, null);
  });

  test(
    'decodes lists and selected reminders including native date precision',
    () async {
      final calls = <MethodCall>[];
      messenger.setMockMethodCallHandler(channel, (call) async {
        calls.add(call);
        if (call.method == 'requestLists') {
          return [
            {'id': 'a', 'title': 'Home', 'account': 'iCloud'},
          ];
        }
        expect(call.arguments, {
          'listIds': ['a'],
        });
        return [
          {
            'id': 'r',
            'listId': 'a',
            'title': 'Buy milk',
            'notes': 'Oat',
            'url': 'https://example.com',
            'completed': false,
            'due': '2026-11-04T00:00:00Z',
            'start': '2026-11-03',
            'dueIsDateOnly': false,
            'recurrenceRules': ['FREQ=DAILY;INTERVAL=2'],
            'hasAlarms': true,
            'priority': 1,
          },
        ];
      });
      final lists = await gateway.requestLists();
      expect(
        (lists.single.id, lists.single.title, lists.single.account),
        ('a', 'Home', 'iCloud'),
      );
      final item = (await gateway.readReminders({'a'})).single;
      expect(
        (item.id, item.listId, item.title, item.notes),
        ('r', 'a', 'Buy milk', 'Oat'),
      );
      expect(item.dueIsDateOnly, isFalse);
      expect(item.due, '2026-11-04T00:00:00Z');
      expect(item.recurrenceRules, ['FREQ=DAILY;INTERVAL=2']);
      expect(calls.map((call) => call.method), [
        'requestLists',
        'readReminders',
      ]);
    },
  );

  for (final code in ['permission_denied', 'lists_changed', 'read_failed']) {
    test('propagates $code without treating it as empty data', () async {
      messenger.setMockMethodCallHandler(
        channel,
        (_) async => throw PlatformException(code: code),
      );
      await expectLater(
        gateway.readReminders({'a'}),
        throwsA(
          isA<AppleRemindersException>().having(
            (e) => e.failure,
            'failure',
            switch (code) {
              'permission_denied' => AppleRemindersFailure.denied,
              'lists_changed' => AppleRemindersFailure.listsChanged,
              _ => AppleRemindersFailure.unavailable,
            },
          ),
        ),
      );
    });
  }

  test('empty selection never invokes native API', () async {
    messenger.setMockMethodCallHandler(
      channel,
      (_) async => fail('Must not read all reminders'),
    );
    expect(await gateway.readReminders({}), isEmpty);
  });

  test('unsupported platforms never prompt for access', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    messenger.setMockMethodCallHandler(
      channel,
      (_) async => fail('Unexpected native call'),
    );
    expect(gateway.supported, isFalse);
    await expectLater(
      gateway.requestLists(),
      throwsA(isA<AppleRemindersException>()),
    );
  });

  test(
    'missing or malformed responses fail rather than silently dropping data',
    () async {
      for (final response in [
        null,
        ['bad'],
        [
          {'id': 'a'},
        ],
      ]) {
        messenger.setMockMethodCallHandler(channel, (_) async => response);
        await expectLater(gateway.requestLists(), throwsA(anything));
      }
    },
  );
}
