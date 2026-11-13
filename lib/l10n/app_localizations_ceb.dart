// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Cebuano (`ceb`).
class AppLocalizationsCeb extends AppLocalizations {
  AppLocalizationsCeb([String locale = 'ceb']) : super(locale);

  @override
  String get appTitle => 'Smart Crops sa Agri Lynk';

  @override
  String get scanCrop => 'I-scan ang tanom';

  @override
  String get fieldCalendar => 'Kalendaryo sa Uma';

  @override
  String get scanQueuedOffline =>
      'Na-save. Susihon namo kini kung naa na kay koneksyon.';

  @override
  String cropsSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tanom ang napili',
      one: '$count tanom ang napili',
      zero: 'Wala pay napiling tanom',
    );
    return '$_temp0';
  }

  @override
  String get skip => 'Laktaw';

  @override
  String get back => 'Mobalik';

  @override
  String get next => 'Sunod';

  @override
  String get getStarted => 'Sugda na';

  @override
  String get onboardingTitle1 => 'Pangtagaan ang Ani';

  @override
  String get onboardingBody1 =>
      'Tabangan ka sa Smart Crops nga maagang makita ang mga suliranon sa tanom aron mapangtagaan ang imong ani.';

  @override
  String get onboardingTitle2 => 'I-scan ug Hibaloa';

  @override
  String get onboardingBody2 =>
      'Kunhao og litrato ang imong tanom ug daghan ug kagawasan nga diagnosis nga naay klarong sunod nga lakang.';

  @override
  String get onboardingTitle3 => 'Planoon Base sa Panahon';

  @override
  String get onboardingBody3 =>
      'Awto nga mo-adjust ang imong Kalendaryo sa Uma base sa forecast aron dili masayang ang pagsikap.';

  @override
  String get profileSetupStep1Title => 'Mahitungod Kanimo';

  @override
  String get profileSetupStep1Subtitle =>
      'Isulti sa amo mahitungod kanimo ug sa imong uma';

  @override
  String get fullName => 'Tibuok Ngalan';

  @override
  String get farmName => 'Ngalan sa Uma';

  @override
  String get location => 'Lokasyon';

  @override
  String get phoneNumber => 'Numero sa Telepono (opsiyonal)';

  @override
  String get profileSetupStep2Title => 'Imong Pangunahing Tanom';

  @override
  String get profileSetupStep2Subtitle =>
      'Pilia ang mga tanom nga imong ginatanum aron personalison namo ang imong atiman';

  @override
  String get searchCrops => 'Pangitaa ang tanom';

  @override
  String get profileSetupStep3Title => 'Permiso';

  @override
  String get profileSetupStep3Subtitle =>
      'Hatagi og access aron maayo namo makahatag ug experience';

  @override
  String get cameraPermission => 'Camera';

  @override
  String get cameraPermissionDescription =>
      'Kinahanglan aron i-scan ang imong tanom';

  @override
  String get locationPermission => 'Lokasyon';

  @override
  String get locationPermissionDescription =>
      'Gamit sa lokal nga panahon ug abiso';

  @override
  String get notificationsPermission => 'Notipikasyon';

  @override
  String get notificationsPermissionDescription =>
      'Makadawat og abiso para sa danger sa panahon ug result sa scan';

  @override
  String get allow => 'Hatagan';

  @override
  String get notNow => 'Unya na';

  @override
  String get completeSetup => 'Kompletoha ang Setup';

  @override
  String get homeFieldBriefing => 'Field Briefing Karon';

  @override
  String get homePriorityAction => 'Pangunahing Lakang';

  @override
  String get homeScanCta => 'I-scan ang Tanom';

  @override
  String get homeCarePlan => 'Care Plan Sa Semana Karon';

  @override
  String get homeRecentScans => 'Mga Miaging Diagnosis';

  @override
  String get homeEmptyFarm =>
      'Andam na ang imong field office. Kuhaa ang una nga scan aron sugdan ang health record sa imong tanom.';

  @override
  String get homeMonitoring =>
      'Luwas tanan. Padayon namo bantayan ang imong mga tanom.';

  @override
  String get cropsTitle => 'Akong mga Tanom';

  @override
  String get cropsAddCrop => 'Magdugang og Tanom';

  @override
  String get cropsEmpty =>
      'Wala pay tanom. Magdugang ug una nga tanom para sa personalisadong atiman.';

  @override
  String get cropDetailCareGuide => 'Gabay sa Atiman';

  @override
  String get cropDetailGrowingConditions => 'Kondisyon sa Paglago';

  @override
  String get cropDetailGrowthTimeline => 'Timeline sa Paglago';

  @override
  String get scanCaptureTitle => 'I-scan ang Imong Tanom';

  @override
  String get scanCaptureGuidance =>
      'Punoa ang frame og usa ka dahon. Likayi ang landong.';

  @override
  String get scanReviewTitle => 'Tan-awa ang Imong Litrato';

  @override
  String get scanReviewRetake => 'Mobalik Kunan';

  @override
  String get scanReviewAnalyze => 'Susiha';

  @override
  String get scanAnalyzing => 'Gina-susi ang imong tanom...';

  @override
  String get scanResultTitle => 'Resulta sa Scan';

  @override
  String get scanResultConfidence => 'Kompiyansa';

  @override
  String get scanResultSeverity => 'Kagubot';

  @override
  String get scanResultDiagnosis => 'Diagnosis';

  @override
  String get scanResultTreatmentSteps => 'Mga Lakang sa Tambal';

  @override
  String get scanResultAddToCalendar => 'Idugang sa Kalendaryo sa Uma';

  @override
  String get scanResultSetReminder => 'Butangi og Pahinumdom';

  @override
  String get scanResultShare => 'Ibahin';

  @override
  String get scanResultLowConfidenceRetake =>
      'Mobalik kunan sa mas maayong kangitngit';

  @override
  String get calendarTitle => 'Kalendaryo sa Uma';

  @override
  String get calendarToday => 'Karon';

  @override
  String get calendarWeek => 'Semana Karon';

  @override
  String get calendarMonth => 'Buwan';

  @override
  String get calendarTaskCompleted => 'Natapos';

  @override
  String get calendarWeatherAdjusted => 'Naayon sa panahon';

  @override
  String get advisoriesTitle => 'Mga Abiso';

  @override
  String get advisoriesEmpty =>
      'Wala pay abiso. Ihatag namo og hibalo kun naay kinahanglan pagtagaan.';

  @override
  String get carePlanTitle => 'Plano sa Atiman';

  @override
  String get carePlanToday => 'Karon';

  @override
  String get carePlanThisWeek => 'Semana Karon';

  @override
  String get carePlanPreventive => 'Prebentibo';

  @override
  String get carePlanEmpty =>
      'Moabot ang imong plano human sa imong una nga scan o kun kinahanglan og atiman ang imong mga tanom.';

  @override
  String get healthLogTitle => 'Talaan sa Kalawasan';

  @override
  String get healthLogEmpty =>
      'Wala pay scan. Ang imong una nga diagnosis mao ang nagsugod.';

  @override
  String get profileTitle => 'Profile sa Mag-uuma';

  @override
  String get profileEdit => 'I-edit ang Profile';

  @override
  String get profileCrops => 'Pangunahing Tanom';

  @override
  String get profileLanguage => 'Pinulongan';

  @override
  String get profileNotifications => 'Notipikasyon';

  @override
  String get profileAgripro => 'Agri Pro';

  @override
  String get profileCooperative => 'Kooperatiba Hub';

  @override
  String get profilePrivacy => 'Privacy ug Datos';

  @override
  String get profileHelp => 'Tabang ug Suporta';

  @override
  String get profileAbout => 'Mahitungod';

  @override
  String get profileSignout => 'Pag-sign Out';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageTagalog => 'Tagalog';

  @override
  String get languageCebuano => 'Cebuano';

  @override
  String get notificationsScanResults => 'Mga Resulta sa Scan';

  @override
  String get notificationsWeatherAdvisories => 'Mga Abiso sa Panahon';

  @override
  String get notificationsCalendarReminders => 'Mga Pahinumdom sa Kalendaryo';

  @override
  String get notificationsCooperativeAdvisories => 'Mga Abiso sa Kooperatiba';

  @override
  String get notificationsQuietHours => 'Mga Tahimik nga Oras';

  @override
  String get agriProTitle => 'Agri Pro';

  @override
  String get agriProHeadline => 'Panalipdan ang mas daghan sa imong gitanom.';

  @override
  String get agriProFreeSummary =>
      'Gawas nga plano: 5 scan/semana, basic kalendaryo.';

  @override
  String get agriProProSummary =>
      'Agri Pro: walay limit nga scan, priority nga pagsusi, trend sa kalawasan, weather-adjusted nga paalala, offline pack.';

  @override
  String get agriProMonthly => 'Kada Buwan';

  @override
  String get agriProSeasonal => 'Pang-season (6 ka buwan)';

  @override
  String get agriProStart => 'Sugda ang Agri Pro';

  @override
  String get agriProNotNow => 'Di karon';

  @override
  String get shopTitle => 'Agri Shop';

  @override
  String get shopPartnerOffer => 'Alok sa partner';

  @override
  String get shopEmpty =>
      'Wala matugmang produkto para niini nga diagnosis. Moobra gihapon ang imong care plan bisan wala sila.';

  @override
  String get cooperativeTitle => 'Kooperatiba Hub';

  @override
  String get cooperativeJoin => 'Mosalapi sa Kooperatiba';

  @override
  String get cooperativeInviteCode => 'Kodigo sa Patawag';

  @override
  String get cooperativeMembers => 'Mga Miyembro';

  @override
  String get cooperativeBroadcasts => 'Mga Broadcast';

  @override
  String get cooperativeOutbreakSummary => 'Summary sa Pagkalat';

  @override
  String get severityHealthy => 'Malipayon';

  @override
  String get severityWatch => 'Bantayi';

  @override
  String get severityAtRisk => 'Nasa Danger';

  @override
  String get confidenceHigh => 'Taas';

  @override
  String get confidenceMedium => 'Katamtaman';

  @override
  String get confidenceLow => 'Ubog';

  @override
  String get errorGeneric => 'Naay nahitabo nga error. Sulaya usab.';

  @override
  String get errorNetwork =>
      'Walay koneksyon. Tan-awa ang imong internet ug sulaya usab.';

  @override
  String get errorPermission => 'Gidili ang permit. Ipahatag sa settings.';

  @override
  String get retry => 'Sulaya Usab';

  @override
  String get offlineBanner => 'Offline ka. Gipakita ang cached nga data.';

  @override
  String get offlineScanQueued =>
      'Na-save. Susihon namo kini kung naa na kay koneksyon.';

  @override
  String get viewAll => 'Tan-awa ang tanan';

  @override
  String get homeScanCTA => 'I-scan ang Tanom';

  @override
  String get calendarSetReminder => 'Magbutang og Pahinumdom';

  @override
  String get homeCriticalWeatherTitle => 'Delikado nga panahon';

  @override
  String get homeCriticalWeatherBody =>
      'Gilauman ang bagyo o maayong hangin. Iyong aseguhon ang imong tanom ug mga istraktura.';

  @override
  String get homeOverdueTaskTitle => 'Naengganan nga mga buluhaton';

  @override
  String get homeOverdueTaskBody =>
      'Naay mga buluhaton nga napalipas sa gitakda nga petsa. Ablihi ang Kalendaryo sa Uma.';

  @override
  String get homeAtRiskDiagnosisTitle => 'Kinahanglan og atensyon ang tanom';

  @override
  String get homeAtRiskDiagnosisBody =>
      'Naay nadiskobre ang pinakabag-o nga scan nga nagkinahanglan og aksyon. Susiha ang Talaan sa Kalawasan.';

  @override
  String get homeRoutineCareTitle => 'Kinahanglan og atiman';

  @override
  String get homeRoutineCareBody =>
      'Naay mga buluhaton sa atiman nga naghulat karon nga semana.';

  @override
  String get homeEmptyFarmTitle => 'Andam na ang imong field office';

  @override
  String get homeMonitorTitle => 'Luwas tanan';

  @override
  String get cropsScanThisCrop => 'I-scan kini nga tanom';

  @override
  String get cropsLastScan => 'Katapusang scan';

  @override
  String get cropsNoScans => 'Wala pay scan';

  @override
  String get cropsGrowingConditions => 'Kondisyon sa pagtubo';

  @override
  String get cropsInOptimal => 'Sulod sa optimal nga range';

  @override
  String get cropsTapToScan => 'I-tap ang tanom aron i-scan';

  @override
  String get cropDetailNotAvailable => 'Wala pa available';

  @override
  String get cropDetailYourScans => 'Imong mga scan para niining tanom';

  @override
  String get cropDetailUpcomingTasks => 'Umaabot nga buluhaton';

  @override
  String get cropDetailOpenCalendar => 'Ablihi ang kalendaryo';

  @override
  String get calendarViewToday => 'Karon';

  @override
  String get calendarViewWeek => 'Kini nga semana';

  @override
  String get calendarViewMonth => 'Buwan';

  @override
  String get calendarEmpty =>
      'Wala pay buluhaton. Makita dinhi ang imong plano.';

  @override
  String get calendarCompleteTask => 'Markahi nga tapos';

  @override
  String get calendarOverdue => 'Na-engganyo';

  @override
  String get calendarUpcoming => 'Nagsingabot';

  @override
  String get advisoriesMarkAllRead => 'Markahi tanan isip nabasa';

  @override
  String get advisoriesMarkRead => 'Markahi isip nabasa';

  @override
  String get advisoriesSource => 'Ginikanan';

  @override
  String get advisoriesUnread => 'Wala pa nabasa';

  @override
  String get healthLogScans => 'Mga scan';

  @override
  String get healthLogHealthy => 'Malig-on';

  @override
  String get healthLogAtRisk => 'Kinahanglan og atiman';

  @override
  String get healthLogFilterAll => 'Tanan';

  @override
  String get healthLogConfidence => 'Kompiyansa';

  @override
  String get carePlanNoItems =>
      'Wala kay kinahanglan nga atiman. Maayo ang imong mga tanom.';

  @override
  String get carePlanItemReason => 'Ngano karon';

  @override
  String get carePlanOpenTask => 'Ablihi sa Kalendaryo sa Uma';

  @override
  String get profileSignOutConfirm => 'Mo-sign out?';

  @override
  String get profileSignOutConfirmBody =>
      'Kinahanglan mo mo-sign in pag-usab aron makita ang imong mga tanom.';

  @override
  String get profileSignOutAction => 'Mo-sign out';

  @override
  String get profileCancel => 'Kanselarha';

  @override
  String get profileManageCrops => 'Dumalaa';

  @override
  String get profileName => 'Mag-uuma';

  @override
  String get languageSheetTitle => 'Pinulongan';

  @override
  String get languageApply => 'I-apply';

  @override
  String get profileUpdated => 'Na-save ang mga kausaban.';

  @override
  String get authSignIn => 'Mag-sign in';

  @override
  String get authCreateAccount => 'Paghimo og Account';

  @override
  String get authSignUpPrompt => 'Wala pa ka account? Sign up';

  @override
  String get authSignInPrompt => 'Naay account ka na? Sign in';

  @override
  String get authForgotPassword => 'Nakalimtan ang password?';

  @override
  String get authContinueGoogle => 'Padayon sa Google';

  @override
  String get authContinueFacebook => 'Padayon sa Facebook';

  @override
  String get authContinuePhone => 'Padayon sa Telepono (OTP)';

  @override
  String get authTagline => 'Diskubreha Agad. Panggawi ang Imong Ani.';

  @override
  String get authEmail => 'Email Address';

  @override
  String get authPassword => 'Password';

  @override
  String get authFullNameRequired => 'Palihug og ngalan';

  @override
  String get authFarmNameRequired => 'Palihug og ngalan sa uma';

  @override
  String get authLocationRequired => 'Palihug og lokasyon';

  @override
  String get authEmailInvalid => 'Palihug og valid nga email';

  @override
  String get authPasswordMinLength =>
      'Ang password kinahanglan 6 ka karakter o labaw pa';

  @override
  String get authPhoneLabel => 'Numero sa Telepono / Mobile (Opsyonal)';

  @override
  String get authOtpMobile => 'Numero sa Mobile (+63...)';

  @override
  String get authOtpCode => 'Ibutang ang OTP Code';

  @override
  String get authSendOtp => 'Ipadala ang OTP';

  @override
  String get authVerifyOtp => 'I-verify ang OTP';

  @override
  String get authOtpTitle => 'Login gamit ang Telepono (OTP)';

  @override
  String get authOtpSent => 'Naipadala na ang OTP sa imong mobile number!';

  @override
  String get authCancel => 'Kanselarha';

  @override
  String get authRequired => 'Kinahanglan';

  @override
  String get authGoogleError => 'Napakalas ang Google Sign-In. Sulaya usab.';

  @override
  String get authFacebookError =>
      'Napakalas ang Facebook Sign-In. Sulaya usab.';

  @override
  String get homeWeatherUpdated => 'Na-update';

  @override
  String get homeOfflineBanner =>
      'Offline ka. Gipakita ang cached nga panahon.';

  @override
  String get calendarAddTask => 'Pagdugang og Buluhaton';

  @override
  String get taskEditTitle => 'I-edit ang Buluhaton';

  @override
  String get taskTitleLabel => 'Ulohan sa Buluhaton';

  @override
  String get taskTitleRequired => 'Isulat ang ulohan sa buluhaton';

  @override
  String get taskCategoryLabel => 'Klaro';

  @override
  String get taskCropLabel => 'May kalabotan nga tanom (opsyonal)';

  @override
  String get taskNoCrop => 'Walay pananum';

  @override
  String get taskPriorityLabel => 'Prayoridad';

  @override
  String get taskPriorityNormal => 'Normal';

  @override
  String get taskPriorityHigh => 'Taas';

  @override
  String get taskDateLabel => 'Petsa';

  @override
  String get taskSave => 'I-save ang Buluhaton';

  @override
  String get taskSaved => 'Na-save ang buluhaton';

  @override
  String get taskSaveError => 'Dili ma-save ang buluhaton. Sulaya usab.';

  @override
  String get taskDetailTitle => 'Buluhaton';

  @override
  String get taskDetailEdit => 'I-edit ang buluhaton';

  @override
  String get taskDetailDelete => 'Tangtangon ang buluhaton';

  @override
  String get taskDeleteConfirmTitle => 'Tangtangon kining buluhatona?';

  @override
  String get taskDeleteConfirmBody =>
      'Matangtang niini ang buluhaton sa imong field calendar.';

  @override
  String get taskDeleteAction => 'Tangtangon';

  @override
  String get taskDeleteCancel => 'Kanselahon';

  @override
  String get taskDeleted => 'Natangtang ang buluhaton';

  @override
  String get taskScheduledFor => 'Gipahinungod';

  @override
  String get taskWhyThisDate => 'Nganong niini nga adlaw';

  @override
  String get taskReasonWeather => 'Gibalhin tungod sa ulan sa forecast.';

  @override
  String get taskReasonOverdue => 'Nilapas na ang petsa niini nga buluhatona.';

  @override
  String get taskReasonScan => 'Gidasugyot base sa imong pinakabag-o nga scan.';

  @override
  String get taskReasonRoutine => 'Regular nga pag-atiman sa bukid.';

  @override
  String get taskRelatedScan => 'Kaugnay nga scan';

  @override
  String get carePlanSuggested => 'Gidasugyot para kanimo';

  @override
  String get carePlanAddToCalendar => 'Idugang sa kalendaryo';

  @override
  String get carePlanAdded => 'Naidugang na sa imong field calendar';

  @override
  String get carePlanReasonWeather => 'Panahon';

  @override
  String get carePlanReasonOverdue => 'Nilapas';

  @override
  String get carePlanReasonScan => 'Gikan sa scan';

  @override
  String get carePlanReasonRoutine => 'Regular';

  @override
  String get scanResultAddedToCalendar =>
      'Naidugang na sa imong field calendar';

  @override
  String get viewCalendar => 'Tan-awa ang kalendaryo';

  @override
  String carePlanSuggestionTitle(String crop, String diagnosis) {
    return 'Susiha pag-usab ang $crop human sa $diagnosis';
  }

  @override
  String get agriProFreePlanSummary =>
      '5 ka scan kada semana, yano nga kalendaryo.';

  @override
  String get agriProFeatureUnlimited => 'Walay limit nga scan';

  @override
  String get agriProFeaturePriority => 'Prayoridad nga pagsusi';

  @override
  String get agriProFeatureTrends => 'Mga trend sa panglawas';

  @override
  String get agriProFeatureWeather => 'Mga pahinumdom nga gipahaom sa panahon';

  @override
  String get agriProFeatureOffline => 'Offline nga pakete';

  @override
  String get agriProPlanMonthly => 'Binulan';

  @override
  String get agriProPlanSeasonal => 'Panahon sa tanom';

  @override
  String get agriProPlanSeasonTagline =>
      'Usa ka panahon sa tanom, unom ka bulan nga walay limit nga scan.';

  @override
  String get agriProPlanMonthlyTagline => 'Isulat ang Agri Pro matag bulan.';

  @override
  String get agriProPriceMonthly => '₱99/bulan';

  @override
  String get agriProPriceSeasonal => '₱499/6 ka bulan';

  @override
  String get agriProPerDay => '₱3 kada adlaw';

  @override
  String get agriProSavePercent => 'Makadaginot og 16%';

  @override
  String get agriProPlanRenewsMonthly => 'Nagre-renew matag bulan sa ₱99.';

  @override
  String get agriProPlanRenewsSeasonal =>
      'Nagre-renew kada unom ka bulan sa ₱499.';

  @override
  String get agriProCancelAnytime => 'Kanselahon bisan kanus-a.';

  @override
  String get agriProPaymentNote =>
      'Apil na ang VAT sa presyo. Ang bayad moagi sa Google Play o App Store.';

  @override
  String get startAgriPro => 'Sugdi ang Agri Pro';

  @override
  String get agriProManageTitle => 'Pagdumala sa Agri Pro';

  @override
  String get agriProManageCurrentPlan => 'Kasamtangang plano';

  @override
  String get agriProManageRenewal => 'Pag-renew';

  @override
  String get agriProManageBilling => 'Pagbayad';

  @override
  String get agriProManageBilledBy => 'Gimando sa imong app store.';

  @override
  String get agriProManageCancelHow =>
      'Para magkansela, abriha ang Google Play → Subscriptions → Smart Crops, o ang App Store → Subscriptions. Magpadayon ang access hangtod matapos ang bayad nga panahon.';

  @override
  String get agriProRestore => 'Baliki ang gipalit';

  @override
  String get agriProPurchaseRestored => 'Moabot ang gipalit.';

  @override
  String get billingNotConfigured =>
      'Wala pa disponable ang pagpalit sa Agri Pro. Makapalit ka kon live na ang store listing.';

  @override
  String get agriProPurchaseFailed => 'Kapakyasan ang gipalit. Sulaya usab.';

  @override
  String get agriProUnlocked => 'Na-unlock ang Agri Pro.';

  @override
  String get agriProPlanActive => 'Agri Pro — Aktibo';

  @override
  String get agriProPlanFree => 'Libre';

  @override
  String get agriProManageUpgradeTitle => 'Sa Free plan ka';

  @override
  String get agriProManageFreeSummary =>
      'Mag-upgrade alang sa walay limit nga scan.';

  @override
  String get agriProManageProSummary =>
      'May walay limit nga scan ug prayoridad nga pagsusi ka.';

  @override
  String get agriProManageUpgradeCta => 'Tan-awa ang mga plano sa Agri Pro';

  @override
  String get agriProRenewalNever => 'Hangtod sa imong pagkansela';

  @override
  String agriProQuotaContext(int used, int limit) {
    return 'Nagamit na nimo ang $used sa $limit ka libreng scan karong semanaha. Tangtangon sa Agri Pro ang limitasyon.';
  }
}
