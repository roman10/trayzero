import '../domain/entities/entities.dart';
import 'complete_item.dart';
import 'convert_to_project.dart';
import 'save_item.dart';
import 'trash_item.dart';

/// Closed set of clarify-step outcomes from the Process Inbox flow. One
/// variant per terminal branch of GTD's decision tree.
sealed class ProcessingDecision {
  const ProcessingDecision();

  /// Whether `UndoProcessDecision` can reverse this decision. Turning an item
  /// into a Project also creates a Project row, which Undo does not unwind.
  bool get isUndoable => this is! ToProjectDecision;
}

class TrashDecision extends ProcessingDecision {
  const TrashDecision();
}

class ReferenceDecision extends ProcessingDecision {
  const ReferenceDecision();
}

class SomedayDecision extends ProcessingDecision {
  const SomedayDecision();
}

class DoItNowDecision extends ProcessingDecision {
  const DoItNowDecision();
}

class WaitingDecision extends ProcessingDecision {
  const WaitingDecision(this.waitingOn);
  final String? waitingOn;
}

class ToProjectDecision extends ProcessingDecision {
  const ToProjectDecision();
}

class ToCalendarDecision extends ProcessingDecision {
  const ToCalendarDecision({this.deferUntil, this.recurrence});
  final DateTime? deferUntil;

  /// Quick-pick cadence chosen in triage, or null for a one-off event. Only
  /// the frequency is set here (interval 1, anchor-derived qualifiers);
  /// finer tuning lives in the item editor.
  final Recurrence? recurrence;
}

class ToNextActionDecision extends ProcessingDecision {
  const ToNextActionDecision({
    this.contextId,
    this.energy,
    this.timeEstimateMinutes,
    this.projectId,
    this.deferUntil,
    this.recurrence,
  });
  final String? contextId;
  final Energy? energy;
  final int? timeEstimateMinutes;
  final String? projectId;
  final DateTime? deferUntil;

  /// Quick-pick cadence chosen in triage, anchored on [deferUntil]. Null for
  /// a one-off action.
  final Recurrence? recurrence;
}

/// Single entry point that takes the current inbox item plus a decision
/// and dispatches to the right downstream use case.
final class ProcessInboxDecisionUseCase {
  ProcessInboxDecisionUseCase({
    required SaveItem saveItem,
    required TrashItem trashItem,
    required CompleteItem completeItem,
    required ConvertToProject convertToProject,
  })  : _saveItem = saveItem,
        _trashItem = trashItem,
        _completeItem = completeItem,
        _convertToProject = convertToProject;

  final SaveItem _saveItem;
  final TrashItem _trashItem;
  final CompleteItem _completeItem;
  final ConvertToProject _convertToProject;

  /// Returns the id of the recurrence instance spawned by [DoItNowDecision]
  /// (null otherwise), which `UndoProcessDecision` needs to remove it again.
  Future<String?> call(Item current, ProcessingDecision decision) async {
    switch (decision) {
      case TrashDecision():
        // Soft delete: the Process screen offers Undo; PurgeTrash finishes it.
        await _trashItem(current.id);
      case ReferenceDecision():
        await _saveItem(current.copyWith(status: ItemStatus.reference));
      case SomedayDecision():
        await _saveItem(current.copyWith(status: ItemStatus.someday));
      case DoItNowDecision():
        // Mark done via CompleteItem so recurrence rollover + reminder
        // cancellation are honoured even for two-min items.
        await _saveItem(current.copyWith(isTwoMin: true));
        return _completeItem(current.id);
      case WaitingDecision(:final waitingOn):
        await _saveItem(current.copyWith(
          status: ItemStatus.waiting,
          waitingOn: waitingOn,
          clearWaitingOn: waitingOn == null,
        ));
      case ToProjectDecision():
        await _convertToProject(current);
      case ToCalendarDecision(:final deferUntil, :final recurrence):
        // A calendar item lives on the GTD "hard landscape": it has a
        // deadline (`dueAt`) and a single "Due:" reminder. It is NOT
        // visibility-gated, so `deferUntil` is cleared — keeping both set
        // double-fired "Due:" + "Ready:" at the same instant.
        final effectiveDue = deferUntil ?? current.dueAt;
        await _saveItem(current.copyWith(
          status: ItemStatus.calendar,
          dueAt: effectiveDue,
          clearDueAt: effectiveDue == null,
          clearDeferUntil: true,
          // Recurrence needs a date anchor; the calendar anchor is `dueAt`,
          // so only honour the quick-pick when one actually exists.
          recurrence: effectiveDue == null ? null : recurrence,
        ));
      case ToNextActionDecision(
          :final contextId,
          :final energy,
          :final timeEstimateMinutes,
          :final projectId,
          :final deferUntil,
          :final recurrence,
        ):
        await _saveItem(current.copyWith(
          status: ItemStatus.nextAction,
          contextId: contextId,
          clearContext: contextId == null,
          energy: energy,
          clearEnergy: energy == null,
          timeEstimateMinutes: timeEstimateMinutes,
          clearTimeEstimate: timeEstimateMinutes == null,
          projectId: projectId,
          clearProject: projectId == null,
          deferUntil: deferUntil,
          clearDeferUntil: deferUntil == null,
          // A next action's only date anchor is `deferUntil`: it lives off the
          // calendar, so any captured `dueAt` is dropped here (SaveItem also
          // enforces this — stated explicitly to keep intent local) and a
          // stray cadence is dropped rather than left with nothing to repeat
          // on.
          clearDueAt: true,
          recurrence: deferUntil == null ? null : recurrence,
        ));
    }
    return null;
  }
}
