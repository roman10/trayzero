import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Safe, localized-at-the-UI failure categories. Never expose OAuth or Graph
/// response bodies: they may contain credentials or private task content.
enum MicrosoftTodoFailure {
  unavailable,
  cancelled,
  signIn,
  permission,
  network,
  invalidResponse,
}

final class MicrosoftTodoException implements Exception {
  const MicrosoftTodoException(this.failure);
  final MicrosoftTodoFailure failure;

  @override
  String toString() => 'MicrosoftTodoException(${failure.name})';
}

/// One-time read of Graph lists, each with a fully fetched `tasks` array;
/// each open task includes its fully fetched `checklistItems` array.
/// No credential is returned to the application or presentation layer.
abstract class MicrosoftTodoGateway {
  bool get available;
  Future<List<Map<String, Object?>>> read({
    required bool Function() isCancelled,
  });
}

class UnavailableMicrosoftTodoGateway implements MicrosoftTodoGateway {
  const UnavailableMicrosoftTodoGateway();
  @override
  bool get available => false;
  @override
  Future<List<Map<String, Object?>>> read({
    required bool Function() isCancelled,
  }) async =>
      throw const MicrosoftTodoException(MicrosoftTodoFailure.unavailable);
}

final microsoftTodoGatewayProvider = Provider<MicrosoftTodoGateway>(
  (ref) => const UnavailableMicrosoftTodoGateway(),
);
