import 'package:cleartray/infrastructure/device_calendar_gateway.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tearDown(
    () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(DeviceCalendarPlugin.channel, null),
  );
  test(
    'platform lookup error propagates instead of becoming an empty list',
    () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(DeviceCalendarPlugin.channel, (_) async {
            throw PlatformException(code: 'provider_failure');
          });
      await expectLater(
        DeviceCalendarGateway().listCalendars(),
        throwsStateError,
      );
    },
  );
  test('empty successful lookup gets one bounded retry', () async {
    var calls = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(DeviceCalendarPlugin.channel, (_) async {
          calls++;
          return '[]';
        });
    expect(await DeviceCalendarGateway().listCalendars(), isEmpty);
    expect(calls, 2);
  });
  test('calendar list retains account identity and read-only status', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          DeviceCalendarPlugin.channel,
          (_) async =>
              '[{"id":"read","name":"Holidays","accountName":"Work","isReadOnly":true}]',
        );
    final calendar = (await DeviceCalendarGateway().listCalendars()).single;
    expect(calendar.displayName, 'Holidays · Work');
    expect(calendar.writable, isFalse);
  });
  test('failed event reads throw instead of reporting no events', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(DeviceCalendarPlugin.channel, (_) async {
          throw PlatformException(code: 'provider_failure');
        });
    await expectLater(
      DeviceCalendarGateway().eventsInRange(
        calendarId: 'calendar',
        from: DateTime(2026),
        to: DateTime(2027),
      ),
      throwsStateError,
    );
  });
  test('automatic permission checks never request a grant', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(DeviceCalendarPlugin.channel, (call) async {
          expect(call.method, 'hasPermissions');
          return false;
        });
    expect(await DeviceCalendarGateway().hasPermissions(), isFalse);
  });
}
