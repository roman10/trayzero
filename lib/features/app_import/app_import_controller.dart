import '../../core/apple_reminders_gateway.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/microsoft_todo_gateway.dart';
import '../../application/read_microsoft_todo_import.dart';
import '../../application/import_from_app.dart';
import '../../application/providers.dart';
import '../../domain/import/import_plan.dart';
import '../../domain/import/import_resolution.dart';

/// Steps of the import-from-another-app flow (ADR 0008).
enum AppImportStep {
  sources,
  appleLists,
  reading,
  preview,
  importing,
  done,
  undoing,
  undone,
}

/// Why the last attempt stopped; localized by the screen.
enum AppImportError {
  unrecognized,
  noTasks,
  unreadable,
  writeFailed,
  undoFailed,
  microsoftSignIn,
  microsoftPermission,
  microsoftNetwork,
  microsoftUnavailable,
  appleDenied,
  appleUnavailable,
  appleListsChanged,
}

/// A file the user picked: its name (for Todoist's project name) and bytes.
typedef PickedImportFile = ({String name, List<int> bytes});

/// Opens the system file picker. Any file type: Android's picker cannot
/// reliably filter `.csv`/`.taskpaper`. Overridden in widget tests.
final pickImportFileProvider = Provider<Future<PickedImportFile?> Function()>(
  (ref) => () async {
    final result = await FilePicker.pickFiles(
      type: FileType.any,
      withData: true,
    );
    final file = result?.files.firstOrNull;
    final bytes = file?.bytes;
    if (file == null || bytes == null) return null;
    return (name: file.name, bytes: bytes);
  },
);

@immutable
class AppImportState {
  const AppImportState({
    this.step = AppImportStep.sources,
    this.source,
    this.plan,
    this.preview,
    this.receipt,
    this.error,
    this.appleLists = const [],
    this.selectedAppleListIds = const {},
    this.previouslyImported = false,
  });

  final AppImportStep step;
  final ImportSourceApp? source;
  final ImportPlan? plan;
  final ImportPreview? preview;
  final ImportReceipt? receipt;
  final AppImportError? error;
  final List<AppleRemindersList> appleLists;
  final Set<String> selectedAppleListIds;
  final bool previouslyImported;

  /// Back must not interrupt a write in progress.
  bool get busy =>
      step == AppImportStep.reading ||
      step == AppImportStep.importing ||
      step == AppImportStep.undoing;
}

class AppImportController extends AutoDisposeNotifier<AppImportState> {
  bool _disposed = false;

  @override
  AppImportState build() {
    _disposed = false;
    ref.onDispose(() {
      _disposed = true;
      _attempt++;
    });
    return const AppImportState();
  }

  int _attempt = 0;

  /// Cancel a Microsoft read; late browser/HTTP responses cannot change state.
  void cancelMicrosoftRead() {
    if (state.source != ImportSourceApp.microsoftToDo ||
        state.step != AppImportStep.reading) {
      return;
    }
    _attempt++;
    state = const AppImportState();
  }

  Future<void> connectMicrosoftTodo() async {
    if (state.busy) return;
    final attempt = ++_attempt;
    bool cancelled() => _disposed || attempt != _attempt;
    state = const AppImportState(
      step: AppImportStep.reading,
      source: ImportSourceApp.microsoftToDo,
    );
    try {
      final plan = await ref.read(readMicrosoftTodoImportProvider)(
        isCancelled: cancelled,
      );
      if (cancelled()) return;
      final preview = await _import.preview(plan);
      if (cancelled()) return;
      state = AppImportState(
        step: AppImportStep.preview,
        source: ImportSourceApp.microsoftToDo,
        plan: plan,
        preview: preview,
      );
    } on MicrosoftTodoException catch (e) {
      if (cancelled()) return;
      if (e.failure == MicrosoftTodoFailure.cancelled) {
        state = const AppImportState();
        return;
      }
      state = AppImportState(
        source: ImportSourceApp.microsoftToDo,
        error: switch (e.failure) {
          MicrosoftTodoFailure.unavailable =>
            AppImportError.microsoftUnavailable,
          MicrosoftTodoFailure.permission => AppImportError.microsoftPermission,
          MicrosoftTodoFailure.signIn => AppImportError.microsoftSignIn,
          _ => AppImportError.microsoftNetwork,
        },
      );
    } on ImportFormatException catch (e) {
      if (cancelled()) return;
      state = AppImportState(
        source: ImportSourceApp.microsoftToDo,
        error: e.failure == ImportFailure.noTasks
            ? AppImportError.noTasks
            : AppImportError.unreadable,
      );
    } catch (_) {
      if (cancelled()) return;
      state = const AppImportState(
        source: ImportSourceApp.microsoftToDo,
        error: AppImportError.microsoftNetwork,
      );
    }
  }

