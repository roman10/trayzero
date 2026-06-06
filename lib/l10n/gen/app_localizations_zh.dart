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
  String get edit => '编辑';

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
  String get rename => '重命名';

  @override
  String get inbox => '收件箱';

  @override
  String get doVerb => '执行';

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
  String get onboardingFinish => '开始吧';

  @override
  String get inboxEmptyTitle => '收件箱清空';

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
  String get processTitle => '处理收件箱';

  @override
  String get processCompleteTitle => '收件箱清空！';

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
  String get twoMinQuestion => '2 分钟内能搞定吗？';

  @override
  String get twoMinYes => '能——我现在就做';

  @override
  String get twoMinNo => '不能';

  @override
  String get delegateQuestion => '可以让别人去做吗？';

  @override
  String get waitingOnPromptTitle => '在等谁？';

  @override
  String get waitingOnPromptHint => '人名或系统';

  @override
  String get multiStepQuestion => '需要多个步骤吗？';

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
  String get engageNoMatchMessage => '当前筛选条件下没有行动。试着放宽筛选或清除筛选。';

  @override
  String get hardLandscape => '硬性日程';

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
  String projectActionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个行动',
      one: '1 个行动',
    );
    return '$_temp0';
  }

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
  String get projectMissingNextActionError => '未定义下一步行动。每个进行中的项目至少应该有一个。';

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
  String get reviewStep5Body => '每个项目要么进行中、要么搁置、要么已完成——并且每个进行中的项目至少要有一个下一步行动。';

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
  String get organizationSection => '组织方式';

  @override
  String get contextsLabel => '情境';

  @override
  String get areasOfFocusLabel => '职责范围';

  @override
  String get areasOfFocusDescription => '按长期负责的领域把项目分组。';

  @override
  String get calendarSyncLabel => '日历同步';

  @override
  String get calendarSyncDescription => '把带截止日期的事项同步到系统日历。';

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
  String get dataSection => '数据';

  @override
  String get exportBackup => '导出备份';

  @override
  String get exportBackupDescriptionIos =>
      '分享一份 JSON 副本。建议存到云盘（如「文件」→ iCloud Drive）作为备份。';

  @override
  String get exportBackupDescriptionAndroid =>
      '分享一份 JSON 副本。建议存到云盘（如 Google Drive）作为备份。';

  @override
  String exportBackupError(String error) {
    return '导出失败：$error';
  }

  @override
  String get weeklyBackupReminder => '每周备份提醒';

  @override
  String get weeklyBackupReminderDescription => '每周日早上提醒我导出并保存备份。';

  @override
  String get importBackup => '导入备份';

  @override
  String get importBackupDescription =>
      '恢复 Trayzero 备份，或导入 Google Tasks（Takeout）导出文件。';

  @override
  String get importConfirmTitle => '导入这份备份？';

  @override
  String importConfirmBody(String sections) {
    return '这将新增或更新 $sections。\n\n相同 id 的现有条目会被备份中的版本覆盖，无法撤销。';
  }

  @override
  String get importButton => '导入';

  @override
  String get importSourceSheetTitle => '导入备份';

  @override
  String get importFromFileTitle => '选择备份文件';

  @override
  String get importFromFileDescription =>
      '推荐——一份 Trayzero .json 备份或 Google Takeout 的 Tasks.json。';

  @override
  String get importFromPasteTitle => '粘贴备份 JSON';

  @override
  String get importFromPasteDescription => '也可以直接粘贴备份文本。';

  @override
  String get pasteBackupHint => '粘贴备份 JSON…';

  @override
  String get privacySection => '隐私';

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
  String get aboutSection => '关于';

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
  String get supportSummaryDefault => '给开发者打赏，或成为支持者';

  @override
  String get supportSummarySupporter => '感谢你支持 Trayzero 💙';

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
    return '$price / 年 · 最划算 · 解锁支持者特权';
  }

  @override
  String get supportSupporterMonthly => '支持者 — 按月';

  @override
  String supportSupporterMonthlySubtitle(String price) {
    return '$price / 月 · 随时取消';
  }

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
  String get edit => '編輯';

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
  String get rename => '重新命名';

  @override
  String get inbox => '收件匣';

  @override
  String get doVerb => '執行';

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
  String get onboardingFinish => '開始吧';

  @override
  String get inboxEmptyTitle => '收件匣清空';

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
  String get processTitle => '處理收件匣';

  @override
  String get processCompleteTitle => '收件匣清空！';

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
  String get twoMinQuestion => '2 分鐘內能搞定嗎？';

  @override
  String get twoMinYes => '能——我現在就做';

  @override
  String get twoMinNo => '不能';

  @override
  String get delegateQuestion => '可以讓別人去做嗎？';

  @override
  String get waitingOnPromptTitle => '在等誰？';

  @override
  String get waitingOnPromptHint => '人名或系統';

  @override
  String get multiStepQuestion => '需要多個步驟嗎？';

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
  String get engageNoMatchMessage => '目前篩選條件下沒有行動。試著放寬篩選或清除篩選。';

  @override
  String get hardLandscape => '硬性日程';

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
  String projectActionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 個行動',
      one: '1 個行動',
    );
    return '$_temp0';
  }

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
  String get projectMissingNextActionError => '未定義下一步行動。每個進行中的專案至少應該有一個。';

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
  String get reviewStep5Body => '每個專案要麼進行中、要麼擱置、要麼已完成——並且每個進行中的專案至少要有一個下一步行動。';

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
  String get organizationSection => '組織方式';

  @override
  String get contextsLabel => '情境';

  @override
  String get areasOfFocusLabel => '職責範圍';

  @override
  String get areasOfFocusDescription => '按長期負責的領域把專案分組。';

  @override
  String get calendarSyncLabel => '行事曆同步';

  @override
  String get calendarSyncDescription => '把帶截止日期的事項同步到系統行事曆。';

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
  String get dataSection => '資料';

  @override
  String get exportBackup => '匯出備份';

  @override
  String get exportBackupDescriptionIos =>
      '分享一份 JSON 副本。建議儲存到雲端（如「檔案」→ iCloud Drive）作為備份。';

  @override
  String get exportBackupDescriptionAndroid =>
      '分享一份 JSON 副本。建議儲存到雲端（如 Google Drive）作為備份。';

  @override
  String exportBackupError(String error) {
    return '匯出失敗：$error';
  }

  @override
  String get weeklyBackupReminder => '每週備份提醒';

  @override
  String get weeklyBackupReminderDescription => '每週日早上提醒我匯出並儲存備份。';

  @override
  String get importBackup => '匯入備份';

  @override
  String get importBackupDescription =>
      '還原 Trayzero 備份，或匯入 Google Tasks（Takeout）匯出檔案。';

  @override
  String get importConfirmTitle => '匯入這份備份？';

  @override
  String importConfirmBody(String sections) {
    return '這將新增或更新 $sections。\n\n相同 id 的現有條目會被備份中的版本覆蓋，無法撤銷。';
  }

  @override
  String get importButton => '匯入';

  @override
  String get importSourceSheetTitle => '匯入備份';

  @override
  String get importFromFileTitle => '選擇備份檔案';

  @override
  String get importFromFileDescription =>
      '推薦——一份 Trayzero .json 備份或 Google Takeout 的 Tasks.json。';

  @override
  String get importFromPasteTitle => '貼上備份 JSON';

  @override
  String get importFromPasteDescription => '也可以直接貼上備份文字。';

  @override
  String get pasteBackupHint => '貼上備份 JSON…';

  @override
  String get privacySection => '隱私';

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
  String get aboutSection => '關於';

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
  String get supportSummaryDefault => '給開發者打賞，或成為支持者';

  @override
  String get supportSummarySupporter => '感謝你支持 Trayzero 💙';

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
    return '$price / 年 · 最划算 · 解鎖支持者特權';
  }

  @override
  String get supportSupporterMonthly => '支持者 — 按月';

  @override
  String supportSupporterMonthlySubtitle(String price) {
    return '$price / 月 · 隨時取消';
  }

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
}
