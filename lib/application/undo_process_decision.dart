import '../domain/entities/entities.dart';
import 'complete_item.dart';
import 'process_inbox_decision.dart';
import 'restore_trashed_item.dart';
import 'save_item.dart';

/// Reverses one [ProcessingDecision], putting [original] (the inbox item as
/// it was before deciding) back in the inbox.
///
/// Covers every decision with `isUndoable`; Convert-to-Project creates a
/// Project row and is deliberately not reversed here.
final class UndoProcessDecision {
  UndoProcessDecision({
    required SaveItem saveItem,
    required RestoreTrashedItem restoreTrashedItem,
    required UndoComplete undoComplete,
  })  : _saveItem = saveItem,
        _restoreTrashedItem = restoreTrashedItem,
        _undoComplete = undoComplete;

  final SaveItem _saveItem;
  final RestoreTrashedItem _restoreTrashedItem;
  final UndoComplete _undoComplete;

  /// [spawnedRecurrenceId] is the value `ProcessInboxDecisionUseCase`
  /// returned for [DoItNowDecision].
  Future<void> call(
    Item original,
    ProcessingDecision decision, {
    String? spawnedRecurrenceId,
  }) async {
    switch (decision) {
      case TrashDecision():
        await _restoreTrashedItem(original);
      case DoItNowDecision():
        // Reopen first (also removes the spawned recurrence), then rewrite
        // the original so the `isTwoMin` flag set by the decision is undone.
        await _undoComplete(
          original.id,
          spawnedRecurrenceId: spawnedRecurrenceId,
        );
        await _saveItem(original);
      case ToProjectDecision():
        break;
      case ReferenceDecision() ||
          SomedayDecision() ||
          WaitingDecision() ||
          ToCalendarDecision() ||
          ToNextActionDecision():
        await _saveItem(original);
    }
  }
}
