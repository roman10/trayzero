// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'Trayzero';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Salvar';

  @override
  String get delete => 'Excluir';

  @override
  String get add => 'Adicionar';

  @override
  String get ok => 'OK';

  @override
  String get next => 'Próximo';

  @override
  String get back => 'Voltar';

  @override
  String get skip => 'Pular';

  @override
  String get done => 'Concluído';

  @override
  String get undo => 'Desfazer';

  @override
  String get retry => 'Tentar de novo';

  @override
  String get settings => 'Ajustes';

  @override
  String get enable => 'Ativar';

  @override
  String get none => 'Nenhum';

  @override
  String get notSet => 'Não definido';

  @override
  String get search => 'Buscar';

  @override
  String get select => 'Selecionar';

  @override
  String get selectAll => 'Tudo';

  @override
  String get selectNone => 'Nenhum';

  @override
  String get inbox => 'Caixa de entrada';

  @override
  String get projects => 'Projetos';

  @override
  String get review => 'Revisar';

  @override
  String get more => 'Mais';

  @override
  String get navInbox => 'Caixa';

  @override
  String get navDo => 'Fazer';

  @override
  String get navProjects => 'Projetos';

  @override
  String get navReview => 'Revisar';

  @override
  String get navMore => 'Mais';

  @override
  String get capture => 'Capturar';

  @override
  String get clarify => 'Esclarecer';

  @override
  String get organize => 'Organizar';

  @override
  String get reflect => 'Refletir';

  @override
  String get engage => 'Executar';

  @override
  String get nextAction => 'Próxima ação';

  @override
  String get waitingFor => 'Aguardando';

  @override
  String get someday => 'Algum dia';

  @override
  String get somedayMaybe => 'Algum dia / talvez';

  @override
  String get reference => 'Referência';

  @override
  String get calendar => 'Agenda';

  @override
  String get project => 'Projeto';

  @override
  String get completed => 'Concluído';

  @override
  String get scheduled => 'Agendado';

  @override
  String get needsClarifying => 'A esclarecer';

  @override
  String get howGtdWorks => 'Como o GTD funciona';

  @override
  String get whatIsGtd => 'O que é GTD?';

  @override
  String get onboardingPage1Title => 'Tire isso da cabeça';

  @override
  String get onboardingPage1Body =>
      'Tudo o que estiver ocupando sua mente — uma tarefa, uma ideia, uma preocupação — vai para a Caixa de entrada. A intenção é liberar a mente, organizar fica para depois.';

  @override
  String get onboardingPage2Title => 'Esclareça, um item de cada vez';

  @override
  String get onboardingPage2Body =>
      'O fluxo de Esclarecer passa cada item capturado pela árvore de decisão do GTD: é acionável? Leva menos de dois minutos? Delegar? É um projeto? Uma próxima ação?';

  @override
  String get onboardingPage3Title => 'Execute quando tiver tempo';

  @override
  String get onboardingPage3Body =>
      'A aba Fazer filtra suas próximas ações por contexto, energia e tempo disponível — você sempre sabe o que pode estar fazendo agora.';

  @override
  String get onboardingPage4Title => 'Revise para manter a confiança';

  @override
  String get onboardingPage4Body =>
      'A Revisão Semanal mantém o sistema honesto. Uma vez por semana, passe por cada lista, esvazie a caixa e olhe para frente.';

  @override
  String get onboardingSeedTitle => 'Tudo pronto';

  @override
  String get onboardingSeedBody =>
      'Contextos padrão (@telefone, @computador, @recados, @casa, @escritório, @qualquerLugar, @aguardando) já estão prontos. Você pode adicionar ou editar nos Ajustes.';

  @override
  String get onboardingSeedSampleLabel => 'Criar um projeto de exemplo';

  @override
  String get onboardingSeedSampleSubtitle =>
      'Adiciona um projeto inicial e alguns itens para que o app não fique vazio.';

  @override
  String get projectSectionActive => 'Ativos';

  @override
  String get projectSectionUnfiled => 'Sem pasta';

  @override
  String get projectSectionOnHold => 'Em espera';

  @override
  String get sampleProjectTitle => 'Aproveite o máximo do GTD';

  @override
  String get sampleProjectOutcome =>
      'Zerar a caixa de entrada todos os dias e fazer uma revisão semanal toda sexta-feira.';

  @override
  String get sampleItemReadPrimer => 'Ler a introdução ao GTD nos Ajustes';

  @override
  String get sampleItemEmptyEmail =>
      'Esvaziar minha caixa de entrada de e-mail aqui';

  @override
  String get sampleItemScheduleReview =>
      'Agendar uma revisão semanal recorrente às sextas-feiras';

  @override
  String get seedContextPhone => '@telefone';

  @override
  String get seedContextComputer => '@computador';

  @override
  String get seedContextErrands => '@recados';

  @override
  String get seedContextHome => '@casa';

  @override
  String get seedContextOffice => '@escritório';

  @override
  String get seedContextAnywhere => '@qualquerLugar';

  @override
  String get seedContextWaiting => '@aguardando';

  @override
  String get onboardingFinish => 'Vamos lá';

  @override
  String get inboxEmptyTitle => 'Caixa zerada';

  @override
  String get inboxEmptyMessage =>
      'Nada a esclarecer. Toque em Capturar para despejar tudo o que estiver na sua cabeça — você esclarece depois.';

  @override
  String get inboxEmptyAction => 'Capturar algo';

  @override
  String inboxItemsToClarify(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count itens para esclarecer',
      one: '1 item para esclarecer',
      zero: 'Nenhum item para esclarecer',
    );
    return '$_temp0';
  }

  @override
  String get processInbox => 'Esclarecer caixa';

  @override
  String deleteItemsConfirmTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Excluir $count itens?',
      one: 'Excluir 1 item?',
    );
    return '$_temp0';
  }

  @override
  String get deleteItemsConfirmBody =>
      'Isso remove os itens e seus anexos de forma permanente. Não dá para desfazer.';

  @override
  String deletedItemsSnackbar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count itens excluídos.',
      one: '1 item excluído.',
    );
    return '$_temp0';
  }

  @override
  String completedItemsSnackbar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count itens concluídos.',
      one: '1 item concluído.',
    );
    return '$_temp0';
  }

  @override
  String filedItemsSnackbar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count itens arquivados no projeto.',
      one: '1 item arquivado no projeto.',
    );
    return '$_temp0';
  }

  @override
  String movedItemsSnackbar(int count, String destination) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count itens movidos para $destination.',
      one: '1 item movido para $destination.',
    );
    return '$_temp0';
  }

  @override
  String selectionCountTitle(int count) {
    return '$count selecionados';
  }

  @override
  String get captureTitle => 'Esvazie a mente';

  @override
  String get captureHint => 'O que está na sua cabeça?';

  @override
  String get captureNotesHint => 'Notas (opcional)';

  @override
  String get captureEmptyError => 'Escreva algo para capturar';

  @override
  String get captureSubmit => 'Adicionar à caixa';

  @override
  String get dictate => 'Ditar';

  @override
  String get stopDictation => 'Parar ditado';

  @override
  String get dictationUnavailable =>
      'O ditado não está disponível. Você ainda pode digitar o que deseja capturar.';

  @override
  String get processTitle => 'Esclarecer caixa';

  @override
  String get processCompleteTitle => 'Caixa zerada!';

  @override
  String get processCompleteNoItems => 'Não há mais nada para esclarecer.';

  @override
  String processCompleteStats(int filed, int doneNow, int trashed) {
    return 'Você arquivou $filed, despachou $doneNow em menos de 2 minutos e descartou $trashed. Mandou bem.';
  }

  @override
  String processStepCounter(int step, int total) {
    return 'Passo $step de $total';
  }

  @override
  String processItemsRemaining(int count) {
    return '$count restantes';
  }

  @override
  String get previousStepTooltip => 'Passo anterior';

  @override
  String get skipItemTooltip => 'Pular';

  @override
  String get actionableQuestion => 'Requer ação?';

  @override
  String get actionableYes => 'Sim — há algo a fazer';

  @override
  String get actionableReference => 'Não — guardar como referência';

  @override
  String get actionableSomeday => 'Não — algum dia / talvez';

  @override
  String get actionableTrash => 'Descartar';

  @override
  String get twoMinQuestion => 'Leva menos de 2 minutos?';

  @override
  String get twoMinYes => 'Sim — faço agora';

  @override
  String get delegateQuestion => 'Outra pessoa pode fazer?';

  @override
  String get waitingOnPromptTitle => 'Você está esperando quem?';

  @override
  String get waitingOnPromptHint => 'Nome ou sistema';

  @override
  String get recurrencePrompt => 'Repete?';

  @override
  String get recurrenceOff => 'Não repete';

  @override
  String get capturedLabel => 'CAPTURADO';

  @override
  String get engageTitle => 'Fazer agora';

  @override
  String get engageEmptyTitle => 'Ainda não há próximas ações';

  @override
  String get engageEmptyMessage =>
      'Capture algo ou esclareça sua caixa de entrada para montar sua lista de próximas ações.';

  @override
  String get engageInlineEmpty =>
      'Ainda sem próximas ações — capture algo ou esclareça sua caixa.';

  @override
  String get engageOpenInbox => 'Abrir caixa';

  @override
  String get engageNoMatchTitle => 'Nada combina';

  @override
  String get hardLandscape => 'Agenda';

  @override
  String get hardLandscapeSubtitle => 'vencem hoje ou estão atrasados';

  @override
  String get filterAllContexts => 'Todos os contextos';

  @override
  String get filterAnyTime => 'Qualquer duração';

  @override
  String get filterUnder5m => '< 5 min';

  @override
  String get filterUnder15m => '< 15 min';

  @override
  String get filterUnder30m => '< 30 min';

  @override
  String get filterUnder1h => '< 1 h';

  @override
  String get filterAnyEnergy => 'Qualquer energia';

  @override
  String get energyLow => 'Baixa';

  @override
  String get energyMedium => 'Média';

  @override
  String get energyHigh => 'Alta';

  @override
  String get projectsTitle => 'Projetos';

  @override
  String get newProject => 'Novo projeto';

  @override
  String get organizeLooseActionsTooltip => 'Organizar ações soltas';

  @override
  String get projectsEmptyTitle => 'Ainda sem projetos';

  @override
  String get projectsEmptyMessage =>
      'Um projeto é qualquer resultado que precise de mais de uma ação. Crie um para agrupar as próximas ações relacionadas e seguir rumo a um resultado claro.';

  @override
  String get projectMissingNextAction => 'Sem próxima ação definida';

  @override
  String get organizeActionsTitle => 'Organizar ações';

  @override
  String get organizeEmptyTitle => 'Nada solto';

  @override
  String get organizeEmptyMessage =>
      'Todas as próximas ações já estão em algum projeto. Novas ações sem projeto aparecerão aqui para você organizar.';

  @override
  String assignToProject(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Atribuir $count a um projeto',
      one: 'Atribuir 1 a um projeto',
    );
    return '$_temp0';
  }

  @override
  String get addNextActionTitle => 'Adicionar próxima ação';

  @override
  String get addNextActionHint => 'ex.: Mandar o cronograma para a Sara';

  @override
  String get addExistingActions => 'Adicionar ações existentes';

  @override
  String get noUnassignedActionsMessage =>
      'Não há próximas ações sem projeto para trazer.';

  @override
  String addCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Adicionar $count',
      one: 'Adicionar 1',
    );
    return '$_temp0';
  }

  @override
  String get editProject => 'Editar projeto';

  @override
  String get projectName => 'Nome do projeto';

  @override
  String get projectNameHint => 'ex.: Lançar o novo site';

  @override
  String get projectNameRequired => 'Digite um nome de projeto';

  @override
  String get areaOfFocusOptional => 'Área de responsabilidade (opcional)';

  @override
  String get unfiledOption => '— Sem pasta —';

  @override
  String get dueDate => 'Vencimento';

  @override
  String get deleteProjectConfirmTitle => 'Excluir projeto?';

  @override
  String get deleteProjectWarning =>
      'Os itens vinculados ficam órfãos, mas não são excluídos.';

  @override
  String get addActionFab => 'Adicionar ação';

  @override
  String get projectOutcomeHint => 'Como é o resultado \"pronto\"?';

  @override
  String get outcomeSection => 'Resultado';

  @override
  String get nextActionsSection => 'Próximas ações';

  @override
  String get noNextActionsMessage => 'Ainda sem próximas ações.';

  @override
  String get statusTooltip => 'Status';

  @override
  String get reviewTitle => 'Revisar';

  @override
  String get weeklyReviewCardTitle => 'Revisão semanal';

  @override
  String get weeklyReviewCardSubtitle =>
      'Passe pela sua caixa, suas listas e seus projetos. O ritual que mantém o sistema confiável.';

  @override
  String get calendarEmpty => 'Nada amarrado a um dia específico.';

  @override
  String get waitingForEmpty => 'Nada delegado.';

  @override
  String get somedayEmpty => 'Sem itens para algum dia.';

  @override
  String get referenceEmpty => 'Sem itens de referência.';

  @override
  String get completedThisWeek => 'Concluído nesta semana';

  @override
  String get completedThisWeekEmpty => 'Nada concluído ainda nesta semana.';

  @override
  String bucketCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count itens',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String get needsReDecision => 'Decidir de novo';

  @override
  String pastDueCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count itens em atraso',
      one: '1 item em atraso',
    );
    return '$_temp0';
  }

  @override
  String get reviewStep1Title => 'Esvazie a cabeça';

  @override
  String get reviewStep1Body =>
      'Capture na caixa tudo o que estiver na sua mente, para que o sistema possa ser confiável.';

  @override
  String get reviewStep2Title => 'Esclareça a caixa até zerar';

  @override
  String get reviewStep2Body =>
      'Esclareça cada item capturado pela árvore de decisão até a caixa ficar vazia.';

  @override
  String get reviewStep3Title => 'Revise suas próximas ações';

  @override
  String get reviewStep3Body =>
      'Olhe cada ação. Feita? Marque. Velha? Edite ou apague. Ainda é a próxima? Deixe estar.';

  @override
  String get reviewStep4Title => 'Revise sua lista de aguardando';

  @override
  String get reviewStep4Body =>
      'Alguém respondeu? Precisa cobrar? Atualize ou remova.';

  @override
  String get reviewStep5Title => 'Revise cada projeto';

  @override
  String get reviewStep5Body =>
      'Revê cada resultado. Adiciona uma próxima ação aos projetos parados, coloca-os em pausa ou marca-os como concluídos. As tarefas em espera e agendadas também contam como progresso.';

  @override
  String get reviewStep6Title => 'Olhe as próximas duas semanas';

  @override
  String get reviewStep6Body =>
      'Veja seus itens da agenda. Há algo para o qual você possa se preparar desde já?';

  @override
  String get reviewStep7Title => 'Revise algum dia / talvez';

  @override
  String get reviewStep7Body =>
      'Vale a pena assumir alguma coisa daqui agora? Promova para projeto ou próxima ação.';

  @override
  String reviewStepCounter(int step, int total) {
    return 'Passo $step de $total';
  }

  @override
  String get finishReview => 'Finalizar revisão';

  @override
  String get reviewCompleteSnackbar => 'Revisão semanal concluída';

  @override
  String get searchHint => 'Buscar itens, notas';

  @override
  String get searchMinChars => 'Digite pelo menos dois caracteres';

  @override
  String get clearFilters => 'Limpar filtros';

  @override
  String get clearSearch => 'Limpar busca';

  @override
  String searchNoResults(String query) {
    return 'Sem resultados para \"$query\"';
  }

  @override
  String get searchNoMatchTitle => 'Nada combina';

  @override
  String get searchNoMatchMessage =>
      'Nenhum resultado se encaixa nos filtros atuais. Tente afrouxá-los ou remova-os.';

  @override
  String get filterAllProjects => 'Todos os projetos';

  @override
  String get filterCompleted => 'Concluídos';

  @override
  String get statusInbox => 'Caixa';

  @override
  String get statusNext => 'Próxima';

  @override
  String get statusWaiting => 'Aguardando';

  @override
  String get statusSomeday => 'Algum dia';

  @override
  String get statusReference => 'Referência';

  @override
  String get appearanceSection => 'Aparência';

  @override
  String get themeLabel => 'Tema';

  @override
  String get themeFollowSystem => 'Padrão do sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Escuro';

  @override
  String get hapticFeedback => 'Retorno tátil';

  @override
  String get languageLabel => 'Idioma';

  @override
  String get languageFollowSystem => 'Padrão do sistema';

  @override
  String get contextsLabel => 'Contextos';

  @override
  String get areasOfFocusLabel => 'Áreas de responsabilidade';

  @override
  String get calendarSyncLabel => 'Sincronizar com a agenda';

  @override
  String get remindersSection => 'Lembretes';

  @override
  String get weeklyReviewNudge => 'Lembrete de revisão semanal';

  @override
  String get weeklyReviewNudgeDescription =>
      'Um lembrete sutil toda sexta-feira às 16h.';

  @override
  String get remindBeforeDue => 'Avisar antes do vencimento';

  @override
  String get remindBeforeDueOff => 'Desligado · só um alerta no vencimento';

  @override
  String get remindBeforeDueSuffix =>
      'vale para os itens salvos a partir de agora';

  @override
  String get deferSurfaceLabel => 'Itens adiados me lembram às';

  @override
  String get deferSurfaceDescription =>
      'itens adiados sem hora ficam na lista o dia inteiro e lembram você neste horário';

  @override
  String get checkingNotificationStatus =>
      'Verificando o estado das notificações…';

  @override
  String exportBackupError(String error) {
    return 'Não foi possível exportar: $error';
  }

  @override
  String get weeklyBackupReminder => 'Lembrete semanal de backup';

  @override
  String get weeklyBackupReminderDescription =>
      'Me lembre todo domingo de manhã de exportar e salvar.';

  @override
  String get importConfirmTitle => 'Importar este backup?';

  @override
  String importConfirmBody(String sections) {
    return 'Isso vai adicionar ou atualizar $sections.\n\nEntradas existentes com o mesmo id serão sobrescritas pela versão do backup. Isso não pode ser desfeito.';
  }

  @override
  String get importButton => 'Importar';

  @override
  String get importFromPasteTitle => 'Colar JSON do backup';

  @override
  String get importFromPasteDescription =>
      'Cole o texto do backup em vez de escolher arquivo.';

  @override
  String get pasteBackupHint => 'Cole o JSON aqui…';

  @override
  String get crashReports => 'Enviar relatórios de falha';

  @override
  String get crashReportsDescription =>
      'Relatórios anônimos de falhas e erros via Sentry. Nenhum dado pessoal é coletado. Desligado por padrão.';

  @override
  String get crashReportsEnabled =>
      'Os relatórios de falha serão enviados na próxima abertura';

  @override
  String get crashReportsDisabled => 'Relatórios de falha desligados';

  @override
  String get showOnboardingAgain => 'Mostrar a introdução de novo';

  @override
  String get versionLabel => 'Versão';

  @override
  String get settingsFooter =>
      'Local primeiro. Seus dados ficam neste aparelho. Inspirado na metodologia Getting Things Done de David Allen.';

  @override
  String get editTitle => 'Editar';

  @override
  String get saveError =>
      'Não foi possível salvar as alterações. Tente novamente.';

  @override
  String get savedIndicator => 'Salvo';

  @override
  String get titleLabel => 'Título';

  @override
  String get notesLabel => 'Notas';

  @override
  String get statusSection => 'Status';

  @override
  String get contextSection => 'Contexto';

  @override
  String get energySection => 'Energia';

  @override
  String get timeEstimateSection => 'Tempo estimado';

  @override
  String get waitingOnSection => 'Aguardando';

  @override
  String get waitingOnHint => 'Quem ou o que você está aguardando?';

  @override
  String get projectSection => 'Projeto';

  @override
  String get datesSection => 'Datas';

  @override
  String get dueLabel => 'Vence';

  @override
  String get deferUntilLabel => 'Adiar até';

  @override
  String get repeatSection => 'Repetição';

  @override
  String get recurrenceNeedsDeferHint =>
      'Adicione uma data de Adiamento acima para ativar a repetição — a recorrência empurra essa data para a frente.';

  @override
  String get recurrenceNeedsDueDateHint =>
      'Adicione uma data de Vencimento ou Adiamento acima para ativar a repetição — a recorrência empurra essa data para a frente.';

  @override
  String get recurrenceExplanation =>
      'Ao concluir este item, a próxima ocorrência aparece com as datas deslocadas.';

  @override
  String get recurrenceNoDateNextActionError =>
      'Este item se repete mas não tem data de Adiamento, então concluí-lo não cria a próxima ocorrência. Adicione uma data de Adiamento acima ou desligue a repetição.';

  @override
  String get recurrenceNoDateError =>
      'Este item se repete mas não tem Vencimento nem Adiamento, então concluí-lo não cria a próxima ocorrência. Adicione uma data acima ou desligue a repetição.';

  @override
  String get attachmentsSection => 'Anexos';

  @override
  String get markComplete => 'Marcar como concluído';

  @override
  String get reopen => 'Reabrir';

  @override
  String get deleteItemConfirmTitle => 'Excluir este item?';

  @override
  String get deleteItemConfirmBody => 'Não dá para desfazer.';

  @override
  String get completeError => 'Não foi possível concluir este item.';

  @override
  String get reopenError => 'Não foi possível reabrir este item.';

  @override
  String get remindersBlockedWarning =>
      'Os lembretes estão bloqueados nos ajustes do sistema — você não vai ser avisado.';

  @override
  String get remindersOffWarning =>
      'Os lembretes estão desligados — você não vai ser avisado.';

  @override
  String get preciseReminderOffWarning =>
      'A precisão dos lembretes está desligada — lembretes curtos podem atrasar.';

  @override
  String get allowExactAlarms => 'Permitir alarmes exatos';

  @override
  String get noContextsAvailable =>
      'Ainda sem contextos — adicione alguns nos Ajustes.';

  @override
  String get noActiveProjects => 'Ainda sem projetos ativos.';

  @override
  String get attachmentPhoto => 'Foto';

  @override
  String get attachmentCamera => 'Câmera';

  @override
  String get attachmentVoiceMemo => 'Áudio';

  @override
  String get attachmentStop => 'Parar';

  @override
  String get remove => 'Remover';

  @override
  String get imageViewerClose => 'Fechar';

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
      other: '$count arquivos',
      one: '1 arquivo',
    );
    return '$_temp0';
  }

  @override
  String get areasTitle => 'Áreas de responsabilidade';

  @override
  String get newArea => 'Nova área';

  @override
  String get renameArea => 'Renomear área';

  @override
  String get areasEmptyMessage =>
      'Ainda sem áreas. Áreas são esferas contínuas de responsabilidade — Saúde, Carreira, Família — que abrigam seus projetos.';

  @override
  String get areaNameHint => 'ex.: Saúde, Carreira, Família';

  @override
  String deleteAreaConfirmTitle(String name) {
    return 'Excluir \"$name\"?';
  }

  @override
  String get deleteAreaWarning =>
      'Os projetos desta área ficarão sem pasta (não serão excluídos).';

  @override
  String get contextsTitle => 'Contextos';

  @override
  String get newContext => 'Novo contexto';

  @override
  String get editContext => 'Editar contexto';

  @override
  String get contextsEmptyMessage =>
      'Ainda sem contextos. Contextos marcam ações por onde ou com o quê dá para fazer (@telefone, @casa, @recados).';

  @override
  String get nameLabel => 'Nome';

  @override
  String get iconLabel => 'Ícone';

  @override
  String get colorLabel => 'Cor';

  @override
  String deleteContextConfirmTitle(String name) {
    return 'Excluir $name?';
  }

  @override
  String get deleteContextWarning =>
      'Itens que usam este contexto vão perdê-lo.';

  @override
  String get calendarSyncTitle => 'Sincronizar com a agenda';

  @override
  String get calendarSyncIntro =>
      'Espelha itens com vencimento na agenda do sistema e traz de volta para a caixa de entrada do Trayzero eventos marcados com \"#gtd\".';

  @override
  String get enableCalendarSync => 'Ativar sincronização com a agenda';

  @override
  String get targetCalendar => 'Agenda de destino';

  @override
  String get calendarAccessDenied =>
      'Acesso à agenda negado. Conceda para escolher uma agenda de destino.';

  @override
  String get grantCalendarAccess => 'Conceder acesso à agenda';

  @override
  String get noCalendarsAvailable =>
      'Nenhuma agenda disponível ainda. Se você acabou de conceder acesso, espere um momento e tente de novo. Verifique também se a sincronização da agenda está ligada para sua conta nos ajustes do sistema.';

  @override
  String get mirrorOutAction => 'Espelhar itens → agenda';

  @override
  String get importInAction => 'Importar eventos #gtd → caixa';

  @override
  String mirrorOutSuccess(int written) {
    return '$written itens espelhados';
  }

  @override
  String mirrorOutSuccessWithStale(int written, int removed) {
    return '$written itens espelhados, $removed obsoletos removidos';
  }

  @override
  String importInSuccess(int count) {
    return '$count eventos da agenda importados';
  }

  @override
  String get mirroringProgress => 'Espelhando…';

  @override
  String get importingProgress => 'Importando…';

  @override
  String get calendarSyncTip =>
      'Dica: coloque \"#gtd\" em qualquer lugar do título de um evento da agenda e ele aparecerá na sua caixa do Trayzero na próxima sincronização.';

  @override
  String get gtdDiagramTitle => 'Como o GTD funciona';

  @override
  String get gtdDiagramSubtitle =>
      'Cinco passos para tirar cada laço aberto da sua cabeça e colocá-lo em um sistema confiável. Toque em uma lista destacada para ir direto até lá.';

  @override
  String get gtdAttribution =>
      'Metodologia de David Allen · gettingthingsdone.com';

  @override
  String get youAreHere => 'Você está aqui';

  @override
  String get gtdStage1Body =>
      'Jogue na Caixa tudo o que estiver ocupando sua mente — tarefas, ideias, preocupações. Sem filtrar, sem organizar, ainda não.';

  @override
  String get gtdStage2Body =>
      'Pegue um item de cada vez e decida o que é. O fluxo de Esclarecer passa cada um por esta árvore de decisão:';

  @override
  String get gtdStage3Body =>
      'O resultado vai parar na lista certa, para que nada mais viva na sua cabeça.';

  @override
  String get gtdStage3Footnote =>
      'Aguardando / Agenda / Algum dia / Referência ficam em Revisar.';

  @override
  String get gtdStage4Body =>
      'Revise suas listas regularmente — principalmente na Revisão Semanal — para que o sistema continue confiável.';

  @override
  String get gtdStage5Body =>
      'Só faça o trabalho — escolha ações por contexto, tempo, energia e prioridade, com a mente limpa.';

  @override
  String get decisionNotActionableQ => 'Não é acionável?';

  @override
  String get decisionNotActionableA =>
      'Descartar, Algum dia/talvez ou Referência';

  @override
  String get decisionTwoMinQ => 'Menos de 2 minutos?';

  @override
  String get decisionTwoMinA => 'Faça agora mesmo';

  @override
  String get decisionDelegateQ => 'Outra pessoa deveria fazer?';

  @override
  String get decisionDelegateA => 'Delegar → Aguardando';

  @override
  String get decisionMultiStepQ => 'Precisa de mais de um passo?';

  @override
  String get decisionMultiStepA => 'Vire um Projeto';

  @override
  String get decisionOtherwiseQ => 'Caso contrário';

  @override
  String get decisionOtherwiseA => 'Defina a próxima ação concreta';

  @override
  String get supportTitle => 'Apoiar o Trayzero';

  @override
  String get supportIntro =>
      'O Trayzero é gratuito, com todos os recursos liberados. Se ele te ajuda, você pode contribuir — isso mantém o app independente e sem anúncios.';

  @override
  String get supportUnavailable =>
      'As opções de apoio estão indisponíveis no momento.';

  @override
  String get supportTipHeader => 'Deixar uma gorjeta';

  @override
  String get supportTipSmall => 'Gorjeta pequena';

  @override
  String get supportTipLarge => 'Gorjeta grande';

  @override
  String get supportSupporterYearly => 'Apoiador — anual';

  @override
  String supportSupporterYearlySubtitle(String price) {
    return '$price / ano · melhor valor · apoia o desenvolvimento';
  }

  @override
  String get supportSupporterMonthly => 'Apoiador — mensal';

  @override
  String supportSupporterMonthlySubtitle(String price) {
    return '$price / mês · cancele quando quiser';
  }

  @override
  String supportOpeningStore(String store) {
    return 'Abrindo $store…';
  }

  @override
  String get supportRestoring => 'Restaurando compras…';

  @override
  String get supportRestore => 'Restaurar compras';

  @override
  String get supportRestoreSubtitle =>
      'Já é apoiador? Restaure neste dispositivo.';

  @override
  String get supportAutoRenewNote =>
      'As assinaturas renovam automaticamente até serem canceladas nos Ajustes.';

  @override
  String get legalPrivacyPolicy => 'Política de Privacidade';

  @override
  String get legalTermsOfUse => 'Termos de Uso';

  @override
  String get supportThanksTip => 'Muitíssimo obrigado! 💙';

  @override
  String get supportThanksSupporter => 'Você agora é apoiador — obrigado! 💙';

  @override
  String get supportRestored => 'Compras restauradas. Bem-vindo de volta! 💙';

  @override
  String get supportRestoreNone => 'Nenhuma compra anterior encontrada.';

  @override
  String get supportBadgeYearly => 'Apoiador · anual';

  @override
  String get supportBadgeMonthly => 'Apoiador · mensal';

  @override
  String get supportBadgeGeneric => 'Apoiador';

  @override
  String get supportBadgeSubtitle =>
      'Obrigado por manter o Trayzero independente.';

  @override
  String get calendarLookupFailed =>
      'Não foi possível carregar os calendários. Verifique a sincronização da conta no aplicativo Calendário e tente novamente.';

  @override
  String get calendarPermissionHelp =>
      'Se a solicitação não aparecer, permita o acesso ao calendário nas configurações do aplicativo e volte aqui.';

  @override
  String get calendarOpenSettings => 'Abrir configurações do aplicativo';

  @override
  String get calendarSettingsFailed =>
      'Abra as configurações do dispositivo e permita que o Trayzero acesse o calendário.';

  @override
  String get calendarSelectionUnavailable =>
      'O calendário selecionado não está mais disponível. Escolha outro calendário.';

  @override
  String get appIcon => 'Ícone do app';

  @override
  String get appIconAndroidDescription =>
      'Escolha um ícone da tela inicial independente da cor do app. O inicializador pode levar um momento para atualizar ou aplicar sua própria tonalidade.';

  @override
  String get appIconDescription =>
      'Escolha um ícone independente da cor do app. O dispositivo pode aplicar sua própria tonalidade. O iOS mostra um aviso ao alterar o ícone.';

  @override
  String get appIconChangeFailed =>
      'Não foi possível alterar o ícone. Tente novamente com o Trayzero aberto.';

  @override
  String get appColor => 'Cor do app';

  @override
  String get appColorDescription =>
      'Funciona nos modos claro e escuro. As cores das listas GTD mantêm seu significado.';

  @override
  String get paletteAmber => 'Âmbar Trayzero — Padrão';

  @override
  String get paletteBlue => 'Azul';

  @override
  String get paletteCyan => 'Ciano';

  @override
  String get paletteTeal => 'Azul-petróleo';

  @override
  String get paletteGreen => 'Verde';

  @override
  String get paletteViolet => 'Violeta';

  @override
  String get paletteRose => 'Rosa';

  @override
  String get appIconNotificationNote =>
      'As notificações Android usam a cor do ícone do app selecionado ao agendar lembretes. As notificações existentes são atualizadas ao serem reagendadas. Alguns dispositivos podem exibir o ícone original do app.';

  @override
  String get appearanceSaveFailed =>
      'Não foi possível salvar a aparência. A configuração anterior foi restaurada.';

  @override
  String mirrorOutPendingCleanup(int count) {
    return 'Ainda há $count eventos do calendário para remover. Sincronize novamente.';
  }

  @override
  String get weeklyReviewResume => 'Retomar revisão semanal';

  @override
  String get weeklyReviewProgressSaved => 'Seu progresso é salvo ao sair.';

  @override
  String get weeklyReviewSaveError =>
      'Não foi possível salvar seu progresso. Tente novamente.';

  @override
  String get weeklyReviewActionError =>
      'Não foi possível salvar esta alteração. Tente novamente.';

  @override
  String get weeklyReviewListEmpty => 'Nada para revisar aqui.';

  @override
  String get weeklyReviewProjectAwaiting =>
      'O trabalho pendente ou agendado faz este projeto avançar.';

  @override
  String get weeklyReviewProjectMoving => 'Próxima ação definida';

  @override
  String get weeklyReviewOpenProject => 'Abrir projeto';

  @override
  String get processTwoMinNo => 'Não — continuar esclarecendo';

  @override
  String get twoMinRule =>
      'A regra dos dois minutos: se fazer leva menos tempo que registrar, faça agora.';

  @override
  String get delegateYes => 'Sim — delegar e aguardar uma resposta';

  @override
  String get delegateNo => 'Não — é minha responsabilidade';

  @override
  String get singleStepQuestion => 'É uma única ação concreta?';

  @override
  String get singleStepYes => 'Sim — uma única próxima ação';

  @override
  String get singleStepProject => 'Não — é um projeto';

  @override
  String get projectRule =>
      'Um projeto é um resultado que exige mais de uma ação e pode ser concluído em até um ano.';

  @override
  String get deferQuestion => 'Tem um dia ou horário específico?';

  @override
  String get deferAsap => 'Não — fazer assim que possível';

  @override
  String get deferCalendar => 'Sim — colocar no calendário';

  @override
  String get deferChooseDate => 'Adiar até uma data';

  @override
  String get processDetailsTitle => 'Adicionar detalhes';

  @override
  String get processFileNextAction => 'Salvar como próxima ação';

  @override
  String minutesShort(int minutes) {
    return '$minutes min';
  }

  @override
  String deferredUntilSummary(String date) {
    return 'Adiado até $date';
  }

  @override
  String deferredRepeatingSummary(String date, String recurrence) {
    return 'Adiado até $date · Repetição: $recurrence';
  }

  @override
  String get recurrenceDaily => 'Diariamente';

  @override
  String get recurrenceWeekly => 'Semanalmente';

  @override
  String get recurrenceMonthly => 'Mensalmente';

  @override
  String get recurrenceYearly => 'Anualmente';

  @override
  String get createProject => 'Criar';

  @override
  String get projectPickerTitle => 'Mover para um projeto';

  @override
  String get projectMoved => 'Movido para um projeto.';

  @override
  String get projectDetached => 'Removido do projeto.';

  @override
  String get noProject => 'Sem projeto';

  @override
  String get decreaseRepeatInterval => 'Diminuir o intervalo de repetição';

  @override
  String get increaseRepeatInterval => 'Aumentar o intervalo de repetição';

  @override
  String get decreaseRepeatCount => 'Diminuir o número de repetições';

  @override
  String get increaseRepeatCount => 'Aumentar o número de repetições';

  @override
  String get repeatOn => 'Repetir em';

  @override
  String get repeatMonthlyOn => 'Em';

  @override
  String get repeatDayOfMonth => 'Dia do mês';

  @override
  String get repeatDayOfWeek => 'Dia da semana';

  @override
  String get repeatFirst => 'Primeiro';

  @override
  String get repeatSecond => 'Segundo';

  @override
  String get repeatThird => 'Terceiro';

  @override
  String get repeatFourth => 'Quarto';

  @override
  String get repeatFifth => 'Quinto';

  @override
  String get repeatLast => 'Último';

  @override
  String get repeatEnds => 'Termina';

  @override
  String get repeatNever => 'Nunca';

  @override
  String get repeatOnDate => 'Em uma data';

  @override
  String get repeatAfterCount => 'Após um número de vezes';

  @override
  String get weekdayListSeparator => ', ';

  @override
  String get dueToday => 'Vence hoje';

  @override
  String get reschedule => 'Reagendar';

  @override
  String get complete => 'Concluir';

  @override
  String get drop => 'Descartar';

  @override
  String get trash => 'Lixeira';

  @override
  String itemEnergyLabel(String energy) {
    return 'Energia: $energy';
  }

  @override
  String waitingOnPerson(String person) {
    return 'Aguardando $person';
  }

  @override
  String dueOverdueDays(int days) {
    return 'Atrasado · $days d';
  }

  @override
  String dueTodayAt(String time) {
    return 'Vence hoje, $time';
  }

  @override
  String selectItem(String title) {
    return 'Selecionar $title';
  }

  @override
  String markItemDone(String title) {
    return 'Marcar $title como concluído';
  }

  @override
  String repeatLastOnDate(String date) {
    return 'Última vez em $date';
  }

  @override
  String repeatAfterOccurrences(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Após $count ocorrências',
      one: 'Após 1 ocorrência',
    );
    return '$_temp0';
  }

  @override
  String recurrenceUntilSummary(String pattern, String date) {
    return '$pattern · até $date';
  }

  @override
  String recurrenceCountSummary(String pattern, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$pattern · $count ocorrências',
      one: '$pattern · 1 ocorrência',
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
      'first': 'primeira',
      'second': 'segunda',
      'third': 'terceira',
      'fourth': 'quarta',
      'fifth': 'quinta',
      'other': 'última',
    });
    return '$cadence · $_temp0 ocorrência de $weekday';
  }

  @override
  String repeatEveryDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'A cada $count dias',
      one: 'Todos os dias',
    );
    return '$_temp0';
  }

  @override
  String repeatEveryWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'A cada $count semanas',
      one: 'Toda semana',
    );
    return '$_temp0';
  }

  @override
  String repeatEveryMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'A cada $count meses',
      one: 'Todo mês',
    );
    return '$_temp0';
  }

  @override
  String repeatEveryYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'A cada $count anos',
      one: 'Todo ano',
    );
    return '$_temp0';
  }

  @override
  String get captureAddContinue => 'Adicionar e continuar';

  @override
  String captureAddedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count itens adicionados à caixa de entrada',
      one: '1 item adicionado à caixa de entrada',
    );
    return '$_temp0';
  }

  @override
  String get folderBackupChoose => 'Escolher pasta de backup';

  @override
  String get folderBackupSaving => 'Fazendo backup…';

  @override
  String get folderBackupOff => 'Os backups automáticos estão desativados.';

  @override
  String get folderBackupNever => 'Nenhum backup concluído ainda.';

  @override
  String folderBackupLastSuccess(String date) {
    return 'Último backup: $date';
  }

  @override
  String get folderBackupFailed =>
      'Falha no backup. Verifique o acesso à pasta e o espaço livre e tente novamente.';

  @override
  String get folderBackupHistoryWarning =>
      'Backup salvo, mas não foi possível remover os backups antigos.';

  @override
  String get folderBackupNow => 'Fazer backup agora';

  @override
  String get doViewToday => 'Hoje';

  @override
  String get doViewNextActions => 'Próximas ações';

  @override
  String get todayPlanCardTitle => 'Planeje seu dia';

  @override
  String get todayPlanCardBody =>
      'Escolha em que vai se concentrar hoje. Leva cerca de dois minutos.';

  @override
  String get todayPlanAction => 'Planejar hoje';

  @override
  String todayCarryOverLine(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count itens de antes precisam de uma decisão',
      one: '1 item de antes precisa de uma decisão',
    );
    return '$_temp0';
  }

  @override
  String get todayFocusHeader => 'Foco';

  @override
  String todayDoneCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count concluídos hoje',
      one: '1 concluído hoje',
    );
    return '$_temp0';
  }

  @override
  String get todayEmptyTitle => 'Nada em foco ainda';

  @override
  String get todayEmptyMessage =>
      'Marque próximas ações com estrela para se comprometer com elas hoje, ou planeje seu dia.';

  @override
  String get focusAddTooltip => 'Adicionar a Hoje';

  @override
  String get focusRemoveTooltip => 'Remover de Hoje';

  @override
  String focusAddItem(String title) {
    return 'Adicionar $title a Hoje';
  }

  @override
  String focusRemoveItem(String title) {
    return 'Remover $title de Hoje';
  }

  @override
  String get focusError => 'Não foi possível atualizar Hoje. Tente novamente.';

  @override
  String get planTodayIntro =>
      'Marque com estrela o que vai assumir hoje. Mantenha curto — todo o resto continua nas suas listas.';

  @override
  String get planSectionCarryOver => 'De antes';

  @override
  String get planCarryOverHint =>
      'Os itens que você não mantiver voltam para suas listas quando você começar o dia.';

  @override
  String get planKeepAll => 'Manter todos';

  @override
  String get planSectionCalendar => 'Agenda';

  @override
  String get planOnToday => 'Em Hoje';

  @override
  String get planSectionWaiting => 'Acompanhamentos pendentes';

  @override
  String get planSectionAvailable => 'Disponíveis a partir de hoje';

  @override
  String get planEmpty =>
      'Ainda não há nada para planejar. Processe sua caixa de entrada para criar próximas ações.';

  @override
  String planFocusedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count em foco para hoje',
      one: '1 em foco para hoje',
      zero: 'Nada em foco ainda',
    );
    return '$_temp0';
  }

  @override
  String get planStartDay => 'Começar meu dia';

  @override
  String get planDoneSnackbar => 'Seu dia está planejado';

  @override
  String planClearedSnackbar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Dia planejado · $count itens voltaram para as listas',
      one: 'Dia planejado · 1 item voltou para a lista',
    );
    return '$_temp0';
  }

  @override
  String get planSaveError =>
      'Não foi possível salvar seu plano. Tente novamente.';

  @override
  String get captureTipDates =>
      'Dica: adicione @contexto, #projeto, +etiqueta ou uma data em inglês como “tomorrow”.';

  @override
  String get captureTipSigils =>
      'Dica: adicione @contexto, #projeto ou +etiqueta.';

  @override
  String startsOnDate(String date) {
    return 'Começa $date';
  }

  @override
  String dueOnDate(String date) {
    return 'Vence $date';
  }

  @override
  String captureChipProject(String name) {
    return 'Projeto: $name';
  }

  @override
  String get captureKeepAsText => 'Manter como texto';

  @override
  String get captureRecognized => 'Detalhes reconhecidos';

  @override
  String deferUseStartDate(String date) {
    return 'Começar em $date';
  }

  @override
  String deferUseDueDate(String date) {
    return 'Na agenda em $date';
  }

  @override
  String weeklyReviewProjectInactive(int days) {
    return 'Sem atividade há $days+ dias';
  }

  @override
  String get weeklyReviewMarkReviewed => 'Marcar como revisado';

  @override
  String get weeklyReviewReviewed => 'Revisado';

  @override
  String weeklyReviewLastReviewed(String date) {
    return 'Revisado pela última vez em $date';
  }

  @override
  String get weeklyReviewNeverReviewed => 'Ainda não revisado';

  @override
  String weeklyReviewReviewedProgress(int done, int total) {
    return 'Revisados $done de $total';
  }

  @override
  String get importFromApp => 'Importar de outro app';

  @override
  String get importSourcePlainText => 'Texto simples / TaskPaper';

  @override
  String get importHintTodoist =>
      'Menu do projeto › Exportar como modelo › CSV, ou um ZIP de backup em Configurações › Backups.';

  @override
  String get importHintTickTick =>
      'No site do TickTick: Configurações › Conta › Backup e importação › Gerar backup (CSV).';

  @override
  String get importHintNirvana =>
      'No app web do Nirvana, exporte seus dados como CSV ou JSON.';

  @override
  String get importHintOmniFocus =>
      'Selecione projetos e depois Editar › Copiar como TaskPaper. Cole aqui ou salve como arquivo.';

  @override
  String get importHintPlainText =>
      'Things: copie as tarefas e cole aqui, uma por linha. Apenas texto básico; exportações do banco de dados do Things não são compatíveis.';

  @override
  String get importChooseFile => 'Escolher arquivo';

  @override
  String get importPasteText => 'Colar texto';

  @override
  String get importPasteTitle => 'Colar tarefas';

  @override
  String get importPasteHint =>
      'Uma tarefa por linha. Recue tarefas sob uma linha terminada em “:” para criar um projeto.';

  @override
  String get importPasteContinue => 'Pré-visualizar';

  @override
  String get importPreviewNothingYet => 'Nada foi adicionado ainda.';

  @override
  String get importPreviewProjects => 'Projetos';

  @override
  String get importProjectNew => 'Novo';

  @override
  String get importProjectExisting => 'Adiciona ao existente';

  @override
  String importProjectActions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ações',
      one: '1 ação',
    );
    return '$_temp0';
  }

  @override
  String importContextsNew(String names) {
    return 'Novos: $names';
  }

  @override
  String importContextsExisting(String names) {
    return 'Você já tem: $names';
  }

  @override
  String get importGoodToKnow => 'Bom saber';

  @override
  String importWarnCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tarefas concluídas ou descartadas ignoradas',
      one: '1 tarefa concluída ou descartada ignorada',
    );
    return '$_temp0';
  }

  @override
  String importWarnCalendar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ações com prazo vão para o Calendário',
      one: '1 ação com prazo vai para o Calendário',
    );
    return '$_temp0';
  }

  @override
  String importWarnDates(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count datas ilegíveis ficam nas notas',
      one: '1 data ilegível fica nas notas',
    );
    return '$_temp0';
  }

  @override
  String importWarnRepeats(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count regras de repetição ficam nas notas',
      one: '1 regra de repetição fica nas notas',
    );
    return '$_temp0';
  }

  @override
  String importWarnSubtasks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count subtarefas viram ações separadas',
      one: '1 subtarefa vira uma ação separada',
    );
    return '$_temp0';
  }

  @override
  String importWarnSections(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tarefas anotam sua seção nas notas',
      one: '1 tarefa anota sua seção nas notas',
    );
    return '$_temp0';
  }

  @override
  String importWarnNotImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count tarefas tinham prioridade, sinalização ou responsável que não é importado',
      one:
          '1 tarefa tinha prioridade, sinalização ou responsável que não é importado',
    );
    return '$_temp0';
  }

  @override
  String importWarnUnreadable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count linhas sem título ignoradas',
      one: '1 linha sem título ignorada',
    );
    return '$_temp0';
  }

  @override
  String importDoneTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tarefas adicionadas',
      one: '1 tarefa adicionada',
    );
    return '$_temp0';
  }

  @override
  String get importDoneBody =>
      'Mudou de ideia? Desfazer remove exatamente o que esta importação adicionou, e nada mais.';

  @override
  String get importUndo => 'Desfazer importação';

  @override
  String get importFinish => 'Concluir';

  @override
  String get importUndoneTitle => 'Importação desfeita';

  @override
  String get importUndoneBody =>
      'Tudo o que esta importação adicionou foi removido.';

  @override
  String get importRemindersFailed =>
      'Alguns lembretes ainda não puderam ser agendados. Eles serão definidos na próxima vez que o app abrir.';

  @override
  String importErrorUnrecognized(String source) {
    return 'Isto não parece uma exportação do $source. Confira os passos e tente de novo.';
  }

  @override
  String get importErrorNoTasks => 'Nenhuma tarefa aberta para importar.';

  @override
  String get importErrorUnreadable =>
      'Não é possível ler este arquivo. Escolha uma exportação em texto, CSV ou ZIP.';

  @override
  String get importErrorWrite => 'A importação falhou. Nada foi adicionado.';

  @override
  String get importErrorUndo =>
      'Não foi possível desfazer a importação. Tente de novo.';

  @override
  String get tagsAndPeopleLabel => 'Etiquetas e pessoas';

  @override
  String get tagsEmptyMessage =>
      'Etiquetas marcam itens em todas as listas. Marque uma etiqueta como pessoa para manter uma pauta do que conversar com ela. Dica: digite +etiqueta ao capturar.';

  @override
  String get newTag => 'Nova etiqueta';

  @override
  String get editTag => 'Editar etiqueta';

  @override
  String get tagPersonSwitch => 'Pessoa';

  @override
  String get tagPersonSwitchHint => 'Mantém uma pauta do que conversar';

  @override
  String tagOpenItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count itens abertos',
      one: '1 item aberto',
      zero: 'Nenhum item aberto',
    );
    return '$_temp0';
  }

  @override
  String deleteTagConfirmTitle(String name) {
    return 'Excluir “$name”?';
  }

  @override
  String deleteTagConfirmBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count itens abertos a usam. Eles continuam; só a etiqueta é removida.',
      one: '1 item aberto a usa. Ele continua; só a etiqueta é removida.',
      zero: 'Nenhum item aberto a usa.',
    );
    return '$_temp0';
  }

  @override
  String get tagMergeTitle => 'Mesclar etiquetas?';

  @override
  String tagMergeBody(String source, String target) {
    return '“$target” já existe. Mesclar “$source” com ela?';
  }

  @override
  String get tagMergeAction => 'Mesclar';

  @override
  String get addTag => 'Adicionar etiqueta';

  @override
  String get tagPickerHint => 'Busque ou crie uma etiqueta';

  @override
  String tagCreate(String name) {
    return 'Criar “$name”';
  }

  @override
  String tagCreatePerson(String name) {
    return 'Criar pessoa “$name”';
  }

  @override
  String get tagsSection => 'Etiquetas';

  @override
  String tagChipSemantics(String name) {
    return 'Etiqueta: $name';
  }

  @override
  String personChipSemantics(String name) {
    return 'Pessoa: $name';
  }

  @override
  String removeTagTooltip(String name) {
    return 'Remover $name';
  }

  @override
  String moreTags(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'mais $count etiquetas',
      one: 'mais 1 etiqueta',
    );
    return '$_temp0';
  }

  @override
  String get filterTag => 'Etiqueta';

  @override
  String get filterAnyTag => 'Qualquer etiqueta';

  @override
  String get agendasTitle => 'Pautas';

  @override
  String agendasPeopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pessoas',
      one: '1 pessoa',
    );
    return '$_temp0';
  }

  @override
  String agendaAddHint(String name) {
    return 'Adicione algo para conversar com $name';
  }

  @override
  String get agendaAddTooltip => 'Adicionar à pauta';

  @override
  String agendaEmpty(String name) {
    return 'Ainda nada para conversar com $name.';
  }

  @override
  String get agendaNotFound => 'Esta pessoa não existe mais.';

  @override
  String captureChipNewTag(String name) {
    return 'Nova etiqueta: $name';
  }

  @override
  String get importHintGoogleTasks =>
      'Google Takeout › selecione Tasks › exporte JSON. Descompacte o download e escolha Tasks.json. As listas ficam nas notas; as tarefas concluídas vão para Concluído.';

  @override
  String get importDuplicateWarning =>
      'Esta mesma entrada já foi importada neste dispositivo. Importar novamente duplicará as tarefas. Cancele se não quiser outra cópia.';

  @override
  String get importHintThings =>
      'Escolha main.sqlite ou um ZIP da pasta da base exportada do Things 3. iPhone/iPad: Ajustes › Geral › Diagnóstico › Inserir código › 491348 › Enviar base. Salve em Arquivos, descompacte .aar e compacte a pasta como ZIP. Mac: encerre o Things antes de copiar. Reconfigure repetições e lembretes.';

  @override
  String importWarnDetailsInNotes(int count) {
    return '$count tarefas mantêm detalhes de listas de verificação ou áreas nas notas';
  }

  @override
  String get importWarnThingsRecurrence =>
      'As repetições do Things não são importadas. Os modelos são ignorados; reconfigure as repetições das tarefas importadas.';

  @override
  String importWarnSourceReminders(int count) {
    return '$count configurações de lembretes de origem não são importadas';
  }

  @override
  String get importAppleHint =>
      'Escolha listas de lembretes neste dispositivo. Apenas lembretes pendentes são importados.';

  @override
  String get importAppleChooseLists => 'Escolher listas';

  @override
  String get importAppleReloadLists => 'Recarregar listas';

  @override
  String get importAppleNoLists =>
      'Não há listas de lembretes disponíveis neste dispositivo.';

  @override
  String get importAppleDenied =>
      'O acesso aos Lembretes está desativado. Permita o acesso ao Trayzero nos Ajustes do iOS e tente novamente.';

  @override
  String get importAppleUnavailable =>
      'Não foi possível ler os Lembretes da Apple. Tente novamente.';

  @override
  String get importAppleListsChanged =>
      'Uma lista selecionada não está mais disponível. Recarregue as listas e selecione novamente.';

  @override
  String get importAppleLimits =>
      'Seus lembretes da Apple permanecem inalterados. Etiquetas da Apple, sinalizadores, anexos, estrutura de subtarefas, prioridades e alertas originais não são copiados. Importar novamente pode duplicar tarefas.';

  @override
  String get importHintMicrosoftTodo =>
      'Entre para copiar listas e tarefas pendentes. Revise antes de importar; importar novamente pode criar duplicatas.';

  @override
  String get importMicrosoftUnavailable =>
      'A importação do Microsoft To Do não está disponível nesta versão.';

  @override
  String get importMicrosoftSignInError =>
      'O login da Microsoft falhou ou expirou. Entre novamente.';

  @override
  String get importMicrosoftPermissionError =>
      'A Microsoft não permitiu acesso às tarefas. Verifique as permissões ou contate sua organização.';

  @override
  String get importMicrosoftNetworkError =>
      'Não foi possível ler todas as tarefas da Microsoft. Nada foi importado. Verifique sua conexão e tente novamente.';

  @override
  String importWarnSourceDetails(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count tarefas têm anexos, configurações de lembrete ou estados que não são importados',
      one:
          '1 tarefa tem anexos, configurações de lembrete ou um estado que não são importados',
    );
    return '$_temp0';
  }

  @override
  String get moreGroupOrganize => 'Organizar';

  @override
  String get moreGroupPreferences => 'Preferências';

  @override
  String get moreGroupData => 'Dados';

  @override
  String get moreOn => 'Ativado';

  @override
  String get moreOff => 'Desativado';

  @override
  String moreAppearanceSummary(String theme, String palette) {
    return '$theme · $palette';
  }

  @override
  String get moreRemindersBlockedTitle => 'Os lembretes estão bloqueados';

  @override
  String get moreRemindersBlockedBody =>
      'As notificações estão desativadas, então os lembretes não podem avisar você.';

  @override
  String get moreBackupFailedTitle => 'Falha no backup';

  @override
  String get moreBackupFailedBody =>
      'Não foi possível salvar o backup automático. Verifique a pasta e o espaço livre.';

  @override
  String get moreFix => 'Corrigir';

  @override
  String get moreBackupRestore => 'Backup e restauração';

  @override
  String get moreBackupSubtitleOff => 'O backup automático está desativado';

  @override
  String get moreBackupSubtitleFailed => 'Falha no backup';

  @override
  String get moreImportSources => 'Todoist, TickTick, OmniFocus e mais';

  @override
  String get moreSupportTrailing => 'Opcional';

  @override
  String get moreSupportTrailingSupporter => 'Apoiador';

  @override
  String get moreAboutPrivacy => 'Sobre e privacidade';

  @override
  String get moreHowGtdWorks => 'Como o GTD funciona';

  @override
  String get moreNudgesGroup => 'Avisos';

  @override
  String get moreTimingGroup => 'Horários';

  @override
  String get moreLeadOff => 'Desativado';

  @override
  String get moreLead10 => '10 minutos antes';

  @override
  String get moreLead30 => '30 minutos antes';

  @override
  String get moreLead60 => '1 hora antes';

  @override
  String get moreLead1440 => '1 dia antes';

  @override
  String moreLeadOther(int minutes) {
    return '$minutes minutos antes';
  }

  @override
  String moreRestoredEntries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count itens restaurados',
      one: '1 item restaurado',
    );
    return '$_temp0.';
  }

  @override
  String get moreBackupEmpty => 'Este backup não tem itens para restaurar.';

  @override
  String get moreCouldntOpenLink => 'Não foi possível abrir o link';

  @override
  String moreVersionBuild(String version, String build) {
    return '$version (build $build)';
  }

  @override
  String get supportBestValue => 'Melhor custo-benefício';

  @override
  String get importListIntro =>
      'Escolha onde suas tarefas estão agora. Você verá uma prévia antes de qualquer coisa ser adicionada.';

  @override
  String get importGroupDirect => 'Conectar diretamente';

  @override
  String get importGroupFile => 'De um arquivo de exportação';

  @override
  String get importGroupOther => 'Qualquer outra coisa';

  @override
  String get importSubGoogleTasks => 'Takeout · Tasks.json';

  @override
  String get importSubTodoist => 'Modelo CSV ou ZIP de backup';

  @override
  String get importSubThings => 'ZIP do banco de dados ou main.sqlite';

  @override
  String get importSubTickTick => 'CSV de backup';

  @override
  String get importSubNirvana => 'Exportação CSV ou JSON';

  @override
  String get importSubOmniFocus => 'Arquivo TaskPaper ou colar';

  @override
  String get importSubPlainText => 'Cole uma lista, uma tarefa por linha';

  @override
  String get importSubApple => 'Escolha listas neste dispositivo';

  @override
  String get importSubMicrosoft => 'Listas e tarefas abertas';

  @override
  String get importChipOnDevice => 'No dispositivo';

  @override
  String get importChipSignIn => 'Entrar';

  @override
  String get importBackupFooter => 'Restaurando um backup do Trayzero?';

  @override
  String get importBackupFooterLink => 'Backup e restauração';

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
      'Abra o Google Takeout e selecione apenas Tasks.';

  @override
  String get importStepGoogleTasks2 =>
      'Exporte como JSON e descompacte o download.';

  @override
  String get importStepGoogleTasks3 => 'Escolha Tasks.json abaixo.';

  @override
  String get importNoteGoogleTasks =>
      'As listas ficam nas notas; tarefas concluídas vão para Concluído.';

  @override
  String get importStepTodoist1 =>
      'Abra o menu de um projeto e escolha Exportar como modelo (CSV).';

  @override
  String get importStepTodoist2 =>
      'Ou salve um ZIP de backup em Configurações › Backups.';

  @override
  String get importStepTodoist3 => 'Escolha o arquivo abaixo.';

  @override
  String get importStepTickTick1 =>
      'No site do TickTick, abra Configurações › Conta.';

  @override
  String get importStepTickTick2 =>
      'Abra Backup e importação e toque em Gerar backup (CSV).';

  @override
  String get importStepTickTick3 => 'Escolha o CSV abaixo.';

  @override
  String get importStepNirvana1 =>
      'No app web do Nirvana, exporte seus dados como CSV ou JSON.';

  @override
  String get importStepNirvana2 => 'Escolha o arquivo abaixo.';

  @override
  String get importStepOmniFocus1 => 'No OmniFocus, selecione seus projetos.';

  @override
  String get importStepOmniFocus2 => 'Escolha Editar › Copiar como TaskPaper.';

  @override
  String get importStepOmniFocus3 =>
      'Cole o texto abaixo ou salve como arquivo e escolha-o.';

  @override
  String get importStepPlainText1 =>
      'Copie suas tarefas de qualquer app, uma tarefa por linha.';

  @override
  String get importStepPlainText2 => 'Toque em Colar texto abaixo e cole-as.';

  @override
  String get importNotePlainText =>
      'Somente importação de texto básico. Exportações de banco de dados de outros apps não são compatíveis.';

  @override
  String get importStepApple1 => 'Toque em Escolher listas abaixo.';

  @override
  String get importStepApple2 =>
      'Permita o acesso aos Lembretes quando solicitado.';

  @override
  String get importStepApple3 => 'Marque as listas que deseja importar.';

  @override
  String get importNoteApple =>
      'Somente lembretes abertos são importados. Seus lembretes da Apple não são alterados.';

  @override
  String get importStepMicrosoft1 => 'Toque em Conectar e entre na Microsoft.';

  @override
  String get importStepMicrosoft2 =>
      'O Trayzero copia suas listas e tarefas abertas.';

  @override
  String get importStepMicrosoft3 => 'Revise a prévia antes de importar.';

  @override
  String get importNoteMicrosoft => 'Importar novamente pode criar duplicatas.';

  @override
  String get importStepThingsIos1 =>
      'No Things, abra Ajustes › Geral › Diagnóstico › Inserir código e digite:';

  @override
  String get importStepThingsIos2 =>
      'Toque em Enviar banco de dados do Things e salve em Arquivos.';

  @override
  String get importStepThingsIos3 =>
      'Em Arquivos, descompacte o .aar e compacte a pasta do banco de dados em ZIP.';

  @override
  String get importStepThingsIos4 => 'Escolha esse ZIP abaixo.';

  @override
  String get importStepThingsMac1 => 'Feche o Things no seu Mac.';

  @override
  String get importStepThingsMac2 =>
      'Copie Things Database.thingsdatabase da pasta do Things e compacte a cópia em ZIP.';

  @override
  String get importStepThingsMac3 =>
      'Mova o ZIP (ou o main.sqlite) para este dispositivo e escolha-o abaixo.';

  @override
  String get importNoteThings =>
      'Repetições e lembretes não são transferidos. Recrie-os após importar.';

  @override
  String get importReviewTitle => 'Revisar importação';

  @override
  String importFromSource(String source) {
    return 'De $source';
  }

  @override
  String importTotalTasks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tarefas',
      one: '1 tarefa',
    );
    return '$_temp0';
  }

  @override
  String importActionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Importar $count tarefas',
      one: 'Importar 1 tarefa',
    );
    return '$_temp0';
  }

  @override
  String importNewExistingSummary(int newCount, int existingCount) {
    return '$newCount novos · $existingCount existentes';
  }

  @override
  String importShowAll(int count) {
    return 'Ver todos ($count)';
  }

  @override
  String get importContextsAndTags => 'Contextos e etiquetas';

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
  String get notificationStatusOnTitle => 'Lembretes ativados';

  @override
  String get notificationStatusOnBody =>
      'Os lembretes vão avisar você neste dispositivo.';

  @override
  String get notificationStatusOffTitle => 'Lembretes desativados';

  @override
  String get notificationStatusOffBody =>
      'Os lembretes estão agendados, mas não vão avisar você até que você permita as notificações.';

  @override
  String get notificationStatusBlockedTitle => 'Lembretes bloqueados';

  @override
  String get notificationStatusBlockedBody =>
      'As notificações do Trayzero estão desativadas nas configurações do sistema. Os lembretes não vão avisar você até que você as reative lá.';

  @override
  String get notificationActionEnable => 'Ativar notificações';

  @override
  String get notificationActionOpenSettings => 'Abrir Ajustes';

  @override
  String get notificationPrimerTitle => 'Ativar lembretes?';

  @override
  String get notificationPrimerBody =>
      'O Trayzero lembra você de prazos e da sua revisão semanal exibindo uma notificação neste dispositivo. Nada é enviado a um servidor: os lembretes são agendados localmente.\n\nAgora seu dispositivo vai pedir permissão para exibir notificações.';

  @override
  String get notificationPrimerNotNow => 'Agora não';

  @override
  String get notificationPrimerContinue => 'Continuar';

  @override
  String get notificationPromptFailed =>
      'Não foi possível abrir o pedido de notificação.';

  @override
  String get notificationAlreadyOn => 'Os lembretes já estão ativados.';

  @override
  String get notificationOpenedSettings =>
      'Configurações do sistema abertas: ative as notificações do Trayzero.';

  @override
  String get notificationStayOff =>
      'Os lembretes continuam desativados. Você pode ativá-los quando quiser em Mais → Lembretes.';

  @override
  String get notificationNowOn => 'Os lembretes estão ativados.';

  @override
  String get notificationBlocked =>
      'As notificações estão bloqueadas para o Trayzero.';

  @override
  String get exactAlarmSettingsFailed =>
      'Não foi possível abrir as configurações de alarmes exatos.';

  @override
  String get exactAlarmAlreadyOn =>
      'O horário preciso dos lembretes já está ativado.';

  @override
  String get exactAlarmNowOn => 'O horário preciso dos lembretes está ativado.';

  @override
  String get exactAlarmStaysOff =>
      'O horário preciso dos lembretes continua desativado. Lembretes de curto prazo podem atrasar.';

  @override
  String get attachmentRemoved => 'Anexo removido.';

  @override
  String get discardCaptureTitle => 'Descartar esta captura?';

  @override
  String get discardCaptureBody => 'O que você digitou será perdido.';

  @override
  String get keepEditing => 'Continuar editando';

  @override
  String get discard => 'Descartar';

  @override
  String get processFiledSnackbar => 'Arquivado.';

  @override
  String get errorLoadTitle => 'Não foi possível carregar';

  @override
  String get errorLoadBody => 'Seus dados estão seguros. Tente novamente.';

  @override
  String sharedAddedToInbox(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count itens adicionados à caixa de entrada',
      one: '1 item adicionado à caixa de entrada',
    );
    return '$_temp0';
  }

  @override
  String get filterByProject => 'Filtrar por projeto';

  @override
  String get projectStatusActive => 'Ativo';

  @override
  String get projectStatusOnHold => 'Em espera';

  @override
  String get projectStatusSomeday => 'Algum dia';

  @override
  String get projectStatusDone => 'Concluído';

  @override
  String get projectStatusDropped => 'Descartado';

  @override
  String get projectChangeStatus => 'Alterar status';

  @override
  String get projectAwaitingTooltip =>
      'Aguardando: avançando por itens em espera ou agendados';

  @override
  String get projectStalledTooltip =>
      'Parado: sem próxima ação, item em espera ou agendado';

  @override
  String get projectStalledBanner =>
      'Parado: nenhuma próxima ação, item em espera ou agendado. Adicione uma próxima ação para colocá-lo em andamento.';

  @override
  String get projectAwaitingBanner =>
      'Este projeto está avançando apenas por itens em espera ou agendados. Considere adicionar uma próxima ação de acompanhamento para que ele não pare quando eles forem resolvidos.';

  @override
  String projectNextActionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count próximas ações',
      one: '1 próxima ação',
    );
    return '$_temp0';
  }

  @override
  String projectWaitingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count em espera',
      one: '1 em espera',
    );
    return '$_temp0';
  }

  @override
  String engageHiddenByFilters(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count próximas ações estão ocultas pelos seus filtros',
      one: '1 próxima ação está oculta pelos seus filtros',
    );
    return '$_temp0';
  }

  @override
  String get filterReset => 'Redefinir';

  @override
  String onboardingSeedExisting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Você já tem $count projetos.',
      one: 'Você já tem 1 projeto.',
    );
    return '$_temp0';
  }

  @override
  String get purchaseErrUnavailable =>
      'As compras não estão disponíveis no momento.';

  @override
  String get purchaseErrProducts =>
      'Não foi possível carregar os produtos. Verifique sua conexão e tente novamente.';

  @override
  String get purchaseErrOption => 'Essa opção não está disponível no momento.';

  @override
  String get purchaseErrNetwork =>
      'Erro de rede. Verifique sua conexão e tente novamente.';

  @override
  String get purchaseErrNotAllowed =>
      'Compras não são permitidas neste dispositivo.';

  @override
  String get purchaseErrPending => 'Sua compra está aguardando aprovação.';

  @override
  String get purchaseErrAlreadyOwned =>
      'Você já possui isto: tente restaurar compras.';

  @override
  String get purchaseErrStore =>
      'A loja está com problemas. Tente novamente mais tarde.';

  @override
  String get purchaseErrUnknown =>
      'Algo deu errado com a compra. Tente novamente.';

  @override
  String get backupErrEmpty =>
      'O backup está vazio: não há nada para importar.';

  @override
  String get backupErrInvalidJson =>
      'Isto não é um JSON válido. Verifique se você selecionou um arquivo de backup do Trayzero completo e sem edições.';

  @override
  String get backupErrNotBackup => 'Este arquivo não é um backup do Trayzero.';

  @override
  String get backupErrNewerVersion =>
      'Este backup foi criado por uma versão mais recente do app. Atualize o Trayzero e tente importar novamente.';

  @override
  String get backupErrUnrecognized =>
      'Este arquivo não parece ser um backup do Trayzero.';

  @override
  String get backupErrInvalidData =>
      'Este backup contém dados inválidos e não pode ser importado.';

  @override
  String get backupErrReminders =>
      'Seus dados foram restaurados, mas alguns lembretes não puderam ser atualizados. Repita a importação para atualizá-los.';

  @override
  String get backupErrRestoreFailed =>
      'Algo deu errado durante a restauração. Seus dados existentes não foram alterados por esta tentativa.';

  @override
  String backupCountItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count itens',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String backupCountProjects(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count projetos',
      one: '1 projeto',
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
      other: '$count anexos',
      one: '1 anexo',
    );
    return '$_temp0';
  }

  @override
  String backupCountReviews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count revisões',
      one: '1 revisão',
    );
    return '$_temp0';
  }

  @override
  String get restoreFolderTitle => 'Restaurar da pasta de backup';

  @override
  String get restoreFolderIntro =>
      'Escolha a pasta onde o Trayzero salva os backups, por exemplo uma mantida pelo iCloud Drive, Google Drive ou Syncthing. A restauração mescla o backup com os dados deste dispositivo; nada que já esteja aqui é apagado.';

  @override
  String get restoreFolderChoose => 'Escolher pasta de backup';

  @override
  String get restoreFolderChange => 'Escolher outra pasta';

  @override
  String restoreFolderFrom(String name) {
    return 'Pasta: $name';
  }

  @override
  String get restoreFolderEmpty =>
      'Nenhum backup do Trayzero encontrado nesta pasta.';

  @override
  String get restoreFolderFailed =>
      'Não foi possível abrir esta pasta. Verifique se ela ainda está disponível ou escolha-a novamente.';

  @override
  String restoreFolderItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count itens',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String get restoreFolderUnreadable => 'Não é possível ler este arquivo';

  @override
  String get restoreFolderReading => 'Lendo…';

  @override
  String get onboardingRestoreAction =>
      'Veio de outro dispositivo? Restaure um backup';

  @override
  String folderBackupStale(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days dias',
      one: '1 dia',
    );
    return 'Sem backup recente há $_temp0.';
  }

  @override
  String get folderBackupRepairHint =>
      'Escolha a pasta novamente se os backups pararam de funcionar.';

  @override
  String moreBackupSubtitleStale(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days dias',
      one: '1 dia',
    );
    return 'Sem backup recente há $_temp0 · toque para reparar';
  }

  @override
  String get backupPromptTitle =>
      'Faça backup das suas tarefas automaticamente';

  @override
  String get backupPromptBody =>
      'Você já capturou bastante. Escolha uma pasta na sua própria nuvem ou app de sincronização e o Trayzero manterá lá os últimos 10 backups. É backup, não sincronização.';

  @override
  String get backupPromptAction => 'Escolher pasta';

  @override
  String get backupPromptDismiss => 'Agora não';

  @override
  String backupCardHealthy(String date) {
    return 'Backup feito $date';
  }

  @override
  String get backupCardOffBody =>
      'Ative para salvar uma cópia em uma pasta após cada alteração.';

  @override
  String get backupCardTurnOn => 'Ativar';

  @override
  String get backupCardChooseAgain => 'Escolher pasta novamente';

  @override
  String get backupCardTryAgain => 'Tentar novamente';

  @override
  String get backupGroupBackUp => 'Fazer backup';

  @override
  String get backupGroupRestore => 'Restaurar';

  @override
  String get backupAutoTitle => 'Fazer backup automaticamente';

  @override
  String get backupAutoSubtitle => 'Após cada alteração';

  @override
  String get backupFolderTitle => 'Pasta de backup';

  @override
  String get backupExportTitle => 'Exportar uma cópia';

  @override
  String get backupExportSubtitle =>
      'Compartilhar um arquivo de backup uma vez';

  @override
  String get backupRestoreTitle => 'Restaurar um backup';

  @override
  String get backupRestoreRowSubtitle => 'Da sua pasta ou de um arquivo';

  @override
  String get backupRestoreSheetBody =>
      'Escolha onde está o seu backup. Você verá o que há nele antes de qualquer mudança.';

  @override
  String get backupRestoreFromFolder => 'Da pasta de backup';

  @override
  String get backupRestoreFromFolderHint =>
      'Recomendado: escolha um backup salvo';

  @override
  String get backupRestoreFromFile => 'De um arquivo';

  @override
  String get backupRestoreFromFileHint => 'Um backup do Trayzero (.json)';

  @override
  String get backupRestorePaste => 'Colar texto do backup';

  @override
  String get backupFootnote =>
      'É backup, não sincronização: sua nuvem ou app de sincronização leva a pasta entre dispositivos.';

  @override
  String get backupCardJustNow => 'Backup feito agora mesmo';

  @override
  String backupCardMinutesAgo(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minutos',
      one: '1 minuto',
    );
    return 'Backup feito há $_temp0';
  }

  @override
  String backupCardHoursAgo(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours horas',
      one: '1 hora',
    );
    return 'Backup feito há $_temp0';
  }

  @override
  String get backupCardYesterday => 'Backup feito ontem';

  @override
  String get backupHowItWorks => 'Como funciona';

  @override
  String get backupHowTitle => 'Como funciona o backup';

  @override
  String get backupHowSaves =>
      'Depois de cada alteração, o Trayzero salva uma cópia JSON dos seus dados na pasta escolhida e mantém as 10 mais recentes.';

  @override
  String get backupHowSync =>
      'Sua nuvem ou app de sincronização (por exemplo iCloud Drive, Google Drive ou Syncthing) leva essa pasta aos seus outros dispositivos. O próprio Trayzero nunca envia nem sincroniza nada.';

  @override
  String get backupHowMove =>
      'Para mudar para outro dispositivo, escolha “Restaurar um backup” e depois “Da pasta de backup”.';

  @override
  String get microphoneAccessDenied =>
      'O acesso ao microfone está desativado. Permita-o nas Configurações para gravar um áudio.';

  @override
  String get filterTimeEnergy => 'Tempo e energia';

  @override
  String get clearDate => 'Limpar data';

  @override
  String get reorderHandle => 'Arraste para reordenar';

  @override
  String get calendarConnectionTitle => 'Conexão com o calendário';

  @override
  String get calendarTogether => 'Seus planos, juntos.';

  @override
  String get calendarConnectionIntro =>
      'Veja seus compromissos do Trayzero junto com o restante do seu dia.';

  @override
  String get calendarConnect => 'Conectar calendário';

  @override
  String get calendarScope =>
      'Somente itens agendados no Calendário do Trayzero são publicados. Prazos comuns de tarefas ficam no Trayzero.';

  @override
  String get calendarAutomatic => 'Atualizações automáticas';

  @override
  String get calendarAutomaticHelp =>
      'Atualiza enquanto você usa o Trayzero e ao reabri-lo.';

  @override
  String get calendarPaused => 'Pausado';

  @override
  String get calendarConnected => 'Conectado';

  @override
  String get calendarNeedsAttention => 'Requer atenção';

  @override
  String get calendarPauseHelp =>
      'Os eventos existentes são mantidos. As alterações aguardam até você retomar as atualizações ou escolher Atualizar agora.';

  @override
  String calendarLinkedCount(int count) {
    return '$count eventos vinculados';
  }

  @override
  String calendarLastUpdated(String when) {
    return 'Última atualização: $when';
  }

  @override
  String get calendarChangesWaiting => 'Alterações aguardando atualização';

  @override
  String get calendarUpdateNow => 'Atualizar agora';

  @override
  String get calendarManage => 'Gerenciar conexão';

  @override
  String get calendarWorking => 'Atualizando conexão com o calendário…';

  @override
  String get calendarRestoreAccess => 'Restaurar acesso';

  @override
  String get calendarUpdateFailed =>
      'Algumas alterações não foram aplicadas. A última atualização bem-sucedida aparece acima. Tente novamente.';

  @override
  String get calendarRemovalPending => 'Remoção pendente';

  @override
  String calendarRemoveFailed(int count) {
    return 'Não foi possível remover $count eventos. As atualizações automáticas estão paradas. Tente remover novamente ou desconecte e mantenha os eventos restantes.';
  }

  @override
  String get calendarSaveFailed =>
      'Não foi possível salvar esta alteração. Verifique as configurações da conexão e tente novamente.';

  @override
  String get calendarNoWritable =>
      'Não há calendários editáveis. Adicione um nos ajustes de calendário do dispositivo e tente novamente.';

  @override
  String get calendarChangeDestination => 'Alterar destino';

  @override
  String get calendarChooseDestination => 'Escolha seu calendário';

  @override
  String get calendarMoveHelp =>
      'Os eventos vinculados serão movidos para o novo calendário. Os demais permanecem onde estão. A configuração atual das atualizações automáticas será mantida.';

  @override
  String calendarSetupCount(int count) {
    return 'Serão publicados $count itens agendados. Vínculos existentes serão reutilizados quando disponíveis.';
  }

  @override
  String get calendarMoveEvents => 'Mover eventos vinculados';

  @override
  String get calendarConnectAndAdd => 'Conectar e adicionar eventos';

  @override
  String get calendarDisconnect => 'Desconectar calendário';

  @override
  String get calendarDisconnectQuestion => 'Desconectar calendário?';

  @override
  String get calendarDisconnectHelp =>
      'Escolha o que acontece com os eventos vinculados. Seus itens do Trayzero e outros eventos do calendário serão mantidos.';

  @override
  String get calendarKeepEvents => 'Manter eventos no meu calendário';

  @override
  String get calendarKeepHelp =>
      'Parar as atualizações e manter os eventos. Reconectar pode reutilizar esses vínculos.';

  @override
  String calendarRemoveEvents(int count) {
    return 'Remover $count eventos vinculados';
  }

  @override
  String get calendarRemoveHelp =>
      'Remover apenas eventos vinculados a esta conexão. Remoções com falha podem ser tentadas novamente.';

  @override
  String get calendarHowItWorks => 'Como funcionam os eventos vinculados';

  @override
  String get calendarRules =>
      'O Trayzero publica itens agendados do Calendário no calendário escolhido do dispositivo. Prazos comuns de tarefas são excluídos.\n\nEdite títulos, notas, horários e recorrências no Trayzero. Atualizações podem sobrescrever alterações feitas no aplicativo de calendário. Os eventos atualmente duram uma hora.\n\nConcluir, enviar para a lixeira ou mover um item para fora do Calendário remove o evento na próxima atualização. Uma série recorrente avança para a próxima ocorrência.\n\nPausar mantém os eventos e vínculos. Desconectar permite manter ou remover os eventos vinculados. Desconectar nunca apaga itens do Trayzero.';

  @override
  String get calendarBringEvents => 'Trazer eventos para o Trayzero';

  @override
  String get calendarImportCopies =>
      'Escolha eventos para copiar para sua Caixa de entrada ou Calendário. As cópias não acompanham alterações posteriores nos originais. Os originais permanecem inalterados.';

  @override
  String get calendarChooseEvents => 'Escolher eventos';

  @override
  String get calendarImportSource => 'Escolher calendário de origem';

  @override
  String get calendarImportDestination => 'Adicionar eventos selecionados a';

  @override
  String calendarAddSelected(int count) {
    return 'Adicionar $count eventos';
  }

  @override
  String get calendarNoImportEvents =>
      'Nenhum evento novo para importar. Eventos já adicionados ou vinculados ao Trayzero são excluídos. O período cobre os últimos 7 dias e o próximo ano.';

  @override
  String get calendarImportFailed =>
      'Não foi possível importar eventos. Verifique o acesso ao calendário e tente novamente.';

  @override
  String get calendarDeviceHelp =>
      'Usa o calendário do dispositivo. Não precisa de conta Trayzero. Outras pessoas com acesso a um calendário compartilhado podem ver seus eventos.';
}
