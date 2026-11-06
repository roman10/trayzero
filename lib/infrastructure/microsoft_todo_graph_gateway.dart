import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../core/microsoft_todo_gateway.dart';

/// Fully reads Graph before offering a preview. A partial read is an error,
/// never a successful import. HTTP clients and tokens live for one attempt.
class MicrosoftTodoGraphGateway implements MicrosoftTodoGateway {
  MicrosoftTodoGraphGateway({
    required this.available,
    required Future<String?> Function() authorize,
    http.Client Function()? clientFactory,
    Future<void> Function(Duration)? delay,
    DateTime Function()? now,
    this.maxPages = 10000,
    this.requestTimeout = const Duration(seconds: 30),
  }) : _authorize = authorize,
       _clientFactory = clientFactory ?? http.Client.new,
       _delay = delay ?? Future<void>.delayed,
       _now = now ?? DateTime.now;

  @override
  final bool available;
  final Future<String?> Function() _authorize;
  final http.Client Function() _clientFactory;
  final Future<void> Function(Duration) _delay;
  final DateTime Function() _now;
  final int maxPages;
  final Duration requestTimeout;

  @override
  Future<List<Map<String, Object?>>> read({
    required bool Function() isCancelled,
  }) async {
    void checkCancelled() {
      if (isCancelled()) {
        throw const MicrosoftTodoException(MicrosoftTodoFailure.cancelled);
      }
    }

    if (!available) {
      throw const MicrosoftTodoException(MicrosoftTodoFailure.unavailable);
    }
    checkCancelled();
    final token = await _authorize();
    checkCancelled();
    if (token == null || token.trim().isEmpty) {
      throw const MicrosoftTodoException(MicrosoftTodoFailure.signIn);
    }
    final client = _clientFactory();
    var pages = 0;
    Future<List<Map<String, Object?>>> collection(Uri initial) async {
      final rows = <Map<String, Object?>>[];
      final visited = <String>{};
      Uri? next = initial;
      while (next != null) {
        checkCancelled();
        if (next.scheme != 'https' ||
            next.host != 'graph.microsoft.com' ||
            next.port != 443 ||
            next.userInfo.isNotEmpty ||
            next.hasFragment ||
            next.path != initial.path ||
            !visited.add(next.toString()) ||
            ++pages > maxPages) {
          throw const MicrosoftTodoException(
            MicrosoftTodoFailure.invalidResponse,
          );
        }
        http.Response? response;
        for (var attempt = 0; attempt < 3; attempt++) {
          checkCancelled();
          final request = http.Request('GET', next)
            ..followRedirects = false
            ..headers.addAll({
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            });
          final stream = await client.send(request).timeout(requestTimeout);
          response = await http.Response.fromStream(
            stream,
          ).timeout(requestTimeout);
          checkCancelled();
          if (response.statusCode != 429 && response.statusCode != 503) break;
          if (attempt < 2) {
            final wait = _retryDelay(response.headers['retry-after'], attempt);
            // Long throttles are surfaced for retry, never shortened silently.
            if (wait.isNegative || wait > const Duration(seconds: 30)) break;
            await _delay(wait);
          }
        }
        final status = response!.statusCode;
        if (status == 401) {
          throw const MicrosoftTodoException(MicrosoftTodoFailure.signIn);
        }
        if (status == 403) {
          throw const MicrosoftTodoException(MicrosoftTodoFailure.permission);
        }
        if (status != 200) {
          throw const MicrosoftTodoException(MicrosoftTodoFailure.network);
        }
        final Object? raw = jsonDecode(utf8.decode(response.bodyBytes));
        if (raw is! Map<String, Object?> || raw['value'] is! List) {
          throw const MicrosoftTodoException(
            MicrosoftTodoFailure.invalidResponse,
          );
        }
        for (final row in raw['value'] as List) {
          if (row is! Map<String, Object?>) {
            throw const MicrosoftTodoException(
              MicrosoftTodoFailure.invalidResponse,
            );
          }
          rows.add(row);
        }
        final link = raw['@odata.nextLink'];
        if (link != null && (link is! String || link.isEmpty)) {
          throw const MicrosoftTodoException(
            MicrosoftTodoFailure.invalidResponse,
          );
        }
        next = link == null ? null : Uri.parse(link as String);
      }
      return rows;
    }

    Uri endpoint(List<String> segments) => Uri(
      scheme: 'https',
      host: 'graph.microsoft.com',
      pathSegments: ['v1.0', 'me', 'todo', ...segments],
    );
    String id(Map<String, Object?> row) {
      final value = row['id'];
      if (value is! String || value.isEmpty) {
        throw const MicrosoftTodoException(
          MicrosoftTodoFailure.invalidResponse,
        );
      }
      return value;
    }

    try {
      final lists = await collection(endpoint(['lists']));
      for (final list in lists) {
        final listId = id(list);
        final tasks = await collection(endpoint(['lists', listId, 'tasks']));
        list['tasks'] = tasks;
        for (final task in tasks) {
          if (task['status'] == 'completed') continue;
          task['checklistItems'] = await collection(
            endpoint(['lists', listId, 'tasks', id(task), 'checklistItems']),
          );
        }
      }
      checkCancelled();
      return lists;
    } on MicrosoftTodoException {
      rethrow;
    } on FormatException {
      throw const MicrosoftTodoException(MicrosoftTodoFailure.invalidResponse);
    } catch (_) {
      throw const MicrosoftTodoException(MicrosoftTodoFailure.network);
    } finally {
      client.close();
    }
  }

  Duration _retryDelay(String? header, int attempt) {
    if (header != null) {
      final seconds = int.tryParse(header.trim());
      if (seconds != null) return Duration(seconds: seconds);
      try {
        // Retry-After accepts both delta seconds and an HTTP date (RFC 9110).
        final wait = HttpDate.parse(header).difference(_now().toUtc());
        return wait.isNegative ? Duration.zero : wait;
      } on HttpException {
        // A missing or unreadable header uses the bounded fallback backoff.
      }
    }
    return Duration(seconds: attempt + 1);
  }
}
