// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Trayzero';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get add => 'Add';

  @override
  String get ok => 'OK';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get skip => 'Skip';

  @override
  String get done => 'Done';

  @override
  String get retry => 'Retry';

  @override
  String get settings => 'Settings';

  @override
  String get enable => 'Enable';

  @override
  String get none => 'None';

  @override
  String get notSet => 'Not set';

  @override
  String get search => 'Search';

  @override
  String get select => 'Select';

  @override
  String get selectAll => 'All';

  @override
  String get selectNone => 'None';

  @override
  String get rename => 'Rename';

  @override
  String get inbox => 'Inbox';

  @override
  String get doVerb => 'Do';

  @override
  String get projects => 'Projects';

  @override
  String get review => 'Review';

  @override
  String get more => 'More';

  @override
  String get navInbox => 'Inbox';

  @override
  String get navDo => 'Do';

  @override
  String get navProjects => 'Projects';

  @override
  String get navReview => 'Review';

  @override
  String get navMore => 'More';

  @override
  String get capture => 'Capture';

  @override
  String get clarify => 'Clarify';

  @override
  String get organize => 'Organize';

  @override
  String get reflect => 'Reflect';

  @override
  String get engage => 'Engage';

  @override
  String get nextAction => 'Next action';

  @override
  String get waitingFor => 'Waiting for';

  @override
  String get someday => 'Someday';

  @override
  String get somedayMaybe => 'Someday / Maybe';

  @override
  String get reference => 'Reference';

  @override
  String get calendar => 'Calendar';

  @override
  String get project => 'Project';

  @override
  String get completed => 'Completed';

  @override
  String get scheduled => 'Scheduled';

  @override
  String get needsClarifying => 'Needs clarifying';

  @override
  String get howGtdWorks => 'How GTD works';

  @override
  String get whatIsGtd => 'What is GTD?';

  @override
  String get onboardingPage1Title => 'Get it out of your head';

  @override
  String get onboardingPage1Body =>
      'Anything that has your attention — a task, an idea, a worry — goes into the Inbox. The point is to free your mind, not to organize yet.';

  @override
  String get onboardingPage2Title => 'Clarify, one item at a time';

  @override
  String get onboardingPage2Body =>
      'The Process flow walks each captured item through the GTD decision tree: is it actionable? Less than two minutes? Delegate? A project? A next action?';

  @override
  String get onboardingPage3Title => 'Engage when you have time';

  @override
  String get onboardingPage3Body =>
      'The Do tab filters next actions by context, energy and time available, so you always know what you could be doing right now.';

  @override
  String get onboardingPage4Title => 'Review to stay trustworthy';

  @override
  String get onboardingPage4Body =>
      'Weekly Reviews keep the system honest. Once a week, run through every list, empty your inbox, and look ahead.';

  @override
  String get onboardingSeedTitle => 'You\'re ready';

  @override
  String get onboardingSeedBody =>
      'Default contexts (@phone, @computer, @errands, @home, @office, @anywhere, @waiting) are seeded for you. You can add or edit them in Settings.';

  @override
  String get onboardingSeedSampleLabel => 'Seed a sample project';

  @override
  String get onboardingSeedSampleSubtitle =>
      'Adds a starter project plus a few items so the app isn\'t empty.';

  @override
  String get onboardingFinish => 'Let\'s go';

  @override
  String get inboxEmptyTitle => 'Inbox zero';

  @override
  String get inboxEmptyMessage =>
      'Nothing to clarify. Tap Capture to brain-dump anything that has your attention — you\'ll process it later.';

  @override
  String get inboxEmptyAction => 'Capture something';

  @override
  String inboxItemsToClarify(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items to clarify',
      one: '1 item to clarify',
      zero: 'No items to clarify',
    );
    return '$_temp0';
  }

  @override
  String get processInbox => 'Process inbox';

  @override
  String deleteItemsConfirmTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Delete $count items?',
      one: 'Delete 1 item?',
    );
    return '$_temp0';
  }

  @override
  String get deleteItemsConfirmBody =>
      'This permanently removes them and their attachments. This can\'t be undone.';

  @override
  String deletedItemsSnackbar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Deleted $count items.',
      one: 'Deleted 1 item.',
    );
    return '$_temp0';
  }

  @override
  String filedItemsSnackbar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Filed $count into the project.',
      one: 'Filed 1 into the project.',
    );
    return '$_temp0';
  }

  @override
  String movedItemsSnackbar(int count, String destination) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Moved $count to $destination.',
      one: 'Moved 1 to $destination.',
    );
    return '$_temp0';
  }

  @override
  String selectionCountTitle(int count) {
    return '$count selected';
  }

  @override
  String get captureTitle => 'Brain dump';

  @override
  String get captureHint => 'What\'s on your mind?';

  @override
  String get captureNotesHint => 'Notes (optional)';

  @override
  String get captureEmptyError => 'Enter something to capture';

  @override
  String get captureSubmit => 'Add to inbox';

  @override
  String get dictate => 'Dictate';

  @override
  String get stopDictation => 'Stop dictation';

  @override
  String get processTitle => 'Process inbox';

  @override
  String get processCompleteTitle => 'Inbox zero!';

  @override
  String get processCompleteNoItems => 'There is nothing to clarify.';

  @override
  String processCompleteStats(int filed, int doneNow, int trashed) {
    return 'You filed $filed, knocked out $doneNow in under 2 minutes, and trashed $trashed. Nicely done.';
  }

  @override
  String processStepCounter(int step, int total) {
    return 'Step $step of $total';
  }

  @override
  String processItemsRemaining(int count) {
    return '$count left';
  }

  @override
  String get previousStepTooltip => 'Previous step';

  @override
  String get skipItemTooltip => 'Skip';

  @override
  String get actionableQuestion => 'Is this actionable?';

  @override
  String get actionableYes => 'Yes — there is something to do';

  @override
  String get actionableReference => 'No — keep as reference';

  @override
  String get actionableSomeday => 'No — someday / maybe';

  @override
  String get actionableTrash => 'Trash';

  @override
  String get twoMinQuestion => 'Will it take less than 2 minutes?';

  @override
  String get twoMinYes => 'Yes — I\'ll do it now';

  @override
  String get twoMinNo => 'No';

  @override
  String get delegateQuestion => 'Can someone else do it?';

  @override
  String get waitingOnPromptTitle => 'Who are you waiting on?';

  @override
  String get waitingOnPromptHint => 'Name or system';

  @override
  String get multiStepQuestion => 'Does it need more than one step?';

  @override
  String get recurrencePrompt => 'Repeat?';

  @override
  String get recurrenceOff => 'Doesn\'t repeat';

  @override
  String get capturedLabel => 'CAPTURED';

  @override
  String get engageTitle => 'Do now';

  @override
  String get engageEmptyTitle => 'No next actions yet';

  @override
  String get engageEmptyMessage =>
      'Capture something or process your inbox to build your next actions list.';

  @override
  String get engageInlineEmpty =>
      'No next actions yet — capture or process your inbox.';

  @override
  String get engageOpenInbox => 'Open inbox';

  @override
  String get engageNoMatchTitle => 'Nothing matches';

  @override
  String get engageNoMatchMessage =>
      'No actions match the current filters. Try widening them or clear the filter.';

  @override
  String get hardLandscape => 'Hard landscape';

  @override
  String get hardLandscapeSubtitle => 'due today & overdue';

  @override
  String get filterAllContexts => 'All contexts';

  @override
  String get filterAnyTime => 'Any time';

  @override
  String get filterUnder5m => '< 5m';

  @override
  String get filterUnder15m => '< 15m';

  @override
  String get filterUnder30m => '< 30m';

  @override
  String get filterUnder1h => '< 1h';

  @override
  String get filterAnyEnergy => 'Any energy';

  @override
  String get energyLow => 'Low';

  @override
  String get energyMedium => 'Medium';

  @override
  String get energyHigh => 'High';

  @override
  String get projectsTitle => 'Projects';

  @override
  String get newProject => 'New project';

  @override
  String get organizeLooseActionsTooltip => 'Organize loose actions';

  @override
  String get projectsEmptyTitle => 'No projects yet';

  @override
  String get projectsEmptyMessage =>
      'A project is any outcome that needs more than one action. Create one to organize related next actions and stay on track to a defined result.';

  @override
  String get projectMissingNextAction => 'No next action defined';

  @override
  String projectActionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count actions',
      one: '1 action',
    );
    return '$_temp0';
  }

  @override
  String get organizeActionsTitle => 'Organize actions';

  @override
  String get organizeEmptyTitle => 'Nothing loose';

  @override
  String get organizeEmptyMessage =>
      'Every next action already belongs to a project. New unassigned actions will show up here to be organized.';

  @override
  String assignToProject(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Assign $count to project',
      one: 'Assign 1 to project',
    );
    return '$_temp0';
  }

  @override
  String get addNextActionTitle => 'Add next action';

  @override
  String get addNextActionHint => 'e.g. Email Sara the timeline';

  @override
  String get addExistingActions => 'Add existing actions';

  @override
  String get noUnassignedActionsMessage =>
      'No unassigned next actions to pull in.';

  @override
  String addCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Add $count',
      one: 'Add 1',
    );
    return '$_temp0';
  }

  @override
  String get editProject => 'Edit project';

  @override
  String get projectName => 'Project name';

  @override
  String get projectNameHint => 'e.g. Launch the new website';

  @override
  String get projectNameRequired => 'Enter a project name';

  @override
  String get areaOfFocusOptional => 'Area of focus (optional)';

  @override
  String get unfiledOption => '— Unfiled —';

  @override
  String get dueDate => 'Due date';

  @override
  String get deleteProjectConfirmTitle => 'Delete project?';

  @override
  String get deleteProjectWarning =>
      'Items assigned to it become orphaned but are not deleted.';

  @override
  String get addActionFab => 'Add action';

  @override
  String get projectOutcomeHint => 'What does \"done\" look like?';

  @override
  String get outcomeSection => 'Outcome';

  @override
  String get nextActionsSection => 'Next actions';

  @override
  String get noNextActionsMessage => 'No next actions yet.';

  @override
  String get projectMissingNextActionError =>
      'No next action defined. Every active project should own at least one.';

  @override
  String get statusTooltip => 'Status';

  @override
  String get reviewTitle => 'Review';

  @override
  String get weeklyReviewCardTitle => 'Weekly review';

  @override
  String get weeklyReviewCardSubtitle =>
      'Run through your inbox, lists, and projects. The ritual that keeps the system trustworthy.';

  @override
  String get calendarEmpty => 'Nothing tied to a specific day.';

  @override
  String get waitingForEmpty => 'Nothing delegated.';

  @override
  String get somedayEmpty => 'No future-maybe items.';

  @override
  String get referenceEmpty => 'No reference items.';

  @override
  String get completedThisWeek => 'Completed this week';

  @override
  String get completedThisWeekEmpty => 'Nothing completed yet this week.';

  @override
  String bucketCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String get needsReDecision => 'Needs re-decision';

  @override
  String pastDueCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items past due',
      one: '1 item past due',
    );
    return '$_temp0';
  }

  @override
  String get reviewStep1Title => 'Empty your head';

  @override
  String get reviewStep1Body =>
      'Capture anything that has your attention into the inbox so the system can be trusted.';

  @override
  String get reviewStep2Title => 'Process inbox to zero';

  @override
  String get reviewStep2Body =>
      'Clarify every captured item using the decision tree until your inbox is empty.';

  @override
  String get reviewStep3Title => 'Review your next actions';

  @override
  String get reviewStep3Body =>
      'Skim every action. Done? Mark it done. Stale? Edit or delete. Still next? Leave it.';

  @override
  String get reviewStep4Title => 'Review your waiting-for list';

  @override
  String get reviewStep4Body =>
      'Has anyone come back to you? Should you follow up? Update or remove.';

  @override
  String get reviewStep5Title => 'Review every project';

  @override
  String get reviewStep5Body =>
      'Each project should be active, on hold, or done — and each active project must own at least one next action.';

  @override
  String get reviewStep6Title => 'Look at the next two weeks';

  @override
  String get reviewStep6Body =>
      'Check your calendar items. Anything you can prepare for now?';

  @override
  String get reviewStep7Title => 'Review someday / maybe';

  @override
  String get reviewStep7Body =>
      'Any of these worth committing to now? Promote them to projects or next actions.';

  @override
  String reviewStepCounter(int step, int total) {
    return 'Step $step of $total';
  }

  @override
  String get finishReview => 'Finish review';

  @override
  String get reviewCompleteSnackbar => 'Weekly review complete';

  @override
  String get searchHint => 'Search items, notes';

  @override
  String get searchMinChars => 'Type at least two characters';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get clearSearch => 'Clear search';

  @override
  String searchNoResults(String query) {
    return 'No matches for \"$query\"';
  }

  @override
  String get searchNoMatchTitle => 'Nothing matches';

  @override
  String get searchNoMatchMessage =>
      'No results match the current filters. Try widening them or clear the filter.';

  @override
  String get filterAllProjects => 'All projects';

  @override
  String get filterCompleted => 'Completed';

  @override
  String get statusInbox => 'Inbox';

  @override
  String get statusNext => 'Next';

  @override
  String get statusWaiting => 'Waiting';

  @override
  String get statusSomeday => 'Someday';

  @override
  String get statusReference => 'Reference';

  @override
  String get appearanceSection => 'Appearance';

  @override
  String get themeLabel => 'Theme';

  @override
  String get themeFollowSystem => 'Follow system';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get hapticFeedback => 'Haptic feedback';

  @override
  String get organizationSection => 'Organization';

  @override
  String get contextsLabel => 'Contexts';

  @override
  String get areasOfFocusLabel => 'Areas of focus';

  @override
  String get areasOfFocusDescription =>
      'Group projects by ongoing spheres of responsibility.';

  @override
  String get calendarSyncLabel => 'Calendar sync';

  @override
  String get calendarSyncDescription =>
      'Mirror items with due dates to your system calendar.';

  @override
  String get remindersSection => 'Reminders';

  @override
  String get weeklyReviewNudge => 'Weekly review nudge';

  @override
  String get weeklyReviewNudgeDescription =>
      'A gentle reminder every Friday at 4 PM.';

  @override
  String get remindBeforeDue => 'Remind me before due time';

  @override
  String get remindBeforeDueOff => 'Off · only an alert at the due time';

  @override
  String get remindBeforeDueSuffix => 'applies to items saved from now on';

  @override
  String get deferSurfaceLabel => 'Deferred items remind me at';

  @override
  String get deferSurfaceDescription =>
      'no-time deferred items stay in the list all day and nudge at this hour';

  @override
  String get checkingNotificationStatus => 'Checking notification status…';

  @override
  String get dataSection => 'Data';

  @override
  String get exportBackup => 'Export backup';

  @override
  String get exportBackupDescriptionIos =>
      'Share a JSON copy. Save it to a cloud drive (e.g. Files → iCloud Drive) for backup.';

  @override
  String get exportBackupDescriptionAndroid =>
      'Share a JSON copy. Save it to a cloud drive (e.g. Google Drive) for backup.';

  @override
  String exportBackupError(String error) {
    return 'Could not export: $error';
  }

  @override
  String get weeklyBackupReminder => 'Weekly backup reminder';

  @override
  String get weeklyBackupReminderDescription =>
      'Nudge me every Sunday morning to export and save.';

  @override
  String get importBackup => 'Import backup';

  @override
  String get importBackupDescription =>
      'Restore a Trayzero backup, or import a Google Tasks (Takeout) export.';

  @override
  String get importConfirmTitle => 'Import this backup?';

  @override
  String importConfirmBody(String sections) {
    return 'This will add or update $sections.\n\nExisting entries with the same id will be overwritten with the backup version. This cannot be undone.';
  }

  @override
  String get importButton => 'Import';

  @override
  String get importSourceSheetTitle => 'Import backup';

  @override
  String get importFromFileTitle => 'Choose a backup file';

  @override
  String get importFromFileDescription =>
      'Recommended — a Trayzero .json backup or a Google Takeout Tasks.json.';

  @override
  String get importFromPasteTitle => 'Paste backup JSON';

  @override
  String get importFromPasteDescription => 'Paste the backup text instead.';

  @override
  String get pasteBackupHint => 'Paste backup JSON…';

  @override
  String get privacySection => 'Privacy';

  @override
  String get crashReports => 'Send crash reports';

  @override
  String get crashReportsDescription =>
      'Anonymous crash + error reports via Sentry. No personal data is collected. Off by default.';

  @override
  String get crashReportsEnabled => 'Crash reports will be sent on next launch';

  @override
  String get crashReportsDisabled => 'Crash reporting disabled';

  @override
  String get aboutSection => 'About';

  @override
  String get showOnboardingAgain => 'Show onboarding again';

  @override
  String get versionLabel => 'Version';

  @override
  String get settingsFooter =>
      'Local-first. Your data stays on this device. Inspired by David Allen\'s Getting Things Done methodology.';

  @override
  String get editTitle => 'Edit';

  @override
  String get savedIndicator => 'Saved';

  @override
  String get titleLabel => 'Title';

  @override
  String get notesLabel => 'Notes';

  @override
  String get statusSection => 'Status';

  @override
  String get contextSection => 'Context';

  @override
  String get energySection => 'Energy';

  @override
  String get timeEstimateSection => 'Time estimate';

  @override
  String get waitingOnSection => 'Waiting on';

  @override
  String get waitingOnHint => 'Who or what are you waiting for?';

  @override
  String get projectSection => 'Project';

  @override
  String get datesSection => 'Dates';

  @override
  String get dueLabel => 'Due';

  @override
  String get deferUntilLabel => 'Defer until';

  @override
  String get repeatSection => 'Repeat';

  @override
  String get recurrenceNeedsDeferHint =>
      'Add a Defer date above to enable repeating — recurrence works by shifting that date forward.';

  @override
  String get recurrenceNeedsDueDateHint =>
      'Add a Due or Defer date above to enable repeating — recurrence works by shifting that date forward.';

  @override
  String get recurrenceExplanation =>
      'When you complete this item, the next instance will appear with shifted dates.';

  @override
  String get recurrenceNoDateNextActionError =>
      'This repeats but has no Defer date, so completing it won\'t create a next occurrence. Add a Defer date above, or turn repeat Off.';

  @override
  String get recurrenceNoDateError =>
      'This repeats but has no Due or Defer date, so completing it won\'t create a next occurrence. Add a date above, or turn repeat Off.';

  @override
  String get attachmentsSection => 'Attachments';

  @override
  String get markComplete => 'Mark complete';

  @override
  String get reopen => 'Reopen';

  @override
  String get deleteItemConfirmTitle => 'Delete item?';

  @override
  String get deleteItemConfirmBody => 'This cannot be undone.';

  @override
  String get completeError => 'Could not complete this item.';

  @override
  String get reopenError => 'Could not reopen this item.';

  @override
  String get remindersBlockedWarning =>
      'Reminders are blocked in system settings — this won\'t alert you.';

  @override
  String get remindersOffWarning =>
      'Reminders are off — this won\'t alert you.';

  @override
  String get preciseReminderOffWarning =>
      'Precise reminder timing is off — short reminders may be delayed.';

  @override
  String get allowExactAlarms => 'Allow exact alarms';

  @override
  String get noContextsAvailable => 'No contexts yet — add some in Settings.';

  @override
  String get noActiveProjects => 'No active projects yet.';

  @override
  String get attachmentPhoto => 'Photo';

  @override
  String get attachmentCamera => 'Camera';

  @override
  String get attachmentVoiceMemo => 'Voice memo';

  @override
  String get attachmentStop => 'Stop';

  @override
  String get remove => 'Remove';

  @override
  String get imageViewerClose => 'Close';

  @override
  String imageViewerCounter(int current, int total) {
    return '$current / $total';
  }

  @override
  String attachmentPhotoCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos',
      one: '1 photo',
    );
    return '$_temp0';
  }

  @override
  String attachmentAudioCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count voice memos',
      one: '1 voice memo',
    );
    return '$_temp0';
  }

  @override
  String attachmentFileCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count files',
      one: '1 file',
    );
    return '$_temp0';
  }

  @override
  String get areasTitle => 'Areas of focus';

  @override
  String get newArea => 'New area';

  @override
  String get renameArea => 'Rename area';

  @override
  String get areasEmptyMessage =>
      'No areas yet. Areas are ongoing spheres of responsibility — Health, Career, Family — that hold projects.';

  @override
  String get areaNameHint => 'e.g. Health, Career, Family';

  @override
  String deleteAreaConfirmTitle(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get deleteAreaWarning =>
      'Projects in this area will become unfiled (they will not be deleted).';

  @override
  String get contextsTitle => 'Contexts';

  @override
  String get newContext => 'New context';

  @override
  String get editContext => 'Edit context';

  @override
  String get contextsEmptyMessage =>
      'No contexts yet. Contexts tag actions with where or with what they can be done (@phone, @home, @errands).';

  @override
  String get nameLabel => 'Name';

  @override
  String get iconLabel => 'Icon';

  @override
  String get colorLabel => 'Color';

  @override
  String deleteContextConfirmTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String get deleteContextWarning => 'Items using this context will lose it.';

  @override
  String get calendarSyncTitle => 'Calendar sync';

  @override
  String get calendarSyncIntro =>
      'Mirror items with due dates to your system calendar, and pull events tagged \"#gtd\" back into your Trayzero inbox.';

  @override
  String get enableCalendarSync => 'Enable calendar sync';

  @override
  String get targetCalendar => 'Target calendar';

  @override
  String get calendarAccessDenied =>
      'Calendar access is denied. Grant it to choose a target calendar.';

  @override
  String get grantCalendarAccess => 'Grant calendar access';

  @override
  String get noCalendarsAvailable =>
      'No calendars available yet. If you just granted access, give it a moment and retry. Also check that calendar sync is on for your account in the system Calendar/Accounts settings.';

  @override
  String get mirrorOutAction => 'Mirror items → calendar';

  @override
  String get importInAction => 'Import #gtd events → inbox';

  @override
  String mirrorOutSuccess(int written) {
    return 'Mirrored $written items out';
  }

  @override
  String mirrorOutSuccessWithStale(int written, int removed) {
    return 'Mirrored $written items out, removed $removed stale';
  }

  @override
  String importInSuccess(int count) {
    return 'Imported $count calendar events';
  }

  @override
  String get mirroringProgress => 'Mirroring out…';

  @override
  String get importingProgress => 'Importing…';

  @override
  String get calendarSyncTip =>
      'Tip: type \"#gtd\" anywhere in a calendar event title and it will appear in your Trayzero inbox the next time you sync.';

  @override
  String get gtdDiagramTitle => 'How GTD works';

  @override
  String get gtdDiagramSubtitle =>
      'Five steps to get every open loop out of your head and into a system you trust. Tap a highlighted list to jump there.';

  @override
  String get gtdAttribution => 'Method by David Allen · gettingthingsdone.com';

  @override
  String get youAreHere => 'You\'re here';

  @override
  String get gtdStage1Body =>
      'Throw anything that has your attention into the Inbox — tasks, ideas, worries. No filtering, no organizing yet.';

  @override
  String get gtdStage2Body =>
      'Take one item at a time and decide what it is. The Process flow walks each item through this decision tree:';

  @override
  String get gtdStage3Body =>
      'The outcome lands on the right list, so nothing lives in your head anymore.';

  @override
  String get gtdStage3Footnote =>
      'Waiting / Calendar / Someday / Reference live under Review.';

  @override
  String get gtdStage4Body =>
      'Review your lists regularly — especially the Weekly Review — so the system stays trustworthy.';

  @override
  String get gtdStage5Body =>
      'Just do the work — pick actions by context, time, energy and priority, with a clear mind.';

  @override
  String get decisionNotActionableQ => 'Not actionable?';

  @override
  String get decisionNotActionableA => 'Trash, Someday/Maybe, or Reference';

  @override
  String get decisionTwoMinQ => 'Takes under 2 minutes?';

  @override
  String get decisionTwoMinA => 'Do it right now';

  @override
  String get decisionDelegateQ => 'Someone else should do it?';

  @override
  String get decisionDelegateA => 'Delegate → Waiting for';

  @override
  String get decisionMultiStepQ => 'Needs more than one step?';

  @override
  String get decisionMultiStepA => 'Make it a Project';

  @override
  String get decisionOtherwiseQ => 'Otherwise';

  @override
  String get decisionOtherwiseA => 'Define the very next action';

  @override
  String get supportTitle => 'Support Trayzero';

  @override
  String get supportSummaryDefault => 'Tip the developer or become a supporter';

  @override
  String get supportSummarySupporter => 'Thanks for supporting Trayzero 💙';

  @override
  String get supportIntro =>
      'Trayzero is free, with every feature unlocked. If it helps you, you can chip in — it keeps the app independent and ad-free.';

  @override
  String get supportUnavailable => 'Support options are unavailable right now.';

  @override
  String get supportTipHeader => 'Leave a tip';

  @override
  String get supportTipSmall => 'Small tip';

  @override
  String get supportTipLarge => 'Large tip';

  @override
  String get supportSupporterYearly => 'Supporter — yearly';

  @override
  String supportSupporterYearlySubtitle(String price) {
    return '$price / year · best value · unlocks supporter perks';
  }

  @override
  String get supportSupporterMonthly => 'Supporter — monthly';

  @override
  String supportSupporterMonthlySubtitle(String price) {
    return '$price / month · cancel anytime';
  }

  @override
  String get supportRestore => 'Restore purchases';

  @override
  String get supportRestoreSubtitle =>
      'Already a supporter? Restore on this device.';

  @override
  String get supportAutoRenewNote =>
      'Subscriptions auto-renew until cancelled in Settings.';

  @override
  String get legalPrivacyPolicy => 'Privacy Policy';

  @override
  String get legalTermsOfUse => 'Terms of Use';

  @override
  String get supportThanksTip => 'Thank you so much! 💙';

  @override
  String get supportThanksSupporter =>
      'You\'re a supporter now — thank you! 💙';

  @override
  String get supportRestored => 'Purchases restored. Welcome back! 💙';

  @override
  String get supportRestoreNone => 'No previous purchases found.';

  @override
  String get supportBadgeYearly => 'Supporter · yearly';

  @override
  String get supportBadgeMonthly => 'Supporter · monthly';

  @override
  String get supportBadgeGeneric => 'Supporter';

  @override
  String get supportBadgeSubtitle =>
      'Thank you for keeping Trayzero independent.';
}
