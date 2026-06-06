import '../core/clock.dart';
import '../core/notification_intent.dart';
import '../core/notification_scheduler.dart';
import 'complete_item.dart';
import 'move_item_to_next_actions.dart';

/// Turns one notification interaction into its effect.
///
/// All decisioning is pure ([decideNotificationResponse]); this use case
/// only performs the chosen effect, so the platform glue in `main.dart`
/// stays a one-liner and the mapping is unit-testable end to end.
///
/// [navigate] is injected (a go_router `.go`) rather than depending on the
/// router so this layer has no Flutter/UI import and tests can assert
/// navigation without a widget tree.
final class HandleNotificationResponse {
  HandleNotificationResponse({
    required NotificationScheduler scheduler,
    required CompleteItem completeItem,
    required MoveItemToNextActions moveToNextActions,
    required Clock clock,
    required void Function(String location) navigate,
  })  : _scheduler = scheduler,
        _completeItem = completeItem,
        _moveToNextActions = moveToNextActions,
        _clock = clock,
        _navigate = navigate;

  final NotificationScheduler _scheduler;
  final CompleteItem _completeItem;
  final MoveItemToNextActions _moveToNextActions;
  final Clock _clock;
  final void Function(String location) _navigate;

  Future<void> call(NotificationActionEvent event) async {
    final payload = NotificationPayload.tryDecode(event.payload);
    if (payload == null) return;
    final decision = decideNotificationResponse(
      payload: payload,
      actionId: event.actionId,
      now: _clock.now(),
    );
    switch (decision) {
      case OpenScreen(:final location):
        _navigate(location);
      case RescheduleAt(payload: final p, :final at):
        // Re-arm under the same OS id so the snoozed reminder replaces,
        // not duplicates, the original.
        if (event.id == null) return;
        await _scheduler.schedule(
          id: event.id!,
          at: at,
          title: p.title,
          body: p.body,
          payload: p.encode(),
        );
      case CompleteItemDecision(:final itemId):
        await _completeItem.call(itemId);
      case MoveToNextActionsDecision(:final itemId):
        await _moveToNextActions.call(itemId);
    }
  }
}
