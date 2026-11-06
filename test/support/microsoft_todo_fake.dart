import 'dart:convert';
import 'dart:io';

import 'package:cleartray/core/microsoft_todo_gateway.dart';

List<Map<String, Object?>> microsoftTodoSnapshot() =>
    (jsonDecode(
              File(
                'test/fixtures/import/microsoft_todo_graph.json',
              ).readAsStringSync(),
            )
            as List)
        .cast<Map<String, Object?>>();

class FakeMicrosoftTodoGateway implements MicrosoftTodoGateway {
  FakeMicrosoftTodoGateway({this.available = true, this.onRead});
  @override
  final bool available;
  final Future<List<Map<String, Object?>>> Function(bool Function())? onRead;
  int reads = 0;
  @override
  Future<List<Map<String, Object?>>> read({
    required bool Function() isCancelled,
  }) async {
    reads++;
    return onRead == null ? microsoftTodoSnapshot() : onRead!(isCancelled);
  }
}
