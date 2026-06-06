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
  String get edit => '編集';

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
  String get rename => '名前を変更';

  @override
  String get inbox => '受信箱';

  @override
  String get doVerb => '実行';

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
  String get actionableQuestion => 'これは行動できますか？';

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
  String get twoMinNo => 'いいえ';

  @override
  String get delegateQuestion => '誰かに任せられますか？';

  @override
  String get waitingOnPromptTitle => '誰の連絡待ちですか？';

  @override
  String get waitingOnPromptHint => '名前またはシステム';

  @override
  String get multiStepQuestion => '複数のステップが必要ですか？';

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
  String get engageNoMatchMessage =>
      '現在のフィルター条件に合う行動がありません。条件を広げるかフィルターを解除してください。';

  @override
  String get hardLandscape => '確定の予定';

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
  String projectActionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 件の行動',
    );
    return '$_temp0';
  }

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
  String get projectMissingNextActionError =>
      '次の行動が未設定です。進行中のプロジェクトには少なくとも一つの次の行動が必要です。';

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
      '各プロジェクトは進行中・保留中・完了のいずれかであるべきです。進行中のプロジェクトには必ず次の行動が一つ以上必要です。';

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
  String get themeFollowSystem => 'システムに従う';

  @override
  String get themeLight => 'ライト';

  @override
  String get themeDark => 'ダーク';

  @override
  String get hapticFeedback => '触覚フィードバック';

  @override
  String get organizationSection => '整理';

  @override
  String get contextsLabel => '状況';

  @override
  String get areasOfFocusLabel => '関心領域';

  @override
  String get areasOfFocusDescription => '継続的な責任分野ごとにプロジェクトをまとめます。';

  @override
  String get calendarSyncLabel => 'カレンダー同期';

  @override
  String get calendarSyncDescription => '期限のある項目をシステムカレンダーに反映します。';

  @override
  String get remindersSection => 'リマインダー';

  @override
  String get weeklyReviewNudge => '週次レビューのお知らせ';

  @override
  String get weeklyReviewNudgeDescription => '毎週金曜の16時にやさしくお知らせします。';

  @override
  String get remindBeforeDue => '期限の前にリマインドする';

  @override
  String get remindBeforeDueOff => 'オフ・期限時刻にのみ通知';

  @override
  String get remindBeforeDueSuffix => '以降に保存する項目に適用されます';

  @override
  String get deferSurfaceLabel => '保留中の項目を通知する時刻';

  @override
  String get deferSurfaceDescription => '時刻指定のない保留項目は一日中リストに表示され、この時刻に通知します';

  @override
  String get checkingNotificationStatus => '通知ステータスを確認中…';

  @override
  String get dataSection => 'データ';

  @override
  String get exportBackup => 'バックアップを書き出し';

  @override
  String get exportBackupDescriptionIos =>
      'JSON形式でコピーを共有します。クラウドドライブ（例：ファイル → iCloud Drive）に保存しておくと安心です。';

  @override
  String get exportBackupDescriptionAndroid =>
      'JSON形式でコピーを共有します。クラウドドライブ（例：Google Drive）に保存しておくと安心です。';

  @override
  String exportBackupError(String error) {
    return '書き出しに失敗しました：$error';
  }

  @override
  String get weeklyBackupReminder => '毎週バックアップを促す';

  @override
  String get weeklyBackupReminderDescription => '毎週日曜の朝に、書き出して保存するようお知らせします。';

  @override
  String get importBackup => 'バックアップを読み込み';

  @override
  String get importBackupDescription =>
      'Trayzeroのバックアップを復元、またはGoogleタスク（Takeout）のエクスポートを取り込みます。';

  @override
  String get importConfirmTitle => 'このバックアップを読み込みますか？';

  @override
  String importConfirmBody(String sections) {
    return '$sections が追加または更新されます。\n\n同じIDの既存データはバックアップの内容で上書きされます。この操作は取り消せません。';
  }

  @override
  String get importButton => '読み込み';

  @override
  String get importSourceSheetTitle => 'バックアップを読み込み';

  @override
  String get importFromFileTitle => 'バックアップファイルを選ぶ';

  @override
  String get importFromFileDescription =>
      'おすすめ——Trayzeroの.jsonバックアップ、またはGoogle TakeoutのTasks.json。';

  @override
  String get importFromPasteTitle => 'バックアップJSONを貼り付け';

  @override
  String get importFromPasteDescription => '代わりにバックアップのテキストを貼り付けます。';

  @override
  String get pasteBackupHint => 'バックアップJSONを貼り付け…';

  @override
  String get privacySection => 'プライバシー';

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
  String get aboutSection => 'このアプリについて';

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
  String get decisionNotActionableQ => '行動できない？';

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
  String get supportSummaryDefault => '開発者にチップを贈る、またはサポーターになる';

  @override
  String get supportSummarySupporter => 'Trayzero を応援してくれてありがとう 💙';

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
    return '$price / 年 · 一番お得 · サポーター特典をアンロック';
  }

  @override
  String get supportSupporterMonthly => 'サポーター — 月額';

  @override
  String supportSupporterMonthlySubtitle(String price) {
    return '$price / 月 · いつでも解約可能';
  }

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
}
