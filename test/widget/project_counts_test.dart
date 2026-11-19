import 'package:cleartray/domain/entities/entities.dart';
import 'package:cleartray/features/projects/projects_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('projectNextActionCount counts only next actions', () {
    final counts = {
      ItemStatus.nextAction: 2,
      ItemStatus.waiting: 1,
      ItemStatus.someday: 1,
      ItemStatus.reference: 1,
      ItemStatus.calendar: 1,
    };
    expect(projectNextActionCount(counts), 2);
    expect(projectNextActionCount(const {}), 0);
  });
}
