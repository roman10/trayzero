import 'package:cleartray/infrastructure/device_calendar_gateway.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  tearDown(
    () =>
        messenger.setMockMethodCallHandler(DeviceCalendarPlugin.channel, null),
  );

  test('confirmed native deletion does not require an event lookup', () async {
    messenger.setMockMethodCallHandler(DeviceCalendarPlugin.channel, (
      call,
    ) async {
      expect(call.method, 'deleteEvent');
      expect(call.arguments, {'calendarId': 'original', 'eventId': 'owned'});
      return true;
    });
    expect(
      await DeviceCalendarGateway().deleteEvent(
        calendarId: 'original',
        eventId: 'owned',
      ),
      isTrue,
    );
  });

  test('an event already removed by the user is confirmed absent', () async {
    final methods = <String>[];
    messenger.setMockMethodCallHandler(DeviceCalendarPlugin.channel, (
      call,
    ) async {
      methods.add(call.method);
      if (call.method == 'deleteEvent') return false;
      expect((call.arguments as Map)['eventIds'], ['owned']);
      return '[]';
    });
    expect(
      await DeviceCalendarGateway().deleteEvent(
        calendarId: 'original',
        eventId: 'owned',
      ),
      isTrue,
    );
    expect(methods, ['deleteEvent', 'retrieveEvents']);
  });

  test(
    'failed event lookup stays retryable instead of confirming deletion',
    () async {
      messenger.setMockMethodCallHandler(DeviceCalendarPlugin.channel, (
        call,
      ) async {
        if (call.method == 'deleteEvent') return false;
        throw PlatformException(code: 'permission_denied');
      });
      expect(
        await DeviceCalendarGateway().deleteEvent(
          calendarId: 'original',
          eventId: 'owned',
        ),
        isFalse,
      );
    },
  );

  test(
    'an event still present after failed deletion stays retryable',
    () async {
      messenger.setMockMethodCallHandler(DeviceCalendarPlugin.channel, (
        call,
      ) async {
        if (call.method == 'deleteEvent') return false;
        return '[{"eventId":"owned","calendarId":"original"}]';
      });
      expect(
        await DeviceCalendarGateway().deleteEvent(
          calendarId: 'original',
          eventId: 'owned',
        ),
        isFalse,
      );
    },
  );
}
