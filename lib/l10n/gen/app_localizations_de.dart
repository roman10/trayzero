// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'Trayzero';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get save => 'Speichern';

  @override
  String get delete => 'Löschen';

  @override
  String get add => 'Hinzufügen';

  @override
  String get ok => 'OK';

  @override
  String get next => 'Weiter';

  @override
  String get back => 'Zurück';

  @override
  String get skip => 'Überspringen';

  @override
  String get done => 'Fertig';

  @override
  String get undo => 'Rückgängig';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get settings => 'Einstellungen';

  @override
  String get enable => 'Aktivieren';

  @override
  String get none => 'Keine';

  @override
  String get notSet => 'Nicht gesetzt';

  @override
  String get search => 'Suchen';

  @override
  String get select => 'Auswählen';

  @override
  String get selectAll => 'Alle';

  @override
  String get selectNone => 'Keine';

  @override
  String get inbox => 'Posteingang';

  @override
  String get projects => 'Projekte';

  @override
  String get review => 'Review';

  @override
  String get more => 'Mehr';

  @override
  String get navInbox => 'Eingang';

  @override
  String get navDo => 'Erledigen';

  @override
  String get navProjects => 'Projekte';

  @override
  String get navReview => 'Review';

  @override
  String get navMore => 'Mehr';

  @override
  String get capture => 'Sammeln';

  @override
  String get clarify => 'Klären';

  @override
  String get organize => 'Organisieren';

  @override
  String get reflect => 'Review';

  @override
  String get engage => 'Erledigen';

  @override
  String get nextAction => 'Nächster Schritt';

  @override
  String get waitingFor => 'Warten auf';

  @override
  String get someday => 'Irgendwann';

  @override
  String get somedayMaybe => 'Irgendwann / Vielleicht';

  @override
  String get reference => 'Referenz';

  @override
  String get calendar => 'Kalender';

  @override
  String get project => 'Projekt';

  @override
  String get completed => 'Abgeschlossen';

  @override
  String get scheduled => 'Geplant';

  @override
  String get needsClarifying => 'Noch zu klären';

  @override
  String get howGtdWorks => 'GTD-Workflow';

  @override
  String get whatIsGtd => 'Was ist GTD?';

  @override
  String get onboardingPage1Title => 'Raus aus dem Kopf';

  @override
  String get onboardingPage1Body =>
      'Alles, was deine Aufmerksamkeit beansprucht — eine Aufgabe, eine Idee, eine Sorge — kommt in den Posteingang. Ziel ist es, den Kopf frei zu bekommen, nicht schon zu sortieren.';

  @override
  String get onboardingPage2Title => 'Kläre eins nach dem anderen';

  @override
  String get onboardingPage2Body =>
      'Der Prozess führt dich durch jedes gesammelte Element: Ist es überhaupt zu erledigen? Dauert es unter zwei Minuten? Delegieren? Ein Projekt? Ein nächster Schritt?';

  @override
  String get onboardingPage3Title => 'Erledigen mit System';

  @override
  String get onboardingPage3Body =>
      'Der \'Erledigen\'-Tab filtert nächste Schritte nach Kontext, Energie und Zeit. So weißt du immer, was du genau jetzt tun kannst.';

  @override
  String get onboardingPage4Title => 'Review für volles Vertrauen';

  @override
  String get onboardingPage4Body =>
      'Der Wöchentliche Rückblick hält dein System aktuell. Einmal pro Woche gehst du alle Listen durch, leerst den Eingang und planst voraus.';

  @override
  String get onboardingSeedTitle => 'Bereit für den Start';

  @override
  String get onboardingSeedBody =>
      'Standard-Kontexte (@Telefon, @Computer, @Besorgungen, @Zuhause, @Büro, @Überall, @Warten) sind bereits angelegt. Du kannst sie in den Einstellungen anpassen.';

  @override
  String get onboardingSeedSampleLabel => 'Beispielprojekt anlegen';

  @override
  String get onboardingSeedSampleSubtitle =>
      'Erstellt ein Starter-Projekt mit ein paar Aufgaben, damit die App nicht leer ist.';

  @override
  String get projectSectionActive => 'Aktiv';

  @override
  String get projectSectionUnfiled => 'Ohne Bereich';

  @override
  String get projectSectionOnHold => 'Pausiert';

  @override
  String get sampleProjectTitle => 'Das Beste aus GTD herausholen';

  @override
  String get sampleProjectOutcome =>
      'Täglich den Posteingang auf null bringen und jeden Freitag einen wöchentlichen Rückblick machen.';

  @override
  String get sampleItemReadPrimer =>
      'Die GTD-Einführung in den Einstellungen lesen';

  @override
  String get sampleItemEmptyEmail => 'Meinen E-Mail-Posteingang hierher leeren';

  @override
  String get sampleItemScheduleReview =>
      'Einen wiederkehrenden wöchentlichen Rückblick für Freitag einplanen';

  @override
  String get seedContextPhone => '@Telefon';

  @override
  String get seedContextComputer => '@Computer';

  @override
  String get seedContextErrands => '@Besorgungen';

  @override
  String get seedContextHome => '@Zuhause';

  @override
  String get seedContextOffice => '@Büro';

  @override
  String get seedContextAnywhere => '@Überall';

  @override
  String get seedContextWaiting => '@Warten';

  @override
  String get onboardingFinish => 'Los geht\'s';

  @override
  String get inboxEmptyTitle => 'Inbox Zero';

  @override
  String get inboxEmptyMessage =>
      'Nichts mehr zu klären. Tippe auf Sammeln, um den Kopf zu leeren — verarbeitet wird später.';

  @override
  String get inboxEmptyAction => 'Etwas sammeln';

  @override
  String inboxItemsToClarify(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Aufgaben zu klären',
      one: '1 Aufgabe zu klären',
      zero: 'Keine Aufgaben zu klären',
    );
    return '$_temp0';
  }

  @override
  String get processInbox => 'Posteingang leeren';

  @override
  String deleteItemsConfirmTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Einträge löschen?',
      one: '1 Eintrag löschen?',
    );
    return '$_temp0';
  }

  @override
  String get deleteItemsConfirmBody =>
      'Diese werden mit allen Anhängen dauerhaft entfernt. Das kann nicht rückgängig gemacht werden.';

  @override
  String deletedItemsSnackbar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Einträge gelöscht.',
      one: '1 Eintrag gelöscht.',
    );
    return '$_temp0';
  }

  @override
  String completedItemsSnackbar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Einträge abgeschlossen.',
      one: '1 Eintrag abgeschlossen.',
    );
    return '$_temp0';
  }

  @override
  String filedItemsSnackbar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Einträge ins Projekt einsortiert.',
      one: '1 Eintrag ins Projekt einsortiert.',
    );
    return '$_temp0';
  }

  @override
  String movedItemsSnackbar(int count, String destination) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Einträge nach $destination verschoben.',
      one: '1 Eintrag nach $destination verschoben.',
    );
    return '$_temp0';
  }

  @override
  String selectionCountTitle(int count) {
    return '$count ausgewählt';
  }

  @override
  String get captureTitle => 'Kopf leeren';

  @override
  String get captureHint => 'Was geht dir gerade durch den Kopf?';

  @override
  String get captureNotesHint => 'Notizen (optional)';

  @override
  String get captureEmptyError => 'Gib etwas zum Sammeln ein';

  @override
  String get captureSubmit => 'In den Posteingang';

  @override
  String get dictate => 'Diktieren';

  @override
  String get stopDictation => 'Diktat stoppen';

  @override
  String get dictationUnavailable =>
      'Diktieren ist nicht verfügbar. Du kannst deine Gedanken weiterhin eintippen.';

  @override
  String get processTitle => 'Posteingang klären';

  @override
  String get processCompleteTitle => 'Inbox Zero!';

  @override
  String get processCompleteNoItems => 'Alles erledigt.';

  @override
  String processCompleteStats(int filed, int doneNow, int trashed) {
    return 'Du hast $filed einsortiert, $doneNow in unter 2 Minuten erledigt und $trashed gelöscht. Saubere Arbeit.';
  }

  @override
  String processStepCounter(int step, int total) {
    return 'Schritt $step von $total';
  }

  @override
  String processItemsRemaining(int count) {
    return 'Noch $count';
  }

  @override
  String get previousStepTooltip => 'Vorheriger Schritt';

  @override
  String get skipItemTooltip => 'Überspringen';

  @override
  String get actionableQuestion => 'Ist eine Aktion erforderlich?';

  @override
  String get actionableYes => 'Ja — es gibt etwas zu tun';

  @override
  String get actionableReference => 'Nein — als Referenz behalten';

  @override
  String get actionableSomeday => 'Nein — irgendwann / vielleicht';

  @override
  String get actionableTrash => 'Löschen';

  @override
  String get twoMinQuestion => 'Dauert es unter 2 Minuten?';

  @override
  String get twoMinYes => 'Ja — ich mach\'s sofort';

  @override
  String get delegateQuestion => 'Kann das jemand anderes tun?';

  @override
  String get waitingOnPromptTitle => 'Auf wen wartest du?';

  @override
  String get waitingOnPromptHint => 'Person oder System';

  @override
  String get recurrencePrompt => 'Wiederholen?';

  @override
  String get recurrenceOff => 'Keine Wiederholung';

  @override
  String get capturedLabel => 'GESAMMELT';

  @override
  String get engageTitle => 'Jetzt tun';

  @override
  String get engageEmptyTitle => 'Keine nächsten Schritte';

  @override
  String get engageEmptyMessage =>
      'Sammle etwas oder kläre deinen Posteingang, um deine Liste zu füllen.';

  @override
  String get engageInlineEmpty =>
      'Keine nächsten Schritte — sammle etwas oder kläre deinen Posteingang.';

  @override
  String get engageOpenInbox => 'Posteingang öffnen';

  @override
  String get engageNoMatchTitle => 'Keine Treffer';

  @override
  String get hardLandscape => 'Kalender';

  @override
  String get hardLandscapeSubtitle => 'Heute fällig & Überfällig';

  @override
  String get filterAllContexts => 'Alle Kontexte';

  @override
  String get filterAnyTime => 'Beliebige Dauer';

  @override
  String get filterUnder5m => '< 5 Min.';

  @override
  String get filterUnder15m => '< 15 Min.';

  @override
  String get filterUnder30m => '< 30 Min.';

  @override
  String get filterUnder1h => '< 1 Std.';

  @override
  String get filterAnyEnergy => 'Beliebige Energie';

  @override
  String get energyLow => 'Niedrig';

  @override
  String get energyMedium => 'Mittel';

  @override
  String get energyHigh => 'Hoch';

  @override
  String get projectsTitle => 'Projekte';

  @override
  String get newProject => 'Neues Projekt';

  @override
  String get organizeLooseActionsTooltip => 'Lose Aufgaben sortieren';

  @override
  String get projectsEmptyTitle => 'Noch keine Projekte';

  @override
  String get projectsEmptyMessage =>
      'Ein Projekt ist jedes Ziel, das mehr als einen Schritt erfordert. Erstelle eines, um Aufgaben zu bündeln.';

  @override
  String get projectMissingNextAction => 'Kein nächster Schritt definiert';

  @override
  String get organizeActionsTitle => 'Aufgaben sortieren';

  @override
  String get organizeEmptyTitle => 'Nichts mehr lose';

  @override
  String get organizeEmptyMessage =>
      'Alle Aufgaben sind bereits Projekten zugeordnet. Neue lose Aufgaben erscheinen hier.';

  @override
  String assignToProject(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count einem Projekt zuordnen',
      one: '1 einem Projekt zuordnen',
    );
    return '$_temp0';
  }

  @override
  String get addNextActionTitle => 'Nächsten Schritt hinzufügen';

  @override
  String get addNextActionHint => 'z. B. Email an Sara wegen Zeitplan';

  @override
  String get addExistingActions => 'Bestehende Aufgaben hinzufügen';

  @override
  String get noUnassignedActionsMessage =>
      'Keine losen Aufgaben zum Übernehmen.';

  @override
  String addCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hinzufügen',
      one: '1 hinzufügen',
    );
    return '$_temp0';
  }

  @override
  String get editProject => 'Projekt bearbeiten';

  @override
  String get projectName => 'Projektname';

  @override
  String get projectNameHint => 'z. B. Launch der neuen Website';

  @override
  String get projectNameRequired => 'Gib einen Projektnamen ein';

  @override
  String get areaOfFocusOptional => 'Fokusbereich (optional)';

  @override
  String get unfiledOption => '— Ohne Bereich —';

  @override
  String get dueDate => 'Fälligkeit';

  @override
  String get deleteProjectConfirmTitle => 'Projekt löschen?';

  @override
  String get deleteProjectWarning =>
      'Zugeordnete Aufgaben verlieren ihr Projekt, werden aber nicht gelöscht.';

  @override
  String get addActionFab => 'Aufgabe hinzufügen';

  @override
  String get projectOutcomeHint => 'Was ist das gewünschte Ergebnis?';

  @override
  String get outcomeSection => 'Ergebnis';

  @override
  String get nextActionsSection => 'Nächste Schritte';

  @override
  String get noNextActionsMessage => 'Noch keine nächsten Schritte.';

  @override
  String get statusTooltip => 'Status';

  @override
  String get reviewTitle => 'Review';

  @override
  String get weeklyReviewCardTitle => 'Wöchentlicher Rückblick';

  @override
  String get weeklyReviewCardSubtitle =>
      'Geh deinen Eingang, deine Listen und Projekte durch. Das Ritual für ein vertrauenswürdiges System.';

  @override
  String get calendarEmpty => 'Nichts für einen bestimmten Tag geplant.';

  @override
  String get waitingForEmpty => 'Nichts delegiert.';

  @override
  String get somedayEmpty => 'Keine \'Irgendwann/Vielleicht\'-Einträge.';

  @override
  String get referenceEmpty => 'Keine Referenzen.';

  @override
  String get completedThisWeek => 'Diese Woche abgeschlossen';

  @override
  String get completedThisWeekEmpty => 'Noch nichts abgeschlossen diese Woche.';

  @override
  String bucketCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Einträge',
      one: '1 Eintrag',
    );
    return '$_temp0';
  }

  @override
  String get needsReDecision => 'Neu entscheiden';

  @override
  String pastDueCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Einträge überfällig',
      one: '1 Eintrag überfällig',
    );
    return '$_temp0';
  }

  @override
  String get reviewStep1Title => 'Kopf leeren';

  @override
  String get reviewStep1Body =>
      'Sammle alles, was dich beschäftigt, in den Posteingang, um den Kopf frei zu bekommen.';

  @override
  String get reviewStep2Title => 'Posteingang leeren';

  @override
  String get reviewStep2Body =>
      'Kläre jedes gesammelte Element anhand des Entscheidungsbaums, bis der Eingang leer ist.';

  @override
  String get reviewStep3Title => 'Nächste Schritte prüfen';

  @override
  String get reviewStep3Body =>
      'Gehe alle Schritte durch. Erledigt? Abhaken. Veraltet? Bearbeiten oder löschen. Immer noch aktuell? So belassen.';

  @override
  String get reviewStep4Title => 'Warten-auf-Liste prüfen';

  @override
  String get reviewStep4Body =>
      'Gibt es Rückmeldungen? Musst du nachhaken? Aktualisieren oder entfernen.';

  @override
  String get reviewStep5Title => 'Projekte prüfen';

  @override
  String get reviewStep5Body =>
      'Prüfe jedes Ergebnis. Gib stockenden Projekten eine nächste Aktion, pausiere sie oder markiere sie als erledigt. Wartende und geplante Aufgaben zählen als Fortschritt.';

  @override
  String get reviewStep6Title => 'Blick auf die nächsten zwei Wochen';

  @override
  String get reviewStep6Body =>
      'Prüfe deinen Kalender. Gibt es etwas, das du jetzt schon vorbereiten kannst?';

  @override
  String get reviewStep7Title => 'Irgendwann / Vielleicht durchsehen';

  @override
  String get reviewStep7Body =>
      'Lohnt sich etwas davon jetzt? Mach ein Projekt oder einen nächsten Schritt daraus.';

  @override
  String reviewStepCounter(int step, int total) {
    return 'Schritt $step von $total';
  }

  @override
  String get finishReview => 'Review abschließen';

  @override
  String get reviewCompleteSnackbar => 'Wöchentlicher Rückblick abgeschlossen';

  @override
  String get searchHint => 'Suche nach Aufgaben, Notizen';

  @override
  String get searchMinChars => 'Mindestens zwei Zeichen';

  @override
  String get clearFilters => 'Filter zurücksetzen';

  @override
  String get clearSearch => 'Suche löschen';

  @override
  String searchNoResults(String query) {
    return 'Keine Treffer für „$query“';
  }

  @override
  String get searchNoMatchTitle => 'Keine Treffer';

  @override
  String get searchNoMatchMessage =>
      'Nichts passt zu den Filtern. Lockere die Filter oder lösche sie.';

  @override
  String get filterAllProjects => 'Alle Projekte';

  @override
  String get filterCompleted => 'Abgeschlossen';

  @override
  String get statusInbox => 'Eingang';

  @override
  String get statusNext => 'Nächste';

  @override
  String get statusWaiting => 'Warten';

  @override
  String get statusSomeday => 'Irgendwann';

  @override
  String get statusReference => 'Referenz';

  @override
  String get appearanceSection => 'Darstellung';

  @override
  String get themeLabel => 'Design';

  @override
  String get themeFollowSystem => 'Systemeinstellung';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get hapticFeedback => 'Haptisches Feedback';

  @override
  String get languageLabel => 'Sprache';

  @override
  String get languageFollowSystem => 'Systemstandard';

  @override
  String get contextsLabel => 'Kontexte';

  @override
  String get areasOfFocusLabel => 'Fokusbereiche';

  @override
  String get calendarSyncLabel => 'Kalender-Sync';

  @override
  String get remindersSection => 'Erinnerungen';

  @override
  String get weeklyReviewNudge => 'Erinnerung: Wöchentlicher Rückblick';

  @override
  String get weeklyReviewNudgeDescription =>
      'Eine sanfte Erinnerung jeden Freitag um 16:00 Uhr.';

  @override
  String get remindBeforeDue => 'Erinnerung vor Fälligkeit';

  @override
  String get remindBeforeDueOff => 'Aus · nur Hinweis zur Fälligkeit';

  @override
  String get remindBeforeDueSuffix => 'gilt für neue Aufgaben';

  @override
  String get deferSurfaceLabel => 'Hinweis für aufgeschobene Aufgaben um';

  @override
  String get deferSurfaceDescription =>
      'Aufgaben ohne Uhrzeit bleiben in der Liste und melden sich zu dieser Zeit';

  @override
  String get checkingNotificationStatus =>
      'Benachrichtigungsstatus wird geprüft…';

  @override
  String exportBackupError(String error) {
    return 'Fehler beim Export: $error';
  }

  @override
  String get weeklyBackupReminder => 'Wöchentliche Backup-Erinnerung';

  @override
  String get weeklyBackupReminderDescription =>
      'Erinnere mich jeden Sonntagmorgen an das Backup.';

  @override
  String get importConfirmTitle => 'Dieses Backup importieren?';

  @override
  String importConfirmBody(String sections) {
    return 'Es werden $sections hinzugefügt oder aktualisiert.\n\nBestehende Einträge mit gleicher ID werden überschrieben. Dies kann nicht rückgängig gemacht werden.';
  }

  @override
  String get importButton => 'Importieren';

  @override
  String get importFromPasteTitle => 'JSON einfügen';

  @override
  String get importFromPasteDescription => 'Backup-Text direkt hier einfügen.';

  @override
  String get pasteBackupHint => 'JSON hier einfügen…';

  @override
  String get crashReports => 'Absturzberichte senden';

  @override
  String get crashReportsDescription =>
      'Anonyme Absturz- und Fehlerberichte via Sentry. Keine persönlichen Daten. Standardmäßig aus.';

  @override
  String get crashReportsEnabled =>
      'Absturzberichte werden beim nächsten Start gesendet';

  @override
  String get crashReportsDisabled => 'Absturzberichte deaktiviert';

  @override
  String get showOnboardingAgain => 'Einführung erneut anzeigen';

  @override
  String get versionLabel => 'Version';

  @override
  String get settingsFooter =>
      'Local-first. Deine Daten bleiben auf diesem Gerät. Inspiriert von David Allens Getting-Things-Done-Methode.';

  @override
  String get editTitle => 'Bearbeiten';

  @override
  String get saveError =>
      'Deine Änderungen konnten nicht gespeichert werden. Bitte versuche es erneut.';

  @override
  String get savedIndicator => 'Gespeichert';

  @override
  String get titleLabel => 'Titel';

  @override
  String get notesLabel => 'Notizen';

  @override
  String get statusSection => 'Status';

  @override
  String get contextSection => 'Kontext';

  @override
  String get energySection => 'Energie';

  @override
  String get timeEstimateSection => 'Zeitaufwand';

  @override
  String get waitingOnSection => 'Warten auf';

  @override
  String get waitingOnHint => 'Auf wen oder was wartest du?';

  @override
  String get projectSection => 'Projekt';

  @override
  String get datesSection => 'Daten';

  @override
  String get dueLabel => 'Fällig';

  @override
  String get deferUntilLabel => 'Aufschieben bis';

  @override
  String get repeatSection => 'Wiederholung';

  @override
  String get recurrenceNeedsDeferHint =>
      'Setze ein \'Aufschieben bis\' Datum, um Wiederholung zu aktivieren.';

  @override
  String get recurrenceNeedsDueDateHint =>
      'Setze ein Datum, um Wiederholung zu aktivieren.';

  @override
  String get recurrenceExplanation =>
      'Nach Abschluss erscheint die nächste Instanz mit neuen Daten.';

  @override
  String get recurrenceNoDateNextActionError =>
      'Wiederholung braucht ein \'Aufschieben bis\' Datum, sonst wird kein Folge-Eintrag erzeugt.';

  @override
  String get recurrenceNoDateError =>
      'Wiederholung braucht ein Datum, sonst wird kein Folge-Eintrag erzeugt.';

  @override
  String get attachmentsSection => 'Anhänge';

  @override
  String get markComplete => 'Erledigen';

  @override
  String get reopen => 'Wieder öffnen';

  @override
  String get deleteItemConfirmTitle => 'Eintrag löschen?';

  @override
  String get deleteItemConfirmBody =>
      'Das kann nicht rückgängig gemacht werden.';

  @override
  String get completeError => 'Konnte nicht abgeschlossen werden.';

  @override
  String get reopenError => 'Konnte nicht wieder geöffnet werden.';

  @override
  String get remindersBlockedWarning =>
      'Mitteilungen sind im System blockiert.';

  @override
  String get remindersOffWarning => 'Mitteilungen sind aus.';

  @override
  String get preciseReminderOffWarning => 'Präzise Erinnerungen sind aus.';

  @override
  String get allowExactAlarms => 'Exakte Alarme erlauben';

  @override
  String get noContextsAvailable => 'Noch keine Kontexte angelegt.';

  @override
  String get noActiveProjects => 'Noch keine aktiven Projekte.';

  @override
  String get attachmentPhoto => 'Foto';

  @override
  String get attachmentCamera => 'Kamera';

  @override
  String get attachmentVoiceMemo => 'Sprachnotiz';

  @override
  String get attachmentStop => 'Stopp';

  @override
  String get remove => 'Entfernen';

  @override
  String get imageViewerClose => 'Schließen';

  @override
  String imageViewerCounter(int current, int total) {
    return '$current / $total';
  }

  @override
  String attachmentPhotoCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Fotos',
      one: '1 Foto',
    );
    return '$_temp0';
  }

  @override
  String attachmentAudioCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Sprachnotizen',
      one: '1 Sprachnotiz',
    );
    return '$_temp0';
  }

  @override
  String attachmentFileCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Dateien',
      one: '1 Datei',
    );
    return '$_temp0';
  }

  @override
  String get areasTitle => 'Fokusbereiche';

  @override
  String get newArea => 'Neuer Bereich';

  @override
  String get renameArea => 'Bereich umbenennen';

  @override
  String get areasEmptyMessage =>
      'Noch keine Fokusbereiche. Bereiche sind Lebensbereiche — Gesundheit, Karriere, Familie — die Projekte halten.';

  @override
  String get areaNameHint => 'z. B. Gesundheit, Karriere, Familie';

  @override
  String deleteAreaConfirmTitle(String name) {
    return '„$name“ löschen?';
  }

  @override
  String get deleteAreaWarning =>
      'Zugeordnete Projekte verlieren ihren Bereich, werden aber nicht gelöscht.';

  @override
  String get contextsTitle => 'Kontexte';

  @override
  String get newContext => 'Neuer Kontext';

  @override
  String get editContext => 'Kontext bearbeiten';

  @override
  String get contextsEmptyMessage =>
      'Noch keine Kontexte. Kontexte sagen dir, wo oder womit etwas erledigt werden kann (@Telefon, @Home).';

  @override
  String get nameLabel => 'Name';

  @override
  String get iconLabel => 'Icon';

  @override
  String get colorLabel => 'Farbe';

  @override
  String deleteContextConfirmTitle(String name) {
    return '$name löschen?';
  }

  @override
  String get deleteContextWarning =>
      'Zugeordnete Aufgaben verlieren diesen Kontext.';

  @override
  String get calendarSyncTitle => 'Kalender-Sync';

  @override
  String get calendarSyncIntro =>
      'Spiegle fällige Aufgaben in deinen Kalender und hole „#gtd“ Events in deinen Posteingang.';

  @override
  String get enableCalendarSync => 'Kalender-Sync aktivieren';

  @override
  String get targetCalendar => 'Zielkalender';

  @override
  String get calendarAccessDenied => 'Kalenderzugriff verweigert.';

  @override
  String get grantCalendarAccess => 'Zugriff erlauben';

  @override
  String get noCalendarsAvailable => 'Keine Kalender verfügbar.';

  @override
  String get mirrorOutAction => 'Aufgaben → Kalender';

  @override
  String get importInAction => '„#gtd“ Events → Posteingang';

  @override
  String mirrorOutSuccess(int written) {
    return '$written Aufgaben gespiegelt';
  }

  @override
  String mirrorOutSuccessWithStale(int written, int removed) {
    return '$written Aufgaben gespiegelt, $removed alte entfernt';
  }

  @override
  String importInSuccess(int count) {
    return '$count Kalender-Events importiert';
  }

  @override
  String get mirroringProgress => 'Spiegelung läuft…';

  @override
  String get importingProgress => 'Import läuft…';

  @override
  String get calendarSyncTip =>
      'Tipp: Schreibe „#gtd“ in den Titel eines Kalender-Events, um es automatisch zu importieren.';

  @override
  String get gtdDiagramTitle => 'GTD-Workflow';

  @override
  String get gtdDiagramSubtitle =>
      'Fünf Schritte, um den Kopf frei zu bekommen. Tippe auf eine Liste, um dorthin zu springen.';

  @override
  String get gtdAttribution =>
      'Methode von David Allen · gettingthingsdone.com';

  @override
  String get youAreHere => 'Du bist hier';

  @override
  String get gtdStage1Body =>
      'Wirf alles in den Posteingang — Aufgaben, Ideen, Sorgen. Noch nicht sortieren.';

  @override
  String get gtdStage2Body =>
      'Nimm eins nach dem anderen und entscheide: Was ist es? Der Prozess führt dich durch diese Fragen:';

  @override
  String get gtdStage3Body =>
      'Das Ergebnis landet auf der passenden Liste. Nichts bleibt mehr im Kopf.';

  @override
  String get gtdStage3Footnote =>
      'Warten / Kalender / Irgendwann / Referenz findest du unter Review.';

  @override
  String get gtdStage4Body =>
      'Prüfe deine Listen regelmäßig — besonders beim Wöchentlichen Rückblick.';

  @override
  String get gtdStage5Body =>
      'Einfach tun — wähle Aufgaben nach Kontext, Zeit und Energie.';

  @override
  String get decisionNotActionableQ => 'Keine Aktion erforderlich?';

  @override
  String get decisionNotActionableA =>
      'Löschen, Irgendwann/Vielleicht oder Referenz';

  @override
  String get decisionTwoMinQ => 'Unter 2 Minuten?';

  @override
  String get decisionTwoMinA => 'Sofort erledigen';

  @override
  String get decisionDelegateQ => 'Jemand anderes?';

  @override
  String get decisionDelegateA => 'Delegieren → Warten auf';

  @override
  String get decisionMultiStepQ => 'Mehr als ein Schritt?';

  @override
  String get decisionMultiStepA => 'Projekt erstellen';

  @override
  String get decisionOtherwiseQ => 'Sonst';

  @override
  String get decisionOtherwiseA => 'Nächsten Schritt definieren';

  @override
  String get supportTitle => 'Trayzero unterstützen';

  @override
  String get supportIntro =>
      'Trayzero ist kostenlos und alle Funktionen sind freigeschaltet. Wenn es dir hilft, kannst du etwas beisteuern – so bleibt die App unabhängig und werbefrei.';

  @override
  String get supportUnavailable =>
      'Unterstützungsoptionen sind gerade nicht verfügbar.';

  @override
  String get supportTipHeader => 'Trinkgeld geben';

  @override
  String get supportTipSmall => 'Kleines Trinkgeld';

  @override
  String get supportTipLarge => 'Großes Trinkgeld';

  @override
  String get supportSupporterYearly => 'Unterstützer — jährlich';

  @override
  String supportSupporterYearlySubtitle(String price) {
    return '$price / Jahr · bestes Angebot · unterstützt die Entwicklung';
  }

  @override
  String get supportSupporterMonthly => 'Unterstützer — monatlich';

  @override
  String supportSupporterMonthlySubtitle(String price) {
    return '$price / Monat · jederzeit kündbar';
  }

  @override
  String supportOpeningStore(String store) {
    return '$store wird geöffnet…';
  }

  @override
  String get supportRestoring => 'Käufe werden wiederhergestellt…';

  @override
  String get supportRestore => 'Käufe wiederherstellen';

  @override
  String get supportRestoreSubtitle =>
      'Schon Unterstützer? Auf diesem Gerät wiederherstellen.';

  @override
  String get supportAutoRenewNote =>
      'Abos verlängern sich automatisch, bis du sie in den Einstellungen kündigst.';

  @override
  String get legalPrivacyPolicy => 'Datenschutzerklärung';

  @override
  String get legalTermsOfUse => 'Nutzungsbedingungen';

  @override
  String get supportThanksTip => 'Vielen herzlichen Dank! 💙';

  @override
  String get supportThanksSupporter => 'Du bist jetzt Unterstützer – danke! 💙';

  @override
  String get supportRestored =>
      'Käufe wiederhergestellt. Willkommen zurück! 💙';

  @override
  String get supportRestoreNone => 'Keine früheren Käufe gefunden.';

  @override
  String get supportBadgeYearly => 'Unterstützer · jährlich';

  @override
  String get supportBadgeMonthly => 'Unterstützer · monatlich';

  @override
  String get supportBadgeGeneric => 'Unterstützer';

  @override
  String get supportBadgeSubtitle =>
      'Danke, dass du Trayzero unabhängig hältst.';

  @override
  String get calendarLookupFailed =>
      'Kalender konnten nicht geladen werden. Prüfe die Kontosynchronisierung in der Kalender-App und versuche es erneut.';

  @override
  String get calendarPermissionHelp =>
      'Wenn keine Berechtigungsabfrage erscheint, erlaube den Kalenderzugriff in den App-Einstellungen und kehre zurück.';

  @override
  String get calendarOpenSettings => 'App-Einstellungen öffnen';

  @override
  String get calendarSettingsFailed =>
      'Öffne die Geräteeinstellungen und erlaube Trayzero den Kalenderzugriff.';

  @override
  String get calendarSelectionUnavailable =>
      'Der bisher ausgewählte Kalender ist nicht mehr verfügbar. Wähle einen anderen Kalender.';

  @override
  String get appIcon => 'App-Symbol';

  @override
  String get appIconAndroidDescription =>
      'Wähle ein Startbildschirm-Symbol unabhängig von der App-Farbe. Der Launcher braucht möglicherweise einen Moment zum Aktualisieren oder wendet eine eigene Farbe an.';

  @override
  String get appIconDescription =>
      'Wähle ein Symbol unabhängig von der App-Farbe. Dein Gerät kann es selbst einfärben. iOS zeigt beim Ändern einen Bestätigungshinweis.';

  @override
  String get appIconChangeFailed =>
      'Das App-Symbol konnte nicht geändert werden. Versuche es erneut, während Trayzero geöffnet ist.';

  @override
  String get appColor => 'App-Farbe';

  @override
  String get appColorDescription =>
      'Funktioniert im hellen und dunklen Modus. Die Farben der GTD-Listen behalten ihre Bedeutung.';

  @override
  String get paletteAmber => 'Trayzero-Bernstein — Standard';

  @override
  String get paletteBlue => 'Blau';

  @override
  String get paletteCyan => 'Cyan';

  @override
  String get paletteTeal => 'Petrol';

  @override
  String get paletteGreen => 'Grün';

  @override
  String get paletteViolet => 'Violett';

  @override
  String get paletteRose => 'Rosa';

  @override
  String get appIconNotificationNote =>
      'Android-Benachrichtigungen verwenden beim Planen von Erinnerungen die ausgewählte App-Symbolfarbe. Bestehende Benachrichtigungen werden beim erneuten Planen aktualisiert. Manche Geräte zeigen möglicherweise das ursprüngliche App-Symbol.';

  @override
  String get appearanceSaveFailed =>
      'Die Darstellung konnte nicht gespeichert werden. Die vorherige Einstellung wurde wiederhergestellt.';

  @override
  String mirrorOutPendingCleanup(int count) {
    return '$count Kalenderereignisse müssen noch entfernt werden. Synchronisiere erneut.';
  }

  @override
  String get weeklyReviewResume => 'Wochenrückblick fortsetzen';

  @override
  String get weeklyReviewProgressSaved =>
      'Dein Fortschritt bleibt beim Verlassen gespeichert.';

  @override
  String get weeklyReviewSaveError =>
      'Dein Fortschritt konnte nicht gespeichert werden. Bitte versuche es erneut.';

  @override
  String get weeklyReviewActionError =>
      'Die Änderung konnte nicht gespeichert werden. Bitte versuche es erneut.';

  @override
  String get weeklyReviewListEmpty => 'Hier gibt es nichts zu überprüfen.';

  @override
  String get weeklyReviewProjectAwaiting =>
      'Ausstehende oder geplante Arbeit bringt dieses Projekt voran.';

  @override
  String get weeklyReviewProjectMoving => 'Nächste Aktion festgelegt';

  @override
  String get weeklyReviewOpenProject => 'Projekt öffnen';

  @override
  String get processTwoMinNo => 'Nein — weiter klären';

  @override
  String get twoMinRule =>
      'Die Zwei-Minuten-Regel: Wenn das Erledigen kürzer dauert als das Erfassen, erledige es sofort.';

  @override
  String get delegateYes => 'Ja — delegieren und auf Rückmeldung warten';

  @override
  String get delegateNo => 'Nein — das mache ich selbst';

  @override
  String get singleStepQuestion => 'Ist das eine einzelne konkrete Aktion?';

  @override
  String get singleStepYes => 'Ja — ein einzelner nächster Schritt';

  @override
  String get singleStepProject => 'Nein — das ist ein Projekt';

  @override
  String get projectRule =>
      'Ein Projekt ist ein Ergebnis, das mehr als eine Aktion erfordert und innerhalb eines Jahres erreicht werden kann.';

  @override
  String get deferQuestion => 'Gibt es einen bestimmten Tag oder Zeitpunkt?';

  @override
  String get deferAsap => 'Nein — so bald wie möglich erledigen';

  @override
  String get deferCalendar => 'Ja — in den Kalender eintragen';

  @override
  String get deferChooseDate => 'Auf ein Datum verschieben';

  @override
  String get processDetailsTitle => 'Details hinzufügen';

  @override
  String get processFileNextAction => 'Als nächsten Schritt ablegen';

  @override
  String minutesShort(int minutes) {
    return '$minutes Min.';
  }

  @override
  String deferredUntilSummary(String date) {
    return 'Verschoben bis $date';
  }

  @override
  String deferredRepeatingSummary(String date, String recurrence) {
    return 'Verschoben bis $date · Wiederholung: $recurrence';
  }

  @override
  String get recurrenceDaily => 'Täglich';

  @override
  String get recurrenceWeekly => 'Wöchentlich';

  @override
  String get recurrenceMonthly => 'Monatlich';

  @override
  String get recurrenceYearly => 'Jährlich';

  @override
  String get createProject => 'Erstellen';

  @override
  String get projectPickerTitle => 'In ein Projekt verschieben';

  @override
  String get projectMoved => 'In ein Projekt verschoben.';

  @override
  String get projectDetached => 'Aus dem Projekt entfernt.';

  @override
  String get noProject => 'Kein Projekt';

  @override
  String get decreaseRepeatInterval => 'Wiederholungsintervall verkürzen';

  @override
  String get increaseRepeatInterval => 'Wiederholungsintervall verlängern';

  @override
  String get decreaseRepeatCount => 'Wiederholungsanzahl verringern';

  @override
  String get increaseRepeatCount => 'Wiederholungsanzahl erhöhen';

  @override
  String get repeatOn => 'Wiederholen am';

  @override
  String get repeatMonthlyOn => 'Am';

  @override
  String get repeatDayOfMonth => 'Tag des Monats';

  @override
  String get repeatDayOfWeek => 'Wochentag';

  @override
  String get repeatFirst => 'Erster';

  @override
  String get repeatSecond => 'Zweiter';

  @override
  String get repeatThird => 'Dritter';

  @override
  String get repeatFourth => 'Vierter';

  @override
  String get repeatFifth => 'Fünfter';

  @override
  String get repeatLast => 'Letzter';

  @override
  String get repeatEnds => 'Endet';

  @override
  String get repeatNever => 'Nie';

  @override
  String get repeatOnDate => 'An einem Datum';

  @override
  String get repeatAfterCount => 'Nach einer Anzahl';

  @override
  String get weekdayListSeparator => ', ';

  @override
  String get dueToday => 'Heute fällig';

  @override
  String get reschedule => 'Neu planen';

  @override
  String get complete => 'Abschließen';

  @override
  String get drop => 'Verwerfen';

  @override
  String get trash => 'Papierkorb';

  @override
  String itemEnergyLabel(String energy) {
    return 'Energie: $energy';
  }

  @override
  String waitingOnPerson(String person) {
    return 'Warten auf $person';
  }

  @override
  String dueOverdueDays(int days) {
    return 'Überfällig · $days T.';
  }

  @override
  String dueTodayAt(String time) {
    return 'Heute fällig, $time';
  }

  @override
  String selectItem(String title) {
    return '$title auswählen';
  }

  @override
  String markItemDone(String title) {
    return '$title als erledigt markieren';
  }

  @override
  String repeatLastOnDate(String date) {
    return 'Zuletzt am $date';
  }

  @override
  String repeatAfterOccurrences(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nach $count Wiederholungen',
      one: 'Nach 1 Wiederholung',
    );
    return '$_temp0';
  }

  @override
  String recurrenceUntilSummary(String pattern, String date) {
    return '$pattern · bis $date';
  }

  @override
  String recurrenceCountSummary(String pattern, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$pattern · $count Wiederholungen',
      one: '$pattern · 1 Wiederholung',
    );
    return '$_temp0';
  }

  @override
  String recurrenceOnWeekdays(String cadence, String weekdays) {
    return '$cadence: $weekdays';
  }

  @override
  String recurrenceOnNthWeekday(
    String cadence,
    String ordinal,
    String weekday,
  ) {
    String _temp0 = intl.Intl.selectLogic(ordinal, {
      'first': 'ersten',
      'second': 'zweiten',
      'third': 'dritten',
      'fourth': 'vierten',
      'fifth': 'fünften',
      'other': 'letzten',
    });
    return '$cadence am $_temp0 $weekday';
  }

  @override
  String repeatEveryDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Alle $count Tage',
      one: 'Jeden Tag',
    );
    return '$_temp0';
  }

  @override
  String repeatEveryWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Alle $count Wochen',
      one: 'Jede Woche',
    );
    return '$_temp0';
  }

  @override
  String repeatEveryMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Alle $count Monate',
      one: 'Jeden Monat',
    );
    return '$_temp0';
  }

  @override
  String repeatEveryYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Alle $count Jahre',
      one: 'Jedes Jahr',
    );
    return '$_temp0';
  }

  @override
  String get captureAddContinue => 'Hinzufügen & weiter';

  @override
  String captureAddedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Einträge zum Posteingang hinzugefügt',
      one: '1 Eintrag zum Posteingang hinzugefügt',
    );
    return '$_temp0';
  }

  @override
  String get folderBackupChoose => 'Sicherungsordner auswählen';

  @override
  String get folderBackupSaving => 'Sicherung läuft…';

  @override
  String get folderBackupOff => 'Automatische Sicherungen sind aus.';

  @override
  String get folderBackupNever => 'Noch keine erfolgreiche Sicherung.';

  @override
  String folderBackupLastSuccess(String date) {
    return 'Letzte Sicherung: $date';
  }

  @override
  String get folderBackupFailed =>
      'Sicherung fehlgeschlagen. Ordnerzugriff und freien Speicher prüfen und erneut versuchen.';

  @override
  String get folderBackupHistoryWarning =>
      'Sicherung gespeichert, aber ältere Sicherungen konnten nicht entfernt werden.';

  @override
  String get folderBackupNow => 'Jetzt sichern';

  @override
  String get doViewToday => 'Heute';

  @override
  String get doViewNextActions => 'Nächste Schritte';

  @override
  String get todayPlanCardTitle => 'Plane deinen Tag';

  @override
  String get todayPlanCardBody =>
      'Wähle aus, worauf du dich heute konzentrierst. Das dauert etwa zwei Minuten.';

  @override
  String get todayPlanAction => 'Heute planen';

  @override
  String todayCarryOverLine(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Einträge von früher brauchen eine Entscheidung',
      one: '1 Eintrag von früher braucht eine Entscheidung',
    );
    return '$_temp0';
  }

  @override
  String get todayFocusHeader => 'Fokus';

  @override
  String todayDoneCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count heute erledigt',
      one: '1 heute erledigt',
    );
    return '$_temp0';
  }

  @override
  String get todayEmptyTitle => 'Noch nichts im Fokus';

  @override
  String get todayEmptyMessage =>
      'Markiere nächste Schritte mit einem Stern, um dich heute darauf festzulegen, oder plane deinen Tag.';

  @override
  String get focusAddTooltip => 'Zu Heute hinzufügen';

  @override
  String get focusRemoveTooltip => 'Aus Heute entfernen';

  @override
  String focusAddItem(String title) {
    return '$title zu Heute hinzufügen';
  }

  @override
  String focusRemoveItem(String title) {
    return '$title aus Heute entfernen';
  }

  @override
  String get focusError =>
      'Heute konnte nicht aktualisiert werden. Versuche es erneut.';

  @override
  String get planTodayIntro =>
      'Markiere mit einem Stern, worauf du dich heute festlegst. Halte die Liste kurz – alles andere bleibt auf deinen Listen.';

  @override
  String get planSectionCarryOver => 'Von früher';

  @override
  String get planCarryOverHint =>
      'Einträge, die du nicht behältst, kehren auf ihre Listen zurück, sobald du deinen Tag startest.';

  @override
  String get planKeepAll => 'Alle behalten';

  @override
  String get planSectionCalendar => 'Kalender';

  @override
  String get planOnToday => 'Auf Heute';

  @override
  String get planSectionWaiting => 'Nachfassen bei Wartenden';

  @override
  String get planSectionAvailable => 'Ab heute verfügbar';

  @override
  String get planEmpty =>
      'Noch nichts zu planen. Bearbeite deinen Eingang, um nächste Schritte zu erstellen.';

  @override
  String planFocusedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count für heute im Fokus',
      one: '1 für heute im Fokus',
      zero: 'Noch nichts im Fokus',
    );
    return '$_temp0';
  }

  @override
  String get planStartDay => 'Tag starten';

  @override
  String get planDoneSnackbar => 'Der Tag ist geplant';

  @override
  String planClearedSnackbar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tag geplant · $count Einträge zurück auf ihren Listen',
      one: 'Tag geplant · 1 Eintrag zurück auf seiner Liste',
    );
    return '$_temp0';
  }

  @override
  String get planSaveError =>
      'Dein Plan konnte nicht gespeichert werden. Versuche es erneut.';

  @override
  String get captureTipDates =>
      'Tipp: Füge @Kontext, #Projekt, +Tag oder ein englisches Datum wie „tomorrow“ hinzu.';

  @override
  String get captureTipSigils =>
      'Tipp: Füge @Kontext, #Projekt oder +Tag hinzu.';

  @override
  String startsOnDate(String date) {
    return 'Ab $date';
  }

  @override
  String dueOnDate(String date) {
    return 'Fällig $date';
  }

  @override
  String captureChipProject(String name) {
    return 'Projekt: $name';
  }

  @override
  String get captureKeepAsText => 'Als Text behalten';

  @override
  String get captureRecognized => 'Erkannte Angaben';

  @override
  String deferUseStartDate(String date) {
    return 'Ab $date beginnen';
  }

  @override
  String deferUseDueDate(String date) {
    return 'Im Kalender am $date';
  }

  @override
  String weeklyReviewProjectInactive(int days) {
    return 'Seit $days+ Tagen keine Aktivität';
  }

  @override
  String get weeklyReviewMarkReviewed => 'Als geprüft markieren';

  @override
  String get weeklyReviewReviewed => 'Geprüft';

  @override
  String weeklyReviewLastReviewed(String date) {
    return 'Zuletzt geprüft am $date';
  }

  @override
  String get weeklyReviewNeverReviewed => 'Noch nicht geprüft';

  @override
  String weeklyReviewReviewedProgress(int done, int total) {
    return '$done von $total geprüft';
  }

  @override
  String get importFromApp => 'Aus anderer App importieren';

  @override
  String get importSourcePlainText => 'Klartext / TaskPaper';

  @override
  String get importHintTodoist =>
      'Projektmenü › Als Vorlage exportieren › CSV, oder ein Backup-ZIP aus Einstellungen › Backups.';

  @override
  String get importHintTickTick =>
      'Auf der TickTick-Website: Einstellungen › Konto › Backup & Import › Backup erstellen (CSV).';

  @override
  String get importHintNirvana =>
      'Exportiere deine Daten in der Nirvana-Web-App als CSV oder JSON.';

  @override
  String get importHintOmniFocus =>
      'Projekte auswählen, dann Bearbeiten › Als TaskPaper kopieren. Hier einfügen oder als Datei sichern.';

  @override
  String get importHintPlainText =>
      'Things: To-dos kopieren und hier einfügen, eine Aufgabe pro Zeile. Nur einfacher Text; Things-Datenbankexporte werden nicht unterstützt.';

  @override
  String get importChooseFile => 'Datei wählen';

  @override
  String get importPasteText => 'Text einfügen';

  @override
  String get importPasteTitle => 'Aufgaben einfügen';

  @override
  String get importPasteHint =>
      'Eine Aufgabe pro Zeile. Rücke Aufgaben unter einer Zeile mit „:“ am Ende ein, um ein Projekt zu bilden.';

  @override
  String get importPasteContinue => 'Vorschau';

  @override
  String get importPreviewNothingYet => 'Bisher wurde nichts hinzugefügt.';

  @override
  String get importPreviewProjects => 'Projekte';

  @override
  String get importProjectNew => 'Neu';

  @override
  String get importProjectExisting => 'Ergänzt bestehendes';

  @override
  String importProjectActions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Aktionen',
      one: '1 Aktion',
    );
    return '$_temp0';
  }

  @override
  String importContextsNew(String names) {
    return 'Neu: $names';
  }

  @override
  String importContextsExisting(String names) {
    return 'Bereits vorhanden: $names';
  }

  @override
  String get importGoodToKnow => 'Gut zu wissen';

  @override
  String importWarnCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count erledigte oder verworfene Aufgaben übersprungen',
      one: '1 erledigte oder verworfene Aufgabe übersprungen',
    );
    return '$_temp0';
  }

  @override
  String importWarnCalendar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Aktionen mit Fälligkeitsdatum kommen in den Kalender',
      one: '1 Aktion mit Fälligkeitsdatum kommt in den Kalender',
    );
    return '$_temp0';
  }

  @override
  String importWarnDates(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Daten waren unlesbar und stehen in den Notizen',
      one: '1 Datum war unlesbar und steht in den Notizen',
    );
    return '$_temp0';
  }

  @override
  String importWarnRepeats(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Wiederholungsregeln stehen in den Notizen',
      one: '1 Wiederholungsregel steht in den Notizen',
    );
    return '$_temp0';
  }

  @override
  String importWarnSubtasks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Unteraufgaben werden eigene Aktionen',
      one: '1 Unteraufgabe wird eine eigene Aktion',
    );
    return '$_temp0';
  }

  @override
  String importWarnSections(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Aufgaben vermerken ihren Abschnitt in den Notizen',
      one: '1 Aufgabe vermerkt ihren Abschnitt in den Notizen',
    );
    return '$_temp0';
  }

  @override
  String importWarnNotImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count Aufgaben hatten Priorität, Markierung oder Zuständige, die nicht übernommen werden',
      one:
          '1 Aufgabe hatte Priorität, Markierung oder Zuständige, die nicht übernommen werden',
    );
    return '$_temp0';
  }

  @override
  String importWarnUnreadable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Zeilen ohne Titel übersprungen',
      one: '1 Zeile ohne Titel übersprungen',
    );
    return '$_temp0';
  }

  @override
  String importDoneTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Aufgaben hinzugefügt',
      one: '1 Aufgabe hinzugefügt',
    );
    return '$_temp0';
  }

  @override
  String get importDoneBody =>
      'Doch anders entschieden? Rückgängig entfernt genau das, was dieser Import hinzugefügt hat – sonst nichts.';

  @override
  String get importUndo => 'Import rückgängig';

  @override
  String get importFinish => 'Fertig';

  @override
  String get importUndoneTitle => 'Import rückgängig gemacht';

  @override
  String get importUndoneBody =>
      'Alles, was dieser Import hinzugefügt hat, wurde entfernt.';

  @override
  String get importRemindersFailed =>
      'Einige Erinnerungen konnten noch nicht geplant werden. Sie werden beim nächsten Öffnen der App gesetzt.';

  @override
  String importErrorUnrecognized(String source) {
    return 'Das sieht nicht nach einem $source-Export aus. Prüfe die Schritte und versuche es erneut.';
  }

  @override
  String get importErrorNoTasks =>
      'Keine offenen Aufgaben zum Importieren gefunden.';

  @override
  String get importErrorUnreadable =>
      'Diese Datei kann nicht gelesen werden. Wähle einen Text-, CSV- oder ZIP-Export.';

  @override
  String get importErrorWrite =>
      'Der Import ist fehlgeschlagen. Es wurde nichts hinzugefügt.';

  @override
  String get importErrorUndo =>
      'Import konnte nicht rückgängig gemacht werden. Versuche es erneut.';

  @override
  String get tagsAndPeopleLabel => 'Tags & Personen';

  @override
  String get tagsEmptyMessage =>
      'Tags markieren Aufgaben über alle Listen hinweg. Markiere einen Tag als Person, um eine Agenda mit Gesprächspunkten zu führen. Tipp: Tippe beim Erfassen +tag.';

  @override
  String get newTag => 'Neuer Tag';

  @override
  String get editTag => 'Tag bearbeiten';

  @override
  String get tagPersonSwitch => 'Person';

  @override
  String get tagPersonSwitchHint => 'Führt eine Agenda mit Gesprächspunkten';

  @override
  String tagOpenItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count offene Aufgaben',
      one: '1 offene Aufgabe',
      zero: 'Keine offenen Aufgaben',
    );
    return '$_temp0';
  }

  @override
  String deleteTagConfirmTitle(String name) {
    return '„$name“ löschen?';
  }

  @override
  String deleteTagConfirmBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count offene Aufgaben nutzen ihn. Sie bleiben; nur der Tag wird entfernt.',
      one: '1 offene Aufgabe nutzt ihn. Sie bleibt; nur der Tag wird entfernt.',
      zero: 'Keine offene Aufgabe nutzt ihn.',
    );
    return '$_temp0';
  }

  @override
  String get tagMergeTitle => 'Tags zusammenführen?';

  @override
  String tagMergeBody(String source, String target) {
    return '„$target“ gibt es schon. „$source“ damit zusammenführen?';
  }

  @override
  String get tagMergeAction => 'Zusammenführen';

  @override
  String get addTag => 'Tag hinzufügen';

  @override
  String get tagPickerHint => 'Tag suchen oder erstellen';

  @override
  String tagCreate(String name) {
    return '„$name“ erstellen';
  }

  @override
  String tagCreatePerson(String name) {
    return 'Person „$name“ erstellen';
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
    return '$name entfernen';
  }

  @override
  String moreTags(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count weitere Tags',
      one: '1 weiterer Tag',
    );
    return '$_temp0';
  }

  @override
  String get filterTag => 'Tag';

  @override
  String get filterAnyTag => 'Beliebiger Tag';

  @override
  String get agendasTitle => 'Agenden';

  @override
  String agendasPeopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Personen',
      one: '1 Person',
    );
    return '$_temp0';
  }

  @override
  String agendaAddHint(String name) {
    return 'Etwas zum Besprechen mit $name hinzufügen';
  }

  @override
  String get agendaAddTooltip => 'Zur Agenda hinzufügen';

  @override
  String agendaEmpty(String name) {
    return 'Noch nichts mit $name zu besprechen.';
  }

  @override
  String get agendaNotFound => 'Diese Person gibt es nicht mehr.';

  @override
  String captureChipNewTag(String name) {
    return 'Neuer Tag: $name';
  }

  @override
  String get importHintGoogleTasks =>
      'Google Takeout › Tasks auswählen › JSON exportieren. Download entpacken und Tasks.json wählen. Listen bleiben in Notizen; erledigte Aufgaben kommen nach Erledigt.';

  @override
  String get importDuplicateWarning =>
      'Diese Eingabe wurde auf diesem Gerät bereits importiert. Ein erneuter Import erzeugt doppelte Aufgaben. Abbrechen, wenn du keine weitere Kopie möchtest.';

  @override
  String get importHintThings =>
      'Wähle main.sqlite oder eine ZIP des exportierten Things-3-Datenbankordners. iPhone/iPad: Einstellungen › Allgemein › Diagnose › Code eingeben › 491348 › Things-Datenbank senden. In Dateien sichern, .aar entpacken, Ordner als ZIP komprimieren. Mac: Things vor dem Kopieren beenden. Wiederholungen und Erinnerungen neu einrichten.';

  @override
  String importWarnDetailsInNotes(int count) {
    return 'Bei $count Aufgaben bleiben Checklisten- oder Bereichsdetails in den Notizen';
  }

  @override
  String get importWarnThingsRecurrence =>
      'Things-Wiederholungen werden nicht importiert. Vorlagen werden übersprungen; richte Wiederholungen für importierte Aufgaben neu ein.';

  @override
  String importWarnSourceReminders(int count) {
    return '$count Erinnerungseinstellungen der Quelle werden nicht importiert';
  }

  @override
  String get importAppleHint =>
      'Wähle Erinnerungslisten auf diesem Gerät. Nur offene Erinnerungen werden importiert.';

  @override
  String get importAppleChooseLists => 'Listen auswählen';

  @override
  String get importAppleReloadLists => 'Listen neu laden';

  @override
  String get importAppleNoLists =>
      'Auf diesem Gerät sind keine Erinnerungslisten verfügbar.';

  @override
  String get importAppleDenied =>
      'Der Zugriff auf Erinnerungen ist deaktiviert. Erlaube Trayzero den Zugriff in den iOS-Einstellungen und versuche es erneut.';

  @override
  String get importAppleUnavailable =>
      'Apple Erinnerungen konnten nicht gelesen werden. Versuche es erneut.';

  @override
  String get importAppleListsChanged =>
      'Eine ausgewählte Liste ist nicht mehr verfügbar. Lade die Listen neu und wähle erneut.';

  @override
  String get importAppleLimits =>
      'Deine Apple-Erinnerungen bleiben unverändert. Apple-Tags, Markierungen, Anhänge, Unteraufgabenstruktur, Prioritäten und ursprüngliche Hinweise werden nicht kopiert. Erneutes Importieren kann doppelte Aufgaben erzeugen.';

  @override
  String get importHintMicrosoftTodo =>
      'Melde dich an, um Listen und offene Aufgaben zu kopieren. Prüfe die Vorschau; erneutes Importieren kann Duplikate erzeugen.';

  @override
  String get importMicrosoftUnavailable =>
      'Der Import aus Microsoft To Do ist in dieser Version nicht verfügbar.';

  @override
  String get importMicrosoftSignInError =>
      'Die Microsoft-Anmeldung ist fehlgeschlagen oder abgelaufen. Bitte erneut anmelden.';

  @override
  String get importMicrosoftPermissionError =>
      'Microsoft hat den Zugriff auf deine Aufgaben verweigert. Prüfe die Kontoberechtigungen oder kontaktiere deine Organisation.';

  @override
  String get importMicrosoftNetworkError =>
      'Nicht alle Microsoft-Aufgaben konnten gelesen werden. Es wurde nichts importiert. Prüfe die Verbindung und versuche es erneut.';

  @override
  String importWarnSourceDetails(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count Aufgaben haben Anhänge, Erinnerungseinstellungen oder einen Status, die nicht importiert werden',
      one:
          '1 Aufgabe hat Anhänge, Erinnerungseinstellungen oder einen Status, die nicht importiert werden',
    );
    return '$_temp0';
  }

  @override
  String get moreGroupOrganize => 'Organisieren';

  @override
  String get moreGroupPreferences => 'Einstellungen';

  @override
  String get moreGroupData => 'Daten';

  @override
  String get moreOn => 'An';

  @override
  String get moreOff => 'Aus';

  @override
  String moreAppearanceSummary(String theme, String palette) {
    return '$theme · $palette';
  }

  @override
  String get moreRemindersBlockedTitle => 'Erinnerungen sind blockiert';

  @override
  String get moreRemindersBlockedBody =>
      'Benachrichtigungen sind aus, daher können Erinnerungen dich nicht benachrichtigen.';

  @override
  String get moreBackupFailedTitle => 'Sicherung fehlgeschlagen';

  @override
  String get moreBackupFailedBody =>
      'Die automatische Sicherung konnte nicht gespeichert werden. Prüfe den Ordner und den freien Speicher.';

  @override
  String get moreFix => 'Beheben';

  @override
  String get moreBackupRestore => 'Sichern & Wiederherstellen';

  @override
  String get moreBackupSubtitleOff => 'Automatische Sicherung ist aus';

  @override
  String get moreBackupSubtitleFailed => 'Sicherung fehlgeschlagen';

  @override
  String get moreImportSources => 'Todoist, TickTick, OmniFocus und mehr';

  @override
  String get moreSupportTrailing => 'Optional';

  @override
  String get moreSupportTrailingSupporter => 'Unterstützer';

  @override
  String get moreAboutPrivacy => 'Info & Datenschutz';

  @override
  String get moreHowGtdWorks => 'So funktioniert GTD';

  @override
  String get moreNudgesGroup => 'Erinnerungen';

  @override
  String get moreTimingGroup => 'Zeitpunkt';

  @override
  String get moreLeadOff => 'Aus';

  @override
  String get moreLead10 => '10 Minuten vorher';

  @override
  String get moreLead30 => '30 Minuten vorher';

  @override
  String get moreLead60 => '1 Stunde vorher';

  @override
  String get moreLead1440 => '1 Tag vorher';

  @override
  String moreLeadOther(int minutes) {
    return '$minutes Minuten vorher';
  }

  @override
  String moreRestoredEntries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Einträge',
      one: '1 Eintrag',
    );
    return '$_temp0 wiederhergestellt.';
  }

  @override
  String get moreBackupEmpty =>
      'Diese Sicherung enthält keine Einträge zum Wiederherstellen.';

  @override
  String get moreCouldntOpenLink => 'Link konnte nicht geöffnet werden';

  @override
  String moreVersionBuild(String version, String build) {
    return '$version (Build $build)';
  }

  @override
  String get supportBestValue => 'Bestes Angebot';

  @override
  String get importListIntro =>
      'Wähle, wo deine Aufgaben jetzt liegen. Du siehst eine Vorschau, bevor etwas hinzugefügt wird.';

  @override
  String get importGroupDirect => 'Direkt verbinden';

  @override
  String get importGroupFile => 'Aus einer Exportdatei';

  @override
  String get importGroupOther => 'Alles andere';

  @override
  String get importSubGoogleTasks => 'Takeout · Tasks.json';

  @override
  String get importSubTodoist => 'CSV-Vorlage oder Backup-ZIP';

  @override
  String get importSubThings => 'Datenbank-ZIP oder main.sqlite';

  @override
  String get importSubTickTick => 'Backup-CSV';

  @override
  String get importSubNirvana => 'CSV- oder JSON-Export';

  @override
  String get importSubOmniFocus => 'TaskPaper-Datei oder Einfügen';

  @override
  String get importSubPlainText => 'Liste einfügen, eine Aufgabe pro Zeile';

  @override
  String get importSubApple => 'Listen auf diesem Gerät wählen';

  @override
  String get importSubMicrosoft => 'Listen und offene Aufgaben';

  @override
  String get importChipOnDevice => 'Auf dem Gerät';

  @override
  String get importChipSignIn => 'Anmelden';

  @override
  String get importBackupFooter => 'Trayzero-Backup wiederherstellen?';

  @override
  String get importBackupFooterLink => 'Backup & Wiederherstellung';

  @override
  String get importThingsDeviceIos => 'iPhone / iPad';

  @override
  String get importThingsDeviceMac => 'Mac';

  @override
  String get importCopyCode => 'Code kopieren';

  @override
  String get importCodeCopied => 'Code kopiert';

  @override
  String get importConnect => 'Verbinden';

  @override
  String get importStepGoogleTasks1 =>
      'Öffne Google Takeout und wähle nur Tasks aus.';

  @override
  String get importStepGoogleTasks2 =>
      'Exportiere als JSON und entpacke den Download.';

  @override
  String get importStepGoogleTasks3 => 'Wähle unten Tasks.json aus.';

  @override
  String get importNoteGoogleTasks =>
      'Listen bleiben in den Notizen; erledigte Aufgaben landen in Erledigt.';

  @override
  String get importStepTodoist1 =>
      'Öffne ein Projektmenü und wähle „Als Vorlage exportieren“ (CSV).';

  @override
  String get importStepTodoist2 =>
      'Oder speichere ein Backup-ZIP unter Einstellungen › Backups.';

  @override
  String get importStepTodoist3 => 'Wähle unten die Datei aus.';

  @override
  String get importStepTickTick1 =>
      'Öffne auf der TickTick-Website Einstellungen › Konto.';

  @override
  String get importStepTickTick2 =>
      'Öffne Backup & Import und tippe auf Backup erstellen (CSV).';

  @override
  String get importStepTickTick3 => 'Wähle unten die CSV-Datei aus.';

  @override
  String get importStepNirvana1 =>
      'Exportiere deine Daten in der Nirvana-Web-App als CSV oder JSON.';

  @override
  String get importStepNirvana2 => 'Wähle unten die Datei aus.';

  @override
  String get importStepOmniFocus1 => 'Wähle in OmniFocus deine Projekte aus.';

  @override
  String get importStepOmniFocus2 =>
      'Wähle Bearbeiten › Als TaskPaper kopieren.';

  @override
  String get importStepOmniFocus3 =>
      'Füge den Text unten ein oder speichere ihn als Datei und wähle sie aus.';

  @override
  String get importStepPlainText1 =>
      'Kopiere deine Aufgaben aus einer beliebigen App, eine Aufgabe pro Zeile.';

  @override
  String get importStepPlainText2 =>
      'Tippe unten auf Text einfügen und füge sie ein.';

  @override
  String get importNotePlainText =>
      'Nur einfacher Textimport. Datenbank-Exporte anderer Apps werden nicht unterstützt.';

  @override
  String get importStepApple1 => 'Tippe unten auf Listen wählen.';

  @override
  String get importStepApple2 =>
      'Erlaube den Zugriff auf Erinnerungen, wenn du gefragt wirst.';

  @override
  String get importStepApple3 =>
      'Hake die Listen an, die du importieren möchtest.';

  @override
  String get importNoteApple =>
      'Nur offene Erinnerungen werden importiert. Deine Apple-Erinnerungen bleiben unverändert.';

  @override
  String get importStepMicrosoft1 =>
      'Tippe auf Verbinden und melde dich bei Microsoft an.';

  @override
  String get importStepMicrosoft2 =>
      'Trayzero kopiert deine Listen und offenen Aufgaben.';

  @override
  String get importStepMicrosoft3 =>
      'Prüfe die Vorschau, bevor du importierst.';

  @override
  String get importNoteMicrosoft =>
      'Erneutes Importieren kann Duplikate erzeugen.';

  @override
  String get importStepThingsIos1 =>
      'Öffne in Things Einstellungen › Allgemein › Diagnose › Code eingeben und gib ein:';

  @override
  String get importStepThingsIos2 =>
      'Tippe auf Things-Datenbank senden und sichere sie in Dateien.';

  @override
  String get importStepThingsIos3 =>
      'Entpacke in Dateien die .aar und komprimiere dann den Datenbankordner zu einer ZIP-Datei.';

  @override
  String get importStepThingsIos4 => 'Wähle unten dieses ZIP aus.';

  @override
  String get importStepThingsMac1 => 'Beende Things auf deinem Mac.';

  @override
  String get importStepThingsMac2 =>
      'Kopiere Things Database.thingsdatabase aus dem Things-Ordner und komprimiere die Kopie zu ZIP.';

  @override
  String get importStepThingsMac3 =>
      'Übertrage das ZIP (oder dessen main.sqlite) auf dieses Gerät und wähle es unten aus.';

  @override
  String get importNoteThings =>
      'Wiederholungen und Erinnerungen werden nicht übernommen. Lege sie nach dem Import neu an.';

  @override
  String get importReviewTitle => 'Import prüfen';

  @override
  String importFromSource(String source) {
    return 'Aus $source';
  }

  @override
  String importTotalTasks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Aufgaben',
      one: '1 Aufgabe',
    );
    return '$_temp0';
  }

  @override
  String importActionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Aufgaben importieren',
      one: '1 Aufgabe importieren',
    );
    return '$_temp0';
  }

  @override
  String importNewExistingSummary(int newCount, int existingCount) {
    return '$newCount neu · $existingCount vorhanden';
  }

  @override
  String importShowAll(int count) {
    return 'Alle $count anzeigen';
  }

  @override
  String get importContextsAndTags => 'Kontexte & Tags';

  @override
  String importNotesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Hinweise',
      one: '1 Hinweis',
    );
    return '$_temp0';
  }

  @override
  String get notificationStatusOnTitle => 'Erinnerungen an';

  @override
  String get notificationStatusOnBody =>
      'Erinnerungen benachrichtigen dich auf diesem Gerät.';

  @override
  String get notificationStatusOffTitle => 'Erinnerungen aus';

  @override
  String get notificationStatusOffBody =>
      'Erinnerungen sind geplant, benachrichtigen dich aber erst, wenn du Benachrichtigungen erlaubst.';

  @override
  String get notificationStatusBlockedTitle => 'Erinnerungen blockiert';

  @override
  String get notificationStatusBlockedBody =>
      'Benachrichtigungen sind für Trayzero in den Systemeinstellungen ausgeschaltet. Erinnerungen benachrichtigen dich erst, wenn du sie dort wieder einschaltest.';

  @override
  String get notificationActionEnable => 'Benachrichtigungen aktivieren';

  @override
  String get notificationActionOpenSettings => 'Einstellungen öffnen';

  @override
  String get notificationPrimerTitle => 'Erinnerungen einschalten?';

  @override
  String get notificationPrimerBody =>
      'Trayzero erinnert dich an Fälligkeitstermine und deinen Wochenrückblick, indem es eine Benachrichtigung auf diesem Gerät anzeigt. Es wird nichts an einen Server gesendet – Erinnerungen werden lokal geplant.\n\nDein Gerät fragt jetzt um Erlaubnis, Benachrichtigungen anzuzeigen.';

  @override
  String get notificationPrimerNotNow => 'Nicht jetzt';

  @override
  String get notificationPrimerContinue => 'Weiter';

  @override
  String get notificationPromptFailed =>
      'Die Benachrichtigungsabfrage konnte nicht geöffnet werden.';

  @override
  String get notificationAlreadyOn => 'Erinnerungen sind bereits an.';

  @override
  String get notificationOpenedSettings =>
      'Systemeinstellungen geöffnet – schalte Benachrichtigungen für Trayzero ein.';

  @override
  String get notificationStayOff =>
      'Erinnerungen bleiben aus. Du kannst sie jederzeit unter Mehr → Erinnerungen aktivieren.';

  @override
  String get notificationNowOn => 'Erinnerungen sind an.';

  @override
  String get notificationBlocked =>
      'Benachrichtigungen sind für Trayzero blockiert.';

  @override
  String get exactAlarmSettingsFailed =>
      'Die Einstellungen für exakte Alarme konnten nicht geöffnet werden.';

  @override
  String get exactAlarmAlreadyOn =>
      'Präzises Erinnerungstiming ist bereits an.';

  @override
  String get exactAlarmNowOn => 'Präzises Erinnerungstiming ist an.';

  @override
  String get exactAlarmStaysOff =>
      'Präzises Erinnerungstiming bleibt aus. Kurzfristige Erinnerungen können sich verzögern.';

  @override
  String get attachmentRemoved => 'Anhang entfernt.';

  @override
  String get discardCaptureTitle => 'Diese Erfassung verwerfen?';

  @override
  String get discardCaptureBody => 'Der eingegebene Text geht verloren.';

  @override
  String get keepEditing => 'Weiter bearbeiten';

  @override
  String get discard => 'Verwerfen';

  @override
  String get processFiledSnackbar => 'Abgelegt.';

  @override
  String get errorLoadTitle => 'Das konnte nicht geladen werden';

  @override
  String get errorLoadBody => 'Deine Daten sind sicher. Versuche es erneut.';

  @override
  String sharedAddedToInbox(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Einträge zum Eingang hinzugefügt',
      one: '1 Eintrag zum Eingang hinzugefügt',
    );
    return '$_temp0';
  }

  @override
  String get filterByProject => 'Nach Projekt filtern';

  @override
  String get projectStatusActive => 'Aktiv';

  @override
  String get projectStatusOnHold => 'Pausiert';

  @override
  String get projectStatusSomeday => 'Irgendwann';

  @override
  String get projectStatusDone => 'Erledigt';

  @override
  String get projectStatusDropped => 'Verworfen';

  @override
  String get projectChangeStatus => 'Status ändern';

  @override
  String get projectAwaitingTooltip =>
      'Wartet – in Bewegung durch Wartend- oder geplante Einträge';

  @override
  String get projectStalledTooltip =>
      'Festgefahren – keine nächste Aktion, kein Wartend- oder geplanter Eintrag';

  @override
  String get projectStalledBanner =>
      'Festgefahren – keine nächste Aktion, kein Wartend- oder geplanter Eintrag vorhanden. Füge eine nächste Aktion hinzu, um das Projekt in Gang zu bringen.';

  @override
  String get projectAwaitingBanner =>
      'Dieses Projekt kommt nur durch Wartend- oder geplante Einträge voran. Füge eine Folgeaktion hinzu, damit es nicht ins Stocken gerät, wenn diese erledigt sind.';

  @override
  String projectNextActionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nächste Aktionen',
      one: '1 nächste Aktion',
    );
    return '$_temp0';
  }

  @override
  String projectWaitingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wartend',
      one: '1 wartend',
    );
    return '$_temp0';
  }

  @override
  String engageHiddenByFilters(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nächste Aktionen werden durch deine Filter ausgeblendet',
      one: '1 nächste Aktion wird durch deine Filter ausgeblendet',
    );
    return '$_temp0';
  }

  @override
  String get filterReset => 'Zurücksetzen';

  @override
  String onboardingSeedExisting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Du hast bereits $count Projekte.',
      one: 'Du hast bereits 1 Projekt.',
    );
    return '$_temp0';
  }

  @override
  String get purchaseErrUnavailable => 'Käufe sind derzeit nicht verfügbar.';

  @override
  String get purchaseErrProducts =>
      'Produkte konnten nicht geladen werden. Prüfe deine Verbindung und versuche es erneut.';

  @override
  String get purchaseErrOption => 'Diese Option ist derzeit nicht verfügbar.';

  @override
  String get purchaseErrNetwork =>
      'Netzwerkfehler. Prüfe deine Verbindung und versuche es erneut.';

  @override
  String get purchaseErrNotAllowed =>
      'Käufe sind auf diesem Gerät nicht erlaubt.';

  @override
  String get purchaseErrPending => 'Dein Kauf wartet auf Genehmigung.';

  @override
  String get purchaseErrAlreadyOwned =>
      'Du besitzt dies bereits – versuche „Käufe wiederherstellen“.';

  @override
  String get purchaseErrStore =>
      'Der Store hat Probleme. Bitte versuche es später erneut.';

  @override
  String get purchaseErrUnknown =>
      'Beim Kauf ist etwas schiefgelaufen. Bitte versuche es erneut.';

  @override
  String get backupErrEmpty =>
      'Das Backup ist leer – es gibt nichts zu importieren.';

  @override
  String get backupErrInvalidJson =>
      'Das ist kein gültiges JSON. Achte darauf, eine vollständige, unveränderte Trayzero-Backup-Datei auszuwählen.';

  @override
  String get backupErrNotBackup => 'Diese Datei ist kein Trayzero-Backup.';

  @override
  String get backupErrNewerVersion =>
      'Dieses Backup wurde mit einer neueren Version der App erstellt. Aktualisiere Trayzero und versuche den Import dann erneut.';

  @override
  String get backupErrUnrecognized =>
      'Diese Datei sieht nicht wie ein Trayzero-Backup aus.';

  @override
  String get backupErrInvalidData =>
      'Dieses Backup enthält ungültige Daten und kann nicht importiert werden.';

  @override
  String get backupErrReminders =>
      'Deine Daten wurden wiederhergestellt, aber einige Erinnerungen konnten nicht aktualisiert werden. Wiederhole den Import, um sie zu aktualisieren.';

  @override
  String get backupErrRestoreFailed =>
      'Beim Wiederherstellen ist etwas schiefgelaufen. Deine vorhandenen Daten wurden durch diesen Versuch nicht verändert.';

  @override
  String backupCountItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Einträge',
      one: '1 Eintrag',
    );
    return '$_temp0';
  }

  @override
  String backupCountProjects(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Projekte',
      one: '1 Projekt',
    );
    return '$_temp0';
  }

  @override
  String backupCountContexts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Kontexte',
      one: '1 Kontext',
    );
    return '$_temp0';
  }

  @override
  String backupCountAreas(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Bereiche',
      one: '1 Bereich',
    );
    return '$_temp0';
  }

  @override
  String backupCountAttachments(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Anhänge',
      one: '1 Anhang',
    );
    return '$_temp0';
  }

  @override
  String backupCountReviews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Wochenübersichten',
      one: '1 Wochenübersicht',
    );
    return '$_temp0';
  }

  @override
  String get restoreFolderTitle => 'Aus Sicherungsordner wiederherstellen';

  @override
  String get restoreFolderIntro =>
      'Wähle den Ordner, in dem Trayzero Sicherungen ablegt, z. B. einen Ordner von iCloud Drive, Google Drive oder Syncthing. Beim Wiederherstellen wird die Sicherung mit den Daten auf diesem Gerät zusammengeführt; nichts wird gelöscht.';

  @override
  String get restoreFolderChoose => 'Sicherungsordner auswählen';

  @override
  String get restoreFolderChange => 'Anderen Ordner auswählen';

  @override
  String restoreFolderFrom(String name) {
    return 'Ordner: $name';
  }

  @override
  String get restoreFolderEmpty =>
      'In diesem Ordner wurden keine Trayzero-Sicherungen gefunden.';

  @override
  String get restoreFolderFailed =>
      'Dieser Ordner konnte nicht geöffnet werden. Prüfe, ob er noch verfügbar ist, oder wähle ihn erneut aus.';

  @override
  String restoreFolderItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Einträge',
      one: '1 Eintrag',
    );
    return '$_temp0';
  }

  @override
  String get restoreFolderUnreadable => 'Diese Datei kann nicht gelesen werden';

  @override
  String get restoreFolderReading => 'Wird gelesen…';

  @override
  String get onboardingRestoreAction =>
      'Neues Gerät? Sicherung wiederherstellen';

  @override
  String folderBackupStale(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days Tagen',
      one: '1 Tag',
    );
    return 'Seit $_temp0 keine neue Sicherung.';
  }

  @override
  String get folderBackupRepairHint =>
      'Wähle den Ordner erneut aus, wenn Sicherungen nicht mehr funktionieren.';

  @override
  String moreBackupSubtitleStale(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days Tagen',
      one: '1 Tag',
    );
    return 'Seit $_temp0 keine neue Sicherung · zum Reparieren tippen';
  }

  @override
  String get backupPromptTitle => 'Aufgaben automatisch sichern';

  @override
  String get backupPromptBody =>
      'Du hast schon viel erfasst. Wähle einen Ordner in deiner eigenen Cloud oder Sync-App, und Trayzero legt dort die letzten 10 Sicherungen ab. Das ist eine Sicherung, keine Synchronisierung.';

  @override
  String get backupPromptAction => 'Ordner auswählen';

  @override
  String get backupPromptDismiss => 'Nein, danke';

  @override
  String backupCardHealthy(String date) {
    return 'Gesichert $date';
  }

  @override
  String get backupCardOffBody =>
      'Aktiviere es, um nach jeder Änderung eine Kopie in einem Ordner zu speichern.';

  @override
  String get backupCardTurnOn => 'Aktivieren';

  @override
  String get backupCardChooseAgain => 'Ordner erneut wählen';

  @override
  String get backupCardTryAgain => 'Erneut versuchen';

  @override
  String get backupGroupBackUp => 'Sichern';

  @override
  String get backupGroupRestore => 'Wiederherstellen';

  @override
  String get backupAutoTitle => 'Automatisch sichern';

  @override
  String get backupAutoSubtitle => 'Nach jeder Änderung';

  @override
  String get backupFolderTitle => 'Sicherungsordner';

  @override
  String get backupExportTitle => 'Kopie exportieren';

  @override
  String get backupExportSubtitle => 'Eine Sicherungsdatei einmalig teilen';

  @override
  String get backupRestoreTitle => 'Sicherung wiederherstellen';

  @override
  String get backupRestoreRowSubtitle => 'Aus deinem Ordner oder einer Datei';

  @override
  String get backupRestoreSheetBody =>
      'Wähle, wo deine Sicherung liegt. Du siehst, was darin ist, bevor sich etwas ändert.';

  @override
  String get backupRestoreFromFolder => 'Aus Sicherungsordner';

  @override
  String get backupRestoreFromFolderHint =>
      'Empfohlen – gespeicherte Sicherung auswählen';

  @override
  String get backupRestoreFromFile => 'Aus einer Datei';

  @override
  String get backupRestoreFromFileHint => 'Eine Trayzero-Sicherung (.json)';

  @override
  String get backupRestorePaste => 'Sicherungstext einfügen';

  @override
  String get backupFootnote =>
      'Sicherung, keine Synchronisierung – deine Cloud oder Sync-App überträgt den Ordner zwischen Geräten.';

  @override
  String get backupCardJustNow => 'Gerade eben gesichert';

  @override
  String backupCardMinutesAgo(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes Minuten',
      one: '1 Minute',
    );
    return 'Vor $_temp0 gesichert';
  }

  @override
  String backupCardHoursAgo(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours Stunden',
      one: '1 Stunde',
    );
    return 'Vor $_temp0 gesichert';
  }

  @override
  String get backupCardYesterday => 'Gestern gesichert';

  @override
  String get backupHowItWorks => 'So funktioniert’s';

  @override
  String get backupHowTitle => 'So funktioniert die Sicherung';

  @override
  String get backupHowSaves =>
      'Nach Änderungen speichert Trayzero eine JSON-Kopie deiner Daten im gewählten Ordner und behält die letzten 10 Kopien.';

  @override
  String get backupHowSync =>
      'Deine Cloud oder Sync-App (z. B. iCloud Drive, Google Drive oder Syncthing) überträgt den Ordner auf deine anderen Geräte. Trayzero selbst lädt nichts hoch und synchronisiert nichts.';

  @override
  String get backupHowMove =>
      'Um auf ein anderes Gerät umzuziehen, wähle „Sicherung wiederherstellen“ und dann „Aus Sicherungsordner“.';

  @override
  String get microphoneAccessDenied =>
      'Der Mikrofonzugriff ist deaktiviert. Erlaube ihn in den Einstellungen, um eine Sprachnotiz aufzunehmen.';

  @override
  String get filterTimeEnergy => 'Zeit & Energie';

  @override
  String get clearDate => 'Datum löschen';

  @override
  String get reorderHandle => 'Zum Sortieren ziehen';

  @override
  String get calendarConnectionTitle => 'Kalenderverbindung';

  @override
  String get calendarTogether => 'Deine Pläne an einem Ort.';

  @override
  String get calendarConnectionIntro =>
      'Sieh deine Trayzero-Termine zusammen mit deinen anderen Tagesplänen.';

  @override
  String get calendarConnect => 'Kalender verbinden';

  @override
  String get calendarScope =>
      'Nur geplante Einträge im Trayzero-Kalender werden veröffentlicht. Normale Aufgabenfristen bleiben in Trayzero.';

  @override
  String get calendarAutomatic => 'Automatische Updates';

  @override
  String get calendarAutomaticHelp =>
      'Aktualisiert beim Verwenden und erneuten Öffnen von Trayzero.';

  @override
  String get calendarPaused => 'Pausiert';

  @override
  String get calendarConnected => 'Verbunden';

  @override
  String get calendarNeedsAttention => 'Aktion erforderlich';

  @override
  String get calendarPauseHelp =>
      'Bestehende Kalenderereignisse bleiben erhalten. Änderungen warten, bis du Updates fortsetzt oder „Jetzt aktualisieren“ wählst.';

  @override
  String calendarLinkedCount(int count) {
    return '$count verknüpfte Ereignisse';
  }

  @override
  String calendarLastUpdated(String when) {
    return 'Zuletzt aktualisiert: $when';
  }

  @override
  String get calendarChangesWaiting => 'Änderungen warten auf Aktualisierung';

  @override
  String get calendarUpdateNow => 'Jetzt aktualisieren';

  @override
  String get calendarManage => 'Verbindung verwalten';

  @override
  String get calendarWorking => 'Kalenderverbindung wird aktualisiert…';

  @override
  String get calendarRestoreAccess => 'Zugriff wiederherstellen';

  @override
  String get calendarUpdateFailed =>
      'Einige Änderungen konnten nicht angewendet werden. Oben steht das letzte erfolgreiche Update. Versuche es erneut.';

  @override
  String get calendarRemovalPending => 'Entfernung ausstehend';

  @override
  String calendarRemoveFailed(int count) {
    return '$count Ereignisse konnten nicht entfernt werden. Automatische Updates sind gestoppt. Wiederhole die Entfernung oder trenne die Verbindung und behalte die übrigen Ereignisse.';
  }

  @override
  String get calendarSaveFailed =>
      'Diese Änderung konnte nicht gespeichert werden. Prüfe die Verbindungseinstellungen und versuche es erneut.';

  @override
  String get calendarNoWritable =>
      'Keine beschreibbaren Kalender verfügbar. Füge in den Kalendereinstellungen deines Geräts einen Kalender hinzu und versuche es erneut.';

  @override
  String get calendarChangeDestination => 'Ziel ändern';

  @override
  String get calendarChooseDestination => 'Kalender auswählen';

  @override
  String get calendarMoveHelp =>
      'Verknüpfte Ereignisse werden in den neuen Kalender verschoben. Andere Ereignisse bleiben unverändert. Die aktuelle Einstellung für automatische Updates bleibt erhalten.';

  @override
  String calendarSetupCount(int count) {
    return '$count geplante Einträge werden veröffentlicht. Vorhandene Verknüpfungen werden nach Möglichkeit wiederverwendet.';
  }

  @override
  String get calendarMoveEvents => 'Verknüpfte Ereignisse verschieben';

  @override
  String get calendarConnectAndAdd => 'Verbinden und Ereignisse hinzufügen';

  @override
  String get calendarDisconnect => 'Kalender trennen';

  @override
  String get calendarDisconnectQuestion => 'Kalenderverbindung trennen?';

  @override
  String get calendarDisconnectHelp =>
      'Wähle, was mit den verknüpften Kalenderereignissen geschieht. Deine Trayzero-Einträge und andere Kalenderereignisse bleiben erhalten.';

  @override
  String get calendarKeepEvents => 'Ereignisse im Kalender behalten';

  @override
  String get calendarKeepHelp =>
      'Updates stoppen und Ereignisse behalten. Beim erneuten Verbinden können die Verknüpfungen wiederverwendet werden.';

  @override
  String calendarRemoveEvents(int count) {
    return '$count verknüpfte Ereignisse entfernen';
  }

  @override
  String get calendarRemoveHelp =>
      'Nur Ereignisse dieser Verbindung entfernen. Fehlgeschlagene Entfernungen können wiederholt werden.';

  @override
  String get calendarHowItWorks => 'So funktionieren verknüpfte Ereignisse';

  @override
  String get calendarRules =>
      'Trayzero veröffentlicht geplante Kalendereinträge im gewählten Gerätekalender. Normale Aufgabenfristen sind ausgeschlossen.\n\nBearbeite Titel, Notizen, Zeiten und Wiederholungen in Trayzero. Updates können Änderungen aus deiner Kalender-App überschreiben. Ereignisse dauern derzeit eine Stunde.\n\nBeim Abschließen, Löschen oder Verschieben aus dem Kalender wird das verknüpfte Ereignis beim nächsten Update entfernt. Eine Wiederholungsserie wird auf den nächsten Termin gesetzt.\n\nPausieren behält Ereignisse und Verknüpfungen. Beim Trennen kannst du Ereignisse behalten oder entfernen. Trayzero-Einträge werden dabei nie gelöscht.';

  @override
  String get calendarBringEvents => 'Ereignisse in Trayzero übernehmen';

  @override
  String get calendarImportCopies =>
      'Kopiere ausgewählte Ereignisse in deinen Eingang oder Kalender. Kopien übernehmen keine späteren Änderungen der Originale. Originale bleiben unverändert.';

  @override
  String get calendarChooseEvents => 'Ereignisse auswählen';

  @override
  String get calendarImportSource => 'Quellkalender auswählen';

  @override
  String get calendarImportDestination =>
      'Ausgewählte Ereignisse hinzufügen zu';

  @override
  String calendarAddSelected(int count) {
    return '$count Ereignisse hinzufügen';
  }

  @override
  String get calendarNoImportEvents =>
      'Keine neuen Ereignisse zum Importieren. Bereits hinzugefügte oder verknüpfte Ereignisse sind ausgeschlossen. Zeitraum: letzte 7 Tage und nächstes Jahr.';

  @override
  String get calendarImportFailed =>
      'Kalenderereignisse konnten nicht importiert werden. Prüfe den Kalenderzugriff und versuche es erneut.';

  @override
  String get calendarDeviceHelp =>
      'Verwendet den Gerätekalender. Kein Trayzero-Konto nötig. Geteilte Kalender können für andere Personen mit Zugriff sichtbar sein.';
}
