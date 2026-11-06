// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'Trayzero';

  @override
  String get cancel => '取消';

  @override
  String get save => '保存';

  @override
  String get delete => '删除';

  @override
  String get add => '添加';

  @override
  String get ok => '确定';

  @override
  String get next => '下一步';

  @override
  String get back => '返回';

  @override
  String get skip => '跳过';

  @override
  String get done => '完成';

  @override
  String get undo => '撤销';

  @override
  String get retry => '重试';

  @override
  String get settings => '设置';

  @override
  String get enable => '启用';

  @override
  String get none => '无';

  @override
  String get notSet => '未设置';

  @override
  String get search => '搜索';

  @override
  String get select => '选择';

  @override
  String get selectAll => '全选';

  @override
  String get selectNone => '取消全选';

  @override
  String get inbox => '收件箱';

  @override
  String get projects => '项目';

  @override
  String get review => '回顾';

  @override
  String get more => '更多';

  @override
  String get navInbox => '收件箱';

  @override
  String get navDo => '执行';

  @override
  String get navProjects => '项目';

  @override
  String get navReview => '回顾';

  @override
  String get navMore => '更多';

  @override
  String get capture => '收集';

  @override
  String get clarify => '厘清';

  @override
  String get organize => '整理';

  @override
  String get reflect => '回顾';

  @override
  String get engage => '执行';

  @override
  String get nextAction => '下一步行动';

  @override
  String get waitingFor => '等待中';

  @override
  String get someday => '将来';

  @override
  String get somedayMaybe => '将来 / 也许';

  @override
  String get reference => '参考资料';

  @override
  String get calendar => '日历';

  @override
  String get project => '项目';

  @override
  String get completed => '已完成';

  @override
  String get scheduled => '已排期';

  @override
  String get needsClarifying => '待厘清';

  @override
  String get howGtdWorks => 'GTD 怎么运作';

  @override
  String get whatIsGtd => '什么是 GTD？';

  @override
  String get onboardingPage1Title => '把它从脑袋里清出来';

  @override
  String get onboardingPage1Body =>
      '任何让你分心的事情——一件任务、一个点子、一份担忧——都先放进收件箱。目的是腾空脑袋，不是急着整理。';

  @override
  String get onboardingPage2Title => '一次厘清一件事';

  @override
  String get onboardingPage2Body =>
      '处理流程会带你按 GTD 决策树逐项厘清：可执行吗？两分钟内能搞定？要委派？是项目？还是下一步行动？';

  @override
  String get onboardingPage3Title => '有时间就去执行';

  @override
  String get onboardingPage3Body => '「执行」标签会按情境、精力和可用时间筛选下一步行动，让你随时知道现在可以做什么。';

  @override
  String get onboardingPage4Title => '回顾让系统值得信赖';

  @override
  String get onboardingPage4Body => '每周回顾让系统保持诚实。每周一次，过一遍所有清单，清空收件箱，预览未来。';

  @override
  String get onboardingSeedTitle => '准备就绪';

  @override
  String get onboardingSeedBody =>
      '默认情境（@phone、@computer、@errands、@home、@office、@anywhere、@waiting）已经为你预置好。可以在「设置」里增加或修改。';

  @override
  String get onboardingSeedSampleLabel => '添加示例项目';

  @override
  String get onboardingSeedSampleSubtitle => '添加一个入门项目和几个事项，让 App 不至于一片空白。';

  @override
  String get projectSectionActive => '进行中';

  @override
  String get projectSectionUnfiled => '未归类';

  @override
  String get projectSectionOnHold => '搁置';

  @override
  String get sampleProjectTitle => '充分利用 GTD';

  @override
  String get sampleProjectOutcome => '每天把收件箱处理到零，并在每周五进行每周回顾。';

  @override
  String get sampleItemReadPrimer => '在设置中阅读 GTD 入门介绍';

  @override
  String get sampleItemEmptyEmail => '把我的邮件收件箱清空到这里';

  @override
  String get sampleItemScheduleReview => '安排每周五重复的每周回顾';

  @override
  String get seedContextPhone => '@phone';

  @override
  String get seedContextComputer => '@computer';

  @override
  String get seedContextErrands => '@errands';

  @override
  String get seedContextHome => '@home';

  @override
  String get seedContextOffice => '@office';

  @override
  String get seedContextAnywhere => '@anywhere';

  @override
  String get seedContextWaiting => '@waiting';

  @override
  String get onboardingFinish => '开始吧';

  @override
  String get inboxEmptyTitle => '收件箱清零';

  @override
  String get inboxEmptyMessage => '没有需要厘清的事项。点「收集」把脑子里的事情全倒出来——稍后再处理。';

  @override
  String get inboxEmptyAction => '去收集一些';

  @override
  String inboxItemsToClarify(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 项待厘清',
      one: '1 项待厘清',
      zero: '没有待厘清的事项',
    );
    return '$_temp0';
  }

  @override
  String get processInbox => '处理收件箱';

  @override
  String deleteItemsConfirmTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '删除 $count 项？',
      one: '删除 1 项？',
    );
    return '$_temp0';
  }

  @override
  String get deleteItemsConfirmBody => '这会永久删除事项及其附件，无法撤销。';

  @override
  String deletedItemsSnackbar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已删除 $count 项。',
      one: '已删除 1 项。',
    );
    return '$_temp0';
  }

  @override
  String completedItemsSnackbar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已完成 $count 项。',
      one: '已完成 1 项。',
    );
    return '$_temp0';
  }

  @override
  String filedItemsSnackbar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已归入项目 $count 项。',
      one: '已归入项目 1 项。',
    );
    return '$_temp0';
  }

  @override
  String movedItemsSnackbar(int count, String destination) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已将 $count 项移至$destination。',
      one: '已将 1 项移至$destination。',
    );
    return '$_temp0';
  }

  @override
  String selectionCountTitle(int count) {
    return '已选 $count 项';
  }

  @override
  String get captureTitle => '清空大脑';

  @override
  String get captureHint => '你在想什么？';

  @override
  String get captureNotesHint => '备注（可选）';

  @override
  String get captureEmptyError => '请输入要收集的内容';

  @override
  String get captureSubmit => '加入收件箱';

  @override
  String get dictate => '语音输入';

  @override
  String get stopDictation => '停止语音输入';

  @override
  String get dictationUnavailable => '语音输入暂不可用。你仍然可以输入要收集的内容。';

  @override
  String get processTitle => '处理收件箱';

  @override
  String get processCompleteTitle => '收件箱清零！';

  @override
  String get processCompleteNoItems => '没有需要厘清的事项。';

  @override
  String processCompleteStats(int filed, int doneNow, int trashed) {
    return '你归档了 $filed 项，2 分钟内顺手做掉 $doneNow 项，扔掉 $trashed 项。干得漂亮。';
  }

  @override
  String processStepCounter(int step, int total) {
    return '第 $step 步 / 共 $total 步';
  }

  @override
  String processItemsRemaining(int count) {
    return '剩 $count 项';
  }

  @override
  String get previousStepTooltip => '上一步';

  @override
  String get skipItemTooltip => '跳过';

  @override
  String get actionableQuestion => '需要采取行动吗？';

  @override
  String get actionableYes => '需要——有事要做';

  @override
  String get actionableReference => '不需要——留作参考';

  @override
  String get actionableSomeday => '不需要——将来 / 也许';

  @override
  String get actionableTrash => '丢弃';

  @override
  String get twoMinQuestion => '可以在 2 分钟内完成吗？';

  @override
  String get twoMinYes => '能——我现在就做';

  @override
  String get delegateQuestion => '可以让别人去做吗？';

  @override
  String get waitingOnPromptTitle => '在等谁？';

  @override
  String get waitingOnPromptHint => '人名或系统';

  @override
  String get recurrencePrompt => '重复？';

  @override
  String get recurrenceOff => '不重复';

  @override
  String get capturedLabel => '已收集';

  @override
  String get engageTitle => '现在去做';

  @override
  String get engageEmptyTitle => '还没有下一步行动';

  @override
  String get engageEmptyMessage => '先收集一些事项或处理收件箱，下一步行动清单就会建立起来。';

  @override
  String get engageInlineEmpty => '暂无下一步行动 — 先收集一些事项或处理收件箱。';

  @override
  String get engageOpenInbox => '打开收件箱';

  @override
  String get engageNoMatchTitle => '没有匹配项';

  @override
  String get hardLandscape => '日历';

  @override
  String get hardLandscapeSubtitle => '今日到期及逾期';

  @override
  String get filterAllContexts => '全部情境';

  @override
  String get filterAnyTime => '任意时长';

  @override
  String get filterUnder5m => '< 5 分钟';

  @override
  String get filterUnder15m => '< 15 分钟';

  @override
  String get filterUnder30m => '< 30 分钟';

  @override
  String get filterUnder1h => '< 1 小时';

  @override
  String get filterAnyEnergy => '任意精力';

  @override
  String get energyLow => '低';

  @override
  String get energyMedium => '中';

  @override
  String get energyHigh => '高';

  @override
  String get projectsTitle => '项目';

  @override
  String get newProject => '新建项目';

  @override
  String get organizeLooseActionsTooltip => '整理散落的行动';

  @override
  String get projectsEmptyTitle => '还没有项目';

  @override
  String get projectsEmptyMessage =>
      '项目是任何需要多步才能达成的成果。创建项目把相关的下一步行动归到一起，朝着明确的结果稳步推进。';

  @override
  String get projectMissingNextAction => '未定义下一步行动';

  @override
  String get organizeActionsTitle => '整理行动';

  @override
  String get organizeEmptyTitle => '没有散落的行动';

  @override
  String get organizeEmptyMessage => '每个下一步行动都已归属到项目。新的未归属行动会出现在这里等待整理。';

  @override
  String assignToProject(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '将 $count 项归入项目',
      one: '将 1 项归入项目',
    );
    return '$_temp0';
  }

  @override
  String get addNextActionTitle => '添加下一步行动';

  @override
  String get addNextActionHint => '例如：把时间表邮件发给小李';

  @override
  String get addExistingActions => '加入已有的行动';

  @override
  String get noUnassignedActionsMessage => '没有可加入的未归属行动。';

  @override
  String addCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '添加 $count 项',
      one: '添加 1 项',
    );
    return '$_temp0';
  }

  @override
  String get editProject => '编辑项目';

  @override
  String get projectName => '项目名称';

  @override
  String get projectNameHint => '例如：上线新官网';

  @override
  String get projectNameRequired => '请输入项目名称';

  @override
  String get areaOfFocusOptional => '职责范围（可选）';

  @override
  String get unfiledOption => '— 未归类 —';

  @override
  String get dueDate => '截止日期';

  @override
  String get deleteProjectConfirmTitle => '删除项目？';

  @override
  String get deleteProjectWarning => '归属到此项目的事项会变成游离状态，但不会被删除。';

  @override
  String get addActionFab => '添加行动';

  @override
  String get projectOutcomeHint => '「完成」是什么样子？';

  @override
  String get outcomeSection => '成果';

  @override
  String get nextActionsSection => '下一步行动';

  @override
  String get noNextActionsMessage => '还没有下一步行动。';

  @override
  String get statusTooltip => '状态';

  @override
  String get reviewTitle => '回顾';

  @override
  String get weeklyReviewCardTitle => '每周回顾';

  @override
  String get weeklyReviewCardSubtitle => '过一遍收件箱、清单和项目。让系统始终值得信赖的仪式。';

  @override
  String get calendarEmpty => '没有与特定日期挂钩的事项。';

  @override
  String get waitingForEmpty => '没有委派出去的事项。';

  @override
  String get somedayEmpty => '没有「将来 / 也许」的事项。';

  @override
  String get referenceEmpty => '没有参考资料。';

  @override
  String get completedThisWeek => '本周已完成';

  @override
  String get completedThisWeekEmpty => '本周还没有完成任何事项。';

  @override
  String bucketCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 项',
      one: '1 项',
    );
    return '$_temp0';
  }

  @override
  String get needsReDecision => '需要重新决定';

  @override
  String pastDueCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 项已逾期',
      one: '1 项已逾期',
    );
    return '$_temp0';
  }

  @override
  String get reviewStep1Title => '腾空脑袋';

  @override
  String get reviewStep1Body => '把所有让你分心的事情都收集到收件箱里，系统才值得信赖。';

  @override
  String get reviewStep2Title => '把收件箱处理到零';

  @override
  String get reviewStep2Body => '按决策树厘清每一条收集到的事项，直到收件箱清空。';

  @override
  String get reviewStep3Title => '回顾下一步行动清单';

  @override
  String get reviewStep3Body => '把每条行动都过一遍。做完了？标记完成。过时了？修改或删除。仍是下一步？保留。';

  @override
  String get reviewStep4Title => '回顾等待清单';

  @override
  String get reviewStep4Body => '对方有回应了吗？要不要催一下？更新或移除。';

  @override
  String get reviewStep5Title => '回顾每一个项目';

  @override
  String get reviewStep5Body =>
      '回顾每个项目的预期成果。为停滞的项目添加下一步行动、暂停项目，或标记为完成。等待中的事项和已安排的工作也算作进展。';

  @override
  String get reviewStep6Title => '看看接下来两周';

  @override
  String get reviewStep6Body => '查一遍日历事项。有什么现在可以提前准备的吗？';

  @override
  String get reviewStep7Title => '回顾「将来 / 也许」';

  @override
  String get reviewStep7Body => '里面有哪些值得现在投入？把它们升级成项目或下一步行动。';

  @override
  String reviewStepCounter(int step, int total) {
    return '第 $step 步 / 共 $total 步';
  }

  @override
  String get finishReview => '完成回顾';

  @override
  String get reviewCompleteSnackbar => '每周回顾已完成';

  @override
  String get searchHint => '搜索事项、备注';

  @override
  String get searchMinChars => '至少输入两个字符';

  @override
  String get clearFilters => '清除筛选';

  @override
  String get clearSearch => '清除搜索';

  @override
  String searchNoResults(String query) {
    return '没有匹配「$query」的结果';
  }

  @override
  String get searchNoMatchTitle => '没有匹配项';

  @override
  String get searchNoMatchMessage => '当前筛选条件下没有结果。试着放宽筛选或清除筛选。';

  @override
  String get filterAllProjects => '全部项目';

  @override
  String get filterCompleted => '已完成';

  @override
  String get statusInbox => '收件箱';

  @override
  String get statusNext => '下一步';

  @override
  String get statusWaiting => '等待中';

  @override
  String get statusSomeday => '将来';

  @override
  String get statusReference => '参考资料';

  @override
  String get appearanceSection => '外观';

  @override
  String get themeLabel => '主题';

  @override
  String get themeFollowSystem => '跟随系统';

  @override
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get hapticFeedback => '触感反馈';

  @override
  String get languageLabel => '语言';

  @override
  String get languageFollowSystem => '跟随系统';

  @override
  String get contextsLabel => '情境';

  @override
  String get areasOfFocusLabel => '职责范围';

  @override
  String get calendarSyncLabel => '日历同步';

  @override
  String get remindersSection => '提醒';

  @override
  String get weeklyReviewNudge => '每周回顾提醒';

  @override
  String get weeklyReviewNudgeDescription => '每周五下午 4 点轻轻提醒一下。';

  @override
  String get remindBeforeDue => '在到期前提醒我';

  @override
  String get remindBeforeDueOff => '关闭 · 仅在到期时提醒';

  @override
  String get remindBeforeDueSuffix => '仅对此后保存的事项生效';

  @override
  String get deferSurfaceLabel => '延迟事项的提醒时间';

  @override
  String get deferSurfaceDescription => '未设具体时间的延迟事项会全天留在清单里，并在此时段提醒';

  @override
  String get checkingNotificationStatus => '正在检查通知状态…';

  @override
  String exportBackupError(String error) {
    return '导出失败：$error';
  }

  @override
  String get weeklyBackupReminder => '每周备份提醒';

  @override
  String get weeklyBackupReminderDescription => '每周日早上提醒我导出并保存备份。';

  @override
  String get importConfirmTitle => '导入这份备份？';

  @override
  String importConfirmBody(String sections) {
    return '这将新增或更新 $sections。\n\n相同 id 的现有条目会被备份中的版本覆盖，无法撤销。';
  }

  @override
  String get importButton => '导入';

  @override
  String get importFromPasteTitle => '粘贴备份 JSON';

  @override
  String get importFromPasteDescription => '也可以直接粘贴备份文本。';

  @override
  String get pasteBackupHint => '粘贴备份 JSON…';

  @override
  String get crashReports => '发送崩溃报告';

  @override
  String get crashReportsDescription =>
      '通过 Sentry 发送匿名的崩溃与错误报告。不收集任何个人数据。默认关闭。';

  @override
  String get crashReportsEnabled => '崩溃报告将在下次启动时发送';

  @override
  String get crashReportsDisabled => '已关闭崩溃报告';

  @override
  String get showOnboardingAgain => '重新查看引导';

  @override
  String get versionLabel => '版本';

  @override
  String get settingsFooter =>
      '本地优先。你的数据只留在这台设备上。灵感来自 David Allen 的《搞定》（GTD）方法论。';

  @override
  String get editTitle => '编辑';

  @override
  String get saveError => '无法保存更改，请重试。';

  @override
  String get savedIndicator => '已保存';

  @override
  String get titleLabel => '标题';

  @override
  String get notesLabel => '备注';

  @override
  String get statusSection => '状态';

  @override
  String get contextSection => '情境';

  @override
  String get energySection => '精力';

  @override
  String get timeEstimateSection => '预估耗时';

  @override
  String get waitingOnSection => '等待对象';

  @override
  String get waitingOnHint => '你在等谁或等什么？';

  @override
  String get projectSection => '项目';

  @override
  String get datesSection => '日期';

  @override
  String get dueLabel => '截止';

  @override
  String get deferUntilLabel => '延迟到';

  @override
  String get repeatSection => '重复';

  @override
  String get recurrenceNeedsDeferHint => '在上方添加「延迟到」日期才能启用重复——重复机制是把这个日期往后顺延。';

  @override
  String get recurrenceNeedsDueDateHint =>
      '在上方添加截止或延迟日期才能启用重复——重复机制是把这个日期往后顺延。';

  @override
  String get recurrenceExplanation => '完成这一项后，下一个实例会按顺延后的日期出现。';

  @override
  String get recurrenceNoDateNextActionError =>
      '这一项设置了重复，但没有「延迟到」日期，完成后不会生成下一次。请在上方添加延迟日期，或把重复设为关闭。';

  @override
  String get recurrenceNoDateError =>
      '这一项设置了重复，但没有截止或延迟日期，完成后不会生成下一次。请在上方添加日期，或把重复设为关闭。';

  @override
  String get attachmentsSection => '附件';

  @override
  String get markComplete => '标记完成';

  @override
  String get reopen => '重新打开';

  @override
  String get deleteItemConfirmTitle => '删除该事项？';

  @override
  String get deleteItemConfirmBody => '此操作无法撤销。';

  @override
  String get completeError => '无法完成此事项。';

  @override
  String get reopenError => '无法重新打开此事项。';

  @override
  String get remindersBlockedWarning => '系统设置中已屏蔽通知——这条不会提醒你。';

  @override
  String get remindersOffWarning => '提醒已关闭——这条不会提醒你。';

  @override
  String get preciseReminderOffWarning => '精确提醒时间已关闭——短时提醒可能延迟。';

  @override
  String get allowExactAlarms => '允许精确闹钟';

  @override
  String get noContextsAvailable => '还没有情境——可以在「设置」里添加。';

  @override
  String get noActiveProjects => '还没有进行中的项目。';

  @override
  String get attachmentPhoto => '照片';

  @override
  String get attachmentCamera => '相机';

  @override
  String get attachmentVoiceMemo => '语音备忘';

  @override
  String get attachmentStop => '停止';

  @override
  String get remove => '移除';

  @override
  String get imageViewerClose => '关闭';

  @override
  String imageViewerCounter(int current, int total) {
    return '$current / $total';
  }

  @override
  String attachmentPhotoCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 张照片',
    );
    return '$_temp0';
  }

  @override
  String attachmentAudioCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 条语音备忘',
    );
    return '$_temp0';
  }

  @override
  String attachmentFileCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个文件',
    );
    return '$_temp0';
  }

  @override
  String get areasTitle => '职责范围';

  @override
  String get newArea => '新建范围';

  @override
  String get renameArea => '重命名范围';

  @override
  String get areasEmptyMessage => '还没有职责范围。范围是你长期负责的领域——健康、事业、家庭——用来归纳项目。';

  @override
  String get areaNameHint => '例如：健康、事业、家庭';

  @override
  String deleteAreaConfirmTitle(String name) {
    return '删除「$name」？';
  }

  @override
  String get deleteAreaWarning => '此范围下的项目会变成未归类（但不会被删除）。';

  @override
  String get contextsTitle => '情境';

  @override
  String get newContext => '新建情境';

  @override
  String get editContext => '编辑情境';

  @override
  String get contextsEmptyMessage =>
      '还没有情境。情境用来标记行动要在哪里或借助什么完成（@phone、@home、@errands）。';

  @override
  String get nameLabel => '名称';

  @override
  String get iconLabel => '图标';

  @override
  String get colorLabel => '颜色';

  @override
  String deleteContextConfirmTitle(String name) {
    return '删除 $name？';
  }

  @override
  String get deleteContextWarning => '使用此情境的事项会失去该情境。';

  @override
  String get calendarSyncTitle => '日历同步';

  @override
  String get calendarSyncIntro =>
      '把带截止日期的事项同步到系统日历，并把标记「#gtd」的日历事件拉回 Trayzero 收件箱。';

  @override
  String get enableCalendarSync => '启用日历同步';

  @override
  String get targetCalendar => '目标日历';

  @override
  String get calendarAccessDenied => '已拒绝访问日历。请授予权限才能选择目标日历。';

  @override
  String get grantCalendarAccess => '授予日历访问权限';

  @override
  String get noCalendarsAvailable =>
      '暂时没有可用的日历。如果你刚刚授权，请稍等再重试。也请确认系统「日历 / 账户」设置里你的账户已开启同步。';

  @override
  String get mirrorOutAction => '把事项同步 → 日历';

  @override
  String get importInAction => '导入 #gtd 事件 → 收件箱';

  @override
  String mirrorOutSuccess(int written) {
    return '已同步 $written 项到日历';
  }

  @override
  String mirrorOutSuccessWithStale(int written, int removed) {
    return '已同步 $written 项到日历，清理了 $removed 条过期数据';
  }

  @override
  String importInSuccess(int count) {
    return '已导入 $count 条日历事件';
  }

  @override
  String get mirroringProgress => '正在同步…';

  @override
  String get importingProgress => '正在导入…';

  @override
  String get calendarSyncTip =>
      '小贴士：在日历事件标题里任意位置输入「#gtd」，下次同步时它就会出现在你的 Trayzero 收件箱里。';

  @override
  String get gtdDiagramTitle => 'GTD 怎么运作';

  @override
  String get gtdDiagramSubtitle => '用五步把所有未了之事从脑袋里搬到一个值得信赖的系统里。点击高亮的清单可以直接跳转。';

  @override
  String get gtdAttribution => '方法源自 David Allen · gettingthingsdone.com';

  @override
  String get youAreHere => '你在这里';

  @override
  String get gtdStage1Body => '把所有让你分心的事情——任务、点子、担忧——都扔进收件箱。先不筛选，也不整理。';

  @override
  String get gtdStage2Body => '一次拿一件，决定它是什么。处理流程会带你走完这棵决策树：';

  @override
  String get gtdStage3Body => '结果会落到正确的清单上，从此不再装在脑袋里。';

  @override
  String get gtdStage3Footnote => '等待 / 日历 / 将来 / 参考资料都在「回顾」下。';

  @override
  String get gtdStage4Body => '定期回顾你的清单——尤其是每周回顾——让系统始终值得信赖。';

  @override
  String get gtdStage5Body => '放心去做——按情境、时间、精力和优先级挑选行动，心无旁骛。';

  @override
  String get decisionNotActionableQ => '不可执行？';

  @override
  String get decisionNotActionableA => '丢弃、将来 / 也许，或参考资料';

  @override
  String get decisionTwoMinQ => '2 分钟内能搞定？';

  @override
  String get decisionTwoMinA => '现在就做';

  @override
  String get decisionDelegateQ => '该让别人做？';

  @override
  String get decisionDelegateA => '委派 → 等待中';

  @override
  String get decisionMultiStepQ => '需要多个步骤？';

  @override
  String get decisionMultiStepA => '变成一个项目';

  @override
  String get decisionOtherwiseQ => '其他情况';

  @override
  String get decisionOtherwiseA => '定义最具体的下一步行动';

  @override
  String get supportTitle => '支持 Trayzero';

  @override
  String get supportIntro =>
      'Trayzero 完全免费，所有功能都已解锁。如果它帮到了你，你可以略表心意——这有助于让应用保持独立、无广告。';

  @override
  String get supportUnavailable => '支持选项暂时无法使用。';

  @override
  String get supportTipHeader => '打赏一下';

  @override
  String get supportTipSmall => '小额打赏';

  @override
  String get supportTipLarge => '大额打赏';

  @override
  String get supportSupporterYearly => '支持者 — 按年';

  @override
  String supportSupporterYearlySubtitle(String price) {
    return '$price / 年 · 最划算 · 支持开发';
  }

  @override
  String get supportSupporterMonthly => '支持者 — 按月';

  @override
  String supportSupporterMonthlySubtitle(String price) {
    return '$price / 月 · 随时取消';
  }

  @override
  String supportOpeningStore(String store) {
    return '正在打开$store…';
  }

  @override
  String get supportRestoring => '正在恢复购买…';

  @override
  String get supportRestore => '恢复购买';

  @override
  String get supportRestoreSubtitle => '已经是支持者了？在此设备上恢复。';

  @override
  String get supportAutoRenewNote => '订阅会自动续期，直到你在“设置”中取消。';

  @override
  String get legalPrivacyPolicy => '隐私政策';

  @override
  String get legalTermsOfUse => '使用条款';

  @override
  String get supportThanksTip => '非常感谢！💙';

  @override
  String get supportThanksSupporter => '你现在是支持者了——谢谢你！💙';

  @override
  String get supportRestored => '购买已恢复。欢迎回来！💙';

  @override
  String get supportRestoreNone => '未找到以往的购买记录。';

  @override
  String get supportBadgeYearly => '支持者 · 按年';

  @override
  String get supportBadgeMonthly => '支持者 · 按月';

  @override
  String get supportBadgeGeneric => '支持者';

  @override
  String get supportBadgeSubtitle => '感谢你让 Trayzero 保持独立。';

  @override
  String get calendarLookupFailed => '无法加载设备日历。请在系统日历应用中检查账户同步，然后返回重试。';

  @override
  String get calendarPermissionHelp => '如果没有出现权限提示，请在应用设置中允许访问日历，然后返回此处。';

  @override
  String get calendarOpenSettings => '打开应用设置';

  @override
  String get calendarSettingsFailed => '无法打开应用设置。请在设备设置中找到 Trayzero 并允许访问日历。';

  @override
  String get calendarSelectionUnavailable => '之前选择的日历已不可用。请选择其他日历。';

  @override
  String get appIcon => '应用图标';

  @override
  String get appIconAndroidDescription =>
      '主屏幕图标可独立于应用颜色选择。启动器可能需要片刻才能更新，也可能应用自己的色调。';

  @override
  String get appIconDescription =>
      '图标可独立于应用颜色选择。设备可能应用自己的色调。iOS 会在图标更改时显示确认提示。';

  @override
  String get appIconChangeFailed => '无法更改应用图标。请在 Trayzero 打开时重试。';

  @override
  String get appColor => '应用颜色';

  @override
  String get appColorDescription => '适用于浅色和深色模式。GTD 列表颜色的含义保持不变。';

  @override
  String get paletteAmber => 'Trayzero 琥珀色 — 默认';

  @override
  String get paletteBlue => '蓝色';

  @override
  String get paletteCyan => '青蓝色';

  @override
  String get paletteTeal => '青色';

  @override
  String get paletteGreen => '绿色';

  @override
  String get paletteViolet => '紫色';

  @override
  String get paletteRose => '玫瑰色';

  @override
  String get appIconNotificationNote =>
      'Android 通知在安排提醒时使用所选应用图标的颜色。现有通知会在重新安排时更新。部分设备可能显示原始应用图标。';

  @override
  String get appearanceSaveFailed => '无法保存外观设置，已恢复之前的设置。';

  @override
  String mirrorOutPendingCleanup(int count) {
    return '还有 $count 个日历事件需要清理。请再次同步以重试。';
  }

  @override
  String get weeklyReviewResume => '继续每周回顾';

  @override
  String get weeklyReviewProgressSaved => '离开页面后，回顾进度仍会保留。';

  @override
  String get weeklyReviewSaveError => '无法保存回顾进度，请重试。';

  @override
  String get weeklyReviewActionError => '无法保存此项更改，请重试。';

  @override
  String get weeklyReviewListEmpty => '这里没有需要回顾的事项。';

  @override
  String get weeklyReviewProjectAwaiting => '等待中或已安排的事项正在推动此项目。';

  @override
  String get weeklyReviewProjectMoving => '已确定下一步行动';

  @override
  String get weeklyReviewOpenProject => '打开项目';

  @override
  String get processTwoMinNo => '否 — 继续理清';

  @override
  String get twoMinRule => '两分钟法则：如果完成比记录更省时，就马上做。';

  @override
  String get delegateYes => '是 — 委派给他人并等待回复';

  @override
  String get delegateNo => '否 — 由我来做';

  @override
  String get singleStepQuestion => '这是一个具体的单步行动吗？';

  @override
  String get singleStepYes => '是 — 一个下一步行动';

  @override
  String get singleStepProject => '否 — 这是一个项目';

  @override
  String get projectRule => '项目是需要多个行动步骤、并能在一年内完成的成果。';

  @override
  String get deferQuestion => '有指定的日期或时间吗？';

  @override
  String get deferAsap => '否 — 尽快完成';

  @override
  String get deferCalendar => '是 — 放入日历';

  @override
  String get deferChooseDate => '延迟到指定日期';

  @override
  String get processDetailsTitle => '添加详情';

  @override
  String get processFileNextAction => '保存为下一步行动';

  @override
  String minutesShort(int minutes) {
    return '$minutes 分钟';
  }

  @override
  String deferredUntilSummary(String date) {
    return '延迟到 $date';
  }

  @override
  String deferredRepeatingSummary(String date, String recurrence) {
    return '延迟到 $date · 重复：$recurrence';
  }

  @override
  String get recurrenceDaily => '每天';

  @override
  String get recurrenceWeekly => '每周';

  @override
  String get recurrenceMonthly => '每月';

  @override
  String get recurrenceYearly => '每年';

  @override
  String get createProject => '创建';

  @override
  String get projectPickerTitle => '移入项目';

  @override
  String get projectMoved => '已移入项目。';

  @override
  String get projectDetached => '已从项目移除。';

  @override
  String get noProject => '无项目';

  @override
  String get decreaseRepeatInterval => '缩短重复间隔';

  @override
  String get increaseRepeatInterval => '延长重复间隔';

  @override
  String get decreaseRepeatCount => '减少重复次数';

  @override
  String get increaseRepeatCount => '增加重复次数';

  @override
  String get repeatOn => '重复星期';

  @override
  String get repeatMonthlyOn => '重复日期';

  @override
  String get repeatDayOfMonth => '按日期';

  @override
  String get repeatDayOfWeek => '按星期';

  @override
  String get repeatFirst => '第一个';

  @override
  String get repeatSecond => '第二个';

  @override
  String get repeatThird => '第三个';

  @override
  String get repeatFourth => '第四个';

  @override
  String get repeatFifth => '第五个';

  @override
  String get repeatLast => '最后一个';

  @override
  String get repeatEnds => '结束条件';

  @override
  String get repeatNever => '永不结束';

  @override
  String get repeatOnDate => '指定日期';

  @override
  String get repeatAfterCount => '指定次数';

  @override
  String get weekdayListSeparator => '、';

  @override
  String get dueToday => '今天到期';

  @override
  String get reschedule => '重新安排';

  @override
  String get complete => '完成';

  @override
  String get drop => '放弃';

  @override
  String get trash => '回收站';

  @override
  String itemEnergyLabel(String energy) {
    return '精力：$energy';
  }

  @override
  String waitingOnPerson(String person) {
    return '等待 $person';
  }

  @override
  String dueOverdueDays(int days) {
    return '已逾期 · $days 天';
  }

  @override
  String dueTodayAt(String time) {
    return '今天到期，$time';
  }

  @override
  String selectItem(String title) {
    return '选择 $title';
  }

  @override
  String markItemDone(String title) {
    return '将 $title 标记为完成';
  }

  @override
  String repeatLastOnDate(String date) {
    return '最后一次：$date';
  }

  @override
  String repeatAfterOccurrences(int count) {
    return '重复 $count 次后结束';
  }

  @override
  String recurrenceUntilSummary(String pattern, String date) {
    return '$pattern · 截至 $date';
  }

  @override
  String recurrenceCountSummary(String pattern, int count) {
    return '$pattern · 共 $count 次';
  }

  @override
  String recurrenceOnWeekdays(String cadence, String weekdays) {
    return '$cadence的$weekdays';
  }

  @override
  String recurrenceOnNthWeekday(
    String cadence,
    String ordinal,
    String weekday,
  ) {
    String _temp0 = intl.Intl.selectLogic(ordinal, {
      'first': '第一个',
      'second': '第二个',
      'third': '第三个',
      'fourth': '第四个',
      'fifth': '第五个',
      'other': '最后一个',
    });
    return '$cadence的$_temp0$weekday';
  }

  @override
  String repeatEveryDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '每 $count 天',
      one: '每天',
    );
    return '$_temp0';
  }

  @override
  String repeatEveryWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '每 $count 周',
      one: '每周',
    );
    return '$_temp0';
  }

  @override
  String repeatEveryMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '每 $count 个月',
      one: '每月',
    );
    return '$_temp0';
  }

  @override
  String repeatEveryYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '每 $count 年',
      one: '每年',
    );
    return '$_temp0';
  }

  @override
  String get captureAddContinue => '添加并继续';

  @override
  String captureAddedCount(int count) {
    return '已添加 $count 项到收件箱';
  }

  @override
  String get folderBackupChoose => '选择备份文件夹';

  @override
  String get folderBackupSaving => '正在备份…';

  @override
  String get folderBackupOff => '自动备份已关闭。';

  @override
  String get folderBackupNever => '尚无成功的备份。';

  @override
  String folderBackupLastSuccess(String date) {
    return '上次备份：$date';
  }

  @override
  String get folderBackupFailed => '备份失败。请检查文件夹访问权限和可用空间，然后重试。';

  @override
  String get folderBackupHistoryWarning => '备份已保存，但无法删除较早的备份。';

  @override
  String get folderBackupNow => '立即备份';

  @override
  String get doViewToday => '今天';

  @override
  String get doViewNextActions => '下一步行动';

  @override
  String get todayPlanCardTitle => '规划今天';

  @override
  String get todayPlanCardBody => '选出今天要专注的事情，大约只需两分钟。';

  @override
  String get todayPlanAction => '规划今天';

  @override
  String todayCarryOverLine(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '有 $count 项之前的事项需要决定',
    );
    return '$_temp0';
  }

  @override
  String get todayFocusHeader => '专注';

  @override
  String todayDoneCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '今天已完成 $count 项',
    );
    return '$_temp0';
  }

  @override
  String get todayEmptyTitle => '还没有专注事项';

  @override
  String get todayEmptyMessage => '为下一步行动加星标，承诺今天完成，或者规划今天。';

  @override
  String get focusAddTooltip => '加入今天';

  @override
  String get focusRemoveTooltip => '从今天移除';

  @override
  String focusAddItem(String title) {
    return '将“$title”加入今天';
  }

  @override
  String focusRemoveItem(String title) {
    return '将“$title”从今天移除';
  }

  @override
  String get focusError => '无法更新今天，请重试。';

  @override
  String get planTodayIntro => '为今天要做的事加星标。保持简短，其他事项仍留在你的清单中。';

  @override
  String get planSectionCarryOver => '之前的';

  @override
  String get planCarryOverHint => '开始今天后，未保留的事项会回到各自的清单。';

  @override
  String get planKeepAll => '全部保留';

  @override
  String get planSectionCalendar => '日历';

  @override
  String get planOnToday => '已在今日';

  @override
  String get planSectionWaiting => '需要跟进的等待事项';

  @override
  String get planSectionAvailable => '今天起可做';

  @override
  String get planEmpty => '暂时没有可规划的事项。处理收件箱以建立下一步行动。';

  @override
  String planFocusedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '今天专注 $count 项',
      zero: '还没有专注事项',
    );
    return '$_temp0';
  }

  @override
  String get planStartDay => '开始今天';

  @override
  String get planDoneSnackbar => '今天已规划好';

  @override
  String planClearedSnackbar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已规划 · $count 项已回到清单',
    );
    return '$_temp0';
  }

  @override
  String get planSaveError => '无法保存计划，请重试。';

  @override
  String get captureTipDates => '提示：可添加 @情境、#项目、+标签，或英文日期如“tomorrow”。';

  @override
  String get captureTipSigils => '提示：可添加 @情境、#项目 或 +标签。';

  @override
  String startsOnDate(String date) {
    return '开始于 $date';
  }

  @override
  String dueOnDate(String date) {
    return '截止 $date';
  }

  @override
  String captureChipProject(String name) {
    return '项目：$name';
  }

  @override
  String get captureKeepAsText => '保留为文字';

  @override
  String get captureRecognized => '识别出的详情';

  @override
  String deferUseStartDate(String date) {
    return '于 $date 开始';
  }

  @override
  String deferUseDueDate(String date) {
    return '排入日程 $date';
  }

  @override
  String weeklyReviewProjectInactive(int days) {
    return '$days 天以上无进展';
  }

  @override
  String get weeklyReviewMarkReviewed => '标记为已回顾';

  @override
  String get weeklyReviewReviewed => '已回顾';

  @override
  String weeklyReviewLastReviewed(String date) {
    return '上次回顾 $date';
  }

  @override
  String get weeklyReviewNeverReviewed => '尚未回顾';

  @override
  String weeklyReviewReviewedProgress(int done, int total) {
    return '已回顾 $done/$total';
  }

  @override
  String get importFromApp => '从其他应用导入';

  @override
  String get importSourcePlainText => '纯文本 / TaskPaper';

  @override
  String get importHintTodoist => '项目菜单 › 导出为模板 › CSV，或在 设置 › 备份 中下载 ZIP。';

  @override
  String get importHintTickTick =>
      '在 TickTick 网站上：设置 › 账户 › 备份与导入 › 生成备份（CSV）。';

  @override
  String get importHintNirvana => '在 Nirvana 网页版中将数据导出为 CSV 或 JSON。';

  @override
  String get importHintOmniFocus => '选中项目，然后 编辑 › 拷贝为 TaskPaper。粘贴到这里或存为文件。';

  @override
  String get importHintPlainText =>
      'Things：复制待办事项并粘贴到这里，每行一个任务。仅支持基础文本导入，不支持 Things 数据库导出文件。';

  @override
  String get importChooseFile => '选择文件';

  @override
  String get importPasteText => '粘贴文本';

  @override
  String get importPasteTitle => '粘贴任务';

  @override
  String get importPasteHint => '每行一个任务。在以“:”结尾的行下缩进即可组成项目。';

  @override
  String get importPasteContinue => '预览';

  @override
  String get importPreviewNothingYet => '目前还没有添加任何内容。';

  @override
  String get importPreviewProjects => '项目';

  @override
  String get importProjectNew => '新建';

  @override
  String get importProjectExisting => '加入已有项目';

  @override
  String importProjectActions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个行动',
    );
    return '$_temp0';
  }

  @override
  String importContextsNew(String names) {
    return '新建：$names';
  }

  @override
  String importContextsExisting(String names) {
    return '已有：$names';
  }

  @override
  String get importGoodToKnow => '须知';

  @override
  String importWarnCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '跳过 $count 个已完成或已放弃的任务',
    );
    return '$_temp0';
  }

  @override
  String importWarnCalendar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个有截止日期的行动放入日历',
    );
    return '$_temp0';
  }

  @override
  String importWarnDates(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个无法识别的日期保留在备注中',
    );
    return '$_temp0';
  }

  @override
  String importWarnRepeats(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 条重复规则保留在备注中',
    );
    return '$_temp0';
  }

  @override
  String importWarnSubtasks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个子任务变为独立行动',
    );
    return '$_temp0';
  }

  @override
  String importWarnSections(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个任务在备注中记下所属分组',
    );
    return '$_temp0';
  }

  @override
  String importWarnNotImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个任务的优先级、旗标或负责人不会导入',
    );
    return '$_temp0';
  }

  @override
  String importWarnUnreadable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '跳过 $count 行无标题的记录',
    );
    return '$_temp0';
  }

  @override
  String importDoneTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已添加 $count 个任务',
    );
    return '$_temp0';
  }

  @override
  String get importDoneBody => '改主意了？撤销只会移除这次导入添加的内容，不影响其他。';

  @override
  String get importUndo => '撤销导入';

  @override
  String get importFinish => '完成';

  @override
  String get importUndoneTitle => '已撤销导入';

  @override
  String get importUndoneBody => '这次导入添加的所有内容都已移除。';

  @override
  String get importRemindersFailed => '部分提醒暂时无法设置，将在下次打开应用时设置。';

  @override
  String importErrorUnrecognized(String source) {
    return '这看起来不是 $source 的导出文件。请检查步骤后重试。';
  }

  @override
  String get importErrorNoTasks => '没有可导入的未完成任务。';

  @override
  String get importErrorUnreadable => '无法读取此文件。请选择文本、CSV 或 ZIP 导出文件。';

  @override
  String get importErrorWrite => '导入失败，未添加任何内容。';

  @override
  String get importErrorUndo => '无法撤销导入，请重试。';

  @override
  String get tagsAndPeopleLabel => '标签和人员';

  @override
  String get tagsEmptyMessage =>
      '标签可跨列表标记事项。把标签设为人员，就能为其保留一份要讨论事项的议程。提示：记录时输入 +标签。';

  @override
  String get newTag => '新建标签';

  @override
  String get editTag => '编辑标签';

  @override
  String get tagPersonSwitch => '人员';

  @override
  String get tagPersonSwitchHint => '保留一份要讨论事项的议程';

  @override
  String tagOpenItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个未完成事项',
      zero: '没有未完成事项',
    );
    return '$_temp0';
  }

  @override
  String deleteTagConfirmTitle(String name) {
    return '删除“$name”？';
  }

  @override
  String deleteTagConfirmBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个未完成事项使用它。事项会保留，只移除标签。',
      zero: '没有未完成事项使用它。',
    );
    return '$_temp0';
  }

  @override
  String get tagMergeTitle => '合并标签？';

  @override
  String tagMergeBody(String source, String target) {
    return '“$target”已存在。要将“$source”合并进去吗？';
  }

  @override
  String get tagMergeAction => '合并';

  @override
  String get addTag => '添加标签';

  @override
  String get tagPickerHint => '搜索或创建标签';

  @override
  String tagCreate(String name) {
    return '创建“$name”';
  }

  @override
  String tagCreatePerson(String name) {
    return '创建人员“$name”';
  }

  @override
  String get tagsSection => '标签';

  @override
  String tagChipSemantics(String name) {
    return '标签：$name';
  }

  @override
  String personChipSemantics(String name) {
    return '人员：$name';
  }

  @override
  String removeTagTooltip(String name) {
    return '移除 $name';
  }

  @override
  String moreTags(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '另外 $count 个标签',
    );
    return '$_temp0';
  }

  @override
  String get filterTag => '标签';

  @override
  String get filterAnyTag => '任意标签';

  @override
  String get agendasTitle => '议程';

  @override
  String agendasPeopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 人',
    );
    return '$_temp0';
  }

  @override
  String agendaAddHint(String name) {
    return '添加要与 $name 讨论的事';
  }

  @override
  String get agendaAddTooltip => '添加到议程';

  @override
  String agendaEmpty(String name) {
    return '暂时没有要与 $name 讨论的事。';
  }

  @override
  String get agendaNotFound => '此人员已不存在。';

  @override
  String captureChipNewTag(String name) {
    return '新标签：$name';
  }

  @override
  String get importHintGoogleTasks =>
      'Google Takeout › 选择 Tasks › 导出 JSON。解压下载文件并选择 Tasks.json。列表名称保留在备注中，已完成任务进入“已完成”。';

  @override
  String get importDuplicateWarning =>
      '此设备之前已导入过完全相同的数据。再次导入会添加重复任务。如果不需要另一份副本，请取消。';

  @override
  String get importHintThings =>
      '选择 main.sqlite 或 Things 3 导出数据库文件夹的 ZIP。iPhone/iPad：设置 › 通用 › 诊断 › 输入代码 › 491348 › 发送 Things 数据库。保存到“文件”，解压 .aar，再将数据库文件夹压缩为 ZIP。Mac：复制前退出 Things。导入后需重新设置重复规则和提醒。';

  @override
  String importWarnDetailsInNotes(int count) {
    return '$count 个任务的清单或领域信息保留在备注中';
  }

  @override
  String get importWarnThingsRecurrence =>
      '不导入 Things 重复规则。将跳过重复模板；请为导入的任务重新设置重复规则。';

  @override
  String importWarnSourceReminders(int count) {
    return '$count 个来源提醒设置未导入';
  }

  @override
  String get importAppleHint => '选择此设备上的提醒事项列表。仅导入未完成的提醒事项。';

  @override
  String get importAppleChooseLists => '选择列表';

  @override
  String get importAppleReloadLists => '重新加载列表';

  @override
  String get importAppleNoLists => '此设备上没有可用的提醒事项列表。';

  @override
  String get importAppleDenied =>
      '提醒事项访问权限已关闭。请在 iOS 设置中允许 Trayzero 访问提醒事项，然后重试。';

  @override
  String get importAppleUnavailable => '无法读取 Apple 提醒事项，请重试。';

  @override
  String get importAppleListsChanged => '所选列表已不可用。请重新加载列表并再次选择。';

  @override
  String get importAppleLimits =>
      '原有 Apple 提醒事项保持不变。Apple 标签、旗标、附件、子任务结构、优先级及原有提醒通知不会复制。再次导入可能产生重复任务。';

  @override
  String get importHintMicrosoftTodo => '登录以复制列表和未完成的任务。导入前可先预览；重复导入可能产生重复任务。';

  @override
  String get importMicrosoftUnavailable => '此版本暂不支持从 Microsoft To Do 导入。';

  @override
  String get importMicrosoftSignInError => 'Microsoft 登录失败或已过期，请重新登录。';

  @override
  String get importMicrosoftPermissionError =>
      'Microsoft 未允许访问你的任务。请检查账户权限或联系所属组织。';

  @override
  String get importMicrosoftNetworkError =>
      '无法读取全部 Microsoft 任务，未导入任何内容。请检查网络连接后重试。';

  @override
  String importWarnSourceDetails(int count) {
    return '$count 个任务包含不会导入的附件、提醒设置或状态。';
  }

  @override
  String get moreGroupOrganize => '整理';

  @override
  String get moreGroupPreferences => '偏好设置';

  @override
  String get moreGroupData => '数据';

  @override
  String get moreOn => '开';

  @override
  String get moreOff => '关';

  @override
  String moreAppearanceSummary(String theme, String palette) {
    return '$theme · $palette';
  }

  @override
  String get moreRemindersBlockedTitle => '提醒已被屏蔽';

  @override
  String get moreRemindersBlockedBody => '通知已关闭，提醒无法通知你。';

  @override
  String get moreBackupFailedTitle => '备份失败';

  @override
  String get moreBackupFailedBody => '自动备份无法保存。请检查文件夹和可用空间。';

  @override
  String get moreFix => '修复';

  @override
  String get moreBackupRestore => '备份与恢复';

  @override
  String get moreBackupSubtitleOff => '自动备份已关闭';

  @override
  String get moreBackupSubtitleFailed => '备份失败';

  @override
  String get moreImportSources => 'Todoist、TickTick、OmniFocus 等';

  @override
  String get moreSupportTrailing => '可选';

  @override
  String get moreSupportTrailingSupporter => '支持者';

  @override
  String get moreAboutPrivacy => '关于与隐私';

  @override
  String get moreHowGtdWorks => 'GTD 如何运作';

  @override
  String get moreNudgesGroup => '提醒推送';

  @override
  String get moreTimingGroup => '时间';

  @override
  String get moreLeadOff => '关';

  @override
  String get moreLead10 => '提前 10 分钟';

  @override
  String get moreLead30 => '提前 30 分钟';

  @override
  String get moreLead60 => '提前 1 小时';

  @override
  String get moreLead1440 => '提前 1 天';

  @override
  String moreLeadOther(int minutes) {
    return '提前 $minutes 分钟';
  }

  @override
  String moreRestoredEntries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 条',
    );
    return '已恢复 $_temp0记录。';
  }

  @override
  String get moreBackupEmpty => '此备份中没有可恢复的条目。';

  @override
  String get moreCouldntOpenLink => '无法打开链接';

  @override
  String moreVersionBuild(String version, String build) {
    return '$version（构建 $build）';
  }

  @override
  String get supportBestValue => '最超值';

  @override
  String get importListIntro => '选择你现在使用的任务应用。添加任何内容之前，你都会先看到预览。';

  @override
  String get importGroupDirect => '直接连接';

  @override
  String get importGroupFile => '从导出文件';

  @override
  String get importGroupOther => '其他';

  @override
  String get importSubGoogleTasks => 'Takeout · Tasks.json';

  @override
  String get importSubTodoist => 'CSV 模板或备份 ZIP';

  @override
  String get importSubThings => '数据库 ZIP 或 main.sqlite';

  @override
  String get importSubTickTick => '备份 CSV';

  @override
  String get importSubNirvana => 'CSV 或 JSON 导出';

  @override
  String get importSubOmniFocus => 'TaskPaper 文件或粘贴';

  @override
  String get importSubPlainText => '粘贴列表，每行一个任务';

  @override
  String get importSubApple => '选择此设备上的列表';

  @override
  String get importSubMicrosoft => '列表和未完成任务';

  @override
  String get importChipOnDevice => '本机';

  @override
  String get importChipSignIn => '登录';

  @override
  String get importBackupFooter => '要恢复 Trayzero 备份？';

  @override
  String get importBackupFooterLink => '备份与恢复';

  @override
  String get importThingsDeviceIos => 'iPhone / iPad';

  @override
  String get importThingsDeviceMac => 'Mac';

  @override
  String get importCopyCode => '复制代码';

  @override
  String get importCodeCopied => '已复制代码';

  @override
  String get importConnect => '连接';

  @override
  String get importStepGoogleTasks1 => '打开 Google Takeout，只选择 Tasks。';

  @override
  String get importStepGoogleTasks2 => '导出为 JSON，并解压下载的文件。';

  @override
  String get importStepGoogleTasks3 => '在下方选择 Tasks.json。';

  @override
  String get importNoteGoogleTasks => '列表会保留在备注中；已完成的任务会进入“完成”。';

  @override
  String get importStepTodoist1 => '打开项目菜单，选择“导出为模板”(CSV)。';

  @override
  String get importStepTodoist2 => '或在“设置 › 备份”中保存备份 ZIP。';

  @override
  String get importStepTodoist3 => '在下方选择该文件。';

  @override
  String get importStepTickTick1 => '在 TickTick 网站上打开“设置 › 账户”。';

  @override
  String get importStepTickTick2 => '打开“备份与导入”，点击“生成备份”(CSV)。';

  @override
  String get importStepTickTick3 => '在下方选择该 CSV。';

  @override
  String get importStepNirvana1 => '在 Nirvana 网页版中将数据导出为 CSV 或 JSON。';

  @override
  String get importStepNirvana2 => '在下方选择该文件。';

  @override
  String get importStepOmniFocus1 => '在 OmniFocus 中选择你的项目。';

  @override
  String get importStepOmniFocus2 => '选择“编辑 › 拷贝为 TaskPaper”。';

  @override
  String get importStepOmniFocus3 => '在下方粘贴文本，或将其保存为文件后选择。';

  @override
  String get importStepPlainText1 => '从任意应用复制任务，每行一个。';

  @override
  String get importStepPlainText2 => '点击下方的“粘贴文本”并粘贴。';

  @override
  String get importNotePlainText => '仅支持基本文本导入，不支持其他应用的数据库导出。';

  @override
  String get importStepApple1 => '点击下方的“选择列表”。';

  @override
  String get importStepApple2 => '出现提示时，允许访问“提醒事项”。';

  @override
  String get importStepApple3 => '勾选要导入的列表。';

  @override
  String get importNoteApple => '仅导入未完成的提醒事项。你的 Apple 提醒事项保持不变。';

  @override
  String get importStepMicrosoft1 => '点击“连接”并登录 Microsoft。';

  @override
  String get importStepMicrosoft2 => 'Trayzero 会复制你的列表和未完成任务。';

  @override
  String get importStepMicrosoft3 => '导入前先查看预览。';

  @override
  String get importNoteMicrosoft => '再次导入可能会产生重复项。';

  @override
  String get importStepThingsIos1 => '在 Things 中打开“设置 › 通用 › 诊断 › 输入代码”，然后输入：';

  @override
  String get importStepThingsIos2 => '点击“发送 Things 数据库”并存储到“文件”。';

  @override
  String get importStepThingsIos3 => '在“文件”中解压 .aar，然后将数据库文件夹压缩为 ZIP。';

  @override
  String get importStepThingsIos4 => '在下方选择该 ZIP。';

  @override
  String get importStepThingsMac1 => '在 Mac 上退出 Things。';

  @override
  String get importStepThingsMac2 =>
      '从 Things 文件夹复制 Things Database.thingsdatabase，并将副本压缩为 ZIP。';

  @override
  String get importStepThingsMac3 => '将 ZIP（或其中的 main.sqlite）传到此设备，并在下方选择。';

  @override
  String get importNoteThings => '重复和提醒不会带过来，导入后请重新创建。';

  @override
  String get importReviewTitle => '检查导入内容';

  @override
  String importFromSource(String source) {
    return '来自 $source';
  }

  @override
  String importTotalTasks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 项任务',
    );
    return '$_temp0';
  }

  @override
  String importActionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '导入 $count 项任务',
    );
    return '$_temp0';
  }

  @override
  String importNewExistingSummary(int newCount, int existingCount) {
    return '$newCount 项新增 · $existingCount 项已有';
  }

  @override
  String importShowAll(int count) {
    return '显示全部 $count 项';
  }

  @override
  String get importContextsAndTags => '情境和标签';

  @override
  String importNotesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 条说明',
    );
    return '$_temp0';
  }

  @override
  String get notificationStatusOnTitle => '提醒已开启';

  @override
  String get notificationStatusOnBody => '提醒会在此设备上通知你。';

  @override
  String get notificationStatusOffTitle => '提醒已关闭';

  @override
  String get notificationStatusOffBody => '提醒已安排，但在你允许通知之前不会提醒你。';

  @override
  String get notificationStatusBlockedTitle => '提醒已被阻止';

  @override
  String get notificationStatusBlockedBody =>
      '系统设置中已关闭 Trayzero 的通知。在那里重新开启之前，提醒不会通知你。';

  @override
  String get notificationActionEnable => '启用通知';

  @override
  String get notificationActionOpenSettings => '打开设置';

  @override
  String get notificationPrimerTitle => '开启提醒？';

  @override
  String get notificationPrimerBody =>
      'Trayzero 会在此设备上发送通知，提醒你到期日和每周回顾。不会向服务器发送任何内容，提醒均在本地安排。\n\n接下来，你的设备会请求显示通知的权限。';

  @override
  String get notificationPrimerNotNow => '暂不';

  @override
  String get notificationPrimerContinue => '继续';

  @override
  String get notificationPromptFailed => '无法打开通知权限提示。';

  @override
  String get notificationAlreadyOn => '提醒已经开启。';

  @override
  String get notificationOpenedSettings => '已打开系统设置，请为 Trayzero 开启通知。';

  @override
  String get notificationStayOff => '提醒保持关闭。你可以随时在“更多”→“提醒”中启用。';

  @override
  String get notificationNowOn => '提醒已开启。';

  @override
  String get notificationBlocked => 'Trayzero 的通知已被阻止。';

  @override
  String get exactAlarmSettingsFailed => '无法打开精确闹钟设置。';

  @override
  String get exactAlarmAlreadyOn => '精确提醒时间已经开启。';

  @override
  String get exactAlarmNowOn => '精确提醒时间已开启。';

  @override
  String get exactAlarmStaysOff => '精确提醒时间保持关闭。短时间提醒可能会延迟。';

  @override
  String get attachmentRemoved => '附件已移除。';

  @override
  String get discardCaptureTitle => '放弃此次记录？';

  @override
  String get discardCaptureBody => '你输入的内容将会丢失。';

  @override
  String get keepEditing => '继续编辑';

  @override
  String get discard => '放弃';

  @override
  String get processFiledSnackbar => '已归类。';

  @override
  String get errorLoadTitle => '无法加载';

  @override
  String get errorLoadBody => '你的数据是安全的。请重试。';

  @override
  String sharedAddedToInbox(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已将 $count 项添加到收集箱',
    );
    return '$_temp0';
  }

  @override
  String get filterByProject => '按项目筛选';

  @override
  String get projectStatusActive => '进行中';

  @override
  String get projectStatusOnHold => '暂停';

  @override
  String get projectStatusSomeday => '将来某天';

  @override
  String get projectStatusDone => '已完成';

  @override
  String get projectStatusDropped => '已放弃';

  @override
  String get projectChangeStatus => '更改状态';

  @override
  String get projectAwaitingTooltip => '等待中——通过等待或已安排的事项推进';

  @override
  String get projectStalledTooltip => '停滞——没有下一步行动、等待或已安排的事项';

  @override
  String get projectStalledBanner => '停滞——尚未设置下一步行动、等待或已安排的事项。添加一个下一步行动来推动它。';

  @override
  String get projectAwaitingBanner =>
      '此项目目前仅靠等待或已安排的事项推进。建议添加一个后续的下一步行动，以免这些事项完成后项目停滞。';

  @override
  String projectNextActionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个下一步行动',
    );
    return '$_temp0';
  }

  @override
  String projectWaitingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个等待中',
    );
    return '$_temp0';
  }

  @override
  String engageHiddenByFilters(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '有 $count 个下一步行动被筛选条件隐藏',
    );
    return '$_temp0';
  }

  @override
  String get filterReset => '重置';

  @override
  String onboardingSeedExisting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '你已有 $count 个项目。',
    );
    return '$_temp0';
  }

  @override
  String get purchaseErrUnavailable => '目前无法购买。';

  @override
  String get purchaseErrProducts => '无法加载商品。请检查网络连接后重试。';

  @override
  String get purchaseErrOption => '该选项目前不可用。';

  @override
  String get purchaseErrNetwork => '网络错误。请检查网络连接后重试。';

  @override
  String get purchaseErrNotAllowed => '此设备不允许购买。';

  @override
  String get purchaseErrPending => '你的购买正在等待批准。';

  @override
  String get purchaseErrAlreadyOwned => '你已拥有此项目——请尝试“恢复购买”。';

  @override
  String get purchaseErrStore => '应用商店出现问题。请稍后再试。';

  @override
  String get purchaseErrUnknown => '购买时出了点问题。请重试。';

  @override
  String get backupErrEmpty => '备份为空，没有可导入的内容。';

  @override
  String get backupErrInvalidJson =>
      '这不是有效的 JSON。请确认所选的是完整且未经编辑的 Trayzero 备份文件。';

  @override
  String get backupErrNotBackup => '此文件不是 Trayzero 备份。';

  @override
  String get backupErrNewerVersion => '此备份由更新版本的应用创建。请更新 Trayzero 后重新导入。';

  @override
  String get backupErrUnrecognized => '此文件看起来不是 Trayzero 备份。';

  @override
  String get backupErrInvalidData => '此备份包含无效数据，无法导入。';

  @override
  String get backupErrReminders => '数据已恢复，但部分提醒未能刷新。请重新导入以刷新它们。';

  @override
  String get backupErrRestoreFailed => '恢复时出了点问题。此次尝试没有更改你现有的数据。';

  @override
  String backupCountItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个事项',
    );
    return '$_temp0';
  }

  @override
  String backupCountProjects(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个项目',
    );
    return '$_temp0';
  }

  @override
  String backupCountContexts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个情境',
    );
    return '$_temp0';
  }

  @override
  String backupCountAreas(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个领域',
    );
    return '$_temp0';
  }

  @override
  String backupCountAttachments(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个附件',
    );
    return '$_temp0';
  }

  @override
  String backupCountReviews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 次回顾',
    );
    return '$_temp0';
  }

  @override
  String get restoreFolderTitle => '从备份文件夹恢复';

  @override
  String get restoreFolderIntro =>
      '选择 Trayzero 保存备份的文件夹，例如由 iCloud Drive、Google Drive 或 Syncthing 管理的文件夹。恢复会把备份合并到这台设备，不会删除已有内容。';

  @override
  String get restoreFolderChoose => '选择备份文件夹';

  @override
  String get restoreFolderChange => '选择其他文件夹';

  @override
  String restoreFolderFrom(String name) {
    return '文件夹：$name';
  }

  @override
  String get restoreFolderEmpty => '此文件夹中没有找到 Trayzero 备份。';

  @override
  String get restoreFolderFailed => '无法打开此文件夹。请确认它仍然可用，或重新选择。';

  @override
  String restoreFolderItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 项',
    );
    return '$_temp0';
  }

  @override
  String get restoreFolderUnreadable => '无法读取此文件';

  @override
  String get restoreFolderReading => '正在读取…';

  @override
  String get onboardingRestoreAction => '从其他设备迁移？恢复备份';

  @override
  String folderBackupStale(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days 天',
    );
    return '已有 $_temp0没有新的备份。';
  }

  @override
  String get folderBackupRepairHint => '如果备份已停止工作，请重新选择文件夹。';

  @override
  String moreBackupSubtitleStale(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days 天',
    );
    return '已有 $_temp0没有新的备份 · 点按修复';
  }

  @override
  String get backupPromptTitle => '自动备份你的任务';

  @override
  String get backupPromptBody =>
      '你已经记录了不少内容。在你自己的云盘或同步应用中选一个文件夹，Trayzero 会在那里保留最近 10 份备份。这是备份，不是同步。';

  @override
  String get backupPromptAction => '选择文件夹';

  @override
  String get backupPromptDismiss => '不用了';

  @override
  String backupCardHealthy(String date) {
    return '已于 $date 备份';
  }

  @override
  String get backupCardOffBody => '开启后，每次更改都会将副本保存到文件夹。';

  @override
  String get backupCardTurnOn => '开启';

  @override
  String get backupCardChooseAgain => '重新选择文件夹';

  @override
  String get backupCardTryAgain => '重试';

  @override
  String get backupGroupBackUp => '备份';

  @override
  String get backupGroupRestore => '恢复';

  @override
  String get backupAutoTitle => '自动备份';

  @override
  String get backupAutoSubtitle => '每次更改后';

  @override
  String get backupFolderTitle => '备份文件夹';

  @override
  String get backupExportTitle => '导出副本';

  @override
  String get backupExportSubtitle => '一次性分享备份文件';

  @override
  String get backupRestoreTitle => '恢复备份';

  @override
  String get backupRestoreRowSubtitle => '从文件夹或文件';

  @override
  String get backupRestoreSheetBody => '选择备份所在位置。在任何内容更改之前，你可以先查看其中的内容。';

  @override
  String get backupRestoreFromFolder => '从备份文件夹';

  @override
  String get backupRestoreFromFolderHint => '推荐 — 选择已保存的备份';

  @override
  String get backupRestoreFromFile => '从文件';

  @override
  String get backupRestoreFromFileHint => 'Trayzero 备份（.json）';

  @override
  String get backupRestorePaste => '粘贴备份文本';

  @override
  String get backupFootnote => '这是备份，不是同步 — 由你的云盘或同步应用在设备间传递该文件夹。';

  @override
  String get backupCardJustNow => '刚刚已备份';

  @override
  String backupCardMinutesAgo(int minutes) {
    return '$minutes 分钟前已备份';
  }

  @override
  String backupCardHoursAgo(int hours) {
    return '$hours 小时前已备份';
  }

  @override
  String get backupCardYesterday => '昨天已备份';

  @override
  String get backupHowItWorks => '工作原理';

  @override
  String get backupHowTitle => '备份如何工作';

  @override
  String get backupHowSaves =>
      '每次更改后，Trayzero 会把数据的 JSON 副本保存到你选择的文件夹，并保留最近的 10 份。';

  @override
  String get backupHowSync =>
      '你的云盘或同步应用（例如 iCloud Drive、Google 云端硬盘或 Syncthing）会把该文件夹带到你的其他设备。Trayzero 本身不会上传或同步任何内容。';

  @override
  String get backupHowMove => '要迁移到另一台设备，请选择“恢复备份”，然后选择“从备份文件夹”。';

  @override
  String get microphoneAccessDenied => '麦克风权限已关闭。请在设置中允许，以录制语音备忘。';

  @override
  String get filterTimeEnergy => '时间和精力';

  @override
  String get clearDate => '清除日期';

  @override
  String get reorderHandle => '拖动以重新排序';

  @override
  String get calendarConnectionTitle => '日历连接';

  @override
  String get calendarTogether => '让计划汇聚一处。';

  @override
  String get calendarConnectionIntro => '将 Trayzero 中的日程与当天的其他安排一起查看。';

  @override
  String get calendarConnect => '连接日历';

  @override
  String get calendarScope =>
      '仅发布 Trayzero“日历”中已安排日期的事项。普通任务截止日期保留在 Trayzero 中。';

  @override
  String get calendarAutomatic => '自动更新';

  @override
  String get calendarAutomaticHelp => '使用 Trayzero 时及重新打开应用时更新。';

  @override
  String get calendarPaused => '已暂停';

  @override
  String get calendarConnected => '已连接';

  @override
  String get calendarNeedsAttention => '需要处理';

  @override
  String get calendarPauseHelp => '现有日历事件保持不变。更改将等待你恢复更新或选择“立即更新”。';

  @override
  String calendarLinkedCount(int count) {
    return '$count 个已关联事件';
  }

  @override
  String calendarLastUpdated(String when) {
    return '上次更新：$when';
  }

  @override
  String get calendarChangesWaiting => '有更改等待更新';

  @override
  String get calendarUpdateNow => '立即更新';

  @override
  String get calendarManage => '管理连接';

  @override
  String get calendarWorking => '正在更新日历连接…';

  @override
  String get calendarRestoreAccess => '恢复访问权限';

  @override
  String get calendarUpdateFailed => '部分更改未能应用。上方显示上次成功更新的时间。请重试以完成更新。';

  @override
  String get calendarRemovalPending => '等待移除';

  @override
  String calendarRemoveFailed(int count) {
    return '$count 个事件未能移除。自动更新已停止。请重试移除，或断开连接并保留剩余事件。';
  }

  @override
  String get calendarSaveFailed => '未能保存此更改。请检查连接设置后重试。';

  @override
  String get calendarNoWritable => '没有可写入的日历。请在设备的日历设置中添加日历后重试。';

  @override
  String get calendarChangeDestination => '更改目标日历';

  @override
  String get calendarChooseDestination => '选择日历';

  @override
  String get calendarMoveHelp => '已关联事件将移至新日历。其他日历事件保持原位。自动更新将保留当前设置。';

  @override
  String calendarSetupCount(int count) {
    return '将发布 $count 个已安排事项。如有可用的既有事件关联，将予以复用。';
  }

  @override
  String get calendarMoveEvents => '移动已关联事件';

  @override
  String get calendarConnectAndAdd => '连接并添加事件';

  @override
  String get calendarDisconnect => '断开日历连接';

  @override
  String get calendarDisconnectQuestion => '断开日历连接？';

  @override
  String get calendarDisconnectHelp => '选择如何处理已关联的日历事件。Trayzero 事项和其他日历事件将保留。';

  @override
  String get calendarKeepEvents => '在日历中保留事件';

  @override
  String get calendarKeepHelp => '停止更新并保留事件。重新连接时可复用这些关联。';

  @override
  String calendarRemoveEvents(int count) {
    return '移除 $count 个已关联事件';
  }

  @override
  String get calendarRemoveHelp => '仅移除此连接关联的事件。移除失败的事件仍可重试。';

  @override
  String get calendarHowItWorks => '已关联事件如何工作';

  @override
  String get calendarRules =>
      'Trayzero 将已安排的“日历”事项发布到所选设备日历。普通任务截止日期不包括在内。\n\n请在 Trayzero 中编辑标题、备注、时间和重复规则。更新可能覆盖你在日历应用中的编辑。事件目前使用一小时的时长。\n\n完成、移至废纸篓或移出“日历”的事项，其关联事件将在下次更新时移除。重复系列会推进至下一次。\n\n暂停会保留事件及关联。断开连接时可选择保留或移除关联事件。断开连接不会删除 Trayzero 事项。';

  @override
  String get calendarBringEvents => '将事件导入 Trayzero';

  @override
  String get calendarImportCopies => '选择事件复制到收集箱或日历。副本不会跟随原始事件的后续更改。原始事件保持不变。';

  @override
  String get calendarChooseEvents => '选择事件';

  @override
  String get calendarImportSource => '选择来源日历';

  @override
  String get calendarImportDestination => '将所选事件添加到';

  @override
  String calendarAddSelected(int count) {
    return '添加 $count 个事件';
  }

  @override
  String get calendarNoImportEvents =>
      '没有可导入的新事件。已添加或已关联到 Trayzero 的事件不会显示。范围为过去 7 天及未来一年。';

  @override
  String get calendarImportFailed => '未能导入日历事件。请检查日历访问权限后重试。';

  @override
  String get calendarDeviceHelp =>
      '使用设备的日历，无需 Trayzero 账号。共享日历中的事件可能对有访问权限的其他人可见。';
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant() : super('zh_Hant');

  @override
  String get appName => 'Trayzero';

  @override
  String get cancel => '取消';

  @override
  String get save => '儲存';

  @override
  String get delete => '刪除';

  @override
  String get add => '新增';

  @override
  String get ok => '確定';

  @override
  String get next => '下一步';

  @override
  String get back => '返回';

  @override
  String get skip => '跳過';

  @override
  String get done => '完成';

  @override
  String get undo => '復原';

  @override
  String get retry => '重試';

  @override
  String get settings => '設定';

  @override
  String get enable => '啟用';

  @override
  String get none => '無';

  @override
  String get notSet => '未設定';

  @override
  String get search => '搜尋';

  @override
  String get select => '選擇';

  @override
  String get selectAll => '全選';

  @override
  String get selectNone => '取消全選';

  @override
  String get inbox => '收件匣';

  @override
  String get projects => '專案';

  @override
  String get review => '回顧';

  @override
  String get more => '更多';

  @override
  String get navInbox => '收件匣';

  @override
  String get navDo => '執行';

  @override
  String get navProjects => '專案';

  @override
  String get navReview => '回顧';

  @override
  String get navMore => '更多';

  @override
  String get capture => '收集';

  @override
  String get clarify => '釐清';

  @override
  String get organize => '整理';

  @override
  String get reflect => '回顧';

  @override
  String get engage => '執行';

  @override
  String get nextAction => '下一步行動';

  @override
  String get waitingFor => '等待中';

  @override
  String get someday => '將來';

  @override
  String get somedayMaybe => '將來 / 也許';

  @override
  String get reference => '參考資料';

  @override
  String get calendar => '行事曆';

  @override
  String get project => '專案';

  @override
  String get completed => '已完成';

  @override
  String get scheduled => '已排程';

  @override
  String get needsClarifying => '待釐清';

  @override
  String get howGtdWorks => 'GTD 如何運作';

  @override
  String get whatIsGtd => '什麼是 GTD？';

  @override
  String get onboardingPage1Title => '把它從腦袋裡清出來';

  @override
  String get onboardingPage1Body =>
      '任何讓你分心的事情——一件任務、一個點子、一份擔憂——都先放進收件匣。目的是騰空腦袋，不是急著整理。';

  @override
  String get onboardingPage2Title => '一次釐清一件事';

  @override
  String get onboardingPage2Body =>
      '處理流程會帶你按 GTD 決策樹逐項釐清：可執行嗎？兩分鐘內能搞定？要委派？是專案？還是下一步行動？';

  @override
  String get onboardingPage3Title => '有時間就去執行';

  @override
  String get onboardingPage3Body => '「執行」標籤會按情境、精力和可用時間篩選下一步行動，讓你隨時知道現在可以做什麼。';

  @override
  String get onboardingPage4Title => '回顧讓系統值得信賴';

  @override
  String get onboardingPage4Body => '每週回顧讓系統保持誠實。每週一次，過一遍所有清單，清空收件匣，預覽未來。';

  @override
  String get onboardingSeedTitle => '準備就緒';

  @override
  String get onboardingSeedBody =>
      '預設情境（@phone、@computer、@errands、@home、@office、@anywhere、@waiting）已經為你預先設定好。可以在「設定」裡新增或修改。';

  @override
  String get onboardingSeedSampleLabel => '新增範例專案';

  @override
  String get onboardingSeedSampleSubtitle => '新增一個入門專案和幾個事項，讓 App 不至於一片空白。';

  @override
  String get projectSectionActive => '進行中';

  @override
  String get projectSectionUnfiled => '未歸類';

  @override
  String get projectSectionOnHold => '擱置';

  @override
  String get sampleProjectTitle => '充分運用 GTD';

  @override
  String get sampleProjectOutcome => '每天把收件匣處理到零，並在每週五進行每週回顧。';

  @override
  String get sampleItemReadPrimer => '在設定中閱讀 GTD 入門介紹';

  @override
  String get sampleItemEmptyEmail => '把我的郵件收件匣清空到這裡';

  @override
  String get sampleItemScheduleReview => '安排每週五重複的每週回顧';

  @override
  String get seedContextPhone => '@phone';

  @override
  String get seedContextComputer => '@computer';

  @override
  String get seedContextErrands => '@errands';

  @override
  String get seedContextHome => '@home';

  @override
  String get seedContextOffice => '@office';

  @override
  String get seedContextAnywhere => '@anywhere';

  @override
  String get seedContextWaiting => '@waiting';

  @override
  String get onboardingFinish => '開始吧';

  @override
  String get inboxEmptyTitle => '收件匣清零';

  @override
  String get inboxEmptyMessage => '沒有需要釐清的事項。點「收集」把腦子裡的事情全倒出來——稍後再處理。';

  @override
  String get inboxEmptyAction => '去收集一些';

  @override
  String inboxItemsToClarify(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 項待釐清',
      one: '1 項待釐清',
      zero: '沒有待釐清的事項',
    );
    return '$_temp0';
  }

  @override
  String get processInbox => '處理收件匣';

  @override
  String deleteItemsConfirmTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '刪除 $count 項？',
      one: '刪除 1 項？',
    );
    return '$_temp0';
  }

  @override
  String get deleteItemsConfirmBody => '這會永久刪除事項及其附件，無法撤銷。';

  @override
  String deletedItemsSnackbar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已刪除 $count 項。',
      one: '已刪除 1 項。',
    );
    return '$_temp0';
  }

  @override
  String completedItemsSnackbar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已完成 $count 項。',
      one: '已完成 1 項。',
    );
    return '$_temp0';
  }

  @override
  String filedItemsSnackbar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已歸入專案 $count 項。',
      one: '已歸入專案 1 項。',
    );
    return '$_temp0';
  }

  @override
  String movedItemsSnackbar(int count, String destination) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已將 $count 項移至$destination。',
      one: '已將 1 項移至$destination。',
    );
    return '$_temp0';
  }

  @override
  String selectionCountTitle(int count) {
    return '已選 $count 項';
  }

  @override
  String get captureTitle => '清空大腦';

  @override
  String get captureHint => '你在想什麼？';

  @override
  String get captureNotesHint => '備註（選填）';

  @override
  String get captureEmptyError => '請輸入要收集的內容';

  @override
  String get captureSubmit => '加入收件匣';

  @override
  String get dictate => '語音輸入';

  @override
  String get stopDictation => '停止語音輸入';

  @override
  String get dictationUnavailable => '語音輸入暫不可用。你仍然可以輸入要收集的內容。';

  @override
  String get processTitle => '處理收件匣';

  @override
  String get processCompleteTitle => '收件匣清零！';

  @override
  String get processCompleteNoItems => '沒有需要釐清的事項。';

  @override
  String processCompleteStats(int filed, int doneNow, int trashed) {
    return '你歸檔了 $filed 項，2 分鐘內順手做掉 $doneNow 項，扔掉 $trashed 項。做得漂亮。';
  }

  @override
  String processStepCounter(int step, int total) {
    return '第 $step 步 / 共 $total 步';
  }

  @override
  String processItemsRemaining(int count) {
    return '剩 $count 項';
  }

  @override
  String get previousStepTooltip => '上一步';

  @override
  String get skipItemTooltip => '跳過';

  @override
  String get actionableQuestion => '需要採取行動嗎？';

  @override
  String get actionableYes => '需要——有事要做';

  @override
  String get actionableReference => '不需要——留作參考';

  @override
  String get actionableSomeday => '不需要——將來 / 也許';

  @override
  String get actionableTrash => '丟棄';

  @override
  String get twoMinQuestion => '可以在 2 分鐘內完成嗎？';

  @override
  String get twoMinYes => '能——我現在就做';

  @override
  String get delegateQuestion => '可以讓別人去做嗎？';

  @override
  String get waitingOnPromptTitle => '在等誰？';

  @override
  String get waitingOnPromptHint => '人名或系統';

  @override
  String get recurrencePrompt => '重複？';

  @override
  String get recurrenceOff => '不重複';

  @override
  String get capturedLabel => '已收集';

  @override
  String get engageTitle => '現在去做';

  @override
  String get engageEmptyTitle => '還沒有下一步行動';

  @override
  String get engageEmptyMessage => '先收集一些事項或處理收件匣，下一步行動清單就會建立起來。';

  @override
  String get engageInlineEmpty => '暫無下一步行動 — 先收集一些事項或處理收件匣。';

  @override
  String get engageOpenInbox => '打開收件匣';

  @override
  String get engageNoMatchTitle => '沒有符合的項目';

  @override
  String get hardLandscape => '行事曆';

  @override
  String get hardLandscapeSubtitle => '今日到期及逾期';

  @override
  String get filterAllContexts => '全部情境';

  @override
  String get filterAnyTime => '任意時長';

  @override
  String get filterUnder5m => '< 5 分鐘';

  @override
  String get filterUnder15m => '< 15 分鐘';

  @override
  String get filterUnder30m => '< 30 分鐘';

  @override
  String get filterUnder1h => '< 1 小時';

  @override
  String get filterAnyEnergy => '任意精力';

  @override
  String get energyLow => '低';

  @override
  String get energyMedium => '中';

  @override
  String get energyHigh => '高';

  @override
  String get projectsTitle => '專案';

  @override
  String get newProject => '新增專案';

  @override
  String get organizeLooseActionsTooltip => '整理散落的行動';

  @override
  String get projectsEmptyTitle => '還沒有專案';

  @override
  String get projectsEmptyMessage =>
      '專案是任何需要多步驟才能達成的成果。建立專案把相關的下一步行動歸到一起，朝著明確的結果穩步推進。';

  @override
  String get projectMissingNextAction => '未定義下一步行動';

  @override
  String get organizeActionsTitle => '整理行動';

  @override
  String get organizeEmptyTitle => '沒有散落的行動';

  @override
  String get organizeEmptyMessage => '每個下一步行動都已歸屬到專案。新的未歸屬行動會出現在這裡等待整理。';

  @override
  String assignToProject(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '將 $count 項歸入專案',
      one: '將 1 項歸入專案',
    );
    return '$_temp0';
  }

  @override
  String get addNextActionTitle => '新增下一步行動';

  @override
  String get addNextActionHint => '例如：把時程表郵件寄給小李';

  @override
  String get addExistingActions => '加入已有的行動';

  @override
  String get noUnassignedActionsMessage => '沒有可加入的未歸屬行動。';

  @override
  String addCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '新增 $count 項',
      one: '新增 1 項',
    );
    return '$_temp0';
  }

  @override
  String get editProject => '編輯專案';

  @override
  String get projectName => '專案名稱';

  @override
  String get projectNameHint => '例如：上線新官網';

  @override
  String get projectNameRequired => '請輸入專案名稱';

  @override
  String get areaOfFocusOptional => '職責範圍（選填）';

  @override
  String get unfiledOption => '— 未歸類 —';

  @override
  String get dueDate => '截止日期';

  @override
  String get deleteProjectConfirmTitle => '刪除專案？';

  @override
  String get deleteProjectWarning => '歸屬到此專案的事項會變成游離狀態，但不會被刪除。';

  @override
  String get addActionFab => '新增行動';

  @override
  String get projectOutcomeHint => '「完成」是什麼樣子？';

  @override
  String get outcomeSection => '成果';

  @override
  String get nextActionsSection => '下一步行動';

  @override
  String get noNextActionsMessage => '還沒有下一步行動。';

  @override
  String get statusTooltip => '狀態';

  @override
  String get reviewTitle => '回顧';

  @override
  String get weeklyReviewCardTitle => '每週回顧';

  @override
  String get weeklyReviewCardSubtitle => '過一遍收件匣、清單和專案。讓系統始終值得信賴的儀式。';

  @override
  String get calendarEmpty => '沒有與特定日期掛鉤的事項。';

  @override
  String get waitingForEmpty => '沒有委派出去的事項。';

  @override
  String get somedayEmpty => '沒有「將來 / 也許」的事項。';

  @override
  String get referenceEmpty => '沒有參考資料。';

  @override
  String get completedThisWeek => '本週已完成';

  @override
  String get completedThisWeekEmpty => '本週還沒有完成任何事項。';

  @override
  String bucketCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 項',
      one: '1 項',
    );
    return '$_temp0';
  }

  @override
  String get needsReDecision => '需要重新決定';

  @override
  String pastDueCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 項已逾期',
      one: '1 項已逾期',
    );
    return '$_temp0';
  }

  @override
  String get reviewStep1Title => '騰空腦袋';

  @override
  String get reviewStep1Body => '把所有讓你分心的事情都收集到收件匣裡，系統才值得信賴。';

  @override
  String get reviewStep2Title => '把收件匣處理到零';

  @override
  String get reviewStep2Body => '按決策樹釐清每一條收集到的事項，直到收件匣清空。';

  @override
  String get reviewStep3Title => '回顧下一步行動清單';

  @override
  String get reviewStep3Body => '把每條行動都過一遍。做完了？標記完成。過時了？修改或刪除。仍是下一步？保留。';

  @override
  String get reviewStep4Title => '回顧等待清單';

  @override
  String get reviewStep4Body => '對方有回應了嗎？要不要催一下？更新或移除。';

  @override
  String get reviewStep5Title => '回顧每一個專案';

  @override
  String get reviewStep5Body =>
      '回顧每個專案的預期成果。為停滯的專案新增下一步行動、暫停專案，或標記為完成。等待中的事項和已安排的工作也算作進展。';

  @override
  String get reviewStep6Title => '看看接下來兩週';

  @override
  String get reviewStep6Body => '查一遍行事曆事項。有什麼現在可以提前準備的嗎？';

  @override
  String get reviewStep7Title => '回顧「將來 / 也許」';

  @override
  String get reviewStep7Body => '裡面有哪些值得現在投入？把它們升級成專案或下一步行動。';

  @override
  String reviewStepCounter(int step, int total) {
    return '第 $step 步 / 共 $total 步';
  }

  @override
  String get finishReview => '完成回顧';

  @override
  String get reviewCompleteSnackbar => '每週回顧已完成';

  @override
  String get searchHint => '搜尋事項、備註';

  @override
  String get searchMinChars => '至少輸入兩個字元';

  @override
  String get clearFilters => '清除篩選';

  @override
  String get clearSearch => '清除搜尋';

  @override
  String searchNoResults(String query) {
    return '沒有符合「$query」的結果';
  }

  @override
  String get searchNoMatchTitle => '沒有符合的項目';

  @override
  String get searchNoMatchMessage => '目前篩選條件下沒有結果。試著放寬篩選或清除篩選。';

  @override
  String get filterAllProjects => '全部專案';

  @override
  String get filterCompleted => '已完成';

  @override
  String get statusInbox => '收件匣';

  @override
  String get statusNext => '下一步';

  @override
  String get statusWaiting => '等待中';

  @override
  String get statusSomeday => '將來';

  @override
  String get statusReference => '參考資料';

  @override
  String get appearanceSection => '外觀';

  @override
  String get themeLabel => '主題';

  @override
  String get themeFollowSystem => '跟隨系統';

  @override
  String get themeLight => '淺色';

  @override
  String get themeDark => '深色';

  @override
  String get hapticFeedback => '觸覺回饋';

  @override
  String get languageLabel => '語言';

  @override
  String get languageFollowSystem => '跟隨系統';

  @override
  String get contextsLabel => '情境';

  @override
  String get areasOfFocusLabel => '職責範圍';

  @override
  String get calendarSyncLabel => '行事曆同步';

  @override
  String get remindersSection => '提醒';

  @override
  String get weeklyReviewNudge => '每週回顧提醒';

  @override
  String get weeklyReviewNudgeDescription => '每週五下午 4 點輕輕提醒一下。';

  @override
  String get remindBeforeDue => '在到期前提醒我';

  @override
  String get remindBeforeDueOff => '關閉 · 僅在到期時提醒';

  @override
  String get remindBeforeDueSuffix => '僅對此後儲存的事項生效';

  @override
  String get deferSurfaceLabel => '延遲事項的提醒時間';

  @override
  String get deferSurfaceDescription => '未設具體時間的延遲事項會全天留在清單裡，並在此時段提醒';

  @override
  String get checkingNotificationStatus => '正在檢查通知狀態…';

  @override
  String exportBackupError(String error) {
    return '匯出失敗：$error';
  }

  @override
  String get weeklyBackupReminder => '每週備份提醒';

  @override
  String get weeklyBackupReminderDescription => '每週日早上提醒我匯出並儲存備份。';

  @override
  String get importConfirmTitle => '匯入這份備份？';

  @override
  String importConfirmBody(String sections) {
    return '這將新增或更新 $sections。\n\n相同 id 的現有條目會被備份中的版本覆蓋，無法撤銷。';
  }

  @override
  String get importButton => '匯入';

  @override
  String get importFromPasteTitle => '貼上備份 JSON';

  @override
  String get importFromPasteDescription => '也可以直接貼上備份文字。';

  @override
  String get pasteBackupHint => '貼上備份 JSON…';

  @override
  String get crashReports => '傳送當機報告';

  @override
  String get crashReportsDescription =>
      '透過 Sentry 傳送匿名的當機與錯誤報告。不收集任何個人資料。預設關閉。';

  @override
  String get crashReportsEnabled => '當機報告將在下次啟動時傳送';

  @override
  String get crashReportsDisabled => '已關閉當機報告';

  @override
  String get showOnboardingAgain => '重新查看引導';

  @override
  String get versionLabel => '版本';

  @override
  String get settingsFooter =>
      '本地優先。你的資料只留在這台裝置上。靈感來自 David Allen 的《搞定》（GTD）方法論。';

  @override
  String get editTitle => '編輯';

  @override
  String get saveError => '無法儲存變更，請重試。';

  @override
  String get savedIndicator => '已儲存';

  @override
  String get titleLabel => '標題';

  @override
  String get notesLabel => '備註';

  @override
  String get statusSection => '狀態';

  @override
  String get contextSection => '情境';

  @override
  String get energySection => '精力';

  @override
  String get timeEstimateSection => '預估耗時';

  @override
  String get waitingOnSection => '等待對象';

  @override
  String get waitingOnHint => '你在等誰或等什麼？';

  @override
  String get projectSection => '專案';

  @override
  String get datesSection => '日期';

  @override
  String get dueLabel => '截止';

  @override
  String get deferUntilLabel => '延遲到';

  @override
  String get repeatSection => '重複';

  @override
  String get recurrenceNeedsDeferHint => '在上方新增「延遲到」日期才能啟用重複——重複機制是把這個日期往後順延。';

  @override
  String get recurrenceNeedsDueDateHint =>
      '在上方新增截止或延遲日期才能啟用重複——重複機制是把這個日期往後順延。';

  @override
  String get recurrenceExplanation => '完成這一項後，下一個實例會按順延後的日期出現。';

  @override
  String get recurrenceNoDateNextActionError =>
      '這一項設定了重複，但沒有「延遲到」日期，完成後不會產生下一次。請在上方新增延遲日期，或把重複設為關閉。';

  @override
  String get recurrenceNoDateError =>
      '這一項設定了重複，但沒有截止或延遲日期，完成後不會產生下一次。請在上方新增日期，或把重複設為關閉。';

  @override
  String get attachmentsSection => '附件';

  @override
  String get markComplete => '標記完成';

  @override
  String get reopen => '重新打開';

  @override
  String get deleteItemConfirmTitle => '刪除該事項？';

  @override
  String get deleteItemConfirmBody => '此操作無法撤銷。';

  @override
  String get completeError => '無法完成此事項。';

  @override
  String get reopenError => '無法重新打開此事項。';

  @override
  String get remindersBlockedWarning => '系統設定中已封鎖通知——這條不會提醒你。';

  @override
  String get remindersOffWarning => '提醒已關閉——這條不會提醒你。';

  @override
  String get preciseReminderOffWarning => '精確提醒時間已關閉——短時提醒可能延遲。';

  @override
  String get allowExactAlarms => '允許精確鬧鐘';

  @override
  String get noContextsAvailable => '還沒有情境——可以在「設定」裡新增。';

  @override
  String get noActiveProjects => '還沒有進行中的專案。';

  @override
  String get attachmentPhoto => '照片';

  @override
  String get attachmentCamera => '相機';

  @override
  String get attachmentVoiceMemo => '語音備忘';

  @override
  String get attachmentStop => '停止';

  @override
  String get remove => '移除';

  @override
  String get imageViewerClose => '關閉';

  @override
  String imageViewerCounter(int current, int total) {
    return '$current / $total';
  }

  @override
  String attachmentPhotoCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 張相片',
    );
    return '$_temp0';
  }

  @override
  String attachmentAudioCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 則語音備忘',
    );
    return '$_temp0';
  }

  @override
  String attachmentFileCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 個檔案',
    );
    return '$_temp0';
  }

  @override
  String get areasTitle => '職責範圍';

  @override
  String get newArea => '新增範圍';

  @override
  String get renameArea => '重新命名範圍';

  @override
  String get areasEmptyMessage => '還沒有職責範圍。範圍是你長期負責的領域——健康、事業、家庭——用來歸納專案。';

  @override
  String get areaNameHint => '例如：健康、事業、家庭';

  @override
  String deleteAreaConfirmTitle(String name) {
    return '刪除「$name」？';
  }

  @override
  String get deleteAreaWarning => '此範圍下的專案會變成未歸類（但不會被刪除）。';

  @override
  String get contextsTitle => '情境';

  @override
  String get newContext => '新增情境';

  @override
  String get editContext => '編輯情境';

  @override
  String get contextsEmptyMessage =>
      '還沒有情境。情境用來標記行動要在哪裡或借助什麼完成（@phone、@home、@errands）。';

  @override
  String get nameLabel => '名稱';

  @override
  String get iconLabel => '圖示';

  @override
  String get colorLabel => '顏色';

  @override
  String deleteContextConfirmTitle(String name) {
    return '刪除 $name？';
  }

  @override
  String get deleteContextWarning => '使用此情境的事項會失去該情境。';

  @override
  String get calendarSyncTitle => '行事曆同步';

  @override
  String get calendarSyncIntro =>
      '把帶截止日期的事項同步到系統行事曆，並把標記「#gtd」的行事曆事件拉回 Trayzero 收件匣。';

  @override
  String get enableCalendarSync => '啟用行事曆同步';

  @override
  String get targetCalendar => '目標行事曆';

  @override
  String get calendarAccessDenied => '已拒絕存取行事曆。請授予權限才能選擇目標行事曆。';

  @override
  String get grantCalendarAccess => '授予行事曆存取權限';

  @override
  String get noCalendarsAvailable =>
      '暫時沒有可用的行事曆。如果你剛剛授權，請稍候再重試。也請確認系統「行事曆 / 帳戶」設定中你的帳戶已啟用同步。';

  @override
  String get mirrorOutAction => '把事項同步 → 行事曆';

  @override
  String get importInAction => '匯入 #gtd 事件 → 收件匣';

  @override
  String mirrorOutSuccess(int written) {
    return '已同步 $written 項到行事曆';
  }

  @override
  String mirrorOutSuccessWithStale(int written, int removed) {
    return '已同步 $written 項到行事曆，清理了 $removed 筆過期資料';
  }

  @override
  String importInSuccess(int count) {
    return '已匯入 $count 筆行事曆事件';
  }

  @override
  String get mirroringProgress => '正在同步…';

  @override
  String get importingProgress => '正在匯入…';

  @override
  String get calendarSyncTip =>
      '小提示：在行事曆事件標題的任意位置輸入「#gtd」，下次同步時它就會出現在你的 Trayzero 收件匣裡。';

  @override
  String get gtdDiagramTitle => 'GTD 如何運作';

  @override
  String get gtdDiagramSubtitle => '用五步把所有未了之事從腦袋裡搬到一個值得信賴的系統裡。點擊高亮的清單可以直接跳轉。';

  @override
  String get gtdAttribution => '方法源自 David Allen · gettingthingsdone.com';

  @override
  String get youAreHere => '你在這裡';

  @override
  String get gtdStage1Body => '把所有讓你分心的事情——任務、點子、擔憂——都扔進收件匣。先不篩選，也不整理。';

  @override
  String get gtdStage2Body => '一次拿一件，決定它是什麼。處理流程會帶你走完這棵決策樹：';

  @override
  String get gtdStage3Body => '結果會落到正確的清單上，從此不再裝在腦袋裡。';

  @override
  String get gtdStage3Footnote => '等待 / 行事曆 / 將來 / 參考資料都在「回顧」下。';

  @override
  String get gtdStage4Body => '定期回顧你的清單——尤其是每週回顧——讓系統始終值得信賴。';

  @override
  String get gtdStage5Body => '放心去做——按情境、時間、精力和優先順序挑選行動，心無旁騖。';

  @override
  String get decisionNotActionableQ => '不可執行？';

  @override
  String get decisionNotActionableA => '丟棄、將來 / 也許，或參考資料';

  @override
  String get decisionTwoMinQ => '2 分鐘內能搞定？';

  @override
  String get decisionTwoMinA => '現在就做';

  @override
  String get decisionDelegateQ => '該讓別人做？';

  @override
  String get decisionDelegateA => '委派 → 等待中';

  @override
  String get decisionMultiStepQ => '需要多個步驟？';

  @override
  String get decisionMultiStepA => '變成一個專案';

  @override
  String get decisionOtherwiseQ => '其他情況';

  @override
  String get decisionOtherwiseA => '定義最具體的下一步行動';

  @override
  String get supportTitle => '支持 Trayzero';

  @override
  String get supportIntro =>
      'Trayzero 完全免費，所有功能都已解鎖。如果它幫到了你，你可以略表心意——這有助於讓應用程式保持獨立、無廣告。';

  @override
  String get supportUnavailable => '支持選項暫時無法使用。';

  @override
  String get supportTipHeader => '打賞一下';

  @override
  String get supportTipSmall => '小額打賞';

  @override
  String get supportTipLarge => '大額打賞';

  @override
  String get supportSupporterYearly => '支持者 — 按年';

  @override
  String supportSupporterYearlySubtitle(String price) {
    return '$price / 年 · 最划算 · 支持開發';
  }

  @override
  String get supportSupporterMonthly => '支持者 — 按月';

  @override
  String supportSupporterMonthlySubtitle(String price) {
    return '$price / 月 · 隨時取消';
  }

  @override
  String supportOpeningStore(String store) {
    return '正在開啟$store…';
  }

  @override
  String get supportRestoring => '正在回復購買…';

  @override
  String get supportRestore => '恢復購買';

  @override
  String get supportRestoreSubtitle => '已經是支持者了？在此裝置上恢復。';

  @override
  String get supportAutoRenewNote => '訂閱會自動續期，直到你在「設定」中取消。';

  @override
  String get legalPrivacyPolicy => '隱私政策';

  @override
  String get legalTermsOfUse => '使用條款';

  @override
  String get supportThanksTip => '非常感謝！💙';

  @override
  String get supportThanksSupporter => '你現在是支持者了——謝謝你！💙';

  @override
  String get supportRestored => '購買已恢復。歡迎回來！💙';

  @override
  String get supportRestoreNone => '找不到以往的購買紀錄。';

  @override
  String get supportBadgeYearly => '支持者 · 按年';

  @override
  String get supportBadgeMonthly => '支持者 · 按月';

  @override
  String get supportBadgeGeneric => '支持者';

  @override
  String get supportBadgeSubtitle => '感謝你讓 Trayzero 保持獨立。';

  @override
  String get calendarLookupFailed => '無法載入裝置行事曆。請在系統行事曆應用程式中檢查帳戶同步，然後返回重試。';

  @override
  String get calendarPermissionHelp => '如果沒有出現權限提示，請在應用程式設定中允許存取行事曆，然後返回此處。';

  @override
  String get calendarOpenSettings => '開啟應用程式設定';

  @override
  String get calendarSettingsFailed =>
      '無法開啟應用程式設定。請在裝置設定中找到 Trayzero 並允許存取行事曆。';

  @override
  String get calendarSelectionUnavailable => '先前選擇的行事曆已無法使用。請選擇其他行事曆。';

  @override
  String get appIcon => '應用程式圖示';

  @override
  String get appIconAndroidDescription =>
      '主畫面圖示可獨立於應用程式顏色選擇。啟動器可能需要片刻才能更新，也可能套用自己的色調。';

  @override
  String get appIconDescription =>
      '圖示可獨立於應用程式顏色選擇。裝置可能套用自己的色調。iOS 會在圖示變更時顯示確認提示。';

  @override
  String get appIconChangeFailed => '無法變更應用程式圖示。請在 Trayzero 開啟時重試。';

  @override
  String get appColor => '應用程式顏色';

  @override
  String get appColorDescription => '適用於淺色和深色模式。GTD 清單顏色的含義保持不變。';

  @override
  String get paletteAmber => 'Trayzero 琥珀色 — 預設';

  @override
  String get paletteBlue => '藍色';

  @override
  String get paletteCyan => '青藍色';

  @override
  String get paletteTeal => '青色';

  @override
  String get paletteGreen => '綠色';

  @override
  String get paletteViolet => '紫色';

  @override
  String get paletteRose => '玫瑰色';

  @override
  String get appIconNotificationNote =>
      'Android 通知在排程提醒時使用所選應用程式圖示的顏色。現有通知會在重新排程時更新。部分裝置可能顯示原始應用程式圖示。';

  @override
  String get appearanceSaveFailed => '無法儲存外觀設定，已還原之前的設定。';

  @override
  String mirrorOutPendingCleanup(int count) {
    return '還有 $count 個行事曆事件需要清理。請再次同步以重試。';
  }

  @override
  String get weeklyReviewResume => '繼續每週回顧';

  @override
  String get weeklyReviewProgressSaved => '離開頁面後，回顧進度仍會保留。';

  @override
  String get weeklyReviewSaveError => '無法儲存回顧進度，請重試。';

  @override
  String get weeklyReviewActionError => '無法儲存此項變更，請重試。';

  @override
  String get weeklyReviewListEmpty => '這裡沒有需要回顧的事項。';

  @override
  String get weeklyReviewProjectAwaiting => '等待中或已安排的事項正在推動此專案。';

  @override
  String get weeklyReviewProjectMoving => '已確定下一步行動';

  @override
  String get weeklyReviewOpenProject => '開啟專案';

  @override
  String get processTwoMinNo => '否 — 繼續釐清';

  @override
  String get twoMinRule => '兩分鐘法則：如果完成比記錄更省時，就馬上做。';

  @override
  String get delegateYes => '是 — 委派給他人並等待回覆';

  @override
  String get delegateNo => '否 — 由我來做';

  @override
  String get singleStepQuestion => '這是一個具體的單步行動嗎？';

  @override
  String get singleStepYes => '是 — 一個下一步行動';

  @override
  String get singleStepProject => '否 — 這是一個專案';

  @override
  String get projectRule => '專案是需要多個行動步驟、並能在一年內完成的成果。';

  @override
  String get deferQuestion => '有指定的日期或時間嗎？';

  @override
  String get deferAsap => '否 — 儘快完成';

  @override
  String get deferCalendar => '是 — 放入行事曆';

  @override
  String get deferChooseDate => '延後到指定日期';

  @override
  String get processDetailsTitle => '新增詳細資料';

  @override
  String get processFileNextAction => '儲存為下一步行動';

  @override
  String minutesShort(int minutes) {
    return '$minutes 分鐘';
  }

  @override
  String deferredUntilSummary(String date) {
    return '延後到 $date';
  }

  @override
  String deferredRepeatingSummary(String date, String recurrence) {
    return '延後到 $date · 重複：$recurrence';
  }

  @override
  String get recurrenceDaily => '每天';

  @override
  String get recurrenceWeekly => '每週';

  @override
  String get recurrenceMonthly => '每月';

  @override
  String get recurrenceYearly => '每年';

  @override
  String get createProject => '建立';

  @override
  String get projectPickerTitle => '移入專案';

  @override
  String get projectMoved => '已移入專案。';

  @override
  String get projectDetached => '已從專案移除。';

  @override
  String get noProject => '無專案';

  @override
  String get decreaseRepeatInterval => '縮短重複間隔';

  @override
  String get increaseRepeatInterval => '延長重複間隔';

  @override
  String get decreaseRepeatCount => '減少重複次數';

  @override
  String get increaseRepeatCount => '增加重複次數';

  @override
  String get repeatOn => '重複星期';

  @override
  String get repeatMonthlyOn => '重複日期';

  @override
  String get repeatDayOfMonth => '按日期';

  @override
  String get repeatDayOfWeek => '按星期';

  @override
  String get repeatFirst => '第一個';

  @override
  String get repeatSecond => '第二個';

  @override
  String get repeatThird => '第三個';

  @override
  String get repeatFourth => '第四個';

  @override
  String get repeatFifth => '第五個';

  @override
  String get repeatLast => '最後一個';

  @override
  String get repeatEnds => '結束條件';

  @override
  String get repeatNever => '永不結束';

  @override
  String get repeatOnDate => '指定日期';

  @override
  String get repeatAfterCount => '指定次數';

  @override
  String get weekdayListSeparator => '、';

  @override
  String get dueToday => '今天到期';

  @override
  String get reschedule => '重新安排';

  @override
  String get complete => '完成';

  @override
  String get drop => '放棄';

  @override
  String get trash => '垃圾桶';

  @override
  String itemEnergyLabel(String energy) {
    return '精力：$energy';
  }

  @override
  String waitingOnPerson(String person) {
    return '等待 $person';
  }

  @override
  String dueOverdueDays(int days) {
    return '已逾期 · $days 天';
  }

  @override
  String dueTodayAt(String time) {
    return '今天到期，$time';
  }

  @override
  String selectItem(String title) {
    return '選取 $title';
  }

  @override
  String markItemDone(String title) {
    return '將 $title 標記為完成';
  }

  @override
  String repeatLastOnDate(String date) {
    return '最後一次：$date';
  }

  @override
  String repeatAfterOccurrences(int count) {
    return '重複 $count 次後結束';
  }

  @override
  String recurrenceUntilSummary(String pattern, String date) {
    return '$pattern · 截至 $date';
  }

  @override
  String recurrenceCountSummary(String pattern, int count) {
    return '$pattern · 共 $count 次';
  }

  @override
  String recurrenceOnWeekdays(String cadence, String weekdays) {
    return '$cadence的$weekdays';
  }

  @override
  String recurrenceOnNthWeekday(
    String cadence,
    String ordinal,
    String weekday,
  ) {
    String _temp0 = intl.Intl.selectLogic(ordinal, {
      'first': '第一個',
      'second': '第二個',
      'third': '第三個',
      'fourth': '第四個',
      'fifth': '第五個',
      'other': '最後一個',
    });
    return '$cadence的$_temp0$weekday';
  }

  @override
  String repeatEveryDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '每 $count 天',
      one: '每天',
    );
    return '$_temp0';
  }

  @override
  String repeatEveryWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '每 $count 週',
      one: '每週',
    );
    return '$_temp0';
  }

  @override
  String repeatEveryMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '每 $count 個月',
      one: '每月',
    );
    return '$_temp0';
  }

  @override
  String repeatEveryYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '每 $count 年',
      one: '每年',
    );
    return '$_temp0';
  }

  @override
  String get captureAddContinue => '新增並繼續';

  @override
  String captureAddedCount(int count) {
    return '已新增 $count 項到收件匣';
  }

  @override
  String get folderBackupChoose => '選擇備份資料夾';

  @override
  String get folderBackupSaving => '正在備份…';

  @override
  String get folderBackupOff => '自動備份已關閉。';

  @override
  String get folderBackupNever => '尚無成功的備份。';

  @override
  String folderBackupLastSuccess(String date) {
    return '上次備份：$date';
  }

  @override
  String get folderBackupFailed => '備份失敗。請檢查資料夾存取權限及可用空間，然後重試。';

  @override
  String get folderBackupHistoryWarning => '備份已儲存，但無法刪除較舊的備份。';

  @override
  String get folderBackupNow => '立即備份';

  @override
  String get doViewToday => '今天';

  @override
  String get doViewNextActions => '下一步行動';

  @override
  String get todayPlanCardTitle => '規劃今天';

  @override
  String get todayPlanCardBody => '選出今天要專注的事情，大約只需兩分鐘。';

  @override
  String get todayPlanAction => '規劃今天';

  @override
  String todayCarryOverLine(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '有 $count 項之前的事項需要決定',
    );
    return '$_temp0';
  }

  @override
  String get todayFocusHeader => '專注';

  @override
  String todayDoneCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '今天已完成 $count 項',
    );
    return '$_temp0';
  }

  @override
  String get todayEmptyTitle => '還沒有專注事項';

  @override
  String get todayEmptyMessage => '為下一步行動加星號，承諾今天完成，或者規劃今天。';

  @override
  String get focusAddTooltip => '加入今天';

  @override
  String get focusRemoveTooltip => '從今天移除';

  @override
  String focusAddItem(String title) {
    return '將「$title」加入今天';
  }

  @override
  String focusRemoveItem(String title) {
    return '將「$title」從今天移除';
  }

  @override
  String get focusError => '無法更新今天，請重試。';

  @override
  String get planTodayIntro => '為今天要做的事加星號。保持簡短，其他事項仍留在你的清單中。';

  @override
  String get planSectionCarryOver => '之前的';

  @override
  String get planCarryOverHint => '開始今天後，未保留的事項會回到各自的清單。';

  @override
  String get planKeepAll => '全部保留';

  @override
  String get planSectionCalendar => '行事曆';

  @override
  String get planOnToday => '已在今日';

  @override
  String get planSectionWaiting => '需要跟進的等待事項';

  @override
  String get planSectionAvailable => '今天起可做';

  @override
  String get planEmpty => '暫時沒有可規劃的事項。處理收件匣以建立下一步行動。';

  @override
  String planFocusedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '今天專注 $count 項',
      zero: '還沒有專注事項',
    );
    return '$_temp0';
  }

  @override
  String get planStartDay => '開始今天';

  @override
  String get planDoneSnackbar => '今天已規劃好';

  @override
  String planClearedSnackbar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已規劃 · $count 項已回到清單',
    );
    return '$_temp0';
  }

  @override
  String get planSaveError => '無法儲存計畫，請重試。';

  @override
  String get captureTipDates => '提示：可加入 @情境、#專案、+標籤，或英文日期如「tomorrow」。';

  @override
  String get captureTipSigils => '提示：可加入 @情境、#專案 或 +標籤。';

  @override
  String startsOnDate(String date) {
    return '開始於 $date';
  }

  @override
  String dueOnDate(String date) {
    return '截止 $date';
  }

  @override
  String captureChipProject(String name) {
    return '專案：$name';
  }

  @override
  String get captureKeepAsText => '保留為文字';

  @override
  String get captureRecognized => '辨識出的詳情';

  @override
  String deferUseStartDate(String date) {
    return '於 $date 開始';
  }

  @override
  String deferUseDueDate(String date) {
    return '排入行事曆 $date';
  }

  @override
  String weeklyReviewProjectInactive(int days) {
    return '$days 天以上無進展';
  }

  @override
  String get weeklyReviewMarkReviewed => '標記為已回顧';

  @override
  String get weeklyReviewReviewed => '已回顧';

  @override
  String weeklyReviewLastReviewed(String date) {
    return '上次回顧 $date';
  }

  @override
  String get weeklyReviewNeverReviewed => '尚未回顧';

  @override
  String weeklyReviewReviewedProgress(int done, int total) {
    return '已回顧 $done/$total';
  }

  @override
  String get importFromApp => '從其他 App 匯入';

  @override
  String get importSourcePlainText => '純文字 / TaskPaper';

  @override
  String get importHintTodoist => '專案選單 › 匯出為範本 › CSV，或在 設定 › 備份 中下載 ZIP。';

  @override
  String get importHintTickTick =>
      '在 TickTick 網站上：設定 › 帳號 › 備份與匯入 › 產生備份（CSV）。';

  @override
  String get importHintNirvana => '在 Nirvana 網頁版中將資料匯出為 CSV 或 JSON。';

  @override
  String get importHintOmniFocus => '選取專案，然後 編輯 › 拷貝為 TaskPaper。貼到這裡或存成檔案。';

  @override
  String get importHintPlainText =>
      'Things：拷貝待辦事項並貼到這裡，每行一個任務。僅支援基本文字匯入，不支援 Things 資料庫匯出檔案。';

  @override
  String get importChooseFile => '選擇檔案';

  @override
  String get importPasteText => '貼上文字';

  @override
  String get importPasteTitle => '貼上任務';

  @override
  String get importPasteHint => '每行一個任務。在以「:」結尾的行下縮排即可組成專案。';

  @override
  String get importPasteContinue => '預覽';

  @override
  String get importPreviewNothingYet => '目前尚未新增任何內容。';

  @override
  String get importPreviewProjects => '專案';

  @override
  String get importProjectNew => '新建';

  @override
  String get importProjectExisting => '加入既有專案';

  @override
  String importProjectActions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 個行動',
    );
    return '$_temp0';
  }

  @override
  String importContextsNew(String names) {
    return '新建：$names';
  }

  @override
  String importContextsExisting(String names) {
    return '已有：$names';
  }

  @override
  String get importGoodToKnow => '須知';

  @override
  String importWarnCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '略過 $count 個已完成或已放棄的任務',
    );
    return '$_temp0';
  }

  @override
  String importWarnCalendar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 個有截止日期的行動放入行事曆',
    );
    return '$_temp0';
  }

  @override
  String importWarnDates(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 個無法辨識的日期保留在備註中',
    );
    return '$_temp0';
  }

  @override
  String importWarnRepeats(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 條重複規則保留在備註中',
    );
    return '$_temp0';
  }

  @override
  String importWarnSubtasks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 個子任務變為獨立行動',
    );
    return '$_temp0';
  }

  @override
  String importWarnSections(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 個任務在備註中記下所屬分組',
    );
    return '$_temp0';
  }

  @override
  String importWarnNotImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 個任務的優先順序、旗標或負責人不會匯入',
    );
    return '$_temp0';
  }

  @override
  String importWarnUnreadable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '略過 $count 列無標題的記錄',
    );
    return '$_temp0';
  }

  @override
  String importDoneTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已新增 $count 個任務',
    );
    return '$_temp0';
  }

  @override
  String get importDoneBody => '改變主意了？復原只會移除這次匯入新增的內容，不影響其他。';

  @override
  String get importUndo => '復原匯入';

  @override
  String get importFinish => '完成';

  @override
  String get importUndoneTitle => '已復原匯入';

  @override
  String get importUndoneBody => '這次匯入新增的所有內容都已移除。';

  @override
  String get importRemindersFailed => '部分提醒暫時無法設定，將在下次開啟 App 時設定。';

  @override
  String importErrorUnrecognized(String source) {
    return '這看起來不是 $source 的匯出檔案。請檢查步驟後重試。';
  }

  @override
  String get importErrorNoTasks => '沒有可匯入的未完成任務。';

  @override
  String get importErrorUnreadable => '無法讀取此檔案。請選擇文字、CSV 或 ZIP 匯出檔案。';

  @override
  String get importErrorWrite => '匯入失敗，未新增任何內容。';

  @override
  String get importErrorUndo => '無法復原匯入，請重試。';

  @override
  String get tagsAndPeopleLabel => '標籤和人員';

  @override
  String get tagsEmptyMessage =>
      '標籤可跨清單標記事項。把標籤設為人員，就能為對方保留一份要討論事項的議程。提示：記錄時輸入 +標籤。';

  @override
  String get newTag => '新增標籤';

  @override
  String get editTag => '編輯標籤';

  @override
  String get tagPersonSwitch => '人員';

  @override
  String get tagPersonSwitchHint => '保留一份要討論事項的議程';

  @override
  String tagOpenItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 個未完成事項',
      zero: '沒有未完成事項',
    );
    return '$_temp0';
  }

  @override
  String deleteTagConfirmTitle(String name) {
    return '刪除「$name」？';
  }

  @override
  String deleteTagConfirmBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 個未完成事項使用它。事項會保留，只移除標籤。',
      zero: '沒有未完成事項使用它。',
    );
    return '$_temp0';
  }

  @override
  String get tagMergeTitle => '合併標籤？';

  @override
  String tagMergeBody(String source, String target) {
    return '「$target」已存在。要將「$source」合併進去嗎？';
  }

  @override
  String get tagMergeAction => '合併';

  @override
  String get addTag => '新增標籤';

  @override
  String get tagPickerHint => '搜尋或建立標籤';

  @override
  String tagCreate(String name) {
    return '建立「$name」';
  }

  @override
  String tagCreatePerson(String name) {
    return '建立人員「$name」';
  }

  @override
  String get tagsSection => '標籤';

  @override
  String tagChipSemantics(String name) {
    return '標籤：$name';
  }

  @override
  String personChipSemantics(String name) {
    return '人員：$name';
  }

  @override
  String removeTagTooltip(String name) {
    return '移除 $name';
  }

  @override
  String moreTags(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '另外 $count 個標籤',
    );
    return '$_temp0';
  }

  @override
  String get filterTag => '標籤';

  @override
  String get filterAnyTag => '任意標籤';

  @override
  String get agendasTitle => '議程';

  @override
  String agendasPeopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 人',
    );
    return '$_temp0';
  }

  @override
  String agendaAddHint(String name) {
    return '新增要與 $name 討論的事';
  }

  @override
  String get agendaAddTooltip => '加入議程';

  @override
  String agendaEmpty(String name) {
    return '暫時沒有要與 $name 討論的事。';
  }

  @override
  String get agendaNotFound => '此人員已不存在。';

  @override
  String captureChipNewTag(String name) {
    return '新標籤：$name';
  }

  @override
  String get importHintGoogleTasks =>
      'Google Takeout › 選取 Tasks › 匯出 JSON。解壓縮下載檔案並選擇 Tasks.json。清單名稱保留在備註中，已完成任務進入「已完成」。';

  @override
  String get importDuplicateWarning =>
      '此裝置之前已匯入過完全相同的資料。再次匯入會新增重複任務。如果不需要另一份副本，請取消。';

  @override
  String get importHintThings =>
      '選擇 main.sqlite 或 Things 3 匯出資料庫資料夾的 ZIP。iPhone/iPad：設定 › 一般 › 診斷 › 輸入代碼 › 491348 › 傳送 Things 資料庫。儲存至「檔案」，解開 .aar，再將資料庫資料夾壓縮為 ZIP。Mac：拷貝前結束 Things。匯入後需重新設定重複規則與提醒。';

  @override
  String importWarnDetailsInNotes(int count) {
    return '$count 個任務的檢查列表或領域資訊保留在備註中';
  }

  @override
  String get importWarnThingsRecurrence =>
      '不匯入 Things 重複規則。將略過重複範本；請為匯入的任務重新設定重複規則。';

  @override
  String importWarnSourceReminders(int count) {
    return '$count 個來源提醒設定未匯入';
  }

  @override
  String get importAppleHint => '選擇此裝置上的提醒事項列表。僅匯入未完成的提醒事項。';

  @override
  String get importAppleChooseLists => '選擇列表';

  @override
  String get importAppleReloadLists => '重新載入列表';

  @override
  String get importAppleNoLists => '此裝置上沒有可用的提醒事項列表。';

  @override
  String get importAppleDenied =>
      '提醒事項存取權限已關閉。請在 iOS 設定中允許 Trayzero 存取提醒事項，然後重試。';

  @override
  String get importAppleUnavailable => '無法讀取 Apple 提醒事項，請重試。';

  @override
  String get importAppleListsChanged => '所選列表已無法使用。請重新載入列表並再次選擇。';

  @override
  String get importAppleLimits =>
      '原有 Apple 提醒事項保持不變。Apple 標籤、旗標、附件、子任務結構、優先順序及原有提醒通知不會複製。再次匯入可能產生重複任務。';

  @override
  String get importHintMicrosoftTodo => '登入以複製清單和未完成的任務。匯入前可先預覽；重複匯入可能產生重複任務。';

  @override
  String get importMicrosoftUnavailable => '此版本暫不支援從 Microsoft To Do 匯入。';

  @override
  String get importMicrosoftSignInError => 'Microsoft 登入失敗或已過期，請重新登入。';

  @override
  String get importMicrosoftPermissionError =>
      'Microsoft 未允許存取你的任務。請檢查帳戶權限或聯絡所屬組織。';

  @override
  String get importMicrosoftNetworkError =>
      '無法讀取全部 Microsoft 任務，未匯入任何內容。請檢查網路連線後重試。';

  @override
  String importWarnSourceDetails(int count) {
    return '$count 個任務包含不會匯入的附件、提醒設定或狀態。';
  }

  @override
  String get moreGroupOrganize => '整理';

  @override
  String get moreGroupPreferences => '偏好設定';

  @override
  String get moreGroupData => '資料';

  @override
  String get moreOn => '開';

  @override
  String get moreOff => '關';

  @override
  String moreAppearanceSummary(String theme, String palette) {
    return '$theme · $palette';
  }

  @override
  String get moreRemindersBlockedTitle => '提醒已被封鎖';

  @override
  String get moreRemindersBlockedBody => '通知已關閉，提醒無法通知你。';

  @override
  String get moreBackupFailedTitle => '備份失敗';

  @override
  String get moreBackupFailedBody => '自動備份無法儲存。請檢查資料夾和可用空間。';

  @override
  String get moreFix => '修復';

  @override
  String get moreBackupRestore => '備份與還原';

  @override
  String get moreBackupSubtitleOff => '自動備份已關閉';

  @override
  String get moreBackupSubtitleFailed => '備份失敗';

  @override
  String get moreImportSources => 'Todoist、TickTick、OmniFocus 等';

  @override
  String get moreSupportTrailing => '選用';

  @override
  String get moreSupportTrailingSupporter => '支持者';

  @override
  String get moreAboutPrivacy => '關於與隱私';

  @override
  String get moreHowGtdWorks => 'GTD 如何運作';

  @override
  String get moreNudgesGroup => '提醒推播';

  @override
  String get moreTimingGroup => '時間';

  @override
  String get moreLeadOff => '關';

  @override
  String get moreLead10 => '提前 10 分鐘';

  @override
  String get moreLead30 => '提前 30 分鐘';

  @override
  String get moreLead60 => '提前 1 小時';

  @override
  String get moreLead1440 => '提前 1 天';

  @override
  String moreLeadOther(int minutes) {
    return '提前 $minutes 分鐘';
  }

  @override
  String moreRestoredEntries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 筆',
    );
    return '已還原 $_temp0記錄。';
  }

  @override
  String get moreBackupEmpty => '此備份中沒有可還原的項目。';

  @override
  String get moreCouldntOpenLink => '無法開啟連結';

  @override
  String moreVersionBuild(String version, String build) {
    return '$version（建置 $build）';
  }

  @override
  String get supportBestValue => '最划算';

  @override
  String get importListIntro => '選擇你現在使用的任務 App。新增任何內容之前，你都會先看到預覽。';

  @override
  String get importGroupDirect => '直接連線';

  @override
  String get importGroupFile => '從匯出檔案';

  @override
  String get importGroupOther => '其他';

  @override
  String get importSubGoogleTasks => 'Takeout · Tasks.json';

  @override
  String get importSubTodoist => 'CSV 範本或備份 ZIP';

  @override
  String get importSubThings => '資料庫 ZIP 或 main.sqlite';

  @override
  String get importSubTickTick => '備份 CSV';

  @override
  String get importSubNirvana => 'CSV 或 JSON 匯出';

  @override
  String get importSubOmniFocus => 'TaskPaper 檔案或貼上';

  @override
  String get importSubPlainText => '貼上清單，每行一個任務';

  @override
  String get importSubApple => '選擇此裝置上的清單';

  @override
  String get importSubMicrosoft => '清單和未完成任務';

  @override
  String get importChipOnDevice => '本機';

  @override
  String get importChipSignIn => '登入';

  @override
  String get importBackupFooter => '要還原 Trayzero 備份？';

  @override
  String get importBackupFooterLink => '備份與還原';

  @override
  String get importThingsDeviceIos => 'iPhone / iPad';

  @override
  String get importThingsDeviceMac => 'Mac';

  @override
  String get importCopyCode => '複製代碼';

  @override
  String get importCodeCopied => '已複製代碼';

  @override
  String get importConnect => '連線';

  @override
  String get importStepGoogleTasks1 => '開啟 Google Takeout，只選擇 Tasks。';

  @override
  String get importStepGoogleTasks2 => '匯出為 JSON，並解壓縮下載的檔案。';

  @override
  String get importStepGoogleTasks3 => '在下方選擇 Tasks.json。';

  @override
  String get importNoteGoogleTasks => '清單會保留在備註中；已完成的任務會進入「完成」。';

  @override
  String get importStepTodoist1 => '開啟專案選單，選擇「匯出為範本」(CSV)。';

  @override
  String get importStepTodoist2 => '或在「設定 › 備份」中儲存備份 ZIP。';

  @override
  String get importStepTodoist3 => '在下方選擇該檔案。';

  @override
  String get importStepTickTick1 => '在 TickTick 網站上開啟「設定 › 帳號」。';

  @override
  String get importStepTickTick2 => '開啟「備份與匯入」，點選「產生備份」(CSV)。';

  @override
  String get importStepTickTick3 => '在下方選擇該 CSV。';

  @override
  String get importStepNirvana1 => '在 Nirvana 網頁版中將資料匯出為 CSV 或 JSON。';

  @override
  String get importStepNirvana2 => '在下方選擇該檔案。';

  @override
  String get importStepOmniFocus1 => '在 OmniFocus 中選擇你的專案。';

  @override
  String get importStepOmniFocus2 => '選擇「編輯 › 拷貝為 TaskPaper」。';

  @override
  String get importStepOmniFocus3 => '在下方貼上文字，或將其儲存為檔案後選擇。';

  @override
  String get importStepPlainText1 => '從任意 App 複製任務，每行一個。';

  @override
  String get importStepPlainText2 => '點選下方的「貼上文字」並貼上。';

  @override
  String get importNotePlainText => '僅支援基本文字匯入，不支援其他 App 的資料庫匯出。';

  @override
  String get importStepApple1 => '點選下方的「選擇清單」。';

  @override
  String get importStepApple2 => '出現提示時，允許取用「提醒事項」。';

  @override
  String get importStepApple3 => '勾選要匯入的清單。';

  @override
  String get importNoteApple => '僅匯入未完成的提醒事項。你的 Apple 提醒事項保持不變。';

  @override
  String get importStepMicrosoft1 => '點選「連線」並登入 Microsoft。';

  @override
  String get importStepMicrosoft2 => 'Trayzero 會複製你的清單和未完成任務。';

  @override
  String get importStepMicrosoft3 => '匯入前先檢視預覽。';

  @override
  String get importNoteMicrosoft => '再次匯入可能會產生重複項目。';

  @override
  String get importStepThingsIos1 => '在 Things 中開啟「設定 › 一般 › 診斷 › 輸入代碼」，然後輸入：';

  @override
  String get importStepThingsIos2 => '點選「傳送 Things 資料庫」並儲存到「檔案」。';

  @override
  String get importStepThingsIos3 => '在「檔案」中解壓縮 .aar，然後將資料庫資料夾壓縮為 ZIP。';

  @override
  String get importStepThingsIos4 => '在下方選擇該 ZIP。';

  @override
  String get importStepThingsMac1 => '在 Mac 上結束 Things。';

  @override
  String get importStepThingsMac2 =>
      '從 Things 資料夾複製 Things Database.thingsdatabase，並將副本壓縮為 ZIP。';

  @override
  String get importStepThingsMac3 => '將 ZIP（或其中的 main.sqlite）傳到此裝置，並在下方選擇。';

  @override
  String get importNoteThings => '重複和提醒不會帶過來，匯入後請重新建立。';

  @override
  String get importReviewTitle => '檢查匯入內容';

  @override
  String importFromSource(String source) {
    return '來自 $source';
  }

  @override
  String importTotalTasks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 項任務',
    );
    return '$_temp0';
  }

  @override
  String importActionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '匯入 $count 項任務',
    );
    return '$_temp0';
  }

  @override
  String importNewExistingSummary(int newCount, int existingCount) {
    return '$newCount 項新增 · $existingCount 項已有';
  }

  @override
  String importShowAll(int count) {
    return '顯示全部 $count 項';
  }

  @override
  String get importContextsAndTags => '情境與標籤';

  @override
  String importNotesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 則說明',
    );
    return '$_temp0';
  }

  @override
  String get notificationStatusOnTitle => '提醒已開啟';

  @override
  String get notificationStatusOnBody => '提醒會在此裝置上通知你。';

  @override
  String get notificationStatusOffTitle => '提醒已關閉';

  @override
  String get notificationStatusOffBody => '提醒已排程，但在你允許通知之前不會提醒你。';

  @override
  String get notificationStatusBlockedTitle => '提醒已被封鎖';

  @override
  String get notificationStatusBlockedBody =>
      '系統設定中已關閉 Trayzero 的通知。在那裡重新開啟之前，提醒不會通知你。';

  @override
  String get notificationActionEnable => '啟用通知';

  @override
  String get notificationActionOpenSettings => '開啟設定';

  @override
  String get notificationPrimerTitle => '開啟提醒？';

  @override
  String get notificationPrimerBody =>
      'Trayzero 會在此裝置上發送通知，提醒你到期日和每週回顧。不會向伺服器傳送任何內容，提醒皆在本機排程。\n\n接下來，你的裝置會請求顯示通知的權限。';

  @override
  String get notificationPrimerNotNow => '暫不';

  @override
  String get notificationPrimerContinue => '繼續';

  @override
  String get notificationPromptFailed => '無法開啟通知權限提示。';

  @override
  String get notificationAlreadyOn => '提醒已經開啟。';

  @override
  String get notificationOpenedSettings => '已開啟系統設定，請為 Trayzero 開啟通知。';

  @override
  String get notificationStayOff => '提醒保持關閉。你可以隨時在「更多」→「提醒」中啟用。';

  @override
  String get notificationNowOn => '提醒已開啟。';

  @override
  String get notificationBlocked => 'Trayzero 的通知已被封鎖。';

  @override
  String get exactAlarmSettingsFailed => '無法開啟精確鬧鐘設定。';

  @override
  String get exactAlarmAlreadyOn => '精確提醒時間已經開啟。';

  @override
  String get exactAlarmNowOn => '精確提醒時間已開啟。';

  @override
  String get exactAlarmStaysOff => '精確提醒時間保持關閉。短時間提醒可能會延遲。';

  @override
  String get attachmentRemoved => '附件已移除。';

  @override
  String get discardCaptureTitle => '捨棄這次擷取？';

  @override
  String get discardCaptureBody => '你輸入的內容將會遺失。';

  @override
  String get keepEditing => '繼續編輯';

  @override
  String get discard => '捨棄';

  @override
  String get processFiledSnackbar => '已歸類。';

  @override
  String get errorLoadTitle => '無法載入';

  @override
  String get errorLoadBody => '你的資料是安全的。請重試。';

  @override
  String sharedAddedToInbox(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已將 $count 項加入收件匣',
    );
    return '$_temp0';
  }

  @override
  String get filterByProject => '依專案篩選';

  @override
  String get projectStatusActive => '進行中';

  @override
  String get projectStatusOnHold => '暫停';

  @override
  String get projectStatusSomeday => '將來某天';

  @override
  String get projectStatusDone => '已完成';

  @override
  String get projectStatusDropped => '已放棄';

  @override
  String get projectChangeStatus => '變更狀態';

  @override
  String get projectAwaitingTooltip => '等待中——透過等待或已安排的事項推進';

  @override
  String get projectStalledTooltip => '停滯——沒有下一步行動、等待或已安排的事項';

  @override
  String get projectStalledBanner => '停滯——尚未設定下一步行動、等待或已安排的事項。新增一個下一步行動來推動它。';

  @override
  String get projectAwaitingBanner =>
      '此專案目前僅靠等待或已安排的事項推進。建議新增一個後續的下一步行動，以免這些事項完成後專案停滯。';

  @override
  String projectNextActionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 個下一步行動',
    );
    return '$_temp0';
  }

  @override
  String projectWaitingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 個等待中',
    );
    return '$_temp0';
  }

  @override
  String engageHiddenByFilters(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '有 $count 個下一步行動被篩選條件隱藏',
    );
    return '$_temp0';
  }

  @override
  String get filterReset => '重設';

  @override
  String onboardingSeedExisting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '你已有 $count 個專案。',
    );
    return '$_temp0';
  }

  @override
  String get purchaseErrUnavailable => '目前無法購買。';

  @override
  String get purchaseErrProducts => '無法載入商品。請檢查網路連線後重試。';

  @override
  String get purchaseErrOption => '該選項目前無法使用。';

  @override
  String get purchaseErrNetwork => '網路錯誤。請檢查網路連線後重試。';

  @override
  String get purchaseErrNotAllowed => '此裝置不允許購買。';

  @override
  String get purchaseErrPending => '你的購買正在等待核准。';

  @override
  String get purchaseErrAlreadyOwned => '你已擁有此項目——請嘗試「恢復購買」。';

  @override
  String get purchaseErrStore => '應用程式商店發生問題。請稍後再試。';

  @override
  String get purchaseErrUnknown => '購買時發生問題。請重試。';

  @override
  String get backupErrEmpty => '備份是空的，沒有可匯入的內容。';

  @override
  String get backupErrInvalidJson =>
      '這不是有效的 JSON。請確認所選的是完整且未經編輯的 Trayzero 備份檔案。';

  @override
  String get backupErrNotBackup => '此檔案不是 Trayzero 備份。';

  @override
  String get backupErrNewerVersion => '此備份由較新版本的應用程式建立。請更新 Trayzero 後重新匯入。';

  @override
  String get backupErrUnrecognized => '此檔案看起來不是 Trayzero 備份。';

  @override
  String get backupErrInvalidData => '此備份包含無效資料，無法匯入。';

  @override
  String get backupErrReminders => '資料已還原，但部分提醒未能更新。請重新匯入以更新它們。';

  @override
  String get backupErrRestoreFailed => '還原時發生問題。此次嘗試沒有變更你現有的資料。';

  @override
  String backupCountItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 個事項',
    );
    return '$_temp0';
  }

  @override
  String backupCountProjects(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 個專案',
    );
    return '$_temp0';
  }

  @override
  String backupCountContexts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 個情境',
    );
    return '$_temp0';
  }

  @override
  String backupCountAreas(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 個領域',
    );
    return '$_temp0';
  }

  @override
  String backupCountAttachments(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 個附件',
    );
    return '$_temp0';
  }

  @override
  String backupCountReviews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 次回顧',
    );
    return '$_temp0';
  }

  @override
  String get restoreFolderTitle => '從備份資料夾還原';

  @override
  String get restoreFolderIntro =>
      '選擇 Trayzero 儲存備份的資料夾，例如由 iCloud Drive、Google Drive 或 Syncthing 管理的資料夾。還原會把備份合併到這部裝置，不會刪除既有內容。';

  @override
  String get restoreFolderChoose => '選擇備份資料夾';

  @override
  String get restoreFolderChange => '選擇其他資料夾';

  @override
  String restoreFolderFrom(String name) {
    return '資料夾：$name';
  }

  @override
  String get restoreFolderEmpty => '此資料夾中找不到 Trayzero 備份。';

  @override
  String get restoreFolderFailed => '無法開啟此資料夾。請確認它仍可使用，或重新選擇。';

  @override
  String restoreFolderItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 項',
    );
    return '$_temp0';
  }

  @override
  String get restoreFolderUnreadable => '無法讀取此檔案';

  @override
  String get restoreFolderReading => '讀取中…';

  @override
  String get onboardingRestoreAction => '從其他裝置轉移？還原備份';

  @override
  String folderBackupStale(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days 天',
    );
    return '已有 $_temp0沒有新的備份。';
  }

  @override
  String get folderBackupRepairHint => '如果備份已停止運作，請重新選擇資料夾。';

  @override
  String moreBackupSubtitleStale(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days 天',
    );
    return '已有 $_temp0沒有新的備份 · 點一下修復';
  }

  @override
  String get backupPromptTitle => '自動備份你的任務';

  @override
  String get backupPromptBody =>
      '你已經記錄了不少內容。在你自己的雲端硬碟或同步 App 中選一個資料夾，Trayzero 會在那裡保留最近 10 份備份。這是備份，不是同步。';

  @override
  String get backupPromptAction => '選擇資料夾';

  @override
  String get backupPromptDismiss => '不用了';

  @override
  String backupCardHealthy(String date) {
    return '已於 $date 備份';
  }

  @override
  String get backupCardOffBody => '開啟後，每次變更都會將副本儲存到資料夾。';

  @override
  String get backupCardTurnOn => '開啟';

  @override
  String get backupCardChooseAgain => '重新選擇資料夾';

  @override
  String get backupCardTryAgain => '重試';

  @override
  String get backupGroupBackUp => '備份';

  @override
  String get backupGroupRestore => '還原';

  @override
  String get backupAutoTitle => '自動備份';

  @override
  String get backupAutoSubtitle => '每次變更後';

  @override
  String get backupFolderTitle => '備份資料夾';

  @override
  String get backupExportTitle => '匯出副本';

  @override
  String get backupExportSubtitle => '一次性分享備份檔案';

  @override
  String get backupRestoreTitle => '還原備份';

  @override
  String get backupRestoreRowSubtitle => '從資料夾或檔案';

  @override
  String get backupRestoreSheetBody => '選擇備份所在位置。在任何內容變更之前，你可以先查看其中的內容。';

  @override
  String get backupRestoreFromFolder => '從備份資料夾';

  @override
  String get backupRestoreFromFolderHint => '建議 — 選擇已儲存的備份';

  @override
  String get backupRestoreFromFile => '從檔案';

  @override
  String get backupRestoreFromFileHint => 'Trayzero 備份（.json）';

  @override
  String get backupRestorePaste => '貼上備份文字';

  @override
  String get backupFootnote => '這是備份，不是同步 — 由你的雲端或同步 App 在裝置間傳遞該資料夾。';

  @override
  String get backupCardJustNow => '剛剛已備份';

  @override
  String backupCardMinutesAgo(int minutes) {
    return '$minutes 分鐘前已備份';
  }

  @override
  String backupCardHoursAgo(int hours) {
    return '$hours 小時前已備份';
  }

  @override
  String get backupCardYesterday => '昨天已備份';

  @override
  String get backupHowItWorks => '運作方式';

  @override
  String get backupHowTitle => '備份如何運作';

  @override
  String get backupHowSaves =>
      '每次變更後，Trayzero 會把資料的 JSON 副本儲存到你選擇的資料夾，並保留最近的 10 份。';

  @override
  String get backupHowSync =>
      '你的雲端或同步應用程式（例如 iCloud Drive、Google 雲端硬碟或 Syncthing）會把該資料夾帶到你的其他裝置。Trayzero 本身不會上傳或同步任何內容。';

  @override
  String get backupHowMove => '若要移轉到另一台裝置，請選擇「還原備份」，然後選擇「從備份資料夾」。';

  @override
  String get microphoneAccessDenied => '麥克風權限已關閉。請在設定中允許，以錄製語音備忘。';

  @override
  String get filterTimeEnergy => '時間與精力';

  @override
  String get clearDate => '清除日期';

  @override
  String get reorderHandle => '拖曳以重新排序';

  @override
  String get calendarConnectionTitle => '行事曆連線';

  @override
  String get calendarTogether => '讓計畫匯聚一處。';

  @override
  String get calendarConnectionIntro => '將 Trayzero 中的行程與當天的其他安排一起查看。';

  @override
  String get calendarConnect => '連接行事曆';

  @override
  String get calendarScope =>
      '僅發佈 Trayzero「行事曆」中已安排日期的事項。一般任務截止日期保留在 Trayzero 中。';

  @override
  String get calendarAutomatic => '自動更新';

  @override
  String get calendarAutomaticHelp => '使用 Trayzero 時及重新開啟應用程式時更新。';

  @override
  String get calendarPaused => '已暫停';

  @override
  String get calendarConnected => '已連線';

  @override
  String get calendarNeedsAttention => '需要處理';

  @override
  String get calendarPauseHelp => '現有行事曆事件保持不變。變更將等待你恢復更新或選擇「立即更新」。';

  @override
  String calendarLinkedCount(int count) {
    return '$count 個已連結事件';
  }

  @override
  String calendarLastUpdated(String when) {
    return '上次更新：$when';
  }

  @override
  String get calendarChangesWaiting => '有變更等待更新';

  @override
  String get calendarUpdateNow => '立即更新';

  @override
  String get calendarManage => '管理連線';

  @override
  String get calendarWorking => '正在更新行事曆連線…';

  @override
  String get calendarRestoreAccess => '恢復存取權限';

  @override
  String get calendarUpdateFailed => '部分變更未能套用。上方顯示上次成功更新的時間。請重試以完成更新。';

  @override
  String get calendarRemovalPending => '等待移除';

  @override
  String calendarRemoveFailed(int count) {
    return '$count 個事件未能移除。自動更新已停止。請重試移除，或中斷連線並保留剩餘事件。';
  }

  @override
  String get calendarSaveFailed => '無法儲存此變更。請檢查連線設定後重試。';

  @override
  String get calendarNoWritable => '沒有可寫入的行事曆。請在裝置的行事曆設定中新增行事曆後重試。';

  @override
  String get calendarChangeDestination => '變更目標行事曆';

  @override
  String get calendarChooseDestination => '選擇行事曆';

  @override
  String get calendarMoveHelp => '已連結事件將移至新行事曆。其他行事曆事件保持原位。自動更新將保留目前設定。';

  @override
  String calendarSetupCount(int count) {
    return '將發佈 $count 個已安排事項。如有可用的既有事件連結，將予以重用。';
  }

  @override
  String get calendarMoveEvents => '移動已連結事件';

  @override
  String get calendarConnectAndAdd => '連接並新增事件';

  @override
  String get calendarDisconnect => '中斷行事曆連線';

  @override
  String get calendarDisconnectQuestion => '中斷行事曆連線？';

  @override
  String get calendarDisconnectHelp =>
      '選擇如何處理已連結的行事曆事件。Trayzero 事項和其他行事曆事件將保留。';

  @override
  String get calendarKeepEvents => '在行事曆中保留事件';

  @override
  String get calendarKeepHelp => '停止更新並保留事件。重新連線時可重用這些連結。';

  @override
  String calendarRemoveEvents(int count) {
    return '移除 $count 個已連結事件';
  }

  @override
  String get calendarRemoveHelp => '僅移除此連線連結的事件。移除失敗的事件仍可重試。';

  @override
  String get calendarHowItWorks => '已連結事件如何運作';

  @override
  String get calendarRules =>
      'Trayzero 將已安排的「行事曆」事項發佈到所選裝置行事曆。一般任務截止日期不包括在內。\n\n請在 Trayzero 中編輯標題、備註、時間和重複規則。更新可能覆寫你在行事曆應用程式中的編輯。事件目前使用一小時的長度。\n\n完成、移至垃圾桶或移出「行事曆」的事項，其連結事件將在下次更新時移除。重複系列會推進至下一次。\n\n暫停會保留事件及連結。中斷連線時可選擇保留或移除連結事件。中斷連線不會刪除 Trayzero 事項。';

  @override
  String get calendarBringEvents => '將事件匯入 Trayzero';

  @override
  String get calendarImportCopies => '選擇事件複製到收件匣或行事曆。副本不會跟隨原始事件的後續變更。原始事件保持不變。';

  @override
  String get calendarChooseEvents => '選擇事件';

  @override
  String get calendarImportSource => '選擇來源行事曆';

  @override
  String get calendarImportDestination => '將所選事件新增至';

  @override
  String calendarAddSelected(int count) {
    return '新增 $count 個事件';
  }

  @override
  String get calendarNoImportEvents =>
      '沒有可匯入的新事件。已新增或已連結至 Trayzero 的事件不會顯示。範圍為過去 7 天及未來一年。';

  @override
  String get calendarImportFailed => '無法匯入行事曆事件。請檢查行事曆存取權限後重試。';

  @override
  String get calendarDeviceHelp =>
      '使用裝置的行事曆，無需 Trayzero 帳號。共享行事曆中的事件可能對有存取權限的其他人可見。';
}
