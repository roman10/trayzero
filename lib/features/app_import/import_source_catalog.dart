import '../../domain/import/import_plan.dart';
import '../../l10n/gen/app_localizations.dart';

/// How a source is grouped on the import list (ADR 0008).
enum ImportSourceGroup { direct, file, paste }

/// Short badge shown on rows that are not an export-file import.
enum ImportMethod { onDevice, signIn }

/// Devices Things exports differ on (its steps are not the same).
enum ThingsDevice { ios, mac }

typedef ImportText = String Function(AppLocalizations l10n);

/// Everything the list and source pages show for one [ImportSourceApp].
class ImportSourceSpec {
  const ImportSourceSpec({
    required this.name,
    required this.subtitle,
    required this.group,
    this.method,
    this.steps = const [],
    this.macSteps,
    this.note,
    this.fallbackHint,
    this.acceptsPaste = false,
  });

  final ImportText name;
  final ImportText subtitle;
  final ImportSourceGroup group;
  final ImportMethod? method;

  /// Numbered steps. When empty the page falls back to [fallbackHint].
  final List<ImportText> steps;

  /// Things only: steps for the Mac variant ([steps] is iPhone/iPad).
  final List<ImportText>? macSteps;
  final ImportText? note;
  final ImportText? fallbackHint;

  /// Sources whose export is text the user can copy, so pasting is offered.
  final bool acceptsPaste;

  List<ImportText> stepsFor(ThingsDevice device) =>
      device == ThingsDevice.mac && macSteps != null ? macSteps! : steps;

  /// Steps to show: the localized list, or the legacy hint as one step.
  List<String> resolveSteps(AppLocalizations l10n, ThingsDevice device) {
    final list = stepsFor(device);
    if (list.isNotEmpty) return [for (final s in list) s(l10n)];
    final hint = fallbackHint;
    return hint == null ? const [] : [hint(l10n)];
  }
}

/// The code Things asks for on iPhone/iPad to send its database.
const thingsDiagnosticsCode = '491348';

final Map<ImportSourceApp, ImportSourceSpec> importSourceCatalog = {
  ImportSourceApp.appleReminders: ImportSourceSpec(
    name: (_) => 'Apple Reminders',
    subtitle: (l) => l.importSubApple,
    group: ImportSourceGroup.direct,
    method: ImportMethod.onDevice,
    steps: [
      (l) => l.importStepApple1,
      (l) => l.importStepApple2,
      (l) => l.importStepApple3,
    ],
    note: (l) => l.importNoteApple,
    fallbackHint: (l) => l.importAppleHint,
  ),
  ImportSourceApp.microsoftToDo: ImportSourceSpec(
    name: (_) => 'Microsoft To Do',
    subtitle: (l) => l.importSubMicrosoft,
    group: ImportSourceGroup.direct,
    method: ImportMethod.signIn,
    steps: [
      (l) => l.importStepMicrosoft1,
      (l) => l.importStepMicrosoft2,
      (l) => l.importStepMicrosoft3,
    ],
    note: (l) => l.importNoteMicrosoft,
    fallbackHint: (l) => l.importHintMicrosoftTodo,
  ),
  ImportSourceApp.googleTasks: ImportSourceSpec(
    name: (_) => 'Google Tasks',
    subtitle: (l) => l.importSubGoogleTasks,
    group: ImportSourceGroup.file,
    steps: [
      (l) => l.importStepGoogleTasks1,
      (l) => l.importStepGoogleTasks2,
      (l) => l.importStepGoogleTasks3,
    ],
    note: (l) => l.importNoteGoogleTasks,
    fallbackHint: (l) => l.importHintGoogleTasks,
  ),
  ImportSourceApp.todoist: ImportSourceSpec(
    name: (_) => 'Todoist',
    subtitle: (l) => l.importSubTodoist,
    group: ImportSourceGroup.file,
    steps: [
      (l) => l.importStepTodoist1,
      (l) => l.importStepTodoist2,
      (l) => l.importStepTodoist3,
    ],
    fallbackHint: (l) => l.importHintTodoist,
  ),
  ImportSourceApp.things: ImportSourceSpec(
    name: (_) => 'Things 3',
    subtitle: (l) => l.importSubThings,
    group: ImportSourceGroup.file,
    steps: [
      (l) => l.importStepThingsIos1,
      (l) => l.importStepThingsIos2,
      (l) => l.importStepThingsIos3,
      (l) => l.importStepThingsIos4,
    ],
    macSteps: [
      (l) => l.importStepThingsMac1,
      (l) => l.importStepThingsMac2,
      (l) => l.importStepThingsMac3,
    ],
    note: (l) => l.importNoteThings,
    fallbackHint: (l) => l.importHintThings,
  ),
  ImportSourceApp.tickTick: ImportSourceSpec(
    name: (_) => 'TickTick',
    subtitle: (l) => l.importSubTickTick,
    group: ImportSourceGroup.file,
    steps: [
      (l) => l.importStepTickTick1,
      (l) => l.importStepTickTick2,
      (l) => l.importStepTickTick3,
    ],
    fallbackHint: (l) => l.importHintTickTick,
  ),
  ImportSourceApp.nirvana: ImportSourceSpec(
    name: (_) => 'Nirvana',
    subtitle: (l) => l.importSubNirvana,
    group: ImportSourceGroup.file,
    steps: [(l) => l.importStepNirvana1, (l) => l.importStepNirvana2],
    fallbackHint: (l) => l.importHintNirvana,
  ),
  ImportSourceApp.omniFocus: ImportSourceSpec(
    name: (_) => 'OmniFocus',
    subtitle: (l) => l.importSubOmniFocus,
    group: ImportSourceGroup.file,
    steps: [
      (l) => l.importStepOmniFocus1,
      (l) => l.importStepOmniFocus2,
      (l) => l.importStepOmniFocus3,
    ],
    fallbackHint: (l) => l.importHintOmniFocus,
    acceptsPaste: true,
  ),
  ImportSourceApp.plainText: ImportSourceSpec(
    name: (l) => l.importSourcePlainText,
    subtitle: (l) => l.importSubPlainText,
    group: ImportSourceGroup.paste,
    steps: [(l) => l.importStepPlainText1, (l) => l.importStepPlainText2],
    note: (l) => l.importNotePlainText,
    fallbackHint: (l) => l.importHintPlainText,
    acceptsPaste: true,
  ),
};

ImportSourceSpec importSpec(ImportSourceApp source) =>
    importSourceCatalog[source]!;
