// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appName => 'Trayzero';

  @override
  String get cancel => 'キャンセル';

  @override
  String get save => '保存';

  @override
  String get delete => '削除';

  @override
  String get add => '追加';

  @override
  String get ok => 'OK';

  @override
  String get next => '次へ';

  @override
  String get back => '戻る';

  @override
  String get skip => 'スキップ';

  @override
  String get done => '完了';

  @override
  String get undo => '元に戻す';

  @override
  String get retry => '再試行';

  @override
  String get settings => '設定';

  @override
  String get enable => '有効にする';

  @override
  String get none => 'なし';

  @override
  String get notSet => '未設定';

  @override
  String get search => '検索';

  @override
  String get select => '選択';

  @override
  String get selectAll => 'すべて選択';

  @override
  String get selectNone => '選択解除';

  @override
  String get inbox => '受信箱';

  @override
  String get projects => 'プロジェクト';

  @override
  String get review => 'レビュー';

  @override
  String get more => 'その他';

  @override
  String get navInbox => '受信箱';

  @override
  String get navDo => '実行';

  @override
  String get navProjects => 'プロジェクト';

  @override
  String get navReview => 'レビュー';

  @override
  String get navMore => 'その他';

  @override
  String get capture => '収集';

  @override
  String get clarify => '処理';

  @override
  String get organize => '整理';

  @override
  String get reflect => 'レビュー';

  @override
  String get engage => '実行';

  @override
  String get nextAction => '次の行動';

  @override
  String get waitingFor => '連絡待ち';

  @override
  String get someday => 'いつか';

  @override
  String get somedayMaybe => 'いつか / たぶん';

  @override
  String get reference => '資料';

  @override
  String get calendar => 'カレンダー';

  @override
  String get project => 'プロジェクト';

  @override
  String get completed => '完了済み';

  @override
  String get scheduled => '予定済み';

  @override
  String get needsClarifying => '要処理';

  @override
  String get howGtdWorks => 'GTDの仕組み';

  @override
  String get whatIsGtd => 'GTDとは？';

  @override
  String get onboardingPage1Title => '頭の中を空にしよう';

  @override
  String get onboardingPage1Body =>
      '気になっていること——タスク、アイデア、心配ごと——をすべて受信箱に入れましょう。整理するのは後で。まずは頭の中を空にすることが大切です。';

  @override
  String get onboardingPage2Title => '一つずつ処理していく';

  @override
  String get onboardingPage2Body =>
      '処理フローでは、収集した項目を一つずつGTDの判断ツリーに沿って整理します。行動できる？2分以内で終わる？人に任せる？プロジェクト？それとも次の行動？';

  @override
  String get onboardingPage3Title => '時間があるときに実行';

  @override
  String get onboardingPage3Body =>
      '「実行」タブでは、状況・エネルギー・使える時間で次の行動を絞り込めます。今やれることがいつでも一目でわかります。';

  @override
  String get onboardingPage4Title => 'レビューで信頼できる仕組みに';

  @override
  String get onboardingPage4Body =>
      '週次レビューがシステムを健全に保ちます。週に一度、すべてのリストに目を通し、受信箱を空にして、先を見渡しましょう。';

  @override
  String get onboardingSeedTitle => '準備完了です';

  @override
  String get onboardingSeedBody =>
      'デフォルトの状況（@phone、@computer、@errands、@home、@office、@anywhere、@waiting）を最初から用意しています。設定からいつでも追加・編集できます。';

  @override
  String get onboardingSeedSampleLabel => 'サンプルプロジェクトを追加';

  @override
  String get onboardingSeedSampleSubtitle =>
      'スタータープロジェクトといくつかの項目を追加して、空っぽの状態を解消します。';

  @override
  String get projectSectionActive => '進行中';

  @override
  String get projectSectionUnfiled => '未分類';

  @override
  String get projectSectionOnHold => '保留中';

  @override
  String get sampleProjectTitle => 'GTDを最大限に活用する';

  @override
  String get sampleProjectOutcome => '毎日受信箱をゼロにし、毎週金曜日に週次レビューを行う。';

  @override
  String get sampleItemReadPrimer => '設定でGTDの入門ガイドを読む';

  @override
  String get sampleItemEmptyEmail => 'メールの受信箱をここへ空にする';

  @override
  String get sampleItemScheduleReview => '毎週金曜日の週次レビューを繰り返し予定に入れる';

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
  String get onboardingFinish => 'はじめる';

  @override
  String get inboxEmptyTitle => '受信箱ゼロ';

  @override
  String get inboxEmptyMessage =>
      '処理する項目はありません。気になっていることを頭から出すには「収集」をタップ——あとでまとめて処理できます。';

  @override
  String get inboxEmptyAction => '何か収集する';

  @override
  String inboxItemsToClarify(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '処理待ち $count 件',
    );
    return '$_temp0';
  }

  @override
  String get processInbox => '受信箱を処理';

  @override
  String deleteItemsConfirmTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 件を削除しますか？',
    );
    return '$_temp0';
  }

  @override
  String get deleteItemsConfirmBody => '添付ファイルも含めて完全に削除されます。この操作は取り消せません。';

  @override
  String deletedItemsSnackbar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 件を削除しました。',
    );
    return '$_temp0';
  }

  @override
  String completedItemsSnackbar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 件を完了しました。',
    );
    return '$_temp0';
  }

  @override
  String filedItemsSnackbar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 件をプロジェクトに振り分けました。',
    );
    return '$_temp0';
  }

  @override
  String movedItemsSnackbar(int count, String destination) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 件を$destinationに移動しました。',
    );
    return '$_temp0';
  }

  @override
  String selectionCountTitle(int count) {
    return '$count 件選択中';
  }

  @override
  String get captureTitle => '頭の中を空に';

  @override
  String get captureHint => '気になっていることは？';

  @override
  String get captureNotesHint => 'メモ（任意）';

  @override
  String get captureEmptyError => '収集する内容を入力してください';

  @override
  String get captureSubmit => '受信箱に追加';

  @override
  String get dictate => '音声入力';

  @override
  String get stopDictation => '音声入力を停止';

  @override
  String get dictationUnavailable => '音声入力を利用できません。引き続き文字を入力できます。';

  @override
  String get processTitle => '受信箱を処理';

  @override
  String get processCompleteTitle => '受信箱ゼロ！';

  @override
  String get processCompleteNoItems => '処理する項目はありません。';

  @override
  String processCompleteStats(int filed, int doneNow, int trashed) {
    return '$filed 件を振り分け、$doneNow 件を2分以内で片付け、$trashed 件を削除しました。お疲れさまでした。';
  }

  @override
  String processStepCounter(int step, int total) {
    return 'ステップ $step / $total';
  }

  @override
  String processItemsRemaining(int count) {
    return '残り $count 件';
  }

  @override
  String get previousStepTooltip => '前のステップ';

  @override
  String get skipItemTooltip => 'スキップ';

  @override
  String get actionableQuestion => '行動を起こす必要がありますか？';

  @override
  String get actionableYes => 'はい——やることがある';

  @override
  String get actionableReference => 'いいえ——資料として残す';

  @override
  String get actionableSomeday => 'いいえ——いつか / たぶん';

  @override
  String get actionableTrash => '削除';

  @override
  String get twoMinQuestion => '2分以内で終わりますか？';

  @override
  String get twoMinYes => 'はい——今すぐやる';

  @override
  String get delegateQuestion => '誰かに任せられますか？';

  @override
  String get waitingOnPromptTitle => '誰の連絡待ちですか？';

  @override
  String get waitingOnPromptHint => '名前またはシステム';

  @override
  String get recurrencePrompt => '繰り返す？';

  @override
  String get recurrenceOff => '繰り返さない';

  @override
  String get capturedLabel => '収集済み';

  @override
  String get engageTitle => '今すぐ実行';

  @override
  String get engageEmptyTitle => '次の行動はまだありません';

  @override
  String get engageEmptyMessage => '何かを収集するか、受信箱を処理して次の行動リストを作りましょう。';

  @override
  String get engageInlineEmpty => '次の行動はまだありません — 何か収集するか、受信箱を処理しましょう。';

  @override
  String get engageOpenInbox => '受信箱を開く';

  @override
  String get engageNoMatchTitle => '一致するものがありません';

  @override
  String get hardLandscape => 'カレンダー';

  @override
  String get hardLandscapeSubtitle => '今日が期限・期限超過';

  @override
  String get filterAllContexts => 'すべての状況';

  @override
  String get filterAnyTime => '時間問わず';

  @override
  String get filterUnder5m => '< 5分';

  @override
  String get filterUnder15m => '< 15分';

  @override
  String get filterUnder30m => '< 30分';

  @override
  String get filterUnder1h => '< 1時間';

  @override
  String get filterAnyEnergy => 'エネルギー問わず';

  @override
  String get energyLow => '低';

  @override
  String get energyMedium => '中';

  @override
  String get energyHigh => '高';

  @override
  String get projectsTitle => 'プロジェクト';

  @override
  String get newProject => '新規プロジェクト';

  @override
  String get organizeLooseActionsTooltip => '未整理の行動を整理';

  @override
  String get projectsEmptyTitle => 'プロジェクトはまだありません';

  @override
  String get projectsEmptyMessage =>
      'プロジェクトとは、複数の行動が必要な成果のことです。関連する次の行動をまとめ、目指す結果に向けて進めるために作成しましょう。';

  @override
  String get projectMissingNextAction => '次の行動が未設定です';

  @override
  String get organizeActionsTitle => '行動を整理';

  @override
  String get organizeEmptyTitle => '未整理のものはありません';

  @override
  String get organizeEmptyMessage =>
      'すべての次の行動がプロジェクトに紐づいています。新しく未割り当ての行動が出てきたら、ここで整理できます。';

  @override
  String assignToProject(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 件をプロジェクトに割り当て',
    );
    return '$_temp0';
  }

  @override
  String get addNextActionTitle => '次の行動を追加';

  @override
  String get addNextActionHint => '例：サラにスケジュールをメール';

  @override
  String get addExistingActions => '既存の行動を追加';

  @override
  String get noUnassignedActionsMessage => '取り込める未割り当ての次の行動はありません。';

  @override
  String addCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 件を追加',
    );
    return '$_temp0';
  }

  @override
  String get editProject => 'プロジェクトを編集';

  @override
  String get projectName => 'プロジェクト名';

  @override
  String get projectNameHint => '例：新しいウェブサイトを公開する';

  @override
  String get projectNameRequired => 'プロジェクト名を入力してください';

  @override
  String get areaOfFocusOptional => '関心領域（任意）';

  @override
  String get unfiledOption => '— 未分類 —';

  @override
  String get dueDate => '期限';

  @override
  String get deleteProjectConfirmTitle => 'プロジェクトを削除しますか？';

  @override
  String get deleteProjectWarning => '紐づいた項目は宙に浮きますが、削除はされません。';

  @override
  String get addActionFab => '行動を追加';

  @override
  String get projectOutcomeHint => '「完了」とはどんな状態？';

  @override
  String get outcomeSection => '成果';

  @override
  String get nextActionsSection => '次の行動';

  @override
  String get noNextActionsMessage => '次の行動はまだありません。';

  @override
  String get statusTooltip => 'ステータス';

  @override
  String get reviewTitle => 'レビュー';

  @override
  String get weeklyReviewCardTitle => '週次レビュー';

  @override
  String get weeklyReviewCardSubtitle =>
      '受信箱、リスト、プロジェクトを一通り見直しましょう。システムを信頼し続けるための習慣です。';

  @override
  String get calendarEmpty => '特定の日に紐づいた項目はありません。';

  @override
  String get waitingForEmpty => '依頼中の項目はありません。';

  @override
  String get somedayEmpty => 'いつか / たぶんの項目はありません。';

  @override
  String get referenceEmpty => '資料はありません。';

  @override
  String get completedThisWeek => '今週完了したもの';

  @override
  String get completedThisWeekEmpty => '今週はまだ完了した項目がありません。';

  @override
  String bucketCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 件',
    );
    return '$_temp0';
  }

  @override
  String get needsReDecision => '要再判断';

  @override
  String pastDueCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 件が期限切れ',
    );
    return '$_temp0';
  }

  @override
  String get reviewStep1Title => '頭の中を空にする';

  @override
  String get reviewStep1Body => '気になっていることをすべて受信箱に入れて、システムを信頼できる状態にしましょう。';

  @override
  String get reviewStep2Title => '受信箱をゼロまで処理';

  @override
  String get reviewStep2Body => '判断ツリーに沿って一つずつ処理し、受信箱を空にします。';

  @override
  String get reviewStep3Title => '次の行動を見直す';

  @override
  String get reviewStep3Body =>
      'すべての行動にざっと目を通します。終わった？完了にチェック。古い？編集または削除。まだ有効？そのままで。';

  @override
  String get reviewStep4Title => '連絡待ちリストを見直す';

  @override
  String get reviewStep4Body => '返事は来ていますか？フォローアップが必要ですか？更新するか削除しましょう。';

  @override
  String get reviewStep5Title => 'すべてのプロジェクトを見直す';

  @override
  String get reviewStep5Body =>
      '各プロジェクトの成果を確認しましょう。停滞しているプロジェクトに次のアクションを追加するか、保留または完了にします。連絡待ちや予定済みの作業も進捗として扱います。';

  @override
  String get reviewStep6Title => '今後2週間を見渡す';

  @override
  String get reviewStep6Body => 'カレンダーの予定をチェック。今のうちに準備できることはありますか？';

  @override
  String get reviewStep7Title => 'いつか / たぶんを見直す';

  @override
  String get reviewStep7Body => '今こそ取り組むべきものはありますか？プロジェクトや次の行動に格上げしましょう。';

  @override
  String reviewStepCounter(int step, int total) {
    return 'ステップ $step / $total';
  }

  @override
  String get finishReview => 'レビューを終える';

  @override
  String get reviewCompleteSnackbar => '週次レビュー完了';

  @override
  String get searchHint => '項目・メモを検索';

  @override
  String get searchMinChars => '2文字以上入力してください';

  @override
  String get clearFilters => 'フィルターをクリア';

  @override
  String get clearSearch => '検索をクリア';

  @override
  String searchNoResults(String query) {
    return '「$query」に一致するものがありません';
  }

  @override
  String get searchNoMatchTitle => '一致するものがありません';

  @override
  String get searchNoMatchMessage =>
      '現在のフィルター条件に合う結果がありません。条件を広げるかフィルターを解除してください。';

  @override
  String get filterAllProjects => 'すべてのプロジェクト';

  @override
  String get filterCompleted => '完了済み';

  @override
  String get statusInbox => '受信箱';

  @override
  String get statusNext => '次の行動';

  @override
  String get statusWaiting => '連絡待ち';

  @override
  String get statusSomeday => 'いつか';

  @override
  String get statusReference => '資料';

  @override
  String get appearanceSection => '外観';

  @override
  String get themeLabel => 'テーマ';

  @override
  String get themeFollowSystem => 'システム設定';

  @override
  String get themeLight => 'ライト';

  @override
  String get themeDark => 'ダーク';

  @override
  String get hapticFeedback => '触覚フィードバック';

  @override
  String get languageLabel => '言語';

  @override
  String get languageFollowSystem => 'システムのデフォルト';

  @override
  String get contextsLabel => '状況';

  @override
  String get areasOfFocusLabel => '関心領域';

  @override
  String get calendarSyncLabel => 'カレンダー同期';

  @override
  String get remindersSection => 'リマインダー';

  @override
  String get weeklyReviewNudge => '週次レビューのお知らせ';

  @override
  String get weeklyReviewNudgeDescription => '毎週金曜日の16時にリマインドします。';

  @override
  String get remindBeforeDue => '期限の前にリマインドする';

  @override
  String get remindBeforeDueOff => 'オフ・期限時刻にのみ通知';

  @override
  String get remindBeforeDueSuffix => '以降に保存する項目に適用されます';

  @override
  String get deferSurfaceLabel => '延期された項目を通知する時刻';

  @override
  String get deferSurfaceDescription => '時刻指定のない延期項目は一日中リストに表示され、この時刻に通知します';

  @override
  String get checkingNotificationStatus => '通知ステータスを確認中…';

  @override
  String exportBackupError(String error) {
    return '書き出しに失敗しました：$error';
  }

  @override
  String get weeklyBackupReminder => '毎週バックアップを促す';

  @override
  String get weeklyBackupReminderDescription => '毎週日曜の朝に、書き出して保存するようお知らせします。';

  @override
  String get importConfirmTitle => 'このバックアップを読み込みますか？';

  @override
  String importConfirmBody(String sections) {
    return '$sections が追加または更新されます。\n\n同じIDの既存データはバックアップの内容で上書きされます。この操作は取り消せません。';
  }

  @override
  String get importButton => '読み込み';

  @override
  String get importFromPasteTitle => 'バックアップJSONを貼り付け';

  @override
  String get importFromPasteDescription => '代わりにバックアップのテキストを貼り付けます。';

  @override
  String get pasteBackupHint => 'バックアップJSONを貼り付け…';

  @override
  String get crashReports => 'クラッシュレポートを送信';

  @override
  String get crashReportsDescription =>
      'Sentry経由でクラッシュとエラーの匿名レポートを送信します。個人情報は収集しません。初期設定はオフです。';

  @override
  String get crashReportsEnabled => '次回起動時からクラッシュレポートが送信されます';

  @override
  String get crashReportsDisabled => 'クラッシュレポートを無効にしました';

  @override
  String get showOnboardingAgain => 'オンボーディングをもう一度表示';

  @override
  String get versionLabel => 'バージョン';

  @override
  String get settingsFooter =>
      'ローカルファースト。データはこの端末に留まります。デビッド・アレン氏の「Getting Things Done」メソッドにインスパイアされました。';

  @override
  String get editTitle => '編集';

  @override
  String get saveError => '変更を保存できませんでした。もう一度お試しください。';

  @override
  String get savedIndicator => '保存済み';

  @override
  String get titleLabel => 'タイトル';

  @override
  String get notesLabel => 'メモ';

  @override
  String get statusSection => 'ステータス';

  @override
  String get contextSection => '状況';

  @override
  String get energySection => 'エネルギー';

  @override
  String get timeEstimateSection => '所要時間';

  @override
  String get waitingOnSection => '連絡待ち';

  @override
  String get waitingOnHint => '誰の・何の連絡待ちですか？';

  @override
  String get projectSection => 'プロジェクト';

  @override
  String get datesSection => '日付';

  @override
  String get dueLabel => '期限';

  @override
  String get deferUntilLabel => '保留期限';

  @override
  String get repeatSection => '繰り返し';

  @override
  String get recurrenceNeedsDeferHint =>
      '繰り返しを有効にするには、上の「保留期限」を設定してください——繰り返しはその日付を進めることで機能します。';

  @override
  String get recurrenceNeedsDueDateHint =>
      '繰り返しを有効にするには、上の「期限」または「保留期限」を設定してください——繰り返しはその日付を進めることで機能します。';

  @override
  String get recurrenceExplanation => 'この項目を完了すると、日付がずれた次のインスタンスが作成されます。';

  @override
  String get recurrenceNoDateNextActionError =>
      '繰り返しが設定されていますが、「保留期限」がないため、完了しても次の繰り返しは作成されません。上で保留期限を設定するか、繰り返しをオフにしてください。';

  @override
  String get recurrenceNoDateError =>
      '繰り返しが設定されていますが、「期限」または「保留期限」がないため、完了しても次の繰り返しは作成されません。上で日付を設定するか、繰り返しをオフにしてください。';

  @override
  String get attachmentsSection => '添付ファイル';

  @override
  String get markComplete => '完了にする';

  @override
  String get reopen => '再開';

  @override
  String get deleteItemConfirmTitle => '項目を削除しますか？';

  @override
  String get deleteItemConfirmBody => 'この操作は取り消せません。';

  @override
  String get completeError => 'この項目を完了にできませんでした。';

  @override
  String get reopenError => 'この項目を再開できませんでした。';

  @override
  String get remindersBlockedWarning => 'システム設定で通知がブロックされています——通知は届きません。';

  @override
  String get remindersOffWarning => '通知がオフになっています——通知は届きません。';

  @override
  String get preciseReminderOffWarning =>
      '精密な通知タイミングがオフです——短い時間のリマインダーは遅れる可能性があります。';

  @override
  String get allowExactAlarms => '正確なアラームを許可';

  @override
  String get noContextsAvailable => '状況がまだありません——設定から追加してください。';

  @override
  String get noActiveProjects => '進行中のプロジェクトはまだありません。';

  @override
  String get attachmentPhoto => '写真';

  @override
  String get attachmentCamera => 'カメラ';

  @override
  String get attachmentVoiceMemo => 'ボイスメモ';

  @override
  String get attachmentStop => '停止';

  @override
  String get remove => '削除';

  @override
  String get imageViewerClose => '閉じる';

  @override
  String imageViewerCounter(int current, int total) {
    return '$current / $total';
  }

  @override
  String attachmentPhotoCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '写真$count枚',
    );
    return '$_temp0';
  }

  @override
  String attachmentAudioCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ボイスメモ$count件',
    );
    return '$_temp0';
  }

  @override
  String attachmentFileCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ファイル$count件',
    );
    return '$_temp0';
  }

  @override
  String get areasTitle => '関心領域';

  @override
  String get newArea => '新規領域';

  @override
  String get renameArea => '領域の名前を変更';

  @override
  String get areasEmptyMessage =>
      '領域はまだありません。関心領域とは、健康・キャリア・家族など継続的な責任分野で、プロジェクトをまとめる役割をします。';

  @override
  String get areaNameHint => '例：健康、キャリア、家族';

  @override
  String deleteAreaConfirmTitle(String name) {
    return '「$name」を削除しますか？';
  }

  @override
  String get deleteAreaWarning => 'この領域にあるプロジェクトは未分類になります（削除はされません）。';

  @override
  String get contextsTitle => '状況';

  @override
  String get newContext => '新規状況';

  @override
  String get editContext => '状況を編集';

  @override
  String get contextsEmptyMessage =>
      '状況はまだありません。状況は、どこで・何を使って行動できるかをタグ付けします（@phone、@home、@errands）。';

  @override
  String get nameLabel => '名前';

  @override
  String get iconLabel => 'アイコン';

  @override
  String get colorLabel => '色';

  @override
  String deleteContextConfirmTitle(String name) {
    return '$name を削除しますか？';
  }

  @override
  String get deleteContextWarning => 'この状況を使っている項目からは外されます。';

  @override
  String get calendarSyncTitle => 'カレンダー同期';

  @override
  String get calendarSyncIntro =>
      '期限のある項目をシステムカレンダーに反映し、「#gtd」とタグ付けされた予定をTrayzeroの受信箱に取り込みます。';

  @override
  String get enableCalendarSync => 'カレンダー同期を有効にする';

  @override
  String get targetCalendar => '対象のカレンダー';

  @override
  String get calendarAccessDenied =>
      'カレンダーへのアクセスが拒否されています。対象カレンダーを選ぶには許可してください。';

  @override
  String get grantCalendarAccess => 'カレンダーへのアクセスを許可';

  @override
  String get noCalendarsAvailable =>
      '利用可能なカレンダーがまだありません。先ほどアクセスを許可した場合は、少し待ってから再試行してください。また、システムのカレンダー / アカウント設定で、アカウントの同期がオンになっているか確認してください。';

  @override
  String get mirrorOutAction => '項目をカレンダーに反映';

  @override
  String get importInAction => '#gtd の予定を受信箱に取り込み';

  @override
  String mirrorOutSuccess(int written) {
    return '$written 件をカレンダーに反映しました';
  }

  @override
  String mirrorOutSuccessWithStale(int written, int removed) {
    return '$written 件を反映、$removed 件の古いものを削除しました';
  }

  @override
  String importInSuccess(int count) {
    return '$count 件のカレンダー予定を取り込みました';
  }

  @override
  String get mirroringProgress => '反映中…';

  @override
  String get importingProgress => '取り込み中…';

  @override
  String get calendarSyncTip =>
      'ヒント：カレンダー予定のタイトルのどこかに「#gtd」と書いておくと、次の同期時にTrayzeroの受信箱に表示されます。';

  @override
  String get gtdDiagramTitle => 'GTDの仕組み';

  @override
  String get gtdDiagramSubtitle =>
      '気になることをすべて頭から出し、信頼できる仕組みに収める5つのステップ。ハイライトされたリストをタップするとそこに移動できます。';

  @override
  String get gtdAttribution => 'メソッド：デビッド・アレン · gettingthingsdone.com';

  @override
  String get youAreHere => '現在地';

  @override
  String get gtdStage1Body =>
      '気になっていること——タスク、アイデア、心配ごと——をすべて受信箱に入れます。まだ整理もフィルタリングもしません。';

  @override
  String get gtdStage2Body =>
      '一つずつ取り上げて、それが何なのかを判断します。処理フローでは、各項目を次の判断ツリーに沿って整理します：';

  @override
  String get gtdStage3Body => '結果は適切なリストに収まり、頭の中に残るものはなくなります。';

  @override
  String get gtdStage3Footnote => '連絡待ち / カレンダー / いつか / 資料 は「レビュー」にあります。';

  @override
  String get gtdStage4Body => 'リストを定期的に見直しましょう——特に週次レビューで——システムを信頼できる状態に保てます。';

  @override
  String get gtdStage5Body =>
      'あとは実行するだけ——状況・時間・エネルギー・優先度から行動を選び、すっきりした頭で取り組みます。';

  @override
  String get decisionNotActionableQ => '行動を起こす必要がない？';

  @override
  String get decisionNotActionableA => 'ゴミ箱、いつか / たぶん、または資料へ';

  @override
  String get decisionTwoMinQ => '2分以内で終わる？';

  @override
  String get decisionTwoMinA => '今すぐやる';

  @override
  String get decisionDelegateQ => '誰かに任せるべき？';

  @override
  String get decisionDelegateA => '依頼 → 連絡待ち';

  @override
  String get decisionMultiStepQ => '複数のステップが必要？';

  @override
  String get decisionMultiStepA => 'プロジェクトにする';

  @override
  String get decisionOtherwiseQ => 'それ以外は';

  @override
  String get decisionOtherwiseA => '次の行動を定義する';

  @override
  String get supportTitle => 'Trayzero を応援';

  @override
  String get supportIntro =>
      'Trayzero は無料で、すべての機能が使えます。役に立ったら、少しだけ支援できます。アプリを独立した広告なしの状態で保つのに役立ちます。';

  @override
  String get supportUnavailable => '現在、支援のオプションを利用できません。';

  @override
  String get supportTipHeader => 'チップを贈る';

  @override
  String get supportTipSmall => '少額のチップ';

  @override
  String get supportTipLarge => '高額のチップ';

  @override
  String get supportSupporterYearly => 'サポーター — 年額';

  @override
  String supportSupporterYearlySubtitle(String price) {
    return '$price / 年 · 一番お得 · 開発を応援';
  }

  @override
  String get supportSupporterMonthly => 'サポーター — 月額';

  @override
  String supportSupporterMonthlySubtitle(String price) {
    return '$price / 月 · いつでも解約可能';
  }

  @override
  String supportOpeningStore(String store) {
    return '$storeを開いています…';
  }

  @override
  String get supportRestoring => '購入を復元しています…';

  @override
  String get supportRestore => '購入を復元';

  @override
  String get supportRestoreSubtitle => 'すでにサポーターですか？この端末で復元します。';

  @override
  String get supportAutoRenewNote => 'サブスクリプションは設定で解約するまで自動更新されます。';

  @override
  String get legalPrivacyPolicy => 'プライバシーポリシー';

  @override
  String get legalTermsOfUse => '利用規約';

  @override
  String get supportThanksTip => '本当にありがとうございます！💙';

  @override
  String get supportThanksSupporter => 'サポーターになりました — ありがとうございます！💙';

  @override
  String get supportRestored => '購入を復元しました。おかえりなさい！💙';

  @override
  String get supportRestoreNone => '以前の購入は見つかりませんでした。';

  @override
  String get supportBadgeYearly => 'サポーター · 年額';

  @override
  String get supportBadgeMonthly => 'サポーター · 月額';

  @override
  String get supportBadgeGeneric => 'サポーター';

  @override
  String get supportBadgeSubtitle => 'Trayzero を独立した状態に保ってくれてありがとう。';

  @override
  String get calendarLookupFailed =>
      '端末のカレンダーを読み込めませんでした。カレンダーアプリでアカウントの同期を確認してから、再試行してください。';

  @override
  String get calendarPermissionHelp =>
      '許可の確認が表示されない場合は、アプリの設定でカレンダーへのアクセスを許可してから戻ってください。';

  @override
  String get calendarOpenSettings => 'アプリの設定を開く';

  @override
  String get calendarSettingsFailed =>
      'アプリの設定を開けませんでした。端末の設定で Trayzero のカレンダーへのアクセスを許可してください。';

  @override
  String get calendarSelectionUnavailable =>
      '以前選択したカレンダーは利用できません。別のカレンダーを選択してください。';

  @override
  String get appIcon => 'アプリアイコン';

  @override
  String get appIconAndroidDescription =>
      'アプリカラーとは別にホーム画面のアイコンを選べます。ランチャーの更新に少し時間がかかったり、端末の色合いが適用されたりする場合があります。';

  @override
  String get appIconDescription =>
      'アプリカラーとは別にアイコンを選べます。端末の色合いが適用される場合があります。iOSでは変更時に確認通知が表示されます。';

  @override
  String get appIconChangeFailed =>
      'アイコンを変更できませんでした。Trayzeroを開いた状態でもう一度お試しください。';

  @override
  String get appColor => 'アプリの色';

  @override
  String get appColorDescription => 'ライトモードとダークモードで使えます。GTDリストの色の意味は変わりません。';

  @override
  String get paletteAmber => 'Trayzeroのアンバー — 標準';

  @override
  String get paletteBlue => 'ブルー';

  @override
  String get paletteCyan => 'シアン';

  @override
  String get paletteTeal => 'ティール';

  @override
  String get paletteGreen => 'グリーン';

  @override
  String get paletteViolet => 'バイオレット';

  @override
  String get paletteRose => 'ローズ';

  @override
  String get appIconNotificationNote =>
      'Androidの通知はリマインダーの設定時に選択中のアプリアイコンの色を使います。既存の通知は再設定時に更新されます。一部の端末では元のアプリアイコンが表示される場合があります。';

  @override
  String get appearanceSaveFailed => '外観を保存できませんでした。以前の設定に戻しました。';

  @override
  String mirrorOutPendingCleanup(int count) {
    return 'カレンダーの$count件の予定をまだ削除できていません。もう一度同期してください。';
  }

  @override
  String get weeklyReviewResume => '週次レビューを再開';

  @override
  String get weeklyReviewProgressSaved => '画面を離れても進捗は保存されます。';

  @override
  String get weeklyReviewSaveError => '進捗を保存できませんでした。もう一度お試しください。';

  @override
  String get weeklyReviewActionError => '変更を保存できませんでした。もう一度お試しください。';

  @override
  String get weeklyReviewListEmpty => 'ここにはレビューする項目がありません。';

  @override
  String get weeklyReviewProjectAwaiting => '待機中または予定済みの作業でプロジェクトが進んでいます。';

  @override
  String get weeklyReviewProjectMoving => '次のアクションを設定済み';

  @override
  String get weeklyReviewOpenProject => 'プロジェクトを開く';

  @override
  String get processTwoMinNo => 'いいえ — 整理を続ける';

  @override
  String get twoMinRule => '2分ルール：記録するより実行する方が早ければ、その場で実行しましょう。';

  @override
  String get delegateYes => 'はい — 任せて返答を待つ';

  @override
  String get delegateNo => 'いいえ — 自分で行う';

  @override
  String get singleStepQuestion => '具体的な行動は1つだけですか？';

  @override
  String get singleStepYes => 'はい — 1つの次の行動';

  @override
  String get singleStepProject => 'いいえ — プロジェクトです';

  @override
  String get projectRule => 'プロジェクトとは、複数の行動が必要で、1年以内に達成できる成果のことです。';

  @override
  String get deferQuestion => '決まった日や時間はありますか？';

  @override
  String get deferAsap => 'いいえ — できるだけ早く行う';

  @override
  String get deferCalendar => 'はい — カレンダーに入れる';

  @override
  String get deferChooseDate => '指定日まで延期する';

  @override
  String get processDetailsTitle => '詳細を追加';

  @override
  String get processFileNextAction => '次の行動として保存';

  @override
  String minutesShort(int minutes) {
    return '$minutes分';
  }

  @override
  String deferredUntilSummary(String date) {
    return '$dateまで延期';
  }

  @override
  String deferredRepeatingSummary(String date, String recurrence) {
    return '$dateまで延期 · 繰り返し：$recurrence';
  }

  @override
  String get recurrenceDaily => '毎日';

  @override
  String get recurrenceWeekly => '毎週';

  @override
  String get recurrenceMonthly => '毎月';

  @override
  String get recurrenceYearly => '毎年';

  @override
  String get createProject => '作成';

  @override
  String get projectPickerTitle => 'プロジェクトに移動';

  @override
  String get projectMoved => 'プロジェクトに移動しました。';

  @override
  String get projectDetached => 'プロジェクトから外しました。';

  @override
  String get noProject => 'プロジェクトなし';

  @override
  String get decreaseRepeatInterval => '繰り返し間隔を短くする';

  @override
  String get increaseRepeatInterval => '繰り返し間隔を長くする';

  @override
  String get decreaseRepeatCount => '繰り返し回数を減らす';

  @override
  String get increaseRepeatCount => '繰り返し回数を増やす';

  @override
  String get repeatOn => '繰り返す曜日';

  @override
  String get repeatMonthlyOn => '繰り返す日';

  @override
  String get repeatDayOfMonth => '日付で指定';

  @override
  String get repeatDayOfWeek => '曜日で指定';

  @override
  String get repeatFirst => '第1';

  @override
  String get repeatSecond => '第2';

  @override
  String get repeatThird => '第3';

  @override
  String get repeatFourth => '第4';

  @override
  String get repeatFifth => '第5';

  @override
  String get repeatLast => '最終';

  @override
  String get repeatEnds => '終了条件';

  @override
  String get repeatNever => '無期限';

  @override
  String get repeatOnDate => '日付を指定';

  @override
  String get repeatAfterCount => '回数を指定';

  @override
  String get weekdayListSeparator => '、';

  @override
  String get dueToday => '今日が期限';

  @override
  String get reschedule => '日程を変更';

  @override
  String get complete => '完了';

  @override
  String get drop => '取りやめる';

  @override
  String get trash => 'ゴミ箱';

  @override
  String itemEnergyLabel(String energy) {
    return 'エネルギー：$energy';
  }

  @override
  String waitingOnPerson(String person) {
    return '$personの対応待ち';
  }

  @override
  String dueOverdueDays(int days) {
    return '期限超過 · $days日';
  }

  @override
  String dueTodayAt(String time) {
    return '今日が期限、$time';
  }

  @override
  String selectItem(String title) {
    return '「$title」を選択';
  }

  @override
  String markItemDone(String title) {
    return '「$title」を完了にする';
  }

  @override
  String repeatLastOnDate(String date) {
    return '最終日：$date';
  }

  @override
  String repeatAfterOccurrences(int count) {
    return '$count回で終了';
  }

  @override
  String recurrenceUntilSummary(String pattern, String date) {
    return '$pattern · $dateまで';
  }

  @override
  String recurrenceCountSummary(String pattern, int count) {
    return '$pattern · $count回';
  }

  @override
  String recurrenceOnWeekdays(String cadence, String weekdays) {
    return '$cadenceの$weekdays';
  }

  @override
  String recurrenceOnNthWeekday(
    String cadence,
    String ordinal,
    String weekday,
  ) {
    String _temp0 = intl.Intl.selectLogic(ordinal, {
      'first': '第1',
      'second': '第2',
      'third': '第3',
      'fourth': '第4',
      'fifth': '第5',
      'other': '最終',
    });
    return '$cadenceの$_temp0$weekday';
  }

  @override
  String repeatEveryDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count日ごと',
      one: '毎日',
    );
    return '$_temp0';
  }

  @override
  String repeatEveryWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count週間ごと',
      one: '毎週',
    );
    return '$_temp0';
  }

  @override
  String repeatEveryMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countか月ごと',
      one: '毎月',
    );
    return '$_temp0';
  }

  @override
  String repeatEveryYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count年ごと',
      one: '毎年',
    );
    return '$_temp0';
  }

  @override
  String get captureAddContinue => '追加して続ける';

  @override
  String captureAddedCount(int count) {
    return '受信箱に$count件追加しました';
  }

  @override
  String get folderBackupChoose => 'バックアップフォルダを選択';

  @override
  String get folderBackupSaving => 'バックアップ中…';

  @override
  String get folderBackupOff => '自動バックアップはオフです。';

  @override
  String get folderBackupNever => 'まだバックアップが完了していません。';

  @override
  String folderBackupLastSuccess(String date) {
    return '最終バックアップ：$date';
  }

  @override
  String get folderBackupFailed =>
      'バックアップに失敗しました。フォルダへのアクセスと空き容量を確認し、再試行してください。';

  @override
  String get folderBackupHistoryWarning =>
      'バックアップを保存しましたが、古いバックアップを削除できませんでした。';

  @override
  String get folderBackupNow => '今すぐバックアップ';

  @override
  String get doViewToday => '今日';

  @override
  String get doViewNextActions => '次のアクション';

  @override
  String get todayPlanCardTitle => '今日の計画を立てる';

  @override
  String get todayPlanCardBody => '今日集中することを選びましょう。2分ほどで終わります。';

  @override
  String get todayPlanAction => '今日を計画';

  @override
  String todayCarryOverLine(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '以前の項目$count件について判断が必要です',
    );
    return '$_temp0';
  }

  @override
  String get todayFocusHeader => 'フォーカス';

  @override
  String todayDoneCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '今日$count件完了',
    );
    return '$_temp0';
  }

  @override
  String get todayEmptyTitle => 'まだ集中する項目がありません';

  @override
  String get todayEmptyMessage => '次のアクションに星を付けて今日やると決めるか、今日の計画を立てましょう。';

  @override
  String get focusAddTooltip => '今日に追加';

  @override
  String get focusRemoveTooltip => '今日から外す';

  @override
  String focusAddItem(String title) {
    return '$titleを今日に追加';
  }

  @override
  String focusRemoveItem(String title) {
    return '$titleを今日から外す';
  }

  @override
  String get focusError => '今日を更新できませんでした。もう一度お試しください。';

  @override
  String get planTodayIntro => '今日やると決めたものに星を付けましょう。少なめに。それ以外はリストに残ります。';

  @override
  String get planSectionCarryOver => '以前から';

  @override
  String get planCarryOverHint => '残さなかった項目は、1日を始めると元のリストに戻ります。';

  @override
  String get planKeepAll => 'すべて残す';

  @override
  String get planSectionCalendar => 'カレンダー';

  @override
  String get planOnToday => '今日に表示';

  @override
  String get planSectionWaiting => '待ち項目のフォローアップ';

  @override
  String get planSectionAvailable => '今日から着手可能';

  @override
  String get planEmpty => 'まだ計画するものがありません。インボックスを処理して次のアクションを作りましょう。';

  @override
  String planFocusedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '今日の集中: $count件',
      zero: 'まだ集中する項目がありません',
    );
    return '$_temp0';
  }

  @override
  String get planStartDay => '1日を始める';

  @override
  String get planDoneSnackbar => '今日の計画ができました';

  @override
  String planClearedSnackbar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '計画完了 · $count件をリストに戻しました',
    );
    return '$_temp0';
  }

  @override
  String get planSaveError => '計画を保存できませんでした。もう一度お試しください。';

  @override
  String get captureTipDates =>
      'ヒント: @コンテキスト、#プロジェクト、+タグ、または「tomorrow」のような英語の日付を追加できます。';

  @override
  String get captureTipSigils => 'ヒント: @コンテキスト、#プロジェクト、+タグを追加できます。';

  @override
  String startsOnDate(String date) {
    return '開始 $date';
  }

  @override
  String dueOnDate(String date) {
    return '期限 $date';
  }

  @override
  String captureChipProject(String name) {
    return 'プロジェクト: $name';
  }

  @override
  String get captureKeepAsText => 'テキストのままにする';

  @override
  String get captureRecognized => '認識された詳細';

  @override
  String deferUseStartDate(String date) {
    return '$dateから開始';
  }

  @override
  String deferUseDueDate(String date) {
    return '$dateにカレンダーへ';
  }

  @override
  String weeklyReviewProjectInactive(int days) {
    return '$days日以上動きなし';
  }

  @override
  String get weeklyReviewMarkReviewed => 'レビュー済みにする';

  @override
  String get weeklyReviewReviewed => 'レビュー済み';

  @override
  String weeklyReviewLastReviewed(String date) {
    return '最終レビュー $date';
  }

  @override
  String get weeklyReviewNeverReviewed => '未レビュー';

  @override
  String weeklyReviewReviewedProgress(int done, int total) {
    return '$total件中$done件レビュー済み';
  }

  @override
  String get importFromApp => '他のアプリから読み込む';

  @override
  String get importSourcePlainText => 'テキスト / TaskPaper';

  @override
  String get importHintTodoist =>
      'プロジェクトメニュー › テンプレートとしてエクスポート › CSV、または 設定 › バックアップ のZIP。';

  @override
  String get importHintTickTick =>
      'TickTick のウェブサイト：設定 › アカウント › バックアップとインポート › バックアップを生成（CSV）。';

  @override
  String get importHintNirvana =>
      'Nirvana のウェブアプリでデータを CSV または JSON でエクスポートします。';

  @override
  String get importHintOmniFocus =>
      'プロジェクトを選択し、編集 › TaskPaper としてコピー。ここに貼り付けるかファイルに保存します。';

  @override
  String get importHintPlainText =>
      'Things：To-Do をコピーし、1行に1タスクで貼り付けます。基本的なテキストのみ対応し、Things のデータベース書き出しには対応していません。';

  @override
  String get importChooseFile => 'ファイルを選択';

  @override
  String get importPasteText => 'テキストを貼り付け';

  @override
  String get importPasteTitle => 'タスクを貼り付け';

  @override
  String get importPasteHint => '1行に1タスク。「:」で終わる行の下にインデントするとプロジェクトになります。';

  @override
  String get importPasteContinue => 'プレビュー';

  @override
  String get importPreviewNothingYet => 'まだ何も追加されていません。';

  @override
  String get importPreviewProjects => 'プロジェクト';

  @override
  String get importProjectNew => '新規';

  @override
  String get importProjectExisting => '既存に追加';

  @override
  String importProjectActions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count件のアクション',
    );
    return '$_temp0';
  }

  @override
  String importContextsNew(String names) {
    return '新規：$names';
  }

  @override
  String importContextsExisting(String names) {
    return '既存：$names';
  }

  @override
  String get importGoodToKnow => '補足';

  @override
  String importWarnCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '完了・中止済みの$count件はスキップ',
    );
    return '$_temp0';
  }

  @override
  String importWarnCalendar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '期限付きのアクション$count件はカレンダーへ',
    );
    return '$_temp0';
  }

  @override
  String importWarnDates(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '読めない日付$count件はメモに保持',
    );
    return '$_temp0';
  }

  @override
  String importWarnRepeats(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '繰り返しルール$count件はメモに保持',
    );
    return '$_temp0';
  }

  @override
  String importWarnSubtasks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'サブタスク$count件は個別のアクションに',
    );
    return '$_temp0';
  }

  @override
  String importWarnSections(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count件のタスクはセクション名をメモに記載',
    );
    return '$_temp0';
  }

  @override
  String importWarnNotImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count件のタスクの優先度・フラグ・担当者は読み込まれません',
    );
    return '$_temp0';
  }

  @override
  String importWarnUnreadable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'タイトルのない$count行はスキップ',
    );
    return '$_temp0';
  }

  @override
  String importDoneTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count件のタスクを追加しました',
    );
    return '$_temp0';
  }

  @override
  String get importDoneBody => '気が変わったら、取り消すとこの読み込みで追加したものだけを削除します。';

  @override
  String get importUndo => '読み込みを取り消す';

  @override
  String get importFinish => '完了';

  @override
  String get importUndoneTitle => '読み込みを取り消しました';

  @override
  String get importUndoneBody => 'この読み込みで追加したものはすべて削除されました。';

  @override
  String get importRemindersFailed =>
      '一部のリマインダーはまだ設定できませんでした。次回アプリを開いたときに設定されます。';

  @override
  String importErrorUnrecognized(String source) {
    return '$source のエクスポートではないようです。手順を確認して、もう一度お試しください。';
  }

  @override
  String get importErrorNoTasks => '読み込める未完了タスクがありません。';

  @override
  String get importErrorUnreadable =>
      'このファイルは読み込めません。テキスト、CSV、ZIP のエクスポートを選んでください。';

  @override
  String get importErrorWrite => '読み込みに失敗しました。何も追加されていません。';

  @override
  String get importErrorUndo => '読み込みを取り消せませんでした。もう一度お試しください。';

  @override
  String get tagsAndPeopleLabel => 'タグと人';

  @override
  String get tagsEmptyMessage =>
      'タグはリストをまたいで項目に付けられます。タグを「人」にすると、その人と話すことのアジェンダを管理できます。ヒント: 記録時に +タグ と入力できます。';

  @override
  String get newTag => '新しいタグ';

  @override
  String get editTag => 'タグを編集';

  @override
  String get tagPersonSwitch => '人';

  @override
  String get tagPersonSwitchHint => '話すことのアジェンダを管理します';

  @override
  String tagOpenItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '未完了 $count 件',
      zero: '未完了の項目なし',
    );
    return '$_temp0';
  }

  @override
  String deleteTagConfirmTitle(String name) {
    return '「$name」を削除しますか？';
  }

  @override
  String deleteTagConfirmBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '未完了の $count 件が使っています。項目は残り、タグだけが外れます。',
      zero: 'このタグを使う未完了の項目はありません。',
    );
    return '$_temp0';
  }

  @override
  String get tagMergeTitle => 'タグを統合しますか？';

  @override
  String tagMergeBody(String source, String target) {
    return '「$target」はすでにあります。「$source」を統合しますか？';
  }

  @override
  String get tagMergeAction => '統合';

  @override
  String get addTag => 'タグを追加';

  @override
  String get tagPickerHint => 'タグを検索または作成';

  @override
  String tagCreate(String name) {
    return '「$name」を作成';
  }

  @override
  String tagCreatePerson(String name) {
    return '人「$name」を作成';
  }

  @override
  String get tagsSection => 'タグ';

  @override
  String tagChipSemantics(String name) {
    return 'タグ: $name';
  }

  @override
  String personChipSemantics(String name) {
    return '人: $name';
  }

  @override
  String removeTagTooltip(String name) {
    return '$name を外す';
  }

  @override
  String moreTags(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ほか $count 個のタグ',
    );
    return '$_temp0';
  }

  @override
  String get filterTag => 'タグ';

  @override
  String get filterAnyTag => 'すべてのタグ';

  @override
  String get agendasTitle => 'アジェンダ';

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
    return '$name と話すことを追加';
  }

  @override
  String get agendaAddTooltip => 'アジェンダに追加';

  @override
  String agendaEmpty(String name) {
    return '$name と話すことはまだありません。';
  }

  @override
  String get agendaNotFound => 'この人は存在しません。';

  @override
  String captureChipNewTag(String name) {
    return '新しいタグ: $name';
  }

  @override
  String get importHintGoogleTasks =>
      'Google Takeout › Tasks を選択 › JSON をエクスポート。ダウンロードを解凍して Tasks.json を選びます。リスト名はメモに保存され、完了したタスクは「完了」に入ります。';

  @override
  String get importDuplicateWarning =>
      '同じデータはこの端末ですでにインポートされています。再度インポートするとタスクが重複します。別のコピーが不要ならキャンセルしてください。';

  @override
  String get importHintThings =>
      'main.sqlite または Things 3 の書き出したデータベースフォルダの ZIP を選択します。iPhone/iPad：設定 › 一般 › 診断 › コードを入力 › 491348 › データベースを送信。「ファイル」に保存して .aar を展開し、フォルダを ZIP に圧縮してください。Mac ではコピー前に Things を終了してください。繰り返しと通知は再設定が必要です。';

  @override
  String importWarnDetailsInNotes(int count) {
    return '$count 件のタスクのチェックリストやエリア情報をメモに保持します';
  }

  @override
  String get importWarnThingsRecurrence =>
      'Things の繰り返し設定は読み込まれません。テンプレートはスキップされます。読み込んだタスクの繰り返しを再設定してください。';

  @override
  String importWarnSourceReminders(int count) {
    return '元の通知設定 $count 件は読み込まれません';
  }

  @override
  String get importAppleHint => 'このデバイスのリマインダーリストを選択します。未完了のリマインダーのみ取り込みます。';

  @override
  String get importAppleChooseLists => 'リストを選択';

  @override
  String get importAppleReloadLists => 'リストを再読み込み';

  @override
  String get importAppleNoLists => 'このデバイスに利用可能なリマインダーリストはありません。';

  @override
  String get importAppleDenied =>
      'リマインダーへのアクセスがオフです。iOSの設定でTrayzeroへのアクセスを許可し、もう一度お試しください。';

  @override
  String get importAppleUnavailable => 'Appleのリマインダーを読み込めませんでした。もう一度お試しください。';

  @override
  String get importAppleListsChanged =>
      '選択したリストが利用できなくなりました。リストを再読み込みして選び直してください。';

  @override
  String get importAppleLimits =>
      '元のAppleのリマインダーは変更されません。Appleのタグ、フラグ、添付ファイル、サブタスク構造、優先度、元の通知はコピーされません。再度取り込むとタスクが重複する場合があります。';

  @override
  String get importHintMicrosoftTodo =>
      'サインインしてリストと未完了のタスクをコピーします。取り込む前に確認してください。再度取り込むと重複する場合があります。';

  @override
  String get importMicrosoftUnavailable => 'このビルドでは Microsoft To Do から取り込めません。';

  @override
  String get importMicrosoftSignInError =>
      'Microsoft へのサインインに失敗したか、有効期限が切れました。もう一度サインインしてください。';

  @override
  String get importMicrosoftPermissionError =>
      'Microsoft がタスクへのアクセスを許可しませんでした。権限を確認するか、所属組織にお問い合わせください。';

  @override
  String get importMicrosoftNetworkError =>
      'Microsoft のすべてのタスクを読み込めませんでした。何も取り込まれていません。接続を確認して再試行してください。';

  @override
  String importWarnSourceDetails(int count) {
    return '$count 件のタスクに、取り込まれない添付ファイル、リマインダー設定、またはステータスがあります。';
  }

  @override
  String get moreGroupOrganize => '整理';

  @override
  String get moreGroupPreferences => '環境設定';

  @override
  String get moreGroupData => 'データ';

  @override
  String get moreOn => 'オン';

  @override
  String get moreOff => 'オフ';

  @override
  String moreAppearanceSummary(String theme, String palette) {
    return '$theme · $palette';
  }

  @override
  String get moreRemindersBlockedTitle => 'リマインダーがブロックされています';

  @override
  String get moreRemindersBlockedBody => '通知がオフのため、リマインダーでお知らせできません。';

  @override
  String get moreBackupFailedTitle => 'バックアップに失敗しました';

  @override
  String get moreBackupFailedBody => '自動バックアップを保存できませんでした。フォルダと空き容量を確認してください。';

  @override
  String get moreFix => '修正';

  @override
  String get moreBackupRestore => 'バックアップと復元';

  @override
  String get moreBackupSubtitleOff => '自動バックアップはオフです';

  @override
  String get moreBackupSubtitleFailed => 'バックアップに失敗しました';

  @override
  String get moreImportSources => 'Todoist、TickTick、OmniFocus など';

  @override
  String get moreSupportTrailing => '任意';

  @override
  String get moreSupportTrailingSupporter => 'サポーター';

  @override
  String get moreAboutPrivacy => '情報とプライバシー';

  @override
  String get moreHowGtdWorks => 'GTDの仕組み';

  @override
  String get moreNudgesGroup => 'お知らせ';

  @override
  String get moreTimingGroup => 'タイミング';

  @override
  String get moreLeadOff => 'オフ';

  @override
  String get moreLead10 => '10分前';

  @override
  String get moreLead30 => '30分前';

  @override
  String get moreLead60 => '1時間前';

  @override
  String get moreLead1440 => '1日前';

  @override
  String moreLeadOther(int minutes) {
    return '$minutes分前';
  }

  @override
  String moreRestoredEntries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count件',
    );
    return '$_temp0を復元しました。';
  }

  @override
  String get moreBackupEmpty => 'このバックアップには復元できる項目がありません。';

  @override
  String get moreCouldntOpenLink => 'リンクを開けませんでした';

  @override
  String moreVersionBuild(String version, String build) {
    return '$version（ビルド $build）';
  }

  @override
  String get supportBestValue => 'いちばんお得';

  @override
  String get importListIntro => 'いまタスクがある場所を選んでください。追加する前にプレビューを確認できます。';

  @override
  String get importGroupDirect => '直接接続';

  @override
  String get importGroupFile => 'エクスポートファイルから';

  @override
  String get importGroupOther => 'その他';

  @override
  String get importSubGoogleTasks => 'Takeout · Tasks.json';

  @override
  String get importSubTodoist => 'CSVテンプレートまたはバックアップZIP';

  @override
  String get importSubThings => 'データベースZIPまたはmain.sqlite';

  @override
  String get importSubTickTick => 'バックアップCSV';

  @override
  String get importSubNirvana => 'CSVまたはJSONのエクスポート';

  @override
  String get importSubOmniFocus => 'TaskPaperファイルまたは貼り付け';

  @override
  String get importSubPlainText => 'リストを貼り付け（1行に1タスク）';

  @override
  String get importSubApple => 'このデバイスのリストを選択';

  @override
  String get importSubMicrosoft => 'リストと未完了タスク';

  @override
  String get importChipOnDevice => '端末内';

  @override
  String get importChipSignIn => 'サインイン';

  @override
  String get importBackupFooter => 'Trayzeroのバックアップを復元しますか？';

  @override
  String get importBackupFooterLink => 'バックアップと復元';

  @override
  String get importThingsDeviceIos => 'iPhone / iPad';

  @override
  String get importThingsDeviceMac => 'Mac';

  @override
  String get importCopyCode => 'コードをコピー';

  @override
  String get importCodeCopied => 'コードをコピーしました';

  @override
  String get importConnect => '接続';

  @override
  String get importStepGoogleTasks1 => 'Google Takeoutを開き、Tasksだけを選択します。';

  @override
  String get importStepGoogleTasks2 => 'JSON形式でエクスポートし、ダウンロードしたファイルを展開します。';

  @override
  String get importStepGoogleTasks3 => '下でTasks.jsonを選択します。';

  @override
  String get importNoteGoogleTasks => 'リストはメモに残り、完了したタスクは「完了」に入ります。';

  @override
  String get importStepTodoist1 =>
      'プロジェクトのメニューを開き、「テンプレートとしてエクスポート」(CSV)を選びます。';

  @override
  String get importStepTodoist2 => 'または「設定 › バックアップ」からバックアップZIPを保存します。';

  @override
  String get importStepTodoist3 => '下でファイルを選択します。';

  @override
  String get importStepTickTick1 => 'TickTickのWebサイトで「設定 › アカウント」を開きます。';

  @override
  String get importStepTickTick2 =>
      '「バックアップとインポート」を開き、「バックアップを生成」(CSV)をタップします。';

  @override
  String get importStepTickTick3 => '下でCSVを選択します。';

  @override
  String get importStepNirvana1 => 'NirvanaのWebアプリでデータをCSVまたはJSONでエクスポートします。';

  @override
  String get importStepNirvana2 => '下でファイルを選択します。';

  @override
  String get importStepOmniFocus1 => 'OmniFocusでプロジェクトを選択します。';

  @override
  String get importStepOmniFocus2 => '「編集 › TaskPaperとしてコピー」を選びます。';

  @override
  String get importStepOmniFocus3 => '下に貼り付けるか、ファイルとして保存して選択します。';

  @override
  String get importStepPlainText1 => 'どのアプリからでもタスクをコピーします（1行に1タスク）。';

  @override
  String get importStepPlainText2 => '下の「テキストを貼り付け」をタップして貼り付けます。';

  @override
  String get importNotePlainText =>
      '基本的なテキスト取り込みのみ。他アプリのデータベースエクスポートには対応していません。';

  @override
  String get importStepApple1 => '下の「リストを選択」をタップします。';

  @override
  String get importStepApple2 => '求められたら、リマインダーへのアクセスを許可します。';

  @override
  String get importStepApple3 => '取り込みたいリストにチェックを付けます。';

  @override
  String get importNoteApple => '未完了のリマインダーのみ取り込みます。Appleのリマインダーは変更されません。';

  @override
  String get importStepMicrosoft1 => '「接続」をタップしてMicrosoftにサインインします。';

  @override
  String get importStepMicrosoft2 => 'Trayzeroがリストと未完了タスクをコピーします。';

  @override
  String get importStepMicrosoft3 => '取り込む前にプレビューを確認します。';

  @override
  String get importNoteMicrosoft => 'もう一度取り込むと重複する場合があります。';

  @override
  String get importStepThingsIos1 =>
      'Thingsで「設定 › 一般 › 診断 › コードを入力」を開き、次を入力します：';

  @override
  String get importStepThingsIos2 => '「Thingsデータベースを送信」をタップし、「ファイル」に保存します。';

  @override
  String get importStepThingsIos3 => '「ファイル」で.aarを展開し、データベースのフォルダをZIPに圧縮します。';

  @override
  String get importStepThingsIos4 => '下でそのZIPを選択します。';

  @override
  String get importStepThingsMac1 => 'MacでThingsを終了します。';

  @override
  String get importStepThingsMac2 =>
      'ThingsのフォルダからThings Database.thingsdatabaseをコピーし、そのコピーをZIPに圧縮します。';

  @override
  String get importStepThingsMac3 => 'ZIP（またはmain.sqlite）をこのデバイスに移し、下で選択します。';

  @override
  String get importNoteThings => '繰り返しとリマインダーは引き継がれません。取り込んだあとに作り直してください。';

  @override
  String get importReviewTitle => 'インポートの確認';

  @override
  String importFromSource(String source) {
    return '$sourceから';
  }

  @override
  String importTotalTasks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count件のタスク',
    );
    return '$_temp0';
  }

  @override
  String importActionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count件のタスクをインポート',
    );
    return '$_temp0';
  }

  @override
  String importNewExistingSummary(int newCount, int existingCount) {
    return '新規$newCount件・既存$existingCount件';
  }

  @override
  String importShowAll(int count) {
    return '$count件すべて表示';
  }

  @override
  String get importContextsAndTags => 'コンテキストとタグ';

  @override
  String importNotesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count件のメモ',
    );
    return '$_temp0';
  }

  @override
  String get notificationStatusOnTitle => 'リマインダーはオン';

  @override
  String get notificationStatusOnBody => 'リマインダーはこの端末でお知らせします。';

  @override
  String get notificationStatusOffTitle => 'リマインダーはオフ';

  @override
  String get notificationStatusOffBody => 'リマインダーは設定されていますが、通知を許可するまでお知らせしません。';

  @override
  String get notificationStatusBlockedTitle => 'リマインダーはブロック中';

  @override
  String get notificationStatusBlockedBody =>
      'システム設定でTrayzeroの通知がオフになっています。そこでオンに戻すまで、リマインダーはお知らせしません。';

  @override
  String get notificationActionEnable => '通知を有効にする';

  @override
  String get notificationActionOpenSettings => '設定を開く';

  @override
  String get notificationPrimerTitle => 'リマインダーをオンにしますか？';

  @override
  String get notificationPrimerBody =>
      'Trayzeroは、この端末に通知を表示して、期限日や週次レビューをお知らせします。サーバーには何も送信されず、リマインダーは端末内で設定されます。\n\n次に、端末が通知の表示を許可するか確認します。';

  @override
  String get notificationPrimerNotNow => '今はしない';

  @override
  String get notificationPrimerContinue => '続ける';

  @override
  String get notificationPromptFailed => '通知の確認画面を開けませんでした。';

  @override
  String get notificationAlreadyOn => 'リマインダーはすでにオンです。';

  @override
  String get notificationOpenedSettings =>
      'システム設定を開きました。Trayzeroの通知をオンにしてください。';

  @override
  String get notificationStayOff =>
      'リマインダーはオフのままです。「その他」→「リマインダー」からいつでも有効にできます。';

  @override
  String get notificationNowOn => 'リマインダーをオンにしました。';

  @override
  String get notificationBlocked => 'Trayzeroの通知はブロックされています。';

  @override
  String get exactAlarmSettingsFailed => '正確なアラームの設定を開けませんでした。';

  @override
  String get exactAlarmAlreadyOn => '正確なリマインダー時刻はすでにオンです。';

  @override
  String get exactAlarmNowOn => '正確なリマインダー時刻をオンにしました。';

  @override
  String get exactAlarmStaysOff =>
      '正確なリマインダー時刻はオフのままです。短い間隔のリマインダーは遅れることがあります。';

  @override
  String get attachmentRemoved => '添付ファイルを削除しました。';

  @override
  String get discardCaptureTitle => 'このキャプチャを破棄しますか？';

  @override
  String get discardCaptureBody => '入力した内容は失われます。';

  @override
  String get keepEditing => '編集を続ける';

  @override
  String get discard => '破棄';

  @override
  String get processFiledSnackbar => '整理しました。';

  @override
  String get errorLoadTitle => '読み込めませんでした';

  @override
  String get errorLoadBody => 'データは安全です。もう一度お試しください。';

  @override
  String sharedAddedToInbox(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count件を受信箱に追加しました',
    );
    return '$_temp0';
  }

  @override
  String get filterByProject => 'プロジェクトで絞り込み';

  @override
  String get projectStatusActive => '進行中';

  @override
  String get projectStatusOnHold => '保留中';

  @override
  String get projectStatusSomeday => 'いつか';

  @override
  String get projectStatusDone => '完了';

  @override
  String get projectStatusDropped => '中止';

  @override
  String get projectChangeStatus => 'ステータスを変更';

  @override
  String get projectAwaitingTooltip => '待機中：待ち・予定の項目で進行しています';

  @override
  String get projectStalledTooltip => '停滞中：次のアクション・待ち・予定の項目がありません';

  @override
  String get projectStalledBanner =>
      '停滞中：次のアクション・待ち・予定の項目がありません。次のアクションを追加して動かしましょう。';

  @override
  String get projectAwaitingBanner =>
      'このプロジェクトは待ち・予定の項目だけで進んでいます。それらが片付いても止まらないよう、フォローアップの次のアクションを追加しましょう。';

  @override
  String projectNextActionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '次のアクション $count 件',
    );
    return '$_temp0';
  }

  @override
  String projectWaitingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '待ち $count 件',
    );
    return '$_temp0';
  }

  @override
  String engageHiddenByFilters(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'フィルターにより次のアクション $count 件が非表示です',
    );
    return '$_temp0';
  }

  @override
  String get filterReset => 'リセット';

  @override
  String onboardingSeedExisting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'すでに $count 件のプロジェクトがあります。',
    );
    return '$_temp0';
  }

  @override
  String get purchaseErrUnavailable => '現在、購入はご利用いただけません。';

  @override
  String get purchaseErrProducts => '商品を読み込めませんでした。接続を確認して、もう一度お試しください。';

  @override
  String get purchaseErrOption => 'この選択肢は現在ご利用いただけません。';

  @override
  String get purchaseErrNetwork => 'ネットワークエラーです。接続を確認して、もう一度お試しください。';

  @override
  String get purchaseErrNotAllowed => 'このデバイスでは購入が許可されていません。';

  @override
  String get purchaseErrPending => '購入は承認待ちです。';

  @override
  String get purchaseErrAlreadyOwned => 'すでに購入済みです。「購入を復元」をお試しください。';

  @override
  String get purchaseErrStore => 'ストアに問題が発生しています。しばらくしてからもう一度お試しください。';

  @override
  String get purchaseErrUnknown => '購入中に問題が発生しました。もう一度お試しください。';

  @override
  String get backupErrEmpty => 'バックアップが空のため、読み込むものがありません。';

  @override
  String get backupErrInvalidJson =>
      '有効な JSON ではありません。完全で未編集の Trayzero バックアップファイルを選択したか確認してください。';

  @override
  String get backupErrNotBackup => 'このファイルは Trayzero のバックアップではありません。';

  @override
  String get backupErrNewerVersion =>
      'このバックアップは新しいバージョンのアプリで作成されました。Trayzero を更新してから、もう一度読み込んでください。';

  @override
  String get backupErrUnrecognized => 'このファイルは Trayzero のバックアップではないようです。';

  @override
  String get backupErrInvalidData => 'このバックアップには無効なデータが含まれているため、読み込めません。';

  @override
  String get backupErrReminders =>
      'データは復元されましたが、一部のリマインダーを更新できませんでした。もう一度読み込むと更新されます。';

  @override
  String get backupErrRestoreFailed => '復元中に問題が発生しました。今回の操作で既存のデータは変更されていません。';

  @override
  String backupCountItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '項目 $count 件',
    );
    return '$_temp0';
  }

  @override
  String backupCountProjects(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'プロジェクト $count 件',
    );
    return '$_temp0';
  }

  @override
  String backupCountContexts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'コンテキスト $count 件',
    );
    return '$_temp0';
  }

  @override
  String backupCountAreas(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'エリア $count 件',
    );
    return '$_temp0';
  }

  @override
  String backupCountAttachments(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '添付ファイル $count 件',
    );
    return '$_temp0';
  }

  @override
  String backupCountReviews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'レビュー $count 件',
    );
    return '$_temp0';
  }

  @override
  String get restoreFolderTitle => 'バックアップフォルダから復元';

  @override
  String get restoreFolderIntro =>
      'Trayzero がバックアップを保存するフォルダ（iCloud Drive、Google Drive、Syncthing などで管理しているフォルダなど）を選んでください。復元ではバックアップがこの端末のデータに統合され、すでにあるデータは削除されません。';

  @override
  String get restoreFolderChoose => 'バックアップフォルダを選択';

  @override
  String get restoreFolderChange => '別のフォルダを選択';

  @override
  String restoreFolderFrom(String name) {
    return 'フォルダ：$name';
  }

  @override
  String get restoreFolderEmpty => 'このフォルダには Trayzero のバックアップがありません。';

  @override
  String get restoreFolderFailed =>
      'このフォルダを開けませんでした。まだ利用できるか確認するか、もう一度選択してください。';

  @override
  String restoreFolderItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count件',
    );
    return '$_temp0';
  }

  @override
  String get restoreFolderUnreadable => 'このファイルを読み込めません';

  @override
  String get restoreFolderReading => '読み込み中…';

  @override
  String get onboardingRestoreAction => '別の端末から移行しますか？バックアップを復元';

  @override
  String folderBackupStale(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days日',
    );
    return '$_temp0間、新しいバックアップがありません。';
  }

  @override
  String get folderBackupRepairHint => 'バックアップが動作しなくなった場合は、フォルダをもう一度選択してください。';

  @override
  String moreBackupSubtitleStale(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days日',
    );
    return '$_temp0間、新しいバックアップがありません · タップして修復';
  }

  @override
  String get backupPromptTitle => 'タスクを自動でバックアップ';

  @override
  String get backupPromptBody =>
      'たくさん記録しましたね。お使いのクラウドや同期アプリ内のフォルダを選ぶと、Trayzero が最新の10件のバックアップをそこに保存します。同期ではなくバックアップです。';

  @override
  String get backupPromptAction => 'フォルダを選択';

  @override
  String get backupPromptDismiss => '今はしない';

  @override
  String backupCardHealthy(String date) {
    return '$dateにバックアップ済み';
  }

  @override
  String get backupCardOffBody => 'オンにすると、変更のたびにフォルダへコピーを保存します。';

  @override
  String get backupCardTurnOn => 'オンにする';

  @override
  String get backupCardChooseAgain => 'フォルダを選び直す';

  @override
  String get backupCardTryAgain => '再試行';

  @override
  String get backupGroupBackUp => 'バックアップ';

  @override
  String get backupGroupRestore => '復元';

  @override
  String get backupAutoTitle => '自動でバックアップ';

  @override
  String get backupAutoSubtitle => '変更のたびに';

  @override
  String get backupFolderTitle => 'バックアップフォルダ';

  @override
  String get backupExportTitle => 'コピーを書き出し';

  @override
  String get backupExportSubtitle => 'バックアップファイルを一度だけ共有';

  @override
  String get backupRestoreTitle => 'バックアップを復元';

  @override
  String get backupRestoreRowSubtitle => 'フォルダまたはファイルから';

  @override
  String get backupRestoreSheetBody => 'バックアップの場所を選びます。変更される前に、中身を確認できます。';

  @override
  String get backupRestoreFromFolder => 'バックアップフォルダから';

  @override
  String get backupRestoreFromFolderHint => 'おすすめ — 保存済みのバックアップを選択';

  @override
  String get backupRestoreFromFile => 'ファイルから';

  @override
  String get backupRestoreFromFileHint => 'Trayzeroのバックアップ(.json)';

  @override
  String get backupRestorePaste => 'バックアップのテキストを貼り付け';

  @override
  String get backupFootnote =>
      'これは同期ではなくバックアップです。デバイス間のフォルダの受け渡しは、お使いのクラウドや同期アプリが行います。';

  @override
  String get backupCardJustNow => 'たった今バックアップ済み';

  @override
  String backupCardMinutesAgo(int minutes) {
    return '$minutes分前にバックアップ済み';
  }

  @override
  String backupCardHoursAgo(int hours) {
    return '$hours時間前にバックアップ済み';
  }

  @override
  String get backupCardYesterday => '昨日バックアップ済み';

  @override
  String get backupHowItWorks => 'しくみ';

  @override
  String get backupHowTitle => 'バックアップのしくみ';

  @override
  String get backupHowSaves =>
      '変更を加えるたびに、Trayzero は選んだフォルダにデータの JSON コピーを保存し、最新の 10 件を保持します。';

  @override
  String get backupHowSync =>
      'iCloud Drive、Google ドライブ、Syncthing などのクラウドや同期アプリが、そのフォルダを他の端末へ運びます。Trayzero 自体は何もアップロードも同期もしません。';

  @override
  String get backupHowMove => '別の端末へ移行するには、「バックアップを復元」から「バックアップフォルダから」を選びます。';

  @override
  String get microphoneAccessDenied =>
      'マイクへのアクセスがオフです。ボイスメモを録音するには、設定で許可してください。';

  @override
  String get filterTimeEnergy => '時間とエネルギー';

  @override
  String get clearDate => '日付をクリア';

  @override
  String get reorderHandle => 'ドラッグして並べ替え';

  @override
  String get calendarConnectionTitle => 'カレンダー接続';

  @override
  String get calendarTogether => '予定をひとつの場所に。';

  @override
  String get calendarConnectionIntro => 'Trayzero の予定を、その日のほかの予定と一緒に確認できます。';

  @override
  String get calendarConnect => 'カレンダーを接続';

  @override
  String get calendarScope =>
      'Trayzero のカレンダーで日付を設定した項目だけを公開します。通常のタスクの期限は Trayzero 内に残ります。';

  @override
  String get calendarAutomatic => '自動更新';

  @override
  String get calendarAutomaticHelp => 'Trayzero の使用中と、アプリを再び開いたときに更新します。';

  @override
  String get calendarPaused => '一時停止中';

  @override
  String get calendarConnected => '接続済み';

  @override
  String get calendarNeedsAttention => '対応が必要です';

  @override
  String get calendarPauseHelp => '既存の予定は残ります。変更は、更新を再開するか「今すぐ更新」を選ぶまで保留されます。';

  @override
  String calendarLinkedCount(int count) {
    return 'リンク済みの予定：$count 件';
  }

  @override
  String calendarLastUpdated(String when) {
    return '最終更新：$when';
  }

  @override
  String get calendarChangesWaiting => '更新待ちの変更があります';

  @override
  String get calendarUpdateNow => '今すぐ更新';

  @override
  String get calendarManage => '接続を管理';

  @override
  String get calendarWorking => 'カレンダー接続を更新中…';

  @override
  String get calendarRestoreAccess => 'アクセスを復元';

  @override
  String get calendarUpdateFailed =>
      '一部の変更を反映できませんでした。上に前回成功した更新時刻を表示しています。もう一度お試しください。';

  @override
  String get calendarRemovalPending => '削除待ち';

  @override
  String calendarRemoveFailed(int count) {
    return '$count 件の予定を削除できませんでした。自動更新は停止しています。削除を再試行するか、残りの予定を保持して接続を解除してください。';
  }

  @override
  String get calendarSaveFailed => '変更を保存できませんでした。接続設定を確認して、もう一度お試しください。';

  @override
  String get calendarNoWritable =>
      '書き込み可能なカレンダーがありません。端末のカレンダー設定で追加してから、もう一度お試しください。';

  @override
  String get calendarChangeDestination => '接続先を変更';

  @override
  String get calendarChooseDestination => 'カレンダーを選択';

  @override
  String get calendarMoveHelp =>
      'リンク済みの予定を新しいカレンダーに移動します。ほかの予定はそのまま残ります。自動更新の現在の設定は維持されます。';

  @override
  String calendarSetupCount(int count) {
    return '日付設定済みの $count 件を公開します。以前のリンクが利用できる場合は再利用します。';
  }

  @override
  String get calendarMoveEvents => 'リンク済みの予定を移動';

  @override
  String get calendarConnectAndAdd => '接続して予定を追加';

  @override
  String get calendarDisconnect => 'カレンダーの接続を解除';

  @override
  String get calendarDisconnectQuestion => 'カレンダーの接続を解除しますか？';

  @override
  String get calendarDisconnectHelp =>
      'リンク済みの予定をどうするか選んでください。Trayzero の項目と、ほかの予定は残ります。';

  @override
  String get calendarKeepEvents => 'カレンダーに予定を残す';

  @override
  String get calendarKeepHelp => '更新を停止し、予定を残します。再接続時にリンクを再利用できます。';

  @override
  String calendarRemoveEvents(int count) {
    return 'リンク済みの $count 件を削除';
  }

  @override
  String get calendarRemoveHelp => 'この接続にリンクした予定だけを削除します。削除に失敗した予定は再試行できます。';

  @override
  String get calendarHowItWorks => 'リンク済みの予定の仕組み';

  @override
  String get calendarRules =>
      'Trayzero は日付設定済みのカレンダー項目を端末の選択したカレンダーに公開します。通常のタスクの期限は対象外です。\n\nタイトル、メモ、時刻、繰り返しは Trayzero で編集してください。更新時にカレンダーアプリでの編集が上書きされる場合があります。予定の長さは現在 1 時間です。\n\n項目を完了、ごみ箱へ移動、またはカレンダーから移動すると、次の更新でリンクした予定を削除します。繰り返しは次の回に進みます。\n\n一時停止すると予定とリンクが残ります。接続解除時はリンクした予定を残すか削除するか選べます。Trayzero の項目は削除されません。';

  @override
  String get calendarBringEvents => '予定を Trayzero に取り込む';

  @override
  String get calendarImportCopies =>
      '受信箱またはカレンダーにコピーする予定を選びます。コピーは元の予定の変更には追従しません。元の予定は変更しません。';

  @override
  String get calendarChooseEvents => '予定を選択';

  @override
  String get calendarImportSource => '取り込み元のカレンダーを選択';

  @override
  String get calendarImportDestination => '選択した予定の追加先';

  @override
  String calendarAddSelected(int count) {
    return '$count 件の予定を追加';
  }

  @override
  String get calendarNoImportEvents =>
      '取り込める新しい予定がありません。追加済みや Trayzero にリンク済みの予定は除外されます。範囲は過去 7 日から今後 1 年です。';

  @override
  String get calendarImportFailed =>
      '予定を取り込めませんでした。カレンダーへのアクセスを確認して、もう一度お試しください。';

  @override
  String get calendarDeviceHelp =>
      '端末のカレンダーを使用します。Trayzero アカウントは不要です。共有カレンダーの予定は、アクセス権のあるほかの人にも表示される場合があります。';
}
