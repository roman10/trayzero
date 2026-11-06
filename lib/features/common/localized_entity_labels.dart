import '../../domain/entities/entities.dart';
import '../../l10n/gen/app_localizations.dart';

extension LocalizedItemStatusLabel on ItemStatus {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    ItemStatus.inbox => l10n.inbox,
    ItemStatus.nextAction => l10n.nextAction,
    ItemStatus.project => l10n.project,
    ItemStatus.waiting => l10n.waitingFor,
    ItemStatus.someday => l10n.somedayMaybe,
    ItemStatus.reference => l10n.reference,
    ItemStatus.calendar => l10n.calendar,
    ItemStatus.done => l10n.done,
    ItemStatus.trashed => l10n.trash,
  };
}

extension LocalizedEnergyLabel on Energy {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    Energy.low => l10n.energyLow,
    Energy.medium => l10n.energyMedium,
    Energy.high => l10n.energyHigh,
  };
}

extension LocalizedRecurrenceLabel on Recurrence {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    Recurrence.daily => l10n.recurrenceDaily,
    Recurrence.weekly => l10n.recurrenceWeekly,
    Recurrence.monthly => l10n.recurrenceMonthly,
    Recurrence.yearly => l10n.recurrenceYearly,
  };
}

extension LocalizedProjectStatusLabel on ProjectStatus {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    ProjectStatus.active => l10n.projectStatusActive,
    ProjectStatus.onHold => l10n.projectStatusOnHold,
    ProjectStatus.someday => l10n.projectStatusSomeday,
    ProjectStatus.done => l10n.projectStatusDone,
    ProjectStatus.dropped => l10n.projectStatusDropped,
  };
}