  Future<void> loadAppleLists() async {
    if (state.busy) return;
    final gateway = ref.read(appleRemindersGatewayProvider);
    state = const AppImportState(
      step: AppImportStep.reading,
      source: ImportSourceApp.appleReminders,
    );
    try {
      final lists = await gateway.requestLists();
      if (_disposed) return;
      state = AppImportState(
        step: AppImportStep.appleLists,
        source: ImportSourceApp.appleReminders,
        appleLists: List.unmodifiable(lists),
      );
    } catch (error) {
      if (_disposed) return;
      state = AppImportState(
        source: ImportSourceApp.appleReminders,
        error: _appleError(error),
      );
    }
  }

  void toggleAppleList(String id) {
    if (state.step != AppImportStep.appleLists ||
        !state.appleLists.any((list) => list.id == id)) {
      return;
    }
    final selected = {...state.selectedAppleListIds};
    if (!selected.add(id)) selected.remove(id);
    state = AppImportState(
      step: AppImportStep.appleLists,
      source: ImportSourceApp.appleReminders,
      appleLists: state.appleLists,
      selectedAppleListIds: Set.unmodifiable(selected),
    );
  }

  Future<void> previewAppleReminders() async {
    if (state.step != AppImportStep.appleLists ||
        state.selectedAppleListIds.isEmpty) {
      return;
    }
    final before = state;
    final prepare = ref.read(prepareAppleRemindersImportProvider);
    final importer = _import;
    state = AppImportState(
      step: AppImportStep.reading,
      source: before.source,
      appleLists: before.appleLists,
      selectedAppleListIds: before.selectedAppleListIds,
    );
    try {
      final plan = await prepare(
        before.appleLists,
        before.selectedAppleListIds,
      );
      final preview = await importer.preview(plan);
      if (_disposed) return;
      state = AppImportState(
        step: AppImportStep.preview,
        source: before.source,
        plan: plan,
        preview: preview,
        appleLists: before.appleLists,
        selectedAppleListIds: before.selectedAppleListIds,
      );
    } catch (error) {
      if (_disposed) return;
      state = AppImportState(
        step: AppImportStep.appleLists,
        source: before.source,
        appleLists: before.appleLists,
        selectedAppleListIds: before.selectedAppleListIds,
        error:
            error is ImportFormatException &&
                error.failure == ImportFailure.noTasks
            ? AppImportError.noTasks
            : _appleError(error),
      );
    }
  }

  AppImportError _appleError(Object error) => switch (error) {
    AppleRemindersException(failure: AppleRemindersFailure.denied) =>
      AppImportError.appleDenied,
    AppleRemindersException(failure: AppleRemindersFailure.listsChanged) =>
      AppImportError.appleListsChanged,
    _ => AppImportError.appleUnavailable,
  };

  ImportFromApp get _import => ref.read(importFromAppProvider);

  /// Picks a file and previews it as [source]; a cancelled picker is a no-op.
  Future<void> chooseFile(ImportSourceApp source) async {
    if (state.busy) return;
    final before = state;
    state = AppImportState(step: AppImportStep.reading, source: source);
    try {
      final file = await ref.read(pickImportFileProvider)();
      if (_disposed) return;
      if (file == null) {
        state = before;
        return;
      }
      await _previewWith(
        source,
        () => _import.parseFile(source, fileName: file.name, bytes: file.bytes),
      );
    } catch (_) {
      if (_disposed) return;
      state = AppImportState(source: source, error: AppImportError.unreadable);
    }
  }

