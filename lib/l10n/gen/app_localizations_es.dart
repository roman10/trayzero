// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Trayzero';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get delete => 'Eliminar';

  @override
  String get add => 'Añadir';

  @override
  String get ok => 'Aceptar';

  @override
  String get next => 'Siguiente';

  @override
  String get back => 'Atrás';

  @override
  String get skip => 'Omitir';

  @override
  String get done => 'Hecho';

  @override
  String get undo => 'Deshacer';

  @override
  String get retry => 'Reintentar';

  @override
  String get settings => 'Ajustes';

  @override
  String get enable => 'Activar';

  @override
  String get none => 'Ninguno';

  @override
  String get notSet => 'Sin definir';

  @override
  String get search => 'Buscar';

  @override
  String get select => 'Seleccionar';

  @override
  String get selectAll => 'Todo';

  @override
  String get selectNone => 'Ninguno';

  @override
  String get inbox => 'Bandeja de entrada';

  @override
  String get projects => 'Proyectos';

  @override
  String get review => 'Revisar';

  @override
  String get more => 'Más';

  @override
  String get navInbox => 'Bandeja';

  @override
  String get navDo => 'Hacer';

  @override
  String get navProjects => 'Proyectos';

  @override
  String get navReview => 'Revisar';

  @override
  String get navMore => 'Más';

  @override
  String get capture => 'Capturar';

  @override
  String get clarify => 'Aclarar';

  @override
  String get organize => 'Organizar';

  @override
  String get reflect => 'Revisar';

  @override
  String get engage => 'Hacer';

  @override
  String get nextAction => 'Siguiente acción';

  @override
  String get waitingFor => 'En espera';

  @override
  String get someday => 'Algún día';

  @override
  String get somedayMaybe => 'Algún día / Tal vez';

  @override
  String get reference => 'Referencia';

  @override
  String get calendar => 'Calendario';

  @override
  String get project => 'Proyecto';

  @override
  String get completed => 'Completado';

  @override
  String get scheduled => 'Programado';

  @override
  String get needsClarifying => 'Por aclarar';

  @override
  String get howGtdWorks => 'Flujo GTD';

  @override
  String get whatIsGtd => '¿Qué es GTD?';

  @override
  String get onboardingPage1Title => 'Sácatelo de la cabeza';

  @override
  String get onboardingPage1Body =>
      'Cualquier cosa que ocupe tu mente —una tarea, una idea, una preocupación— va a la Bandeja de entrada. El objetivo es liberar la mente, no organizar todavía.';

  @override
  String get onboardingPage2Title => 'Aclara, paso a paso';

  @override
  String get onboardingPage2Body =>
      'El proceso te guía por cada elemento: ¿es accionable? ¿Toma menos de dos minutos? ¿Delegar? ¿Es un proyecto? ¿Una siguiente acción?';

  @override
  String get onboardingPage3Title => 'Haz lo que importa';

  @override
  String get onboardingPage3Body =>
      'La pestaña Hacer filtra tus acciones por contexto, energía y tiempo. Así siempre sabes qué puedes estar haciendo ahora mismo.';

  @override
  String get onboardingPage4Title => 'Revisa para confiar';

  @override
  String get onboardingPage4Body =>
      'La Revisión Semanal mantiene tu sistema al día. Una vez por semana, repasa tus listas, vacía la bandeja y mira hacia adelante.';

  @override
  String get onboardingSeedTitle => 'Todo listo';

  @override
  String get onboardingSeedBody =>
      'Hemos preparado contextos comunes (@teléfono, @ordenador, @recados, @casa, @oficina, @cualquier sitio, @en espera). Puedes personalizarlos en Ajustes.';

  @override
  String get onboardingSeedSampleLabel => 'Crear proyecto de ejemplo';

  @override
  String get onboardingSeedSampleSubtitle =>
      'Añade un proyecto inicial para que no empieces de cero.';

  @override
  String get projectSectionActive => 'Activos';

  @override
  String get projectSectionUnfiled => 'Sin archivar';

  @override
  String get projectSectionOnHold => 'En pausa';

  @override
  String get sampleProjectTitle => 'Aprovecha GTD al máximo';

  @override
  String get sampleProjectOutcome =>
      'Vaciar la bandeja de entrada a cero cada día y hacer una revisión semanal cada viernes.';

  @override
  String get sampleItemReadPrimer => 'Leer la introducción a GTD en Ajustes';

  @override
  String get sampleItemEmptyEmail =>
      'Vaciar aquí mi bandeja de entrada de correo';

  @override
  String get sampleItemScheduleReview =>
      'Programar una revisión semanal recurrente los viernes';

  @override
  String get seedContextPhone => '@teléfono';

  @override
  String get seedContextComputer => '@ordenador';

  @override
  String get seedContextErrands => '@recados';

  @override
  String get seedContextHome => '@casa';

  @override
  String get seedContextOffice => '@oficina';

  @override
  String get seedContextAnywhere => '@cualquier sitio';

  @override
  String get seedContextWaiting => '@en espera';

  @override
  String get onboardingFinish => '¡Vamos!';

  @override
  String get inboxEmptyTitle => 'Bandeja vacía';

  @override
  String get inboxEmptyMessage =>
      'Nada que aclarar. Usa Capturar para volcar lo que tengas en mente —lo procesarás después.';

  @override
  String get inboxEmptyAction => 'Capturar algo';

  @override
  String inboxItemsToClarify(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementos por aclarar',
      one: '1 elemento por aclarar',
      zero: 'Sin elementos por aclarar',
    );
    return '$_temp0';
  }

  @override
  String get processInbox => 'Procesar bandeja';

  @override
  String deleteItemsConfirmTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '¿Eliminar $count elementos?',
      one: '¿Eliminar 1 elemento?',
    );
    return '$_temp0';
  }

  @override
  String get deleteItemsConfirmBody =>
      'Se eliminarán permanentemente junto con sus adjuntos. No se puede deshacer.';

  @override
  String deletedItemsSnackbar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementos eliminados.',
      one: '1 elemento eliminado.',
    );
    return '$_temp0';
  }

  @override
  String completedItemsSnackbar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementos completados.',
      one: '1 elemento completado.',
    );
    return '$_temp0';
  }

  @override
  String filedItemsSnackbar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count archivados en el proyecto.',
      one: '1 archivado en el proyecto.',
    );
    return '$_temp0';
  }

  @override
  String movedItemsSnackbar(int count, String destination) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count movidos a $destination.',
      one: '1 movido a $destination.',
    );
    return '$_temp0';
  }

  @override
  String selectionCountTitle(int count) {
    return '$count seleccionados';
  }

  @override
  String get captureTitle => 'Vaciar la mente';

  @override
  String get captureHint => '¿Qué tienes en mente?';

  @override
  String get captureNotesHint => 'Notas (opcional)';

  @override
  String get captureEmptyError => 'Escribe algo para capturar';

  @override
  String get captureSubmit => 'A la bandeja';

  @override
  String get dictate => 'Dictar';

  @override
  String get stopDictation => 'Parar dictado';

  @override
  String get dictationUnavailable =>
      'El dictado no está disponible. Puedes escribir lo que quieres capturar.';

  @override
  String get processTitle => 'Procesar bandeja';

  @override
  String get processCompleteTitle => '¡Bandeja vacía!';

  @override
  String get processCompleteNoItems => 'Todo aclarado.';

  @override
  String processCompleteStats(int filed, int doneNow, int trashed) {
    return 'Has archivado $filed, terminado $doneNow en menos de 2 minutos y descartado $trashed. ¡Buen trabajo!';
  }

  @override
  String processStepCounter(int step, int total) {
    return 'Paso $step de $total';
  }

  @override
  String processItemsRemaining(int count) {
    return '$count restantes';
  }

  @override
  String get previousStepTooltip => 'Paso anterior';

  @override
  String get skipItemTooltip => 'Omitir';

  @override
  String get actionableQuestion => '¿Requiere acción?';

  @override
  String get actionableYes => 'Sí — hay algo que hacer';

  @override
  String get actionableReference => 'No — guardar como referencia';

  @override
  String get actionableSomeday => 'No — algún día / tal vez';

  @override
  String get actionableTrash => 'Eliminar';

  @override
  String get twoMinQuestion => '¿Toma menos de 2 minutos?';

  @override
  String get twoMinYes => 'Sí — lo hago ahora';

  @override
  String get delegateQuestion => '¿Puede hacerlo otra persona?';

  @override
  String get waitingOnPromptTitle => '¿A quién esperas?';

  @override
  String get waitingOnPromptHint => 'Nombre o sistema';

  @override
  String get recurrencePrompt => '¿Se repite?';

  @override
  String get recurrenceOff => 'No se repite';

  @override
  String get capturedLabel => 'CAPTURADO';

  @override
  String get engageTitle => 'Hacer ahora';

  @override
  String get engageEmptyTitle => 'Sin siguientes acciones';

  @override
  String get engageEmptyMessage =>
      'Captura algo o procesa tu bandeja para llenar tu lista.';

  @override
  String get engageInlineEmpty =>
      'Sin siguientes acciones — captura algo o procesa tu bandeja.';

  @override
  String get engageOpenInbox => 'Abrir bandeja';

  @override
  String get engageNoMatchTitle => 'Sin coincidencias';

  @override
  String get hardLandscape => 'Calendario';

  @override
  String get hardLandscapeSubtitle => 'Vencen hoy & Atrasadas';

  @override
  String get filterAllContexts => 'Todos los contextos';

  @override
  String get filterAnyTime => 'Cualquier duración';

  @override
  String get filterUnder5m => '< 5 min';

  @override
  String get filterUnder15m => '< 15 min';

  @override
  String get filterUnder30m => '< 30 min';

  @override
  String get filterUnder1h => '< 1 h';

  @override
  String get filterAnyEnergy => 'Cualquier energía';

  @override
  String get energyLow => 'Baja';

  @override
  String get energyMedium => 'Media';

  @override
  String get energyHigh => 'Alta';

  @override
  String get projectsTitle => 'Proyectos';

  @override
  String get newProject => 'Nuevo proyecto';

  @override
  String get organizeLooseActionsTooltip => 'Organizar acciones sueltas';

  @override
  String get projectsEmptyTitle => 'Aún no hay proyectos';

  @override
  String get projectsEmptyMessage =>
      'Un proyecto es cualquier resultado que requiera más de una acción. Crea uno para agrupar tus tareas.';

  @override
  String get projectMissingNextAction => 'Sin siguiente acción definida';

  @override
  String get organizeActionsTitle => 'Organizar acciones';

  @override
  String get organizeEmptyTitle => 'Nada suelto';

  @override
  String get organizeEmptyMessage =>
      'Todas las acciones ya pertenecen a un proyecto. Las acciones nuevas sin asignar aparecerán aquí.';

  @override
  String assignToProject(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Asignar $count a proyecto',
      one: 'Asignar 1 a proyecto',
    );
    return '$_temp0';
  }

  @override
  String get addNextActionTitle => 'Añadir siguiente acción';

  @override
  String get addNextActionHint => 'p. ej., Enviar cronograma a Sara';

  @override
  String get addExistingActions => 'Añadir acciones existentes';

  @override
  String get noUnassignedActionsMessage => 'No hay acciones sin asignar.';

  @override
  String addCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Añadir $count',
      one: 'Añadir 1',
    );
    return '$_temp0';
  }

  @override
  String get editProject => 'Editar proyecto';

  @override
  String get projectName => 'Nombre del proyecto';

  @override
  String get projectNameHint => 'p. ej., Lanzar la nueva web';

  @override
  String get projectNameRequired => 'Escribe un nombre de proyecto';

  @override
  String get areaOfFocusOptional => 'Área de enfoque (opcional)';

  @override
  String get unfiledOption => '— Sin archivar —';

  @override
  String get dueDate => 'Vencimiento';

  @override
  String get deleteProjectConfirmTitle => '¿Eliminar proyecto?';

  @override
  String get deleteProjectWarning =>
      'Las acciones asignadas quedarán huérfanas pero no se eliminarán.';

  @override
  String get addActionFab => 'Añadir acción';

  @override
  String get projectOutcomeHint => '¿Cuál es el resultado deseado?';

  @override
  String get outcomeSection => 'Resultado';

  @override
  String get nextActionsSection => 'Siguientes acciones';

  @override
  String get noNextActionsMessage => 'Aún no hay siguientes acciones.';

  @override
  String get statusTooltip => 'Estado';

  @override
  String get reviewTitle => 'Revisar';

  @override
  String get weeklyReviewCardTitle => 'Revisión semanal';

  @override
  String get weeklyReviewCardSubtitle =>
      'Repasa tu bandeja, listas y proyectos. El ritual para mantener el sistema fiable.';

  @override
  String get calendarEmpty => 'Nada para un día concreto.';

  @override
  String get waitingForEmpty => 'Nada delegado.';

  @override
  String get somedayEmpty => 'Sin elementos para \'Algún día\'.';

  @override
  String get referenceEmpty => 'Sin material de referencia.';

  @override
  String get completedThisWeek => 'Completado esta semana';

  @override
  String get completedThisWeekEmpty => 'Nada completado todavía esta semana.';

  @override
  String bucketCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementos',
      one: '1 elemento',
    );
    return '$_temp0';
  }

  @override
  String get needsReDecision => 'Volver a decidir';

  @override
  String pastDueCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vencidos',
      one: '1 vencido',
    );
    return '$_temp0';
  }

  @override
  String get reviewStep1Title => 'Vacía la cabeza';

  @override
  String get reviewStep1Body =>
      'Captura en la bandeja todo lo que ocupe tu atención para poder confiar en el sistema.';

  @override
  String get reviewStep2Title => 'Bandeja a cero';

  @override
  String get reviewStep2Body =>
      'Aclara cada elemento siguiendo el árbol de decisión hasta vaciar la bandeja.';

  @override
  String get reviewStep3Title => 'Revisa tus acciones';

  @override
  String get reviewStep3Body =>
      'Mira cada acción. ¿Hecha? Márcala. ¿Obsoleta? Edítala o bórrala. ¿Sigue vigente? Déjala.';

  @override
  String get reviewStep4Title => 'Revisa tu lista \'En espera\'';

  @override
  String get reviewStep4Body =>
      '¿Alguna respuesta? ¿Toca hacer seguimiento? Actualiza o elimina.';

  @override
  String get reviewStep5Title => 'Revisa cada proyecto';

  @override
  String get reviewStep5Body =>
      'Revisa cada resultado. Añade una próxima acción a los proyectos estancados, ponlos en pausa o márcalos como completados. Las tareas en espera y programadas también cuentan como avance.';

  @override
  String get reviewStep6Title => 'Mira las próximas dos semanas';

  @override
  String get reviewStep6Body =>
      'Revisa el calendario. ¿Hay algo para lo que puedas prepararte ya?';

  @override
  String get reviewStep7Title => 'Revisa \'Algún día / Tal vez\'';

  @override
  String get reviewStep7Body =>
      '¿Algo aquí merece la pena ahora? Promuévelo a proyecto o siguiente acción.';

  @override
  String reviewStepCounter(int step, int total) {
    return 'Paso $step de $total';
  }

  @override
  String get finishReview => 'Finalizar revisión';

  @override
  String get reviewCompleteSnackbar => 'Revisión semanal completada';

  @override
  String get searchHint => 'Buscar acciones, notas';

  @override
  String get searchMinChars => 'Escribe al menos dos caracteres';

  @override
  String get clearFilters => 'Borrar filtros';

  @override
  String get clearSearch => 'Borrar búsqueda';

  @override
  String searchNoResults(String query) {
    return 'Sin resultados para «$query»';
  }

  @override
  String get searchNoMatchTitle => 'Nada coincide';

  @override
  String get searchNoMatchMessage =>
      'Nada coincide con los filtros actuales. Prueba a ampliarlos o quítalos.';

  @override
  String get filterAllProjects => 'Todos los proyectos';

  @override
  String get filterCompleted => 'Completados';

  @override
  String get statusInbox => 'Bandeja';

  @override
  String get statusNext => 'Siguiente';

  @override
  String get statusWaiting => 'Espera';

  @override
  String get statusSomeday => 'Algún día';

  @override
  String get statusReference => 'Referencia';

  @override
  String get appearanceSection => 'Apariencia';

  @override
  String get themeLabel => 'Tema';

  @override
  String get themeFollowSystem => 'Predeterminado del sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get hapticFeedback => 'Respuesta háptica';

  @override
  String get languageLabel => 'Idioma';

  @override
  String get languageFollowSystem => 'Predeterminado del sistema';

  @override
  String get contextsLabel => 'Contextos';

  @override
  String get areasOfFocusLabel => 'Áreas de enfoque';

  @override
  String get calendarSyncLabel => 'Sincronización de calendario';

  @override
  String get remindersSection => 'Recordatorios';

  @override
  String get weeklyReviewNudge => 'Recordatorio de revisión semanal';

  @override
  String get weeklyReviewNudgeDescription =>
      'Un recordatorio sutil cada viernes a las 16:00.';

  @override
  String get remindBeforeDue => 'Avisarme antes del vencimiento';

  @override
  String get remindBeforeDueOff => 'Desactivado · solo alerta al vencer';

  @override
  String get remindBeforeDueSuffix => 'se aplica a nuevas tareas';

  @override
  String get deferSurfaceLabel => 'Aviso de tareas diferidas a las';

  @override
  String get deferSurfaceDescription =>
      'tareas diferidas sin hora te avisan a esta hora';

  @override
  String get checkingNotificationStatus => 'Comprobando notificaciones…';

  @override
  String exportBackupError(String error) {
    return 'Error al exportar: $error';
  }

  @override
  String get weeklyBackupReminder => 'Recordatorio semanal de copia';

  @override
  String get weeklyBackupReminderDescription =>
      'Recuérdame cada domingo exportar la copia.';

  @override
  String get importConfirmTitle => '¿Importar esta copia?';

  @override
  String importConfirmBody(String sections) {
    return 'Se añadirán o actualizarán $sections.\n\nLas entradas con el mismo ID se sobrescribirán. No se puede deshacer.';
  }

  @override
  String get importButton => 'Importar';

  @override
  String get importFromPasteTitle => 'Pegar JSON';

  @override
  String get importFromPasteDescription =>
      'Pega el texto de la copia directamente.';

  @override
  String get pasteBackupHint => 'Pega aquí el JSON…';

  @override
  String get crashReports => 'Enviar informes de fallos';

  @override
  String get crashReportsDescription =>
      'Informes anónimos vía Sentry. Sin datos personales. Desactivado por defecto.';

  @override
  String get crashReportsEnabled => 'Se enviarán en el próximo arranque';

  @override
  String get crashReportsDisabled => 'Informes desactivados';

  @override
  String get showOnboardingAgain => 'Ver introducción de nuevo';

  @override
  String get versionLabel => 'Versión';

  @override
  String get settingsFooter =>
      'Local primero. Tus datos se quedan en este dispositivo. Inspirado en el método GTD de David Allen.';

  @override
  String get editTitle => 'Editar';

  @override
  String get saveError =>
      'No se pudieron guardar los cambios. Inténtalo de nuevo.';

  @override
  String get savedIndicator => 'Guardado';

  @override
  String get titleLabel => 'Título';

  @override
  String get notesLabel => 'Notas';

  @override
  String get statusSection => 'Estado';

  @override
  String get contextSection => 'Contexto';

  @override
  String get energySection => 'Energía';

  @override
  String get timeEstimateSection => 'Tiempo estimado';

  @override
  String get waitingOnSection => 'En espera de';

  @override
  String get waitingOnHint => '¿A quién o qué esperas?';

  @override
  String get projectSection => 'Proyecto';

  @override
  String get datesSection => 'Fechas';

  @override
  String get dueLabel => 'Vencimiento';

  @override
  String get deferUntilLabel => 'Diferir hasta';

  @override
  String get repeatSection => 'Repetición';

  @override
  String get recurrenceNeedsDeferHint =>
      'Añade una fecha para \'Diferir hasta\' para activar la repetición.';

  @override
  String get recurrenceNeedsDueDateHint =>
      'Añade una fecha para activar la repetición.';

  @override
  String get recurrenceExplanation =>
      'Al completar la tarea, aparecerá la siguiente repetición.';

  @override
  String get recurrenceNoDateNextActionError =>
      'La repetición requiere fecha de inicio (\'Diferir hasta\').';

  @override
  String get recurrenceNoDateError => 'La repetición requiere una fecha.';

  @override
  String get attachmentsSection => 'Adjuntos';

  @override
  String get markComplete => 'Terminar';

  @override
  String get reopen => 'Reabrir';

  @override
  String get deleteItemConfirmTitle => '¿Eliminar elemento?';

  @override
  String get deleteItemConfirmBody => 'No se puede deshacer.';

  @override
  String get completeError => 'Error al terminar.';

  @override
  String get reopenError => 'Error al reabrir.';

  @override
  String get remindersBlockedWarning =>
      'Recordatorios bloqueados en el sistema.';

  @override
  String get remindersOffWarning => 'Recordatorios desactivados.';

  @override
  String get preciseReminderOffWarning =>
      'Precisión de recordatorios desactivada.';

  @override
  String get allowExactAlarms => 'Permitir alarmas exactas';

  @override
  String get noContextsAvailable => 'Sin contextos — añade algunos en Ajustes.';

  @override
  String get noActiveProjects => 'Sin proyectos activos.';

  @override
  String get attachmentPhoto => 'Foto';

  @override
  String get attachmentCamera => 'Cámara';

  @override
  String get attachmentVoiceMemo => 'Nota de voz';

  @override
  String get attachmentStop => 'Parar';

  @override
  String get remove => 'Quitar';

  @override
  String get imageViewerClose => 'Cerrar';

  @override
  String imageViewerCounter(int current, int total) {
    return '$current / $total';
  }

  @override
  String attachmentPhotoCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotos',
      one: '1 foto',
    );
    return '$_temp0';
  }

  @override
  String attachmentAudioCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notas de voz',
      one: '1 nota de voz',
    );
    return '$_temp0';
  }

  @override
  String attachmentFileCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count archivos',
      one: '1 archivo',
    );
    return '$_temp0';
  }

  @override
  String get areasTitle => 'Áreas de enfoque';

  @override
  String get newArea => 'Nueva área';

  @override
  String get renameArea => 'Renombrar área';

  @override
  String get areasEmptyMessage =>
      'Aún no hay áreas. Las áreas son esferas de responsabilidad —Salud, Carrera, Familia— que agrupan tus proyectos.';

  @override
  String get areaNameHint => 'p. ej., Salud, Carrera, Familia';

  @override
  String deleteAreaConfirmTitle(String name) {
    return '¿Eliminar «$name»?';
  }

  @override
  String get deleteAreaWarning =>
      'Los proyectos de esta área quedarán sin archivar.';

  @override
  String get contextsTitle => 'Contextos';

  @override
  String get newContext => 'Nuevo contexto';

  @override
  String get editContext => 'Editar contexto';

  @override
  String get contextsEmptyMessage =>
      'Sin contextos. Los contextos indican dónde o con qué puedes actuar (@teléfono, @casa).';

  @override
  String get nameLabel => 'Nombre';

  @override
  String get iconLabel => 'Icono';

  @override
  String get colorLabel => 'Color';

  @override
  String deleteContextConfirmTitle(String name) {
    return '¿Eliminar $name?';
  }

  @override
  String get deleteContextWarning => 'Las tareas perderán este contexto.';

  @override
  String get calendarSyncTitle => 'Sincronización';

  @override
  String get calendarSyncIntro =>
      'Refleja tareas con fecha en tu calendario y trae eventos «#gtd» a tu bandeja.';

  @override
  String get enableCalendarSync => 'Activar sincronización';

  @override
  String get targetCalendar => 'Calendario de destino';

  @override
  String get calendarAccessDenied => 'Acceso denegado.';

  @override
  String get grantCalendarAccess => 'Permitir acceso';

  @override
  String get noCalendarsAvailable => 'Sin calendarios disponibles.';

  @override
  String get mirrorOutAction => 'Tareas → Calendario';

  @override
  String get importInAction => 'Eventos «#gtd» → Bandeja';

  @override
  String mirrorOutSuccess(int written) {
    return '$written tareas reflejadas';
  }

  @override
  String mirrorOutSuccessWithStale(int written, int removed) {
    return '$written tareas reflejadas, $removed obsoletas quitadas';
  }

  @override
  String importInSuccess(int count) {
    return '$count eventos importados';
  }

  @override
  String get mirroringProgress => 'Sincronizando…';

  @override
  String get importingProgress => 'Importando…';

  @override
  String get calendarSyncTip =>
      'Consejo: escribe «#gtd» en el título de un evento para importarlo automáticamente.';

  @override
  String get gtdDiagramTitle => 'Flujo GTD';

  @override
  String get gtdDiagramSubtitle =>
      'Cinco pasos para vaciar tu cabeza en un sistema fiable. Toca una lista para ir allí.';

  @override
  String get gtdAttribution => 'Método de David Allen · gettingthingsdone.com';

  @override
  String get youAreHere => 'Estás aquí';

  @override
  String get gtdStage1Body =>
      'Vuelca todo en la bandeja —tareas, ideas, preocupaciones. No filtres ni organices todavía.';

  @override
  String get gtdStage2Body =>
      'Toma un elemento a la vez y decide qué es. Sigue este flujo de decisión:';

  @override
  String get gtdStage3Body =>
      'El resultado va a la lista correcta. Nada se queda en tu cabeza.';

  @override
  String get gtdStage3Footnote =>
      'Espera / Calendario / Algún día / Referencia están en Revisar.';

  @override
  String get gtdStage4Body =>
      'Revisa tus listas regularmente —sobre todo en la Revisión Semanal.';

  @override
  String get gtdStage5Body =>
      'Simplemente hazlo —elige tareas por contexto, tiempo y energía.';

  @override
  String get decisionNotActionableQ => '¿No requiere acción?';

  @override
  String get decisionNotActionableA =>
      'Eliminar, Algún día/Tal vez o Referencia';

  @override
  String get decisionTwoMinQ => '¿Lleva menos de 2 minutos?';

  @override
  String get decisionTwoMinA => 'Hazlo ya mismo';

  @override
  String get decisionDelegateQ => '¿Debe hacerlo otro?';

  @override
  String get decisionDelegateA => 'Delegar → En espera';

  @override
  String get decisionMultiStepQ => '¿Requiere más de un paso?';

  @override
  String get decisionMultiStepA => 'Crea un Proyecto';

  @override
  String get decisionOtherwiseQ => 'De lo contrario';

  @override
  String get decisionOtherwiseA => 'Define la siguiente acción';

  @override
  String get supportTitle => 'Apoya a Trayzero';

  @override
  String get supportIntro =>
      'Trayzero es gratis, con todas las funciones desbloqueadas. Si te resulta útil, puedes contribuir: así la app sigue siendo independiente y sin anuncios.';

  @override
  String get supportUnavailable =>
      'Las opciones de apoyo no están disponibles en este momento.';

  @override
  String get supportTipHeader => 'Deja una propina';

  @override
  String get supportTipSmall => 'Propina pequeña';

  @override
  String get supportTipLarge => 'Propina grande';

  @override
  String get supportSupporterYearly => 'Colaborador — anual';

  @override
  String supportSupporterYearlySubtitle(String price) {
    return '$price / año · mejor precio · apoya el desarrollo';
  }

  @override
  String get supportSupporterMonthly => 'Colaborador — mensual';

  @override
  String supportSupporterMonthlySubtitle(String price) {
    return '$price / mes · cancela cuando quieras';
  }

  @override
  String supportOpeningStore(String store) {
    return 'Abriendo $store…';
  }

  @override
  String get supportRestoring => 'Restaurando compras…';

  @override
  String get supportRestore => 'Restaurar compras';

  @override
  String get supportRestoreSubtitle =>
      '¿Ya eres colaborador? Restáuralas en este dispositivo.';

  @override
  String get supportAutoRenewNote =>
      'Las suscripciones se renuevan automáticamente hasta que las canceles en Ajustes.';

  @override
  String get legalPrivacyPolicy => 'Política de privacidad';

  @override
  String get legalTermsOfUse => 'Términos de uso';

  @override
  String get supportThanksTip => '¡Muchas gracias! 💙';

  @override
  String get supportThanksSupporter => 'Ya eres colaborador, ¡gracias! 💙';

  @override
  String get supportRestored => 'Compras restauradas. ¡Bienvenido de nuevo! 💙';

  @override
  String get supportRestoreNone => 'No se encontraron compras anteriores.';

  @override
  String get supportBadgeYearly => 'Colaborador · anual';

  @override
  String get supportBadgeMonthly => 'Colaborador · mensual';

  @override
  String get supportBadgeGeneric => 'Colaborador';

  @override
  String get supportBadgeSubtitle =>
      'Gracias por mantener a Trayzero independiente.';

  @override
  String get calendarLookupFailed =>
      'No se pudieron cargar los calendarios. Comprueba la sincronización de tu cuenta en la app Calendario y vuelve a intentarlo.';

  @override
  String get calendarPermissionHelp =>
      'Si no aparece la solicitud de permiso, permite el acceso al calendario en los ajustes de la app y vuelve aquí.';

  @override
  String get calendarOpenSettings => 'Abrir ajustes de la app';

  @override
  String get calendarSettingsFailed =>
      'Abre los ajustes del dispositivo y permite a Trayzero acceder al calendario.';

  @override
  String get calendarSelectionUnavailable =>
      'El calendario seleccionado ya no está disponible. Elige otro calendario.';

  @override
  String get appIcon => 'Icono de la app';

  @override
  String get appIconAndroidDescription =>
      'Elige un icono de inicio independiente del color de la app. El lanzador puede tardar un momento en actualizarlo o aplicar su propio tinte.';

  @override
  String get appIconDescription =>
      'Elige un icono independiente del color de la app. El dispositivo puede aplicar su propio tinte. iOS muestra un aviso al cambiar el icono.';

  @override
  String get appIconChangeFailed =>
      'No se pudo cambiar el icono. Inténtalo de nuevo con Trayzero abierto.';

  @override
  String get appColor => 'Color de la app';

  @override
  String get appColorDescription =>
      'Funciona en modo claro y oscuro. Los colores de las listas GTD conservan su significado.';

  @override
  String get paletteAmber => 'Ámbar Trayzero — Predeterminado';

  @override
  String get paletteBlue => 'Azul';

  @override
  String get paletteCyan => 'Cian';

  @override
  String get paletteTeal => 'Verde azulado';

  @override
  String get paletteGreen => 'Verde';

  @override
  String get paletteViolet => 'Violeta';

  @override
  String get paletteRose => 'Rosa';

  @override
  String get appIconNotificationNote =>
      'Los avisos de Android usan el color del icono de la app seleccionado al programar recordatorios. Las notificaciones existentes se actualizan al reprogramarse. Algunos dispositivos pueden mostrar el icono original de la app.';

  @override
  String get appearanceSaveFailed =>
      'No se pudo guardar la apariencia. Se ha restaurado el ajuste anterior.';

  @override
  String mirrorOutPendingCleanup(int count) {
    return 'Quedan $count eventos de calendario por eliminar. Sincroniza de nuevo.';
  }

  @override
  String get weeklyReviewResume => 'Continuar revisión semanal';

  @override
  String get weeklyReviewProgressSaved => 'Tu progreso se guarda al salir.';

  @override
  String get weeklyReviewSaveError =>
      'No se pudo guardar tu progreso. Inténtalo de nuevo.';

  @override
  String get weeklyReviewActionError =>
      'No se pudo guardar este cambio. Inténtalo de nuevo.';

  @override
  String get weeklyReviewListEmpty => 'No hay nada que revisar aquí.';

  @override
  String get weeklyReviewProjectAwaiting =>
      'El trabajo pendiente o programado hace avanzar este proyecto.';

  @override
  String get weeklyReviewProjectMoving => 'Próxima acción definida';

  @override
  String get weeklyReviewOpenProject => 'Abrir proyecto';

  @override
  String get processTwoMinNo => 'No — seguir aclarando';

  @override
  String get twoMinRule =>
      'La regla de los dos minutos: si tardas menos en hacerlo que en registrarlo, hazlo ahora.';

  @override
  String get delegateYes => 'Sí — delegar y esperar su respuesta';

  @override
  String get delegateNo => 'No — me corresponde a mí';

  @override
  String get singleStepQuestion => '¿Es una sola acción concreta?';

  @override
  String get singleStepYes => 'Sí — una única siguiente acción';

  @override
  String get singleStepProject => 'No — es un proyecto';

  @override
  String get projectRule =>
      'Un proyecto es un resultado que requiere más de una acción y puede completarse en un año.';

  @override
  String get deferQuestion => '¿Tiene un día o una hora específicos?';

  @override
  String get deferAsap => 'No — hacerlo lo antes posible';

  @override
  String get deferCalendar => 'Sí — añadirlo al calendario';

  @override
  String get deferChooseDate => 'Posponer hasta una fecha';

  @override
  String get processDetailsTitle => 'Añadir detalles';

  @override
  String get processFileNextAction => 'Guardar como siguiente acción';

  @override
  String minutesShort(int minutes) {
    return '$minutes min';
  }

  @override
  String deferredUntilSummary(String date) {
    return 'Pospuesto hasta $date';
  }

  @override
  String deferredRepeatingSummary(String date, String recurrence) {
    return 'Pospuesto hasta $date · Repetición: $recurrence';
  }

  @override
  String get recurrenceDaily => 'Diariamente';

  @override
  String get recurrenceWeekly => 'Semanalmente';

  @override
  String get recurrenceMonthly => 'Mensualmente';

  @override
  String get recurrenceYearly => 'Anualmente';

  @override
  String get createProject => 'Crear';

  @override
  String get projectPickerTitle => 'Mover a un proyecto';

  @override
  String get projectMoved => 'Movido a un proyecto.';

  @override
  String get projectDetached => 'Retirado del proyecto.';

  @override
  String get noProject => 'Sin proyecto';

  @override
  String get decreaseRepeatInterval => 'Reducir el intervalo de repetición';

  @override
  String get increaseRepeatInterval => 'Aumentar el intervalo de repetición';

  @override
  String get decreaseRepeatCount => 'Reducir el número de repeticiones';

  @override
  String get increaseRepeatCount => 'Aumentar el número de repeticiones';

  @override
  String get repeatOn => 'Repetir los';

  @override
  String get repeatMonthlyOn => 'El';

  @override
  String get repeatDayOfMonth => 'Día del mes';

  @override
  String get repeatDayOfWeek => 'Día de la semana';

  @override
  String get repeatFirst => 'Primer';

  @override
  String get repeatSecond => 'Segundo';

  @override
  String get repeatThird => 'Tercer';

  @override
  String get repeatFourth => 'Cuarto';

  @override
  String get repeatFifth => 'Quinto';

  @override
  String get repeatLast => 'Último';

  @override
  String get repeatEnds => 'Finaliza';

  @override
  String get repeatNever => 'Nunca';

  @override
  String get repeatOnDate => 'En una fecha';

  @override
  String get repeatAfterCount => 'Tras un número de veces';

  @override
  String get weekdayListSeparator => ', ';

  @override
  String get dueToday => 'Vence hoy';

  @override
  String get reschedule => 'Reprogramar';

  @override
  String get complete => 'Completar';

  @override
  String get drop => 'Descartar';

  @override
  String get trash => 'Papelera';

  @override
  String itemEnergyLabel(String energy) {
    return 'Energía: $energy';
  }

  @override
  String waitingOnPerson(String person) {
    return 'Esperando a $person';
  }

  @override
  String dueOverdueDays(int days) {
    return 'Vencido · $days d';
  }

  @override
  String dueTodayAt(String time) {
    return 'Vence hoy, $time';
  }

  @override
  String selectItem(String title) {
    return 'Seleccionar $title';
  }

  @override
  String markItemDone(String title) {
    return 'Marcar $title como completado';
  }

  @override
  String repeatLastOnDate(String date) {
    return 'Última vez el $date';
  }

  @override
  String repeatAfterOccurrences(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Después de $count repeticiones',
      one: 'Después de 1 repetición',
    );
    return '$_temp0';
  }

  @override
  String recurrenceUntilSummary(String pattern, String date) {
    return '$pattern · hasta el $date';
  }

  @override
  String recurrenceCountSummary(String pattern, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$pattern · $count repeticiones',
      one: '$pattern · 1 repetición',
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
      'first': 'primer',
      'second': 'segundo',
      'third': 'tercer',
      'fourth': 'cuarto',
      'fifth': 'quinto',
      'other': 'último',
    });
    return '$cadence, el $_temp0 $weekday';
  }

  @override
  String repeatEveryDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Cada $count días',
      one: 'Cada día',
    );
    return '$_temp0';
  }

  @override
  String repeatEveryWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Cada $count semanas',
      one: 'Cada semana',
    );
    return '$_temp0';
  }

  @override
  String repeatEveryMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Cada $count meses',
      one: 'Cada mes',
    );
    return '$_temp0';
  }

  @override
  String repeatEveryYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Cada $count años',
      one: 'Cada año',
    );
    return '$_temp0';
  }

  @override
  String get captureAddContinue => 'Añadir y seguir';

  @override
  String captureAddedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementos añadidos a la bandeja',
      one: '1 elemento añadido a la bandeja',
    );
    return '$_temp0';
  }

  @override
  String get folderBackupChoose => 'Elegir carpeta de copias';

  @override
  String get folderBackupSaving => 'Guardando copia…';

  @override
  String get folderBackupOff => 'Las copias automáticas están desactivadas.';

  @override
  String get folderBackupNever => 'Aún no se ha guardado ninguna copia.';

  @override
  String folderBackupLastSuccess(String date) {
    return 'Última copia: $date';
  }

  @override
  String get folderBackupFailed =>
      'No se pudo guardar la copia. Comprueba el acceso a la carpeta y el espacio libre e inténtalo de nuevo.';

  @override
  String get folderBackupHistoryWarning =>
      'Copia guardada, pero no se pudieron eliminar las copias antiguas.';

  @override
  String get folderBackupNow => 'Guardar copia ahora';

  @override
  String get doViewToday => 'Hoy';

  @override
  String get doViewNextActions => 'Próximas acciones';

  @override
  String get todayPlanCardTitle => 'Planifica tu día';

  @override
  String get todayPlanCardBody =>
      'Elige en qué te centrarás hoy. Lleva unos dos minutos.';

  @override
  String get todayPlanAction => 'Planificar hoy';

  @override
  String todayCarryOverLine(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementos de antes necesitan una decisión',
      one: '1 elemento de antes necesita una decisión',
    );
    return '$_temp0';
  }

  @override
  String get todayFocusHeader => 'Enfoque';

  @override
  String todayDoneCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hechos hoy',
      one: '1 hecho hoy',
    );
    return '$_temp0';
  }

  @override
  String get todayEmptyTitle => 'Aún no hay nada destacado';

  @override
  String get todayEmptyMessage =>
      'Marca con una estrella las próximas acciones para comprometerte con ellas hoy, o planifica tu día.';

  @override
  String get focusAddTooltip => 'Añadir a Hoy';

  @override
  String get focusRemoveTooltip => 'Quitar de Hoy';

  @override
  String focusAddItem(String title) {
    return 'Añadir $title a Hoy';
  }

  @override
  String focusRemoveItem(String title) {
    return 'Quitar $title de Hoy';
  }

  @override
  String get focusError => 'No se pudo actualizar Hoy. Inténtalo de nuevo.';

  @override
  String get planTodayIntro =>
      'Marca con una estrella aquello con lo que te comprometes hoy. Que sea breve: todo lo demás sigue en tus listas.';

  @override
  String get planSectionCarryOver => 'De antes';

  @override
  String get planCarryOverHint =>
      'Los elementos que no conserves vuelven a sus listas cuando empieces tu día.';

  @override
  String get planKeepAll => 'Conservar todos';

  @override
  String get planSectionCalendar => 'Calendario';

  @override
  String get planOnToday => 'En Hoy';

  @override
  String get planSectionWaiting => 'Seguimientos pendientes';

  @override
  String get planSectionAvailable => 'Disponibles desde hoy';

  @override
  String get planEmpty =>
      'Aún no hay nada que planificar. Procesa tu bandeja de entrada para crear próximas acciones.';

  @override
  String planFocusedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count destacados para hoy',
      one: '1 destacado para hoy',
      zero: 'Aún no hay nada destacado',
    );
    return '$_temp0';
  }

  @override
  String get planStartDay => 'Empezar mi día';

  @override
  String get planDoneSnackbar => 'El día está planificado';

  @override
  String planClearedSnackbar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Día planificado · $count elementos volvieron a sus listas',
      one: 'Día planificado · 1 elemento volvió a su lista',
    );
    return '$_temp0';
  }

  @override
  String get planSaveError => 'No se pudo guardar tu plan. Inténtalo de nuevo.';

  @override
  String get captureTipDates =>
      'Consejo: añade @contexto, #proyecto, +etiqueta o una fecha en inglés como “tomorrow”.';

  @override
  String get captureTipSigils =>
      'Consejo: añade @contexto, #proyecto o +etiqueta.';

  @override
  String startsOnDate(String date) {
    return 'Empieza $date';
  }

  @override
  String dueOnDate(String date) {
    return 'Vence $date';
  }

  @override
  String captureChipProject(String name) {
    return 'Proyecto: $name';
  }

  @override
  String get captureKeepAsText => 'Mantener como texto';

  @override
  String get captureRecognized => 'Detalles reconocidos';

  @override
  String deferUseStartDate(String date) {
    return 'Empezar el $date';
  }

  @override
  String deferUseDueDate(String date) {
    return 'En el calendario el $date';
  }

  @override
  String weeklyReviewProjectInactive(int days) {
    return 'Sin actividad en $days+ días';
  }

  @override
  String get weeklyReviewMarkReviewed => 'Marcar como revisado';

  @override
  String get weeklyReviewReviewed => 'Revisado';

  @override
  String weeklyReviewLastReviewed(String date) {
    return 'Revisado por última vez el $date';
  }

  @override
  String get weeklyReviewNeverReviewed => 'Aún sin revisar';

  @override
  String weeklyReviewReviewedProgress(int done, int total) {
    return 'Revisados $done de $total';
  }

  @override
  String get importFromApp => 'Importar de otra app';

  @override
  String get importSourcePlainText => 'Texto sin formato / TaskPaper';

  @override
  String get importHintTodoist =>
      'Menú del proyecto › Exportar como plantilla › CSV, o un ZIP de copia desde Ajustes › Copias de seguridad.';

  @override
  String get importHintTickTick =>
      'En el sitio web de TickTick: Ajustes › Cuenta › Copia de seguridad e importación › Generar copia (CSV).';

  @override
  String get importHintNirvana =>
      'En la app web de Nirvana, exporta tus datos como CSV o JSON.';

  @override
  String get importHintOmniFocus =>
      'Selecciona proyectos y luego Edición › Copiar como TaskPaper. Pégalo aquí o guárdalo como archivo.';

  @override
  String get importHintPlainText =>
      'Things: copia las tareas y pégalas aquí, una por línea. Solo texto básico; no se admiten exportaciones de la base de datos de Things.';

  @override
  String get importChooseFile => 'Elegir archivo';

  @override
  String get importPasteText => 'Pegar texto';

  @override
  String get importPasteTitle => 'Pegar tareas';

  @override
  String get importPasteHint =>
      'Una tarea por línea. Sangra tareas bajo una línea que termine en «:» para crear un proyecto.';

  @override
  String get importPasteContinue => 'Vista previa';

  @override
  String get importPreviewNothingYet => 'Todavía no se ha añadido nada.';

  @override
  String get importPreviewProjects => 'Proyectos';

  @override
  String get importProjectNew => 'Nuevo';

  @override
  String get importProjectExisting => 'Se añade al existente';

  @override
  String importProjectActions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count acciones',
      one: '1 acción',
    );
    return '$_temp0';
  }

  @override
  String importContextsNew(String names) {
    return 'Nuevos: $names';
  }

  @override
  String importContextsExisting(String names) {
    return 'Ya los tienes: $names';
  }

  @override
  String get importGoodToKnow => 'Conviene saber';

  @override
  String importWarnCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tareas completadas o descartadas omitidas',
      one: '1 tarea completada o descartada omitida',
    );
    return '$_temp0';
  }

  @override
  String importWarnCalendar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count acciones con fecha límite van al Calendario',
      one: '1 acción con fecha límite va al Calendario',
    );
    return '$_temp0';
  }

  @override
  String importWarnDates(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fechas ilegibles se guardan en las notas',
      one: '1 fecha ilegible se guarda en las notas',
    );
    return '$_temp0';
  }

  @override
  String importWarnRepeats(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reglas de repetición se guardan en las notas',
      one: '1 regla de repetición se guarda en las notas',
    );
    return '$_temp0';
  }

  @override
  String importWarnSubtasks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count subtareas pasan a ser acciones aparte',
      one: '1 subtarea pasa a ser una acción aparte',
    );
    return '$_temp0';
  }

  @override
  String importWarnSections(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tareas anotan su sección en las notas',
      one: '1 tarea anota su sección en las notas',
    );
    return '$_temp0';
  }

  @override
  String importWarnNotImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count tareas tenían prioridad, marca o responsable que no se importa',
      one: '1 tarea tenía prioridad, marca o responsable que no se importa',
    );
    return '$_temp0';
  }

  @override
  String importWarnUnreadable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count filas sin título omitidas',
      one: '1 fila sin título omitida',
    );
    return '$_temp0';
  }

  @override
  String importDoneTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tareas añadidas',
      one: '1 tarea añadida',
    );
    return '$_temp0';
  }

  @override
  String get importDoneBody =>
      '¿Has cambiado de idea? Deshacer elimina exactamente lo que añadió esta importación y nada más.';

  @override
  String get importUndo => 'Deshacer importación';

  @override
  String get importFinish => 'Listo';

  @override
  String get importUndoneTitle => 'Importación deshecha';

  @override
  String get importUndoneBody =>
      'Se ha eliminado todo lo que añadió esta importación.';

  @override
  String get importRemindersFailed =>
      'Algunos recordatorios aún no se pudieron programar. Se configurarán la próxima vez que abras la app.';

  @override
  String importErrorUnrecognized(String source) {
    return 'Esto no parece una exportación de $source. Revisa los pasos e inténtalo de nuevo.';
  }

  @override
  String get importErrorNoTasks => 'No hay tareas abiertas para importar.';

  @override
  String get importErrorUnreadable =>
      'No se puede leer este archivo. Elige una exportación de texto, CSV o ZIP.';

  @override
  String get importErrorWrite => 'La importación falló. No se añadió nada.';

  @override
  String get importErrorUndo =>
      'No se pudo deshacer la importación. Inténtalo de nuevo.';

  @override
  String get tagsAndPeopleLabel => 'Etiquetas y personas';

  @override
  String get tagsEmptyMessage =>
      'Las etiquetas marcan elementos en todas las listas. Marca una etiqueta como persona para llevar una agenda de temas que hablar con ella. Consejo: escribe +etiqueta al capturar.';

  @override
  String get newTag => 'Nueva etiqueta';

  @override
  String get editTag => 'Editar etiqueta';

  @override
  String get tagPersonSwitch => 'Persona';

  @override
  String get tagPersonSwitchHint => 'Lleva una agenda de temas que hablar';

  @override
  String tagOpenItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementos abiertos',
      one: '1 elemento abierto',
      zero: 'Ningún elemento abierto',
    );
    return '$_temp0';
  }

  @override
  String deleteTagConfirmTitle(String name) {
    return '¿Eliminar «$name»?';
  }

  @override
  String deleteTagConfirmBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count elementos abiertos la usan. Se conservan; solo se quita la etiqueta.',
      one: '1 elemento abierto la usa. Se conserva; solo se quita la etiqueta.',
      zero: 'Ningún elemento abierto la usa.',
    );
    return '$_temp0';
  }

  @override
  String get tagMergeTitle => '¿Combinar etiquetas?';

  @override
  String tagMergeBody(String source, String target) {
    return '«$target» ya existe. ¿Combinar «$source» con ella?';
  }

  @override
  String get tagMergeAction => 'Combinar';

  @override
  String get addTag => 'Añadir etiqueta';

  @override
  String get tagPickerHint => 'Busca o crea una etiqueta';

  @override
  String tagCreate(String name) {
    return 'Crear «$name»';
  }

  @override
  String tagCreatePerson(String name) {
    return 'Crear persona «$name»';
  }

  @override
  String get tagsSection => 'Etiquetas';

  @override
  String tagChipSemantics(String name) {
    return 'Etiqueta: $name';
  }

  @override
  String personChipSemantics(String name) {
    return 'Persona: $name';
  }

  @override
  String removeTagTooltip(String name) {
    return 'Quitar $name';
  }

  @override
  String moreTags(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count etiquetas más',
      one: '1 etiqueta más',
    );
    return '$_temp0';
  }

  @override
  String get filterTag => 'Etiqueta';

  @override
  String get filterAnyTag => 'Cualquier etiqueta';

  @override
  String get agendasTitle => 'Agendas';

  @override
  String agendasPeopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personas',
      one: '1 persona',
    );
    return '$_temp0';
  }

  @override
  String agendaAddHint(String name) {
    return 'Añade algo que hablar con $name';
  }

  @override
  String get agendaAddTooltip => 'Añadir a la agenda';

  @override
  String agendaEmpty(String name) {
    return 'Aún no hay nada que hablar con $name.';
  }

  @override
  String get agendaNotFound => 'Esta persona ya no existe.';

  @override
  String captureChipNewTag(String name) {
    return 'Nueva etiqueta: $name';
  }

  @override
  String get importHintGoogleTasks =>
      'Google Takeout › selecciona Tasks › exporta JSON. Descomprime la descarga y elige Tasks.json. Las listas quedan en las notas; las tareas completadas van a Hecho.';

  @override
  String get importDuplicateWarning =>
      'Esta misma entrada ya se importó en este dispositivo. Importarla de nuevo duplicará las tareas. Cancela si no quieres otra copia.';

  @override
  String get importHintThings =>
      'Elige main.sqlite o un ZIP de la carpeta de la base exportada de Things 3. iPhone/iPad: Ajustes › General › Diagnóstico › Introducir código › 491348 › Enviar base de datos. Guarda en Archivos, descomprime .aar y comprime la carpeta como ZIP. Mac: cierra Things antes de copiar. Reconfigura repeticiones y recordatorios.';

  @override
  String importWarnDetailsInNotes(int count) {
    return '$count tareas conservan detalles de listas de verificación o áreas en las notas';
  }

  @override
  String get importWarnThingsRecurrence =>
      'No se importan las repeticiones de Things. Se omiten las plantillas; configura de nuevo las repeticiones de las tareas importadas.';

  @override
  String importWarnSourceReminders(int count) {
    return 'No se importan $count ajustes de recordatorios de origen';
  }

  @override
  String get importAppleHint =>
      'Elige listas de recordatorios de este dispositivo. Solo se importan los pendientes.';

  @override
  String get importAppleChooseLists => 'Elegir listas';

  @override
  String get importAppleReloadLists => 'Recargar listas';

  @override
  String get importAppleNoLists =>
      'No hay listas de recordatorios disponibles en este dispositivo.';

  @override
  String get importAppleDenied =>
      'El acceso a Recordatorios está desactivado. Permite el acceso a Trayzero en Ajustes de iOS y vuelve a intentarlo.';

  @override
  String get importAppleUnavailable =>
      'No se pudo leer Recordatorios de Apple. Vuelve a intentarlo.';

  @override
  String get importAppleListsChanged =>
      'Una lista seleccionada ya no está disponible. Recarga las listas y vuelve a seleccionar.';

  @override
  String get importAppleLimits =>
      'Tus recordatorios de Apple no cambian. No se copian las etiquetas de Apple, indicadores, archivos adjuntos, estructura de subtareas, prioridades ni avisos originales. Volver a importar puede duplicar tareas.';

  @override
  String get importHintMicrosoftTodo =>
      'Inicia sesión para copiar listas y tareas pendientes. Revisa antes de importar; repetir la importación puede crear duplicados.';

  @override
  String get importMicrosoftUnavailable =>
      'La importación de Microsoft To Do no está disponible en esta versión.';

  @override
  String get importMicrosoftSignInError =>
      'El inicio de sesión en Microsoft falló o caducó. Vuelve a iniciar sesión.';

  @override
  String get importMicrosoftPermissionError =>
      'Microsoft no permitió acceder a tus tareas. Revisa los permisos o contacta con tu organización.';

  @override
  String get importMicrosoftNetworkError =>
      'No se pudieron leer todas las tareas de Microsoft. No se importó nada. Revisa tu conexión e inténtalo de nuevo.';

  @override
  String importWarnSourceDetails(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count tareas tienen archivos adjuntos, ajustes de recordatorio o estados que no se importan',
      one:
          '1 tarea tiene archivos adjuntos, ajustes de recordatorio o un estado que no se importan',
    );
    return '$_temp0';
  }

  @override
  String get moreGroupOrganize => 'Organizar';

  @override
  String get moreGroupPreferences => 'Preferencias';

  @override
  String get moreGroupData => 'Datos';

  @override
  String get moreOn => 'Sí';

  @override
  String get moreOff => 'No';

  @override
  String moreAppearanceSummary(String theme, String palette) {
    return '$theme · $palette';
  }

  @override
  String get moreRemindersBlockedTitle => 'Los recordatorios están bloqueados';

  @override
  String get moreRemindersBlockedBody =>
      'Las notificaciones están desactivadas, así que los recordatorios no pueden avisarte.';

  @override
  String get moreBackupFailedTitle => 'Falló la copia de seguridad';

  @override
  String get moreBackupFailedBody =>
      'La copia automática no se pudo guardar. Revisa la carpeta y el espacio libre.';

  @override
  String get moreFix => 'Arreglar';

  @override
  String get moreBackupRestore => 'Copia y restauración';

  @override
  String get moreBackupSubtitleOff => 'La copia automática está desactivada';

  @override
  String get moreBackupSubtitleFailed => 'Falló la copia de seguridad';

  @override
  String get moreImportSources => 'Todoist, TickTick, OmniFocus y más';

  @override
  String get moreSupportTrailing => 'Opcional';

  @override
  String get moreSupportTrailingSupporter => 'Colaborador';

  @override
  String get moreAboutPrivacy => 'Acerca de y privacidad';

  @override
  String get moreHowGtdWorks => 'Cómo funciona GTD';

  @override
  String get moreNudgesGroup => 'Avisos';

  @override
  String get moreTimingGroup => 'Horarios';

  @override
  String get moreLeadOff => 'Desactivado';

  @override
  String get moreLead10 => '10 minutos antes';

  @override
  String get moreLead30 => '30 minutos antes';

  @override
  String get moreLead60 => '1 hora antes';

  @override
  String get moreLead1440 => '1 día antes';

  @override
  String moreLeadOther(int minutes) {
    return '$minutes minutos antes';
  }

  @override
  String moreRestoredEntries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'restauraron $count entradas',
      one: 'restauró 1 entrada',
    );
    return 'Se $_temp0.';
  }

  @override
  String get moreBackupEmpty => 'Esta copia no tiene entradas que restaurar.';

  @override
  String get moreCouldntOpenLink => 'No se pudo abrir el enlace';

  @override
  String moreVersionBuild(String version, String build) {
    return '$version (compilación $build)';
  }

  @override
  String get supportBestValue => 'Mejor valor';

  @override
  String get importListIntro =>
      'Elige dónde están ahora tus tareas. Verás una vista previa antes de añadir nada.';

  @override
  String get importGroupDirect => 'Conectar directamente';

  @override
  String get importGroupFile => 'Desde un archivo de exportación';

  @override
  String get importGroupOther => 'Cualquier otra cosa';

  @override
  String get importSubGoogleTasks => 'Takeout · Tasks.json';

  @override
  String get importSubTodoist => 'Plantilla CSV o ZIP de copia';

  @override
  String get importSubThings => 'ZIP de la base de datos o main.sqlite';

  @override
  String get importSubTickTick => 'CSV de copia de seguridad';

  @override
  String get importSubNirvana => 'Exportación CSV o JSON';

  @override
  String get importSubOmniFocus => 'Archivo TaskPaper o pegar';

  @override
  String get importSubPlainText => 'Pega una lista, una tarea por línea';

  @override
  String get importSubApple => 'Elige listas en este dispositivo';

  @override
  String get importSubMicrosoft => 'Listas y tareas abiertas';

  @override
  String get importChipOnDevice => 'En el dispositivo';

  @override
  String get importChipSignIn => 'Iniciar sesión';

  @override
  String get importBackupFooter => '¿Restauras una copia de Trayzero?';

  @override
  String get importBackupFooterLink => 'Copia y restauración';

  @override
  String get importThingsDeviceIos => 'iPhone / iPad';

  @override
  String get importThingsDeviceMac => 'Mac';

  @override
  String get importCopyCode => 'Copiar código';

  @override
  String get importCodeCopied => 'Código copiado';

  @override
  String get importConnect => 'Conectar';

  @override
  String get importStepGoogleTasks1 =>
      'Abre Google Takeout y selecciona solo Tasks.';

  @override
  String get importStepGoogleTasks2 =>
      'Expórtalo como JSON y descomprime la descarga.';

  @override
  String get importStepGoogleTasks3 => 'Elige Tasks.json abajo.';

  @override
  String get importNoteGoogleTasks =>
      'Las listas se guardan en las notas; las tareas completadas van a Hecho.';

  @override
  String get importStepTodoist1 =>
      'Abre el menú de un proyecto y elige Exportar como plantilla (CSV).';

  @override
  String get importStepTodoist2 =>
      'O guarda un ZIP de copia desde Ajustes › Copias de seguridad.';

  @override
  String get importStepTodoist3 => 'Elige el archivo abajo.';

  @override
  String get importStepTickTick1 =>
      'En el sitio web de TickTick, abre Ajustes › Cuenta.';

  @override
  String get importStepTickTick2 =>
      'Abre Copia e importación y pulsa Generar copia (CSV).';

  @override
  String get importStepTickTick3 => 'Elige el CSV abajo.';

  @override
  String get importStepNirvana1 =>
      'En la app web de Nirvana, exporta tus datos como CSV o JSON.';

  @override
  String get importStepNirvana2 => 'Elige el archivo abajo.';

  @override
  String get importStepOmniFocus1 => 'En OmniFocus, selecciona tus proyectos.';

  @override
  String get importStepOmniFocus2 => 'Elige Edición › Copiar como TaskPaper.';

  @override
  String get importStepOmniFocus3 =>
      'Pega el texto abajo, o guárdalo como archivo y elígelo.';

  @override
  String get importStepPlainText1 =>
      'Copia tus tareas desde cualquier app, una tarea por línea.';

  @override
  String get importStepPlainText2 => 'Pulsa Pegar texto abajo y pégalas.';

  @override
  String get importNotePlainText =>
      'Solo importación de texto básico. No se admiten exportaciones de bases de datos de otras apps.';

  @override
  String get importStepApple1 => 'Pulsa Elegir listas abajo.';

  @override
  String get importStepApple2 =>
      'Permite el acceso a Recordatorios cuando se te pida.';

  @override
  String get importStepApple3 => 'Marca las listas que quieras importar.';

  @override
  String get importNoteApple =>
      'Solo se importan los recordatorios abiertos. Tus recordatorios de Apple no cambian.';

  @override
  String get importStepMicrosoft1 =>
      'Pulsa Conectar e inicia sesión en Microsoft.';

  @override
  String get importStepMicrosoft2 =>
      'Trayzero copia tus listas y tareas abiertas.';

  @override
  String get importStepMicrosoft3 =>
      'Revisa la vista previa antes de importar.';

  @override
  String get importNoteMicrosoft => 'Importar de nuevo puede crear duplicados.';

  @override
  String get importStepThingsIos1 =>
      'En Things, abre Ajustes › General › Diagnóstico › Introducir código e introduce:';

  @override
  String get importStepThingsIos2 =>
      'Pulsa Enviar base de datos de Things y guárdala en Archivos.';

  @override
  String get importStepThingsIos3 =>
      'En Archivos, descomprime el .aar y luego comprime la carpeta de la base de datos en ZIP.';

  @override
  String get importStepThingsIos4 => 'Elige ese ZIP abajo.';

  @override
  String get importStepThingsMac1 => 'Cierra Things en tu Mac.';

  @override
  String get importStepThingsMac2 =>
      'Copia Things Database.thingsdatabase de la carpeta de Things y comprime la copia en ZIP.';

  @override
  String get importStepThingsMac3 =>
      'Pasa el ZIP (o su main.sqlite) a este dispositivo y elígelo abajo.';

  @override
  String get importNoteThings =>
      'Las repeticiones y los recordatorios no se transfieren. Vuelve a crearlos tras importar.';

  @override
  String get importReviewTitle => 'Revisar importación';

  @override
  String importFromSource(String source) {
    return 'Desde $source';
  }

  @override
  String importTotalTasks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tareas',
      one: '1 tarea',
    );
    return '$_temp0';
  }

  @override
  String importActionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Importar $count tareas',
      one: 'Importar 1 tarea',
    );
    return '$_temp0';
  }

  @override
  String importNewExistingSummary(int newCount, int existingCount) {
    return '$newCount nuevos · $existingCount existentes';
  }

  @override
  String importShowAll(int count) {
    return 'Ver los $count';
  }

  @override
  String get importContextsAndTags => 'Contextos y etiquetas';

  @override
  String importNotesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notas',
      one: '1 nota',
    );
    return '$_temp0';
  }

  @override
  String get notificationStatusOnTitle => 'Recordatorios activados';

  @override
  String get notificationStatusOnBody =>
      'Los recordatorios te avisarán en este dispositivo.';

  @override
  String get notificationStatusOffTitle => 'Recordatorios desactivados';

  @override
  String get notificationStatusOffBody =>
      'Los recordatorios están programados, pero no te avisarán hasta que permitas las notificaciones.';

  @override
  String get notificationStatusBlockedTitle => 'Recordatorios bloqueados';

  @override
  String get notificationStatusBlockedBody =>
      'Las notificaciones de Trayzero están desactivadas en los ajustes del sistema. Los recordatorios no te avisarán hasta que las vuelvas a activar allí.';

  @override
  String get notificationActionEnable => 'Activar notificaciones';

  @override
  String get notificationActionOpenSettings => 'Abrir Ajustes';

  @override
  String get notificationPrimerTitle => '¿Activar los recordatorios?';

  @override
  String get notificationPrimerBody =>
      'Trayzero te recuerda las fechas de vencimiento y tu revisión semanal mostrando una notificación en este dispositivo. No se envía nada a ningún servidor: los recordatorios se programan localmente.\n\nAhora tu dispositivo te pedirá permiso para mostrar notificaciones.';

  @override
  String get notificationPrimerNotNow => 'Ahora no';

  @override
  String get notificationPrimerContinue => 'Continuar';

  @override
  String get notificationPromptFailed =>
      'No se pudo abrir el aviso de notificaciones.';

  @override
  String get notificationAlreadyOn => 'Los recordatorios ya están activados.';

  @override
  String get notificationOpenedSettings =>
      'Se abrieron los ajustes del sistema: activa las notificaciones de Trayzero.';

  @override
  String get notificationStayOff =>
      'Los recordatorios siguen desactivados. Puedes activarlos cuando quieras en Más → Recordatorios.';

  @override
  String get notificationNowOn => 'Los recordatorios están activados.';

  @override
  String get notificationBlocked =>
      'Las notificaciones están bloqueadas para Trayzero.';

  @override
  String get exactAlarmSettingsFailed =>
      'No se pudieron abrir los ajustes de alarmas exactas.';

  @override
  String get exactAlarmAlreadyOn =>
      'La sincronización precisa de recordatorios ya está activada.';

  @override
  String get exactAlarmNowOn =>
      'La sincronización precisa de recordatorios está activada.';

  @override
  String get exactAlarmStaysOff =>
      'La sincronización precisa de recordatorios sigue desactivada. Los recordatorios cortos pueden retrasarse.';

  @override
  String get attachmentRemoved => 'Adjunto eliminado.';

  @override
  String get discardCaptureTitle => '¿Descartar esta captura?';

  @override
  String get discardCaptureBody => 'Se perderá lo que escribiste.';

  @override
  String get keepEditing => 'Seguir editando';

  @override
  String get discard => 'Descartar';

  @override
  String get processFiledSnackbar => 'Archivado.';

  @override
  String get errorLoadTitle => 'No se pudo cargar';

  @override
  String get errorLoadBody => 'Tus datos están a salvo. Inténtalo de nuevo.';

  @override
  String sharedAddedToInbox(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementos añadidos a la bandeja de entrada',
      one: '1 elemento añadido a la bandeja de entrada',
    );
    return '$_temp0';
  }

  @override
  String get filterByProject => 'Filtrar por proyecto';

  @override
  String get projectStatusActive => 'Activo';

  @override
  String get projectStatusOnHold => 'En pausa';

  @override
  String get projectStatusSomeday => 'Algún día';

  @override
  String get projectStatusDone => 'Hecho';

  @override
  String get projectStatusDropped => 'Descartado';

  @override
  String get projectChangeStatus => 'Cambiar estado';

  @override
  String get projectAwaitingTooltip =>
      'En espera: avanza mediante elementos en espera o programados';

  @override
  String get projectStalledTooltip =>
      'Estancado: sin próxima acción, elemento en espera ni programado';

  @override
  String get projectStalledBanner =>
      'Estancado: no hay próxima acción, elemento en espera ni programado. Añade una próxima acción para ponerlo en marcha.';

  @override
  String get projectAwaitingBanner =>
      'Este proyecto avanza solo mediante elementos en espera o programados. Considera añadir una próxima acción de seguimiento para que no se estanque cuando se resuelvan.';

  @override
  String projectNextActionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count próximas acciones',
      one: '1 próxima acción',
    );
    return '$_temp0';
  }

  @override
  String projectWaitingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count en espera',
      one: '1 en espera',
    );
    return '$_temp0';
  }

  @override
  String engageHiddenByFilters(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count próximas acciones están ocultas por tus filtros',
      one: '1 próxima acción está oculta por tus filtros',
    );
    return '$_temp0';
  }

  @override
  String get filterReset => 'Restablecer';

  @override
  String onboardingSeedExisting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ya tienes $count proyectos.',
      one: 'Ya tienes 1 proyecto.',
    );
    return '$_temp0';
  }

  @override
  String get purchaseErrUnavailable =>
      'Las compras no están disponibles en este momento.';

  @override
  String get purchaseErrProducts =>
      'No se pudieron cargar los productos. Comprueba tu conexión e inténtalo de nuevo.';

  @override
  String get purchaseErrOption =>
      'Esa opción no está disponible en este momento.';

  @override
  String get purchaseErrNetwork =>
      'Error de red. Comprueba tu conexión e inténtalo de nuevo.';

  @override
  String get purchaseErrNotAllowed =>
      'No se permiten compras en este dispositivo.';

  @override
  String get purchaseErrPending => 'Tu compra está pendiente de aprobación.';

  @override
  String get purchaseErrAlreadyOwned =>
      'Ya lo tienes: prueba a restaurar compras.';

  @override
  String get purchaseErrStore =>
      'La tienda tiene problemas. Inténtalo de nuevo más tarde.';

  @override
  String get purchaseErrUnknown =>
      'Algo salió mal con la compra. Inténtalo de nuevo.';

  @override
  String get backupErrEmpty =>
      'La copia de seguridad está vacía: no hay nada que importar.';

  @override
  String get backupErrInvalidJson =>
      'Esto no es un JSON válido. Asegúrate de seleccionar un archivo de copia de seguridad de Trayzero completo y sin editar.';

  @override
  String get backupErrNotBackup =>
      'Este archivo no es una copia de seguridad de Trayzero.';

  @override
  String get backupErrNewerVersion =>
      'Esta copia de seguridad se creó con una versión más reciente de la app. Actualiza Trayzero e inténtalo de nuevo.';

  @override
  String get backupErrUnrecognized =>
      'Este archivo no parece una copia de seguridad de Trayzero.';

  @override
  String get backupErrInvalidData =>
      'Esta copia de seguridad contiene datos no válidos y no se puede importar.';

  @override
  String get backupErrReminders =>
      'Tus datos se restauraron, pero no se pudieron actualizar algunos recordatorios. Repite la importación para actualizarlos.';

  @override
  String get backupErrRestoreFailed =>
      'Algo salió mal al restaurar. Tus datos existentes no se modificaron con este intento.';

  @override
  String backupCountItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementos',
      one: '1 elemento',
    );
    return '$_temp0';
  }

  @override
  String backupCountProjects(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count proyectos',
      one: '1 proyecto',
    );
    return '$_temp0';
  }

  @override
  String backupCountContexts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contextos',
      one: '1 contexto',
    );
    return '$_temp0';
  }

  @override
  String backupCountAreas(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count áreas',
      one: '1 área',
    );
    return '$_temp0';
  }

  @override
  String backupCountAttachments(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count adjuntos',
      one: '1 adjunto',
    );
    return '$_temp0';
  }

  @override
  String backupCountReviews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count revisiones',
      one: '1 revisión',
    );
    return '$_temp0';
  }

  @override
  String get restoreFolderTitle => 'Restaurar desde la carpeta de copias';

  @override
  String get restoreFolderIntro =>
      'Elige la carpeta donde Trayzero guarda las copias, por ejemplo una gestionada por iCloud Drive, Google Drive o Syncthing. Al restaurar, la copia se combina con los datos de este dispositivo; no se elimina nada de lo que ya hay.';

  @override
  String get restoreFolderChoose => 'Elegir carpeta de copias';

  @override
  String get restoreFolderChange => 'Elegir otra carpeta';

  @override
  String restoreFolderFrom(String name) {
    return 'Carpeta: $name';
  }

  @override
  String get restoreFolderEmpty =>
      'No se encontraron copias de Trayzero en esta carpeta.';

  @override
  String get restoreFolderFailed =>
      'No se pudo abrir esta carpeta. Comprueba que sigue disponible o elígela de nuevo.';

  @override
  String restoreFolderItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementos',
      one: '1 elemento',
    );
    return '$_temp0';
  }

  @override
  String get restoreFolderUnreadable => 'No se puede leer este archivo';

  @override
  String get restoreFolderReading => 'Leyendo…';

  @override
  String get onboardingRestoreAction =>
      '¿Vienes de otro dispositivo? Restaura una copia';

  @override
  String folderBackupStale(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days días',
      one: '1 día',
    );
    return 'Sin copia reciente desde hace $_temp0.';
  }

  @override
  String get folderBackupRepairHint =>
      'Elige la carpeta de nuevo si las copias han dejado de funcionar.';

  @override
  String moreBackupSubtitleStale(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days días',
      one: '1 día',
    );
    return 'Sin copia reciente desde hace $_temp0 · toca para reparar';
  }

  @override
  String get backupPromptTitle => 'Copia tus tareas automáticamente';

  @override
  String get backupPromptBody =>
      'Ya has capturado mucho. Elige una carpeta de tu propia nube o app de sincronización y Trayzero guardará allí las últimas 10 copias. Es copia de seguridad, no sincronización.';

  @override
  String get backupPromptAction => 'Elegir carpeta';

  @override
  String get backupPromptDismiss => 'No, gracias';

  @override
  String backupCardHealthy(String date) {
    return 'Copia guardada $date';
  }

  @override
  String get backupCardOffBody =>
      'Actívalo para guardar una copia en una carpeta tras cada cambio.';

  @override
  String get backupCardTurnOn => 'Activar';

  @override
  String get backupCardChooseAgain => 'Elegir carpeta de nuevo';

  @override
  String get backupCardTryAgain => 'Reintentar';

  @override
  String get backupGroupBackUp => 'Copia de seguridad';

  @override
  String get backupGroupRestore => 'Restaurar';

  @override
  String get backupAutoTitle => 'Copia automática';

  @override
  String get backupAutoSubtitle => 'Después de cada cambio';

  @override
  String get backupFolderTitle => 'Carpeta de copias';

  @override
  String get backupExportTitle => 'Exportar una copia';

  @override
  String get backupExportSubtitle => 'Comparte un archivo de copia una vez';

  @override
  String get backupRestoreTitle => 'Restaurar una copia';

  @override
  String get backupRestoreRowSubtitle => 'Desde tu carpeta o un archivo';

  @override
  String get backupRestoreSheetBody =>
      'Elige dónde está tu copia. Verás qué contiene antes de que cambie nada.';

  @override
  String get backupRestoreFromFolder => 'Desde la carpeta de copias';

  @override
  String get backupRestoreFromFolderHint =>
      'Recomendado: elige una copia guardada';

  @override
  String get backupRestoreFromFile => 'Desde un archivo';

  @override
  String get backupRestoreFromFileHint => 'Una copia de Trayzero (.json)';

  @override
  String get backupRestorePaste => 'Pegar texto de la copia';

  @override
  String get backupFootnote =>
      'Es una copia, no sincronización: tu nube o app de sincronización lleva la carpeta entre dispositivos.';

  @override
  String get backupCardJustNow => 'Copia guardada ahora mismo';

  @override
  String backupCardMinutesAgo(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minutos',
      one: '1 minuto',
    );
    return 'Copia guardada hace $_temp0';
  }

  @override
  String backupCardHoursAgo(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours horas',
      one: '1 hora',
    );
    return 'Copia guardada hace $_temp0';
  }

  @override
  String get backupCardYesterday => 'Copia guardada ayer';

  @override
  String get backupHowItWorks => 'Cómo funciona';

  @override
  String get backupHowTitle => 'Cómo funcionan las copias';

  @override
  String get backupHowSaves =>
      'Tras cada cambio, Trayzero guarda una copia JSON de tus datos en la carpeta que elijas y conserva las últimas 10 copias.';

  @override
  String get backupHowSync =>
      'Tu nube o app de sincronización (por ejemplo iCloud Drive, Google Drive o Syncthing) lleva esa carpeta a tus otros dispositivos. Trayzero en sí nunca sube ni sincroniza nada.';

  @override
  String get backupHowMove =>
      'Para pasar a otro dispositivo, elige «Restaurar una copia» y luego «Desde la carpeta de copias».';

  @override
  String get microphoneAccessDenied =>
      'El acceso al micrófono está desactivado. Actívalo en Ajustes para grabar una nota de voz.';

  @override
  String get filterTimeEnergy => 'Tiempo y energía';

  @override
  String get clearDate => 'Borrar fecha';

  @override
  String get reorderHandle => 'Arrastra para reordenar';

  @override
  String get calendarConnectionTitle => 'Conexión de calendario';

  @override
  String get calendarTogether => 'Tus planes, juntos.';

  @override
  String get calendarConnectionIntro =>
      'Ve tus compromisos de Trayzero junto al resto de tu día.';

  @override
  String get calendarConnect => 'Conectar calendario';

  @override
  String get calendarScope =>
      'Solo se publican los elementos programados del Calendario de Trayzero. Los plazos de tareas normales permanecen en Trayzero.';

  @override
  String get calendarAutomatic => 'Actualizaciones automáticas';

  @override
  String get calendarAutomaticHelp =>
      'Se actualiza al usar Trayzero y al volver a abrirlo.';

  @override
  String get calendarPaused => 'En pausa';

  @override
  String get calendarConnected => 'Conectado';

  @override
  String get calendarNeedsAttention => 'Requiere atención';

  @override
  String get calendarPauseHelp =>
      'Los eventos existentes se conservan. Los cambios esperarán hasta que reanudes las actualizaciones o elijas Actualizar ahora.';

  @override
  String calendarLinkedCount(int count) {
    return '$count eventos vinculados';
  }

  @override
  String calendarLastUpdated(String when) {
    return 'Última actualización: $when';
  }

  @override
  String get calendarChangesWaiting => 'Cambios pendientes de actualizar';

  @override
  String get calendarUpdateNow => 'Actualizar ahora';

  @override
  String get calendarManage => 'Gestionar conexión';

  @override
  String get calendarWorking => 'Actualizando conexión de calendario…';

  @override
  String get calendarRestoreAccess => 'Restaurar acceso';

  @override
  String get calendarUpdateFailed =>
      'No se pudieron aplicar algunos cambios. Arriba se muestra la última actualización correcta. Vuelve a intentarlo.';

  @override
  String get calendarRemovalPending => 'Eliminación pendiente';

  @override
  String calendarRemoveFailed(int count) {
    return 'No se pudieron eliminar $count eventos. Las actualizaciones automáticas están detenidas. Reintenta eliminarlos o desconecta y conserva los eventos restantes.';
  }

  @override
  String get calendarSaveFailed =>
      'No se pudo guardar este cambio. Revisa la configuración de la conexión e inténtalo de nuevo.';

  @override
  String get calendarNoWritable =>
      'No hay calendarios editables. Añade uno en los ajustes de calendario del dispositivo e inténtalo de nuevo.';

  @override
  String get calendarChangeDestination => 'Cambiar destino';

  @override
  String get calendarChooseDestination => 'Elige tu calendario';

  @override
  String get calendarMoveHelp =>
      'Los eventos vinculados se moverán al nuevo calendario. Los demás permanecerán en su lugar. Se conservará tu configuración actual de actualizaciones automáticas.';

  @override
  String calendarSetupCount(int count) {
    return 'Se publicarán $count elementos programados. Se reutilizarán los vínculos existentes cuando sea posible.';
  }

  @override
  String get calendarMoveEvents => 'Mover eventos vinculados';

  @override
  String get calendarConnectAndAdd => 'Conectar y añadir eventos';

  @override
  String get calendarDisconnect => 'Desconectar calendario';

  @override
  String get calendarDisconnectQuestion => '¿Desconectar calendario?';

  @override
  String get calendarDisconnectHelp =>
      'Elige qué hacer con los eventos vinculados. Tus elementos de Trayzero y otros eventos del calendario se conservarán.';

  @override
  String get calendarKeepEvents => 'Conservar eventos en mi calendario';

  @override
  String get calendarKeepHelp =>
      'Detener las actualizaciones y conservar los eventos. Al reconectar se pueden reutilizar estos vínculos.';

  @override
  String calendarRemoveEvents(int count) {
    return 'Eliminar $count eventos vinculados';
  }

  @override
  String get calendarRemoveHelp =>
      'Eliminar solo los eventos vinculados a esta conexión. Las eliminaciones fallidas se pueden reintentar.';

  @override
  String get calendarHowItWorks => 'Cómo funcionan los eventos vinculados';

  @override
  String get calendarRules =>
      'Trayzero publica los elementos programados del Calendario en el calendario elegido del dispositivo. Los plazos de tareas normales quedan excluidos.\n\nEdita títulos, notas, horas y repeticiones en Trayzero. Al actualizar se pueden sobrescribir cambios de tu app de calendario. Los eventos duran actualmente una hora.\n\nCompletar, enviar a la papelera o sacar un elemento del Calendario elimina su evento en la siguiente actualización. Las series recurrentes avanzan a la siguiente aparición.\n\nPausar conserva eventos y vínculos. Al desconectar puedes conservar o eliminar eventos vinculados. Nunca se eliminan elementos de Trayzero al desconectar.';

  @override
  String get calendarBringEvents => 'Traer eventos a Trayzero';

  @override
  String get calendarImportCopies =>
      'Elige eventos para copiar a tu Bandeja de entrada o Calendario. Las copias no reflejan cambios posteriores de los originales. Los originales no cambian.';

  @override
  String get calendarChooseEvents => 'Elegir eventos';

  @override
  String get calendarImportSource => 'Elegir calendario de origen';

  @override
  String get calendarImportDestination => 'Añadir eventos seleccionados a';

  @override
  String calendarAddSelected(int count) {
    return 'Añadir $count eventos';
  }

  @override
  String get calendarNoImportEvents =>
      'No hay eventos nuevos para importar. Se excluyen los ya añadidos o vinculados a Trayzero. El intervalo abarca los últimos 7 días y el próximo año.';

  @override
  String get calendarImportFailed =>
      'No se pudieron importar los eventos. Comprueba el acceso al calendario e inténtalo de nuevo.';

  @override
  String get calendarDeviceHelp =>
      'Usa el calendario del dispositivo. No necesitas cuenta de Trayzero. Otras personas con acceso a un calendario compartido pueden ver sus eventos.';
}
