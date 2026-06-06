import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/calendar_gateway.dart';
import '../core/clock.dart';
import '../core/home_widget_bridge.dart';
import '../core/id_generator.dart';
import '../core/notification_scheduler.dart';
import '../core/system_settings.dart';
import 'device_calendar_gateway.dart';
import 'home_widget_bridge_impl.dart';
import 'local_notification_scheduler.dart';
import 'permission_handler_system_settings.dart';
import 'uuid_id_generator.dart';

/// The default overrides applied at app startup. Tests pass in a different
/// list (FakeClock, FixedIdGenerator, fake scheduler / bridge) and skip
/// these.
List<Override> defaultInfrastructureOverrides() => [
      clockProvider.overrideWithValue(const SystemClock()),
      idGeneratorProvider.overrideWithValue(const UuidIdGenerator()),
      notificationSchedulerProvider
          .overrideWithValue(LocalNotificationScheduler()),
      homeWidgetBridgeProvider.overrideWithValue(HomeWidgetBridgeImpl()),
      calendarGatewayProvider.overrideWithValue(DeviceCalendarGateway()),
      systemSettingsProvider
          .overrideWithValue(const PermissionHandlerSystemSettings()),
    ];
