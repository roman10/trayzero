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
  String get edit => 'Editar';

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
  String get rename => 'Renomear';

  @override
  String get inbox => 'Caixa de entrada';

  @override
  String get doVerb => 'Fazer';

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
  String get actionableQuestion => 'É acionável?';

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
  String get twoMinNo => 'Não';

  @override
  String get delegateQuestion => 'Outra pessoa pode fazer?';

  @override
  String get waitingOnPromptTitle => 'Você está esperando quem?';

  @override
  String get waitingOnPromptHint => 'Nome ou sistema';

  @override
  String get multiStepQuestion => 'Precisa de mais de um passo?';

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
  String get engageNoMatchMessage =>
      'Nenhuma ação se encaixa nos filtros atuais. Tente afrouxá-los ou remova-os.';

  @override
  String get hardLandscape => 'Compromissos fixos';

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
  String projectActionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ações',
      one: '1 ação',
    );
    return '$_temp0';
  }

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
  String get projectMissingNextActionError =>
      'Sem próxima ação definida. Todo projeto ativo deveria ter pelo menos uma.';

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
      'Cada projeto deveria estar ativo, em espera ou concluído — e todo projeto ativo precisa de pelo menos uma próxima ação.';

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
  String get themeFollowSystem => 'Seguir o sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Escuro';

  @override
  String get hapticFeedback => 'Vibração';

  @override
  String get organizationSection => 'Organização';

  @override
  String get contextsLabel => 'Contextos';

  @override
  String get areasOfFocusLabel => 'Áreas de responsabilidade';

  @override
  String get areasOfFocusDescription =>
      'Agrupa projetos por esferas contínuas de responsabilidade.';

  @override
  String get calendarSyncLabel => 'Sincronizar com a agenda';

  @override
  String get calendarSyncDescription =>
      'Espelha itens com vencimento na agenda do sistema.';

  @override
  String get remindersSection => 'Lembretes';

  @override
  String get weeklyReviewNudge => 'Lembrete de revisão semanal';

  @override
  String get weeklyReviewNudgeDescription =>
      'Um cutucão suave toda sexta-feira às 16h.';

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
      'itens adiados sem hora ficam na lista o dia inteiro e cutucam neste horário';

  @override
  String get checkingNotificationStatus =>
      'Verificando o estado das notificações…';

  @override
  String get dataSection => 'Dados';

  @override
  String get exportBackup => 'Exportar backup';

  @override
  String get exportBackupDescriptionIos =>
      'Compartilhe uma cópia em JSON. Salve-a em um serviço de nuvem (ex.: Arquivos → iCloud Drive) como backup.';

  @override
  String get exportBackupDescriptionAndroid =>
      'Compartilhe uma cópia em JSON. Salve-a em um serviço de nuvem (ex.: Google Drive) como backup.';

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
  String get importBackup => 'Importar backup';

  @override
  String get importBackupDescription =>
      'Restaure um backup do Trayzero ou importe uma exportação do Google Tasks (Takeout).';

  @override
  String get importConfirmTitle => 'Importar este backup?';

  @override
  String importConfirmBody(String sections) {
    return 'Isso vai adicionar ou atualizar $sections.\n\nEntradas existentes com o mesmo id serão sobrescritas pela versão do backup. Isso não pode ser desfeito.';
  }

  @override
  String get importButton => 'Importar';

  @override
  String get importSourceSheetTitle => 'Importar backup';

  @override
  String get importFromFileTitle => 'Escolher um arquivo de backup';

  @override
  String get importFromFileDescription =>
      'Recomendado — um .json do Trayzero ou um Tasks.json do Google Takeout.';

  @override
  String get importFromPasteTitle => 'Colar JSON do backup';

  @override
  String get importFromPasteDescription =>
      'Cole o texto do backup em vez de escolher arquivo.';

  @override
  String get pasteBackupHint => 'Cole o JSON aqui…';

  @override
  String get privacySection => 'Privacidade';

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
  String get aboutSection => 'Sobre';

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
  String get supportSummaryDefault =>
      'Dê uma gorjeta ao desenvolvedor ou torne-se apoiador';

  @override
  String get supportSummarySupporter => 'Obrigado por apoiar o Trayzero 💙';

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
    return '$price / ano · melhor valor · desbloqueia vantagens de apoiador';
  }

  @override
  String get supportSupporterMonthly => 'Apoiador — mensal';

  @override
  String supportSupporterMonthlySubtitle(String price) {
    return '$price / mês · cancele quando quiser';
  }

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
}
