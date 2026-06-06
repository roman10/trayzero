import 'enums.dart';

class Project {
  const Project({
    required this.id,
    required this.title,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.outcome,
    this.areaId,
    this.dueAt,
  });

  final String id;
  final String title;
  final String? outcome;
  final String? areaId;
  final ProjectStatus status;
  final DateTime? dueAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Project copyWith({
    String? title,
    String? outcome,
    bool clearOutcome = false,
    String? areaId,
    bool clearArea = false,
    ProjectStatus? status,
    DateTime? dueAt,
    bool clearDueAt = false,
    DateTime? updatedAt,
  }) {
    return Project(
      id: id,
      title: title ?? this.title,
      outcome: clearOutcome ? null : (outcome ?? this.outcome),
      areaId: clearArea ? null : (areaId ?? this.areaId),
      status: status ?? this.status,
      dueAt: clearDueAt ? null : (dueAt ?? this.dueAt),
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
