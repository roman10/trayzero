import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/process_inbox_decision.dart';
import '../../application/providers.dart';
import '../../domain/entities/entities.dart';

/// Steps in the GTD clarify flow. Indices correspond to the step widgets in
/// `process_inbox_screen.dart`. The trailing `detail` step is the only
/// terminal step that needs draft fields before the decision is final.
enum ProcessStep { actionable, twoMin, delegate, singleStep, defer, detail }

const _stepOrder = ProcessStep.values;
int get processStepCount => _stepOrder.length;

@immutable
class ProcessInboxState {
  const ProcessInboxState({
    this.step = ProcessStep.actionable,
    this.waitingOn,
    this.defer,
    this.recurrence,
    this.selectedContextId,
    this.energy,
    this.timeEstimate,
    this.selectedProjectId,
    this.doneNow = 0,
    this.filed = 0,
    this.trashed = 0,
  });

  final ProcessStep step;
  final String? waitingOn;
  final DateTime? defer;

  /// Quick-pick cadence chosen on the defer-until path; applied when the
  /// item is filed as a next action. Null = one-off.
  final Recurrence? recurrence;
  final String? selectedContextId;
  final Energy? energy;
  final int? timeEstimate;
  final String? selectedProjectId;
  final int doneNow;
  final int filed;
  final int trashed;

  int get stepIndex => _stepOrder.indexOf(step);
  bool get canGoBack => stepIndex > 0;

  ProcessInboxState copyWith({
    ProcessStep? step,
    String? waitingOn,
    bool clearWaitingOn = false,
    DateTime? defer,
    bool clearDefer = false,
    Recurrence? recurrence,
    bool clearRecurrence = false,
    String? selectedContextId,
    bool clearSelectedContext = false,
    Energy? energy,
    bool clearEnergy = false,
    int? timeEstimate,
    bool clearTimeEstimate = false,
    String? selectedProjectId,
    bool clearSelectedProject = false,
    int? doneNow,
    int? filed,
    int? trashed,
  }) =>
      ProcessInboxState(
        step: step ?? this.step,
        waitingOn:
            clearWaitingOn ? null : (waitingOn ?? this.waitingOn),
        defer: clearDefer ? null : (defer ?? this.defer),
        recurrence:
            clearRecurrence ? null : (recurrence ?? this.recurrence),
        selectedContextId: clearSelectedContext
            ? null
            : (selectedContextId ?? this.selectedContextId),
        energy: clearEnergy ? null : (energy ?? this.energy),
        timeEstimate:
            clearTimeEstimate ? null : (timeEstimate ?? this.timeEstimate),
        selectedProjectId: clearSelectedProject
            ? null
            : (selectedProjectId ?? this.selectedProjectId),
        doneNow: doneNow ?? this.doneNow,
        filed: filed ?? this.filed,
        trashed: trashed ?? this.trashed,
      );
}

/// Holds the wizard state and dispatches the chosen [ProcessingDecision]
/// through the application layer. The widget tree is purely declarative
/// against this controller.
class ProcessInboxController extends Notifier<ProcessInboxState> {
  /// Id of the inbox item the wizard is currently clarifying. The clarify
  /// flow is per-item: when the head of the inbox changes (a decision filed
  /// the item, a skip deferred it, or a fresh capture jumped the queue), the
  /// step pointer and draft fields must restart from step 1. Driving that
  /// reset off the stream — rather than each decision call site — keeps the
  /// item list and the step pointer from ever disagreeing about which item
  /// is on screen, and means no future code path can forget to reset.
  String? _clarifyingId;

  @override
  ProcessInboxState build() {
    ref.listen(inboxItemsProvider, (_, next) {
      final list = next.valueOrNull;
      final headId =
          (list != null && list.isNotEmpty) ? list.first.id : null;
      if (headId == _clarifyingId) return;
      _clarifyingId = headId;
      state = ProcessInboxState(
        doneNow: state.doneNow,
        filed: state.filed,
        trashed: state.trashed,
      );
    });
    return const ProcessInboxState();
  }

  void advance() {
    final next = (state.stepIndex + 1).clamp(0, _stepOrder.length - 1);
    state = state.copyWith(step: _stepOrder[next]);
  }

  void back() {
    final prev = (state.stepIndex - 1).clamp(0, _stepOrder.length - 1);
    state = state.copyWith(step: _stepOrder[prev]);
  }

  void setWaitingOn(String? v) =>
      state = state.copyWith(waitingOn: v, clearWaitingOn: v == null);
  void setDefer(DateTime? v) =>
      state = state.copyWith(defer: v, clearDefer: v == null);
  void setRecurrence(Recurrence? v) =>
      state = state.copyWith(recurrence: v, clearRecurrence: v == null);
  void setSelectedContext(String? v) => state = state.copyWith(
        selectedContextId: v,
        clearSelectedContext: v == null,
      );
  void setEnergy(Energy? v) =>
      state = state.copyWith(energy: v, clearEnergy: v == null);
  void setTimeEstimate(int? v) =>
      state = state.copyWith(timeEstimate: v, clearTimeEstimate: v == null);
  void setSelectedProject(String? v) => state = state.copyWith(
        selectedProjectId: v,
        clearSelectedProject: v == null,
      );

  /// Persists the decision, then bumps the session tally. The step pointer
  /// resets itself once [inboxItemsProvider] drops [current] and the build
  /// listener sees a new head item — so a thrown decision leaves the item,
  /// step, and tally untouched for a clean retry.
  Future<void> decide(Item current, ProcessingDecision decision) async {
    await ref.read(processInboxDecisionProvider).call(current, decision);
    state = switch (decision) {
      TrashDecision() => state.copyWith(trashed: state.trashed + 1),
      DoItNowDecision() => state.copyWith(doneNow: state.doneNow + 1),
      _ => state.copyWith(filed: state.filed + 1),
    };
  }

  /// Re-queues [current] to the back of the inbox. Unlike [decide], skip
  /// leaves the item *in* the inbox, so when it is the only item the head
  /// never changes and the build listener never fires — skip therefore
  /// restarts the flow explicitly, both to give visible feedback and to
  /// honour its intent: "abandon my progress on this one for now."
  Future<void> skip(Item current) async {
    await ref.read(skipInboxItemProvider).call(current);
    state = ProcessInboxState(
      doneNow: state.doneNow,
      filed: state.filed,
      trashed: state.trashed,
    );
  }
}

final processInboxControllerProvider =
    NotifierProvider<ProcessInboxController, ProcessInboxState>(
  ProcessInboxController.new,
);
