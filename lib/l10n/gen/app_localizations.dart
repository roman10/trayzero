import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('ja'),
    Locale('ko'),
    Locale('pt'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
  ];

  /// App brand name. Do not translate.
  ///
  /// In en, this message translates to:
  /// **'Trayzero'**
  String get appName;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @enable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get enable;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get selectAll;

  /// No description provided for @selectNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get selectNone;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// GTD term — the universal capture bucket.
  ///
  /// In en, this message translates to:
  /// **'Inbox'**
  String get inbox;

  /// Bottom-nav label for the Engage tab — the imperative verb 'do', not the auxiliary 'do you'.
  ///
  /// In en, this message translates to:
  /// **'Do'**
  String get doVerb;

  /// No description provided for @projects.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get projects;

  /// No description provided for @review.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get review;

  /// Bottom-nav label leading to Settings/More.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @navInbox.
  ///
  /// In en, this message translates to:
  /// **'Inbox'**
  String get navInbox;

  /// No description provided for @navDo.
  ///
  /// In en, this message translates to:
  /// **'Do'**
  String get navDo;

  /// No description provided for @navProjects.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get navProjects;

  /// No description provided for @navReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get navReview;

  /// No description provided for @navMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get navMore;

  /// GTD stage 1 — record anything that has your attention.
  ///
  /// In en, this message translates to:
  /// **'Capture'**
  String get capture;

  /// GTD stage 2 — decide what each captured item is.
  ///
  /// In en, this message translates to:
  /// **'Clarify'**
  String get clarify;

  /// GTD stage 3 — file outcomes onto the right list.
  ///
  /// In en, this message translates to:
  /// **'Organize'**
  String get organize;

  /// GTD stage 4 — review your lists regularly.
  ///
  /// In en, this message translates to:
  /// **'Reflect'**
  String get reflect;

  /// GTD stage 5 — actually do the work.
  ///
  /// In en, this message translates to:
  /// **'Engage'**
  String get engage;

  /// No description provided for @nextAction.
  ///
  /// In en, this message translates to:
  /// **'Next action'**
  String get nextAction;

  /// No description provided for @waitingFor.
  ///
  /// In en, this message translates to:
  /// **'Waiting for'**
  String get waitingFor;

  /// No description provided for @someday.
  ///
  /// In en, this message translates to:
  /// **'Someday'**
  String get someday;

  /// No description provided for @somedayMaybe.
  ///
  /// In en, this message translates to:
  /// **'Someday / Maybe'**
  String get somedayMaybe;

  /// No description provided for @reference.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get reference;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @project.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get project;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @scheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get scheduled;

  /// No description provided for @needsClarifying.
  ///
  /// In en, this message translates to:
  /// **'Needs clarifying'**
  String get needsClarifying;

  /// Tooltip / button that opens the GTD workflow diagram.
  ///
  /// In en, this message translates to:
  /// **'How GTD works'**
  String get howGtdWorks;

  /// Settings entry opening the GTD overview.
  ///
  /// In en, this message translates to:
  /// **'What is GTD?'**
  String get whatIsGtd;

  /// No description provided for @onboardingPage1Title.
  ///
  /// In en, this message translates to:
  /// **'Get it out of your head'**
  String get onboardingPage1Title;

  /// No description provided for @onboardingPage1Body.
  ///
  /// In en, this message translates to:
  /// **'Anything that has your attention — a task, an idea, a worry — goes into the Inbox. The point is to free your mind, not to organize yet.'**
  String get onboardingPage1Body;

  /// No description provided for @onboardingPage2Title.
  ///
  /// In en, this message translates to:
  /// **'Clarify, one item at a time'**
  String get onboardingPage2Title;

  /// No description provided for @onboardingPage2Body.
  ///
  /// In en, this message translates to:
  /// **'The Process flow walks each captured item through the GTD decision tree: is it actionable? Less than two minutes? Delegate? A project? A next action?'**
  String get onboardingPage2Body;

  /// No description provided for @onboardingPage3Title.
  ///
  /// In en, this message translates to:
  /// **'Engage when you have time'**
  String get onboardingPage3Title;

  /// No description provided for @onboardingPage3Body.
  ///
  /// In en, this message translates to:
  /// **'The Do tab filters next actions by context, energy and time available, so you always know what you could be doing right now.'**
  String get onboardingPage3Body;

  /// No description provided for @onboardingPage4Title.
  ///
  /// In en, this message translates to:
  /// **'Review to stay trustworthy'**
  String get onboardingPage4Title;

  /// No description provided for @onboardingPage4Body.
  ///
  /// In en, this message translates to:
  /// **'Weekly Reviews keep the system honest. Once a week, run through every list, empty your inbox, and look ahead.'**
  String get onboardingPage4Body;

  /// No description provided for @onboardingSeedTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re ready'**
  String get onboardingSeedTitle;

  /// No description provided for @onboardingSeedBody.
  ///
  /// In en, this message translates to:
  /// **'Default contexts (@phone, @computer, @errands, @home, @office, @anywhere, @waiting) are seeded for you. You can add or edit them in Settings.'**
  String get onboardingSeedBody;

  /// No description provided for @onboardingSeedSampleLabel.
  ///
  /// In en, this message translates to:
  /// **'Seed a sample project'**
  String get onboardingSeedSampleLabel;

  /// No description provided for @onboardingSeedSampleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Adds a starter project plus a few items so the app isn\'t empty.'**
  String get onboardingSeedSampleSubtitle;

  /// No description provided for @onboardingFinish.
  ///
  /// In en, this message translates to:
  /// **'Let\'s go'**
  String get onboardingFinish;

  /// No description provided for @inboxEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Inbox zero'**
  String get inboxEmptyTitle;

  /// No description provided for @inboxEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Nothing to clarify. Tap Capture to brain-dump anything that has your attention — you\'ll process it later.'**
  String get inboxEmptyMessage;

  /// No description provided for @inboxEmptyAction.
  ///
  /// In en, this message translates to:
  /// **'Capture something'**
  String get inboxEmptyAction;

  /// Header in the inbox list showing how many items are waiting to be clarified.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No items to clarify} =1{1 item to clarify} other{{count} items to clarify}}'**
  String inboxItemsToClarify(int count);

  /// No description provided for @processInbox.
  ///
  /// In en, this message translates to:
  /// **'Process inbox'**
  String get processInbox;

  /// No description provided for @deleteItemsConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Delete 1 item?} other{Delete {count} items?}}'**
  String deleteItemsConfirmTitle(int count);

  /// No description provided for @deleteItemsConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This permanently removes them and their attachments. This can\'t be undone.'**
  String get deleteItemsConfirmBody;

  /// No description provided for @deletedItemsSnackbar.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Deleted 1 item.} other{Deleted {count} items.}}'**
  String deletedItemsSnackbar(int count);

  /// No description provided for @filedItemsSnackbar.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Filed 1 into the project.} other{Filed {count} into the project.}}'**
  String filedItemsSnackbar(int count);

  /// No description provided for @movedItemsSnackbar.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Moved 1 to {destination}.} other{Moved {count} to {destination}.}}'**
  String movedItemsSnackbar(int count, String destination);

  /// No description provided for @selectionCountTitle.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String selectionCountTitle(int count);

  /// No description provided for @captureTitle.
  ///
  /// In en, this message translates to:
  /// **'Brain dump'**
  String get captureTitle;

  /// No description provided for @captureHint.
  ///
  /// In en, this message translates to:
  /// **'What\'s on your mind?'**
  String get captureHint;

  /// No description provided for @captureNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get captureNotesHint;

  /// No description provided for @captureEmptyError.
  ///
  /// In en, this message translates to:
  /// **'Enter something to capture'**
  String get captureEmptyError;

  /// No description provided for @captureSubmit.
  ///
  /// In en, this message translates to:
  /// **'Add to inbox'**
  String get captureSubmit;

  /// No description provided for @dictate.
  ///
  /// In en, this message translates to:
  /// **'Dictate'**
  String get dictate;

  /// No description provided for @stopDictation.
  ///
  /// In en, this message translates to:
  /// **'Stop dictation'**
  String get stopDictation;

  /// No description provided for @processTitle.
  ///
  /// In en, this message translates to:
  /// **'Process inbox'**
  String get processTitle;

  /// No description provided for @processCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Inbox zero!'**
  String get processCompleteTitle;

  /// No description provided for @processCompleteNoItems.
  ///
  /// In en, this message translates to:
  /// **'There is nothing to clarify.'**
  String get processCompleteNoItems;

  /// No description provided for @processCompleteStats.
  ///
  /// In en, this message translates to:
  /// **'You filed {filed}, knocked out {doneNow} in under 2 minutes, and trashed {trashed}. Nicely done.'**
  String processCompleteStats(int filed, int doneNow, int trashed);

  /// No description provided for @processStepCounter.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total}'**
  String processStepCounter(int step, int total);

  /// No description provided for @processItemsRemaining.
  ///
  /// In en, this message translates to:
  /// **'{count} left'**
  String processItemsRemaining(int count);

  /// No description provided for @previousStepTooltip.
  ///
  /// In en, this message translates to:
  /// **'Previous step'**
  String get previousStepTooltip;

  /// No description provided for @skipItemTooltip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skipItemTooltip;

  /// No description provided for @actionableQuestion.
  ///
  /// In en, this message translates to:
  /// **'Is this actionable?'**
  String get actionableQuestion;

  /// No description provided for @actionableYes.
  ///
  /// In en, this message translates to:
  /// **'Yes — there is something to do'**
  String get actionableYes;

  /// No description provided for @actionableReference.
  ///
  /// In en, this message translates to:
  /// **'No — keep as reference'**
  String get actionableReference;

  /// No description provided for @actionableSomeday.
  ///
  /// In en, this message translates to:
  /// **'No — someday / maybe'**
  String get actionableSomeday;

  /// No description provided for @actionableTrash.
  ///
  /// In en, this message translates to:
  /// **'Trash'**
  String get actionableTrash;

  /// No description provided for @twoMinQuestion.
  ///
  /// In en, this message translates to:
  /// **'Will it take less than 2 minutes?'**
  String get twoMinQuestion;

  /// No description provided for @twoMinYes.
  ///
  /// In en, this message translates to:
  /// **'Yes — I\'ll do it now'**
  String get twoMinYes;

  /// No description provided for @twoMinNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get twoMinNo;

  /// No description provided for @delegateQuestion.
  ///
  /// In en, this message translates to:
  /// **'Can someone else do it?'**
  String get delegateQuestion;

  /// No description provided for @waitingOnPromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Who are you waiting on?'**
  String get waitingOnPromptTitle;

  /// No description provided for @waitingOnPromptHint.
  ///
  /// In en, this message translates to:
  /// **'Name or system'**
  String get waitingOnPromptHint;

  /// No description provided for @multiStepQuestion.
  ///
  /// In en, this message translates to:
  /// **'Does it need more than one step?'**
  String get multiStepQuestion;

  /// No description provided for @recurrencePrompt.
  ///
  /// In en, this message translates to:
  /// **'Repeat?'**
  String get recurrencePrompt;

  /// No description provided for @recurrenceOff.
  ///
  /// In en, this message translates to:
  /// **'Doesn\'t repeat'**
  String get recurrenceOff;

  /// No description provided for @capturedLabel.
  ///
  /// In en, this message translates to:
  /// **'CAPTURED'**
  String get capturedLabel;

  /// No description provided for @engageTitle.
  ///
  /// In en, this message translates to:
  /// **'Do now'**
  String get engageTitle;

  /// No description provided for @engageEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No next actions yet'**
  String get engageEmptyTitle;

  /// No description provided for @engageEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Capture something or process your inbox to build your next actions list.'**
  String get engageEmptyMessage;

  /// No description provided for @engageInlineEmpty.
  ///
  /// In en, this message translates to:
  /// **'No next actions yet — capture or process your inbox.'**
  String get engageInlineEmpty;

  /// No description provided for @engageOpenInbox.
  ///
  /// In en, this message translates to:
  /// **'Open inbox'**
  String get engageOpenInbox;

  /// No description provided for @engageNoMatchTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches'**
  String get engageNoMatchTitle;

  /// No description provided for @engageNoMatchMessage.
  ///
  /// In en, this message translates to:
  /// **'No actions match the current filters. Try widening them or clear the filter.'**
  String get engageNoMatchMessage;

  /// No description provided for @hardLandscape.
  ///
  /// In en, this message translates to:
  /// **'Hard landscape'**
  String get hardLandscape;

  /// No description provided for @hardLandscapeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'due today & overdue'**
  String get hardLandscapeSubtitle;

  /// No description provided for @filterAllContexts.
  ///
  /// In en, this message translates to:
  /// **'All contexts'**
  String get filterAllContexts;

  /// No description provided for @filterAnyTime.
  ///
  /// In en, this message translates to:
  /// **'Any time'**
  String get filterAnyTime;

  /// No description provided for @filterUnder5m.
  ///
  /// In en, this message translates to:
  /// **'< 5m'**
  String get filterUnder5m;

  /// No description provided for @filterUnder15m.
  ///
  /// In en, this message translates to:
  /// **'< 15m'**
  String get filterUnder15m;

  /// No description provided for @filterUnder30m.
  ///
  /// In en, this message translates to:
  /// **'< 30m'**
  String get filterUnder30m;

  /// No description provided for @filterUnder1h.
  ///
  /// In en, this message translates to:
  /// **'< 1h'**
  String get filterUnder1h;

  /// No description provided for @filterAnyEnergy.
  ///
  /// In en, this message translates to:
  /// **'Any energy'**
  String get filterAnyEnergy;

  /// No description provided for @energyLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get energyLow;

  /// No description provided for @energyMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get energyMedium;

  /// No description provided for @energyHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get energyHigh;

  /// No description provided for @projectsTitle.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get projectsTitle;

  /// No description provided for @newProject.
  ///
  /// In en, this message translates to:
  /// **'New project'**
  String get newProject;

  /// No description provided for @organizeLooseActionsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Organize loose actions'**
  String get organizeLooseActionsTooltip;

  /// No description provided for @projectsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No projects yet'**
  String get projectsEmptyTitle;

  /// No description provided for @projectsEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'A project is any outcome that needs more than one action. Create one to organize related next actions and stay on track to a defined result.'**
  String get projectsEmptyMessage;

  /// No description provided for @projectMissingNextAction.
  ///
  /// In en, this message translates to:
  /// **'No next action defined'**
  String get projectMissingNextAction;

  /// No description provided for @projectActionCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 action} other{{count} actions}}'**
  String projectActionCount(int count);

  /// No description provided for @organizeActionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Organize actions'**
  String get organizeActionsTitle;

  /// No description provided for @organizeEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing loose'**
  String get organizeEmptyTitle;

  /// No description provided for @organizeEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Every next action already belongs to a project. New unassigned actions will show up here to be organized.'**
  String get organizeEmptyMessage;

  /// No description provided for @assignToProject.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Assign 1 to project} other{Assign {count} to project}}'**
  String assignToProject(int count);

  /// No description provided for @addNextActionTitle.
  ///
  /// In en, this message translates to:
  /// **'Add next action'**
  String get addNextActionTitle;

  /// No description provided for @addNextActionHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Email Sara the timeline'**
  String get addNextActionHint;

  /// No description provided for @addExistingActions.
  ///
  /// In en, this message translates to:
  /// **'Add existing actions'**
  String get addExistingActions;

  /// No description provided for @noUnassignedActionsMessage.
  ///
  /// In en, this message translates to:
  /// **'No unassigned next actions to pull in.'**
  String get noUnassignedActionsMessage;

  /// No description provided for @addCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Add 1} other{Add {count}}}'**
  String addCount(int count);

  /// No description provided for @editProject.
  ///
  /// In en, this message translates to:
  /// **'Edit project'**
  String get editProject;

  /// No description provided for @projectName.
  ///
  /// In en, this message translates to:
  /// **'Project name'**
  String get projectName;

  /// No description provided for @projectNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Launch the new website'**
  String get projectNameHint;

  /// No description provided for @projectNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a project name'**
  String get projectNameRequired;

  /// No description provided for @areaOfFocusOptional.
  ///
  /// In en, this message translates to:
  /// **'Area of focus (optional)'**
  String get areaOfFocusOptional;

  /// No description provided for @unfiledOption.
  ///
  /// In en, this message translates to:
  /// **'— Unfiled —'**
  String get unfiledOption;

  /// No description provided for @dueDate.
  ///
  /// In en, this message translates to:
  /// **'Due date'**
  String get dueDate;

  /// No description provided for @deleteProjectConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete project?'**
  String get deleteProjectConfirmTitle;

  /// No description provided for @deleteProjectWarning.
  ///
  /// In en, this message translates to:
  /// **'Items assigned to it become orphaned but are not deleted.'**
  String get deleteProjectWarning;

  /// No description provided for @addActionFab.
  ///
  /// In en, this message translates to:
  /// **'Add action'**
  String get addActionFab;

  /// No description provided for @projectOutcomeHint.
  ///
  /// In en, this message translates to:
  /// **'What does \"done\" look like?'**
  String get projectOutcomeHint;

  /// No description provided for @outcomeSection.
  ///
  /// In en, this message translates to:
  /// **'Outcome'**
  String get outcomeSection;

  /// No description provided for @nextActionsSection.
  ///
  /// In en, this message translates to:
  /// **'Next actions'**
  String get nextActionsSection;

  /// No description provided for @noNextActionsMessage.
  ///
  /// In en, this message translates to:
  /// **'No next actions yet.'**
  String get noNextActionsMessage;

  /// No description provided for @projectMissingNextActionError.
  ///
  /// In en, this message translates to:
  /// **'No next action defined. Every active project should own at least one.'**
  String get projectMissingNextActionError;

  /// No description provided for @statusTooltip.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusTooltip;

  /// No description provided for @reviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get reviewTitle;

  /// No description provided for @weeklyReviewCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly review'**
  String get weeklyReviewCardTitle;

  /// No description provided for @weeklyReviewCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Run through your inbox, lists, and projects. The ritual that keeps the system trustworthy.'**
  String get weeklyReviewCardSubtitle;

  /// No description provided for @calendarEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing tied to a specific day.'**
  String get calendarEmpty;

  /// No description provided for @waitingForEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing delegated.'**
  String get waitingForEmpty;

  /// No description provided for @somedayEmpty.
  ///
  /// In en, this message translates to:
  /// **'No future-maybe items.'**
  String get somedayEmpty;

  /// No description provided for @referenceEmpty.
  ///
  /// In en, this message translates to:
  /// **'No reference items.'**
  String get referenceEmpty;

  /// No description provided for @completedThisWeek.
  ///
  /// In en, this message translates to:
  /// **'Completed this week'**
  String get completedThisWeek;

  /// No description provided for @completedThisWeekEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing completed yet this week.'**
  String get completedThisWeekEmpty;

  /// No description provided for @bucketCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}}'**
  String bucketCount(int count);

  /// No description provided for @needsReDecision.
  ///
  /// In en, this message translates to:
  /// **'Needs re-decision'**
  String get needsReDecision;

  /// No description provided for @pastDueCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item past due} other{{count} items past due}}'**
  String pastDueCount(int count);

  /// No description provided for @reviewStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Empty your head'**
  String get reviewStep1Title;

  /// No description provided for @reviewStep1Body.
  ///
  /// In en, this message translates to:
  /// **'Capture anything that has your attention into the inbox so the system can be trusted.'**
  String get reviewStep1Body;

  /// No description provided for @reviewStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Process inbox to zero'**
  String get reviewStep2Title;

  /// No description provided for @reviewStep2Body.
  ///
  /// In en, this message translates to:
  /// **'Clarify every captured item using the decision tree until your inbox is empty.'**
  String get reviewStep2Body;

  /// No description provided for @reviewStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Review your next actions'**
  String get reviewStep3Title;

  /// No description provided for @reviewStep3Body.
  ///
  /// In en, this message translates to:
  /// **'Skim every action. Done? Mark it done. Stale? Edit or delete. Still next? Leave it.'**
  String get reviewStep3Body;

  /// No description provided for @reviewStep4Title.
  ///
  /// In en, this message translates to:
  /// **'Review your waiting-for list'**
  String get reviewStep4Title;

  /// No description provided for @reviewStep4Body.
  ///
  /// In en, this message translates to:
  /// **'Has anyone come back to you? Should you follow up? Update or remove.'**
  String get reviewStep4Body;

  /// No description provided for @reviewStep5Title.
  ///
  /// In en, this message translates to:
  /// **'Review every project'**
  String get reviewStep5Title;

  /// No description provided for @reviewStep5Body.
  ///
  /// In en, this message translates to:
  /// **'Each project should be active, on hold, or done — and each active project must own at least one next action.'**
  String get reviewStep5Body;

  /// No description provided for @reviewStep6Title.
  ///
  /// In en, this message translates to:
  /// **'Look at the next two weeks'**
  String get reviewStep6Title;

  /// No description provided for @reviewStep6Body.
  ///
  /// In en, this message translates to:
  /// **'Check your calendar items. Anything you can prepare for now?'**
  String get reviewStep6Body;

  /// No description provided for @reviewStep7Title.
  ///
  /// In en, this message translates to:
  /// **'Review someday / maybe'**
  String get reviewStep7Title;

  /// No description provided for @reviewStep7Body.
  ///
  /// In en, this message translates to:
  /// **'Any of these worth committing to now? Promote them to projects or next actions.'**
  String get reviewStep7Body;

  /// No description provided for @reviewStepCounter.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total}'**
  String reviewStepCounter(int step, int total);

  /// No description provided for @finishReview.
  ///
  /// In en, this message translates to:
  /// **'Finish review'**
  String get finishReview;

  /// No description provided for @reviewCompleteSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Weekly review complete'**
  String get reviewCompleteSnackbar;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search items, notes'**
  String get searchHint;

  /// No description provided for @searchMinChars.
  ///
  /// In en, this message translates to:
  /// **'Type at least two characters'**
  String get searchMinChars;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// No description provided for @searchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No matches for \"{query}\"'**
  String searchNoResults(String query);

  /// No description provided for @searchNoMatchTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches'**
  String get searchNoMatchTitle;

  /// No description provided for @searchNoMatchMessage.
  ///
  /// In en, this message translates to:
  /// **'No results match the current filters. Try widening them or clear the filter.'**
  String get searchNoMatchMessage;

  /// No description provided for @filterAllProjects.
  ///
  /// In en, this message translates to:
  /// **'All projects'**
  String get filterAllProjects;

  /// No description provided for @filterCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get filterCompleted;

  /// No description provided for @statusInbox.
  ///
  /// In en, this message translates to:
  /// **'Inbox'**
  String get statusInbox;

  /// No description provided for @statusNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get statusNext;

  /// No description provided for @statusWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get statusWaiting;

  /// No description provided for @statusSomeday.
  ///
  /// In en, this message translates to:
  /// **'Someday'**
  String get statusSomeday;

  /// No description provided for @statusReference.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get statusReference;

  /// No description provided for @appearanceSection.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceSection;

  /// No description provided for @themeLabel.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeLabel;

  /// No description provided for @themeFollowSystem.
  ///
  /// In en, this message translates to:
  /// **'Follow system'**
  String get themeFollowSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @hapticFeedback.
  ///
  /// In en, this message translates to:
  /// **'Haptic feedback'**
  String get hapticFeedback;

  /// No description provided for @organizationSection.
  ///
  /// In en, this message translates to:
  /// **'Organization'**
  String get organizationSection;

  /// No description provided for @contextsLabel.
  ///
  /// In en, this message translates to:
  /// **'Contexts'**
  String get contextsLabel;

  /// No description provided for @areasOfFocusLabel.
  ///
  /// In en, this message translates to:
  /// **'Areas of focus'**
  String get areasOfFocusLabel;

  /// No description provided for @areasOfFocusDescription.
  ///
  /// In en, this message translates to:
  /// **'Group projects by ongoing spheres of responsibility.'**
  String get areasOfFocusDescription;

  /// No description provided for @calendarSyncLabel.
  ///
  /// In en, this message translates to:
  /// **'Calendar sync'**
  String get calendarSyncLabel;

  /// No description provided for @calendarSyncDescription.
  ///
  /// In en, this message translates to:
  /// **'Mirror items with due dates to your system calendar.'**
  String get calendarSyncDescription;

  /// No description provided for @remindersSection.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get remindersSection;

  /// No description provided for @weeklyReviewNudge.
  ///
  /// In en, this message translates to:
  /// **'Weekly review nudge'**
  String get weeklyReviewNudge;

  /// No description provided for @weeklyReviewNudgeDescription.
  ///
  /// In en, this message translates to:
  /// **'A gentle reminder every Friday at 4 PM.'**
  String get weeklyReviewNudgeDescription;

  /// No description provided for @remindBeforeDue.
  ///
  /// In en, this message translates to:
  /// **'Remind me before due time'**
  String get remindBeforeDue;

  /// No description provided for @remindBeforeDueOff.
  ///
  /// In en, this message translates to:
  /// **'Off · only an alert at the due time'**
  String get remindBeforeDueOff;

  /// No description provided for @remindBeforeDueSuffix.
  ///
  /// In en, this message translates to:
  /// **'applies to items saved from now on'**
  String get remindBeforeDueSuffix;

  /// No description provided for @deferSurfaceLabel.
  ///
  /// In en, this message translates to:
  /// **'Deferred items remind me at'**
  String get deferSurfaceLabel;

  /// No description provided for @deferSurfaceDescription.
  ///
  /// In en, this message translates to:
  /// **'no-time deferred items stay in the list all day and nudge at this hour'**
  String get deferSurfaceDescription;

  /// No description provided for @checkingNotificationStatus.
  ///
  /// In en, this message translates to:
  /// **'Checking notification status…'**
  String get checkingNotificationStatus;

  /// No description provided for @dataSection.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get dataSection;

  /// No description provided for @exportBackup.
  ///
  /// In en, this message translates to:
  /// **'Export backup'**
  String get exportBackup;

  /// No description provided for @exportBackupDescriptionIos.
  ///
  /// In en, this message translates to:
  /// **'Share a JSON copy. Save it to a cloud drive (e.g. Files → iCloud Drive) for backup.'**
  String get exportBackupDescriptionIos;

  /// No description provided for @exportBackupDescriptionAndroid.
  ///
  /// In en, this message translates to:
  /// **'Share a JSON copy. Save it to a cloud drive (e.g. Google Drive) for backup.'**
  String get exportBackupDescriptionAndroid;

  /// No description provided for @exportBackupError.
  ///
  /// In en, this message translates to:
  /// **'Could not export: {error}'**
  String exportBackupError(String error);

  /// No description provided for @weeklyBackupReminder.
  ///
  /// In en, this message translates to:
  /// **'Weekly backup reminder'**
  String get weeklyBackupReminder;

  /// No description provided for @weeklyBackupReminderDescription.
  ///
  /// In en, this message translates to:
  /// **'Nudge me every Sunday morning to export and save.'**
  String get weeklyBackupReminderDescription;

  /// No description provided for @importBackup.
  ///
  /// In en, this message translates to:
  /// **'Import backup'**
  String get importBackup;

  /// No description provided for @importBackupDescription.
  ///
  /// In en, this message translates to:
  /// **'Restore a Trayzero backup, or import a Google Tasks (Takeout) export.'**
  String get importBackupDescription;

  /// No description provided for @importConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Import this backup?'**
  String get importConfirmTitle;

  /// No description provided for @importConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This will add or update {sections}.\n\nExisting entries with the same id will be overwritten with the backup version. This cannot be undone.'**
  String importConfirmBody(String sections);

  /// No description provided for @importButton.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importButton;

  /// No description provided for @importSourceSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Import backup'**
  String get importSourceSheetTitle;

  /// No description provided for @importFromFileTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a backup file'**
  String get importFromFileTitle;

  /// No description provided for @importFromFileDescription.
  ///
  /// In en, this message translates to:
  /// **'Recommended — a Trayzero .json backup or a Google Takeout Tasks.json.'**
  String get importFromFileDescription;

  /// No description provided for @importFromPasteTitle.
  ///
  /// In en, this message translates to:
  /// **'Paste backup JSON'**
  String get importFromPasteTitle;

  /// No description provided for @importFromPasteDescription.
  ///
  /// In en, this message translates to:
  /// **'Paste the backup text instead.'**
  String get importFromPasteDescription;

  /// No description provided for @pasteBackupHint.
  ///
  /// In en, this message translates to:
  /// **'Paste backup JSON…'**
  String get pasteBackupHint;

  /// No description provided for @privacySection.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacySection;

  /// No description provided for @crashReports.
  ///
  /// In en, this message translates to:
  /// **'Send crash reports'**
  String get crashReports;

  /// No description provided for @crashReportsDescription.
  ///
  /// In en, this message translates to:
  /// **'Anonymous crash + error reports via Sentry. No personal data is collected. Off by default.'**
  String get crashReportsDescription;

  /// No description provided for @crashReportsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Crash reports will be sent on next launch'**
  String get crashReportsEnabled;

  /// No description provided for @crashReportsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Crash reporting disabled'**
  String get crashReportsDisabled;

  /// No description provided for @aboutSection.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutSection;

  /// No description provided for @showOnboardingAgain.
  ///
  /// In en, this message translates to:
  /// **'Show onboarding again'**
  String get showOnboardingAgain;

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get versionLabel;

  /// No description provided for @settingsFooter.
  ///
  /// In en, this message translates to:
  /// **'Local-first. Your data stays on this device. Inspired by David Allen\'s Getting Things Done methodology.'**
  String get settingsFooter;

  /// No description provided for @editTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editTitle;

  /// No description provided for @savedIndicator.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get savedIndicator;

  /// No description provided for @titleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get titleLabel;

  /// No description provided for @notesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesLabel;

  /// No description provided for @statusSection.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusSection;

  /// No description provided for @contextSection.
  ///
  /// In en, this message translates to:
  /// **'Context'**
  String get contextSection;

  /// No description provided for @energySection.
  ///
  /// In en, this message translates to:
  /// **'Energy'**
  String get energySection;

  /// No description provided for @timeEstimateSection.
  ///
  /// In en, this message translates to:
  /// **'Time estimate'**
  String get timeEstimateSection;

  /// No description provided for @waitingOnSection.
  ///
  /// In en, this message translates to:
  /// **'Waiting on'**
  String get waitingOnSection;

  /// No description provided for @waitingOnHint.
  ///
  /// In en, this message translates to:
  /// **'Who or what are you waiting for?'**
  String get waitingOnHint;

  /// No description provided for @projectSection.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get projectSection;

  /// No description provided for @datesSection.
  ///
  /// In en, this message translates to:
  /// **'Dates'**
  String get datesSection;

  /// No description provided for @dueLabel.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get dueLabel;

  /// No description provided for @deferUntilLabel.
  ///
  /// In en, this message translates to:
  /// **'Defer until'**
  String get deferUntilLabel;

  /// No description provided for @repeatSection.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeatSection;

  /// No description provided for @recurrenceNeedsDeferHint.
  ///
  /// In en, this message translates to:
  /// **'Add a Defer date above to enable repeating — recurrence works by shifting that date forward.'**
  String get recurrenceNeedsDeferHint;

  /// No description provided for @recurrenceNeedsDueDateHint.
  ///
  /// In en, this message translates to:
  /// **'Add a Due or Defer date above to enable repeating — recurrence works by shifting that date forward.'**
  String get recurrenceNeedsDueDateHint;

  /// No description provided for @recurrenceExplanation.
  ///
  /// In en, this message translates to:
  /// **'When you complete this item, the next instance will appear with shifted dates.'**
  String get recurrenceExplanation;

  /// No description provided for @recurrenceNoDateNextActionError.
  ///
  /// In en, this message translates to:
  /// **'This repeats but has no Defer date, so completing it won\'t create a next occurrence. Add a Defer date above, or turn repeat Off.'**
  String get recurrenceNoDateNextActionError;

  /// No description provided for @recurrenceNoDateError.
  ///
  /// In en, this message translates to:
  /// **'This repeats but has no Due or Defer date, so completing it won\'t create a next occurrence. Add a date above, or turn repeat Off.'**
  String get recurrenceNoDateError;

  /// No description provided for @attachmentsSection.
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get attachmentsSection;

  /// No description provided for @markComplete.
  ///
  /// In en, this message translates to:
  /// **'Mark complete'**
  String get markComplete;

  /// No description provided for @reopen.
  ///
  /// In en, this message translates to:
  /// **'Reopen'**
  String get reopen;

  /// No description provided for @deleteItemConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete item?'**
  String get deleteItemConfirmTitle;

  /// No description provided for @deleteItemConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone.'**
  String get deleteItemConfirmBody;

  /// No description provided for @completeError.
  ///
  /// In en, this message translates to:
  /// **'Could not complete this item.'**
  String get completeError;

  /// No description provided for @reopenError.
  ///
  /// In en, this message translates to:
  /// **'Could not reopen this item.'**
  String get reopenError;

  /// No description provided for @remindersBlockedWarning.
  ///
  /// In en, this message translates to:
  /// **'Reminders are blocked in system settings — this won\'t alert you.'**
  String get remindersBlockedWarning;

  /// No description provided for @remindersOffWarning.
  ///
  /// In en, this message translates to:
  /// **'Reminders are off — this won\'t alert you.'**
  String get remindersOffWarning;

  /// No description provided for @preciseReminderOffWarning.
  ///
  /// In en, this message translates to:
  /// **'Precise reminder timing is off — short reminders may be delayed.'**
  String get preciseReminderOffWarning;

  /// No description provided for @allowExactAlarms.
  ///
  /// In en, this message translates to:
  /// **'Allow exact alarms'**
  String get allowExactAlarms;

  /// No description provided for @noContextsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No contexts yet — add some in Settings.'**
  String get noContextsAvailable;

  /// No description provided for @noActiveProjects.
  ///
  /// In en, this message translates to:
  /// **'No active projects yet.'**
  String get noActiveProjects;

  /// No description provided for @attachmentPhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get attachmentPhoto;

  /// No description provided for @attachmentCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get attachmentCamera;

  /// No description provided for @attachmentVoiceMemo.
  ///
  /// In en, this message translates to:
  /// **'Voice memo'**
  String get attachmentVoiceMemo;

  /// No description provided for @attachmentStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get attachmentStop;

  /// Tooltip on the button that removes an attachment.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// Tooltip on the close button of the full-screen image viewer.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get imageViewerClose;

  /// Page position in the image viewer when an item has several photos, e.g. 2 / 3.
  ///
  /// In en, this message translates to:
  /// **'{current} / {total}'**
  String imageViewerCounter(int current, int total);

  /// Accessibility label for the photo-count chip on an item card.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 photo} other{{count} photos}}'**
  String attachmentPhotoCount(int count);

  /// Accessibility label for the audio-count chip on an item card.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 voice memo} other{{count} voice memos}}'**
  String attachmentAudioCount(int count);

  /// Accessibility label for the file-count chip on an item card.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 file} other{{count} files}}'**
  String attachmentFileCount(int count);

  /// No description provided for @areasTitle.
  ///
  /// In en, this message translates to:
  /// **'Areas of focus'**
  String get areasTitle;

  /// No description provided for @newArea.
  ///
  /// In en, this message translates to:
  /// **'New area'**
  String get newArea;

  /// No description provided for @renameArea.
  ///
  /// In en, this message translates to:
  /// **'Rename area'**
  String get renameArea;

  /// No description provided for @areasEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'No areas yet. Areas are ongoing spheres of responsibility — Health, Career, Family — that hold projects.'**
  String get areasEmptyMessage;

  /// No description provided for @areaNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Health, Career, Family'**
  String get areaNameHint;

  /// No description provided for @deleteAreaConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"?'**
  String deleteAreaConfirmTitle(String name);

  /// No description provided for @deleteAreaWarning.
  ///
  /// In en, this message translates to:
  /// **'Projects in this area will become unfiled (they will not be deleted).'**
  String get deleteAreaWarning;

  /// No description provided for @contextsTitle.
  ///
  /// In en, this message translates to:
  /// **'Contexts'**
  String get contextsTitle;

  /// No description provided for @newContext.
  ///
  /// In en, this message translates to:
  /// **'New context'**
  String get newContext;

  /// No description provided for @editContext.
  ///
  /// In en, this message translates to:
  /// **'Edit context'**
  String get editContext;

  /// No description provided for @contextsEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'No contexts yet. Contexts tag actions with where or with what they can be done (@phone, @home, @errands).'**
  String get contextsEmptyMessage;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @iconLabel.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get iconLabel;

  /// No description provided for @colorLabel.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get colorLabel;

  /// No description provided for @deleteContextConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String deleteContextConfirmTitle(String name);

  /// No description provided for @deleteContextWarning.
  ///
  /// In en, this message translates to:
  /// **'Items using this context will lose it.'**
  String get deleteContextWarning;

  /// No description provided for @calendarSyncTitle.
  ///
  /// In en, this message translates to:
  /// **'Calendar sync'**
  String get calendarSyncTitle;

  /// No description provided for @calendarSyncIntro.
  ///
  /// In en, this message translates to:
  /// **'Mirror items with due dates to your system calendar, and pull events tagged \"#gtd\" back into your Trayzero inbox.'**
  String get calendarSyncIntro;

  /// No description provided for @enableCalendarSync.
  ///
  /// In en, this message translates to:
  /// **'Enable calendar sync'**
  String get enableCalendarSync;

  /// No description provided for @targetCalendar.
  ///
  /// In en, this message translates to:
  /// **'Target calendar'**
  String get targetCalendar;

  /// No description provided for @calendarAccessDenied.
  ///
  /// In en, this message translates to:
  /// **'Calendar access is denied. Grant it to choose a target calendar.'**
  String get calendarAccessDenied;

  /// No description provided for @grantCalendarAccess.
  ///
  /// In en, this message translates to:
  /// **'Grant calendar access'**
  String get grantCalendarAccess;

  /// No description provided for @noCalendarsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No calendars available yet. If you just granted access, give it a moment and retry. Also check that calendar sync is on for your account in the system Calendar/Accounts settings.'**
  String get noCalendarsAvailable;

  /// No description provided for @mirrorOutAction.
  ///
  /// In en, this message translates to:
  /// **'Mirror items → calendar'**
  String get mirrorOutAction;

  /// No description provided for @importInAction.
  ///
  /// In en, this message translates to:
  /// **'Import #gtd events → inbox'**
  String get importInAction;

  /// No description provided for @mirrorOutSuccess.
  ///
  /// In en, this message translates to:
  /// **'Mirrored {written} items out'**
  String mirrorOutSuccess(int written);

  /// No description provided for @mirrorOutSuccessWithStale.
  ///
  /// In en, this message translates to:
  /// **'Mirrored {written} items out, removed {removed} stale'**
  String mirrorOutSuccessWithStale(int written, int removed);

  /// No description provided for @importInSuccess.
  ///
  /// In en, this message translates to:
  /// **'Imported {count} calendar events'**
  String importInSuccess(int count);

  /// No description provided for @mirroringProgress.
  ///
  /// In en, this message translates to:
  /// **'Mirroring out…'**
  String get mirroringProgress;

  /// No description provided for @importingProgress.
  ///
  /// In en, this message translates to:
  /// **'Importing…'**
  String get importingProgress;

  /// No description provided for @calendarSyncTip.
  ///
  /// In en, this message translates to:
  /// **'Tip: type \"#gtd\" anywhere in a calendar event title and it will appear in your Trayzero inbox the next time you sync.'**
  String get calendarSyncTip;

  /// No description provided for @gtdDiagramTitle.
  ///
  /// In en, this message translates to:
  /// **'How GTD works'**
  String get gtdDiagramTitle;

  /// No description provided for @gtdDiagramSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Five steps to get every open loop out of your head and into a system you trust. Tap a highlighted list to jump there.'**
  String get gtdDiagramSubtitle;

  /// No description provided for @gtdAttribution.
  ///
  /// In en, this message translates to:
  /// **'Method by David Allen · gettingthingsdone.com'**
  String get gtdAttribution;

  /// No description provided for @youAreHere.
  ///
  /// In en, this message translates to:
  /// **'You\'re here'**
  String get youAreHere;

  /// No description provided for @gtdStage1Body.
  ///
  /// In en, this message translates to:
  /// **'Throw anything that has your attention into the Inbox — tasks, ideas, worries. No filtering, no organizing yet.'**
  String get gtdStage1Body;

  /// No description provided for @gtdStage2Body.
  ///
  /// In en, this message translates to:
  /// **'Take one item at a time and decide what it is. The Process flow walks each item through this decision tree:'**
  String get gtdStage2Body;

  /// No description provided for @gtdStage3Body.
  ///
  /// In en, this message translates to:
  /// **'The outcome lands on the right list, so nothing lives in your head anymore.'**
  String get gtdStage3Body;

  /// No description provided for @gtdStage3Footnote.
  ///
  /// In en, this message translates to:
  /// **'Waiting / Calendar / Someday / Reference live under Review.'**
  String get gtdStage3Footnote;

  /// No description provided for @gtdStage4Body.
  ///
  /// In en, this message translates to:
  /// **'Review your lists regularly — especially the Weekly Review — so the system stays trustworthy.'**
  String get gtdStage4Body;

  /// No description provided for @gtdStage5Body.
  ///
  /// In en, this message translates to:
  /// **'Just do the work — pick actions by context, time, energy and priority, with a clear mind.'**
  String get gtdStage5Body;

  /// No description provided for @decisionNotActionableQ.
  ///
  /// In en, this message translates to:
  /// **'Not actionable?'**
  String get decisionNotActionableQ;

  /// No description provided for @decisionNotActionableA.
  ///
  /// In en, this message translates to:
  /// **'Trash, Someday/Maybe, or Reference'**
  String get decisionNotActionableA;

  /// No description provided for @decisionTwoMinQ.
  ///
  /// In en, this message translates to:
  /// **'Takes under 2 minutes?'**
  String get decisionTwoMinQ;

  /// No description provided for @decisionTwoMinA.
  ///
  /// In en, this message translates to:
  /// **'Do it right now'**
  String get decisionTwoMinA;

  /// No description provided for @decisionDelegateQ.
  ///
  /// In en, this message translates to:
  /// **'Someone else should do it?'**
  String get decisionDelegateQ;

  /// No description provided for @decisionDelegateA.
  ///
  /// In en, this message translates to:
  /// **'Delegate → Waiting for'**
  String get decisionDelegateA;

  /// No description provided for @decisionMultiStepQ.
  ///
  /// In en, this message translates to:
  /// **'Needs more than one step?'**
  String get decisionMultiStepQ;

  /// No description provided for @decisionMultiStepA.
  ///
  /// In en, this message translates to:
  /// **'Make it a Project'**
  String get decisionMultiStepA;

  /// No description provided for @decisionOtherwiseQ.
  ///
  /// In en, this message translates to:
  /// **'Otherwise'**
  String get decisionOtherwiseQ;

  /// No description provided for @decisionOtherwiseA.
  ///
  /// In en, this message translates to:
  /// **'Define the very next action'**
  String get decisionOtherwiseA;

  /// Settings section title for tips and supporter purchases.
  ///
  /// In en, this message translates to:
  /// **'Support Trayzero'**
  String get supportTitle;

  /// Collapsed summary for non-supporters.
  ///
  /// In en, this message translates to:
  /// **'Tip the developer or become a supporter'**
  String get supportSummaryDefault;

  /// Collapsed summary for supporters.
  ///
  /// In en, this message translates to:
  /// **'Thanks for supporting Trayzero 💙'**
  String get supportSummarySupporter;

  /// Intro paragraph in the Support section.
  ///
  /// In en, this message translates to:
  /// **'Trayzero is free, with every feature unlocked. If it helps you, you can chip in — it keeps the app independent and ad-free.'**
  String get supportIntro;

  /// Shown when the store offering cannot be loaded.
  ///
  /// In en, this message translates to:
  /// **'Support options are unavailable right now.'**
  String get supportUnavailable;

  /// Header above the one-time tip options.
  ///
  /// In en, this message translates to:
  /// **'Leave a tip'**
  String get supportTipHeader;

  /// Label for the small consumable tip.
  ///
  /// In en, this message translates to:
  /// **'Small tip'**
  String get supportTipSmall;

  /// Label for the large consumable tip.
  ///
  /// In en, this message translates to:
  /// **'Large tip'**
  String get supportTipLarge;

  /// Title for the yearly supporter subscription.
  ///
  /// In en, this message translates to:
  /// **'Supporter — yearly'**
  String get supportSupporterYearly;

  /// Subtitle for yearly supporter; price is store-localized.
  ///
  /// In en, this message translates to:
  /// **'{price} / year · best value · unlocks supporter perks'**
  String supportSupporterYearlySubtitle(String price);

  /// Title for the monthly supporter subscription.
  ///
  /// In en, this message translates to:
  /// **'Supporter — monthly'**
  String get supportSupporterMonthly;

  /// Subtitle for monthly supporter; price is store-localized.
  ///
  /// In en, this message translates to:
  /// **'{price} / month · cancel anytime'**
  String supportSupporterMonthlySubtitle(String price);

  /// Title for the restore purchases row.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get supportRestore;

  /// Subtitle for restore row.
  ///
  /// In en, this message translates to:
  /// **'Already a supporter? Restore on this device.'**
  String get supportRestoreSubtitle;

  /// Auto-renewal disclosure shown under the supporter subscription rows.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions auto-renew until cancelled in Settings.'**
  String get supportAutoRenewNote;

  /// Row that opens the privacy policy web page.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get legalPrivacyPolicy;

  /// Row that opens the Terms of Use (EULA) web page.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get legalTermsOfUse;

  /// Snackbar after a successful tip.
  ///
  /// In en, this message translates to:
  /// **'Thank you so much! 💙'**
  String get supportThanksTip;

  /// Snackbar after becoming a supporter.
  ///
  /// In en, this message translates to:
  /// **'You\'re a supporter now — thank you! 💙'**
  String get supportThanksSupporter;

  /// Snackbar after a restore that found a purchase.
  ///
  /// In en, this message translates to:
  /// **'Purchases restored. Welcome back! 💙'**
  String get supportRestored;

  /// Snackbar after a restore that found nothing.
  ///
  /// In en, this message translates to:
  /// **'No previous purchases found.'**
  String get supportRestoreNone;

  /// Supporter badge label for yearly subscribers.
  ///
  /// In en, this message translates to:
  /// **'Supporter · yearly'**
  String get supportBadgeYearly;

  /// Supporter badge label for monthly subscribers.
  ///
  /// In en, this message translates to:
  /// **'Supporter · monthly'**
  String get supportBadgeMonthly;

  /// Supporter badge label when plan is unknown.
  ///
  /// In en, this message translates to:
  /// **'Supporter'**
  String get supportBadgeGeneric;

  /// Subtitle under the supporter badge.
  ///
  /// In en, this message translates to:
  /// **'Thank you for keeping Trayzero independent.'**
  String get supportBadgeSubtitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'ja',
    'ko',
    'pt',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hant':
            return AppLocalizationsZhHant();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'pt':
      return AppLocalizationsPt();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
