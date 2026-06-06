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
  String get edit => 'Bearbeiten';

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
  String get rename => 'Umbenennen';

  @override
  String get inbox => 'Posteingang';

  @override
  String get doVerb => 'Erledigen';

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
  String get actionableQuestion => 'Ist das umsetzbar?';

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
  String get twoMinNo => 'Nein';

  @override
  String get delegateQuestion => 'Kann das jemand anderes tun?';

  @override
  String get waitingOnPromptTitle => 'Auf wen wartest du?';

  @override
  String get waitingOnPromptHint => 'Person oder System';

  @override
  String get multiStepQuestion => 'Braucht es mehr als einen Schritt?';

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
  String get engageNoMatchMessage =>
      'Nichts passt zu den Filtern. Lockere die Filter oder lösche sie.';

  @override
  String get hardLandscape => 'Terminkalender';

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
  String projectActionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Aufgaben',
      one: '1 Aufgabe',
    );
    return '$_temp0';
  }

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
  String get projectMissingNextActionError =>
      'Kein nächster Schritt definiert. Jedes aktive Projekt sollte mindestens einen haben.';

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
      'Kläre jedes gesammelte Element mit dem Entscheidungsbaum, bis der Eingang leer ist.';

  @override
  String get reviewStep3Title => 'Nächste Schritte prüfen';

  @override
  String get reviewStep3Body =>
      'Geh alle Schritte durch. Erledigt? Abhaken. Veraltet? Bearbeiten oder löschen. Immer noch aktuell? Stehen lassen.';

  @override
  String get reviewStep4Title => 'Warten-auf-Liste prüfen';

  @override
  String get reviewStep4Body =>
      'Gibt es Rückmeldungen? Musst du nachhaken? Aktualisieren oder entfernen.';

  @override
  String get reviewStep5Title => 'Projekte prüfen';

  @override
  String get reviewStep5Body =>
      'Jedes Projekt sollte aktiv, pausiert oder erledigt sein — und jedes aktive Projekt braucht einen nächsten Schritt.';

  @override
  String get reviewStep6Title => 'Blick auf die nächsten zwei Wochen';

  @override
  String get reviewStep6Body =>
      'Check deinen Kalender. Gibt es etwas, das du jetzt schon vorbereiten kannst?';

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
  String get themeFollowSystem => 'System folgen';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get hapticFeedback => 'Haptisches Feedback';

  @override
  String get organizationSection => 'Organisation';

  @override
  String get contextsLabel => 'Kontexte';

  @override
  String get areasOfFocusLabel => 'Fokusbereiche';

  @override
  String get areasOfFocusDescription =>
      'Gruppiere Projekte nach langfristigen Lebensbereichen.';

  @override
  String get calendarSyncLabel => 'Kalender-Sync';

  @override
  String get calendarSyncDescription =>
      'Spiegle fällige Aufgaben in deinen Systemkalender.';

  @override
  String get remindersSection => 'Erinnerungen';

  @override
  String get weeklyReviewNudge => 'Reminder Wöchentlicher Rückblick';

  @override
  String get weeklyReviewNudgeDescription =>
      'Ein sanfter Stups jeden Freitag um 16:00.';

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
      'Status der Mitteilungen wird geprüft…';

  @override
  String get dataSection => 'Daten';

  @override
  String get exportBackup => 'Backup exportieren';

  @override
  String get exportBackupDescriptionIos =>
      'Teile eine JSON-Kopie. Speichere sie z.B. in der iCloud Drive als Backup.';

  @override
  String get exportBackupDescriptionAndroid =>
      'Teile eine JSON-Kopie. Speichere sie z.B. in Google Drive als Backup.';

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
  String get importBackup => 'Backup importieren';

  @override
  String get importBackupDescription =>
      'Stelle ein Trayzero-Backup wieder her oder importiere einen Google Tasks Export.';

  @override
  String get importConfirmTitle => 'Dieses Backup importieren?';

  @override
  String importConfirmBody(String sections) {
    return 'Es werden $sections hinzugefügt oder aktualisiert.\n\nBestehende Einträge mit gleicher ID werden überschrieben. Dies kann nicht rückgängig gemacht werden.';
  }

  @override
  String get importButton => 'Importieren';

  @override
  String get importSourceSheetTitle => 'Backup importieren';

  @override
  String get importFromFileTitle => 'Backup-Datei wählen';

  @override
  String get importFromFileDescription =>
      'Empfohlen — ein Trayzero-.json oder Google Takeout Tasks.json.';

  @override
  String get importFromPasteTitle => 'JSON einfügen';

  @override
  String get importFromPasteDescription => 'Backup-Text direkt hier einfügen.';

  @override
  String get pasteBackupHint => 'JSON hier einfügen…';

  @override
  String get privacySection => 'Privatsphäre';

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
  String get aboutSection => 'Info';

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
  String get decisionNotActionableQ => 'Nicht umsetzbar?';

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
  String get supportSummaryDefault =>
      'Gib dem Entwickler ein Trinkgeld oder werde Unterstützer';

  @override
  String get supportSummarySupporter =>
      'Danke, dass du Trayzero unterstützt 💙';

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
    return '$price / Jahr · bestes Angebot · schaltet Unterstützer-Vorteile frei';
  }

  @override
  String get supportSupporterMonthly => 'Unterstützer — monatlich';

  @override
  String supportSupporterMonthlySubtitle(String price) {
    return '$price / Monat · jederzeit kündbar';
  }

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
}
