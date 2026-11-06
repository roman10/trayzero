import 'package:cleartray/core/microsoft_todo_gateway.dart';
import 'package:cleartray/infrastructure/microsoft_todo_auth.dart';
import 'package:cleartray/infrastructure/providers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeAppAuth extends FlutterAppAuth {
  AuthorizationTokenRequest? request;
  Object? error;
  String? accessToken = 'short-lived-token';
  @override
  Future<AuthorizationTokenResponse> authorizeAndExchangeCode(
    AuthorizationTokenRequest request,
  ) async {
    this.request = request;
    if (error != null) throw error!;
    return AuthorizationTokenResponse(
      accessToken,
      null,
      null,
      null,
      'Bearer',
      null,
      null,
      null,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('build configuration controls the real importer availability', () async {
    final container = ProviderContainer(
      overrides: defaultInfrastructureOverrides(),
    );
    addTearDown(container.dispose);
    const expectedId = String.fromEnvironment(
      'MICROSOFT_TODO_CLIENT_ID',
      defaultValue: 'a17f0981-ccba-4ff6-9445-2e09297f88c8',
    );
    expect(MicrosoftTodoAuth.configuredClientId, expectedId);
    final gateway = container.read(microsoftTodoGatewayProvider);
    expect(gateway.available, expectedId.trim().isNotEmpty);
    if (!gateway.available) {
      await expectLater(
        gateway.read(isCancelled: () => false),
        throwsA(
          isA<MicrosoftTodoException>().having(
            (e) => e.failure,
            'failure',
            MicrosoftTodoFailure.unavailable,
          ),
        ),
      );
    }
  });

  test(
    'uses the native PKCE exchange with read-only scope and no refresh or secret',
    () async {
      final native = FakeAppAuth();
      final auth = MicrosoftTodoAuth(
        clientId: 'public-client',
        appAuth: native,
      );
      expect(await auth.authorize(), 'short-lived-token');
      final request = native.request!;
      expect(request.clientId, 'public-client');
      expect(
        request.redirectUrl,
        'app.cleartray.microsoft.debug://oauth/callback',
      );
      expect(request.scopes, ['https://graph.microsoft.com/Tasks.Read']);
      expect(request.clientSecret, isNull);
      expect(request.promptValues, ['select_account']);
      expect(
        request.externalUserAgent,
        ExternalUserAgent.ephemeralAsWebAuthenticationSession,
      );
      expect(
        request.serviceConfiguration!.authorizationEndpoint,
        'https://login.microsoftonline.com/common/oauth2/v2.0/authorize',
      );
      expect(
        request.serviceConfiguration!.tokenEndpoint,
        'https://login.microsoftonline.com/common/oauth2/v2.0/token',
      );
    },
  );

  test('missing configuration never starts a browser session', () async {
    final native = FakeAppAuth();
    await expectLater(
      MicrosoftTodoAuth(clientId: '', appAuth: native).authorize(),
      throwsA(
        isA<MicrosoftTodoException>().having(
          (e) => e.failure,
          'failure',
          MicrosoftTodoFailure.unavailable,
        ),
      ),
    );
    expect(native.request, isNull);
  });

  test(
    'sanitizes platform failures so tokens and private URLs never escape',
    () async {
      final native = FakeAppAuth()
        ..error = PlatformException(
          code: 'auth',
          message: 'secret-token-and-private-url',
        );
      final future = MicrosoftTodoAuth(
        clientId: 'public-client',
        appAuth: native,
      ).authorize();
      await expectLater(
        future,
        throwsA(
          isA<MicrosoftTodoException>()
              .having((e) => e.failure, 'failure', MicrosoftTodoFailure.signIn)
              .having(
                (e) => e.toString(),
                'safe details',
                isNot(contains('secret')),
              ),
        ),
      );
    },
  );

  test(
    'native user cancellation is distinguished from sign-in failure',
    () async {
      final native = FakeAppAuth()
        ..error = FlutterAppAuthUserCancelledException(
          code: 'cancelled',
          platformErrorDetails: FlutterAppAuthPlatformErrorDetails(),
        );
      await expectLater(
        MicrosoftTodoAuth(
          clientId: 'public-client',
          appAuth: native,
        ).authorize(),
        throwsA(
          isA<MicrosoftTodoException>().having(
            (e) => e.failure,
            'failure',
            MicrosoftTodoFailure.cancelled,
          ),
        ),
      );
    },
  );
}
