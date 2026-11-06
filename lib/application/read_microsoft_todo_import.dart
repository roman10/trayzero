import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/microsoft_todo_gateway.dart';
import '../domain/import/import_plan.dart';
import '../domain/import/microsoft_todo_parser.dart';

/// Fetch first, then map; no partial import or database writes on read failure.
class ReadMicrosoftTodoImport {
  ReadMicrosoftTodoImport(this._gateway);
  final MicrosoftTodoGateway _gateway;

  Future<ImportPlan> call({required bool Function() isCancelled}) async {
    final lists = await _gateway.read(isCancelled: isCancelled);
    if (isCancelled()) {
      throw const MicrosoftTodoException(MicrosoftTodoFailure.cancelled);
    }
    return parseMicrosoftTodo(lists);
  }
}

final readMicrosoftTodoImportProvider = Provider<ReadMicrosoftTodoImport>(
  (ref) => ReadMicrosoftTodoImport(ref.watch(microsoftTodoGatewayProvider)),
);
