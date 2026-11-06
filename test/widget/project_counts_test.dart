import 'package:cleartray/domain/entities/entities.dart';
import 'package:cleartray/features/projects/projects_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

void main() {
  test('projectNextActionCount counts only next actions', () {
    final items = [
      anItem(status: ItemStatus.nextAction),
      anItem(status: ItemStatus.nextAction),
      anItem(status: ItemStatus.waiting),
      anItem(status: ItemStatus.someday),
      anItem(status: ItemStatus.reference),
      anItem(status: ItemStatus.calendar),
    ];
    expect(projectNextActionCount(items), 2);
  });
}
