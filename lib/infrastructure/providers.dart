import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/microsoft_todo_gateway.dart';
import 'microsoft_todo_auth.dart';
import 'microsoft_todo_graph_gateway.dart';
import '../core/apple_reminders_gateway.dart';
import 'method_channel_apple_reminders_gateway.dart';
import '../core/app_icon.dart';
import '../core/app_review.dart';
import 'in_app_review_prompter.dart';
import 'method_channel_app_icon_gateway.dart';
import '../core/calendar_gateway.dart';
import '../core/backup_files.dart';
import '../core/folder_backup.dart';
import 'device_folder_backup.dart';
import 'device_backup_files.dart';
import '../core/clock.dart';
import '../core/things_snapshot_reader.dart';
import 'sqlite_things_snapshot_reader.dart';
import '../core/dictation.dart';
import '../core/home_widget_bridge.dart';
import '../core/id_generator.dart';
import '../core/notification_scheduler.dart';
import '../core/system_settings.dart';
import 'device_calendar_gateway.dart';
import 'home_widget_bridge_impl.dart';
import 'local_notification_scheduler.dart';
import 'permission_handler_system_settings.dart';
import 'uuid_id_generator.dart';
import 'speech_to_text_dictation.dart';

/// The default overrides applied at app startup. Tests pass in a different
/// list (FakeClock, FixedIdGenerator, fake scheduler / bridge) and skip
/// these.
List<Override> defaultInfrastructureOverrides() => [
  microsoftTodoGatewayProvider.overrideWithValue(
    MicrosoftTodoGraphGateway(
      available: MicrosoftTodoAuth.configuredClientId.trim().isNotEmpty,
      authorize: MicrosoftTodoAuth(
        clientId: MicrosoftTodoAuth.configuredClientId,
      ).authorize,
    ),
  ),
  thingsSnapshotReaderProvider.overrideWithValue(SqliteThingsSnapshotReader()),
  folderBackupFilesProvider.overrideWithValue(const DeviceFolderBackup()),
  appleRemindersGatewayProvider.overrideWithValue(
    const MethodChannelAppleRemindersGateway(),
  ),
  appIconGatewayProvider.overrideWithValue(const MethodChannelAppIconGateway()),
  appReviewPrompterProvider.overrideWithValue(const InAppReviewPrompter()),
  dictationFactoryProvider.overrideWithValue(SpeechToTextDictation.new),
  backupFilesProvider.overrideWithValue(
    DeviceBackupFiles(ids: const UuidIdGenerator()),
  ),
  clockProvider.overrideWithValue(const SystemClock()),
  idGeneratorProvider.overrideWithValue(const UuidIdGenerator()),
  notificationSchedulerProvider.overrideWithValue(LocalNotificationScheduler()),
  homeWidgetBridgeProvider.overrideWithValue(HomeWidgetBridgeImpl()),
  calendarGatewayProvider.overrideWithValue(DeviceCalendarGateway()),
  systemSettingsProvider.overrideWithValue(
    const PermissionHandlerSystemSettings(),
  ),
];
