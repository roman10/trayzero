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
  String get edit => 'Editar';

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
  String get rename => 'Cambiar nombre';

  @override
  String get inbox => 'Bandeja de entrada';

  @override
  String get doVerb => 'Hacer';

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
  String get actionableQuestion => '¿Es accionable?';

  @override
  String get actionableYes => 'Sí — hay algo que hacer';

  @override
  String get actionableReference => 'No — guardar como referencia';

  @override
  String get actionableSomeday => 'No — algún día / tal vez';

  @override
  String get actionableTrash => 'Eliminar';

  @override
  String get twoMinQuestion => '¿Lleva menos de 2 minutos?';

  @override
  String get twoMinYes => 'Sí — lo hago ahora';

  @override
  String get twoMinNo => 'No';

  @override
  String get delegateQuestion => '¿Puede hacerlo otra persona?';

  @override
  String get waitingOnPromptTitle => '¿A quién esperas?';

  @override
  String get waitingOnPromptHint => 'Nombre o sistema';

  @override
  String get multiStepQuestion => '¿Requiere más de un paso?';

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
  String get engageNoMatchMessage =>
      'Nada coincide con los filtros actuales. Prueba a ampliarlos o quítalos.';

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
  String projectActionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count acciones',
      one: '1 acción',
    );
    return '$_temp0';
  }

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
  String get projectMissingNextActionError =>
      'Sin siguiente acción definida. Cada proyecto activo debería tener al menos una.';

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
      'Cada proyecto debe estar activo, en pausa o hecho — y cada proyecto activo debe tener una siguiente acción.';

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
  String get themeFollowSystem => 'Seguir al sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get hapticFeedback => 'Vibración táctil';

  @override
  String get organizationSection => 'Organización';

  @override
  String get contextsLabel => 'Contextos';

  @override
  String get areasOfFocusLabel => 'Áreas de enfoque';

  @override
  String get areasOfFocusDescription =>
      'Agrupa proyectos por esferas de responsabilidad.';

  @override
  String get calendarSyncLabel => 'Sincronización de calendario';

  @override
  String get calendarSyncDescription =>
      'Refleja las tareas con fecha en el calendario del sistema.';

  @override
  String get remindersSection => 'Recordatorios';

  @override
  String get weeklyReviewNudge => 'Aviso Revisión Semanal';

  @override
  String get weeklyReviewNudgeDescription =>
      'Un recordatorio suave cada viernes a las 16:00.';

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
  String get dataSection => 'Datos';

  @override
  String get exportBackup => 'Exportar copia';

  @override
  String get exportBackupDescriptionIos =>
      'Comparte un JSON. Guárdalo en iCloud Drive como respaldo.';

  @override
  String get exportBackupDescriptionAndroid =>
      'Comparte un JSON. Guárdala en Google Drive como respaldo.';

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
  String get importBackup => 'Importar copia';

  @override
  String get importBackupDescription =>
      'Restaura una copia de Trayzero o importa Google Tasks.';

  @override
  String get importConfirmTitle => '¿Importar esta copia?';

  @override
  String importConfirmBody(String sections) {
    return 'Se añadirán o actualizarán $sections.\n\nLas entradas con el mismo ID se sobrescribirán. No se puede deshacer.';
  }

  @override
  String get importButton => 'Importar';

  @override
  String get importSourceSheetTitle => 'Importar copia';

  @override
  String get importFromFileTitle => 'Elegir archivo';

  @override
  String get importFromFileDescription =>
      'Recomendado — .json de Trayzero o Tasks.json de Google.';

  @override
  String get importFromPasteTitle => 'Pegar JSON';

  @override
  String get importFromPasteDescription =>
      'Pega el texto de la copia directamente.';

  @override
  String get pasteBackupHint => 'Pega aquí el JSON…';

  @override
  String get privacySection => 'Privacidad';

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
  String get aboutSection => 'Acerca de';

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
  String get decisionNotActionableQ => '¿No es accionable?';

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
  String get decisionOtherwiseQ => 'Si no';

  @override
  String get decisionOtherwiseA => 'Define la siguiente acción';

  @override
  String get supportTitle => 'Apoya a Trayzero';

  @override
  String get supportSummaryDefault =>
      'Da una propina al desarrollador o hazte colaborador';

  @override
  String get supportSummarySupporter => 'Gracias por apoyar a Trayzero 💙';

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
    return '$price / año · mejor precio · desbloquea ventajas de colaborador';
  }

  @override
  String get supportSupporterMonthly => 'Colaborador — mensual';

  @override
  String supportSupporterMonthlySubtitle(String price) {
    return '$price / mes · cancela cuando quieras';
  }

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
}
