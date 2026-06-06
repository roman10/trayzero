import 'package:uuid/uuid.dart';

import '../core/id_generator.dart';

class UuidIdGenerator extends IdGenerator {
  const UuidIdGenerator();
  static const _uuid = Uuid();
  @override
  String newId() => _uuid.v4();
}
