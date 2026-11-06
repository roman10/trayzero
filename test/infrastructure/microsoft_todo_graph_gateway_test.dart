import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cleartray/core/microsoft_todo_gateway.dart';
import 'package:cleartray/infrastructure/microsoft_todo_graph_gateway.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const base = 'https://graph.microsoft.com/v1.0/me/todo/lists';
http.Response page(List<Object?> rows, [String? next]) =>
    http.Response(jsonEncode({'value': rows, '@odata.nextLink': ?next}), 200);
Matcher failure(MicrosoftTodoFailure value) => throwsA(
  isA<MicrosoftTodoException>().having((e) => e.failure, 'failure', value),
);

class TrackingClient extends MockClient {
  TrackingClient(super.fn);
  bool closed = false;
  @override
  void close() {
    closed = true;
    super.close();
  }
}

void main() {
  test(
    'fully paginates lists, tasks and checklist steps with read-only requests',
    () async {
      final urls = <String>[];
      final responses = {
        base: page([
          {'id': 'l/1', 'displayName': 'Garage'},
        ], '$base?skip=2'),
        '$base?skip=2': page([
          {'id': 'empty', 'displayName': 'Empty'},
        ]),
        '$base/l%2F1/tasks': page([
          {'id': 't/1', 'title': 'A'},
        ], '$base/l%2F1/tasks?skip=2'),
        '$base/l%2F1/tasks?skip=2': page([
          {'id': 'done', 'status': 'completed'},
        ]),
        '$base/l%2F1/tasks/t%2F1/checklistItems': page([
          {'displayName': 'Step1'},
        ], '$base/l%2F1/tasks/t%2F1/checklistItems?skip=2'),
        '$base/l%2F1/tasks/t%2F1/checklistItems?skip=2': page([
          {'displayName': 'Step2'},
        ]),
        '$base/empty/tasks': page([]),
      };
      final client = TrackingClient((request) async {
        expect(request.method, 'GET');
        expect(request.followRedirects, isFalse);
        expect(request.headers['Authorization'], 'Bearer test-token');
        urls.add(request.url.toString());
        return responses[request.url.toString()]!;
      });
      final gateway = MicrosoftTodoGraphGateway(
        available: true,
        authorize: () async => 'test-token',
        clientFactory: () => client,
      );
      final lists = await gateway.read(isCancelled: () => false);
      expect(urls, responses.keys.toList());
      final tasks = lists.first['tasks'] as List;
      expect(tasks, hasLength(2));
      expect(tasks.first['checklistItems'], hasLength(2));
      expect(tasks.last.containsKey('checklistItems'), isFalse);
      expect(client.closed, isTrue);
    },
  );

  test(
    'a failing later page rejects the complete snapshot and closes the client',
    () async {
      final client = TrackingClient(
        (r) async => r.url.query.isEmpty
            ? page([
                {'id': 'first'},
              ], '$base?next=2')
            : http.Response('private server details', 500),
      );
      final gateway = MicrosoftTodoGraphGateway(
        available: true,
        authorize: () async => 'token',
        clientFactory: () => client,
      );
      await expectLater(
        gateway.read(isCancelled: () => false),
        failure(MicrosoftTodoFailure.network),
      );
      expect(client.closed, isTrue);
    },
  );

  for (final link in [
    'https://evil.example/steal',
    'http://graph.microsoft.com/v1.0/me/todo/lists',
    'https://graph.microsoft.com/v1.0/me/messages',
    '$base#fragment',
    base,
    'https://graph.microsoft.com:444/v1.0/me/todo/lists',
  ]) {
    test('rejects untrusted, cyclic or misplaced next link: $link', () async {
      var requests = 0;
      final gateway = MicrosoftTodoGraphGateway(
        available: true,
        authorize: () async => 'secret',
        clientFactory: () => MockClient((r) async {
          requests++;
          return page([], link);
        }),
      );
      await expectLater(
        gateway.read(isCancelled: () => false),
        failure(MicrosoftTodoFailure.invalidResponse),
      );
      expect(requests, 1);
    });
  }

  for (final entry in {
    401: MicrosoftTodoFailure.signIn,
    403: MicrosoftTodoFailure.permission,
    302: MicrosoftTodoFailure.network,
  }.entries) {
    test('HTTP ${entry.key} returns a safe failure category', () async {
      final gateway = MicrosoftTodoGraphGateway(
        available: true,
        authorize: () async => 'token',
        clientFactory: () =>
            MockClient((_) async => http.Response('secret', entry.key)),
      );
      await expectLater(
        gateway.read(isCancelled: () => false),
        failure(entry.value),
      );
    });
  }

  for (final body in [
    'broken JSON',
    '{"value":{}}',
    '{"value":[false]}',
    '{"value":[],"@odata.nextLink":7}',
    '{"value":[{}]}',
  ]) {
    test(
      'malformed Graph response fails without returning a partial import: $body',
      () async {
        final gateway = MicrosoftTodoGraphGateway(
          available: true,
          authorize: () async => 'token',
          clientFactory: () =>
              MockClient((_) async => http.Response(body, 200)),
        );
        await expectLater(
          gateway.read(isCancelled: () => false),
          failure(MicrosoftTodoFailure.invalidResponse),
        );
      },
    );
  }

  test(
    'throttling retries honor Retry-After and terminate after three attempts',
    () async {
      final delays = <Duration>[];
      var requests = 0;
      final gateway = MicrosoftTodoGraphGateway(
        available: true,
        authorize: () async => 'token',
        delay: (d) async {
          delays.add(d);
        },
        clientFactory: () => MockClient((_) async {
          requests++;
          return http.Response('', 429, headers: {'retry-after': '7'});
        }),
      );
      await expectLater(
        gateway.read(isCancelled: () => false),
        failure(MicrosoftTodoFailure.network),
      );
      expect(requests, 3);
      expect(delays, [const Duration(seconds: 7), const Duration(seconds: 7)]);
    },
  );

  test(
    'recovers from a transient 503 without retrying a successful page',
    () async {
      var requests = 0;
      final gateway = MicrosoftTodoGraphGateway(
        available: true,
        authorize: () async => 'token',
        delay: (_) async {},
        clientFactory: () => MockClient(
          (_) async => ++requests == 1 ? http.Response('', 503) : page([]),
        ),
      );
      expect(await gateway.read(isCancelled: () => false), isEmpty);
      expect(requests, 2);
    },
  );

  test('long throttles are surfaced without shortening Retry-After', () async {
    var requests = 0;
    final gateway = MicrosoftTodoGraphGateway(
      available: true,
      authorize: () async => 'token',
      delay: (_) async => fail('must not delay'),
      clientFactory: () => MockClient((_) async {
        requests++;
        return http.Response('', 429, headers: {'retry-after': '120'});
      }),
    );
    await expectLater(
      gateway.read(isCancelled: () => false),
      failure(MicrosoftTodoFailure.network),
    );
    expect(requests, 1);
  });

  test('HTTP-date Retry-After waits until the advertised time', () async {
    final now = DateTime.utc(2026, 11, 3, 8);
    final delays = <Duration>[];
    var requests = 0;
    final gateway = MicrosoftTodoGraphGateway(
      available: true,
      authorize: () async => 'token',
      now: () => now,
      delay: (duration) async => delays.add(duration),
      clientFactory: () => MockClient(
        (_) async => ++requests == 1
            ? http.Response(
                '',
                503,
                headers: {
                  'retry-after': HttpDate.format(
                    now.add(const Duration(seconds: 20)),
                  ),
                },
              )
            : page([]),
      ),
    );
    expect(await gateway.read(isCancelled: () => false), isEmpty);
    expect(delays, [const Duration(seconds: 20)]);
    expect(requests, 2);
  });

  test(
    'a long HTTP-date Retry-After is surfaced without an early retry',
    () async {
      final now = DateTime.utc(2026, 11, 3, 8);
      var requests = 0;
      final gateway = MicrosoftTodoGraphGateway(
        available: true,
        authorize: () async => 'token',
        now: () => now,
        delay: (_) async => fail('must not wait or retry early'),
        clientFactory: () => MockClient((_) async {
          requests++;
          return http.Response(
            '',
            429,
            headers: {
              'retry-after': HttpDate.format(
                now.add(const Duration(minutes: 5)),
              ),
            },
          );
        }),
      );
      await expectLater(
        gateway.read(isCancelled: () => false),
        failure(MicrosoftTodoFailure.network),
      );
      expect(requests, 1);
    },
  );

  test(
    'a malformed Retry-After retains the bounded fallback backoff',
    () async {
      final delays = <Duration>[];
      var requests = 0;
      final gateway = MicrosoftTodoGraphGateway(
        available: true,
        authorize: () async => 'token',
        delay: (duration) async => delays.add(duration),
        clientFactory: () => MockClient(
          (_) async => ++requests == 1
              ? http.Response('', 429, headers: {'retry-after': 'unreadable'})
              : page([]),
        ),
      );
      expect(await gateway.read(isCancelled: () => false), isEmpty);
      expect(delays, [const Duration(seconds: 1)]);
      expect(requests, 2);
    },
  );

  test(
    'a past HTTP-date Retry-After never produces a negative delay',
    () async {
      final now = DateTime.utc(2026, 11, 3, 8);
      final delays = <Duration>[];
      var requests = 0;
      final gateway = MicrosoftTodoGraphGateway(
        available: true,
        authorize: () async => 'token',
        now: () => now,
        delay: (duration) async => delays.add(duration),
        clientFactory: () => MockClient(
          (_) async => ++requests == 1
              ? http.Response(
                  '',
                  503,
                  headers: {
                    'retry-after': HttpDate.format(
                      now.subtract(const Duration(minutes: 1)),
                    ),
                  },
                )
              : page([]),
        ),
      );
      expect(await gateway.read(isCancelled: () => false), isEmpty);
      expect(delays, [Duration.zero]);
      expect(requests, 2);
    },
  );

  test('cancel during authentication prevents every Graph request', () async {
    final auth = Completer<String?>();
    var cancelled = false;
    final gateway = MicrosoftTodoGraphGateway(
      available: true,
      authorize: () => auth.future,
      clientFactory: () => throw StateError('must not create client'),
    );
    final read = gateway.read(isCancelled: () => cancelled);
    cancelled = true;
    auth.complete('token');
    await expectLater(read, failure(MicrosoftTodoFailure.cancelled));
  });

  test(
    'cancel between pages stops reading and discards the snapshot',
    () async {
      var cancelled = false;
      var requests = 0;
      final client = TrackingClient((_) async {
        requests++;
        cancelled = true;
        return page([], '$base?next=2');
      });
      final gateway = MicrosoftTodoGraphGateway(
        available: true,
        authorize: () async => 'token',
        clientFactory: () => client,
      );
      await expectLater(
        gateway.read(isCancelled: () => cancelled),
        failure(MicrosoftTodoFailure.cancelled),
      );
      expect(requests, 1);
      expect(client.closed, isTrue);
    },
  );

  test(
    'unavailable configuration and missing tokens never access Graph',
    () async {
      for (final available in [true, false]) {
        final gateway = MicrosoftTodoGraphGateway(
          available: available,
          authorize: () async => null,
          clientFactory: () => throw StateError('must not create client'),
        );
        await expectLater(
          gateway.read(isCancelled: () => false),
          failure(
            available
                ? MicrosoftTodoFailure.signIn
                : MicrosoftTodoFailure.unavailable,
          ),
        );
      }
    },
  );

  test('page budget bounds non-cyclic runaway pagination', () async {
    var requests = 0;
    final gateway = MicrosoftTodoGraphGateway(
      available: true,
      authorize: () async => 'token',
      maxPages: 2,
      clientFactory: () => MockClient((_) async {
        requests++;
        return page([], '$base?skip=$requests');
      }),
    );
    await expectLater(
      gateway.read(isCancelled: () => false),
      failure(MicrosoftTodoFailure.invalidResponse),
    );
    expect(requests, 2);
  });
  test(
    'a stalled network request times out, closes the client and yields no snapshot',
    () async {
      final pending = Completer<http.Response>();
      final client = TrackingClient((_) => pending.future);
      final gateway = MicrosoftTodoGraphGateway(
        available: true,
        authorize: () async => 'token',
        clientFactory: () => client,
        requestTimeout: const Duration(milliseconds: 5),
      );
      await expectLater(
        gateway.read(isCancelled: () => false),
        failure(MicrosoftTodoFailure.network),
      );
      expect(client.closed, isTrue);
      pending.complete(page([]));
    },
  );
}
