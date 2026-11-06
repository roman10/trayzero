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
  String get undo => 'Undo';

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
  String get inbox => 'Inbox';

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
  String get projectSectionActive => 'Active';

  @override
  String get projectSectionUnfiled => 'Unfiled';

  @override
  String get projectSectionOnHold => 'On hold';

  @override
  String get sampleProjectTitle => 'Get the most out of GTD';

  @override
  String get sampleProjectOutcome =>
      'Capture inbox to zero daily and run a Weekly Review every Friday.';

  @override
  String get sampleItemReadPrimer => 'Read the GTD primer in Settings';

  @override
  String get sampleItemEmptyEmail => 'Empty my email inbox into here';

  @override
  String get sampleItemScheduleReview =>
      'Schedule a recurring Friday Weekly Review';

  @override
  String get seedContextPhone => '@phone';

  @override
  String get seedContextComputer => '@computer';

  @override
  String get seedContextErrands => '@errands';

  @override
  String get seedContextHome => '@home';

  @override
  String get seedContextOffice => '@office';

  @override
  String get seedContextAnywhere => '@anywhere';

  @override
  String get seedContextWaiting => '@waiting';

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
  String completedItemsSnackbar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Completed $count items.',
      one: 'Completed 1 item.',
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
  String get dictationUnavailable =>
      'Dictation is unavailable. You can still type your capture.';

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
  String get delegateQuestion => 'Can someone else do it?';

  @override
  String get waitingOnPromptTitle => 'Who are you waiting on?';

  @override
  String get waitingOnPromptHint => 'Name or system';

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
  String get hardLandscape => 'Calendar';

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
      'Review each outcome. Give stalled projects a next action, put them on hold, or mark them done. Waiting and scheduled work count as movement.';

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
  String get languageLabel => 'Language';

  @override
  String get languageFollowSystem => 'System default';

  @override
  String get contextsLabel => 'Contexts';

  @override
  String get areasOfFocusLabel => 'Areas of focus';

  @override
  String get calendarSyncLabel => 'Calendar sync';

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
  String exportBackupError(String error) {
    return 'Could not export: $error';
  }

  @override
  String get weeklyBackupReminder => 'Weekly backup reminder';

  @override
  String get weeklyBackupReminderDescription =>
      'Nudge me every Sunday morning to export and save.';

  @override
  String get importConfirmTitle => 'Import this backup?';

  @override
  String importConfirmBody(String sections) {
    return 'This will add or update $sections.\n\nExisting entries with the same id will be overwritten with the backup version. This cannot be undone.';
  }

  @override
  String get importButton => 'Import';

  @override
  String get importFromPasteTitle => 'Paste backup JSON';

  @override
  String get importFromPasteDescription => 'Paste the backup text instead.';

  @override
  String get pasteBackupHint => 'Paste backup JSON…';

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
  String get showOnboardingAgain => 'Show onboarding again';

  @override
  String get versionLabel => 'Version';

  @override
  String get settingsFooter =>
      'Local-first. Your data stays on this device. Inspired by David Allen\'s Getting Things Done methodology.';

  @override
  String get editTitle => 'Edit';

  @override
  String get saveError => 'Couldn\'t save your changes. Please try again.';

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
    return '$price / year · best value · supports development';
  }

  @override
  String get supportSupporterMonthly => 'Supporter — monthly';

  @override
  String supportSupporterMonthlySubtitle(String price) {
    return '$price / month · cancel anytime';
  }

  @override
  String supportOpeningStore(String store) {
    return 'Opening $store…';
  }

  @override
  String get supportRestoring => 'Restoring purchases…';

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

  @override
  String get calendarLookupFailed =>
      'Could not load your device calendars. Open your system Calendar app and check that your account is syncing, then return here and retry.';

  @override
  String get calendarPermissionHelp =>
      'If the permission prompt does not appear, open app settings and allow Calendar access, then return here.';

  @override
  String get calendarOpenSettings => 'Open app settings';

  @override
  String get calendarSettingsFailed =>
      'Could not open app settings. Open your device Settings, find Trayzero, and allow Calendar access.';

  @override
  String get calendarSelectionUnavailable =>
      'Your previously selected calendar is no longer available. Choose a calendar to continue.';

  @override
  String get appIcon => 'App icon';

  @override
  String get appIconAndroidDescription =>
      'Choose a Home screen icon independently of App color. Your launcher may take a moment to update or apply its own tint.';

  @override
  String get appIconDescription =>
      'Choose an icon independently of App color. Your device may apply its own tint. iOS shows a confirmation alert when the icon changes.';

  @override
  String get appIconChangeFailed =>
      'Could not change the app icon. Try again while Trayzero is open.';

  @override
  String get appColor => 'App color';

  @override
  String get appColorDescription =>
      'Works in light and dark mode. GTD list colors keep their meaning.';

  @override
  String get paletteAmber => 'Trayzero amber — Default';

  @override
  String get paletteBlue => 'Blue';

  @override
  String get paletteCyan => 'Cyan';

  @override
  String get paletteTeal => 'Teal';

  @override
  String get paletteGreen => 'Green';

  @override
  String get paletteViolet => 'Violet';

  @override
  String get paletteRose => 'Rose';

  @override
  String get appIconNotificationNote =>
      'Android notification accents use your selected app icon color when reminders are scheduled. Existing notifications update when rescheduled. Some devices may display the original app icon.';

  @override
  String get appearanceSaveFailed =>
      'Could not save your appearance. Your previous setting has been restored.';

  @override
  String mirrorOutPendingCleanup(int count) {
    return '$count calendar events still need cleanup. Sync again to retry.';
  }

  @override
  String get weeklyReviewResume => 'Resume weekly review';

  @override
  String get weeklyReviewProgressSaved => 'Your place is saved when you leave.';

  @override
  String get weeklyReviewSaveError =>
      'Could not save your progress. Please try again.';

  @override
  String get weeklyReviewActionError =>
      'Could not save this change. Please try again.';

  @override
  String get weeklyReviewListEmpty => 'Nothing to review here.';

  @override
  String get weeklyReviewProjectAwaiting =>
      'Waiting or scheduled work is moving this project forward.';

  @override
  String get weeklyReviewProjectMoving => 'Next action defined';

  @override
  String get weeklyReviewOpenProject => 'Open project';

  @override
  String get processTwoMinNo => 'No — keep clarifying';

  @override
  String get twoMinRule =>
      'The Two-Minute Rule: if it takes less time to do than to track, just do it.';

  @override
  String get delegateYes => 'Yes — delegate & wait for them';

  @override
  String get delegateNo => 'No — it\'s on me';

  @override
  String get singleStepQuestion => 'Is this a single physical action?';

  @override
  String get singleStepYes => 'Yes — single next action';

  @override
  String get singleStepProject => 'No — this is a project';

  @override
  String get projectRule =>
      'A project is any outcome that needs more than one action step and can finish within a year.';

  @override
  String get deferQuestion => 'Does it have a specific day or time?';

  @override
  String get deferAsap => 'No — do it as soon as I can';

  @override
  String get deferCalendar => 'Yes — put it on the calendar';

  @override
  String get deferChooseDate => 'Defer until a date';

  @override
  String get processDetailsTitle => 'Add details';

  @override
  String get processFileNextAction => 'File as next action';

  @override
  String minutesShort(int minutes) {
    return '$minutes min';
  }

  @override
  String deferredUntilSummary(String date) {
    return 'Deferred until $date';
  }

  @override
  String deferredRepeatingSummary(String date, String recurrence) {
    return 'Deferred until $date · Repeat: $recurrence';
  }

  @override
  String get recurrenceDaily => 'Daily';

  @override
  String get recurrenceWeekly => 'Weekly';

  @override
  String get recurrenceMonthly => 'Monthly';

  @override
  String get recurrenceYearly => 'Yearly';

  @override
  String get createProject => 'Create';

  @override
  String get projectPickerTitle => 'Move to project';

  @override
  String get projectMoved => 'Moved to project.';

  @override
  String get projectDetached => 'Removed from project.';

  @override
  String get noProject => 'No project';

  @override
  String get decreaseRepeatInterval => 'Decrease repeat interval';

  @override
  String get increaseRepeatInterval => 'Increase repeat interval';

  @override
  String get decreaseRepeatCount => 'Decrease repeat count';

  @override
  String get increaseRepeatCount => 'Increase repeat count';

  @override
  String get repeatOn => 'Repeat on';

  @override
  String get repeatMonthlyOn => 'On';

  @override
  String get repeatDayOfMonth => 'Day of month';

  @override
  String get repeatDayOfWeek => 'Day of week';

  @override
  String get repeatFirst => 'First';

  @override
  String get repeatSecond => 'Second';

  @override
  String get repeatThird => 'Third';

  @override
  String get repeatFourth => 'Fourth';

  @override
  String get repeatFifth => 'Fifth';

  @override
  String get repeatLast => 'Last';

  @override
  String get repeatEnds => 'Ends';

  @override
  String get repeatNever => 'Never';

  @override
  String get repeatOnDate => 'On date';

  @override
  String get repeatAfterCount => 'After N times';

  @override
  String get weekdayListSeparator => ', ';

  @override
  String get dueToday => 'Due today';

  @override
  String get reschedule => 'Reschedule';

  @override
  String get complete => 'Complete';

  @override
  String get drop => 'Drop';

  @override
  String get trash => 'Trash';

  @override
  String itemEnergyLabel(String energy) {
    return '$energy energy';
  }

  @override
  String waitingOnPerson(String person) {
    return 'Waiting on $person';
  }

  @override
  String dueOverdueDays(int days) {
    return 'Overdue · ${days}d';
  }

  @override
  String dueTodayAt(String time) {
    return 'Due today, $time';
  }

  @override
  String selectItem(String title) {
    return 'Select $title';
  }

  @override
  String markItemDone(String title) {
    return 'Mark $title done';
  }

  @override
  String repeatLastOnDate(String date) {
    return 'Last on $date';
  }

  @override
  String repeatAfterOccurrences(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'After $count occurrences',
      one: 'After 1 occurrence',
    );
    return '$_temp0';
  }

  @override
  String recurrenceUntilSummary(String pattern, String date) {
    return '$pattern · until $date';
  }

  @override
  String recurrenceCountSummary(String pattern, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$pattern · $count occurrences',
      one: '$pattern · 1 occurrence',
    );
    return '$_temp0';
  }

  @override
  String recurrenceOnWeekdays(String cadence, String weekdays) {
    return '$cadence on $weekdays';
  }

  @override
  String recurrenceOnNthWeekday(
    String cadence,
    String ordinal,
    String weekday,
  ) {
    String _temp0 = intl.Intl.selectLogic(ordinal, {
      'first': 'first',
      'second': 'second',
      'third': 'third',
      'fourth': 'fourth',
      'fifth': 'fifth',
      'other': 'last',
    });
    return '$cadence on the $_temp0 $weekday';
  }

  @override
  String repeatEveryDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Every $count days',
      one: 'Every day',
    );
    return '$_temp0';
  }

  @override
  String repeatEveryWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Every $count weeks',
      one: 'Every week',
    );
    return '$_temp0';
  }

  @override
  String repeatEveryMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Every $count months',
      one: 'Every month',
    );
    return '$_temp0';
  }

  @override
  String repeatEveryYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Every $count years',
      one: 'Every year',
    );
    return '$_temp0';
  }

  @override
  String get captureAddContinue => 'Add & continue';

  @override
  String captureAddedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items added to inbox',
      one: '1 item added to inbox',
    );
    return '$_temp0';
  }

  @override
  String get folderBackupChoose => 'Choose backup folder';

  @override
  String get folderBackupSaving => 'Backing up…';

  @override
  String get folderBackupOff => 'Automatic backups are off.';

  @override
  String get folderBackupNever => 'No successful backup yet.';

  @override
  String folderBackupLastSuccess(String date) {
    return 'Last backup: $date';
  }

  @override
  String get folderBackupFailed =>
      'Backup failed. Check folder access and free space, then try again.';

  @override
  String get folderBackupHistoryWarning =>
      'Backup saved, but older backups could not be removed.';

  @override
  String get folderBackupNow => 'Back up now';

  @override
  String get doViewToday => 'Today';

  @override
  String get doViewNextActions => 'Next actions';

  @override
  String get todayPlanCardTitle => 'Plan your day';

  @override
  String get todayPlanCardBody =>
      'Pick what you’ll focus on today. It takes about two minutes.';

  @override
  String get todayPlanAction => 'Plan today';

  @override
  String todayCarryOverLine(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count from earlier need a decision',
      one: '1 from earlier needs a decision',
    );
    return '$_temp0';
  }

  @override
  String get todayFocusHeader => 'Focus';

  @override
  String todayDoneCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count done today',
      one: '1 done today',
    );
    return '$_temp0';
  }

  @override
  String get todayEmptyTitle => 'Nothing focused yet';

  @override
  String get todayEmptyMessage =>
      'Star next actions to commit to them today, or plan your day.';

  @override
  String get focusAddTooltip => 'Add to Today';

  @override
  String get focusRemoveTooltip => 'Remove from Today';

  @override
  String focusAddItem(String title) {
    return 'Add $title to Today';
  }

  @override
  String focusRemoveItem(String title) {
    return 'Remove $title from Today';
  }

  @override
  String get focusError => 'Couldn’t update Today. Try again.';

  @override
  String get planTodayIntro =>
      'Star what you’ll commit to today. Keep it short — everything else stays on your lists.';

  @override
  String get planSectionCarryOver => 'From earlier';

  @override
  String get planCarryOverHint =>
      'Items you don’t keep go back to their lists when you start your day.';

  @override
  String get planKeepAll => 'Keep all';

  @override
  String get planSectionCalendar => 'Calendar';

  @override
  String get planOnToday => 'On Today';

  @override
  String get planSectionWaiting => 'Waiting follow-ups';

  @override
  String get planSectionAvailable => 'Available from today';

  @override
  String get planEmpty =>
      'Nothing to plan yet. Process your inbox to build your next actions.';

  @override
  String planFocusedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count focused for today',
      one: '1 focused for today',
      zero: 'Nothing focused yet',
    );
    return '$_temp0';
  }

  @override
  String get planStartDay => 'Start my day';

  @override
  String get planDoneSnackbar => 'Today is planned';

  @override
  String planClearedSnackbar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Day planned · $count items back on their lists',
      one: 'Day planned · 1 item back on its list',
    );
    return '$_temp0';
  }

  @override
  String get planSaveError => 'Couldn’t save your plan. Try again.';

  @override
  String get captureTipDates =>
      'Tip: add @context, #project, +tag, or a date like “tomorrow” or “due fri”.';

  @override
  String get captureTipSigils => 'Tip: add @context, #project, or +tag.';

  @override
  String startsOnDate(String date) {
    return 'Starts $date';
  }

  @override
  String dueOnDate(String date) {
    return 'Due $date';
  }

  @override
  String captureChipProject(String name) {
    return 'Project: $name';
  }

  @override
  String get captureKeepAsText => 'Keep as text';

  @override
  String get captureRecognized => 'Recognized details';

  @override
  String deferUseStartDate(String date) {
    return 'Start on $date';
  }

  @override
  String deferUseDueDate(String date) {
    return 'On calendar $date';
  }

  @override
  String weeklyReviewProjectInactive(int days) {
    return 'No activity in $days+ days';
  }

  @override
  String get weeklyReviewMarkReviewed => 'Mark reviewed';

  @override
  String get weeklyReviewReviewed => 'Reviewed';

  @override
  String weeklyReviewLastReviewed(String date) {
    return 'Last reviewed $date';
  }

  @override
  String get weeklyReviewNeverReviewed => 'Not reviewed yet';

  @override
  String weeklyReviewReviewedProgress(int done, int total) {
    return 'Reviewed $done of $total';
  }

  @override
  String get importFromApp => 'Import from another app';

  @override
  String get importSourcePlainText => 'Plain text / TaskPaper';

  @override
  String get importHintTodoist =>
      'Project menu › Export as a template › CSV, or a backup ZIP from Settings › Backups.';

  @override
  String get importHintTickTick =>
      'On the TickTick website: Settings › Account › Backup & Import › Generate Backup (CSV).';

  @override
  String get importHintNirvana =>
      'In the Nirvana web app, export your data as CSV or JSON.';

  @override
  String get importHintOmniFocus =>
      'Select projects, then Edit › Copy as TaskPaper. Paste here or save as a file.';

  @override
  String get importHintPlainText =>
      'Things: copy to-dos and paste here, one task per line. Basic text import only; Things database exports are not supported.';

  @override
  String get importChooseFile => 'Choose file';

  @override
  String get importPasteText => 'Paste text';

  @override
  String get importPasteTitle => 'Paste tasks';

  @override
  String get importPasteHint =>
      'One task per line. Indent tasks under a line ending in “:” to make a project.';

  @override
  String get importPasteContinue => 'Preview';

  @override
  String get importPreviewNothingYet => 'Nothing has been added yet.';

  @override
  String get importPreviewProjects => 'Projects';

  @override
  String get importProjectNew => 'New';

  @override
  String get importProjectExisting => 'Adds to existing';

  @override
  String importProjectActions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count actions',
      one: '1 action',
    );
    return '$_temp0';
  }

  @override
  String importContextsNew(String names) {
    return 'New: $names';
  }

  @override
  String importContextsExisting(String names) {
    return 'Already yours: $names';
  }

  @override
  String get importGoodToKnow => 'Good to know';

  @override
  String importWarnCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count completed or dropped tasks skipped',
      one: '1 completed or dropped task skipped',
    );
    return '$_temp0';
  }

  @override
  String importWarnCalendar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count actions with a due date go to Calendar',
      one: '1 action with a due date goes to Calendar',
    );
    return '$_temp0';
  }

  @override
  String importWarnDates(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dates could not be read and are kept in notes',
      one: '1 date could not be read and is kept in notes',
    );
    return '$_temp0';
  }

  @override
  String importWarnRepeats(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count repeat rules are kept in notes',
      one: '1 repeat rule is kept in notes',
    );
    return '$_temp0';
  }

  @override
  String importWarnSubtasks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count subtasks become separate actions',
      one: '1 subtask becomes a separate action',
    );
    return '$_temp0';
  }

  @override
  String importWarnSections(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks note their section or heading',
      one: '1 task notes its section or heading',
    );
    return '$_temp0';
  }

  @override
  String importWarnNotImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count tasks had a priority, flag or assignee that is not imported',
      one: '1 task had a priority, flag or assignee that is not imported',
    );
    return '$_temp0';
  }

  @override
  String importWarnUnreadable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rows without a title skipped',
      one: '1 row without a title skipped',
    );
    return '$_temp0';
  }

  @override
  String importDoneTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks added',
      one: '1 task added',
    );
    return '$_temp0';
  }

  @override
  String get importDoneBody =>
      'Changed your mind? Undo removes exactly what this import added, and nothing else.';

  @override
  String get importUndo => 'Undo import';

  @override
  String get importFinish => 'Done';

  @override
  String get importUndoneTitle => 'Import undone';

  @override
  String get importUndoneBody =>
      'Everything this import added has been removed.';

  @override
  String get importRemindersFailed =>
      'Some reminders could not be scheduled yet. They will be set the next time the app opens.';

  @override
  String importErrorUnrecognized(String source) {
    return 'This does not look like a $source export. Check the steps and try again.';
  }

  @override
  String get importErrorNoTasks => 'No open tasks found to import.';

  @override
  String get importErrorUnreadable =>
      'This file cannot be read. Choose a text, CSV or ZIP export.';

  @override
  String get importErrorWrite => 'The import failed. Nothing was added.';

  @override
  String get importErrorUndo => 'Could not undo the import. Try again.';

  @override
  String get tagsAndPeopleLabel => 'Tags & people';

  @override
  String get tagsEmptyMessage =>
      'Tags label items across lists. Mark a tag as a person to keep an agenda of things to discuss with them. Tip: type +tag when capturing.';

  @override
  String get newTag => 'New tag';

  @override
  String get editTag => 'Edit tag';

  @override
  String get tagPersonSwitch => 'Person';

  @override
  String get tagPersonSwitchHint => 'Keeps an agenda of things to discuss';

  @override
  String tagOpenItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count open items',
      one: '1 open item',
      zero: 'No open items',
    );
    return '$_temp0';
  }

  @override
  String deleteTagConfirmTitle(String name) {
    return 'Delete “$name”?';
  }

  @override
  String deleteTagConfirmBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count open items use it. They stay; only the tag is removed.',
      one: '1 open item uses it. It stays; only the tag is removed.',
      zero: 'No open item uses it.',
    );
    return '$_temp0';
  }

  @override
  String get tagMergeTitle => 'Merge tags?';

  @override
  String tagMergeBody(String source, String target) {
    return '“$target” already exists. Merge “$source” into it?';
  }

  @override
  String get tagMergeAction => 'Merge';

  @override
  String get addTag => 'Add tag';

  @override
  String get tagPickerHint => 'Search or create a tag';

  @override
  String tagCreate(String name) {
    return 'Create “$name”';
  }

  @override
  String tagCreatePerson(String name) {
    return 'Create person “$name”';
  }

  @override
  String get tagsSection => 'Tags';

  @override
  String tagChipSemantics(String name) {
    return 'Tag: $name';
  }

  @override
  String personChipSemantics(String name) {
    return 'Person: $name';
  }

  @override
  String removeTagTooltip(String name) {
    return 'Remove $name';
  }

  @override
  String moreTags(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count more tags',
      one: '1 more tag',
    );
    return '$_temp0';
  }

  @override
  String get filterTag => 'Tag';

  @override
  String get filterAnyTag => 'Any tag';

  @override
  String get agendasTitle => 'Agendas';

  @override
  String agendasPeopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people',
      one: '1 person',
    );
    return '$_temp0';
  }

  @override
  String agendaAddHint(String name) {
    return 'Add something to discuss with $name';
  }

  @override
  String get agendaAddTooltip => 'Add to agenda';

  @override
  String agendaEmpty(String name) {
    return 'Nothing to discuss with $name yet.';
  }

  @override
  String get agendaNotFound => 'This person no longer exists.';

  @override
  String captureChipNewTag(String name) {
    return 'New tag: $name';
  }

  @override
  String get importHintGoogleTasks =>
      'Google Takeout › select Tasks › export JSON. Unzip the download and choose Tasks.json. Lists stay in notes; completed tasks go to Done.';

  @override
  String get importDuplicateWarning =>
      'This exact input was imported before on this device. Importing again will add duplicate tasks. Cancel unless you want another copy.';

  @override
  String get importHintThings =>
      'Choose main.sqlite or a ZIP of an exported Things 3 database folder. iPhone/iPad: Settings › General › Diagnostics › Enter Code › 491348 › Send Things Database. Save to Files, unpack .aar, then compress the database folder to ZIP. On Mac, quit Things before copying its database. Recreate repeats and reminders after importing.';

  @override
  String importWarnDetailsInNotes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks keep checklist or Area details in notes',
      one: '1 task keeps checklist or Area details in notes',
    );
    return '$_temp0';
  }

  @override
  String get importWarnThingsRecurrence =>
      'Things repeat schedules are not imported. Recurring templates are skipped; recreate repeats for imported tasks.';

  @override
  String importWarnSourceReminders(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count source reminder settings are not imported',
      one: '1 source reminder setting is not imported',
    );
    return '$_temp0';
  }

  @override
  String get importAppleHint =>
      'Choose reminder lists on this device. Only open reminders are imported.';

  @override
  String get importAppleChooseLists => 'Choose lists';

  @override
  String get importAppleReloadLists => 'Reload lists';

  @override
  String get importAppleNoLists =>
      'No reminder lists are available on this device.';

  @override
  String get importAppleDenied =>
      'Reminders access is off. Allow Trayzero to access Reminders in iOS Settings, then try again.';

  @override
  String get importAppleUnavailable =>
      'Could not read Apple Reminders. Try again.';

  @override
  String get importAppleListsChanged =>
      'A selected list is no longer available. Reload lists and select again.';

  @override
  String get importAppleLimits =>
      'Your Apple reminders stay unchanged. Apple tags, flags, attachments and subtask structure are not copied. Priorities and original alerts are not copied. Importing again can add duplicate tasks.';

  @override
  String get importHintMicrosoftTodo =>
      'Sign in to copy your lists and open tasks. Review before importing; importing again can create duplicates.';

  @override
  String get importMicrosoftUnavailable =>
      'Microsoft To Do import is unavailable in this build.';

  @override
  String get importMicrosoftSignInError =>
      'Microsoft sign-in failed or expired. Please sign in again.';

  @override
  String get importMicrosoftPermissionError =>
      'Microsoft did not allow access to your tasks. Check account permissions or contact your organization.';

  @override
  String get importMicrosoftNetworkError =>
      'Could not read all Microsoft tasks. Nothing was imported. Check your connection and try again.';

  @override
  String importWarnSourceDetails(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count tasks have attachments, reminder settings or statuses that are not imported',
      one:
          '1 task has attachments, reminder settings or a status that are not imported',
    );
    return '$_temp0';
  }

  @override
  String get moreGroupOrganize => 'Organize';

  @override
  String get moreGroupPreferences => 'Preferences';

  @override
  String get moreGroupData => 'Data';

  @override
  String get moreOn => 'On';

  @override
  String get moreOff => 'Off';

  @override
  String moreAppearanceSummary(String theme, String palette) {
    return '$theme · $palette';
  }

  @override
  String get moreRemindersBlockedTitle => 'Reminders are blocked';

  @override
  String get moreRemindersBlockedBody =>
      'Notifications are off, so reminders can\'t alert you.';

  @override
  String get moreBackupFailedTitle => 'Backup failed';

  @override
  String get moreBackupFailedBody =>
      'Automatic backup couldn\'t save. Check the folder and free space.';

  @override
  String get moreFix => 'Fix';

  @override
  String get moreBackupRestore => 'Backup & restore';

  @override
  String get moreBackupSubtitleOff => 'Automatic backup is off';

  @override
  String get moreBackupSubtitleFailed => 'Backup failed';

  @override
  String get moreImportSources => 'Todoist, TickTick, OmniFocus and more';

  @override
  String get moreSupportTrailing => 'Optional';

  @override
  String get moreSupportTrailingSupporter => 'Supporter';

  @override
  String get moreAboutPrivacy => 'About & privacy';

  @override
  String get moreHowGtdWorks => 'How GTD works';

  @override
  String get moreNudgesGroup => 'Nudges';

  @override
  String get moreTimingGroup => 'Timing';

  @override
  String get moreLeadOff => 'Off';

  @override
  String get moreLead10 => '10 minutes before';

  @override
  String get moreLead30 => '30 minutes before';

  @override
  String get moreLead60 => '1 hour before';

  @override
  String get moreLead1440 => '1 day before';

  @override
  String moreLeadOther(int minutes) {
    return '$minutes minutes before';
  }

  @override
  String moreRestoredEntries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries',
      one: '1 entry',
    );
    return 'Restored $_temp0.';
  }

  @override
  String get moreBackupEmpty => 'This backup has no entries to restore.';

  @override
  String get moreCouldntOpenLink => 'Couldn\'t open link';

  @override
  String moreVersionBuild(String version, String build) {
    return '$version (build $build)';
  }

  @override
  String get supportBestValue => 'Best value';

  @override
  String get importListIntro =>
      'Pick where your tasks live now. You will see a preview before anything is added.';

  @override
  String get importGroupDirect => 'Connect directly';

  @override
  String get importGroupFile => 'From an export file';

  @override
  String get importGroupOther => 'Anything else';

  @override
  String get importSubGoogleTasks => 'Takeout · Tasks.json';

  @override
  String get importSubTodoist => 'CSV template or backup ZIP';

  @override
  String get importSubThings => 'Database ZIP or main.sqlite';

  @override
  String get importSubTickTick => 'Backup CSV';

  @override
  String get importSubNirvana => 'CSV or JSON export';

  @override
  String get importSubOmniFocus => 'TaskPaper file or paste';

  @override
  String get importSubPlainText => 'Paste a list, one task per line';

  @override
  String get importSubApple => 'Pick lists on this device';

  @override
  String get importSubMicrosoft => 'Lists and open tasks';

  @override
  String get importChipOnDevice => 'On device';

  @override
  String get importChipSignIn => 'Sign in';

  @override
  String get importBackupFooter => 'Restoring a Trayzero backup?';

  @override
  String get importBackupFooterLink => 'Backup & restore';

  @override
  String get importThingsDeviceIos => 'iPhone / iPad';

  @override
  String get importThingsDeviceMac => 'Mac';

  @override
  String get importCopyCode => 'Copy code';

  @override
  String get importCodeCopied => 'Code copied';

  @override
  String get importConnect => 'Connect';

  @override
  String get importStepGoogleTasks1 =>
      'Open Google Takeout and select only Tasks.';

  @override
  String get importStepGoogleTasks2 =>
      'Export it as JSON and unzip the download.';

  @override
  String get importStepGoogleTasks3 => 'Choose Tasks.json below.';

  @override
  String get importNoteGoogleTasks =>
      'Lists stay in notes; completed tasks go to Done.';

  @override
  String get importStepTodoist1 =>
      'Open a project menu and choose Export as a template (CSV).';

  @override
  String get importStepTodoist2 =>
      'Or save a backup ZIP from Settings › Backups.';

  @override
  String get importStepTodoist3 => 'Choose the file below.';

  @override
  String get importStepTickTick1 =>
      'On the TickTick website, open Settings › Account.';

  @override
  String get importStepTickTick2 =>
      'Open Backup & Import and tap Generate Backup (CSV).';

  @override
  String get importStepTickTick3 => 'Choose the CSV below.';

  @override
  String get importStepNirvana1 =>
      'In the Nirvana web app, export your data as CSV or JSON.';

  @override
  String get importStepNirvana2 => 'Choose the file below.';

  @override
  String get importStepOmniFocus1 => 'In OmniFocus, select your projects.';

  @override
  String get importStepOmniFocus2 => 'Choose Edit › Copy as TaskPaper.';

  @override
  String get importStepOmniFocus3 =>
      'Paste the text below, or save it as a file and choose it.';

  @override
  String get importStepPlainText1 =>
      'Copy your tasks from any app, one task per line.';

  @override
  String get importStepPlainText2 => 'Tap Paste text below and paste them.';

  @override
  String get importNotePlainText =>
      'Basic text import only. Database exports from other apps are not supported.';

  @override
  String get importStepApple1 => 'Tap Choose lists below.';

  @override
  String get importStepApple2 => 'Allow access to Reminders when asked.';

  @override
  String get importStepApple3 => 'Tick the lists you want to import.';

  @override
  String get importNoteApple =>
      'Only open reminders are imported. Your Apple reminders stay unchanged.';

  @override
  String get importStepMicrosoft1 => 'Tap Connect and sign in to Microsoft.';

  @override
  String get importStepMicrosoft2 =>
      'Trayzero copies your lists and open tasks.';

  @override
  String get importStepMicrosoft3 => 'Review the preview before importing.';

  @override
  String get importNoteMicrosoft => 'Importing again can create duplicates.';

  @override
  String get importStepThingsIos1 =>
      'Open Settings › General › Diagnostics › Enter Code in Things, then enter:';

  @override
  String get importStepThingsIos2 =>
      'Tap Send Things Database and save it to Files.';

  @override
  String get importStepThingsIos3 =>
      'In Files, unpack the .aar, then compress the database folder to ZIP.';

  @override
  String get importStepThingsIos4 => 'Choose that ZIP below.';

  @override
  String get importStepThingsMac1 => 'Quit Things on your Mac.';

  @override
  String get importStepThingsMac2 =>
      'Copy Things Database.thingsdatabase from the Things folder, then compress the copy to ZIP.';

  @override
  String get importStepThingsMac3 =>
      'Move the ZIP (or its main.sqlite) to this device and choose it below.';

  @override
  String get importNoteThings =>
      'Repeats and reminders don\'t carry over. Recreate them after importing.';

  @override
  String get importReviewTitle => 'Review import';

  @override
  String importFromSource(String source) {
    return 'From $source';
  }

  @override
  String importTotalTasks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks',
      one: '1 task',
    );
    return '$_temp0';
  }

  @override
  String importActionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks',
      one: '1 task',
    );
    return 'Import $_temp0';
  }

  @override
  String importNewExistingSummary(int newCount, int existingCount) {
    return '$newCount new · $existingCount existing';
  }

  @override
  String importShowAll(int count) {
    return 'Show all $count';
  }

  @override
  String get importContextsAndTags => 'Contexts & tags';

  @override
  String importNotesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notes',
      one: '1 note',
    );
    return '$_temp0';
  }

  @override
  String get notificationStatusOnTitle => 'Reminders on';

  @override
  String get notificationStatusOnBody =>
      'Reminders will alert you on this device.';

  @override
  String get notificationStatusOffTitle => 'Reminders off';

  @override
  String get notificationStatusOffBody =>
      'Reminders are scheduled but won’t alert you until you allow notifications.';

  @override
  String get notificationStatusBlockedTitle => 'Reminders blocked';

  @override
  String get notificationStatusBlockedBody =>
      'Notifications are turned off for Trayzero in system settings. Reminders won’t alert you until you turn them back on there.';

  @override
  String get notificationActionEnable => 'Enable notifications';

  @override
  String get notificationActionOpenSettings => 'Open Settings';

  @override
  String get notificationPrimerTitle => 'Turn on reminders?';

  @override
  String get notificationPrimerBody =>
      'Trayzero reminds you about due dates and your weekly review by posting a notification on this device. Nothing is sent to a server — reminders are scheduled locally.\n\nYour device will now ask for permission to show notifications.';

  @override
  String get notificationPrimerNotNow => 'Not now';

  @override
  String get notificationPrimerContinue => 'Continue';

  @override
  String get notificationPromptFailed =>
      'Couldn’t open the notification prompt.';

  @override
  String get notificationAlreadyOn => 'Reminders are already on.';

  @override
  String get notificationOpenedSettings =>
      'Opened system settings — turn on Notifications for Trayzero.';

  @override
  String get notificationStayOff =>
      'Reminders stay off. You can enable them anytime in More → Reminders.';

  @override
  String get notificationNowOn => 'Reminders are on.';

  @override
  String get notificationBlocked => 'Notifications are blocked for Trayzero.';

  @override
  String get exactAlarmSettingsFailed => 'Couldn’t open exact alarm settings.';

  @override
  String get exactAlarmAlreadyOn => 'Precise reminder timing is already on.';

  @override
  String get exactAlarmNowOn => 'Precise reminder timing is on.';

  @override
  String get exactAlarmStaysOff =>
      'Precise reminder timing stays off. Short reminders may be delayed.';

  @override
  String get attachmentRemoved => 'Attachment removed.';

  @override
  String get discardCaptureTitle => 'Discard this capture?';

  @override
  String get discardCaptureBody => 'What you typed will be lost.';

  @override
  String get keepEditing => 'Keep editing';

  @override
  String get discard => 'Discard';

  @override
  String get processFiledSnackbar => 'Filed.';

  @override
  String get errorLoadTitle => 'Couldn\'t load this';

  @override
  String get errorLoadBody => 'Your data is safe. Try again.';

  @override
  String sharedAddedToInbox(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Added $count items to Inbox',
      one: 'Added 1 item to Inbox',
    );
    return '$_temp0';
  }

  @override
  String get filterByProject => 'Filter by project';

  @override
  String get projectStatusActive => 'Active';

  @override
  String get projectStatusOnHold => 'On hold';

  @override
  String get projectStatusSomeday => 'Someday';

  @override
  String get projectStatusDone => 'Done';

  @override
  String get projectStatusDropped => 'Dropped';

  @override
  String get projectChangeStatus => 'Change status';

  @override
  String get projectAwaitingTooltip =>
      'Awaiting — in motion via waiting or scheduled items';

  @override
  String get projectStalledTooltip =>
      'Stalled — no next action, waiting, or scheduled item';

  @override
  String get projectStalledBanner =>
      'Stalled — no next action, waiting, or scheduled item defined. Add a next action to get this moving.';

  @override
  String get projectAwaitingBanner =>
      'This project is moving through waiting or scheduled items only. Consider adding a follow-up next action so it doesn\'t stall when those clear.';

  @override
  String projectNextActionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count next actions',
      one: '1 next action',
    );
    return '$_temp0';
  }

  @override
  String projectWaitingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count waiting',
      one: '1 waiting',
    );
    return '$_temp0';
  }

  @override
  String engageHiddenByFilters(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count next actions are hidden by your filters',
      one: '1 next action is hidden by your filters',
    );
    return '$_temp0';
  }

  @override
  String get filterReset => 'Reset';

  @override
  String onboardingSeedExisting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'You already have $count projects.',
      one: 'You already have 1 project.',
    );
    return '$_temp0';
  }

  @override
  String get purchaseErrUnavailable => 'Purchases are not available right now.';

  @override
  String get purchaseErrProducts =>
      'Could not load products. Check your connection and try again.';

  @override
  String get purchaseErrOption => 'That option is not available right now.';

  @override
  String get purchaseErrNetwork =>
      'Network error. Check your connection and try again.';

  @override
  String get purchaseErrNotAllowed =>
      'Purchases are not allowed on this device.';

  @override
  String get purchaseErrPending => 'Your purchase is pending approval.';

  @override
  String get purchaseErrAlreadyOwned =>
      'You already own this — try Restore Purchases.';

  @override
  String get purchaseErrStore =>
      'The store is having trouble. Please try again later.';

  @override
  String get purchaseErrUnknown =>
      'Something went wrong with the purchase. Please try again.';

  @override
  String get backupErrEmpty => 'The backup is empty — nothing to import.';

  @override
  String get backupErrInvalidJson =>
      'This isn\'t valid JSON. Make sure you selected a complete, unedited Trayzero backup file.';

  @override
  String get backupErrNotBackup => 'This file is not a Trayzero backup.';

  @override
  String get backupErrNewerVersion =>
      'This backup was created by a newer version of the app. Update Trayzero, then try importing again.';

  @override
  String get backupErrUnrecognized =>
      'This file doesn\'t look like a Trayzero backup.';

  @override
  String get backupErrInvalidData =>
      'This backup contains invalid data and can\'t be imported.';

  @override
  String get backupErrReminders =>
      'Your data was restored, but some reminders could not be refreshed. Retry the import to refresh them.';

  @override
  String get backupErrRestoreFailed =>
      'Something went wrong while restoring. Your existing data was not changed by this attempt.';

  @override
  String backupCountItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String backupCountProjects(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count projects',
      one: '1 project',
    );
    return '$_temp0';
  }

  @override
  String backupCountContexts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contexts',
      one: '1 context',
    );
    return '$_temp0';
  }

  @override
  String backupCountAreas(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count areas',
      one: '1 area',
    );
    return '$_temp0';
  }

  @override
  String backupCountAttachments(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count attachments',
      one: '1 attachment',
    );
    return '$_temp0';
  }

  @override
  String backupCountReviews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reviews',
      one: '1 review',
    );
    return '$_temp0';
  }

  @override
  String get restoreFolderTitle => 'Restore from backup folder';

  @override
  String get restoreFolderIntro =>
      'Choose the folder where Trayzero saves backups, for example one kept by iCloud Drive, Google Drive or Syncthing. Restoring merges the backup into this device; it doesn\'t delete anything already here.';

  @override
  String get restoreFolderChoose => 'Choose backup folder';

  @override
  String get restoreFolderChange => 'Choose a different folder';

  @override
  String restoreFolderFrom(String name) {
    return 'Folder: $name';
  }

  @override
  String get restoreFolderEmpty => 'No Trayzero backups found in this folder.';

  @override
  String get restoreFolderFailed =>
      'Couldn\'t open this folder. Check that it\'s still available, or choose it again.';

  @override
  String restoreFolderItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String get restoreFolderUnreadable => 'Can\'t read this file';

  @override
  String get restoreFolderReading => 'Reading…';

  @override
  String get onboardingRestoreAction =>
      'Coming from another device? Restore a backup';

  @override
  String folderBackupStale(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return 'No fresh backup for $_temp0.';
  }

  @override
  String get folderBackupRepairHint =>
      'Choose the folder again if backups have stopped working.';

  @override
  String moreBackupSubtitleStale(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return 'No fresh backup for $_temp0 · tap to repair';
  }

  @override
  String get backupPromptTitle => 'Back up your tasks automatically';

  @override
  String get backupPromptBody =>
      'You\'ve captured a lot. Pick a folder in your own cloud or sync app and Trayzero will keep the latest 10 backups there. It\'s backup, not sync.';

  @override
  String get backupPromptAction => 'Choose folder';

  @override
  String get backupPromptDismiss => 'No thanks';

  @override
  String backupCardHealthy(String date) {
    return 'Backed up $date';
  }

  @override
  String get backupCardOffBody =>
      'Turn on to save a copy to a folder after every change.';

  @override
  String get backupCardTurnOn => 'Turn on';

  @override
  String get backupCardChooseAgain => 'Choose folder again';

  @override
  String get backupCardTryAgain => 'Try again';

  @override
  String get backupGroupBackUp => 'Back up';

  @override
  String get backupGroupRestore => 'Restore';

  @override
  String get backupAutoTitle => 'Back up automatically';

  @override
  String get backupAutoSubtitle => 'After each change';

  @override
  String get backupFolderTitle => 'Backup folder';

  @override
  String get backupExportTitle => 'Export a copy';

  @override
  String get backupExportSubtitle => 'Share a backup file once';

  @override
  String get backupRestoreTitle => 'Restore a backup';

  @override
  String get backupRestoreRowSubtitle => 'From your folder or a file';

  @override
  String get backupRestoreSheetBody =>
      'Choose where your backup is. You\'ll see what\'s inside before anything changes.';

  @override
  String get backupRestoreFromFolder => 'From backup folder';

  @override
  String get backupRestoreFromFolderHint => 'Recommended — pick a saved backup';

  @override
  String get backupRestoreFromFile => 'From a file';

  @override
  String get backupRestoreFromFileHint => 'A Trayzero backup (.json)';

  @override
  String get backupRestorePaste => 'Paste backup text';

  @override
  String get backupFootnote =>
      'Backup, not sync — your cloud or sync app carries the folder between devices.';

  @override
  String get backupCardJustNow => 'Backed up just now';

  @override
  String backupCardMinutesAgo(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minutes',
      one: '1 minute',
    );
    return 'Backed up $_temp0 ago';
  }

  @override
  String backupCardHoursAgo(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours hours',
      one: '1 hour',
    );
    return 'Backed up $_temp0 ago';
  }

  @override
  String get backupCardYesterday => 'Backed up yesterday';

  @override
  String get backupHowItWorks => 'How it works';

  @override
  String get backupHowTitle => 'How backup works';

  @override
  String get backupHowSaves =>
      'After you make changes, Trayzero saves a JSON copy of your data to the folder you choose, and keeps the latest 10 copies.';

  @override
  String get backupHowSync =>
      'Your cloud or sync app (for example iCloud Drive, Google Drive or Syncthing) carries that folder to your other devices. Trayzero itself never uploads or syncs anything.';

  @override
  String get backupHowMove =>
      'To move to another device, choose Restore a backup, then From backup folder.';

  @override
  String get microphoneAccessDenied =>
      'Microphone access is off. Allow it in Settings to record a voice memo.';

  @override
  String get filterTimeEnergy => 'Time & energy';

  @override
  String get clearDate => 'Clear date';

  @override
  String get reorderHandle => 'Drag to reorder';

  @override
  String get calendarConnectionTitle => 'Calendar connection';

  @override
  String get calendarTogether => 'Your plans, together.';

  @override
  String get calendarConnectionIntro =>
      'See your Trayzero commitments alongside the rest of your day.';

  @override
  String get calendarConnect => 'Connect calendar';

  @override
  String get calendarScope =>
      'Only scheduled items in Trayzero’s Calendar are published. Ordinary task deadlines stay in Trayzero.';

  @override
  String get calendarAutomatic => 'Automatic updates';

  @override
  String get calendarAutomaticHelp =>
      'Updates while you use Trayzero and when you reopen it.';

  @override
  String get calendarPaused => 'Paused';

  @override
  String get calendarConnected => 'Connected';

  @override
  String get calendarNeedsAttention => 'Needs attention';

  @override
  String get calendarPauseHelp =>
      'Existing calendar events stay in place. Changes will wait until you resume updates or choose Update now.';

  @override
  String calendarLinkedCount(int count) {
    return '$count linked events';
  }

  @override
  String calendarLastUpdated(String when) {
    return 'Last updated: $when';
  }

  @override
  String get calendarChangesWaiting => 'Changes waiting to update';

  @override
  String get calendarUpdateNow => 'Update now';

  @override
  String get calendarManage => 'Manage connection';

  @override
  String get calendarWorking => 'Updating calendar connection…';

  @override
  String get calendarRestoreAccess => 'Restore access';

  @override
  String get calendarUpdateFailed =>
      'Some changes could not be applied. Your last successful update is shown above. Try again to finish updating.';

  @override
  String get calendarRemovalPending => 'Removal pending';

  @override
  String calendarRemoveFailed(int count) {
    return '$count events could not be removed. Automatic updates are stopped. Retry removal, or disconnect and keep the remaining events.';
  }

  @override
  String get calendarSaveFailed =>
      'Could not save this change. Check the connection settings and try again.';

  @override
  String get calendarNoWritable =>
      'No writable calendars are available. Add a calendar in your device’s calendar settings, then try again.';

  @override
  String get calendarChangeDestination => 'Change destination';

  @override
  String get calendarChooseDestination => 'Choose your calendar';

  @override
  String get calendarMoveHelp =>
      'Linked events will move to the new calendar. Other calendar events stay where they are. Automatic updates keep your current setting.';

  @override
  String calendarSetupCount(int count) {
    return '$count scheduled items will be published. Previously linked events are reused where available.';
  }

  @override
  String get calendarMoveEvents => 'Move linked events';

  @override
  String get calendarConnectAndAdd => 'Connect and add events';

  @override
  String get calendarDisconnect => 'Disconnect calendar';

  @override
  String get calendarDisconnectQuestion => 'Disconnect calendar?';

  @override
  String get calendarDisconnectHelp =>
      'Choose what happens to linked calendar events. Your Trayzero items and unrelated calendar events will remain.';

  @override
  String get calendarKeepEvents => 'Keep events in my calendar';

  @override
  String get calendarKeepHelp =>
      'Stop updates and leave events in place. Reconnecting can reuse these links.';

  @override
  String calendarRemoveEvents(int count) {
    return 'Remove $count linked events';
  }

  @override
  String get calendarRemoveHelp =>
      'Remove only events linked to this connection. Failed removals remain available to retry.';

  @override
  String get calendarHowItWorks => 'How linked events work';

  @override
  String get calendarRules =>
      'Trayzero publishes scheduled Calendar items to your chosen device calendar. Ordinary task deadlines are excluded.\n\nEdit linked titles, notes, times and recurrence in Trayzero. Updating can overwrite edits made in your calendar app. Events currently use a one-hour duration.\n\nCompleting, trashing or moving an item off Calendar removes its linked event on the next update. A recurring series advances to the next occurrence.\n\nPausing keeps events and their links. Disconnecting lets you keep or remove linked events. Trayzero items are never deleted by disconnecting.';

  @override
  String get calendarBringEvents => 'Bring events into Trayzero';

  @override
  String get calendarImportCopies =>
      'Choose events to copy into your Inbox or Calendar. Copies do not follow later changes to the original events. Originals stay unchanged.';

  @override
  String get calendarChooseEvents => 'Choose events';

  @override
  String get calendarImportSource => 'Choose a source calendar';

  @override
  String get calendarImportDestination => 'Add selected events to';

  @override
  String calendarAddSelected(int count) {
    return 'Add $count events';
  }

  @override
  String get calendarNoImportEvents =>
      'No new events to import. Events already added or linked to Trayzero are excluded. The range is the past 7 days and the next year.';

  @override
  String get calendarImportFailed =>
      'Could not import calendar events. Check calendar access and try again.';

  @override
  String get calendarDeviceHelp =>
      'Uses your device’s calendar. No Trayzero account needed. A shared calendar may be visible to other people with access to it.';
}
