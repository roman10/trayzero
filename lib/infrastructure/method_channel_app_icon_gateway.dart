import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/app_icon.dart';
import '../core/appearance_preferences.dart';

/// Derived notification fallback only; the OS remains the icon source of truth.
const androidNotificationIconPaletteKey = 'android_notification_icon_palette';

class MethodChannelAppIconGateway implements AppIconGateway {
  const MethodChannelAppIconGateway();
  static const _channel = MethodChannel('app.cleartray/app_icon');

  @override
  Future<AppIconState> load() async {
    if (defaultTargetPlatform != TargetPlatform.iOS &&
        defaultTargetPlatform != TargetPlatform.android) {
      return const AppIconState(supported: false);
    }
    return _confirmed(
      await _channel.invokeMapMethod<String, dynamic>('getState'),
    );
  }

  @override
  Future<AppIconState> setIcon(AppPalette palette) async => _confirmed(
    await _channel.invokeMapMethod<String, dynamic>('setIcon', {
      'icon': palette.id,
    }),
  );

  Future<AppIconState> _confirmed(Map<String, dynamic>? nativeState) async {
    final actual = _decode(nativeState);
    if (defaultTargetPlatform == TargetPlatform.android && actual.supported) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          androidNotificationIconPaletteKey,
          actual.palette.id,
        );
      } catch (_) {
        // A notification fallback failure must not invalidate a native success.
      }
    }
    return actual;
  }

  AppIconState _decode(Map<String, dynamic>? state) {
    if (state == null) throw StateError('Missing native icon state');
    return AppIconState(
      supported: state['supported'] == true,
      palette: AppPalette.fromId(state['icon'] as String?),
    );
  }
}
