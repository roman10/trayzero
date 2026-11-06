// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Trayzero';

  @override
  String get cancel => 'Annuler';

  @override
  String get save => 'Enregistrer';

  @override
  String get delete => 'Supprimer';

  @override
  String get add => 'Ajouter';

  @override
  String get ok => 'OK';

  @override
  String get next => 'Suivant';

  @override
  String get back => 'Retour';

  @override
  String get skip => 'Passer';

  @override
  String get done => 'Terminé';

  @override
  String get undo => 'Annuler';

  @override
  String get retry => 'Réessayer';

  @override
  String get settings => 'Réglages';

  @override
  String get enable => 'Activer';

  @override
  String get none => 'Aucun';

  @override
  String get notSet => 'Non défini';

  @override
  String get search => 'Rechercher';

  @override
  String get select => 'Sélectionner';

  @override
  String get selectAll => 'Tout';

  @override
  String get selectNone => 'Aucun';

  @override
  String get inbox => 'Boîte de réception';

  @override
  String get projects => 'Projets';

  @override
  String get review => 'Revue';

  @override
  String get more => 'Plus';

  @override
  String get navInbox => 'Boîte';

  @override
  String get navDo => 'Agir';

  @override
  String get navProjects => 'Projets';

  @override
  String get navReview => 'Revue';

  @override
  String get navMore => 'Plus';

  @override
  String get capture => 'Capturer';

  @override
  String get clarify => 'Clarifier';

  @override
  String get organize => 'Organiser';

  @override
  String get reflect => 'Réfléchir';

  @override
  String get engage => 'Agir';

  @override
  String get nextAction => 'Prochaine action';

  @override
  String get waitingFor => 'En attente';

  @override
  String get someday => 'Un jour';

  @override
  String get somedayMaybe => 'Un jour / peut-être';

  @override
  String get reference => 'Référence';

  @override
  String get calendar => 'Agenda';

  @override
  String get project => 'Projet';

  @override
  String get completed => 'Terminé';

  @override
  String get scheduled => 'Planifié';

  @override
  String get needsClarifying => 'À clarifier';

  @override
  String get howGtdWorks => 'Comment fonctionne GTD';

  @override
  String get whatIsGtd => 'Qu\'est-ce que GTD ?';

  @override
  String get onboardingPage1Title => 'Sortez-le de votre tête';

  @override
  String get onboardingPage1Body =>
      'Tout ce qui occupe votre esprit — une tâche, une idée, une inquiétude — va dans la Boîte de réception. L\'objectif est de libérer votre esprit, pas encore d\'organiser.';

  @override
  String get onboardingPage2Title => 'Clarifiez, élément par élément';

  @override
  String get onboardingPage2Body =>
      'Le flux de Traitement passe chaque élément capturé dans l\'arbre de décision GTD : est-ce actionnable ? Moins de deux minutes ? À déléguer ? Un projet ? Une prochaine action ?';

  @override
  String get onboardingPage3Title => 'Agissez quand vous avez le temps';

  @override
  String get onboardingPage3Body =>
      'L\'onglet Agir filtre les prochaines actions par contexte, énergie et temps disponible, pour savoir à tout instant ce que vous pourriez faire.';

  @override
  String get onboardingPage4Title => 'La revue, pour garder confiance';

  @override
  String get onboardingPage4Body =>
      'La Revue Hebdomadaire maintient le système honnête. Une fois par semaine, parcourez chaque liste, videz votre boîte et regardez devant vous.';

  @override
  String get onboardingSeedTitle => 'Vous êtes prêt';

  @override
  String get onboardingSeedBody =>
      'Les contextes par défaut (@téléphone, @ordinateur, @courses, @maison, @bureau, @partout, @en attente) sont déjà préparés. Vous pouvez les modifier dans les Réglages.';

  @override
  String get onboardingSeedSampleLabel => 'Ajouter un projet d\'exemple';

  @override
  String get onboardingSeedSampleSubtitle =>
      'Crée un projet de départ et quelques éléments pour que l\'app ne soit pas vide.';

  @override
  String get projectSectionActive => 'Actifs';

  @override
  String get projectSectionUnfiled => 'Non classé';

  @override
  String get projectSectionOnHold => 'En pause';

  @override
  String get sampleProjectTitle => 'Tirer le meilleur de GTD';

  @override
  String get sampleProjectOutcome =>
      'Vider la boîte de réception à zéro chaque jour et faire une revue hebdomadaire chaque vendredi.';

  @override
  String get sampleItemReadPrimer =>
      'Lire l\'introduction à GTD dans les Réglages';

  @override
  String get sampleItemEmptyEmail => 'Vider ma boîte de réception e-mail ici';

  @override
  String get sampleItemScheduleReview =>
      'Planifier une revue hebdomadaire récurrente le vendredi';

  @override
  String get seedContextPhone => '@téléphone';

  @override
  String get seedContextComputer => '@ordinateur';

  @override
  String get seedContextErrands => '@courses';

  @override
  String get seedContextHome => '@maison';

  @override
  String get seedContextOffice => '@bureau';

  @override
  String get seedContextAnywhere => '@partout';

  @override
  String get seedContextWaiting => '@en attente';

  @override
  String get onboardingFinish => 'C\'est parti';

  @override
  String get inboxEmptyTitle => 'Boîte vide';

  @override
  String get inboxEmptyMessage =>
      'Rien à clarifier. Touchez Capturer pour vider votre tête — vous traiterez plus tard.';

  @override
  String get inboxEmptyAction => 'Capturer quelque chose';

  @override
  String inboxItemsToClarify(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count éléments à clarifier',
      one: '1 élément à clarifier',
      zero: 'Aucun élément à clarifier',
    );
    return '$_temp0';
  }

  @override
  String get processInbox => 'Traiter la boîte';

  @override
  String deleteItemsConfirmTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Supprimer $count éléments ?',
      one: 'Supprimer 1 élément ?',
    );
    return '$_temp0';
  }

  @override
  String get deleteItemsConfirmBody =>
      'Cela les supprime définitivement, ainsi que leurs pièces jointes. Impossible à annuler.';

  @override
  String deletedItemsSnackbar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count éléments supprimés.',
      one: '1 élément supprimé.',
    );
    return '$_temp0';
  }

  @override
  String completedItemsSnackbar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count éléments terminés.',
      one: '1 élément terminé.',
    );
    return '$_temp0';
  }

  @override
  String filedItemsSnackbar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count éléments classés dans le projet.',
      one: '1 élément classé dans le projet.',
    );
    return '$_temp0';
  }

  @override
  String movedItemsSnackbar(int count, String destination) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count éléments déplacés vers $destination.',
      one: '1 élément déplacé vers $destination.',
    );
    return '$_temp0';
  }

  @override
  String selectionCountTitle(int count) {
    return '$count sélectionnés';
  }

  @override
  String get captureTitle => 'Vider la tête';

  @override
  String get captureHint => 'Qu\'avez-vous en tête ?';

  @override
  String get captureNotesHint => 'Notes (facultatif)';

  @override
  String get captureEmptyError => 'Écrivez quelque chose à capturer';

  @override
  String get captureSubmit => 'Ajouter à la boîte';

  @override
  String get dictate => 'Dicter';

  @override
  String get stopDictation => 'Arrêter la dictée';

  @override
  String get dictationUnavailable =>
      'La dictée est indisponible. Vous pouvez toujours saisir votre idée.';

  @override
  String get processTitle => 'Traiter la boîte';

  @override
  String get processCompleteTitle => 'Boîte vide !';

  @override
  String get processCompleteNoItems => 'Plus rien à clarifier.';

  @override
  String processCompleteStats(int filed, int doneNow, int trashed) {
    return 'Vous avez classé $filed, expédié $doneNow en moins de 2 minutes et écarté $trashed. Bien joué.';
  }

  @override
  String processStepCounter(int step, int total) {
    return 'Étape $step sur $total';
  }

  @override
  String processItemsRemaining(int count) {
    return '$count restants';
  }

  @override
  String get previousStepTooltip => 'Étape précédente';

  @override
  String get skipItemTooltip => 'Passer';

  @override
  String get actionableQuestion => 'Cela nécessite-t-il une action ?';

  @override
  String get actionableYes => 'Oui — il y a quelque chose à faire';

  @override
  String get actionableReference => 'Non — garder en référence';

  @override
  String get actionableSomeday => 'Non — un jour / peut-être';

  @override
  String get actionableTrash => 'Jeter';

  @override
  String get twoMinQuestion => 'Cela prendra-t-il moins de 2 minutes ?';

  @override
  String get twoMinYes => 'Oui — je le fais tout de suite';

  @override
  String get delegateQuestion => 'Quelqu\'un d\'autre peut-il le faire ?';

  @override
  String get waitingOnPromptTitle => 'Vous attendez après qui ?';

  @override
  String get waitingOnPromptHint => 'Nom ou système';

  @override
  String get recurrencePrompt => 'Récurrence ?';

  @override
  String get recurrenceOff => 'Pas de répétition';

  @override
  String get capturedLabel => 'CAPTURÉ';

  @override
  String get engageTitle => 'À faire maintenant';

  @override
  String get engageEmptyTitle => 'Pas encore de prochaines actions';

  @override
  String get engageEmptyMessage =>
      'Capturez quelque chose ou traitez votre boîte pour constituer votre liste de prochaines actions.';

  @override
  String get engageInlineEmpty =>
      'Pas encore de prochaines actions — capturez ou traitez votre boîte.';

  @override
  String get engageOpenInbox => 'Ouvrir la boîte';

  @override
  String get engageNoMatchTitle => 'Aucune correspondance';

  @override
  String get hardLandscape => 'Agenda';

  @override
  String get hardLandscapeSubtitle => 'à échéance aujourd\'hui ou en retard';

  @override
  String get filterAllContexts => 'Tous les contextes';

  @override
  String get filterAnyTime => 'Toute durée';

  @override
  String get filterUnder5m => '< 5 min';

  @override
  String get filterUnder15m => '< 15 min';

  @override
  String get filterUnder30m => '< 30 min';

  @override
  String get filterUnder1h => '< 1 h';

  @override
  String get filterAnyEnergy => 'Toute énergie';

  @override
  String get energyLow => 'Basse';

  @override
  String get energyMedium => 'Moyenne';

  @override
  String get energyHigh => 'Haute';

  @override
  String get projectsTitle => 'Projets';

  @override
  String get newProject => 'Nouveau projet';

  @override
  String get organizeLooseActionsTooltip => 'Organiser les actions isolées';

  @override
  String get projectsEmptyTitle => 'Pas encore de projets';

  @override
  String get projectsEmptyMessage =>
      'Un projet est tout résultat qui demande plus d\'une action. Créez-en un pour regrouper les prochaines actions liées et progresser vers un objectif clair.';

  @override
  String get projectMissingNextAction => 'Pas de prochaine action définie';

  @override
  String get organizeActionsTitle => 'Organiser les actions';

  @override
  String get organizeEmptyTitle => 'Rien d\'isolé';

  @override
  String get organizeEmptyMessage =>
      'Toutes les prochaines actions appartiennent déjà à un projet. Les nouvelles actions non assignées apparaîtront ici pour être organisées.';

  @override
  String assignToProject(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Assigner $count à un projet',
      one: 'Assigner 1 à un projet',
    );
    return '$_temp0';
  }

  @override
  String get addNextActionTitle => 'Ajouter une prochaine action';

  @override
  String get addNextActionHint => 'ex. Envoyer le calendrier à Sara';

  @override
  String get addExistingActions => 'Ajouter des actions existantes';

  @override
  String get noUnassignedActionsMessage =>
      'Pas de prochaines actions non assignées à rapatrier.';

  @override
  String addCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ajouter $count',
      one: 'Ajouter 1',
    );
    return '$_temp0';
  }

  @override
  String get editProject => 'Modifier le projet';

  @override
  String get projectName => 'Nom du projet';

  @override
  String get projectNameHint => 'ex. Lancer le nouveau site';

  @override
  String get projectNameRequired => 'Saisissez un nom de projet';

  @override
  String get areaOfFocusOptional => 'Domaine de responsabilité (facultatif)';

  @override
  String get unfiledOption => '— Non classé —';

  @override
  String get dueDate => 'Échéance';

  @override
  String get deleteProjectConfirmTitle => 'Supprimer le projet ?';

  @override
  String get deleteProjectWarning =>
      'Les éléments rattachés deviendront orphelins mais ne seront pas supprimés.';

  @override
  String get addActionFab => 'Ajouter une action';

  @override
  String get projectOutcomeHint => 'À quoi ressemble le résultat « fini » ?';

  @override
  String get outcomeSection => 'Résultat visé';

  @override
  String get nextActionsSection => 'Prochaines actions';

  @override
  String get noNextActionsMessage => 'Pas encore de prochaine action.';

  @override
  String get statusTooltip => 'Statut';

  @override
  String get reviewTitle => 'Revue';

  @override
  String get weeklyReviewCardTitle => 'Revue hebdomadaire';

  @override
  String get weeklyReviewCardSubtitle =>
      'Parcourez votre boîte, vos listes et vos projets. Le rituel qui rend le système digne de confiance.';

  @override
  String get calendarEmpty => 'Rien lié à un jour précis.';

  @override
  String get waitingForEmpty => 'Rien de délégué.';

  @override
  String get somedayEmpty => 'Aucun élément pour un jour / peut-être.';

  @override
  String get referenceEmpty => 'Aucun élément de référence.';

  @override
  String get completedThisWeek => 'Terminé cette semaine';

  @override
  String get completedThisWeekEmpty =>
      'Rien de terminé cette semaine pour l\'instant.';

  @override
  String bucketCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count éléments',
      one: '1 élément',
    );
    return '$_temp0';
  }

  @override
  String get needsReDecision => 'À redécider';

  @override
  String pastDueCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count éléments en retard',
      one: '1 élément en retard',
    );
    return '$_temp0';
  }

  @override
  String get reviewStep1Title => 'Videz votre tête';

  @override
  String get reviewStep1Body =>
      'Capturez dans la boîte tout ce qui occupe votre esprit, pour que le système reste digne de confiance.';

  @override
  String get reviewStep2Title => 'Traitez la boîte jusqu\'à zéro';

  @override
  String get reviewStep2Body =>
      'Clarifiez chaque élément capturé via l\'arbre de décision jusqu\'à ce que votre boîte soit vide.';

  @override
  String get reviewStep3Title => 'Passez en revue vos prochaines actions';

  @override
  String get reviewStep3Body =>
      'Parcourez chaque action. Faite ? Cochez-la. Périmée ? Modifiez ou supprimez. Toujours d\'actualité ? Laissez.';

  @override
  String get reviewStep4Title => 'Passez en revue votre liste d\'attente';

  @override
  String get reviewStep4Body =>
      'Quelqu\'un a-t-il répondu ? Faut-il relancer ? Actualisez ou retirez.';

  @override
  String get reviewStep5Title => 'Passez en revue chaque projet';

  @override
  String get reviewStep5Body =>
      'Passe en revue chaque résultat. Ajoute une prochaine action aux projets bloqués, mets-les en pause ou marque-les comme terminés. Les tâches en attente et planifiées comptent aussi comme une progression.';

  @override
  String get reviewStep6Title => 'Regardez les deux prochaines semaines';

  @override
  String get reviewStep6Body =>
      'Examinez vos éléments d\'agenda. Y a-t-il quelque chose que vous pouvez préparer dès maintenant ?';

  @override
  String get reviewStep7Title => 'Passez en revue un jour / peut-être';

  @override
  String get reviewStep7Body =>
      'Y a-t-il quelque chose à engager maintenant ? Transformez-le en projet ou en prochaine action.';

  @override
  String reviewStepCounter(int step, int total) {
    return 'Étape $step sur $total';
  }

  @override
  String get finishReview => 'Terminer la revue';

  @override
  String get reviewCompleteSnackbar => 'Revue hebdomadaire terminée';

  @override
  String get searchHint => 'Rechercher éléments, notes';

  @override
  String get searchMinChars => 'Saisissez au moins deux caractères';

  @override
  String get clearFilters => 'Effacer les filtres';

  @override
  String get clearSearch => 'Effacer la recherche';

  @override
  String searchNoResults(String query) {
    return 'Aucun résultat pour « $query »';
  }

  @override
  String get searchNoMatchTitle => 'Aucune correspondance';

  @override
  String get searchNoMatchMessage =>
      'Aucun résultat ne correspond aux filtres actuels. Élargissez-les ou retirez-les.';

  @override
  String get filterAllProjects => 'Tous les projets';

  @override
  String get filterCompleted => 'Terminés';

  @override
  String get statusInbox => 'Boîte';

  @override
  String get statusNext => 'Suivante';

  @override
  String get statusWaiting => 'En attente';

  @override
  String get statusSomeday => 'Un jour';

  @override
  String get statusReference => 'Référence';

  @override
  String get appearanceSection => 'Apparence';

  @override
  String get themeLabel => 'Thème';

  @override
  String get themeFollowSystem => 'Système';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get hapticFeedback => 'Retour haptique';

  @override
  String get languageLabel => 'Langue';

  @override
  String get languageFollowSystem => 'Par défaut du système';

  @override
  String get contextsLabel => 'Contextes';

  @override
  String get areasOfFocusLabel => 'Domaines de responsabilité';

  @override
  String get calendarSyncLabel => 'Synchronisation avec l\'agenda';

  @override
  String get remindersSection => 'Rappels';

  @override
  String get weeklyReviewNudge => 'Rappel de revue hebdomadaire';

  @override
  String get weeklyReviewNudgeDescription =>
      'Un petit rappel chaque vendredi à 16h.';

  @override
  String get remindBeforeDue => 'Me rappeler avant l\'échéance';

  @override
  String get remindBeforeDueOff =>
      'Désactivé · uniquement une alerte à l\'échéance';

  @override
  String get remindBeforeDueSuffix =>
      's\'applique aux éléments enregistrés à partir de maintenant';

  @override
  String get deferSurfaceLabel => 'Les éléments différés me rappellent à';

  @override
  String get deferSurfaceDescription =>
      'les éléments différés sans heure restent dans la liste toute la journée et vous rappellent à cette heure';

  @override
  String get checkingNotificationStatus =>
      'Vérification de l\'état des notifications…';

  @override
  String exportBackupError(String error) {
    return 'Impossible d\'exporter : $error';
  }

  @override
  String get weeklyBackupReminder => 'Rappel hebdomadaire de sauvegarde';

  @override
  String get weeklyBackupReminderDescription =>
      'Rappelez-moi chaque dimanche matin d\'exporter et de sauvegarder.';

  @override
  String get importConfirmTitle => 'Importer cette sauvegarde ?';

  @override
  String importConfirmBody(String sections) {
    return 'Cela ajoutera ou mettra à jour $sections.\n\nLes entrées existantes portant le même id seront écrasées par la version de la sauvegarde. Impossible à annuler.';
  }

  @override
  String get importButton => 'Importer';

  @override
  String get importFromPasteTitle => 'Coller le JSON';

  @override
  String get importFromPasteDescription =>
      'Collez le texte de la sauvegarde plutôt que de choisir un fichier.';

  @override
  String get pasteBackupHint => 'Collez le JSON ici…';

  @override
  String get crashReports => 'Envoyer les rapports de plantage';

  @override
  String get crashReportsDescription =>
      'Rapports anonymes de plantages et d\'erreurs via Sentry. Aucune donnée personnelle. Désactivé par défaut.';

  @override
  String get crashReportsEnabled =>
      'Les rapports de plantage seront envoyés au prochain lancement';

  @override
  String get crashReportsDisabled => 'Rapports de plantage désactivés';

  @override
  String get showOnboardingAgain => 'Revoir la présentation';

  @override
  String get versionLabel => 'Version';

  @override
  String get settingsFooter =>
      'Local d\'abord. Vos données restent sur cet appareil. Inspiré par la méthode Getting Things Done de David Allen.';

  @override
  String get editTitle => 'Modifier';

  @override
  String get saveError =>
      'Impossible d’enregistrer vos modifications. Réessayez.';

  @override
  String get savedIndicator => 'Enregistré';

  @override
  String get titleLabel => 'Titre';

  @override
  String get notesLabel => 'Notes';

  @override
  String get statusSection => 'Statut';

  @override
  String get contextSection => 'Contexte';

  @override
  String get energySection => 'Énergie';

  @override
  String get timeEstimateSection => 'Durée estimée';

  @override
  String get waitingOnSection => 'En attente de';

  @override
  String get waitingOnHint => 'Qui ou quoi attendez-vous ?';

  @override
  String get projectSection => 'Projet';

  @override
  String get datesSection => 'Dates';

  @override
  String get dueLabel => 'Échéance';

  @override
  String get deferUntilLabel => 'Différer jusqu\'à';

  @override
  String get repeatSection => 'Répétition';

  @override
  String get recurrenceNeedsDeferHint =>
      'Ajoutez une date de Report ci-dessus pour activer la répétition — la récurrence décale cette date.';

  @override
  String get recurrenceNeedsDueDateHint =>
      'Ajoutez une date d\'Échéance ou de Report ci-dessus pour activer la répétition — la récurrence décale cette date.';

  @override
  String get recurrenceExplanation =>
      'Quand vous terminerez cet élément, la prochaine occurrence apparaîtra avec ses dates décalées.';

  @override
  String get recurrenceNoDateNextActionError =>
      'Cet élément se répète mais n\'a pas de date de Report : le terminer ne créera pas la prochaine occurrence. Ajoutez une date de Report, ou désactivez la répétition.';

  @override
  String get recurrenceNoDateError =>
      'Cet élément se répète mais n\'a ni Échéance ni Report : le terminer ne créera pas la prochaine occurrence. Ajoutez une date, ou désactivez la répétition.';

  @override
  String get attachmentsSection => 'Pièces jointes';

  @override
  String get markComplete => 'Marquer comme terminé';

  @override
  String get reopen => 'Rouvrir';

  @override
  String get deleteItemConfirmTitle => 'Supprimer cet élément ?';

  @override
  String get deleteItemConfirmBody => 'Impossible à annuler.';

  @override
  String get completeError => 'Impossible de terminer cet élément.';

  @override
  String get reopenError => 'Impossible de rouvrir cet élément.';

  @override
  String get remindersBlockedWarning =>
      'Les rappels sont bloqués dans les réglages système — vous ne recevrez pas d\'alerte.';

  @override
  String get remindersOffWarning =>
      'Les rappels sont désactivés — vous ne recevrez pas d\'alerte.';

  @override
  String get preciseReminderOffWarning =>
      'La précision des rappels est désactivée — les rappels courts peuvent arriver en retard.';

  @override
  String get allowExactAlarms => 'Autoriser les alarmes exactes';

  @override
  String get noContextsAvailable =>
      'Pas encore de contextes — ajoutez-en dans les Réglages.';

  @override
  String get noActiveProjects => 'Pas encore de projets actifs.';

  @override
  String get attachmentPhoto => 'Photo';

  @override
  String get attachmentCamera => 'Appareil photo';

  @override
  String get attachmentVoiceMemo => 'Mémo vocal';

  @override
  String get attachmentStop => 'Arrêter';

  @override
  String get remove => 'Supprimer';

  @override
  String get imageViewerClose => 'Fermer';

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
      other: '$count mémos vocaux',
      one: '1 mémo vocal',
    );
    return '$_temp0';
  }

  @override
  String attachmentFileCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fichiers',
      one: '1 fichier',
    );
    return '$_temp0';
  }

  @override
  String get areasTitle => 'Domaines de responsabilité';

  @override
  String get newArea => 'Nouveau domaine';

  @override
  String get renameArea => 'Renommer le domaine';

  @override
  String get areasEmptyMessage =>
      'Pas encore de domaines. Les domaines sont des sphères continues de responsabilité — Santé, Carrière, Famille — qui contiennent vos projets.';

  @override
  String get areaNameHint => 'ex. Santé, Carrière, Famille';

  @override
  String deleteAreaConfirmTitle(String name) {
    return 'Supprimer « $name » ?';
  }

  @override
  String get deleteAreaWarning =>
      'Les projets de ce domaine deviendront non classés (ils ne seront pas supprimés).';

  @override
  String get contextsTitle => 'Contextes';

  @override
  String get newContext => 'Nouveau contexte';

  @override
  String get editContext => 'Modifier le contexte';

  @override
  String get contextsEmptyMessage =>
      'Pas encore de contextes. Les contextes étiquettent les actions selon où ou avec quoi elles peuvent être faites (@téléphone, @maison, @courses).';

  @override
  String get nameLabel => 'Nom';

  @override
  String get iconLabel => 'Icône';

  @override
  String get colorLabel => 'Couleur';

  @override
  String deleteContextConfirmTitle(String name) {
    return 'Supprimer $name ?';
  }

  @override
  String get deleteContextWarning =>
      'Les éléments utilisant ce contexte le perdront.';

  @override
  String get calendarSyncTitle => 'Synchronisation avec l\'agenda';

  @override
  String get calendarSyncIntro =>
      'Reflétez les éléments à échéance dans l\'agenda du système, et ramenez les événements marqués « #gtd » dans votre boîte Trayzero.';

  @override
  String get enableCalendarSync => 'Activer la synchronisation avec l\'agenda';

  @override
  String get targetCalendar => 'Agenda cible';

  @override
  String get calendarAccessDenied =>
      'L\'accès à l\'agenda est refusé. Accordez-le pour choisir un agenda cible.';

  @override
  String get grantCalendarAccess => 'Accorder l\'accès à l\'agenda';

  @override
  String get noCalendarsAvailable =>
      'Aucun agenda disponible pour le moment. Si vous venez d\'accorder l\'accès, patientez un instant puis réessayez. Vérifiez aussi que la synchronisation est activée pour votre compte dans les réglages système.';

  @override
  String get mirrorOutAction => 'Refléter les éléments → agenda';

  @override
  String get importInAction => 'Importer les événements #gtd → boîte';

  @override
  String mirrorOutSuccess(int written) {
    return '$written éléments reflétés';
  }

  @override
  String mirrorOutSuccessWithStale(int written, int removed) {
    return '$written éléments reflétés, $removed obsolètes retirés';
  }

  @override
  String importInSuccess(int count) {
    return '$count événements d\'agenda importés';
  }

  @override
  String get mirroringProgress => 'Reflet en cours…';

  @override
  String get importingProgress => 'Import en cours…';

  @override
  String get calendarSyncTip =>
      'Astuce : tapez « #gtd » n\'importe où dans le titre d\'un événement d\'agenda et il apparaîtra dans votre boîte Trayzero à la prochaine synchronisation.';

  @override
  String get gtdDiagramTitle => 'Comment fonctionne GTD';

  @override
  String get gtdDiagramSubtitle =>
      'Cinq étapes pour sortir chaque boucle ouverte de votre tête et la placer dans un système digne de confiance. Touchez une liste mise en valeur pour y accéder directement.';

  @override
  String get gtdAttribution => 'Méthode de David Allen · gettingthingsdone.com';

  @override
  String get youAreHere => 'Vous êtes ici';

  @override
  String get gtdStage1Body =>
      'Jetez dans la Boîte tout ce qui occupe votre esprit — tâches, idées, inquiétudes. Sans filtrer ni organiser, pas encore.';

  @override
  String get gtdStage2Body =>
      'Prenez un élément à la fois et décidez de ce qu\'il est. Le flux de Traitement passe chaque élément dans cet arbre de décision :';

  @override
  String get gtdStage3Body =>
      'Le résultat atterrit sur la bonne liste, pour que plus rien ne reste dans votre tête.';

  @override
  String get gtdStage3Footnote =>
      'En attente / Agenda / Un jour / Référence se trouvent dans Revue.';

  @override
  String get gtdStage4Body =>
      'Passez vos listes en revue régulièrement — surtout la Revue Hebdomadaire — pour que le système reste digne de confiance.';

  @override
  String get gtdStage5Body =>
      'Faites le travail — choisissez les actions selon le contexte, le temps, l\'énergie et la priorité, l\'esprit clair.';

  @override
  String get decisionNotActionableQ => 'Aucune action requise ?';

  @override
  String get decisionNotActionableA => 'Jeter, Un jour/peut-être ou Référence';

  @override
  String get decisionTwoMinQ => 'Moins de 2 minutes ?';

  @override
  String get decisionTwoMinA => 'Faites-le tout de suite';

  @override
  String get decisionDelegateQ => 'Quelqu\'un d\'autre devrait le faire ?';

  @override
  String get decisionDelegateA => 'Déléguer → En attente';

  @override
  String get decisionMultiStepQ => 'Plus d\'une étape ?';

  @override
  String get decisionMultiStepA => 'Faites-en un Projet';

  @override
  String get decisionOtherwiseQ => 'Sinon';

  @override
  String get decisionOtherwiseA => 'Définissez la toute prochaine action';

  @override
  String get supportTitle => 'Soutenir Trayzero';

  @override
  String get supportIntro =>
      'Trayzero est gratuit, avec toutes les fonctionnalités débloquées. S\'il vous est utile, vous pouvez participer : cela garde l\'application indépendante et sans publicité.';

  @override
  String get supportUnavailable =>
      'Les options de soutien sont indisponibles pour le moment.';

  @override
  String get supportTipHeader => 'Laisser un pourboire';

  @override
  String get supportTipSmall => 'Petit pourboire';

  @override
  String get supportTipLarge => 'Grand pourboire';

  @override
  String get supportSupporterYearly => 'Soutien — annuel';

  @override
  String supportSupporterYearlySubtitle(String price) {
    return '$price / an · meilleure offre · soutient le développement';
  }

  @override
  String get supportSupporterMonthly => 'Soutien — mensuel';

  @override
  String supportSupporterMonthlySubtitle(String price) {
    return '$price / mois · annulable à tout moment';
  }

  @override
  String supportOpeningStore(String store) {
    return 'Ouverture de $store…';
  }

  @override
  String get supportRestoring => 'Restauration des achats…';

  @override
  String get supportRestore => 'Restaurer les achats';

  @override
  String get supportRestoreSubtitle =>
      'Déjà soutien ? Restaurez sur cet appareil.';

  @override
  String get supportAutoRenewNote =>
      'Les abonnements se renouvellent automatiquement jusqu\'à leur résiliation dans les Réglages.';

  @override
  String get legalPrivacyPolicy => 'Politique de confidentialité';

  @override
  String get legalTermsOfUse => 'Conditions d\'utilisation';

  @override
  String get supportThanksTip => 'Merci infiniment ! 💙';

  @override
  String get supportThanksSupporter =>
      'Vous êtes désormais soutien — merci ! 💙';

  @override
  String get supportRestored => 'Achats restaurés. Bon retour ! 💙';

  @override
  String get supportRestoreNone => 'Aucun achat précédent trouvé.';

  @override
  String get supportBadgeYearly => 'Soutien · annuel';

  @override
  String get supportBadgeMonthly => 'Soutien · mensuel';

  @override
  String get supportBadgeGeneric => 'Soutien';

  @override
  String get supportBadgeSubtitle => 'Merci de garder Trayzero indépendant.';

  @override
  String get calendarLookupFailed =>
      'Impossible de charger les calendriers. Vérifiez la synchronisation du compte dans votre application Calendrier, puis réessayez.';

  @override
  String get calendarPermissionHelp =>
      'Si la demande ne s’affiche pas, autorisez l’accès au calendrier dans les paramètres de l’application, puis revenez ici.';

  @override
  String get calendarOpenSettings => 'Ouvrir les paramètres';

  @override
  String get calendarSettingsFailed =>
      'Ouvrez les paramètres de votre appareil et autorisez Trayzero à accéder au calendrier.';

  @override
  String get calendarSelectionUnavailable =>
      'Le calendrier sélectionné n’est plus disponible. Choisissez un autre calendrier.';

  @override
  String get appIcon => 'Icône de l’application';

  @override
  String get appIconAndroidDescription =>
      'Choisissez une icône d’accueil indépendamment de la couleur de l’app. Le lanceur peut prendre un moment pour l’actualiser ou appliquer sa propre teinte.';

  @override
  String get appIconDescription =>
      'Choisissez une icône indépendamment de la couleur de l’app. Votre appareil peut appliquer sa propre teinte. iOS affiche une alerte lors du changement.';

  @override
  String get appIconChangeFailed =>
      'Impossible de changer l’icône. Réessayez avec Trayzero ouvert.';

  @override
  String get appColor => 'Couleur de l’app';

  @override
  String get appColorDescription =>
      'Fonctionne en mode clair et sombre. Les couleurs des listes GTD gardent leur signification.';

  @override
  String get paletteAmber => 'Ambre Trayzero — Par défaut';

  @override
  String get paletteBlue => 'Bleu';

  @override
  String get paletteCyan => 'Cyan';

  @override
  String get paletteTeal => 'Bleu canard';

  @override
  String get paletteGreen => 'Vert';

  @override
  String get paletteViolet => 'Violet';

  @override
  String get paletteRose => 'Rose';

  @override
  String get appIconNotificationNote =>
      'Les notifications Android utilisent la couleur de l’icône d’application sélectionnée lors de la programmation des rappels. Les notifications existantes sont actualisées lors de leur reprogrammation. Certains appareils peuvent afficher l’icône d’origine.';

  @override
  String get appearanceSaveFailed =>
      'Impossible d’enregistrer l’apparence. Le réglage précédent a été rétabli.';

  @override
  String mirrorOutPendingCleanup(int count) {
    return 'Il reste $count événements à supprimer du calendrier. Relancez la synchronisation.';
  }

  @override
  String get weeklyReviewResume => 'Reprendre la revue hebdomadaire';

  @override
  String get weeklyReviewProgressSaved =>
      'Votre progression est conservée quand vous quittez.';

  @override
  String get weeklyReviewSaveError =>
      'Impossible d’enregistrer votre progression. Réessayez.';

  @override
  String get weeklyReviewActionError =>
      'Impossible d’enregistrer cette modification. Réessayez.';

  @override
  String get weeklyReviewListEmpty => 'Rien à revoir ici.';

  @override
  String get weeklyReviewProjectAwaiting =>
      'Le travail en attente ou planifié fait avancer ce projet.';

  @override
  String get weeklyReviewProjectMoving => 'Prochaine action définie';

  @override
  String get weeklyReviewOpenProject => 'Ouvrir le projet';

  @override
  String get processTwoMinNo => 'Non — continuer à clarifier';

  @override
  String get twoMinRule =>
      'La règle des deux minutes : si agir prend moins de temps que de noter la tâche, faites-la maintenant.';

  @override
  String get delegateYes => 'Oui — déléguer et attendre un retour';

  @override
  String get delegateNo => 'Non — c\'est à moi de le faire';

  @override
  String get singleStepQuestion => 'Est-ce une seule action concrète ?';

  @override
  String get singleStepYes => 'Oui — une seule prochaine action';

  @override
  String get singleStepProject => 'Non — c\'est un projet';

  @override
  String get projectRule =>
      'Un projet est un résultat qui nécessite plusieurs actions et peut être atteint en moins d\'un an.';

  @override
  String get deferQuestion => 'Y a-t-il un jour ou une heure précis ?';

  @override
  String get deferAsap => 'Non — le faire dès que possible';

  @override
  String get deferCalendar => 'Oui — l\'ajouter au calendrier';

  @override
  String get deferChooseDate => 'Reporter à une date';

  @override
  String get processDetailsTitle => 'Ajouter des détails';

  @override
  String get processFileNextAction => 'Classer comme prochaine action';

  @override
  String minutesShort(int minutes) {
    return '$minutes min';
  }

  @override
  String deferredUntilSummary(String date) {
    return 'Reporté au $date';
  }

  @override
  String deferredRepeatingSummary(String date, String recurrence) {
    return 'Reporté au $date · Répétition : $recurrence';
  }

  @override
  String get recurrenceDaily => 'Chaque jour';

  @override
  String get recurrenceWeekly => 'Chaque semaine';

  @override
  String get recurrenceMonthly => 'Chaque mois';

  @override
  String get recurrenceYearly => 'Chaque année';

  @override
  String get createProject => 'Créer';

  @override
  String get projectPickerTitle => 'Déplacer vers un projet';

  @override
  String get projectMoved => 'Déplacé vers un projet.';

  @override
  String get projectDetached => 'Retiré du projet.';

  @override
  String get noProject => 'Aucun projet';

  @override
  String get decreaseRepeatInterval => 'Réduire l’intervalle de répétition';

  @override
  String get increaseRepeatInterval => 'Augmenter l’intervalle de répétition';

  @override
  String get decreaseRepeatCount => 'Réduire le nombre de répétitions';

  @override
  String get increaseRepeatCount => 'Augmenter le nombre de répétitions';

  @override
  String get repeatOn => 'Répéter le';

  @override
  String get repeatMonthlyOn => 'Le';

  @override
  String get repeatDayOfMonth => 'Jour du mois';

  @override
  String get repeatDayOfWeek => 'Jour de la semaine';

  @override
  String get repeatFirst => 'Premier';

  @override
  String get repeatSecond => 'Deuxième';

  @override
  String get repeatThird => 'Troisième';

  @override
  String get repeatFourth => 'Quatrième';

  @override
  String get repeatFifth => 'Cinquième';

  @override
  String get repeatLast => 'Dernier';

  @override
  String get repeatEnds => 'Se termine';

  @override
  String get repeatNever => 'Jamais';

  @override
  String get repeatOnDate => 'À une date';

  @override
  String get repeatAfterCount => 'Après un nombre de fois';

  @override
  String get weekdayListSeparator => ', ';

  @override
  String get dueToday => 'À faire aujourd’hui';

  @override
  String get reschedule => 'Replanifier';

  @override
  String get complete => 'Terminer';

  @override
  String get drop => 'Abandonner';

  @override
  String get trash => 'Corbeille';

  @override
  String itemEnergyLabel(String energy) {
    return 'Énergie : $energy';
  }

  @override
  String waitingOnPerson(String person) {
    return 'En attente de $person';
  }

  @override
  String dueOverdueDays(int days) {
    return 'En retard · $days j';
  }

  @override
  String dueTodayAt(String time) {
    return 'À faire aujourd’hui, $time';
  }

  @override
  String selectItem(String title) {
    return 'Sélectionner $title';
  }

  @override
  String markItemDone(String title) {
    return 'Marquer $title comme terminé';
  }

  @override
  String repeatLastOnDate(String date) {
    return 'Dernière fois le $date';
  }

  @override
  String repeatAfterOccurrences(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Après $count occurrences',
      one: 'Après 1 occurrence',
    );
    return '$_temp0';
  }

  @override
  String recurrenceUntilSummary(String pattern, String date) {
    return '$pattern · jusqu’au $date';
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
    return '$cadence : $weekdays';
  }

  @override
  String recurrenceOnNthWeekday(
    String cadence,
    String ordinal,
    String weekday,
  ) {
    String _temp0 = intl.Intl.selectLogic(ordinal, {
      'first': 'premier',
      'second': 'deuxième',
      'third': 'troisième',
      'fourth': 'quatrième',
      'fifth': 'cinquième',
      'other': 'dernier',
    });
    return '$cadence, le $_temp0 $weekday';
  }

  @override
  String repeatEveryDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tous les $count jours',
      one: 'Chaque jour',
    );
    return '$_temp0';
  }

  @override
  String repeatEveryWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Toutes les $count semaines',
      one: 'Chaque semaine',
    );
    return '$_temp0';
  }

  @override
  String repeatEveryMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tous les $count mois',
      one: 'Chaque mois',
    );
    return '$_temp0';
  }

  @override
  String repeatEveryYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tous les $count ans',
      one: 'Chaque année',
    );
    return '$_temp0';
  }

  @override
  String get captureAddContinue => 'Ajouter et continuer';

  @override
  String captureAddedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count éléments ajoutés à la boîte de réception',
      one: '1 élément ajouté à la boîte de réception',
    );
    return '$_temp0';
  }

  @override
  String get folderBackupChoose => 'Choisir le dossier de sauvegarde';

  @override
  String get folderBackupSaving => 'Sauvegarde en cours…';

  @override
  String get folderBackupOff =>
      'Les sauvegardes automatiques sont désactivées.';

  @override
  String get folderBackupNever => 'Aucune sauvegarde réussie pour le moment.';

  @override
  String folderBackupLastSuccess(String date) {
    return 'Dernière sauvegarde : $date';
  }

  @override
  String get folderBackupFailed =>
      'Échec de la sauvegarde. Vérifiez l’accès au dossier et l’espace libre, puis réessayez.';

  @override
  String get folderBackupHistoryWarning =>
      'Sauvegarde enregistrée, mais les anciennes sauvegardes n’ont pas pu être supprimées.';

  @override
  String get folderBackupNow => 'Sauvegarder maintenant';

  @override
  String get doViewToday => 'Aujourd’hui';

  @override
  String get doViewNextActions => 'Prochaines actions';

  @override
  String get todayPlanCardTitle => 'Planifiez votre journée';

  @override
  String get todayPlanCardBody =>
      'Choisissez ce sur quoi vous vous concentrerez aujourd’hui. Cela prend environ deux minutes.';

  @override
  String get todayPlanAction => 'Planifier aujourd’hui';

  @override
  String todayCarryOverLine(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count éléments d’avant demandent une décision',
      one: '1 élément d’avant demande une décision',
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
      other: '$count terminés aujourd’hui',
      one: '1 terminé aujourd’hui',
    );
    return '$_temp0';
  }

  @override
  String get todayEmptyTitle => 'Rien en focus pour l’instant';

  @override
  String get todayEmptyMessage =>
      'Ajoutez une étoile aux prochaines actions pour vous y engager aujourd’hui, ou planifiez votre journée.';

  @override
  String get focusAddTooltip => 'Ajouter à Aujourd’hui';

  @override
  String get focusRemoveTooltip => 'Retirer d’Aujourd’hui';

  @override
  String focusAddItem(String title) {
    return 'Ajouter $title à Aujourd’hui';
  }

  @override
  String focusRemoveItem(String title) {
    return 'Retirer $title d’Aujourd’hui';
  }

  @override
  String get focusError =>
      'Impossible de mettre à jour Aujourd’hui. Réessayez.';

  @override
  String get planTodayIntro =>
      'Ajoutez une étoile à ce que vous vous engagez à faire aujourd’hui. Restez bref : tout le reste reste dans vos listes.';

  @override
  String get planSectionCarryOver => 'Des jours précédents';

  @override
  String get planCarryOverHint =>
      'Les éléments que vous ne gardez pas retournent dans leurs listes quand vous commencez votre journée.';

  @override
  String get planKeepAll => 'Tout garder';

  @override
  String get planSectionCalendar => 'Agenda';

  @override
  String get planOnToday => 'Dans Aujourd’hui';

  @override
  String get planSectionWaiting => 'Relances en attente';

  @override
  String get planSectionAvailable => 'Disponibles dès aujourd’hui';

  @override
  String get planEmpty =>
      'Rien à planifier pour l’instant. Traitez votre boîte de réception pour créer des prochaines actions.';

  @override
  String planFocusedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count en focus aujourd’hui',
      one: '1 en focus aujourd’hui',
      zero: 'Rien en focus pour l’instant',
    );
    return '$_temp0';
  }

  @override
  String get planStartDay => 'Commencer ma journée';

  @override
  String get planDoneSnackbar => 'Votre journée est planifiée';

  @override
  String planClearedSnackbar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Journée planifiée · $count éléments de retour dans leurs listes',
      one: 'Journée planifiée · 1 élément de retour dans sa liste',
    );
    return '$_temp0';
  }

  @override
  String get planSaveError => 'Impossible d’enregistrer votre plan. Réessayez.';

  @override
  String get captureTipDates =>
      'Astuce : ajoutez @contexte, #projet, +étiquette ou une date en anglais comme « tomorrow ».';

  @override
  String get captureTipSigils =>
      'Astuce : ajoutez @contexte, #projet ou +étiquette.';

  @override
  String startsOnDate(String date) {
    return 'Débute $date';
  }

  @override
  String dueOnDate(String date) {
    return 'Échéance $date';
  }

  @override
  String captureChipProject(String name) {
    return 'Projet : $name';
  }

  @override
  String get captureKeepAsText => 'Garder comme texte';

  @override
  String get captureRecognized => 'Détails reconnus';

  @override
  String deferUseStartDate(String date) {
    return 'Commencer le $date';
  }

  @override
  String deferUseDueDate(String date) {
    return 'Dans l’agenda le $date';
  }

  @override
  String weeklyReviewProjectInactive(int days) {
    return 'Aucune activité depuis $days+ jours';
  }

  @override
  String get weeklyReviewMarkReviewed => 'Marquer comme revu';

  @override
  String get weeklyReviewReviewed => 'Revu';

  @override
  String weeklyReviewLastReviewed(String date) {
    return 'Revu pour la dernière fois le $date';
  }

  @override
  String get weeklyReviewNeverReviewed => 'Pas encore revu';

  @override
  String weeklyReviewReviewedProgress(int done, int total) {
    return '$done sur $total revus';
  }

  @override
  String get importFromApp => 'Importer depuis une autre app';

  @override
  String get importSourcePlainText => 'Texte brut / TaskPaper';

  @override
  String get importHintTodoist =>
      'Menu du projet › Exporter comme modèle › CSV, ou un ZIP de sauvegarde depuis Paramètres › Sauvegardes.';

  @override
  String get importHintTickTick =>
      'Sur le site web TickTick : Paramètres › Compte › Sauvegarde et importation › Générer une sauvegarde (CSV).';

  @override
  String get importHintNirvana =>
      'Dans l’app web Nirvana, exportez vos données en CSV ou JSON.';

  @override
  String get importHintOmniFocus =>
      'Sélectionnez des projets, puis Édition › Copier en TaskPaper. Collez ici ou enregistrez un fichier.';

  @override
  String get importHintPlainText =>
      'Things : copiez les tâches et collez-les ici, une par ligne. Import de texte simple uniquement ; les exports de base de données Things ne sont pas pris en charge.';

  @override
  String get importChooseFile => 'Choisir un fichier';

  @override
  String get importPasteText => 'Coller du texte';

  @override
  String get importPasteTitle => 'Coller des tâches';

  @override
  String get importPasteHint =>
      'Une tâche par ligne. Indentez des tâches sous une ligne finissant par « : » pour créer un projet.';

  @override
  String get importPasteContinue => 'Aperçu';

  @override
  String get importPreviewNothingYet => 'Rien n’a encore été ajouté.';

  @override
  String get importPreviewProjects => 'Projets';

  @override
  String get importProjectNew => 'Nouveau';

  @override
  String get importProjectExisting => 'Complète l’existant';

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
    return 'Nouveaux : $names';
  }

  @override
  String importContextsExisting(String names) {
    return 'Déjà présents : $names';
  }

  @override
  String get importGoodToKnow => 'Bon à savoir';

  @override
  String importWarnCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tâches terminées ou abandonnées ignorées',
      one: '1 tâche terminée ou abandonnée ignorée',
    );
    return '$_temp0';
  }

  @override
  String importWarnCalendar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count actions avec échéance vont dans le Calendrier',
      one: '1 action avec échéance va dans le Calendrier',
    );
    return '$_temp0';
  }

  @override
  String importWarnDates(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dates illisibles sont conservées dans les notes',
      one: '1 date illisible est conservée dans les notes',
    );
    return '$_temp0';
  }

  @override
  String importWarnRepeats(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count règles de répétition sont conservées dans les notes',
      one: '1 règle de répétition est conservée dans les notes',
    );
    return '$_temp0';
  }

  @override
  String importWarnSubtasks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sous-tâches deviennent des actions distinctes',
      one: '1 sous-tâche devient une action distincte',
    );
    return '$_temp0';
  }

  @override
  String importWarnSections(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tâches notent leur section dans leurs notes',
      one: '1 tâche note sa section dans ses notes',
    );
    return '$_temp0';
  }

  @override
  String importWarnNotImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count tâches avaient une priorité, un drapeau ou un responsable non importé',
      one:
          '1 tâche avait une priorité, un drapeau ou un responsable non importé',
    );
    return '$_temp0';
  }

  @override
  String importWarnUnreadable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lignes sans titre ignorées',
      one: '1 ligne sans titre ignorée',
    );
    return '$_temp0';
  }

  @override
  String importDoneTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tâches ajoutées',
      one: '1 tâche ajoutée',
    );
    return '$_temp0';
  }

  @override
  String get importDoneBody =>
      'Changé d’avis ? Annuler retire exactement ce que cet import a ajouté, rien d’autre.';

  @override
  String get importUndo => 'Annuler l’import';

  @override
  String get importFinish => 'Terminé';

  @override
  String get importUndoneTitle => 'Import annulé';

  @override
  String get importUndoneBody =>
      'Tout ce que cet import avait ajouté a été retiré.';

  @override
  String get importRemindersFailed =>
      'Certains rappels n’ont pas encore pu être programmés. Ils le seront à la prochaine ouverture de l’app.';

  @override
  String importErrorUnrecognized(String source) {
    return 'Ceci ne ressemble pas à un export $source. Vérifiez les étapes et réessayez.';
  }

  @override
  String get importErrorNoTasks => 'Aucune tâche ouverte à importer.';

  @override
  String get importErrorUnreadable =>
      'Impossible de lire ce fichier. Choisissez un export texte, CSV ou ZIP.';

  @override
  String get importErrorWrite => 'L’import a échoué. Rien n’a été ajouté.';

  @override
  String get importErrorUndo => 'Impossible d’annuler l’import. Réessayez.';

  @override
  String get tagsAndPeopleLabel => 'Étiquettes et personnes';

  @override
  String get tagsEmptyMessage =>
      'Les étiquettes marquent des éléments dans toutes les listes. Marquez une étiquette comme personne pour tenir un agenda des sujets à aborder avec elle. Astuce : tapez +étiquette lors de la capture.';

  @override
  String get newTag => 'Nouvelle étiquette';

  @override
  String get editTag => 'Modifier l’étiquette';

  @override
  String get tagPersonSwitch => 'Personne';

  @override
  String get tagPersonSwitchHint => 'Tient un agenda des sujets à aborder';

  @override
  String tagOpenItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count éléments ouverts',
      one: '1 élément ouvert',
      zero: 'Aucun élément ouvert',
    );
    return '$_temp0';
  }

  @override
  String deleteTagConfirmTitle(String name) {
    return 'Supprimer « $name » ?';
  }

  @override
  String deleteTagConfirmBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count éléments ouverts l’utilisent. Ils sont conservés ; seule l’étiquette est retirée.',
      one:
          '1 élément ouvert l’utilise. Il est conservé ; seule l’étiquette est retirée.',
      zero: 'Aucun élément ouvert ne l’utilise.',
    );
    return '$_temp0';
  }

  @override
  String get tagMergeTitle => 'Fusionner les étiquettes ?';

  @override
  String tagMergeBody(String source, String target) {
    return '« $target » existe déjà. Fusionner « $source » avec elle ?';
  }

  @override
  String get tagMergeAction => 'Fusionner';

  @override
  String get addTag => 'Ajouter une étiquette';

  @override
  String get tagPickerHint => 'Chercher ou créer une étiquette';

  @override
  String tagCreate(String name) {
    return 'Créer « $name »';
  }

  @override
  String tagCreatePerson(String name) {
    return 'Créer la personne « $name »';
  }

  @override
  String get tagsSection => 'Étiquettes';

  @override
  String tagChipSemantics(String name) {
    return 'Étiquette : $name';
  }

  @override
  String personChipSemantics(String name) {
    return 'Personne : $name';
  }

  @override
  String removeTagTooltip(String name) {
    return 'Retirer $name';
  }

  @override
  String moreTags(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count autres étiquettes',
      one: '1 autre étiquette',
    );
    return '$_temp0';
  }

  @override
  String get filterTag => 'Étiquette';

  @override
  String get filterAnyTag => 'Toutes les étiquettes';

  @override
  String get agendasTitle => 'Agendas';

  @override
  String agendasPeopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personnes',
      one: '1 personne',
    );
    return '$_temp0';
  }

  @override
  String agendaAddHint(String name) {
    return 'Ajouter un sujet à aborder avec $name';
  }

  @override
  String get agendaAddTooltip => 'Ajouter à l’agenda';

  @override
  String agendaEmpty(String name) {
    return 'Rien à aborder avec $name pour l’instant.';
  }

  @override
  String get agendaNotFound => 'Cette personne n’existe plus.';

  @override
  String captureChipNewTag(String name) {
    return 'Nouvelle étiquette : $name';
  }

  @override
  String get importHintGoogleTasks =>
      'Google Takeout › sélectionnez Tasks › exportez en JSON. Décompressez le téléchargement et choisissez Tasks.json. Les listes restent dans les notes ; les tâches terminées vont dans Terminé.';

  @override
  String get importDuplicateWarning =>
      'Ces mêmes données ont déjà été importées sur cet appareil. Les importer à nouveau créera des doublons. Annulez si vous ne souhaitez pas une autre copie.';

  @override
  String get importHintThings =>
      'Choisissez main.sqlite ou un ZIP du dossier de la base Things 3 exportée. iPhone/iPad : Réglages › Général › Diagnostics › Saisir un code › 491348 › Envoyer la base. Enregistrez dans Fichiers, décompressez .aar puis compressez le dossier en ZIP. Mac : quittez Things avant la copie. Recréez répétitions et rappels.';

  @override
  String importWarnDetailsInNotes(int count) {
    return '$count tâches conservent les détails de listes de contrôle ou de domaines dans les notes';
  }

  @override
  String get importWarnThingsRecurrence =>
      'Les répétitions Things ne sont pas importées. Les modèles sont ignorés ; recréez les répétitions des tâches importées.';

  @override
  String importWarnSourceReminders(int count) {
    return '$count réglages de rappels de la source ne sont pas importés';
  }

  @override
  String get importAppleHint =>
      'Choisissez des listes de rappels sur cet appareil. Seuls les rappels non terminés sont importés.';

  @override
  String get importAppleChooseLists => 'Choisir des listes';

  @override
  String get importAppleReloadLists => 'Recharger les listes';

  @override
  String get importAppleNoLists =>
      'Aucune liste de rappels n’est disponible sur cet appareil.';

  @override
  String get importAppleDenied =>
      'L’accès aux rappels est désactivé. Autorisez Trayzero dans les Réglages iOS, puis réessayez.';

  @override
  String get importAppleUnavailable =>
      'Impossible de lire les rappels Apple. Réessayez.';

  @override
  String get importAppleListsChanged =>
      'Une liste sélectionnée n’est plus disponible. Rechargez les listes et sélectionnez à nouveau.';

  @override
  String get importAppleLimits =>
      'Vos rappels Apple restent inchangés. Les tags Apple, drapeaux, pièces jointes, structure des sous-tâches, priorités et alertes d’origine ne sont pas copiés. Un nouvel import peut créer des doublons.';

  @override
  String get importHintMicrosoftTodo =>
      'Connectez-vous pour copier vos listes et tâches en cours. Vérifiez avant d’importer ; un nouvel import peut créer des doublons.';

  @override
  String get importMicrosoftUnavailable =>
      'L’import depuis Microsoft To Do n’est pas disponible dans cette version.';

  @override
  String get importMicrosoftSignInError =>
      'La connexion Microsoft a échoué ou a expiré. Veuillez vous reconnecter.';

  @override
  String get importMicrosoftPermissionError =>
      'Microsoft a refusé l’accès à vos tâches. Vérifiez les autorisations ou contactez votre organisation.';

  @override
  String get importMicrosoftNetworkError =>
      'Impossible de lire toutes les tâches Microsoft. Rien n’a été importé. Vérifiez votre connexion et réessayez.';

  @override
  String importWarnSourceDetails(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count tâches comportent des pièces jointes, des réglages de rappel ou des statuts qui ne sont pas importés',
      one:
          '1 tâche comporte des pièces jointes, des réglages de rappel ou un statut qui ne sont pas importés',
    );
    return '$_temp0';
  }

  @override
  String get moreGroupOrganize => 'Organiser';

  @override
  String get moreGroupPreferences => 'Préférences';

  @override
  String get moreGroupData => 'Données';

  @override
  String get moreOn => 'Activé';

  @override
  String get moreOff => 'Désactivé';

  @override
  String moreAppearanceSummary(String theme, String palette) {
    return '$theme · $palette';
  }

  @override
  String get moreRemindersBlockedTitle => 'Les rappels sont bloqués';

  @override
  String get moreRemindersBlockedBody =>
      'Les notifications sont désactivées : les rappels ne peuvent pas vous alerter.';

  @override
  String get moreBackupFailedTitle => 'Échec de la sauvegarde';

  @override
  String get moreBackupFailedBody =>
      'La sauvegarde automatique n\'a pas pu être enregistrée. Vérifiez le dossier et l\'espace libre.';

  @override
  String get moreFix => 'Corriger';

  @override
  String get moreBackupRestore => 'Sauvegarde et restauration';

  @override
  String get moreBackupSubtitleOff =>
      'La sauvegarde automatique est désactivée';

  @override
  String get moreBackupSubtitleFailed => 'Échec de la sauvegarde';

  @override
  String get moreImportSources => 'Todoist, TickTick, OmniFocus et plus';

  @override
  String get moreSupportTrailing => 'Facultatif';

  @override
  String get moreSupportTrailingSupporter => 'Soutien';

  @override
  String get moreAboutPrivacy => 'À propos et confidentialité';

  @override
  String get moreHowGtdWorks => 'Comment fonctionne GTD';

  @override
  String get moreNudgesGroup => 'Rappels récurrents';

  @override
  String get moreTimingGroup => 'Horaires';

  @override
  String get moreLeadOff => 'Désactivé';

  @override
  String get moreLead10 => '10 minutes avant';

  @override
  String get moreLead30 => '30 minutes avant';

  @override
  String get moreLead60 => '1 heure avant';

  @override
  String get moreLead1440 => '1 jour avant';

  @override
  String moreLeadOther(int minutes) {
    return '$minutes minutes avant';
  }

  @override
  String moreRestoredEntries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entrées restaurées',
      one: '1 entrée restaurée',
    );
    return '$_temp0.';
  }

  @override
  String get moreBackupEmpty =>
      'Cette sauvegarde ne contient aucune entrée à restaurer.';

  @override
  String get moreCouldntOpenLink => 'Impossible d\'ouvrir le lien';

  @override
  String moreVersionBuild(String version, String build) {
    return '$version (build $build)';
  }

  @override
  String get supportBestValue => 'Meilleure offre';

  @override
  String get importListIntro =>
      'Choisissez où se trouvent vos tâches. Vous verrez un aperçu avant tout ajout.';

  @override
  String get importGroupDirect => 'Connexion directe';

  @override
  String get importGroupFile => 'Depuis un fichier d\'export';

  @override
  String get importGroupOther => 'Autre chose';

  @override
  String get importSubGoogleTasks => 'Takeout · Tasks.json';

  @override
  String get importSubTodoist => 'Modèle CSV ou ZIP de sauvegarde';

  @override
  String get importSubThings => 'ZIP de la base ou main.sqlite';

  @override
  String get importSubTickTick => 'CSV de sauvegarde';

  @override
  String get importSubNirvana => 'Export CSV ou JSON';

  @override
  String get importSubOmniFocus => 'Fichier TaskPaper ou collage';

  @override
  String get importSubPlainText => 'Collez une liste, une tâche par ligne';

  @override
  String get importSubApple => 'Choisissez des listes sur cet appareil';

  @override
  String get importSubMicrosoft => 'Listes et tâches ouvertes';

  @override
  String get importChipOnDevice => 'Sur l\'appareil';

  @override
  String get importChipSignIn => 'Connexion';

  @override
  String get importBackupFooter => 'Restaurer une sauvegarde Trayzero ?';

  @override
  String get importBackupFooterLink => 'Sauvegarde et restauration';

  @override
  String get importThingsDeviceIos => 'iPhone / iPad';

  @override
  String get importThingsDeviceMac => 'Mac';

  @override
  String get importCopyCode => 'Copier le code';

  @override
  String get importCodeCopied => 'Code copié';

  @override
  String get importConnect => 'Connecter';

  @override
  String get importStepGoogleTasks1 =>
      'Ouvrez Google Takeout et sélectionnez uniquement Tasks.';

  @override
  String get importStepGoogleTasks2 =>
      'Exportez-le en JSON et décompressez le téléchargement.';

  @override
  String get importStepGoogleTasks3 => 'Choisissez Tasks.json ci-dessous.';

  @override
  String get importNoteGoogleTasks =>
      'Les listes restent dans les notes ; les tâches terminées vont dans Terminé.';

  @override
  String get importStepTodoist1 =>
      'Ouvrez le menu d\'un projet et choisissez Exporter comme modèle (CSV).';

  @override
  String get importStepTodoist2 =>
      'Ou enregistrez un ZIP de sauvegarde depuis Réglages › Sauvegardes.';

  @override
  String get importStepTodoist3 => 'Choisissez le fichier ci-dessous.';

  @override
  String get importStepTickTick1 =>
      'Sur le site TickTick, ouvrez Paramètres › Compte.';

  @override
  String get importStepTickTick2 =>
      'Ouvrez Sauvegarde et import, puis touchez Générer une sauvegarde (CSV).';

  @override
  String get importStepTickTick3 => 'Choisissez le CSV ci-dessous.';

  @override
  String get importStepNirvana1 =>
      'Dans l\'application web Nirvana, exportez vos données en CSV ou JSON.';

  @override
  String get importStepNirvana2 => 'Choisissez le fichier ci-dessous.';

  @override
  String get importStepOmniFocus1 =>
      'Dans OmniFocus, sélectionnez vos projets.';

  @override
  String get importStepOmniFocus2 =>
      'Choisissez Édition › Copier comme TaskPaper.';

  @override
  String get importStepOmniFocus3 =>
      'Collez le texte ci-dessous, ou enregistrez-le en fichier et choisissez-le.';

  @override
  String get importStepPlainText1 =>
      'Copiez vos tâches depuis n\'importe quelle app, une tâche par ligne.';

  @override
  String get importStepPlainText2 =>
      'Touchez Coller le texte ci-dessous et collez-les.';

  @override
  String get importNotePlainText =>
      'Import de texte basique uniquement. Les exports de base de données d\'autres apps ne sont pas pris en charge.';

  @override
  String get importStepApple1 => 'Touchez Choisir des listes ci-dessous.';

  @override
  String get importStepApple2 =>
      'Autorisez l\'accès à Rappels lorsqu\'on vous le demande.';

  @override
  String get importStepApple3 => 'Cochez les listes à importer.';

  @override
  String get importNoteApple =>
      'Seuls les rappels ouverts sont importés. Vos rappels Apple restent inchangés.';

  @override
  String get importStepMicrosoft1 =>
      'Touchez Connecter et connectez-vous à Microsoft.';

  @override
  String get importStepMicrosoft2 =>
      'Trayzero copie vos listes et tâches ouvertes.';

  @override
  String get importStepMicrosoft3 => 'Vérifiez l\'aperçu avant d\'importer.';

  @override
  String get importNoteMicrosoft =>
      'Importer à nouveau peut créer des doublons.';

  @override
  String get importStepThingsIos1 =>
      'Dans Things, ouvrez Réglages › Général › Diagnostics › Saisir le code, puis saisissez :';

  @override
  String get importStepThingsIos2 =>
      'Touchez Envoyer la base de données Things et enregistrez-la dans Fichiers.';

  @override
  String get importStepThingsIos3 =>
      'Dans Fichiers, décompressez le .aar puis compressez le dossier de la base en ZIP.';

  @override
  String get importStepThingsIos4 => 'Choisissez ce ZIP ci-dessous.';

  @override
  String get importStepThingsMac1 => 'Quittez Things sur votre Mac.';

  @override
  String get importStepThingsMac2 =>
      'Copiez Things Database.thingsdatabase depuis le dossier Things, puis compressez la copie en ZIP.';

  @override
  String get importStepThingsMac3 =>
      'Transférez le ZIP (ou son main.sqlite) sur cet appareil et choisissez-le ci-dessous.';

  @override
  String get importNoteThings =>
      'Les répétitions et rappels ne sont pas transférés. Recréez-les après l\'import.';

  @override
  String get importReviewTitle => 'Vérifier l’import';

  @override
  String importFromSource(String source) {
    return 'Depuis $source';
  }

  @override
  String importTotalTasks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tâches',
      one: '1 tâche',
    );
    return '$_temp0';
  }

  @override
  String importActionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Importer $count tâches',
      one: 'Importer 1 tâche',
    );
    return '$_temp0';
  }

  @override
  String importNewExistingSummary(int newCount, int existingCount) {
    return '$newCount nouveaux · $existingCount existants';
  }

  @override
  String importShowAll(int count) {
    return 'Tout afficher ($count)';
  }

  @override
  String get importContextsAndTags => 'Contextes et étiquettes';

  @override
  String importNotesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count remarques',
      one: '1 remarque',
    );
    return '$_temp0';
  }

  @override
  String get notificationStatusOnTitle => 'Rappels activés';

  @override
  String get notificationStatusOnBody =>
      'Les rappels vous alerteront sur cet appareil.';

  @override
  String get notificationStatusOffTitle => 'Rappels désactivés';

  @override
  String get notificationStatusOffBody =>
      'Les rappels sont programmés mais ne vous alerteront pas tant que vous n’aurez pas autorisé les notifications.';

  @override
  String get notificationStatusBlockedTitle => 'Rappels bloqués';

  @override
  String get notificationStatusBlockedBody =>
      'Les notifications sont désactivées pour Trayzero dans les réglages du système. Les rappels ne vous alerteront pas tant que vous ne les aurez pas réactivées là-bas.';

  @override
  String get notificationActionEnable => 'Activer les notifications';

  @override
  String get notificationActionOpenSettings => 'Ouvrir les Réglages';

  @override
  String get notificationPrimerTitle => 'Activer les rappels ?';

  @override
  String get notificationPrimerBody =>
      'Trayzero vous rappelle les échéances et votre revue hebdomadaire en affichant une notification sur cet appareil. Rien n’est envoyé à un serveur : les rappels sont programmés localement.\n\nVotre appareil va maintenant demander l’autorisation d’afficher des notifications.';

  @override
  String get notificationPrimerNotNow => 'Pas maintenant';

  @override
  String get notificationPrimerContinue => 'Continuer';

  @override
  String get notificationPromptFailed =>
      'Impossible d’ouvrir la demande de notification.';

  @override
  String get notificationAlreadyOn => 'Les rappels sont déjà activés.';

  @override
  String get notificationOpenedSettings =>
      'Réglages système ouverts : activez les notifications pour Trayzero.';

  @override
  String get notificationStayOff =>
      'Les rappels restent désactivés. Vous pouvez les activer à tout moment dans Plus → Rappels.';

  @override
  String get notificationNowOn => 'Les rappels sont activés.';

  @override
  String get notificationBlocked =>
      'Les notifications sont bloquées pour Trayzero.';

  @override
  String get exactAlarmSettingsFailed =>
      'Impossible d’ouvrir les réglages des alarmes exactes.';

  @override
  String get exactAlarmAlreadyOn =>
      'La précision des rappels est déjà activée.';

  @override
  String get exactAlarmNowOn => 'La précision des rappels est activée.';

  @override
  String get exactAlarmStaysOff =>
      'La précision des rappels reste désactivée. Les rappels à court terme peuvent être retardés.';

  @override
  String get attachmentRemoved => 'Pièce jointe supprimée.';

  @override
  String get discardCaptureTitle => 'Abandonner cette capture ?';

  @override
  String get discardCaptureBody => 'Le texte saisi sera perdu.';

  @override
  String get keepEditing => 'Continuer à modifier';

  @override
  String get discard => 'Abandonner';

  @override
  String get processFiledSnackbar => 'Classé.';

  @override
  String get errorLoadTitle => 'Impossible de charger ce contenu';

  @override
  String get errorLoadBody => 'Vos données sont en sécurité. Réessayez.';

  @override
  String sharedAddedToInbox(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count éléments ajoutés à la boîte de réception',
      one: '1 élément ajouté à la boîte de réception',
    );
    return '$_temp0';
  }

  @override
  String get filterByProject => 'Filtrer par projet';

  @override
  String get projectStatusActive => 'Actif';

  @override
  String get projectStatusOnHold => 'En pause';

  @override
  String get projectStatusSomeday => 'Un jour';

  @override
  String get projectStatusDone => 'Terminé';

  @override
  String get projectStatusDropped => 'Abandonné';

  @override
  String get projectChangeStatus => 'Changer le statut';

  @override
  String get projectAwaitingTooltip =>
      'En attente : avance via des éléments en attente ou planifiés';

  @override
  String get projectStalledTooltip =>
      'Bloqué : aucune prochaine action, ni élément en attente ou planifié';

  @override
  String get projectStalledBanner =>
      'Bloqué : aucune prochaine action, ni élément en attente ou planifié. Ajoutez une prochaine action pour relancer le projet.';

  @override
  String get projectAwaitingBanner =>
      'Ce projet n’avance que via des éléments en attente ou planifiés. Pensez à ajouter une prochaine action de suivi pour qu’il ne cale pas quand ils seront réglés.';

  @override
  String projectNextActionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count prochaines actions',
      one: '1 prochaine action',
    );
    return '$_temp0';
  }

  @override
  String projectWaitingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count en attente',
      one: '1 en attente',
    );
    return '$_temp0';
  }

  @override
  String engageHiddenByFilters(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count prochaines actions sont masquées par vos filtres',
      one: '1 prochaine action est masquée par vos filtres',
    );
    return '$_temp0';
  }

  @override
  String get filterReset => 'Réinitialiser';

  @override
  String onboardingSeedExisting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vous avez déjà $count projets.',
      one: 'Vous avez déjà 1 projet.',
    );
    return '$_temp0';
  }

  @override
  String get purchaseErrUnavailable =>
      'Les achats ne sont pas disponibles pour le moment.';

  @override
  String get purchaseErrProducts =>
      'Impossible de charger les produits. Vérifiez votre connexion et réessayez.';

  @override
  String get purchaseErrOption =>
      'Cette option n’est pas disponible pour le moment.';

  @override
  String get purchaseErrNetwork =>
      'Erreur réseau. Vérifiez votre connexion et réessayez.';

  @override
  String get purchaseErrNotAllowed =>
      'Les achats ne sont pas autorisés sur cet appareil.';

  @override
  String get purchaseErrPending => 'Votre achat est en attente d’approbation.';

  @override
  String get purchaseErrAlreadyOwned =>
      'Vous le possédez déjà : essayez « Restaurer les achats ».';

  @override
  String get purchaseErrStore =>
      'La boutique rencontre un problème. Réessayez plus tard.';

  @override
  String get purchaseErrUnknown =>
      'Un problème est survenu lors de l’achat. Réessayez.';

  @override
  String get backupErrEmpty => 'La sauvegarde est vide : rien à importer.';

  @override
  String get backupErrInvalidJson =>
      'Ce n’est pas un JSON valide. Vérifiez que vous avez choisi un fichier de sauvegarde Trayzero complet et non modifié.';

  @override
  String get backupErrNotBackup =>
      'Ce fichier n’est pas une sauvegarde Trayzero.';

  @override
  String get backupErrNewerVersion =>
      'Cette sauvegarde a été créée par une version plus récente de l’app. Mettez à jour Trayzero, puis réessayez l’import.';

  @override
  String get backupErrUnrecognized =>
      'Ce fichier ne ressemble pas à une sauvegarde Trayzero.';

  @override
  String get backupErrInvalidData =>
      'Cette sauvegarde contient des données invalides et ne peut pas être importée.';

  @override
  String get backupErrReminders =>
      'Vos données ont été restaurées, mais certains rappels n’ont pas pu être actualisés. Relancez l’import pour les actualiser.';

  @override
  String get backupErrRestoreFailed =>
      'Un problème est survenu pendant la restauration. Vos données existantes n’ont pas été modifiées par cette tentative.';

  @override
  String backupCountItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count éléments',
      one: '1 élément',
    );
    return '$_temp0';
  }

  @override
  String backupCountProjects(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count projets',
      one: '1 projet',
    );
    return '$_temp0';
  }

  @override
  String backupCountContexts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contextes',
      one: '1 contexte',
    );
    return '$_temp0';
  }

  @override
  String backupCountAreas(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count domaines',
      one: '1 domaine',
    );
    return '$_temp0';
  }

  @override
  String backupCountAttachments(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pièces jointes',
      one: '1 pièce jointe',
    );
    return '$_temp0';
  }

  @override
  String backupCountReviews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count revues',
      one: '1 revue',
    );
    return '$_temp0';
  }

  @override
  String get restoreFolderTitle => 'Restaurer depuis le dossier de sauvegarde';

  @override
  String get restoreFolderIntro =>
      'Choisissez le dossier où Trayzero enregistre les sauvegardes, par exemple un dossier géré par iCloud Drive, Google Drive ou Syncthing. La restauration fusionne la sauvegarde avec les données de cet appareil ; rien de ce qui s\'y trouve déjà n\'est supprimé.';

  @override
  String get restoreFolderChoose => 'Choisir le dossier de sauvegarde';

  @override
  String get restoreFolderChange => 'Choisir un autre dossier';

  @override
  String restoreFolderFrom(String name) {
    return 'Dossier : $name';
  }

  @override
  String get restoreFolderEmpty =>
      'Aucune sauvegarde Trayzero trouvée dans ce dossier.';

  @override
  String get restoreFolderFailed =>
      'Impossible d\'ouvrir ce dossier. Vérifiez qu\'il est toujours disponible ou choisissez-le à nouveau.';

  @override
  String restoreFolderItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count éléments',
      one: '1 élément',
    );
    return '$_temp0';
  }

  @override
  String get restoreFolderUnreadable => 'Impossible de lire ce fichier';

  @override
  String get restoreFolderReading => 'Lecture…';

  @override
  String get onboardingRestoreAction =>
      'Vous venez d\'un autre appareil ? Restaurez une sauvegarde';

  @override
  String folderBackupStale(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days jours',
      one: '1 jour',
    );
    return 'Aucune sauvegarde récente depuis $_temp0.';
  }

  @override
  String get folderBackupRepairHint =>
      'Choisissez à nouveau le dossier si les sauvegardes ne fonctionnent plus.';

  @override
  String moreBackupSubtitleStale(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days jours',
      one: '1 jour',
    );
    return 'Aucune sauvegarde récente depuis $_temp0 · touchez pour réparer';
  }

  @override
  String get backupPromptTitle => 'Sauvegardez vos tâches automatiquement';

  @override
  String get backupPromptBody =>
      'Vous avez déjà beaucoup capturé. Choisissez un dossier de votre propre cloud ou application de synchronisation et Trayzero y conservera les 10 dernières sauvegardes. C\'est une sauvegarde, pas une synchronisation.';

  @override
  String get backupPromptAction => 'Choisir un dossier';

  @override
  String get backupPromptDismiss => 'Non merci';

  @override
  String backupCardHealthy(String date) {
    return 'Sauvegardé $date';
  }

  @override
  String get backupCardOffBody =>
      'Activez pour enregistrer une copie dans un dossier après chaque modification.';

  @override
  String get backupCardTurnOn => 'Activer';

  @override
  String get backupCardChooseAgain => 'Rechoisir le dossier';

  @override
  String get backupCardTryAgain => 'Réessayer';

  @override
  String get backupGroupBackUp => 'Sauvegarde';

  @override
  String get backupGroupRestore => 'Restauration';

  @override
  String get backupAutoTitle => 'Sauvegarder automatiquement';

  @override
  String get backupAutoSubtitle => 'Après chaque modification';

  @override
  String get backupFolderTitle => 'Dossier de sauvegarde';

  @override
  String get backupExportTitle => 'Exporter une copie';

  @override
  String get backupExportSubtitle =>
      'Partager un fichier de sauvegarde une fois';

  @override
  String get backupRestoreTitle => 'Restaurer une sauvegarde';

  @override
  String get backupRestoreRowSubtitle => 'Depuis votre dossier ou un fichier';

  @override
  String get backupRestoreSheetBody =>
      'Choisissez où se trouve votre sauvegarde. Vous verrez son contenu avant tout changement.';

  @override
  String get backupRestoreFromFolder => 'Depuis le dossier de sauvegarde';

  @override
  String get backupRestoreFromFolderHint =>
      'Recommandé : choisissez une sauvegarde enregistrée';

  @override
  String get backupRestoreFromFile => 'Depuis un fichier';

  @override
  String get backupRestoreFromFileHint => 'Une sauvegarde Trayzero (.json)';

  @override
  String get backupRestorePaste => 'Coller le texte de la sauvegarde';

  @override
  String get backupFootnote =>
      'Sauvegarde, pas synchronisation : votre cloud ou app de synchronisation transporte le dossier d\'un appareil à l\'autre.';

  @override
  String get backupCardJustNow => 'Sauvegardé à l’instant';

  @override
  String backupCardMinutesAgo(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minutes',
      one: '1 minute',
    );
    return 'Sauvegardé il y a $_temp0';
  }

  @override
  String backupCardHoursAgo(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours heures',
      one: '1 heure',
    );
    return 'Sauvegardé il y a $_temp0';
  }

  @override
  String get backupCardYesterday => 'Sauvegardé hier';

  @override
  String get backupHowItWorks => 'Comment ça marche';

  @override
  String get backupHowTitle => 'Comment fonctionne la sauvegarde';

  @override
  String get backupHowSaves =>
      'Après chaque modification, Trayzero enregistre une copie JSON de vos données dans le dossier choisi et conserve les 10 dernières copies.';

  @override
  String get backupHowSync =>
      'Votre cloud ou application de synchronisation (par exemple iCloud Drive, Google Drive ou Syncthing) transmet ce dossier à vos autres appareils. Trayzero n’envoie ni ne synchronise rien lui-même.';

  @override
  String get backupHowMove =>
      'Pour passer à un autre appareil, choisissez « Restaurer une sauvegarde », puis « Depuis le dossier de sauvegarde ».';

  @override
  String get microphoneAccessDenied =>
      'L’accès au microphone est désactivé. Autorisez-le dans les Réglages pour enregistrer un mémo vocal.';

  @override
  String get filterTimeEnergy => 'Durée et énergie';

  @override
  String get clearDate => 'Effacer la date';

  @override
  String get reorderHandle => 'Faire glisser pour réorganiser';

  @override
  String get calendarConnectionTitle => 'Connexion au calendrier';

  @override
  String get calendarTogether => 'Vos projets, réunis.';

  @override
  String get calendarConnectionIntro =>
      'Retrouvez vos engagements Trayzero aux côtés du reste de votre journée.';

  @override
  String get calendarConnect => 'Connecter un calendrier';

  @override
  String get calendarScope =>
      'Seuls les éléments planifiés du Calendrier Trayzero sont publiés. Les échéances ordinaires restent dans Trayzero.';

  @override
  String get calendarAutomatic => 'Mises à jour automatiques';

  @override
  String get calendarAutomaticHelp =>
      'Mise à jour pendant l’utilisation de Trayzero et à sa réouverture.';

  @override
  String get calendarPaused => 'En pause';

  @override
  String get calendarConnected => 'Connecté';

  @override
  String get calendarNeedsAttention => 'Action requise';

  @override
  String get calendarPauseHelp =>
      'Les événements existants sont conservés. Les modifications attendront la reprise des mises à jour ou le choix de Mettre à jour.';

  @override
  String calendarLinkedCount(int count) {
    return '$count événements liés';
  }

  @override
  String calendarLastUpdated(String when) {
    return 'Dernière mise à jour : $when';
  }

  @override
  String get calendarChangesWaiting => 'Modifications en attente';

  @override
  String get calendarUpdateNow => 'Mettre à jour';

  @override
  String get calendarManage => 'Gérer la connexion';

  @override
  String get calendarWorking => 'Mise à jour de la connexion…';

  @override
  String get calendarRestoreAccess => 'Rétablir l’accès';

  @override
  String get calendarUpdateFailed =>
      'Certaines modifications n’ont pas pu être appliquées. La dernière mise à jour réussie apparaît ci-dessus. Réessayez.';

  @override
  String get calendarRemovalPending => 'Suppression en attente';

  @override
  String calendarRemoveFailed(int count) {
    return '$count événements n’ont pas pu être supprimés. Les mises à jour automatiques sont arrêtées. Réessayez ou déconnectez en conservant les événements restants.';
  }

  @override
  String get calendarSaveFailed =>
      'Impossible d’enregistrer cette modification. Vérifiez les paramètres de connexion et réessayez.';

  @override
  String get calendarNoWritable =>
      'Aucun calendrier modifiable disponible. Ajoutez-en un dans les réglages de calendrier de votre appareil, puis réessayez.';

  @override
  String get calendarChangeDestination => 'Changer de destination';

  @override
  String get calendarChooseDestination => 'Choisir un calendrier';

  @override
  String get calendarMoveHelp =>
      'Les événements liés seront déplacés vers le nouveau calendrier. Les autres resteront en place. Le réglage actuel des mises à jour automatiques sera conservé.';

  @override
  String calendarSetupCount(int count) {
    return '$count éléments planifiés seront publiés. Les liens existants seront réutilisés si possible.';
  }

  @override
  String get calendarMoveEvents => 'Déplacer les événements liés';

  @override
  String get calendarConnectAndAdd => 'Connecter et ajouter les événements';

  @override
  String get calendarDisconnect => 'Déconnecter le calendrier';

  @override
  String get calendarDisconnectQuestion => 'Déconnecter le calendrier ?';

  @override
  String get calendarDisconnectHelp =>
      'Choisissez le sort des événements liés. Vos éléments Trayzero et les autres événements seront conservés.';

  @override
  String get calendarKeepEvents =>
      'Conserver les événements dans mon calendrier';

  @override
  String get calendarKeepHelp =>
      'Arrêter les mises à jour et conserver les événements. Une reconnexion peut réutiliser ces liens.';

  @override
  String calendarRemoveEvents(int count) {
    return 'Supprimer $count événements liés';
  }

  @override
  String get calendarRemoveHelp =>
      'Supprimer uniquement les événements liés à cette connexion. Les suppressions échouées restent disponibles pour réessayer.';

  @override
  String get calendarHowItWorks => 'Fonctionnement des événements liés';

  @override
  String get calendarRules =>
      'Trayzero publie les éléments planifiés du Calendrier dans le calendrier choisi de votre appareil. Les échéances ordinaires sont exclues.\n\nModifiez les titres, notes, horaires et répétitions dans Trayzero. Une mise à jour peut remplacer les modifications de votre application de calendrier. Les événements durent actuellement une heure.\n\nTerminer, mettre à la corbeille ou retirer un élément du Calendrier supprime son événement à la prochaine mise à jour. Une série récurrente passe à l’occurrence suivante.\n\nLa pause conserve les événements et leurs liens. La déconnexion permet de conserver ou supprimer les événements liés. Elle ne supprime jamais les éléments Trayzero.';

  @override
  String get calendarBringEvents => 'Importer des événements dans Trayzero';

  @override
  String get calendarImportCopies =>
      'Choisissez des événements à copier dans votre Boîte de réception ou Calendrier. Les copies ne suivent pas les modifications ultérieures des originaux. Les originaux restent inchangés.';

  @override
  String get calendarChooseEvents => 'Choisir des événements';

  @override
  String get calendarImportSource => 'Choisir le calendrier source';

  @override
  String get calendarImportDestination =>
      'Ajouter les événements sélectionnés à';

  @override
  String calendarAddSelected(int count) {
    return 'Ajouter $count événements';
  }

  @override
  String get calendarNoImportEvents =>
      'Aucun nouvel événement à importer. Ceux déjà ajoutés ou liés à Trayzero sont exclus. Période : les 7 derniers jours et l’année à venir.';

  @override
  String get calendarImportFailed =>
      'Impossible d’importer les événements. Vérifiez l’accès au calendrier et réessayez.';

  @override
  String get calendarDeviceHelp =>
      'Utilise le calendrier de l’appareil. Aucun compte Trayzero requis. Un calendrier partagé peut être visible par les autres personnes qui y ont accès.';
}
