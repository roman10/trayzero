import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/current_time.dart';
import '../../application/providers.dart';
import '../../domain/entities/entities.dart';
import '../../domain/project_movement.dart';

/// Progress is written before the displayed step changes. A failed write keeps
/// the current step available for retry; leaving never marks a Review complete.
class WeeklyReviewController extends AutoDisposeAsyncNotifier<ReviewLog> {
  bool _saving = false;

  @override
  Future<ReviewLog> build() => ref.read(startWeeklyReviewProvider).call();

  Future<bool> moveTo(WeeklyReviewStep step) async {
    final review = state.valueOrNull;
    if (_saving || review == null) return false;
    _saving = true;
    try {
      await ref.read(saveWeeklyReviewStepProvider).call(review.id, step);
      state = AsyncData(
        ReviewLog(
          id: review.id,
          type: review.type,
          startedAt: review.startedAt,
          notes: review.notes,
          currentStep: step,
        ),
      );
      return true;
    } finally {
      _saving = false;
    }
  }

  Future<bool> finish() async {
    final review = state.valueOrNull;
    if (_saving || review == null) return false;
    _saving = true;
    try {
      await ref.read(finishWeeklyReviewProvider).call(review.id);
      return true;
    } finally {
      _saving = false;
    }
  }
}

final weeklyReviewControllerProvider =
    AsyncNotifierProvider.autoDispose<WeeklyReviewController, ReviewLog>(
      WeeklyReviewController.new,
    );

class ReviewProject {
  const ReviewProject(this.project, this.movement, {this.inactive = false});
  final Project project;
  final ProjectMovement movement;

  /// Active, but no linked Item created, edited, or completed in
  /// [inactiveProjectDays] days (ADR 0007).
  final bool inactive;
}

/// Days without action activity after which an active Project is flagged.
const inactiveProjectDays = 14;

/// Whether an active Project has gone quiet: its latest Item activity (or,
/// when newer or absent, its own creation) is [inactiveProjectDays] or more
/// days before [now].
bool isProjectInactive(Project project, DateTime? lastActivity, DateTime now) {
  if (project.status != ProjectStatus.active) return false;
  final created = project.createdAt;
  final last = lastActivity == null || created.isAfter(lastActivity)
      ? created
      : lastActivity;
  return !last.isAfter(now.subtract(const Duration(days: inactiveProjectDays)));
}

/// Review active Projects first: stalled ones (no next action) at the top,
/// then inactive ones, then the rest. Waiting and scheduled work count as
/// movement, matching the Project detail policy. The order ignores review
/// state so cards don't jump when the user marks one reviewed.
List<ReviewProject> reviewProjects(
  List<Project> projects,
  List<Item> items, {
  Map<String, DateTime> activity = const {},
  DateTime? now,
}) {
  final byProject = <String, List<Item>>{};
  for (final item in items) {
    if (item.projectId != null) (byProject[item.projectId!] ??= []).add(item);
  }
  final result = projects
      .where(
        (p) =>
            p.status != ProjectStatus.done && p.status != ProjectStatus.dropped,
      )
      .map(
        (p) => ReviewProject(
          p,
          projectMovement(byProject[p.id] ?? const []),
          inactive: now != null && isProjectInactive(p, activity[p.id], now),
        ),
      )
      .toList();
  int priority(ReviewProject p) => p.project.status != ProjectStatus.active
      ? 3
      : p.movement == ProjectMovement.stalled
      ? 0
      : p.inactive
      ? 1
      : 2;
  result.sort((a, b) {
    final rank = priority(a).compareTo(priority(b));
    if (rank != 0) return rank;
    final title = a.project.title.toLowerCase().compareTo(
      b.project.title.toLowerCase(),
    );
    return title != 0 ? title : a.project.id.compareTo(b.project.id);
  });
  return result;
}

List<Item> reviewStepItems(
  List<Item> items,
  WeeklyReviewStep step,
  DateTime now,
) {
  final status = switch (step) {
    WeeklyReviewStep.capture || WeeklyReviewStep.inbox => ItemStatus.inbox,
    WeeklyReviewStep.actions => ItemStatus.nextAction,
    WeeklyReviewStep.waiting => ItemStatus.waiting,
    WeeklyReviewStep.calendar => ItemStatus.calendar,
    WeeklyReviewStep.someday => ItemStatus.someday,
    WeeklyReviewStep.projects => null,
  };
  final end = now.isUtc
      ? DateTime.utc(now.year, now.month, now.day + 15)
      : DateTime(now.year, now.month, now.day + 15);
  final result = items
      .where(
        (i) =>
            i.status == status &&
            i.completedAt == null &&
            (step != WeeklyReviewStep.calendar ||
                (i.dueAt != null && i.dueAt!.isBefore(end))),
      )
      .toList();
  if (step == WeeklyReviewStep.calendar) {
    result.sort((a, b) => a.dueAt!.compareTo(b.dueAt!));
  }
  return result;
}

final weeklyReviewItemsProvider = Provider.autoDispose
    .family<AsyncValue<List<Item>>, WeeklyReviewStep>((ref, step) {
      final now = ref.watch(currentTimeProvider);
      return ref
          .watch(reviewItemsProvider)
          .whenData((items) => reviewStepItems(items, step, now));
    });

final weeklyReviewProjectsProvider =
    Provider.autoDispose<AsyncValue<List<ReviewProject>>>((ref) {
      final projects = ref.watch(projectsProvider);
      final items = ref.watch(reviewItemsProvider);
      final now = ref.watch(currentTimeProvider);
      // Activity only adds a flag; the list doesn't wait for it.
      final activity =
          ref.watch(projectActivityProvider).valueOrNull ?? const {};
      if (projects.hasError) {
        return AsyncError(projects.error!, projects.stackTrace!);
      }
      if (items.hasError) return AsyncError(items.error!, items.stackTrace!);
      if (!projects.hasValue || !items.hasValue) return const AsyncLoading();
      return AsyncData(
        reviewProjects(
          projects.value!,
          items.value!,
          activity: activity,
          now: now,
        ),
      );
    });
