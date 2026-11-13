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
  String get onboardingTitle1 => 'Protektahan ang Ani';

  @override
  String get onboardingBody1 =>
      'Tutulungan ka ng Smart Crops na maagap na matukoy ang mga suliranin sa pananim upang maprotektahan ang iyong ani.';

  @override
  String get onboardingTitle2 => 'I-scan at Malaman';

  @override
  String get onboardingBody2 =>
      'Kunan ng litrato ang iyong pananim at makuha agad ang diagnosis na may malinaw susunod na hakbang.';

  @override
  String get onboardingTitle3 => 'Magplano ayon sa Panahon';

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
  String get notNow => 'Hindi Muna';

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
      'Protektahan nang higit pa ang iyong pinag-aanihan.';

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
  String get authTagline => 'Tuklasin nang Maaga. Protektahan ang Iyong Ani.';

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
  String get authOtpMobile => 'Numero ng Mobile (+63...)';

  @override
  String get authOtpCode => 'Ilagay ang OTP Code';

  @override
  String get authSendOtp => 'Ipadala ang OTP';

  @override
  String get authVerifyOtp => 'Patunayan ang OTP';

  @override
  String get authOtpTitle => 'Login gamit ang Telepono (OTP)';

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
}
