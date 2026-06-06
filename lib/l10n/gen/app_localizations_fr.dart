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
  String get edit => 'Modifier';

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
  String get rename => 'Renommer';

  @override
  String get inbox => 'Boîte de réception';

  @override
  String get doVerb => 'Agir';

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
  String get actionableQuestion => 'Est-ce actionnable ?';

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
  String get twoMinNo => 'Non';

  @override
  String get delegateQuestion => 'Quelqu\'un d\'autre peut-il le faire ?';

  @override
  String get waitingOnPromptTitle => 'Vous attendez après qui ?';

  @override
  String get waitingOnPromptHint => 'Nom ou système';

  @override
  String get multiStepQuestion => 'Cela demande plus d\'une étape ?';

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
  String get engageNoMatchMessage =>
      'Aucune action ne correspond aux filtres actuels. Élargissez-les ou retirez-les.';

  @override
  String get hardLandscape => 'Engagements fixes';

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
  String get projectMissingNextActionError =>
      'Pas de prochaine action définie. Tout projet actif devrait en avoir au moins une.';

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
      'Chaque projet doit être actif, en pause ou terminé — et chaque projet actif doit posséder au moins une prochaine action.';

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
  String get themeFollowSystem => 'Suivre le système';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get hapticFeedback => 'Retour haptique';

  @override
  String get organizationSection => 'Organisation';

  @override
  String get contextsLabel => 'Contextes';

  @override
  String get areasOfFocusLabel => 'Domaines de responsabilité';

  @override
  String get areasOfFocusDescription =>
      'Regroupez vos projets par sphères de responsabilité continues.';

  @override
  String get calendarSyncLabel => 'Synchronisation avec l\'agenda';

  @override
  String get calendarSyncDescription =>
      'Reflétez les éléments à échéance dans l\'agenda du système.';

  @override
  String get remindersSection => 'Rappels';

  @override
  String get weeklyReviewNudge => 'Rappel de revue hebdomadaire';

  @override
  String get weeklyReviewNudgeDescription =>
      'Un petit rappel chaque vendredi à 16 h.';

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
  String get dataSection => 'Données';

  @override
  String get exportBackup => 'Exporter la sauvegarde';

  @override
  String get exportBackupDescriptionIos =>
      'Partagez une copie JSON. Enregistrez-la sur un service cloud (par exemple Fichiers → iCloud Drive) en guise de sauvegarde.';

  @override
  String get exportBackupDescriptionAndroid =>
      'Partagez une copie JSON. Enregistrez-la sur un service cloud (par exemple Google Drive) en guise de sauvegarde.';

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
  String get importBackup => 'Importer une sauvegarde';

  @override
  String get importBackupDescription =>
      'Restaurez une sauvegarde Trayzero, ou importez un export Google Tasks (Takeout).';

  @override
  String get importConfirmTitle => 'Importer cette sauvegarde ?';

  @override
  String importConfirmBody(String sections) {
    return 'Cela ajoutera ou mettra à jour $sections.\n\nLes entrées existantes portant le même id seront écrasées par la version de la sauvegarde. Impossible à annuler.';
  }

  @override
  String get importButton => 'Importer';

  @override
  String get importSourceSheetTitle => 'Importer une sauvegarde';

  @override
  String get importFromFileTitle => 'Choisir un fichier de sauvegarde';

  @override
  String get importFromFileDescription =>
      'Recommandé — un .json Trayzero ou un Tasks.json de Google Takeout.';

  @override
  String get importFromPasteTitle => 'Coller le JSON';

  @override
  String get importFromPasteDescription =>
      'Collez le texte de la sauvegarde plutôt que de choisir un fichier.';

  @override
  String get pasteBackupHint => 'Collez le JSON ici…';

  @override
  String get privacySection => 'Confidentialité';

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
  String get aboutSection => 'À propos';

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
  String get decisionNotActionableQ => 'Non actionnable ?';

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
  String get supportSummaryDefault =>
      'Laissez un pourboire au développeur ou devenez soutien';

  @override
  String get supportSummarySupporter => 'Merci de soutenir Trayzero 💙';

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
    return '$price / an · meilleure offre · débloque les avantages soutien';
  }

  @override
  String get supportSupporterMonthly => 'Soutien — mensuel';

  @override
  String supportSupporterMonthlySubtitle(String price) {
    return '$price / mois · annulable à tout moment';
  }

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
}
