import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter/foundation.dart';

import '../core/microsoft_todo_gateway.dart';

/// Native AppAuth handles the browser, redirect state and PKCE exchange.
/// The short-lived access token stays in memory for this import only.
class MicrosoftTodoAuth {
  /// Public application identifier; this is not a credential. An explicit empty
  /// build override disables the importer for distributions that omit it.
  static const configuredClientId = String.fromEnvironment(
    'MICROSOFT_TODO_CLIENT_ID',
    defaultValue: 'a17f0981-ccba-4ff6-9445-2e09297f88c8',
  );

  MicrosoftTodoAuth({required this.clientId, FlutterAppAuth? appAuth})
    : _appAuth = appAuth ?? const FlutterAppAuth();

  final String clientId;
  final FlutterAppAuth _appAuth;
  // Android debug and release builds coexist (different application IDs).
  // Distinct schemes prevent one install from intercepting the other's login.
  static const redirectUri = kDebugMode
      ? 'app.cleartray.microsoft.debug://oauth/callback'
      : 'app.cleartray.microsoft://oauth/callback';
  static const scope = 'https://graph.microsoft.com/Tasks.Read';

  Future<String?> authorize() async {
    if (clientId.trim().isEmpty) {
      throw const MicrosoftTodoException(MicrosoftTodoFailure.unavailable);
    }
    try {
      final response = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          clientId,
          redirectUri,
          serviceConfiguration: const AuthorizationServiceConfiguration(
            authorizationEndpoint:
                'https://login.microsoftonline.com/common/oauth2/v2.0/authorize',
            tokenEndpoint:
                'https://login.microsoftonline.com/common/oauth2/v2.0/token',
          ),
          scopes: const [scope],
          promptValues: const ['select_account'],
          externalUserAgent:
              ExternalUserAgent.ephemeralAsWebAuthenticationSession,
        ),
      );
      return response.accessToken;
    } on FlutterAppAuthUserCancelledException {
      throw const MicrosoftTodoException(MicrosoftTodoFailure.cancelled);
    } catch (_) {
      // Never propagate platform error details, which can include tokens/URLs.
      throw const MicrosoftTodoException(MicrosoftTodoFailure.signIn);
    }
  }
}