  /// Previews pasted [text] as [source].
  Future<void> pasteText(ImportSourceApp source, String text) async {
    if (state.busy) return;
    await _previewWith(source, () => _import.parseText(source, text));
  }

  Future<void> _previewWith(
    ImportSourceApp source,
    ImportPlan Function() parse,
  ) async {
    state = AppImportState(step: AppImportStep.reading, source: source);
    try {
      final plan = parse();
      final preview = await _import.preview(plan);
      if (_disposed) return;
      final previouslyImported = await _import.wasImported(plan);
      if (_disposed) return;
      state = AppImportState(
        step: AppImportStep.preview,
        source: source,
        plan: plan,
        preview: preview,
        previouslyImported: previouslyImported,
      );
    } on ImportFormatException catch (e) {
      if (_disposed) return;
      state = AppImportState(
        source: source,
        error: switch (e.failure) {
          ImportFailure.unrecognized => AppImportError.unrecognized,
          ImportFailure.noTasks => AppImportError.noTasks,
          ImportFailure.unreadable => AppImportError.unreadable,
        },
      );
    } catch (_) {
      // A parser bug on odd input must not strand the flow.
      if (_disposed) return;
      state = AppImportState(source: source, error: AppImportError.unreadable);
    }
  }

  /// Back from the preview or list choice, or entering a source: nothing was written.
  void reset() {
    if (state.busy) return;
    if (state.step == AppImportStep.preview &&
        state.source == ImportSourceApp.appleReminders &&
        state.appleLists.isNotEmpty) {
      state = AppImportState(
        step: AppImportStep.appleLists,
        source: state.source,
        appleLists: state.appleLists,
        selectedAppleListIds: state.selectedAppleListIds,
      );
    } else {
      state = const AppImportState();
    }
  }

  /// Writes the previewed plan in one transaction.
  Future<void> confirm() async {
    final plan = state.plan;
    if (plan == null || state.step != AppImportStep.preview) return;
    final before = state;
    state = AppImportState(
      step: AppImportStep.importing,
      source: before.source,
      plan: plan,
      preview: before.preview,
      previouslyImported: before.previouslyImported,
    );
    try {
      final receipt = await _import(plan);
      if (_disposed) return;
      state = AppImportState(
        step: AppImportStep.done,
        source: before.source,
        preview: before.preview,
        previouslyImported: before.previouslyImported,
        receipt: receipt,
      );
    } catch (_) {
      // The transaction rolled back: nothing was added.
      if (_disposed) return;
      state = AppImportState(
        step: AppImportStep.preview,
        source: before.source,
        plan: plan,
        preview: before.preview,
        previouslyImported: before.previouslyImported,
        error: AppImportError.writeFailed,
        appleLists: before.appleLists,
        selectedAppleListIds: before.selectedAppleListIds,
      );
    }
  }

  /// Removes everything the import added.
  Future<void> undo() async {
    final receipt = state.receipt;
    if (receipt == null || state.step != AppImportStep.done) return;
    final before = state;
    state = AppImportState(
      step: AppImportStep.undoing,
      source: before.source,
      preview: before.preview,
      previouslyImported: before.previouslyImported,
      receipt: receipt,
    );
    try {
      await _import.undo(receipt);
      if (_disposed) return;
      state = AppImportState(step: AppImportStep.undone, source: before.source);
    } catch (_) {
      if (_disposed) return;
      state = AppImportState(
        step: AppImportStep.done,
        source: before.source,
        preview: before.preview,
        previouslyImported: before.previouslyImported,
        receipt: receipt,
        error: AppImportError.undoFailed,
      );
    }
  }
}

final appImportControllerProvider =
    NotifierProvider.autoDispose<AppImportController, AppImportState>(
      AppImportController.new,
    );

/// Platform filtering stays out of widget build methods.
final appImportSourcesProvider = Provider<List<ImportSourceApp>>(
  (ref) => [
    if (ref.watch(appleRemindersGatewayProvider).supported)
      ImportSourceApp.appleReminders,
    for (final source in ImportSourceApp.values)
      if (source != ImportSourceApp.appleReminders) source,
  ],
);
