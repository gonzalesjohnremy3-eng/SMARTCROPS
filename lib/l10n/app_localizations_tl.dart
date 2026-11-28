// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tagalog (`tl`).
class AppLocalizationsTl extends AppLocalizations {
  AppLocalizationsTl([String locale = 'tl']) : super(locale);

  @override
  String get appTitle => 'Smart Crops ng Agri Lynk';

  @override
  String get scanCrop => 'I-scan ang pananim';

  @override
  String get fieldCalendar => 'Kalendaryo ng Bukid';

  @override
  String get scanQueuedOffline =>
      'Nai-save. Susuriin namin ito kapag may koneksyon ka na.';

  @override
  String cropsSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pananim ang napili',
      one: '$count pananim ang napili',
      zero: 'Wala pang napiling pananim',
    );
    return '$_temp0';
  }

  @override
  String get skip => 'Lagtaan';

  @override
  String get back => 'Bumalik';

  @override
  String get next => 'Sunod';

  @override
  String get getStarted => 'Simulan na';

  @override
  String get onboardingTitle1 => 'Protektahan ang ani';

  @override
  String get onboardingBody1 =>
      'Tutulungan ka ng Smart Crops na maagap na matukoy ang mga suliranin sa pananim upang maprotektahan ang iyong ani.';

  @override
  String get onboardingTitle2 => 'I-scan at malaman';

  @override
  String get onboardingBody2 =>
      'Kunan ng litrato ang iyong pananim at makuha agad ang diagnosis na may malinaw susunod na hakbang.';

  @override
  String get onboardingTitle3 => 'Magplano ayon sa panahon';

  @override
  String get onboardingBody3 =>
      'Awtomatik na naaayon ang iyong Kalendaryo ng Bukid batay sa forecast upang hindi masayang ang pagsisikap.';

  @override
  String get profileSetupStep1Title => 'Tungkol Sa Iyo';

  @override
  String get profileSetupStep1Subtitle =>
      'Sabihin sa amin ang tungkol sa iyo at sa iyong bukid';

  @override
  String get fullName => 'Buong Pangalan';

  @override
  String get farmName => 'Pangalan ng Bukid';

  @override
  String get location => 'Lokasyon';

  @override
  String get phoneNumber => 'Numero ng Telepono (pagpipilian)';

  @override
  String get profileSetupStep2Title => 'Iyong Pangunahing Pananim';

  @override
  String get profileSetupStep2Subtitle =>
      'Piliin ang mga pananim na inyong tinatanim upang personalizin ang inyong alaga';

  @override
  String get searchCrops => 'Maghanap ng pananim';

  @override
  String get profileSetupStep3Title => 'Permiso';

  @override
  String get profileSetupStep3Subtitle =>
      'Payagan ang access upang mabigyan ka namin ng karanasang pinakamahusay';

  @override
  String get cameraPermission => 'Camera';

  @override
  String get cameraPermissionDescription =>
      'Kailangan para i-scan ang iyong pananim';

  @override
  String get locationPermission => 'Lokasyon';

  @override
  String get locationPermissionDescription =>
      'Ginagamit para sa lokal na panahon at abiso';

  @override
  String get notificationsPermission => 'Notipikasyon';

  @override
  String get notificationsPermissionDescription =>
      'Makakuha ng abiso para sa panganib ng panahon at resulta ng scan';

  @override
  String get allow => 'Payagan';

  @override
  String get notNow => 'Mamaya na';

  @override
  String get completeSetup => 'Kumpletuhin ang Setup';

  @override
  String get homeFieldBriefing => 'Field Briefing Ngayon';

  @override
  String get homePriorityAction => 'Pangunahing Kilos';

  @override
  String get homeScanCta => 'I-scan ang Pananim';

  @override
  String get homeCarePlan => 'Care Plan Ng Linggang Ito';

  @override
  String get homeRecentScans => 'Mga Nakaraang Diagnosis';

  @override
  String get homeEmptyFarm =>
      'Handa na ang iyong field office. Kumuha ng unang scan upang simulan ang talaan ng kalusugan ng iyong pananim.';

  @override
  String get homeMonitoring =>
      'Ligtas lahat. Patuloy naming bantayan ang iyong mga pananim.';

  @override
  String get cropsTitle => 'Aking mga Pananim';

  @override
  String get cropsAddCrop => 'Magdagdag ng Pananim';

  @override
  String get cropsEmpty =>
      'Wala pang pananim. Magdagdag ng unang pananim para sa personalisadong alaga.';

  @override
  String get cropDetailCareGuide => 'Gabay sa Alaga';

  @override
  String get cropDetailGrowingConditions => 'Kaugnayan sa Pagtubo';

  @override
  String get cropDetailGrowthTimeline => 'Timeline ng Paglago';

  @override
  String get scanCaptureTitle => 'I-scan ang Iyong Pananim';

  @override
  String get scanCaptureGuidance =>
      'Punan ang frame ng isang dahon. Iwasan ang anino.';

  @override
  String get scanReviewTitle => 'Surin ang Iyong Litrato';

  @override
  String get scanReviewRetake => 'Muling Kunan';

  @override
  String get scanReviewAnalyze => 'Suriin';

  @override
  String get scanAnalyzing => 'Sinusuri ang iyong pananim...';

  @override
  String get scanResultTitle => 'Resulta ng Scan';

  @override
  String get scanResultConfidence => 'Kumpiyansa';

  @override
  String get scanResultSeverity => 'Kagubatan';

  @override
  String get scanResultDiagnosis => 'Diagnosis';

  @override
  String get scanResultTreatmentSteps => 'Mga Hakbang ng Gamot';

  @override
  String get scanResultAddToCalendar => 'Idagdag sa Kalendaryo ng Bukid';

  @override
  String get scanResultSetReminder => 'Maglagay ng Paalala';

  @override
  String get scanResultShare => 'Ibahagi';

  @override
  String get scanResultLowConfidenceRetake =>
      'Muling kunan sa mas magandang liwanag';

  @override
  String get calendarTitle => 'Kalendaryo ng Bukid';

  @override
  String get calendarToday => 'Ngayon';

  @override
  String get calendarWeek => 'Linggang Ito';

  @override
  String get calendarMonth => 'Buwan';

  @override
  String get calendarTaskCompleted => 'Natapos';

  @override
  String get calendarWeatherAdjusted => 'Naaayon sa panahon';

  @override
  String get advisoriesTitle => 'Mga Abiso';

  @override
  String get advisoriesEmpty =>
      'Wala pang abiso. Sasabihin namin kung may kailangang pagtuunan ng pansin.';

  @override
  String get carePlanTitle => 'Plano ng Alaga';

  @override
  String get carePlanToday => 'Ngayon';

  @override
  String get carePlanThisWeek => 'Linggang Ito';

  @override
  String get carePlanPreventive => 'Prebentibo';

  @override
  String get carePlanEmpty =>
      'Lalabas ang iyong plano pagkatapos ng iyong unang scan o kapag kailangan ng alaga ang iyong mga pananim.';

  @override
  String get healthLogTitle => 'Talaan ng Kalusugan';

  @override
  String get healthLogEmpty =>
      'Wala pang scan. Ang iyong unang diagnosis ang nagsisimula dito.';

  @override
  String get profileTitle => 'Profile ng Magsasaka';

  @override
  String get profileEdit => 'I-edit ang Profile';

  @override
  String get profileCrops => 'Pangunahing Pananim';

  @override
  String get profileLanguage => 'Wika';

  @override
  String get profileNotifications => 'Notipikasyon';

  @override
  String get profileAgripro => 'Agri Pro';

  @override
  String get profileCooperative => 'Kooperatiba Hub';

  @override
  String get profilePrivacy => 'Privacy at Datos';

  @override
  String get profileHelp => 'Tulong at Suporta';

  @override
  String get profileAbout => 'Tungkol';

  @override
  String get profileSignout => 'Mag-sign Out';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageTagalog => 'Tagalog';

  @override
  String get languageCebuano => 'Cebuano';

  @override
  String get notificationsScanResults => 'Mga Resulta ng Scan';

  @override
  String get notificationsWeatherAdvisories => 'Mga Abiso sa Panahon';

  @override
  String get notificationsCalendarReminders => 'Mga Paalala sa Kalendaryo';

  @override
  String get notificationsCooperativeAdvisories => 'Mga Abiso ng Kooperatiba';

  @override
  String get notificationsQuietHours => 'Mga Tahimik na Oras';

  @override
  String get agriProTitle => 'Agri Pro';

  @override
  String get agriProHeadline =>
      'Protektahan ang mas marami sa iyong itinatanim.';

  @override
  String get agriProFreeSummary =>
      'Libreng plano: 5 scan/linggo, batayan na kalendaryo.';

  @override
  String get agriProProSummary =>
      'Agri Pro: walang limit na scan, prayoridad na pagsusuri, trend ng kalusugan, paalala na naaayon sa panahon, offline pack.';

  @override
  String get agriProMonthly => 'Buwanan';

  @override
  String get agriProSeasonal => 'Pang-season (6 na buwan)';

  @override
  String get agriProStart => 'Simulan ang Agri Pro';

  @override
  String get agriProNotNow => 'Hindi muna';

  @override
  String get shopTitle => 'Agri Shop';

  @override
  String get shopPartnerOffer => 'Alok ng partner';

  @override
  String get shopEmpty =>
      'Walang tumutugmang produkto para sa diagnosis ito. Gumagana pa rin ang iyong plano ng alaga nang walang mga ito.';

  @override
  String get cooperativeTitle => 'Kooperatiba Hub';

  @override
  String get cooperativeJoin => 'Sumapi sa Kooperatiba';

  @override
  String get cooperativeInviteCode => 'Kodigo ng Imbitasyon';

  @override
  String get cooperativeMembers => 'Mga Miyembro';

  @override
  String get cooperativeBroadcasts => 'Mga Broadcast';

  @override
  String get cooperativeOutbreakSummary => 'Buod ng Pagkalat';

  @override
  String get severityHealthy => 'Malusog';

  @override
  String get severityWatch => 'Bantayan';

  @override
  String get severityAtRisk => 'Nasa Panganib';

  @override
  String get confidenceHigh => 'Mataas';

  @override
  String get confidenceMedium => 'Katamtaman';

  @override
  String get confidenceLow => 'Mababa';

  @override
  String get errorGeneric => 'May naganap na error. Subukan muli.';

  @override
  String get errorNetwork =>
      'Walang koneksyon. Suriin ang iyong internet at subukan muli.';

  @override
  String get errorPermission =>
      'Pinagbabawal ang permit. Pakipayagan sa settings.';

  @override
  String get retry => 'Subukan Muli';

  @override
  String get offlineBanner => 'Offline ka. Ipinapakita ang cached na data.';

  @override
  String get offlineScanQueued =>
      'Nai-save. Susuriin namin ito kapag may koneksyon ka na.';

  @override
  String get viewAll => 'Tingnan ang lahat';

  @override
  String get homeScanCTA => 'I-scan ang Pananim';

  @override
  String get calendarSetReminder => 'Maglagay ng Paalala';

  @override
  String get homeCriticalWeatherTitle => 'Mapanganib na panahon';

  @override
  String get homeCriticalWeatherBody =>
      'Inaasahan ang bagyo o malakas na hangin. I-secure ang iyong pananim at mga istraktura.';

  @override
  String get homeOverdueTaskTitle => 'Nahuli na mga gawain';

  @override
  String get homeOverdueTaskBody =>
      'May mga gawain kang lagpas sa nakatakdang petsa. Buksan ang Kalendaryo ng Bukid.';

  @override
  String get homeAtRiskDiagnosisTitle => 'Kailangan ng atensyon ang pananim';

  @override
  String get homeAtRiskDiagnosisBody =>
      'May nakita ang pinakahuling scan na nangangailangan ng aksyon. Suriin ang Talaan ng Kalusugan.';

  @override
  String get homeRoutineCareTitle => 'Kailangan ng alaga';

  @override
  String get homeRoutineCareBody =>
      'May mga gawain ng alaga kang naghihintay sa linggong ito.';

  @override
  String get homeEmptyFarmTitle => 'Handa na ang iyong field office';

  @override
  String get homeMonitorTitle => 'Ligtas lahat';

  @override
  String get cropsScanThisCrop => 'I-scan ang pananim na ito';

  @override
  String get cropsLastScan => 'Huling scan';

  @override
  String get cropsNoScans => 'Wala pang scan';

  @override
  String get cropsGrowingConditions => 'Kundisyon sa paglaki';

  @override
  String get cropsInOptimal => 'Nasa loob ng optimal na saklaw';

  @override
  String get cropsTapToScan => 'I-tap ang pananim upang i-scan';

  @override
  String get cropDetailNotAvailable => 'Hindi available';

  @override
  String get cropDetailYourScans => 'Mga scan mo para sa pananim na ito';

  @override
  String get cropDetailUpcomingTasks => 'Mga susunod na gawain';

  @override
  String get cropDetailOpenCalendar => 'Buksan ang kalendaryo';

  @override
  String get calendarViewToday => 'Ngayon';

  @override
  String get calendarViewWeek => 'Linggang ito';

  @override
  String get calendarViewMonth => 'Buwan';

  @override
  String get calendarEmpty => 'Wala pang gawain. Lalabas ang iyong plano dito.';

  @override
  String get calendarCompleteTask => 'Markahang tapos';

  @override
  String get calendarOverdue => 'Huli na';

  @override
  String get calendarUpcoming => 'Paparating';

  @override
  String get advisoriesMarkAllRead => 'Markahan lahat bilang nabasa';

  @override
  String get advisoriesMarkRead => 'Markahan bilang nabasa';

  @override
  String get advisoriesSource => 'Pinanggalingan';

  @override
  String get advisoriesUnread => 'Hindi pa nababasa';

  @override
  String get healthLogScans => 'Mga scan';

  @override
  String get healthLogHealthy => 'Malusog';

  @override
  String get healthLogAtRisk => 'Kailangan ng pansin';

  @override
  String get healthLogFilterAll => 'Lahat';

  @override
  String get healthLogConfidence => 'Kumpiyansa';

  @override
  String get carePlanNoItems =>
      'Walang kailangang alaga. Maganda ang iyong mga pananim.';

  @override
  String get carePlanItemReason => 'Bakit ngayon';

  @override
  String get carePlanOpenTask => 'Buksan sa Kalendaryo ng Bukid';

  @override
  String get profileSignOutConfirm => 'Mag-sign out?';

  @override
  String get profileSignOutConfirmBody =>
      'Kailangan mong mag-sign in muli upang makita ang iyong mga pananim.';

  @override
  String get profileSignOutAction => 'Mag-sign out';

  @override
  String get profileCancel => 'Kanselahin';

  @override
  String get profileManageCrops => 'Pamahalaan';

  @override
  String get profileName => 'Magsasaka';

  @override
  String get languageSheetTitle => 'Wika';

  @override
  String get languageApply => 'Ilapat';

  @override
  String get profileUpdated => 'Nai-save ang mga pagbabago.';

  @override
  String get authSignIn => 'Mag-sign in';

  @override
  String get authCreateAccount => 'Gumawa ng Account';

  @override
  String get authSignUpPrompt => 'Wala pang account? Mag-sign up';

  @override
  String get authSignInPrompt => 'May account ka na? Mag-sign in';

  @override
  String get authForgotPassword => 'Nakalimutan ang password?';

  @override
  String get authContinueGoogle => 'Magpatuloy sa Google';

  @override
  String get authContinueFacebook => 'Magpatuloy sa Facebook';

  @override
  String get authContinuePhone => 'Magpatuloy sa Telepono (OTP)';

  @override
  String get authUseEmail => 'Gumamit ng email';

  @override
  String get authUsePhone => 'Gumamit ng telepono';

  @override
  String get authTagline => 'Alamin ang kailangan ng iyong pananim.';

  @override
  String get authBrandName => 'Smart Crops';

  @override
  String get authBrandByline => 'by Agri Lynk';

  @override
  String get authEmail => 'Email Address';

  @override
  String get authPassword => 'Password';

  @override
  String get authFullNameRequired => 'Pakilagay ang iyong buong pangalan';

  @override
  String get authFarmNameRequired => 'Pakilagay ang pangalan ng bukid';

  @override
  String get authLocationRequired => 'Pakilagay ang lokasyon';

  @override
  String get authEmailInvalid => 'Pakilagay ang valid na email';

  @override
  String get authPasswordMinLength =>
      'Ang password ay dapat hindi bababa sa 6 na karakter';

  @override
  String get authPhoneLabel => 'Numero ng Telepono / Mobile (Opsyonal)';

  @override
  String get authOtpMobile => 'Numero ng mobile';

  @override
  String get authOtpCode => 'Ilagay ang 6-digit na code';

  @override
  String get authSendOtp => 'Magpatuloy';

  @override
  String get authVerifyOtp => 'I-verify ang code';

  @override
  String get authOtpTitle => 'Mag-sign in o gumawa ng account';

  @override
  String get authOtpSent => 'Ang OTP ay ipinadala sa iyong mobile number!';

  @override
  String get authCancel => 'Kanselahin';

  @override
  String get authRequired => 'Kailangan';

  @override
  String get authGoogleError =>
      'Hindi nagtagumpay ang Google Sign-In. Subukan muli.';

  @override
  String get authFacebookError =>
      'Hindi nagtagumpay ang Facebook Sign-In. Subukan muli.';

  @override
  String get homeWeatherUpdated => 'Na-update';

  @override
  String get homeOfflineBanner =>
      'Offline ka. Ipinapakita ang cached na panahon.';

  @override
  String get calendarAddTask => 'Magdagdag ng Gawain';

  @override
  String get taskEditTitle => 'I-edit ang Gawain';

  @override
  String get taskTitleLabel => 'Pamagat ng Gawain';

  @override
  String get taskTitleRequired => 'Ilagay ang pamagat ng gawain';

  @override
  String get taskCategoryLabel => 'Kategorya';

  @override
  String get taskCropLabel => 'Kaugnay na pananim (opsyonal)';

  @override
  String get taskNoCrop => 'Walang pananim';

  @override
  String get taskPriorityLabel => 'Priyoridad';

  @override
  String get taskPriorityNormal => 'Karaniwan';

  @override
  String get taskPriorityHigh => 'Mataas';

  @override
  String get taskDateLabel => 'Takdang-araw';

  @override
  String get taskSave => 'I-save ang Gawain';

  @override
  String get taskSaved => 'Na-save ang gawain';

  @override
  String get taskSaveError => 'Hindi ma-save ang gawain. Pakisubukan ulit.';

  @override
  String get taskDetailTitle => 'Gawain';

  @override
  String get taskDetailEdit => 'I-edit ang gawain';

  @override
  String get taskDetailDelete => 'Tanggalin ang gawain';

  @override
  String get taskDeleteConfirmTitle => 'Tanggalin ang gawaing ito?';

  @override
  String get taskDeleteConfirmBody =>
      'Maaalis nito ang gawain sa iyong field calendar.';

  @override
  String get taskDeleteAction => 'Tanggalin';

  @override
  String get taskDeleteCancel => 'Kanselahin';

  @override
  String get taskDeleted => 'Natanggal ang gawain';

  @override
  String get taskScheduledFor => 'Takda';

  @override
  String get taskWhyThisDate => 'Bakit sa araw na ito';

  @override
  String get taskReasonWeather => 'Inilipat dahil sa naulawang ulan.';

  @override
  String get taskReasonOverdue => 'Lampas na ang petsa ng gawaing ito.';

  @override
  String get taskReasonScan => 'Iminungkahi batay sa iyong pinakahuling scan.';

  @override
  String get taskReasonRoutine => 'Mga regular na gawain sa bukid.';

  @override
  String get taskRelatedScan => 'Kaugnay na scan';

  @override
  String get carePlanSuggested => 'Iminungkahi para sa iyo';

  @override
  String get carePlanAddToCalendar => 'Idagdag sa kalendaryo';

  @override
  String get carePlanAdded => 'Idinagdag na sa iyong field calendar';

  @override
  String get carePlanReasonWeather => 'Panahon';

  @override
  String get carePlanReasonOverdue => 'Lampas na';

  @override
  String get carePlanReasonScan => 'Mula sa scan';

  @override
  String get carePlanReasonRoutine => 'Regular';

  @override
  String get scanResultAddedToCalendar =>
      'Idinagdag na sa iyong field calendar';

  @override
  String get viewCalendar => 'Tingnan ang kalendaryo';

  @override
  String carePlanSuggestionTitle(String crop, String diagnosis) {
    return 'Suriin muli ang $crop pagkatapos ng $diagnosis';
  }

  @override
  String get agriProFreePlanSummary =>
      '5 scan bawat linggo, simpleng kalendaryo.';

  @override
  String get agriProFeatureUnlimited => 'Walang limitasyong scan';

  @override
  String get agriProFeaturePriority => 'Prayoridad na pagsusuri';

  @override
  String get agriProFeatureTrends => 'Mga trend ng kalusugan';

  @override
  String get agriProFeatureWeather => 'Mga paalala na inayon sa panahon';

  @override
  String get agriProFeatureOffline => 'Offline na pakete';

  @override
  String get agriProPlanMonthly => 'Buwanan';

  @override
  String get agriProPlanSeasonal => 'Panahon ng tanim';

  @override
  String get agriProPlanSeasonTagline =>
      'Isang panahon ng tanim, anim na buwan ng walang limitasyong scan.';

  @override
  String get agriProPlanMonthlyTagline => 'Subukan ang Agri Pro buwan-buwan.';

  @override
  String get agriProPriceMonthly => '₱99/buwan';

  @override
  String get agriProPriceSeasonal => '₱499/6 na buwan';

  @override
  String get agriProPerDay => '₱3 kada araw';

  @override
  String get agriProSavePercent => 'Makatipid ng 16%';

  @override
  String get agriProPlanRenewsMonthly => 'Nagre-renew buwan-buwan sa ₱99.';

  @override
  String get agriProPlanRenewsSeasonal =>
      'Nagre-renew kada anim na buwan sa ₱499.';

  @override
  String get agriProCancelAnytime => 'Kanselahin anumang oras.';

  @override
  String get agriProPaymentNote =>
      'Kasama na ang VAT sa presyo. Ang bayad ay dumadaan sa Google Play o App Store.';

  @override
  String get startAgriPro => 'Simulan ang Agri Pro';

  @override
  String get agriProManageTitle => 'Pamahalaan ang Agri Pro';

  @override
  String get agriProManageCurrentPlan => 'Kasalukuyang plano';

  @override
  String get agriProManageRenewal => 'Pag-renew';

  @override
  String get agriProManageBilling => 'Pagbayad';

  @override
  String get agriProManageBilledBy => 'Pinamamahalaan ng iyong app store.';

  @override
  String get agriProManageCancelHow =>
      'Upang kanselahin, buksan ang Google Play → Subscriptions → Smart Crops, o ang App Store → Subscriptions. Mananatili ang access hanggang sa matapos ang bayad na panahon.';

  @override
  String get agriProRestore => 'Ibalik ang bili';

  @override
  String get agriProPurchaseRestored => 'Naibalik ang bili.';

  @override
  String get billingNotConfigured =>
      'Hindi pa available ang pagbili ng Agri Pro. Maaari kang bumili kapag live na ang store listing.';

  @override
  String get agriProPurchaseFailed =>
      'Hindi nagtagumpay ang bili. Pakisubukan ulit.';

  @override
  String get agriProUnlocked => 'Na-unlock ang Agri Pro.';

  @override
  String get agriProPlanActive => 'Agri Pro — Aktibo';

  @override
  String get agriProPlanFree => 'Libre';

  @override
  String get agriProManageUpgradeTitle => 'Nasa Free plan ka';

  @override
  String get agriProManageFreeSummary =>
      'Mag-upgrade para sa walang limitasyong scan.';

  @override
  String get agriProManageProSummary =>
      'May walang limitasyong scan at prayoridad na pagsusuri ka.';

  @override
  String get agriProManageUpgradeCta => 'Tingnan ang mga planong Agri Pro';

  @override
  String get agriProRenewalNever => 'Hanggang sa magkansela ka';

  @override
  String agriProQuotaContext(int used, int limit) {
    return 'Nagamit mo na ang $used sa $limit libreng scan ngayong linggo. Tinatanggal ng Agri Pro ang limitasyon.';
  }

  @override
  String get shopSearchHint =>
      'Maghanap ng produkto, tindahan, o sakit ng pananim';

  @override
  String get shopAll => 'Lahat';

  @override
  String get shopCategoryOrganic => 'Organiko';

  @override
  String get shopCategoryFungicide => 'Fungicide';

  @override
  String get shopCategoryFertilizer => 'Abono';

  @override
  String get shopCategoryPestControl => 'Panlaban sa peste';

  @override
  String get shopPartnerDisclosureTitle => 'Pagsisiwalat bilang partner';

  @override
  String get shopPartnerDisclosureBody =>
      'Maaaring makatanggap ang Agri Lynk ng komisyon sa mga pabilang sa pamamagitan ng mga link ng partner, nang walang dagdag na bayad sa iyo. Ipinapakita lamang ng Agri Lynk ang mga produktong tumutugma sa iyong kamakailang diagnosis ng pananim. Laging sundin ang label ng produkto, at kapag hindi sigurado, kumosulta sa isang extension officer.';

  @override
  String get shopContinueToMerchant => 'Magpatuloy sa tindahan';

  @override
  String get shopGoToMerchant => 'Pumunta sa tindahan';

  @override
  String get shopWhyMatchesHeader => 'Bakit ang produktong ito';

  @override
  String shopCommonlyFor(String disease) {
    return 'Karaniwang ginagamit sa mga bukid sa Pilipinas para sa $disease.';
  }

  @override
  String get shopSafetyCopy =>
      'Laging sundin ang label ng produkto. Kapag hindi sigurado, kumosulta sa extension officer bago gamitin.';

  @override
  String get shopSeeProductsFor =>
      'Tingnan ang mga produkto para sa diagnosis na ito';

  @override
  String get shopCouldNotLoad => 'Hindi ma-load ang mga produkto';

  @override
  String get shopEmptyAll =>
      'Lalabas ang mga produkto rito habang nagdaragdag ng mga partner.';

  @override
  String get shopProfileSubtitle =>
      'Mga partner product na tumutugma sa iyong diagnosis';

  @override
  String get scanDemoBannerTitle => 'Demo na diagnosis';

  @override
  String get scanDemoBannerBody =>
      'Hindi nakasagot ang Smart Crops AI para sa larawang ito kaya ito ay malinaw na may labeling na sample na resulta. Itanggap ang gabay na ito bilang mungkahi lamang at i-verify sa iyong barangay o municipal agricultural technologist. Lalabas ang live na AI result sa sandaling bumalik ang serbisyo.';

  @override
  String get scanDetailCause => 'Bakit ito nangyayari';

  @override
  String get scanDetailSymptoms => 'Kung ano ang mapapansin';

  @override
  String get scanDetailPrevention => 'Paano maiiwasan';

  @override
  String get scanDetailExpertNote => 'Kailan tatawag sa eksperto';

  @override
  String get cropCareTagline => 'Matalinong Scan. Malusog na Pananim.';

  @override
  String get cropCareGoodMorning => 'Magandang umaga,';

  @override
  String get cropCareFarmerExclaim => 'Magsasaka!';

  @override
  String get cropCareKeepCropsHealthy =>
      'Panatilihing malusog ang iyong mga pananim.';

  @override
  String get cropCareScanDetectProtect => 'I-scan. Alamin. Protektahan.';

  @override
  String get cropCareScanYourCrop => 'I-scan ang Pananim';

  @override
  String get cropCareQuickAccess => 'Mabilis na Access';

  @override
  String get cropCareHome => 'Unahang Pahina';

  @override
  String get cropCareScan => 'I-scan';

  @override
  String get cropCareHistory => 'Kasaysayan';

  @override
  String get cropCareProfile => 'Profile';

  @override
  String get cropCareCrops => 'Mga Pananim';

  @override
  String get cropCareSupport => 'Suporta';

  @override
  String get cropCareSettings => 'Mga Setting';

  @override
  String get cropCareNotifications => 'Mga Abiso';

  @override
  String get cropCareAdvisoriesAndReminders =>
      'Mga paalala sa abiso at pag-scan';

  @override
  String get cropCareLanguage => 'Wika';

  @override
  String get cropCareEnglish => 'Ingles';

  @override
  String get cropCareScanCropTitle => 'I-scan ang Pananim';

  @override
  String get cropCareFillFrameHint => 'Ikasya ang apektadong dahon sa frame';

  @override
  String get cropCareImport => 'Mag-import';

  @override
  String get cropCareFlash => 'Flash';

  @override
  String get cropCareHoldSteady =>
      'Pitagin nang mahinahon. Ang malinaw na larawan ay mas kapaki-pakinabang.';

  @override
  String get cropCareScanResult => 'Resulta ng Scan';

  @override
  String get cropCareHealthy => 'Malusog';

  @override
  String get cropCareNoDiseaseDetected => 'Walang natukoy na sakit';

  @override
  String get cropCareScannedToday => 'ina-scan ngayong araw';

  @override
  String get cropCareConfidence => 'kumpiyansa';

  @override
  String get cropCareWhatNext => 'Mga susunod na hakbang';

  @override
  String get cropCareKeepWateringMorning => 'Magdidilig sa umaga';

  @override
  String get cropCareCheckSoilBeforeIrrigation =>
      'Suriin ang lupa bago ang susunod na pagdidilig.';

  @override
  String get cropCareWatchNewSpots => 'Bantayan ang mga bagong mantsa';

  @override
  String get cropCareScanAgainWeek =>
      'Mag-scan muli pagkatapos ng pitong araw o mas maaga kung magbago ang dahon.';

  @override
  String get cropCareSaveToHealthLog => 'I-save sa Health Log';

  @override
  String get cropCareScanAgain => 'Mag-scan muli';

  @override
  String get cropCareScanHistory => 'Kasaysayan ng Scan';

  @override
  String get cropCareNeedsAttention => 'Kailangan ng atensyon';

  @override
  String get cropCareToday => 'Ngayon';

  @override
  String cropCareDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count araw ang nakararaan',
      one: '1 araw ang nakararaan',
    );
    return '$_temp0';
  }

  @override
  String get cropCareLastWeek => 'Noong nakaraang linggo';

  @override
  String get cropCareLeafSpots => 'mga mantsa sa dahon';

  @override
  String get cropCareFarm => 'Bukid';

  @override
  String get cropCareFarmer => 'Magsasaka';

  @override
  String get cropCareMainCrops => 'Pangunahing pananim';

  @override
  String cropCareCropCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pananim',
      one: '1 pananim',
    );
    return '$_temp0';
  }

  @override
  String get cropCareYourCrops => 'Iyong mga Pananim';

  @override
  String get cropCareNoRecentDisease =>
      'Walang natukoy na sakit sa mga kamakailang scan.';

  @override
  String get cropCareKeepSoilHealthy => 'Panatilihing malusog ang lupa';

  @override
  String get cropCareHealthySoilBody =>
      'Ang malusog na lupa ay nagbibigay ng mas malakas na pananim.';

  @override
  String get authTrustEyebrow => 'Smart Crops ng Agri Lynk';

  @override
  String get authTrustTitle => 'Maligayang pagdating sa iyong field office.';

  @override
  String get authTrustBody => 'Pribado ang datos ng iyong bukid.';

  @override
  String get advisoriesCriticalLabel => 'Kritikal na advisory';

  @override
  String get agriProComparePlan => 'Plano';

  @override
  String get agriProComparePrice => 'Presyo';

  @override
  String get agriProCompareIncludes => 'Ano ang kasama';

  @override
  String get agriProPriceFree => '₱0';

  @override
  String get authPromiseBody =>
      'I-scan ang dahon, alamin ang sakit at plano ng pag-aalaga, sa Tagalog, Cebuano o English.';

  @override
  String get authPhoneHelper =>
      'Padadalhan ka namin ng 6-digit na code sa SMS.';

  @override
  String get authPhoneInvalid =>
      'Maglagay ng 11-digit na mobile number na nagsisimula sa 09.';

  @override
  String authCodeSentTo(String phone) {
    return 'Ipinadala sa SMS sa $phone';
  }

  @override
  String get authChangeNumber => 'Palitan ang numero';

  @override
  String authResendIn(int seconds) {
    return 'Ipadala muli sa loob ng ${seconds}s';
  }

  @override
  String get authResendCode => 'Ipadala muli ang code';

  @override
  String get authErrorBadCode =>
      'Mali o expired na ang code. Tingnan ang SMS o magpadala ng bago.';

  @override
  String authErrorTooManyWait(int seconds) {
    return 'Masyadong maraming subok. Subukang muli sa loob ng ${seconds}s.';
  }

  @override
  String get authErrorTooMany =>
      'Masyadong maraming subok. Maghintay ng isang minuto at subukang muli.';

  @override
  String get authErrorUnreachable =>
      'Hindi kami makapagpadala ng code sa numerong ito. Suriin ito at subukang muli.';

  @override
  String get authErrorOffline =>
      'Walang koneksyon. Tingnan ang iyong mobile data at subukang muli.';

  @override
  String get authErrorGeneric => 'May nangyaring mali. Subukang muli.';

  @override
  String get authOtherWays => 'Ibang paraan ng pag-sign in';

  @override
  String get authBack => 'Bumalik';

  @override
  String onboardingProgress(int current, int total) {
    return 'Hakbang $current sa $total';
  }

  @override
  String get onboardingExampleForecast => 'Uulan bukas';

  @override
  String get onboardingExampleTask => 'Inilipat sa Huwebes ang pag-spray';
}
