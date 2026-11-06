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
import 'app_localizations_ru.dart';
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
    Locale('ru'),
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

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

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

  /// GTD term — the universal capture bucket.
  ///
  /// In en, this message translates to:
  /// **'Inbox'**
  String get inbox;

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

  /// Projects screen: header for the active-projects section
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get projectSectionActive;

  /// Projects screen: header for projects not filed under any area of focus
  ///
  /// In en, this message translates to:
  /// **'Unfiled'**
  String get projectSectionUnfiled;

  /// Projects screen: header for the on-hold projects section
  ///
  /// In en, this message translates to:
  /// **'On hold'**
  String get projectSectionOnHold;

  /// Title of the sample onboarding project
  ///
  /// In en, this message translates to:
  /// **'Get the most out of GTD'**
  String get sampleProjectTitle;

  /// Outcome statement of the sample onboarding project
  ///
  /// In en, this message translates to:
  /// **'Capture inbox to zero daily and run a Weekly Review every Friday.'**
  String get sampleProjectOutcome;

  /// Sample onboarding next action: read the GTD primer
  ///
  /// In en, this message translates to:
  /// **'Read the GTD primer in Settings'**
  String get sampleItemReadPrimer;

  /// Sample onboarding next action: empty the email inbox
  ///
  /// In en, this message translates to:
  /// **'Empty my email inbox into here'**
  String get sampleItemEmptyEmail;

  /// Sample onboarding next action: schedule the weekly review
  ///
  /// In en, this message translates to:
  /// **'Schedule a recurring Friday Weekly Review'**
  String get sampleItemScheduleReview;

  /// Default GTD context: phone. Keep the leading @.
  ///
  /// In en, this message translates to:
  /// **'@phone'**
  String get seedContextPhone;

  /// Default GTD context: computer. Keep the leading @.
  ///
  /// In en, this message translates to:
  /// **'@computer'**
  String get seedContextComputer;

  /// Default GTD context: errands. Keep the leading @.
  ///
  /// In en, this message translates to:
  /// **'@errands'**
  String get seedContextErrands;

  /// Default GTD context: home. Keep the leading @.
  ///
  /// In en, this message translates to:
  /// **'@home'**
  String get seedContextHome;

  /// Default GTD context: office. Keep the leading @.
  ///
  /// In en, this message translates to:
  /// **'@office'**
  String get seedContextOffice;

  /// Default GTD context: anywhere. Keep the leading @.
  ///
  /// In en, this message translates to:
  /// **'@anywhere'**
  String get seedContextAnywhere;

  /// Default GTD context: waiting. Keep the leading @.
  ///
  /// In en, this message translates to:
  /// **'@waiting'**
  String get seedContextWaiting;

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

  /// No description provided for @completedItemsSnackbar.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Completed 1 item.} other{Completed {count} items.}}'**
  String completedItemsSnackbar(int count);

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

  /// No description provided for @dictationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Dictation is unavailable. You can still type your capture.'**
  String get dictationUnavailable;

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

  /// No description provided for @hardLandscape.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
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
  /// **'Review each outcome. Give stalled projects a next action, put them on hold, or mark them done. Waiting and scheduled work count as movement.'**
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

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @languageFollowSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageFollowSystem;

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

  /// No description provided for @calendarSyncLabel.
  ///
  /// In en, this message translates to:
  /// **'Calendar sync'**
  String get calendarSyncLabel;

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

  /// No description provided for @saveError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save your changes. Please try again.'**
  String get saveError;

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
  /// **'{price} / year · best value · supports development'**
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

  /// Progress while waiting for the native purchase sheet. Store is App Store or Google Play.
  ///
  /// In en, this message translates to:
  /// **'Opening {store}…'**
  String supportOpeningStore(String store);

  /// Progress while restoring store purchases.
  ///
  /// In en, this message translates to:
  /// **'Restoring purchases…'**
  String get supportRestoring;

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

  /// No description provided for @calendarLookupFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load your device calendars. Open your system Calendar app and check that your account is syncing, then return here and retry.'**
  String get calendarLookupFailed;

  /// No description provided for @calendarPermissionHelp.
  ///
  /// In en, this message translates to:
  /// **'If the permission prompt does not appear, open app settings and allow Calendar access, then return here.'**
  String get calendarPermissionHelp;

  /// No description provided for @calendarOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open app settings'**
  String get calendarOpenSettings;

  /// No description provided for @calendarSettingsFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open app settings. Open your device Settings, find Trayzero, and allow Calendar access.'**
  String get calendarSettingsFailed;

  /// No description provided for @calendarSelectionUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Your previously selected calendar is no longer available. Choose a calendar to continue.'**
  String get calendarSelectionUnavailable;

  /// No description provided for @appIcon.
  ///
  /// In en, this message translates to:
  /// **'App icon'**
  String get appIcon;

  /// No description provided for @appIconAndroidDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose a Home screen icon independently of App color. Your launcher may take a moment to update or apply its own tint.'**
  String get appIconAndroidDescription;

  /// No description provided for @appIconDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose an icon independently of App color. Your device may apply its own tint. iOS shows a confirmation alert when the icon changes.'**
  String get appIconDescription;

  /// No description provided for @appIconChangeFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not change the app icon. Try again while Trayzero is open.'**
  String get appIconChangeFailed;

  /// No description provided for @appColor.
  ///
  /// In en, this message translates to:
  /// **'App color'**
  String get appColor;

  /// No description provided for @appColorDescription.
  ///
  /// In en, this message translates to:
  /// **'Works in light and dark mode. GTD list colors keep their meaning.'**
  String get appColorDescription;

  /// No description provided for @paletteAmber.
  ///
  /// In en, this message translates to:
  /// **'Trayzero amber — Default'**
  String get paletteAmber;

  /// No description provided for @paletteBlue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get paletteBlue;

  /// No description provided for @paletteCyan.
  ///
  /// In en, this message translates to:
  /// **'Cyan'**
  String get paletteCyan;

  /// No description provided for @paletteTeal.
  ///
  /// In en, this message translates to:
  /// **'Teal'**
  String get paletteTeal;

  /// No description provided for @paletteGreen.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get paletteGreen;

  /// No description provided for @paletteViolet.
  ///
  /// In en, this message translates to:
  /// **'Violet'**
  String get paletteViolet;

  /// No description provided for @paletteRose.
  ///
  /// In en, this message translates to:
  /// **'Rose'**
  String get paletteRose;

  /// No description provided for @appIconNotificationNote.
  ///
  /// In en, this message translates to:
  /// **'Android notification accents use your selected app icon color when reminders are scheduled. Existing notifications update when rescheduled. Some devices may display the original app icon.'**
  String get appIconNotificationNote;

  /// No description provided for @appearanceSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save your appearance. Your previous setting has been restored.'**
  String get appearanceSaveFailed;

  /// Calendar sync result when native event deletion failed and will be retried.
  ///
  /// In en, this message translates to:
  /// **'{count} calendar events still need cleanup. Sync again to retry.'**
  String mirrorOutPendingCleanup(int count);

  /// No description provided for @weeklyReviewResume.
  ///
  /// In en, this message translates to:
  /// **'Resume weekly review'**
  String get weeklyReviewResume;

  /// No description provided for @weeklyReviewProgressSaved.
  ///
  /// In en, this message translates to:
  /// **'Your place is saved when you leave.'**
  String get weeklyReviewProgressSaved;

  /// No description provided for @weeklyReviewSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save your progress. Please try again.'**
  String get weeklyReviewSaveError;

  /// No description provided for @weeklyReviewActionError.
  ///
  /// In en, this message translates to:
  /// **'Could not save this change. Please try again.'**
  String get weeklyReviewActionError;

  /// No description provided for @weeklyReviewListEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing to review here.'**
  String get weeklyReviewListEmpty;

  /// No description provided for @weeklyReviewProjectAwaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting or scheduled work is moving this project forward.'**
  String get weeklyReviewProjectAwaiting;

  /// No description provided for @weeklyReviewProjectMoving.
  ///
  /// In en, this message translates to:
  /// **'Next action defined'**
  String get weeklyReviewProjectMoving;

  /// No description provided for @weeklyReviewOpenProject.
  ///
  /// In en, this message translates to:
  /// **'Open project'**
  String get weeklyReviewOpenProject;

  /// No description provided for @processTwoMinNo.
  ///
  /// In en, this message translates to:
  /// **'No — keep clarifying'**
  String get processTwoMinNo;

  /// No description provided for @twoMinRule.
  ///
  /// In en, this message translates to:
  /// **'The Two-Minute Rule: if it takes less time to do than to track, just do it.'**
  String get twoMinRule;

  /// No description provided for @delegateYes.
  ///
  /// In en, this message translates to:
  /// **'Yes — delegate & wait for them'**
  String get delegateYes;

  /// No description provided for @delegateNo.
  ///
  /// In en, this message translates to:
  /// **'No — it\'s on me'**
  String get delegateNo;

  /// No description provided for @singleStepQuestion.
  ///
  /// In en, this message translates to:
  /// **'Is this a single physical action?'**
  String get singleStepQuestion;

  /// No description provided for @singleStepYes.
  ///
  /// In en, this message translates to:
  /// **'Yes — single next action'**
  String get singleStepYes;

  /// No description provided for @singleStepProject.
  ///
  /// In en, this message translates to:
  /// **'No — this is a project'**
  String get singleStepProject;

  /// No description provided for @projectRule.
  ///
  /// In en, this message translates to:
  /// **'A project is any outcome that needs more than one action step and can finish within a year.'**
  String get projectRule;

  /// No description provided for @deferQuestion.
  ///
  /// In en, this message translates to:
  /// **'Does it have a specific day or time?'**
  String get deferQuestion;

  /// No description provided for @deferAsap.
  ///
  /// In en, this message translates to:
  /// **'No — do it as soon as I can'**
  String get deferAsap;

  /// No description provided for @deferCalendar.
  ///
  /// In en, this message translates to:
  /// **'Yes — put it on the calendar'**
  String get deferCalendar;

  /// No description provided for @deferChooseDate.
  ///
  /// In en, this message translates to:
  /// **'Defer until a date'**
  String get deferChooseDate;

  /// No description provided for @processDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Add details'**
  String get processDetailsTitle;

  /// No description provided for @processFileNextAction.
  ///
  /// In en, this message translates to:
  /// **'File as next action'**
  String get processFileNextAction;

  /// Short duration label for a number of minutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String minutesShort(int minutes);

  /// Clarify detail summary with a date formatted in the selected app language.
  ///
  /// In en, this message translates to:
  /// **'Deferred until {date}'**
  String deferredUntilSummary(String date);

  /// Clarify detail summary with a localized date and recurrence cadence.
  ///
  /// In en, this message translates to:
  /// **'Deferred until {date} · Repeat: {recurrence}'**
  String deferredRepeatingSummary(String date, String recurrence);

  /// No description provided for @recurrenceDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get recurrenceDaily;

  /// No description provided for @recurrenceWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get recurrenceWeekly;

  /// No description provided for @recurrenceMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get recurrenceMonthly;

  /// No description provided for @recurrenceYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get recurrenceYearly;

  /// No description provided for @createProject.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get createProject;

  /// No description provided for @projectPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Move to project'**
  String get projectPickerTitle;

  /// No description provided for @projectMoved.
  ///
  /// In en, this message translates to:
  /// **'Moved to project.'**
  String get projectMoved;

  /// No description provided for @projectDetached.
  ///
  /// In en, this message translates to:
  /// **'Removed from project.'**
  String get projectDetached;

  /// No description provided for @noProject.
  ///
  /// In en, this message translates to:
  /// **'No project'**
  String get noProject;

  /// No description provided for @decreaseRepeatInterval.
  ///
  /// In en, this message translates to:
  /// **'Decrease repeat interval'**
  String get decreaseRepeatInterval;

  /// No description provided for @increaseRepeatInterval.
  ///
  /// In en, this message translates to:
  /// **'Increase repeat interval'**
  String get increaseRepeatInterval;

  /// No description provided for @decreaseRepeatCount.
  ///
  /// In en, this message translates to:
  /// **'Decrease repeat count'**
  String get decreaseRepeatCount;

  /// No description provided for @increaseRepeatCount.
  ///
  /// In en, this message translates to:
  /// **'Increase repeat count'**
  String get increaseRepeatCount;

  /// No description provided for @repeatOn.
  ///
  /// In en, this message translates to:
  /// **'Repeat on'**
  String get repeatOn;

  /// No description provided for @repeatMonthlyOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get repeatMonthlyOn;

  /// No description provided for @repeatDayOfMonth.
  ///
  /// In en, this message translates to:
  /// **'Day of month'**
  String get repeatDayOfMonth;

  /// No description provided for @repeatDayOfWeek.
  ///
  /// In en, this message translates to:
  /// **'Day of week'**
  String get repeatDayOfWeek;

  /// No description provided for @repeatFirst.
  ///
  /// In en, this message translates to:
  /// **'First'**
  String get repeatFirst;

  /// No description provided for @repeatSecond.
  ///
  /// In en, this message translates to:
  /// **'Second'**
  String get repeatSecond;

  /// No description provided for @repeatThird.
  ///
  /// In en, this message translates to:
  /// **'Third'**
  String get repeatThird;

  /// No description provided for @repeatFourth.
  ///
  /// In en, this message translates to:
  /// **'Fourth'**
  String get repeatFourth;

  /// No description provided for @repeatFifth.
  ///
  /// In en, this message translates to:
  /// **'Fifth'**
  String get repeatFifth;

  /// No description provided for @repeatLast.
  ///
  /// In en, this message translates to:
  /// **'Last'**
  String get repeatLast;

  /// No description provided for @repeatEnds.
  ///
  /// In en, this message translates to:
  /// **'Ends'**
  String get repeatEnds;

  /// No description provided for @repeatNever.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get repeatNever;

  /// No description provided for @repeatOnDate.
  ///
  /// In en, this message translates to:
  /// **'On date'**
  String get repeatOnDate;

  /// No description provided for @repeatAfterCount.
  ///
  /// In en, this message translates to:
  /// **'After N times'**
  String get repeatAfterCount;

  /// No description provided for @weekdayListSeparator.
  ///
  /// In en, this message translates to:
  /// **', '**
  String get weekdayListSeparator;

  /// No description provided for @dueToday.
  ///
  /// In en, this message translates to:
  /// **'Due today'**
  String get dueToday;

  /// No description provided for @reschedule.
  ///
  /// In en, this message translates to:
  /// **'Reschedule'**
  String get reschedule;

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// No description provided for @drop.
  ///
  /// In en, this message translates to:
  /// **'Drop'**
  String get drop;

  /// No description provided for @trash.
  ///
  /// In en, this message translates to:
  /// **'Trash'**
  String get trash;

  /// Localized recurrence or item-card label; format dates and weekday names in the selected app language.
  ///
  /// In en, this message translates to:
  /// **'{energy} energy'**
  String itemEnergyLabel(String energy);

  /// Localized recurrence or item-card label; format dates and weekday names in the selected app language.
  ///
  /// In en, this message translates to:
  /// **'Waiting on {person}'**
  String waitingOnPerson(String person);

  /// Localized recurrence or item-card label; format dates and weekday names in the selected app language.
  ///
  /// In en, this message translates to:
  /// **'Overdue · {days}d'**
  String dueOverdueDays(int days);

  /// Localized recurrence or item-card label; format dates and weekday names in the selected app language.
  ///
  /// In en, this message translates to:
  /// **'Due today, {time}'**
  String dueTodayAt(String time);

  /// Localized recurrence or item-card label; format dates and weekday names in the selected app language.
  ///
  /// In en, this message translates to:
  /// **'Select {title}'**
  String selectItem(String title);

  /// Localized recurrence or item-card label; format dates and weekday names in the selected app language.
  ///
  /// In en, this message translates to:
  /// **'Mark {title} done'**
  String markItemDone(String title);

  /// Localized recurrence or item-card label; format dates and weekday names in the selected app language.
  ///
  /// In en, this message translates to:
  /// **'Last on {date}'**
  String repeatLastOnDate(String date);

  /// Localized recurrence or item-card label; format dates and weekday names in the selected app language.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{After 1 occurrence} other{After {count} occurrences}}'**
  String repeatAfterOccurrences(int count);

  /// Localized recurrence or item-card label; format dates and weekday names in the selected app language.
  ///
  /// In en, this message translates to:
  /// **'{pattern} · until {date}'**
  String recurrenceUntilSummary(String pattern, String date);

  /// Localized recurrence or item-card label; format dates and weekday names in the selected app language.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{pattern} · 1 occurrence} other{{pattern} · {count} occurrences}}'**
  String recurrenceCountSummary(String pattern, int count);

  /// Localized recurrence or item-card label; format dates and weekday names in the selected app language.
  ///
  /// In en, this message translates to:
  /// **'{cadence} on {weekdays}'**
  String recurrenceOnWeekdays(String cadence, String weekdays);

  /// Localized recurrence or item-card label; format dates and weekday names in the selected app language.
  ///
  /// In en, this message translates to:
  /// **'{cadence} on the {ordinal, select, first{first} second{second} third{third} fourth{fourth} fifth{fifth} other{last}} {weekday}'**
  String recurrenceOnNthWeekday(String cadence, String ordinal, String weekday);

  /// Localized recurrence or item-card label; format dates and weekday names in the selected app language.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Every day} other{Every {count} days}}'**
  String repeatEveryDays(int count);

  /// Localized recurrence or item-card label; format dates and weekday names in the selected app language.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Every week} other{Every {count} weeks}}'**
  String repeatEveryWeeks(int count);

  /// Localized recurrence or item-card label; format dates and weekday names in the selected app language.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Every month} other{Every {count} months}}'**
  String repeatEveryMonths(int count);

  /// Localized recurrence or item-card label; format dates and weekday names in the selected app language.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Every year} other{Every {count} years}}'**
  String repeatEveryYears(int count);

  /// Save the current capture to the inbox and keep the sheet open for another item.
  ///
  /// In en, this message translates to:
  /// **'Add & continue'**
  String get captureAddContinue;

  /// Confirmation counts only Items saved during this capture sheet session, excluding the current unsaved draft.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item added to inbox} other{{count} items added to inbox}}'**
  String captureAddedCount(int count);

  /// No description provided for @folderBackupChoose.
  ///
  /// In en, this message translates to:
  /// **'Choose backup folder'**
  String get folderBackupChoose;

  /// No description provided for @folderBackupSaving.
  ///
  /// In en, this message translates to:
  /// **'Backing up…'**
  String get folderBackupSaving;

  /// No description provided for @folderBackupOff.
  ///
  /// In en, this message translates to:
  /// **'Automatic backups are off.'**
  String get folderBackupOff;

  /// No description provided for @folderBackupNever.
  ///
  /// In en, this message translates to:
  /// **'No successful backup yet.'**
  String get folderBackupNever;

  /// No description provided for @folderBackupLastSuccess.
  ///
  /// In en, this message translates to:
  /// **'Last backup: {date}'**
  String folderBackupLastSuccess(String date);

  /// No description provided for @folderBackupFailed.
  ///
  /// In en, this message translates to:
  /// **'Backup failed. Check folder access and free space, then try again.'**
  String get folderBackupFailed;

  /// No description provided for @folderBackupHistoryWarning.
  ///
  /// In en, this message translates to:
  /// **'Backup saved, but older backups could not be removed.'**
  String get folderBackupHistoryWarning;

  /// No description provided for @folderBackupNow.
  ///
  /// In en, this message translates to:
  /// **'Back up now'**
  String get folderBackupNow;

  /// Do tab segment: today's committed focus list.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get doViewToday;

  /// Do tab segment: all available next actions.
  ///
  /// In en, this message translates to:
  /// **'Next actions'**
  String get doViewNextActions;

  /// Card on Today inviting the daily plan.
  ///
  /// In en, this message translates to:
  /// **'Plan your day'**
  String get todayPlanCardTitle;

  /// Body of the plan-your-day card.
  ///
  /// In en, this message translates to:
  /// **'Pick what you’ll focus on today. It takes about two minutes.'**
  String get todayPlanCardBody;

  /// Button that opens the daily plan.
  ///
  /// In en, this message translates to:
  /// **'Plan today'**
  String get todayPlanAction;

  /// Line on the Today plan card: focused items left over from an earlier day need a keep-or-clear decision.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 from earlier needs a decision} other{{count} from earlier need a decision}}'**
  String todayCarryOverLine(int count);

  /// Heading of the focused items on Today.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get todayFocusHeader;

  /// Progress line: focused items completed today.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 done today} other{{count} done today}}'**
  String todayDoneCount(int count);

  /// Empty Today list title.
  ///
  /// In en, this message translates to:
  /// **'Nothing focused yet'**
  String get todayEmptyTitle;

  /// Empty Today list message.
  ///
  /// In en, this message translates to:
  /// **'Star next actions to commit to them today, or plan your day.'**
  String get todayEmptyMessage;

  /// Tooltip: star an item for Today.
  ///
  /// In en, this message translates to:
  /// **'Add to Today'**
  String get focusAddTooltip;

  /// Tooltip: unstar an item from Today.
  ///
  /// In en, this message translates to:
  /// **'Remove from Today'**
  String get focusRemoveTooltip;

  /// Screen-reader label for starring an item.
  ///
  /// In en, this message translates to:
  /// **'Add {title} to Today'**
  String focusAddItem(String title);

  /// Screen-reader label for unstarring an item.
  ///
  /// In en, this message translates to:
  /// **'Remove {title} from Today'**
  String focusRemoveItem(String title);

  /// Error when a Today focus change fails.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t update Today. Try again.'**
  String get focusError;

  /// Intro text on the daily plan screen.
  ///
  /// In en, this message translates to:
  /// **'Star what you’ll commit to today. Keep it short — everything else stays on your lists.'**
  String get planTodayIntro;

  /// Plan section: items focused on an earlier day.
  ///
  /// In en, this message translates to:
  /// **'From earlier'**
  String get planSectionCarryOver;

  /// Explains what happens to carried-over items that are not kept.
  ///
  /// In en, this message translates to:
  /// **'Items you don’t keep go back to their lists when you start your day.'**
  String get planCarryOverHint;

  /// Keep every carried-over item for today.
  ///
  /// In en, this message translates to:
  /// **'Keep all'**
  String get planKeepAll;

  /// Plan section: calendar items due today or overdue.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get planSectionCalendar;

  /// Trailing label on a calendar item in the daily plan: it is on Today automatically.
  ///
  /// In en, this message translates to:
  /// **'On Today'**
  String get planOnToday;

  /// Plan section: waiting-for items whose follow-up date has arrived.
  ///
  /// In en, this message translates to:
  /// **'Waiting follow-ups'**
  String get planSectionWaiting;

  /// Plan section: deferred next actions that became available today.
  ///
  /// In en, this message translates to:
  /// **'Available from today'**
  String get planSectionAvailable;

  /// Daily plan with nothing to choose from.
  ///
  /// In en, this message translates to:
  /// **'Nothing to plan yet. Process your inbox to build your next actions.'**
  String get planEmpty;

  /// Count of items focused for today on the plan screen.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Nothing focused yet} =1{1 focused for today} other{{count} focused for today}}'**
  String planFocusedCount(int count);

  /// Finishes the daily plan.
  ///
  /// In en, this message translates to:
  /// **'Start my day'**
  String get planStartDay;

  /// Snackbar after finishing the daily plan.
  ///
  /// In en, this message translates to:
  /// **'Today is planned'**
  String get planDoneSnackbar;

  /// Snackbar: carried-over items not kept were returned to their lists.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Day planned · 1 item back on its list} other{Day planned · {count} items back on their lists}}'**
  String planClearedSnackbar(int count);

  /// Error when finishing the daily plan fails.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t save your plan. Try again.'**
  String get planSaveError;

  /// Capture helper (English UI): quick-capture syntax.
  ///
  /// In en, this message translates to:
  /// **'Tip: add @context, #project, +tag, or a date like “tomorrow” or “due fri”.'**
  String get captureTipDates;

  /// Capture helper (non-English UI): context and project shortcuts.
  ///
  /// In en, this message translates to:
  /// **'Tip: add @context, #project, or +tag.'**
  String get captureTipSigils;

  /// Chip: start (defer) date.
  ///
  /// In en, this message translates to:
  /// **'Starts {date}'**
  String startsOnDate(String date);

  /// Chip: due date recognized in capture.
  ///
  /// In en, this message translates to:
  /// **'Due {date}'**
  String dueOnDate(String date);

  /// Capture chip: recognized project.
  ///
  /// In en, this message translates to:
  /// **'Project: {name}'**
  String captureChipProject(String name);

  /// Delete action on a recognized capture chip: keep the words in the title.
  ///
  /// In en, this message translates to:
  /// **'Keep as text'**
  String get captureKeepAsText;

  /// Screen-reader label for the row of recognized capture details.
  ///
  /// In en, this message translates to:
  /// **'Recognized details'**
  String get captureRecognized;

  /// Process Inbox: keep the start date typed at capture.
  ///
  /// In en, this message translates to:
  /// **'Start on {date}'**
  String deferUseStartDate(String date);

  /// Process Inbox: put the item on the calendar on the due date typed at capture.
  ///
  /// In en, this message translates to:
  /// **'On calendar {date}'**
  String deferUseDueDate(String date);

  /// Weekly review: active project without action activity for N days.
  ///
  /// In en, this message translates to:
  /// **'No activity in {days}+ days'**
  String weeklyReviewProjectInactive(int days);

  /// Button: mark a project reviewed.
  ///
  /// In en, this message translates to:
  /// **'Mark reviewed'**
  String get weeklyReviewMarkReviewed;

  /// State after a project is marked reviewed this session.
  ///
  /// In en, this message translates to:
  /// **'Reviewed'**
  String get weeklyReviewReviewed;

  /// When the project was last reviewed.
  ///
  /// In en, this message translates to:
  /// **'Last reviewed {date}'**
  String weeklyReviewLastReviewed(String date);

  /// Project never marked reviewed.
  ///
  /// In en, this message translates to:
  /// **'Not reviewed yet'**
  String get weeklyReviewNeverReviewed;

  /// Projects reviewed so far in this weekly review.
  ///
  /// In en, this message translates to:
  /// **'Reviewed {done} of {total}'**
  String weeklyReviewReviewedProgress(int done, int total);

  /// Settings tile and screen title: import tasks from another to-do app.
  ///
  /// In en, this message translates to:
  /// **'Import from another app'**
  String get importFromApp;

  /// Source tile for plain text or TaskPaper lists.
  ///
  /// In en, this message translates to:
  /// **'Plain text / TaskPaper'**
  String get importSourcePlainText;

  /// How to export from Todoist. Menu names follow Todoist's English UI.
  ///
  /// In en, this message translates to:
  /// **'Project menu › Export as a template › CSV, or a backup ZIP from Settings › Backups.'**
  String get importHintTodoist;

  /// How to export from TickTick.
  ///
  /// In en, this message translates to:
  /// **'On the TickTick website: Settings › Account › Backup & Import › Generate Backup (CSV).'**
  String get importHintTickTick;

  /// How to export from Nirvana.
  ///
  /// In en, this message translates to:
  /// **'In the Nirvana web app, export your data as CSV or JSON.'**
  String get importHintNirvana;

  /// How to export from OmniFocus.
  ///
  /// In en, this message translates to:
  /// **'Select projects, then Edit › Copy as TaskPaper. Paste here or save as a file.'**
  String get importHintOmniFocus;

  /// How to bring tasks from Things or another text list.
  ///
  /// In en, this message translates to:
  /// **'Things: copy to-dos and paste here, one task per line. Basic text import only; Things database exports are not supported.'**
  String get importHintPlainText;

  /// Button: open the file picker.
  ///
  /// In en, this message translates to:
  /// **'Choose file'**
  String get importChooseFile;

  /// Button: paste exported text instead of choosing a file.
  ///
  /// In en, this message translates to:
  /// **'Paste text'**
  String get importPasteText;

  /// Title of the paste dialog.
  ///
  /// In en, this message translates to:
  /// **'Paste tasks'**
  String get importPasteTitle;

  /// Hint in the paste text field.
  ///
  /// In en, this message translates to:
  /// **'One task per line. Indent tasks under a line ending in “:” to make a project.'**
  String get importPasteHint;

  /// Paste dialog button that shows the import preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get importPasteContinue;

  /// Preview reassurance that nothing is written yet.
  ///
  /// In en, this message translates to:
  /// **'Nothing has been added yet.'**
  String get importPreviewNothingYet;

  /// Preview section: projects.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get importPreviewProjects;

  /// Badge: this project will be created.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get importProjectNew;

  /// Badge: actions go into a project the user already has.
  ///
  /// In en, this message translates to:
  /// **'Adds to existing'**
  String get importProjectExisting;

  /// Number of actions going into one project.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 action} other{{count} actions}}'**
  String importProjectActions(int count);

  /// Comma-separated names of contexts the import creates.
  ///
  /// In en, this message translates to:
  /// **'New: {names}'**
  String importContextsNew(String names);

  /// Comma-separated names of the user's existing contexts the import reuses.
  ///
  /// In en, this message translates to:
  /// **'Already yours: {names}'**
  String importContextsExisting(String names);

  /// Preview section listing what was skipped or changed.
  ///
  /// In en, this message translates to:
  /// **'Good to know'**
  String get importGoodToKnow;

  /// Completed, dropped or cancelled tasks that are not imported.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 completed or dropped task skipped} other{{count} completed or dropped tasks skipped}}'**
  String importWarnCompleted(int count);

  /// Open actions with a due date are placed in Calendar.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 action with a due date goes to Calendar} other{{count} actions with a due date go to Calendar}}'**
  String importWarnCalendar(int count);

  /// Dates that could not be read are kept as text in notes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 date could not be read and is kept in notes} other{{count} dates could not be read and are kept in notes}}'**
  String importWarnDates(int count);

  /// Repeat rules that could not be mapped are kept in notes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 repeat rule is kept in notes} other{{count} repeat rules are kept in notes}}'**
  String importWarnRepeats(int count);

  /// Subtasks become separate actions.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 subtask becomes a separate action} other{{count} subtasks become separate actions}}'**
  String importWarnSubtasks(int count);

  /// Section, heading or folder names kept in notes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 task notes its section or heading} other{{count} tasks note their section or heading}}'**
  String importWarnSections(int count);

  /// Priority, flag or assignee have no equivalent and are dropped.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 task had a priority, flag or assignee that is not imported} other{{count} tasks had a priority, flag or assignee that is not imported}}'**
  String importWarnNotImported(int count);

  /// Rows without a title are skipped.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 row without a title skipped} other{{count} rows without a title skipped}}'**
  String importWarnUnreadable(int count);

  /// Result after importing.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 task added} other{{count} tasks added}}'**
  String importDoneTitle(int count);

  /// Result explanation of Undo.
  ///
  /// In en, this message translates to:
  /// **'Changed your mind? Undo removes exactly what this import added, and nothing else.'**
  String get importDoneBody;

  /// Button: remove everything the import added.
  ///
  /// In en, this message translates to:
  /// **'Undo import'**
  String get importUndo;

  /// Button: close the import screen.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get importFinish;

  /// Result after undoing an import.
  ///
  /// In en, this message translates to:
  /// **'Import undone'**
  String get importUndoneTitle;

  /// Explanation after undoing an import.
  ///
  /// In en, this message translates to:
  /// **'Everything this import added has been removed.'**
  String get importUndoneBody;

  /// Some reminders could not be scheduled yet.
  ///
  /// In en, this message translates to:
  /// **'Some reminders could not be scheduled yet. They will be set the next time the app opens.'**
  String get importRemindersFailed;

  /// The chosen file is not an export of the selected app. {source} is the app name.
  ///
  /// In en, this message translates to:
  /// **'This does not look like a {source} export. Check the steps and try again.'**
  String importErrorUnrecognized(String source);

  /// The file has no open task.
  ///
  /// In en, this message translates to:
  /// **'No open tasks found to import.'**
  String get importErrorNoTasks;

  /// The file is binary, corrupt or too large.
  ///
  /// In en, this message translates to:
  /// **'This file cannot be read. Choose a text, CSV or ZIP export.'**
  String get importErrorUnreadable;

  /// Writing the import failed; nothing was added.
  ///
  /// In en, this message translates to:
  /// **'The import failed. Nothing was added.'**
  String get importErrorWrite;

  /// Undoing the import failed.
  ///
  /// In en, this message translates to:
  /// **'Could not undo the import. Try again.'**
  String get importErrorUndo;

  /// Settings row and screen title for managing tags and people (ADR 0010).
  ///
  /// In en, this message translates to:
  /// **'Tags & people'**
  String get tagsAndPeopleLabel;

  /// Empty state of the Tags & people screen.
  ///
  /// In en, this message translates to:
  /// **'Tags label items across lists. Mark a tag as a person to keep an agenda of things to discuss with them. Tip: type +tag when capturing.'**
  String get tagsEmptyMessage;

  /// Button/sheet title: create a tag.
  ///
  /// In en, this message translates to:
  /// **'New tag'**
  String get newTag;

  /// Sheet title: edit a tag.
  ///
  /// In en, this message translates to:
  /// **'Edit tag'**
  String get editTag;

  /// Switch: this tag is a person.
  ///
  /// In en, this message translates to:
  /// **'Person'**
  String get tagPersonSwitch;

  /// Explains what marking a tag as a person does.
  ///
  /// In en, this message translates to:
  /// **'Keeps an agenda of things to discuss'**
  String get tagPersonSwitchHint;

  /// Number of open items carrying a tag.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No open items} =1{1 open item} other{{count} open items}}'**
  String tagOpenItems(int count);

  /// Confirm deleting a tag.
  ///
  /// In en, this message translates to:
  /// **'Delete “{name}”?'**
  String deleteTagConfirmTitle(String name);

  /// Deleting a tag keeps the items.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No open item uses it.} =1{1 open item uses it. It stays; only the tag is removed.} other{{count} open items use it. They stay; only the tag is removed.}}'**
  String deleteTagConfirmBody(int count);

  /// Dialog title when a rename collides with another tag.
  ///
  /// In en, this message translates to:
  /// **'Merge tags?'**
  String get tagMergeTitle;

  /// Rename collides: offer to merge source into the existing target.
  ///
  /// In en, this message translates to:
  /// **'“{target}” already exists. Merge “{source}” into it?'**
  String tagMergeBody(String source, String target);

  /// Button: merge tags.
  ///
  /// In en, this message translates to:
  /// **'Merge'**
  String get tagMergeAction;

  /// Chip/button: add a tag to an item.
  ///
  /// In en, this message translates to:
  /// **'Add tag'**
  String get addTag;

  /// Tag picker search field hint.
  ///
  /// In en, this message translates to:
  /// **'Search or create a tag'**
  String get tagPickerHint;

  /// Picker row: create a tag with the typed name.
  ///
  /// In en, this message translates to:
  /// **'Create “{name}”'**
  String tagCreate(String name);

  /// Picker row: create a person tag with the typed name.
  ///
  /// In en, this message translates to:
  /// **'Create person “{name}”'**
  String tagCreatePerson(String name);

  /// Section header: tags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tagsSection;

  /// Screen-reader label of a tag chip.
  ///
  /// In en, this message translates to:
  /// **'Tag: {name}'**
  String tagChipSemantics(String name);

  /// Screen-reader label of a person tag chip.
  ///
  /// In en, this message translates to:
  /// **'Person: {name}'**
  String personChipSemantics(String name);

  /// Tooltip: remove a tag from the item.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}'**
  String removeTagTooltip(String name);

  /// Screen-reader label of the +N chip on a card.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 more tag} other{{count} more tags}}'**
  String moreTags(int count);

  /// Do filter chip when no tag is selected.
  ///
  /// In en, this message translates to:
  /// **'Tag'**
  String get filterTag;

  /// Tag filter option: no tag constraint.
  ///
  /// In en, this message translates to:
  /// **'Any tag'**
  String get filterAnyTag;

  /// Review list: things to discuss per person (GTD Agendas).
  ///
  /// In en, this message translates to:
  /// **'Agendas'**
  String get agendasTitle;

  /// Agendas bucket subtitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 person} other{{count} people}}'**
  String agendasPeopleCount(int count);

  /// Agenda screen: add a talking point.
  ///
  /// In en, this message translates to:
  /// **'Add something to discuss with {name}'**
  String agendaAddHint(String name);

  /// Button: add to the agenda.
  ///
  /// In en, this message translates to:
  /// **'Add to agenda'**
  String get agendaAddTooltip;

  /// Agenda screen empty state.
  ///
  /// In en, this message translates to:
  /// **'Nothing to discuss with {name} yet.'**
  String agendaEmpty(String name);

  /// Agenda screen for a deleted person.
  ///
  /// In en, this message translates to:
  /// **'This person no longer exists.'**
  String get agendaNotFound;

  /// Capture chip: a +word that creates a new tag.
  ///
  /// In en, this message translates to:
  /// **'New tag: {name}'**
  String captureChipNewTag(String name);

  /// How to export Google Tasks, and the list/completion mapping.
  ///
  /// In en, this message translates to:
  /// **'Google Takeout › select Tasks › export JSON. Unzip the download and choose Tasks.json. Lists stay in notes; completed tasks go to Done.'**
  String get importHintGoogleTasks;

  /// Non-blocking warning for previously committed identical import input on this device.
  ///
  /// In en, this message translates to:
  /// **'This exact input was imported before on this device. Importing again will add duplicate tasks. Cancel unless you want another copy.'**
  String get importDuplicateWarning;

  /// No description provided for @importHintThings.
  ///
  /// In en, this message translates to:
  /// **'Choose main.sqlite or a ZIP of an exported Things 3 database folder. iPhone/iPad: Settings › General › Diagnostics › Enter Code › 491348 › Send Things Database. Save to Files, unpack .aar, then compress the database folder to ZIP. On Mac, quit Things before copying its database. Recreate repeats and reminders after importing.'**
  String get importHintThings;

  /// No description provided for @importWarnDetailsInNotes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 task keeps checklist or Area details in notes} other{{count} tasks keep checklist or Area details in notes}}'**
  String importWarnDetailsInNotes(int count);

  /// No description provided for @importWarnThingsRecurrence.
  ///
  /// In en, this message translates to:
  /// **'Things repeat schedules are not imported. Recurring templates are skipped; recreate repeats for imported tasks.'**
  String get importWarnThingsRecurrence;

  /// No description provided for @importWarnSourceReminders.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 source reminder setting is not imported} other{{count} source reminder settings are not imported}}'**
  String importWarnSourceReminders(int count);

  /// No description provided for @importAppleHint.
  ///
  /// In en, this message translates to:
  /// **'Choose reminder lists on this device. Only open reminders are imported.'**
  String get importAppleHint;

  /// No description provided for @importAppleChooseLists.
  ///
  /// In en, this message translates to:
  /// **'Choose lists'**
  String get importAppleChooseLists;

  /// No description provided for @importAppleReloadLists.
  ///
  /// In en, this message translates to:
  /// **'Reload lists'**
  String get importAppleReloadLists;

  /// No description provided for @importAppleNoLists.
  ///
  /// In en, this message translates to:
  /// **'No reminder lists are available on this device.'**
  String get importAppleNoLists;

  /// No description provided for @importAppleDenied.
  ///
  /// In en, this message translates to:
  /// **'Reminders access is off. Allow Trayzero to access Reminders in iOS Settings, then try again.'**
  String get importAppleDenied;

  /// No description provided for @importAppleUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Could not read Apple Reminders. Try again.'**
  String get importAppleUnavailable;

  /// No description provided for @importAppleListsChanged.
  ///
  /// In en, this message translates to:
  /// **'A selected list is no longer available. Reload lists and select again.'**
  String get importAppleListsChanged;

  /// No description provided for @importAppleLimits.
  ///
  /// In en, this message translates to:
  /// **'Your Apple reminders stay unchanged. Apple tags, flags, attachments and subtask structure are not copied. Priorities and original alerts are not copied. Importing again can add duplicate tasks.'**
  String get importAppleLimits;

  /// No description provided for @importHintMicrosoftTodo.
  ///
  /// In en, this message translates to:
  /// **'Sign in to copy your lists and open tasks. Review before importing; importing again can create duplicates.'**
  String get importHintMicrosoftTodo;

  /// No description provided for @importMicrosoftUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Microsoft To Do import is unavailable in this build.'**
  String get importMicrosoftUnavailable;

  /// No description provided for @importMicrosoftSignInError.
  ///
  /// In en, this message translates to:
  /// **'Microsoft sign-in failed or expired. Please sign in again.'**
  String get importMicrosoftSignInError;

  /// No description provided for @importMicrosoftPermissionError.
  ///
  /// In en, this message translates to:
  /// **'Microsoft did not allow access to your tasks. Check account permissions or contact your organization.'**
  String get importMicrosoftPermissionError;

  /// No description provided for @importMicrosoftNetworkError.
  ///
  /// In en, this message translates to:
  /// **'Could not read all Microsoft tasks. Nothing was imported. Check your connection and try again.'**
  String get importMicrosoftNetworkError;

  /// Tasks whose attachments, reminder settings or source statuses cannot be migrated.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 task has attachments, reminder settings or a status that are not imported} other{{count} tasks have attachments, reminder settings or statuses that are not imported}}'**
  String importWarnSourceDetails(int count);

  /// No description provided for @moreGroupOrganize.
  ///
  /// In en, this message translates to:
  /// **'Organize'**
  String get moreGroupOrganize;

  /// No description provided for @moreGroupPreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get moreGroupPreferences;

  /// No description provided for @moreGroupData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get moreGroupData;

  /// No description provided for @moreOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get moreOn;

  /// No description provided for @moreOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get moreOff;

  /// No description provided for @moreAppearanceSummary.
  ///
  /// In en, this message translates to:
  /// **'{theme} · {palette}'**
  String moreAppearanceSummary(String theme, String palette);

  /// No description provided for @moreRemindersBlockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders are blocked'**
  String get moreRemindersBlockedTitle;

  /// No description provided for @moreRemindersBlockedBody.
  ///
  /// In en, this message translates to:
  /// **'Notifications are off, so reminders can\'t alert you.'**
  String get moreRemindersBlockedBody;

  /// No description provided for @moreBackupFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup failed'**
  String get moreBackupFailedTitle;

  /// No description provided for @moreBackupFailedBody.
  ///
  /// In en, this message translates to:
  /// **'Automatic backup couldn\'t save. Check the folder and free space.'**
  String get moreBackupFailedBody;

  /// No description provided for @moreFix.
  ///
  /// In en, this message translates to:
  /// **'Fix'**
  String get moreFix;

  /// No description provided for @moreBackupRestore.
  ///
  /// In en, this message translates to:
  /// **'Backup & restore'**
  String get moreBackupRestore;

  /// No description provided for @moreBackupSubtitleOff.
  ///
  /// In en, this message translates to:
  /// **'Automatic backup is off'**
  String get moreBackupSubtitleOff;

  /// No description provided for @moreBackupSubtitleFailed.
  ///
  /// In en, this message translates to:
  /// **'Backup failed'**
  String get moreBackupSubtitleFailed;

  /// No description provided for @moreImportSources.
  ///
  /// In en, this message translates to:
  /// **'Todoist, TickTick, OmniFocus and more'**
  String get moreImportSources;

  /// No description provided for @moreSupportTrailing.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get moreSupportTrailing;

  /// No description provided for @moreSupportTrailingSupporter.
  ///
  /// In en, this message translates to:
  /// **'Supporter'**
  String get moreSupportTrailingSupporter;

  /// No description provided for @moreAboutPrivacy.
  ///
  /// In en, this message translates to:
  /// **'About & privacy'**
  String get moreAboutPrivacy;

  /// No description provided for @moreHowGtdWorks.
  ///
  /// In en, this message translates to:
  /// **'How GTD works'**
  String get moreHowGtdWorks;

  /// No description provided for @moreNudgesGroup.
  ///
  /// In en, this message translates to:
  /// **'Nudges'**
  String get moreNudgesGroup;

  /// No description provided for @moreTimingGroup.
  ///
  /// In en, this message translates to:
  /// **'Timing'**
  String get moreTimingGroup;

  /// No description provided for @moreLeadOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get moreLeadOff;

  /// No description provided for @moreLead10.
  ///
  /// In en, this message translates to:
  /// **'10 minutes before'**
  String get moreLead10;

  /// No description provided for @moreLead30.
  ///
  /// In en, this message translates to:
  /// **'30 minutes before'**
  String get moreLead30;

  /// No description provided for @moreLead60.
  ///
  /// In en, this message translates to:
  /// **'1 hour before'**
  String get moreLead60;

  /// No description provided for @moreLead1440.
  ///
  /// In en, this message translates to:
  /// **'1 day before'**
  String get moreLead1440;

  /// No description provided for @moreLeadOther.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes before'**
  String moreLeadOther(int minutes);

  /// No description provided for @moreRestoredEntries.
  ///
  /// In en, this message translates to:
  /// **'Restored {count, plural, =1{1 entry} other{{count} entries}}.'**
  String moreRestoredEntries(int count);

  /// No description provided for @moreBackupEmpty.
  ///
  /// In en, this message translates to:
  /// **'This backup has no entries to restore.'**
  String get moreBackupEmpty;

  /// No description provided for @moreCouldntOpenLink.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open link'**
  String get moreCouldntOpenLink;

  /// No description provided for @moreVersionBuild.
  ///
  /// In en, this message translates to:
  /// **'{version} (build {build})'**
  String moreVersionBuild(String version, String build);

  /// No description provided for @supportBestValue.
  ///
  /// In en, this message translates to:
  /// **'Best value'**
  String get supportBestValue;

  /// Intro above the list of import sources.
  ///
  /// In en, this message translates to:
  /// **'Pick where your tasks live now. You will see a preview before anything is added.'**
  String get importListIntro;

  /// Group label: sources read directly.
  ///
  /// In en, this message translates to:
  /// **'Connect directly'**
  String get importGroupDirect;

  /// Group label: sources imported from an export file.
  ///
  /// In en, this message translates to:
  /// **'From an export file'**
  String get importGroupFile;

  /// Group label: other sources such as plain text.
  ///
  /// In en, this message translates to:
  /// **'Anything else'**
  String get importGroupOther;

  /// Subtitle of the Google Tasks source row.
  ///
  /// In en, this message translates to:
  /// **'Takeout · Tasks.json'**
  String get importSubGoogleTasks;

  /// Subtitle of the Todoist source row.
  ///
  /// In en, this message translates to:
  /// **'CSV template or backup ZIP'**
  String get importSubTodoist;

  /// Subtitle of the Things 3 source row.
  ///
  /// In en, this message translates to:
  /// **'Database ZIP or main.sqlite'**
  String get importSubThings;

  /// Subtitle of the TickTick source row.
  ///
  /// In en, this message translates to:
  /// **'Backup CSV'**
  String get importSubTickTick;

  /// Subtitle of the Nirvana source row.
  ///
  /// In en, this message translates to:
  /// **'CSV or JSON export'**
  String get importSubNirvana;

  /// Subtitle of the OmniFocus source row.
  ///
  /// In en, this message translates to:
  /// **'TaskPaper file or paste'**
  String get importSubOmniFocus;

  /// Subtitle of the plain text source row.
  ///
  /// In en, this message translates to:
  /// **'Paste a list, one task per line'**
  String get importSubPlainText;

  /// Subtitle of the Apple Reminders source row.
  ///
  /// In en, this message translates to:
  /// **'Pick lists on this device'**
  String get importSubApple;

  /// Subtitle of the Microsoft To Do source row.
  ///
  /// In en, this message translates to:
  /// **'Lists and open tasks'**
  String get importSubMicrosoft;

  /// Chip on a source that is read on this device.
  ///
  /// In en, this message translates to:
  /// **'On device'**
  String get importChipOnDevice;

  /// Chip on a source that needs a sign-in.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get importChipSignIn;

  /// Footer text before the Backup & restore link.
  ///
  /// In en, this message translates to:
  /// **'Restoring a Trayzero backup?'**
  String get importBackupFooter;

  /// Link to the Backup & restore screen.
  ///
  /// In en, this message translates to:
  /// **'Backup & restore'**
  String get importBackupFooterLink;

  /// Things device toggle: iPhone or iPad.
  ///
  /// In en, this message translates to:
  /// **'iPhone / iPad'**
  String get importThingsDeviceIos;

  /// Things device toggle: Mac.
  ///
  /// In en, this message translates to:
  /// **'Mac'**
  String get importThingsDeviceMac;

  /// Tooltip of the copyable code chip.
  ///
  /// In en, this message translates to:
  /// **'Copy code'**
  String get importCopyCode;

  /// Snackbar after copying a code.
  ///
  /// In en, this message translates to:
  /// **'Code copied'**
  String get importCodeCopied;

  /// Primary button: connect to a sign-in source.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get importConnect;

  /// Google Tasks step 1.
  ///
  /// In en, this message translates to:
  /// **'Open Google Takeout and select only Tasks.'**
  String get importStepGoogleTasks1;

  /// Google Tasks step 2.
  ///
  /// In en, this message translates to:
  /// **'Export it as JSON and unzip the download.'**
  String get importStepGoogleTasks2;

  /// Google Tasks step 3.
  ///
  /// In en, this message translates to:
  /// **'Choose Tasks.json below.'**
  String get importStepGoogleTasks3;

  /// Google Tasks good-to-know note.
  ///
  /// In en, this message translates to:
  /// **'Lists stay in notes; completed tasks go to Done.'**
  String get importNoteGoogleTasks;

  /// Todoist step 1.
  ///
  /// In en, this message translates to:
  /// **'Open a project menu and choose Export as a template (CSV).'**
  String get importStepTodoist1;

  /// Todoist step 2.
  ///
  /// In en, this message translates to:
  /// **'Or save a backup ZIP from Settings › Backups.'**
  String get importStepTodoist2;

  /// Todoist step 3.
  ///
  /// In en, this message translates to:
  /// **'Choose the file below.'**
  String get importStepTodoist3;

  /// TickTick step 1.
  ///
  /// In en, this message translates to:
  /// **'On the TickTick website, open Settings › Account.'**
  String get importStepTickTick1;

  /// TickTick step 2.
  ///
  /// In en, this message translates to:
  /// **'Open Backup & Import and tap Generate Backup (CSV).'**
  String get importStepTickTick2;

  /// TickTick step 3.
  ///
  /// In en, this message translates to:
  /// **'Choose the CSV below.'**
  String get importStepTickTick3;

  /// Nirvana step 1.
  ///
  /// In en, this message translates to:
  /// **'In the Nirvana web app, export your data as CSV or JSON.'**
  String get importStepNirvana1;

  /// Nirvana step 2.
  ///
  /// In en, this message translates to:
  /// **'Choose the file below.'**
  String get importStepNirvana2;

  /// OmniFocus step 1.
  ///
  /// In en, this message translates to:
  /// **'In OmniFocus, select your projects.'**
  String get importStepOmniFocus1;

  /// OmniFocus step 2.
  ///
  /// In en, this message translates to:
  /// **'Choose Edit › Copy as TaskPaper.'**
  String get importStepOmniFocus2;

  /// OmniFocus step 3.
  ///
  /// In en, this message translates to:
  /// **'Paste the text below, or save it as a file and choose it.'**
  String get importStepOmniFocus3;

  /// Plain text step 1.
  ///
  /// In en, this message translates to:
  /// **'Copy your tasks from any app, one task per line.'**
  String get importStepPlainText1;

  /// Plain text step 2.
  ///
  /// In en, this message translates to:
  /// **'Tap Paste text below and paste them.'**
  String get importStepPlainText2;

  /// Plain text good-to-know note.
  ///
  /// In en, this message translates to:
  /// **'Basic text import only. Database exports from other apps are not supported.'**
  String get importNotePlainText;

  /// Apple Reminders step 1.
  ///
  /// In en, this message translates to:
  /// **'Tap Choose lists below.'**
  String get importStepApple1;

  /// Apple Reminders step 2.
  ///
  /// In en, this message translates to:
  /// **'Allow access to Reminders when asked.'**
  String get importStepApple2;

  /// Apple Reminders step 3.
  ///
  /// In en, this message translates to:
  /// **'Tick the lists you want to import.'**
  String get importStepApple3;

  /// Apple Reminders good-to-know note.
  ///
  /// In en, this message translates to:
  /// **'Only open reminders are imported. Your Apple reminders stay unchanged.'**
  String get importNoteApple;

  /// Microsoft To Do step 1.
  ///
  /// In en, this message translates to:
  /// **'Tap Connect and sign in to Microsoft.'**
  String get importStepMicrosoft1;

  /// Microsoft To Do step 2.
  ///
  /// In en, this message translates to:
  /// **'Trayzero copies your lists and open tasks.'**
  String get importStepMicrosoft2;

  /// Microsoft To Do step 3.
  ///
  /// In en, this message translates to:
  /// **'Review the preview before importing.'**
  String get importStepMicrosoft3;

  /// Microsoft To Do good-to-know note.
  ///
  /// In en, this message translates to:
  /// **'Importing again can create duplicates.'**
  String get importNoteMicrosoft;

  /// Things on iPhone/iPad step 1; code chip follows.
  ///
  /// In en, this message translates to:
  /// **'Open Settings › General › Diagnostics › Enter Code in Things, then enter:'**
  String get importStepThingsIos1;

  /// Things on iPhone/iPad step 2.
  ///
  /// In en, this message translates to:
  /// **'Tap Send Things Database and save it to Files.'**
  String get importStepThingsIos2;

  /// Things on iPhone/iPad step 3.
  ///
  /// In en, this message translates to:
  /// **'In Files, unpack the .aar, then compress the database folder to ZIP.'**
  String get importStepThingsIos3;

  /// Things on iPhone/iPad step 4.
  ///
  /// In en, this message translates to:
  /// **'Choose that ZIP below.'**
  String get importStepThingsIos4;

  /// Things on Mac step 1.
  ///
  /// In en, this message translates to:
  /// **'Quit Things on your Mac.'**
  String get importStepThingsMac1;

  /// Things on Mac step 2.
  ///
  /// In en, this message translates to:
  /// **'Copy Things Database.thingsdatabase from the Things folder, then compress the copy to ZIP.'**
  String get importStepThingsMac2;

  /// Things on Mac step 3.
  ///
  /// In en, this message translates to:
  /// **'Move the ZIP (or its main.sqlite) to this device and choose it below.'**
  String get importStepThingsMac3;

  /// Things good-to-know note.
  ///
  /// In en, this message translates to:
  /// **'Repeats and reminders don\'t carry over. Recreate them after importing.'**
  String get importNoteThings;

  /// App bar title of the import preview.
  ///
  /// In en, this message translates to:
  /// **'Review import'**
  String get importReviewTitle;

  /// Preview header: which app the import comes from.
  ///
  /// In en, this message translates to:
  /// **'From {source}'**
  String importFromSource(String source);

  /// Preview header: total tasks to import.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 task} other{{count} tasks}}'**
  String importTotalTasks(int count);

  /// Confirm button that writes the import, with the task count.
  ///
  /// In en, this message translates to:
  /// **'Import {count, plural, =1{1 task} other{{count} tasks}}'**
  String importActionCount(int count);

  /// Collapsed card summary: how many items are new vs already the user's.
  ///
  /// In en, this message translates to:
  /// **'{newCount} new · {existingCount} existing'**
  String importNewExistingSummary(int newCount, int existingCount);

  /// Button expanding a truncated list to all items.
  ///
  /// In en, this message translates to:
  /// **'Show all {count}'**
  String importShowAll(int count);

  /// Preview card title combining contexts and tags.
  ///
  /// In en, this message translates to:
  /// **'Contexts & tags'**
  String get importContextsAndTags;

  /// Collapsed Good to know summary: number of notes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 note} other{{count} notes}}'**
  String importNotesCount(int count);

  /// No description provided for @notificationStatusOnTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders on'**
  String get notificationStatusOnTitle;

  /// No description provided for @notificationStatusOnBody.
  ///
  /// In en, this message translates to:
  /// **'Reminders will alert you on this device.'**
  String get notificationStatusOnBody;

  /// No description provided for @notificationStatusOffTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders off'**
  String get notificationStatusOffTitle;

  /// No description provided for @notificationStatusOffBody.
  ///
  /// In en, this message translates to:
  /// **'Reminders are scheduled but won’t alert you until you allow notifications.'**
  String get notificationStatusOffBody;

  /// No description provided for @notificationStatusBlockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders blocked'**
  String get notificationStatusBlockedTitle;

  /// No description provided for @notificationStatusBlockedBody.
  ///
  /// In en, this message translates to:
  /// **'Notifications are turned off for Trayzero in system settings. Reminders won’t alert you until you turn them back on there.'**
  String get notificationStatusBlockedBody;

  /// No description provided for @notificationActionEnable.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications'**
  String get notificationActionEnable;

  /// No description provided for @notificationActionOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get notificationActionOpenSettings;

  /// No description provided for @notificationPrimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Turn on reminders?'**
  String get notificationPrimerTitle;

  /// No description provided for @notificationPrimerBody.
  ///
  /// In en, this message translates to:
  /// **'Trayzero reminds you about due dates and your weekly review by posting a notification on this device. Nothing is sent to a server — reminders are scheduled locally.\n\nYour device will now ask for permission to show notifications.'**
  String get notificationPrimerBody;

  /// No description provided for @notificationPrimerNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notificationPrimerNotNow;

  /// No description provided for @notificationPrimerContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get notificationPrimerContinue;

  /// No description provided for @notificationPromptFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t open the notification prompt.'**
  String get notificationPromptFailed;

  /// No description provided for @notificationAlreadyOn.
  ///
  /// In en, this message translates to:
  /// **'Reminders are already on.'**
  String get notificationAlreadyOn;

  /// No description provided for @notificationOpenedSettings.
  ///
  /// In en, this message translates to:
  /// **'Opened system settings — turn on Notifications for Trayzero.'**
  String get notificationOpenedSettings;

  /// No description provided for @notificationStayOff.
  ///
  /// In en, this message translates to:
  /// **'Reminders stay off. You can enable them anytime in More → Reminders.'**
  String get notificationStayOff;

  /// No description provided for @notificationNowOn.
  ///
  /// In en, this message translates to:
  /// **'Reminders are on.'**
  String get notificationNowOn;

  /// No description provided for @notificationBlocked.
  ///
  /// In en, this message translates to:
  /// **'Notifications are blocked for Trayzero.'**
  String get notificationBlocked;

  /// No description provided for @exactAlarmSettingsFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t open exact alarm settings.'**
  String get exactAlarmSettingsFailed;

  /// No description provided for @exactAlarmAlreadyOn.
  ///
  /// In en, this message translates to:
  /// **'Precise reminder timing is already on.'**
  String get exactAlarmAlreadyOn;

  /// No description provided for @exactAlarmNowOn.
  ///
  /// In en, this message translates to:
  /// **'Precise reminder timing is on.'**
  String get exactAlarmNowOn;

  /// No description provided for @exactAlarmStaysOff.
  ///
  /// In en, this message translates to:
  /// **'Precise reminder timing stays off. Short reminders may be delayed.'**
  String get exactAlarmStaysOff;

  /// Snackbar after removing an attachment, with Undo.
  ///
  /// In en, this message translates to:
  /// **'Attachment removed.'**
  String get attachmentRemoved;

  /// Dialog title when closing the capture sheet with unsaved text.
  ///
  /// In en, this message translates to:
  /// **'Discard this capture?'**
  String get discardCaptureTitle;

  /// Dialog body for discarding unsaved capture text.
  ///
  /// In en, this message translates to:
  /// **'What you typed will be lost.'**
  String get discardCaptureBody;

  /// Dialog button: go back to the capture sheet.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get keepEditing;

  /// Dialog button: throw away unsaved text.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// Snackbar after Process inbox files an item, with Undo.
  ///
  /// In en, this message translates to:
  /// **'Filed.'**
  String get processFiledSnackbar;

  /// Shared error state title when a list or screen fails to load.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load this'**
  String get errorLoadTitle;

  /// Shared error state body; reassures the user and suggests retrying.
  ///
  /// In en, this message translates to:
  /// **'Your data is safe. Try again.'**
  String get errorLoadBody;

  /// Snackbar after text shared into the app was added to the Inbox.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Added 1 item to Inbox} other{Added {count} items to Inbox}}'**
  String sharedAddedToInbox(int count);

  /// Title of the project filter bottom sheet in Search.
  ///
  /// In en, this message translates to:
  /// **'Filter by project'**
  String get filterByProject;

  /// Project status: active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get projectStatusActive;

  /// Project status: on hold.
  ///
  /// In en, this message translates to:
  /// **'On hold'**
  String get projectStatusOnHold;

  /// Project status: someday/maybe.
  ///
  /// In en, this message translates to:
  /// **'Someday'**
  String get projectStatusSomeday;

  /// Project status: done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get projectStatusDone;

  /// Project status: dropped.
  ///
  /// In en, this message translates to:
  /// **'Dropped'**
  String get projectStatusDropped;

  /// Project overflow menu item and dialog title for changing the project status.
  ///
  /// In en, this message translates to:
  /// **'Change status'**
  String get projectChangeStatus;

  /// Tooltip on a project that is moving only through waiting/scheduled items.
  ///
  /// In en, this message translates to:
  /// **'Awaiting — in motion via waiting or scheduled items'**
  String get projectAwaitingTooltip;

  /// Tooltip on a project with no next action, waiting, or scheduled item.
  ///
  /// In en, this message translates to:
  /// **'Stalled — no next action, waiting, or scheduled item'**
  String get projectStalledTooltip;

  /// Banner on a stalled project detail screen.
  ///
  /// In en, this message translates to:
  /// **'Stalled — no next action, waiting, or scheduled item defined. Add a next action to get this moving.'**
  String get projectStalledBanner;

  /// Banner on a project detail screen that moves only through waiting/scheduled items.
  ///
  /// In en, this message translates to:
  /// **'This project is moving through waiting or scheduled items only. Consider adding a follow-up next action so it doesn\'t stall when those clear.'**
  String get projectAwaitingBanner;

  /// Project tile chip: number of next actions.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 next action} other{{count} next actions}}'**
  String projectNextActionCount(int count);

  /// Project tile chip: number of waiting-for items.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 waiting} other{{count} waiting}}'**
  String projectWaitingCount(int count);

  /// Do tab: shown when filters hide every next action.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 next action is hidden by your filters} other{{count} next actions are hidden by your filters}}'**
  String engageHiddenByFilters(int count);

  /// Do tab: chip that clears all active filters.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get filterReset;

  /// Onboarding replay: shown under the sample-project switch when the user already has projects.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{You already have 1 project.} other{You already have {count} projects.}}'**
  String onboardingSeedExisting(int count);

  /// Purchase error: billing not configured/available.
  ///
  /// In en, this message translates to:
  /// **'Purchases are not available right now.'**
  String get purchaseErrUnavailable;

  /// Purchase error: products could not be loaded.
  ///
  /// In en, this message translates to:
  /// **'Could not load products. Check your connection and try again.'**
  String get purchaseErrProducts;

  /// Purchase error: the chosen product is unavailable.
  ///
  /// In en, this message translates to:
  /// **'That option is not available right now.'**
  String get purchaseErrOption;

  /// Purchase error: network problem.
  ///
  /// In en, this message translates to:
  /// **'Network error. Check your connection and try again.'**
  String get purchaseErrNetwork;

  /// Purchase error: purchases disabled on the device.
  ///
  /// In en, this message translates to:
  /// **'Purchases are not allowed on this device.'**
  String get purchaseErrNotAllowed;

  /// Purchase error: payment pending approval.
  ///
  /// In en, this message translates to:
  /// **'Your purchase is pending approval.'**
  String get purchaseErrPending;

  /// Purchase error: product already owned.
  ///
  /// In en, this message translates to:
  /// **'You already own this — try Restore Purchases.'**
  String get purchaseErrAlreadyOwned;

  /// Purchase error: store service problem.
  ///
  /// In en, this message translates to:
  /// **'The store is having trouble. Please try again later.'**
  String get purchaseErrStore;

  /// Purchase error: generic.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong with the purchase. Please try again.'**
  String get purchaseErrUnknown;

  /// Backup import error: empty input.
  ///
  /// In en, this message translates to:
  /// **'The backup is empty — nothing to import.'**
  String get backupErrEmpty;

  /// Backup import error: not valid JSON.
  ///
  /// In en, this message translates to:
  /// **'This isn\'t valid JSON. Make sure you selected a complete, unedited Trayzero backup file.'**
  String get backupErrInvalidJson;

  /// Backup import error: JSON is not a backup object.
  ///
  /// In en, this message translates to:
  /// **'This file is not a Trayzero backup.'**
  String get backupErrNotBackup;

  /// Backup import error: backup made by a newer app version.
  ///
  /// In en, this message translates to:
  /// **'This backup was created by a newer version of the app. Update Trayzero, then try importing again.'**
  String get backupErrNewerVersion;

  /// Backup import error: file has none of the backup sections.
  ///
  /// In en, this message translates to:
  /// **'This file doesn\'t look like a Trayzero backup.'**
  String get backupErrUnrecognized;

  /// Backup import error: backup contains invalid data (technical detail is logged, not shown).
  ///
  /// In en, this message translates to:
  /// **'This backup contains invalid data and can\'t be imported.'**
  String get backupErrInvalidData;

  /// Backup restore: data restored but reminders could not be refreshed.
  ///
  /// In en, this message translates to:
  /// **'Your data was restored, but some reminders could not be refreshed. Retry the import to refresh them.'**
  String get backupErrReminders;

  /// Backup restore: generic failure (technical detail is logged, not shown).
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while restoring. Your existing data was not changed by this attempt.'**
  String get backupErrRestoreFailed;

  /// Backup preview: number of items.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}}'**
  String backupCountItems(int count);

  /// Backup preview: number of projects.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 project} other{{count} projects}}'**
  String backupCountProjects(int count);

  /// Backup preview: number of contexts.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 context} other{{count} contexts}}'**
  String backupCountContexts(int count);

  /// Backup preview: number of areas.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 area} other{{count} areas}}'**
  String backupCountAreas(int count);

  /// Backup preview: number of attachments.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 attachment} other{{count} attachments}}'**
  String backupCountAttachments(int count);

  /// Backup preview: number of reviews.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 review} other{{count} reviews}}'**
  String backupCountReviews(int count);

  /// No description provided for @restoreFolderTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore from backup folder'**
  String get restoreFolderTitle;

  /// No description provided for @restoreFolderIntro.
  ///
  /// In en, this message translates to:
  /// **'Choose the folder where Trayzero saves backups, for example one kept by iCloud Drive, Google Drive or Syncthing. Restoring merges the backup into this device; it doesn\'t delete anything already here.'**
  String get restoreFolderIntro;

  /// No description provided for @restoreFolderChoose.
  ///
  /// In en, this message translates to:
  /// **'Choose backup folder'**
  String get restoreFolderChoose;

  /// No description provided for @restoreFolderChange.
  ///
  /// In en, this message translates to:
  /// **'Choose a different folder'**
  String get restoreFolderChange;

  /// No description provided for @restoreFolderFrom.
  ///
  /// In en, this message translates to:
  /// **'Folder: {name}'**
  String restoreFolderFrom(String name);

  /// No description provided for @restoreFolderEmpty.
  ///
  /// In en, this message translates to:
  /// **'No Trayzero backups found in this folder.'**
  String get restoreFolderEmpty;

  /// No description provided for @restoreFolderFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open this folder. Check that it\'s still available, or choose it again.'**
  String get restoreFolderFailed;

  /// No description provided for @restoreFolderItemCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}}'**
  String restoreFolderItemCount(int count);

  /// No description provided for @restoreFolderUnreadable.
  ///
  /// In en, this message translates to:
  /// **'Can\'t read this file'**
  String get restoreFolderUnreadable;

  /// No description provided for @restoreFolderReading.
  ///
  /// In en, this message translates to:
  /// **'Reading…'**
  String get restoreFolderReading;

  /// No description provided for @onboardingRestoreAction.
  ///
  /// In en, this message translates to:
  /// **'Coming from another device? Restore a backup'**
  String get onboardingRestoreAction;

  /// No description provided for @folderBackupStale.
  ///
  /// In en, this message translates to:
  /// **'No fresh backup for {days, plural, =1{1 day} other{{days} days}}.'**
  String folderBackupStale(int days);

  /// No description provided for @folderBackupRepairHint.
  ///
  /// In en, this message translates to:
  /// **'Choose the folder again if backups have stopped working.'**
  String get folderBackupRepairHint;

  /// No description provided for @moreBackupSubtitleStale.
  ///
  /// In en, this message translates to:
  /// **'No fresh backup for {days, plural, =1{1 day} other{{days} days}} · tap to repair'**
  String moreBackupSubtitleStale(int days);

  /// No description provided for @backupPromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Back up your tasks automatically'**
  String get backupPromptTitle;

  /// No description provided for @backupPromptBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ve captured a lot. Pick a folder in your own cloud or sync app and Trayzero will keep the latest 10 backups there. It\'s backup, not sync.'**
  String get backupPromptBody;

  /// No description provided for @backupPromptAction.
  ///
  /// In en, this message translates to:
  /// **'Choose folder'**
  String get backupPromptAction;

  /// No description provided for @backupPromptDismiss.
  ///
  /// In en, this message translates to:
  /// **'No thanks'**
  String get backupPromptDismiss;

  /// No description provided for @backupCardHealthy.
  ///
  /// In en, this message translates to:
  /// **'Backed up {date}'**
  String backupCardHealthy(String date);

  /// No description provided for @backupCardOffBody.
  ///
  /// In en, this message translates to:
  /// **'Turn on to save a copy to a folder after every change.'**
  String get backupCardOffBody;

  /// No description provided for @backupCardTurnOn.
  ///
  /// In en, this message translates to:
  /// **'Turn on'**
  String get backupCardTurnOn;

  /// No description provided for @backupCardChooseAgain.
  ///
  /// In en, this message translates to:
  /// **'Choose folder again'**
  String get backupCardChooseAgain;

  /// No description provided for @backupCardTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get backupCardTryAgain;

  /// No description provided for @backupGroupBackUp.
  ///
  /// In en, this message translates to:
  /// **'Back up'**
  String get backupGroupBackUp;

  /// No description provided for @backupGroupRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get backupGroupRestore;

  /// No description provided for @backupAutoTitle.
  ///
  /// In en, this message translates to:
  /// **'Back up automatically'**
  String get backupAutoTitle;

  /// No description provided for @backupAutoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'After each change'**
  String get backupAutoSubtitle;

  /// No description provided for @backupFolderTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup folder'**
  String get backupFolderTitle;

  /// No description provided for @backupExportTitle.
  ///
  /// In en, this message translates to:
  /// **'Export a copy'**
  String get backupExportTitle;

  /// No description provided for @backupExportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share a backup file once'**
  String get backupExportSubtitle;

  /// No description provided for @backupRestoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore a backup'**
  String get backupRestoreTitle;

  /// No description provided for @backupRestoreRowSubtitle.
  ///
  /// In en, this message translates to:
  /// **'From your folder or a file'**
  String get backupRestoreRowSubtitle;

  /// No description provided for @backupRestoreSheetBody.
  ///
  /// In en, this message translates to:
  /// **'Choose where your backup is. You\'ll see what\'s inside before anything changes.'**
  String get backupRestoreSheetBody;

  /// No description provided for @backupRestoreFromFolder.
  ///
  /// In en, this message translates to:
  /// **'From backup folder'**
  String get backupRestoreFromFolder;

  /// No description provided for @backupRestoreFromFolderHint.
  ///
  /// In en, this message translates to:
  /// **'Recommended — pick a saved backup'**
  String get backupRestoreFromFolderHint;

  /// No description provided for @backupRestoreFromFile.
  ///
  /// In en, this message translates to:
  /// **'From a file'**
  String get backupRestoreFromFile;

  /// No description provided for @backupRestoreFromFileHint.
  ///
  /// In en, this message translates to:
  /// **'A Trayzero backup (.json)'**
  String get backupRestoreFromFileHint;

  /// No description provided for @backupRestorePaste.
  ///
  /// In en, this message translates to:
  /// **'Paste backup text'**
  String get backupRestorePaste;

  /// No description provided for @backupFootnote.
  ///
  /// In en, this message translates to:
  /// **'Backup, not sync — your cloud or sync app carries the folder between devices.'**
  String get backupFootnote;

  /// No description provided for @backupCardJustNow.
  ///
  /// In en, this message translates to:
  /// **'Backed up just now'**
  String get backupCardJustNow;

  /// No description provided for @backupCardMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'Backed up {minutes, plural, =1{1 minute} other{{minutes} minutes}} ago'**
  String backupCardMinutesAgo(int minutes);

  /// No description provided for @backupCardHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'Backed up {hours, plural, =1{1 hour} other{{hours} hours}} ago'**
  String backupCardHoursAgo(int hours);

  /// No description provided for @backupCardYesterday.
  ///
  /// In en, this message translates to:
  /// **'Backed up yesterday'**
  String get backupCardYesterday;

  /// No description provided for @backupHowItWorks.
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get backupHowItWorks;

  /// No description provided for @backupHowTitle.
  ///
  /// In en, this message translates to:
  /// **'How backup works'**
  String get backupHowTitle;

  /// No description provided for @backupHowSaves.
  ///
  /// In en, this message translates to:
  /// **'After you make changes, Trayzero saves a JSON copy of your data to the folder you choose, and keeps the latest 10 copies.'**
  String get backupHowSaves;

  /// No description provided for @backupHowSync.
  ///
  /// In en, this message translates to:
  /// **'Your cloud or sync app (for example iCloud Drive, Google Drive or Syncthing) carries that folder to your other devices. Trayzero itself never uploads or syncs anything.'**
  String get backupHowSync;

  /// No description provided for @backupHowMove.
  ///
  /// In en, this message translates to:
  /// **'To move to another device, choose Restore a backup, then From backup folder.'**
  String get backupHowMove;

  /// No description provided for @microphoneAccessDenied.
  ///
  /// In en, this message translates to:
  /// **'Microphone access is off. Allow it in Settings to record a voice memo.'**
  String get microphoneAccessDenied;

  /// No description provided for @filterTimeEnergy.
  ///
  /// In en, this message translates to:
  /// **'Time & energy'**
  String get filterTimeEnergy;

  /// No description provided for @clearDate.
  ///
  /// In en, this message translates to:
  /// **'Clear date'**
  String get clearDate;

  /// No description provided for @reorderHandle.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder'**
  String get reorderHandle;

  /// No description provided for @calendarConnectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Calendar connection'**
  String get calendarConnectionTitle;

  /// No description provided for @calendarTogether.
  ///
  /// In en, this message translates to:
  /// **'Your plans, together.'**
  String get calendarTogether;

  /// No description provided for @calendarConnectionIntro.
  ///
  /// In en, this message translates to:
  /// **'See your Trayzero commitments alongside the rest of your day.'**
  String get calendarConnectionIntro;

  /// No description provided for @calendarConnect.
  ///
  /// In en, this message translates to:
  /// **'Connect calendar'**
  String get calendarConnect;

  /// No description provided for @calendarScope.
  ///
  /// In en, this message translates to:
  /// **'Only scheduled items in Trayzero’s Calendar are published. Ordinary task deadlines stay in Trayzero.'**
  String get calendarScope;

  /// No description provided for @calendarAutomatic.
  ///
  /// In en, this message translates to:
  /// **'Automatic updates'**
  String get calendarAutomatic;

  /// No description provided for @calendarAutomaticHelp.
  ///
  /// In en, this message translates to:
  /// **'Updates while you use Trayzero and when you reopen it.'**
  String get calendarAutomaticHelp;

  /// No description provided for @calendarPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get calendarPaused;

  /// No description provided for @calendarConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get calendarConnected;

  /// No description provided for @calendarNeedsAttention.
  ///
  /// In en, this message translates to:
  /// **'Needs attention'**
  String get calendarNeedsAttention;

  /// No description provided for @calendarPauseHelp.
  ///
  /// In en, this message translates to:
  /// **'Existing calendar events stay in place. Changes will wait until you resume updates or choose Update now.'**
  String get calendarPauseHelp;

  /// No description provided for @calendarLinkedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} linked events'**
  String calendarLinkedCount(int count);

  /// No description provided for @calendarLastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: {when}'**
  String calendarLastUpdated(String when);

  /// No description provided for @calendarChangesWaiting.
  ///
  /// In en, this message translates to:
  /// **'Changes waiting to update'**
  String get calendarChangesWaiting;

  /// No description provided for @calendarUpdateNow.
  ///
  /// In en, this message translates to:
  /// **'Update now'**
  String get calendarUpdateNow;

  /// No description provided for @calendarManage.
  ///
  /// In en, this message translates to:
  /// **'Manage connection'**
  String get calendarManage;

  /// No description provided for @calendarWorking.
  ///
  /// In en, this message translates to:
  /// **'Updating calendar connection…'**
  String get calendarWorking;

  /// No description provided for @calendarRestoreAccess.
  ///
  /// In en, this message translates to:
  /// **'Restore access'**
  String get calendarRestoreAccess;

  /// No description provided for @calendarUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Some changes could not be applied. Your last successful update is shown above. Try again to finish updating.'**
  String get calendarUpdateFailed;

  /// No description provided for @calendarRemovalPending.
  ///
  /// In en, this message translates to:
  /// **'Removal pending'**
  String get calendarRemovalPending;

  /// No description provided for @calendarRemoveFailed.
  ///
  /// In en, this message translates to:
  /// **'{count} events could not be removed. Automatic updates are stopped. Retry removal, or disconnect and keep the remaining events.'**
  String calendarRemoveFailed(int count);

  /// No description provided for @calendarSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save this change. Check the connection settings and try again.'**
  String get calendarSaveFailed;

  /// No description provided for @calendarNoWritable.
  ///
  /// In en, this message translates to:
  /// **'No writable calendars are available. Add a calendar in your device’s calendar settings, then try again.'**
  String get calendarNoWritable;

  /// No description provided for @calendarChangeDestination.
  ///
  /// In en, this message translates to:
  /// **'Change destination'**
  String get calendarChangeDestination;

  /// No description provided for @calendarChooseDestination.
  ///
  /// In en, this message translates to:
  /// **'Choose your calendar'**
  String get calendarChooseDestination;

  /// No description provided for @calendarMoveHelp.
  ///
  /// In en, this message translates to:
  /// **'Linked events will move to the new calendar. Other calendar events stay where they are. Automatic updates keep your current setting.'**
  String get calendarMoveHelp;

  /// No description provided for @calendarSetupCount.
  ///
  /// In en, this message translates to:
  /// **'{count} scheduled items will be published. Previously linked events are reused where available.'**
  String calendarSetupCount(int count);

  /// No description provided for @calendarMoveEvents.
  ///
  /// In en, this message translates to:
  /// **'Move linked events'**
  String get calendarMoveEvents;

  /// No description provided for @calendarConnectAndAdd.
  ///
  /// In en, this message translates to:
  /// **'Connect and add events'**
  String get calendarConnectAndAdd;

  /// No description provided for @calendarDisconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect calendar'**
  String get calendarDisconnect;

  /// No description provided for @calendarDisconnectQuestion.
  ///
  /// In en, this message translates to:
  /// **'Disconnect calendar?'**
  String get calendarDisconnectQuestion;

  /// No description provided for @calendarDisconnectHelp.
  ///
  /// In en, this message translates to:
  /// **'Choose what happens to linked calendar events. Your Trayzero items and unrelated calendar events will remain.'**
  String get calendarDisconnectHelp;

  /// No description provided for @calendarKeepEvents.
  ///
  /// In en, this message translates to:
  /// **'Keep events in my calendar'**
  String get calendarKeepEvents;

  /// No description provided for @calendarKeepHelp.
  ///
  /// In en, this message translates to:
  /// **'Stop updates and leave events in place. Reconnecting can reuse these links.'**
  String get calendarKeepHelp;

  /// No description provided for @calendarRemoveEvents.
  ///
  /// In en, this message translates to:
  /// **'Remove {count} linked events'**
  String calendarRemoveEvents(int count);

  /// No description provided for @calendarRemoveHelp.
  ///
  /// In en, this message translates to:
  /// **'Remove only events linked to this connection. Failed removals remain available to retry.'**
  String get calendarRemoveHelp;

  /// No description provided for @calendarHowItWorks.
  ///
  /// In en, this message translates to:
  /// **'How linked events work'**
  String get calendarHowItWorks;

  /// No description provided for @calendarRules.
  ///
  /// In en, this message translates to:
  /// **'Trayzero publishes scheduled Calendar items to your chosen device calendar. Ordinary task deadlines are excluded.\n\nEdit linked titles, notes, times and recurrence in Trayzero. Updating can overwrite edits made in your calendar app. Events currently use a one-hour duration.\n\nCompleting, trashing or moving an item off Calendar removes its linked event on the next update. A recurring series advances to the next occurrence.\n\nPausing keeps events and their links. Disconnecting lets you keep or remove linked events. Trayzero items are never deleted by disconnecting.'**
  String get calendarRules;

  /// No description provided for @calendarBringEvents.
  ///
  /// In en, this message translates to:
  /// **'Bring events into Trayzero'**
  String get calendarBringEvents;

  /// No description provided for @calendarImportCopies.
  ///
  /// In en, this message translates to:
  /// **'Choose events to copy into your Inbox or Calendar. Copies do not follow later changes to the original events. Originals stay unchanged.'**
  String get calendarImportCopies;

  /// No description provided for @calendarChooseEvents.
  ///
  /// In en, this message translates to:
  /// **'Choose events'**
  String get calendarChooseEvents;

  /// No description provided for @calendarImportSource.
  ///
  /// In en, this message translates to:
  /// **'Choose a source calendar'**
  String get calendarImportSource;

  /// No description provided for @calendarImportDestination.
  ///
  /// In en, this message translates to:
  /// **'Add selected events to'**
  String get calendarImportDestination;

  /// No description provided for @calendarAddSelected.
  ///
  /// In en, this message translates to:
  /// **'Add {count} events'**
  String calendarAddSelected(int count);

  /// No description provided for @calendarNoImportEvents.
  ///
  /// In en, this message translates to:
  /// **'No new events to import. Events already added or linked to Trayzero are excluded. The range is the past 7 days and the next year.'**
  String get calendarNoImportEvents;

  /// No description provided for @calendarImportFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not import calendar events. Check calendar access and try again.'**
  String get calendarImportFailed;

  /// No description provided for @calendarDeviceHelp.
  ///
  /// In en, this message translates to:
  /// **'Uses your device’s calendar. No Trayzero account needed. A shared calendar may be visible to other people with access to it.'**
  String get calendarDeviceHelp;
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
    'ru',
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
    case 'ru':
      return AppLocalizationsRu();
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
