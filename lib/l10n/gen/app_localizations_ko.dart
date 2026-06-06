// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appName => 'Trayzero';

  @override
  String get cancel => '취소';

  @override
  String get save => '저장';

  @override
  String get delete => '삭제';

  @override
  String get edit => '편집';

  @override
  String get add => '추가';

  @override
  String get ok => '확인';

  @override
  String get next => '다음';

  @override
  String get back => '뒤로';

  @override
  String get skip => '건너뛰기';

  @override
  String get done => '완료';

  @override
  String get retry => '다시 시도';

  @override
  String get settings => '설정';

  @override
  String get enable => '사용';

  @override
  String get none => '없음';

  @override
  String get notSet => '설정 안 됨';

  @override
  String get search => '검색';

  @override
  String get select => '선택';

  @override
  String get selectAll => '전체 선택';

  @override
  String get selectNone => '선택 해제';

  @override
  String get rename => '이름 변경';

  @override
  String get inbox => '받은편지함';

  @override
  String get doVerb => '실행';

  @override
  String get projects => '프로젝트';

  @override
  String get review => '검토';

  @override
  String get more => '더보기';

  @override
  String get navInbox => '받은편지함';

  @override
  String get navDo => '실행';

  @override
  String get navProjects => '프로젝트';

  @override
  String get navReview => '검토';

  @override
  String get navMore => '더보기';

  @override
  String get capture => '수집';

  @override
  String get clarify => '처리';

  @override
  String get organize => '정리';

  @override
  String get reflect => '검토';

  @override
  String get engage => '실행';

  @override
  String get nextAction => '다음 행동';

  @override
  String get waitingFor => '대기 중';

  @override
  String get someday => '언젠가';

  @override
  String get somedayMaybe => '언젠가 / 어쩌면';

  @override
  String get reference => '참고 자료';

  @override
  String get calendar => '캘린더';

  @override
  String get project => '프로젝트';

  @override
  String get completed => '완료됨';

  @override
  String get scheduled => '예정';

  @override
  String get needsClarifying => '처리 필요';

  @override
  String get howGtdWorks => 'GTD 작동 방식';

  @override
  String get whatIsGtd => 'GTD란?';

  @override
  String get onboardingPage1Title => '머릿속에서 꺼내세요';

  @override
  String get onboardingPage1Body =>
      '신경 쓰이는 모든 것 — 할 일, 아이디어, 걱정 — 을 받은편지함에 넣으세요. 일단은 머리를 비우는 게 목적이에요. 정리는 나중에 해도 돼요.';

  @override
  String get onboardingPage2Title => '하나씩 처리해 보세요';

  @override
  String get onboardingPage2Body =>
      '처리 흐름이 수집된 항목을 하나씩 GTD 결정 트리로 안내해요. 실행할 수 있는 일인가? 2분 안에 끝나는가? 위임할 일인가? 프로젝트인가? 다음 행동은 무엇인가?';

  @override
  String get onboardingPage3Title => '시간이 날 때 실행하세요';

  @override
  String get onboardingPage3Body =>
      '실행 탭은 컨텍스트, 에너지, 가용 시간에 따라 다음 행동을 걸러내요. 지금 무엇을 할 수 있는지 한눈에 보여요.';

  @override
  String get onboardingPage4Title => '검토로 신뢰를 유지하세요';

  @override
  String get onboardingPage4Body =>
      '주간 검토가 시스템을 정직하게 유지해요. 일주일에 한 번, 모든 목록을 훑고 받은편지함을 비우고 앞을 내다보세요.';

  @override
  String get onboardingSeedTitle => '준비 완료';

  @override
  String get onboardingSeedBody =>
      '기본 컨텍스트(@phone, @computer, @errands, @home, @office, @anywhere, @waiting)가 미리 들어 있어요. 설정에서 추가하거나 수정할 수 있어요.';

  @override
  String get onboardingSeedSampleLabel => '샘플 프로젝트 만들기';

  @override
  String get onboardingSeedSampleSubtitle =>
      '시작용 프로젝트와 몇 가지 항목을 추가해 앱이 비어 보이지 않게 해요.';

  @override
  String get onboardingFinish => '시작하기';

  @override
  String get inboxEmptyTitle => '인박스 제로';

  @override
  String get inboxEmptyMessage =>
      '처리할 항목이 없어요. 수집을 눌러 신경 쓰이는 것을 머릿속에서 쏟아내 보세요 — 나중에 처리하면 돼요.';

  @override
  String get inboxEmptyAction => '지금 수집하기';

  @override
  String inboxItemsToClarify(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '처리할 항목 $count개',
      zero: '처리할 항목 없음',
    );
    return '$_temp0';
  }

  @override
  String get processInbox => '받은편지함 처리';

  @override
  String deleteItemsConfirmTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '항목 $count개를 삭제할까요?',
    );
    return '$_temp0';
  }

  @override
  String get deleteItemsConfirmBody => '항목과 첨부 파일이 영구적으로 삭제돼요. 되돌릴 수 없어요.';

  @override
  String deletedItemsSnackbar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개 항목을 삭제했어요.',
    );
    return '$_temp0';
  }

  @override
  String filedItemsSnackbar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개 항목을 프로젝트에 정리했어요.',
    );
    return '$_temp0';
  }

  @override
  String movedItemsSnackbar(int count, String destination) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개 항목을 $destination(으)로 옮겼어요.',
    );
    return '$_temp0';
  }

  @override
  String selectionCountTitle(int count) {
    return '$count개 선택됨';
  }

  @override
  String get captureTitle => '머릿속 비우기';

  @override
  String get captureHint => '무엇이 떠오르나요?';

  @override
  String get captureNotesHint => '메모 (선택)';

  @override
  String get captureEmptyError => '수집할 내용을 입력하세요';

  @override
  String get captureSubmit => '받은편지함에 추가';

  @override
  String get dictate => '받아쓰기';

  @override
  String get stopDictation => '받아쓰기 중지';

  @override
  String get processTitle => '받은편지함 처리';

  @override
  String get processCompleteTitle => '인박스 제로!';

  @override
  String get processCompleteNoItems => '처리할 항목이 없어요.';

  @override
  String processCompleteStats(int filed, int doneNow, int trashed) {
    return '$filed개 정리, 2분 안에 $doneNow개 해치움, $trashed개 휴지통으로. 수고하셨어요.';
  }

  @override
  String processStepCounter(int step, int total) {
    return '$total단계 중 $step단계';
  }

  @override
  String processItemsRemaining(int count) {
    return '$count개 남음';
  }

  @override
  String get previousStepTooltip => '이전 단계';

  @override
  String get skipItemTooltip => '건너뛰기';

  @override
  String get actionableQuestion => '실행할 수 있는 일인가요?';

  @override
  String get actionableYes => '네 — 할 일이 있어요';

  @override
  String get actionableReference => '아니요 — 참고 자료로 보관';

  @override
  String get actionableSomeday => '아니요 — 언젠가 / 어쩌면';

  @override
  String get actionableTrash => '삭제';

  @override
  String get twoMinQuestion => '2분 안에 끝낼 수 있나요?';

  @override
  String get twoMinYes => '네 — 지금 바로 할게요';

  @override
  String get twoMinNo => '아니요';

  @override
  String get delegateQuestion => '다른 사람이 할 수 있나요?';

  @override
  String get waitingOnPromptTitle => '누구를 기다리고 있나요?';

  @override
  String get waitingOnPromptHint => '이름 또는 시스템';

  @override
  String get multiStepQuestion => '여러 단계가 필요한가요?';

  @override
  String get recurrencePrompt => '반복할까요?';

  @override
  String get recurrenceOff => '반복 안 함';

  @override
  String get capturedLabel => '수집됨';

  @override
  String get engageTitle => '지금 실행';

  @override
  String get engageEmptyTitle => '아직 다음 행동이 없어요';

  @override
  String get engageEmptyMessage => '수집하거나 받은편지함을 처리해서 다음 행동 목록을 만들어 보세요.';

  @override
  String get engageInlineEmpty => '다음 행동이 아직 없어요 — 무언가를 수집하거나 받은편지함을 처리해 보세요.';

  @override
  String get engageOpenInbox => '받은편지함 열기';

  @override
  String get engageNoMatchTitle => '일치하는 항목이 없어요';

  @override
  String get engageNoMatchMessage =>
      '현재 필터와 일치하는 행동이 없어요. 조건을 넓히거나 필터를 지워 보세요.';

  @override
  String get hardLandscape => '확정 일정';

  @override
  String get hardLandscapeSubtitle => '오늘 마감 및 기한 초과';

  @override
  String get filterAllContexts => '모든 컨텍스트';

  @override
  String get filterAnyTime => '시간 무관';

  @override
  String get filterUnder5m => '5분 이내';

  @override
  String get filterUnder15m => '15분 이내';

  @override
  String get filterUnder30m => '30분 이내';

  @override
  String get filterUnder1h => '1시간 이내';

  @override
  String get filterAnyEnergy => '에너지 무관';

  @override
  String get energyLow => '낮음';

  @override
  String get energyMedium => '보통';

  @override
  String get energyHigh => '높음';

  @override
  String get projectsTitle => '프로젝트';

  @override
  String get newProject => '새 프로젝트';

  @override
  String get organizeLooseActionsTooltip => '미배정 행동 정리';

  @override
  String get projectsEmptyTitle => '아직 프로젝트가 없어요';

  @override
  String get projectsEmptyMessage =>
      '프로젝트는 한 번에 끝나지 않는 모든 결과물이에요. 프로젝트를 만들어 관련된 다음 행동을 묶고 목표를 향한 흐름을 유지해 보세요.';

  @override
  String get projectMissingNextAction => '다음 행동이 지정되지 않음';

  @override
  String projectActionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '행동 $count개',
    );
    return '$_temp0';
  }

  @override
  String get organizeActionsTitle => '행동 정리';

  @override
  String get organizeEmptyTitle => '미배정 항목 없음';

  @override
  String get organizeEmptyMessage =>
      '모든 다음 행동이 이미 프로젝트에 속해 있어요. 새로 들어오는 미배정 행동은 여기에 나타나 정리할 수 있어요.';

  @override
  String assignToProject(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개를 프로젝트에 배정',
    );
    return '$_temp0';
  }

  @override
  String get addNextActionTitle => '다음 행동 추가';

  @override
  String get addNextActionHint => '예: 사라에게 일정 이메일 보내기';

  @override
  String get addExistingActions => '기존 행동 가져오기';

  @override
  String get noUnassignedActionsMessage => '가져올 미배정 다음 행동이 없어요.';

  @override
  String addCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개 추가',
    );
    return '$_temp0';
  }

  @override
  String get editProject => '프로젝트 편집';

  @override
  String get projectName => '프로젝트 이름';

  @override
  String get projectNameHint => '예: 새 웹사이트 런칭하기';

  @override
  String get projectNameRequired => '프로젝트 이름을 입력하세요';

  @override
  String get areaOfFocusOptional => '책임 영역 (선택)';

  @override
  String get unfiledOption => '— 미분류 —';

  @override
  String get dueDate => '마감일';

  @override
  String get deleteProjectConfirmTitle => '프로젝트를 삭제할까요?';

  @override
  String get deleteProjectWarning => '여기에 속한 항목은 미분류 상태가 되지만 삭제되지는 않아요.';

  @override
  String get addActionFab => '행동 추가';

  @override
  String get projectOutcomeHint => '\"완료\"는 어떤 모습인가요?';

  @override
  String get outcomeSection => '결과';

  @override
  String get nextActionsSection => '다음 행동';

  @override
  String get noNextActionsMessage => '아직 다음 행동이 없어요.';

  @override
  String get projectMissingNextActionError =>
      '다음 행동이 지정되지 않았어요. 진행 중인 프로젝트에는 최소 하나의 다음 행동이 있어야 해요.';

  @override
  String get statusTooltip => '상태';

  @override
  String get reviewTitle => '검토';

  @override
  String get weeklyReviewCardTitle => '주간 검토';

  @override
  String get weeklyReviewCardSubtitle =>
      '받은편지함, 목록, 프로젝트를 차례로 점검하세요. 시스템을 믿을 수 있게 유지하는 의식이에요.';

  @override
  String get calendarEmpty => '특정 날짜에 묶인 항목이 없어요.';

  @override
  String get waitingForEmpty => '위임한 항목이 없어요.';

  @override
  String get somedayEmpty => '언젠가 / 어쩌면 항목이 없어요.';

  @override
  String get referenceEmpty => '참고 자료가 없어요.';

  @override
  String get completedThisWeek => '이번 주 완료';

  @override
  String get completedThisWeekEmpty => '이번 주에 완료한 항목이 아직 없어요.';

  @override
  String bucketCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '항목 $count개',
    );
    return '$_temp0';
  }

  @override
  String get needsReDecision => '재결정 필요';

  @override
  String pastDueCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '기한 초과 $count개',
    );
    return '$_temp0';
  }

  @override
  String get reviewStep1Title => '머리를 비우세요';

  @override
  String get reviewStep1Body => '신경 쓰이는 모든 것을 받은편지함에 수집해야 시스템을 신뢰할 수 있어요.';

  @override
  String get reviewStep2Title => '받은편지함을 0으로';

  @override
  String get reviewStep2Body => '결정 트리를 따라 수집된 모든 항목을 처리해서 받은편지함을 비우세요.';

  @override
  String get reviewStep3Title => '다음 행동 점검';

  @override
  String get reviewStep3Body =>
      '모든 행동을 훑어보세요. 끝났나요? 완료 표시. 오래됐나요? 수정하거나 삭제. 여전히 다음인가요? 그대로 두세요.';

  @override
  String get reviewStep4Title => '대기 중 목록 점검';

  @override
  String get reviewStep4Body => '누군가에게서 답이 왔나요? 후속 조치가 필요한가요? 업데이트하거나 제거하세요.';

  @override
  String get reviewStep5Title => '모든 프로젝트 점검';

  @override
  String get reviewStep5Body =>
      '각 프로젝트는 진행 중, 보류, 또는 완료 상태여야 해요. 진행 중인 프로젝트에는 반드시 다음 행동이 하나 이상 있어야 해요.';

  @override
  String get reviewStep6Title => '앞으로 2주 살펴보기';

  @override
  String get reviewStep6Body => '캘린더 항목을 확인하세요. 지금 미리 준비할 수 있는 일이 있나요?';

  @override
  String get reviewStep7Title => '언젠가 / 어쩌면 점검';

  @override
  String get reviewStep7Body => '지금 시작해 볼 만한 게 있나요? 프로젝트나 다음 행동으로 옮겨 보세요.';

  @override
  String reviewStepCounter(int step, int total) {
    return '$total단계 중 $step단계';
  }

  @override
  String get finishReview => '검토 마치기';

  @override
  String get reviewCompleteSnackbar => '주간 검토 완료';

  @override
  String get searchHint => '항목, 메모 검색';

  @override
  String get searchMinChars => '두 글자 이상 입력하세요';

  @override
  String get clearFilters => '필터 지우기';

  @override
  String get clearSearch => '검색 지우기';

  @override
  String searchNoResults(String query) {
    return '\"$query\"에 대한 결과가 없어요';
  }

  @override
  String get searchNoMatchTitle => '일치하는 항목이 없어요';

  @override
  String get searchNoMatchMessage =>
      '현재 필터와 일치하는 결과가 없어요. 조건을 넓히거나 필터를 지워 보세요.';

  @override
  String get filterAllProjects => '모든 프로젝트';

  @override
  String get filterCompleted => '완료됨';

  @override
  String get statusInbox => '받은편지함';

  @override
  String get statusNext => '다음';

  @override
  String get statusWaiting => '대기 중';

  @override
  String get statusSomeday => '언젠가';

  @override
  String get statusReference => '참고';

  @override
  String get appearanceSection => '화면';

  @override
  String get themeLabel => '테마';

  @override
  String get themeFollowSystem => '시스템 설정 따름';

  @override
  String get themeLight => '라이트';

  @override
  String get themeDark => '다크';

  @override
  String get hapticFeedback => '햅틱 피드백';

  @override
  String get organizationSection => '정리';

  @override
  String get contextsLabel => '컨텍스트';

  @override
  String get areasOfFocusLabel => '책임 영역';

  @override
  String get areasOfFocusDescription => '지속적인 책임 영역으로 프로젝트를 묶어요.';

  @override
  String get calendarSyncLabel => '캘린더 동기화';

  @override
  String get calendarSyncDescription => '마감일이 있는 항목을 시스템 캘린더에 반영해요.';

  @override
  String get remindersSection => '알림';

  @override
  String get weeklyReviewNudge => '주간 검토 알림';

  @override
  String get weeklyReviewNudgeDescription => '매주 금요일 오후 4시에 부드럽게 알려드려요.';

  @override
  String get remindBeforeDue => '마감 전 미리 알림';

  @override
  String get remindBeforeDueOff => '끄기 · 마감 시각에만 알림';

  @override
  String get remindBeforeDueSuffix => '지금부터 저장하는 항목에 적용돼요';

  @override
  String get deferSurfaceLabel => '보류된 항목 알림 시각';

  @override
  String get deferSurfaceDescription =>
      '시간이 지정되지 않은 보류 항목은 하루 종일 목록에 남고 이 시각에 알려드려요';

  @override
  String get checkingNotificationStatus => '알림 상태 확인 중…';

  @override
  String get dataSection => '데이터';

  @override
  String get exportBackup => '백업 내보내기';

  @override
  String get exportBackupDescriptionIos =>
      'JSON 사본을 공유해요. 클라우드 드라이브(예: 파일 → iCloud Drive)에 저장해 백업하세요.';

  @override
  String get exportBackupDescriptionAndroid =>
      'JSON 사본을 공유해요. 클라우드 드라이브(예: Google Drive)에 저장해 백업하세요.';

  @override
  String exportBackupError(String error) {
    return '내보낼 수 없어요: $error';
  }

  @override
  String get weeklyBackupReminder => '주간 백업 알림';

  @override
  String get weeklyBackupReminderDescription => '매주 일요일 아침에 내보내서 저장하라고 알려드려요.';

  @override
  String get importBackup => '백업 가져오기';

  @override
  String get importBackupDescription =>
      'Trayzero 백업을 복원하거나, Google Tasks(Takeout) 내보내기를 가져와요.';

  @override
  String get importConfirmTitle => '이 백업을 가져올까요?';

  @override
  String importConfirmBody(String sections) {
    return '$sections을(를) 추가하거나 업데이트해요.\n\n같은 id의 기존 항목은 백업 버전으로 덮어쓰여요. 되돌릴 수 없어요.';
  }

  @override
  String get importButton => '가져오기';

  @override
  String get importSourceSheetTitle => '백업 가져오기';

  @override
  String get importFromFileTitle => '백업 파일 선택';

  @override
  String get importFromFileDescription =>
      '권장 — Trayzero .json 백업 또는 Google Takeout의 Tasks.json.';

  @override
  String get importFromPasteTitle => '백업 JSON 붙여넣기';

  @override
  String get importFromPasteDescription => '백업 텍스트를 대신 붙여넣어요.';

  @override
  String get pasteBackupHint => '백업 JSON 붙여넣기…';

  @override
  String get privacySection => '개인정보';

  @override
  String get crashReports => '충돌 보고서 보내기';

  @override
  String get crashReportsDescription =>
      'Sentry를 통해 익명 충돌 및 오류 보고서를 보내요. 개인 정보는 수집하지 않아요. 기본값은 꺼짐이에요.';

  @override
  String get crashReportsEnabled => '다음 실행 시 충돌 보고서가 전송돼요';

  @override
  String get crashReportsDisabled => '충돌 보고서가 꺼졌어요';

  @override
  String get aboutSection => '정보';

  @override
  String get showOnboardingAgain => '온보딩 다시 보기';

  @override
  String get versionLabel => '버전';

  @override
  String get settingsFooter =>
      '로컬 우선. 데이터는 이 기기에만 저장돼요. David Allen의 Getting Things Done 방법론에서 영감을 받았어요.';

  @override
  String get editTitle => '편집';

  @override
  String get savedIndicator => '저장됨';

  @override
  String get titleLabel => '제목';

  @override
  String get notesLabel => '메모';

  @override
  String get statusSection => '상태';

  @override
  String get contextSection => '컨텍스트';

  @override
  String get energySection => '에너지';

  @override
  String get timeEstimateSection => '예상 시간';

  @override
  String get waitingOnSection => '기다리는 대상';

  @override
  String get waitingOnHint => '누구를 또는 무엇을 기다리고 있나요?';

  @override
  String get projectSection => '프로젝트';

  @override
  String get datesSection => '날짜';

  @override
  String get dueLabel => '마감';

  @override
  String get deferUntilLabel => '보류 기간';

  @override
  String get repeatSection => '반복';

  @override
  String get recurrenceNeedsDeferHint =>
      '위에 보류 날짜를 추가해야 반복을 사용할 수 있어요 — 반복은 그 날짜를 앞으로 옮기는 방식으로 동작해요.';

  @override
  String get recurrenceNeedsDueDateHint =>
      '위에 마감일 또는 보류 날짜를 추가해야 반복을 사용할 수 있어요 — 반복은 그 날짜를 앞으로 옮기는 방식으로 동작해요.';

  @override
  String get recurrenceExplanation => '이 항목을 완료하면 다음 항목이 날짜가 옮겨진 채로 나타나요.';

  @override
  String get recurrenceNoDateNextActionError =>
      '반복으로 설정됐지만 보류 날짜가 없어요. 완료해도 다음 항목이 만들어지지 않아요. 위에 보류 날짜를 추가하거나 반복을 꺼주세요.';

  @override
  String get recurrenceNoDateError =>
      '반복으로 설정됐지만 마감일 또는 보류 날짜가 없어요. 완료해도 다음 항목이 만들어지지 않아요. 위에 날짜를 추가하거나 반복을 꺼주세요.';

  @override
  String get attachmentsSection => '첨부';

  @override
  String get markComplete => '완료 표시';

  @override
  String get reopen => '다시 열기';

  @override
  String get deleteItemConfirmTitle => '항목을 삭제할까요?';

  @override
  String get deleteItemConfirmBody => '되돌릴 수 없어요.';

  @override
  String get completeError => '이 항목을 완료할 수 없어요.';

  @override
  String get reopenError => '이 항목을 다시 열 수 없어요.';

  @override
  String get remindersBlockedWarning => '시스템 설정에서 알림이 차단돼 있어요 — 알림이 오지 않아요.';

  @override
  String get remindersOffWarning => '알림이 꺼져 있어요 — 알림이 오지 않아요.';

  @override
  String get preciseReminderOffWarning =>
      '정확한 알림 시각이 꺼져 있어요 — 짧은 알림은 지연될 수 있어요.';

  @override
  String get allowExactAlarms => '정확한 알람 허용';

  @override
  String get noContextsAvailable => '아직 컨텍스트가 없어요 — 설정에서 추가해 보세요.';

  @override
  String get noActiveProjects => '진행 중인 프로젝트가 없어요.';

  @override
  String get attachmentPhoto => '사진';

  @override
  String get attachmentCamera => '카메라';

  @override
  String get attachmentVoiceMemo => '음성 메모';

  @override
  String get attachmentStop => '정지';

  @override
  String get remove => '제거';

  @override
  String get imageViewerClose => '닫기';

  @override
  String imageViewerCounter(int current, int total) {
    return '$current / $total';
  }

  @override
  String attachmentPhotoCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '사진 $count장',
    );
    return '$_temp0';
  }

  @override
  String attachmentAudioCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '음성 메모 $count개',
    );
    return '$_temp0';
  }

  @override
  String attachmentFileCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '파일 $count개',
    );
    return '$_temp0';
  }

  @override
  String get areasTitle => '책임 영역';

  @override
  String get newArea => '새 영역';

  @override
  String get renameArea => '영역 이름 변경';

  @override
  String get areasEmptyMessage =>
      '아직 영역이 없어요. 영역은 건강, 커리어, 가족처럼 프로젝트를 묶는 지속적인 책임의 범주예요.';

  @override
  String get areaNameHint => '예: 건강, 커리어, 가족';

  @override
  String deleteAreaConfirmTitle(String name) {
    return '\"$name\"을(를) 삭제할까요?';
  }

  @override
  String get deleteAreaWarning => '이 영역의 프로젝트는 미분류 상태가 돼요 (삭제되지는 않아요).';

  @override
  String get contextsTitle => '컨텍스트';

  @override
  String get newContext => '새 컨텍스트';

  @override
  String get editContext => '컨텍스트 편집';

  @override
  String get contextsEmptyMessage =>
      '아직 컨텍스트가 없어요. 컨텍스트는 행동에 어디서 또는 무엇으로 할 수 있는지 태그를 붙여요 (@phone, @home, @errands).';

  @override
  String get nameLabel => '이름';

  @override
  String get iconLabel => '아이콘';

  @override
  String get colorLabel => '색상';

  @override
  String deleteContextConfirmTitle(String name) {
    return '$name을(를) 삭제할까요?';
  }

  @override
  String get deleteContextWarning => '이 컨텍스트를 사용하는 항목은 컨텍스트를 잃게 돼요.';

  @override
  String get calendarSyncTitle => '캘린더 동기화';

  @override
  String get calendarSyncIntro =>
      '마감일이 있는 항목을 시스템 캘린더에 반영하고, \"#gtd\" 태그가 붙은 이벤트를 Trayzero 받은편지함으로 가져와요.';

  @override
  String get enableCalendarSync => '캘린더 동기화 켜기';

  @override
  String get targetCalendar => '대상 캘린더';

  @override
  String get calendarAccessDenied =>
      '캘린더 접근 권한이 거부됐어요. 권한을 허용해야 대상 캘린더를 선택할 수 있어요.';

  @override
  String get grantCalendarAccess => '캘린더 접근 허용';

  @override
  String get noCalendarsAvailable =>
      '사용 가능한 캘린더가 없어요. 방금 권한을 허용했다면 잠시 후 다시 시도해 보세요. 시스템 캘린더/계정 설정에서 캘린더 동기화가 켜져 있는지도 확인해 주세요.';

  @override
  String get mirrorOutAction => '항목 → 캘린더로 내보내기';

  @override
  String get importInAction => '#gtd 이벤트 → 받은편지함으로 가져오기';

  @override
  String mirrorOutSuccess(int written) {
    return '$written개 항목을 내보냈어요';
  }

  @override
  String mirrorOutSuccessWithStale(int written, int removed) {
    return '$written개 항목을 내보내고 오래된 $removed개를 정리했어요';
  }

  @override
  String importInSuccess(int count) {
    return '캘린더 이벤트 $count개를 가져왔어요';
  }

  @override
  String get mirroringProgress => '내보내는 중…';

  @override
  String get importingProgress => '가져오는 중…';

  @override
  String get calendarSyncTip =>
      '팁: 캘린더 이벤트 제목 어디든 \"#gtd\"를 넣으면 다음 동기화 때 Trayzero 받은편지함에 나타나요.';

  @override
  String get gtdDiagramTitle => 'GTD 작동 방식';

  @override
  String get gtdDiagramSubtitle =>
      '열려 있는 모든 고리를 머릿속에서 꺼내 신뢰할 수 있는 시스템으로 옮기는 다섯 단계예요. 강조된 목록을 누르면 그곳으로 바로 이동해요.';

  @override
  String get gtdAttribution => 'David Allen의 방법론 · gettingthingsdone.com';

  @override
  String get youAreHere => '현재 위치';

  @override
  String get gtdStage1Body =>
      '신경 쓰이는 것은 무엇이든 받은편지함에 던져 넣으세요 — 할 일, 아이디어, 걱정. 거르지도, 정리하지도 마세요.';

  @override
  String get gtdStage2Body =>
      '한 번에 하나씩 꺼내서 그게 무엇인지 결정하세요. 처리 흐름이 각 항목을 이 결정 트리로 안내해요:';

  @override
  String get gtdStage3Body => '결과가 알맞은 목록에 자리 잡으면 더 이상 머릿속에 남는 게 없어요.';

  @override
  String get gtdStage3Footnote => '대기 / 캘린더 / 언젠가 / 참고 자료는 검토 아래에 있어요.';

  @override
  String get gtdStage4Body =>
      '목록을 꾸준히 검토하세요 — 특히 주간 검토 — 그래야 시스템을 계속 믿을 수 있어요.';

  @override
  String get gtdStage5Body =>
      '그냥 해내세요 — 컨텍스트, 시간, 에너지, 우선순위에 따라 맑은 정신으로 행동을 골라 실행해요.';

  @override
  String get decisionNotActionableQ => '실행할 수 없는 일?';

  @override
  String get decisionNotActionableA => '휴지통, 언젠가/어쩌면, 또는 참고 자료';

  @override
  String get decisionTwoMinQ => '2분 안에 끝나는 일?';

  @override
  String get decisionTwoMinA => '지금 바로 실행';

  @override
  String get decisionDelegateQ => '다른 사람이 해야 할 일?';

  @override
  String get decisionDelegateA => '위임 → 대기 중';

  @override
  String get decisionMultiStepQ => '여러 단계가 필요한 일?';

  @override
  String get decisionMultiStepA => '프로젝트로 만들기';

  @override
  String get decisionOtherwiseQ => '그 외';

  @override
  String get decisionOtherwiseA => '바로 다음 행동을 정의';

  @override
  String get supportTitle => 'Trayzero 응원하기';

  @override
  String get supportSummaryDefault => '개발자에게 팁을 주거나 후원자가 되기';

  @override
  String get supportSummarySupporter => 'Trayzero를 응원해 주셔서 감사합니다 💙';

  @override
  String get supportIntro =>
      'Trayzero는 모든 기능이 열린 무료 앱입니다. 도움이 되었다면 보탬을 줄 수 있어요. 앱을 독립적이고 광고 없는 상태로 유지하는 데 도움이 됩니다.';

  @override
  String get supportUnavailable => '지금은 후원 옵션을 사용할 수 없습니다.';

  @override
  String get supportTipHeader => '팁 남기기';

  @override
  String get supportTipSmall => '작은 팁';

  @override
  String get supportTipLarge => '큰 팁';

  @override
  String get supportSupporterYearly => '후원자 — 연간';

  @override
  String supportSupporterYearlySubtitle(String price) {
    return '$price / 년 · 가장 합리적 · 후원자 혜택 잠금 해제';
  }

  @override
  String get supportSupporterMonthly => '후원자 — 월간';

  @override
  String supportSupporterMonthlySubtitle(String price) {
    return '$price / 월 · 언제든 해지 가능';
  }

  @override
  String get supportRestore => '구매 복원';

  @override
  String get supportRestoreSubtitle => '이미 후원자이신가요? 이 기기에서 복원하세요.';

  @override
  String get supportAutoRenewNote => '구독은 설정에서 취소하기 전까지 자동으로 갱신됩니다.';

  @override
  String get legalPrivacyPolicy => '개인정보 처리방침';

  @override
  String get legalTermsOfUse => '이용약관';

  @override
  String get supportThanksTip => '정말 감사합니다! 💙';

  @override
  String get supportThanksSupporter => '이제 후원자가 되셨어요 — 감사합니다! 💙';

  @override
  String get supportRestored => '구매가 복원되었습니다. 다시 오신 걸 환영해요! 💙';

  @override
  String get supportRestoreNone => '이전 구매 내역을 찾을 수 없습니다.';

  @override
  String get supportBadgeYearly => '후원자 · 연간';

  @override
  String get supportBadgeMonthly => '후원자 · 월간';

  @override
  String get supportBadgeGeneric => '후원자';

  @override
  String get supportBadgeSubtitle => 'Trayzero를 독립적으로 유지해 주셔서 감사합니다.';
}
