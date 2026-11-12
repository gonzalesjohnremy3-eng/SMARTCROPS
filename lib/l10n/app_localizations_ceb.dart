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
  String get notNow => 'Di Karon';

  @override
  String get completeSetup => 'Kompletoha ang Setup';

  @override
  String get homeFieldbriefing => 'Field Briefing Karon';

  @override
  String get homePriorityaction => 'Pangunahing Lakang';

  @override
  String get homeScancta => 'I-scan ang Tanom';

  @override
  String get homeCareplan => 'Care Plan Sa Semana Karon';

  @override
  String get homeRecentscans => 'Mga Miaging Diagnosis';

  @override
  String get homeEmptyfarm =>
      'Andam na ang imong field office. Kuhaa ang una nga scan aron sugdan ang health record sa imong tanom.';

  @override
  String get homeMonitoring =>
      'Luwas tanan. Padayon namo bantayan ang imong mga tanom.';

  @override
  String get cropsTitle => 'Akong mga Tanom';

  @override
  String get cropsAddcrop => 'Magdugang og Tanom';

  @override
  String get cropsEmpty =>
      'Wala pay tanom. Magdugang ug una nga tanom para sa personalisadong atiman.';

  @override
  String get cropDetailCareguide => 'Gabay sa Atiman';

  @override
  String get cropDetailGrowingconditions => 'Kondisyon sa Paglago';

  @override
  String get cropDetailGrowthtimeline => 'Timeline sa Paglago';

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
  String get scanResultTreatmentsteps => 'Mga Lakang sa Tambal';

  @override
  String get scanResultAddtocalendar => 'Idugang sa Kalendaryo sa Uma';

  @override
  String get scanResultSetreminder => 'Butangi og Pahinumdom';

  @override
  String get scanResultShare => 'Ibahin';

  @override
  String get scanResultLowconfidenceretake =>
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
  String get calendarWeatheradjusted => 'Naayon sa panahon';

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
  String get carePlanThisweek => 'Semana Karon';

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
  String get notificationsScanresults => 'Mga Resulta sa Scan';

  @override
  String get notificationsWeatheradvisories => 'Mga Abiso sa Panahon';

  @override
  String get notificationsCalendarreminders => 'Mga Pahinumdom sa Kalendaryo';

  @override
  String get notificationsCooperativeadvisories => 'Mga Abiso sa Kooperatiba';

  @override
  String get notificationsQuiethours => 'Mga Tahimik nga Oras';

  @override
  String get agriProTitle => 'Agri Pro';

  @override
  String get agriProHeadline => 'Pangtagaan og daghan ang imong ginatanom.';

  @override
  String get agriProFreesummary =>
      'Gawas nga plano: 5 scan/semana, basic kalendaryo.';

  @override
  String get agriProProsummary =>
      'Agri Pro: walay limit nga scan, priority nga pagsusi, trend sa kalawasan, weather-adjusted nga paalala, offline pack.';

  @override
  String get agriProMonthly => 'Kada Buwan';

  @override
  String get agriProSeasonal => 'Pang-season (6 ka buwan)';

  @override
  String get agriProStart => 'Sugda ang Agri Pro';

  @override
  String get agriProNotnow => 'Di karon';

  @override
  String get shopTitle => 'Agri Shop';

  @override
  String get shopPartneroffer => 'Alok sa partner';

  @override
  String get shopEmpty =>
      'Wala matugmang produkto para niini nga diagnosis. Moobra gihapon ang imong care plan bisan wala sila.';

  @override
  String get cooperativeTitle => 'Kooperatiba Hub';

  @override
  String get cooperativeJoin => 'Mosalapi sa Kooperatiba';

  @override
  String get cooperativeInvitecode => 'Kodigo sa Patawag';

  @override
  String get cooperativeMembers => 'Mga Miyembro';

  @override
  String get cooperativeBroadcasts => 'Mga Broadcast';

  @override
  String get cooperativeOutbreaksummary => 'Summary sa Pagkalat';

  @override
  String get severityHealthy => 'Malipayon';

  @override
  String get severityWatch => 'Bantayi';

  @override
  String get severityAtrisk => 'Nasa Danger';

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
  String get offlineScanqueued =>
      'Na-save. Susihon namo kini kung naa na kay koneksyon.';

  @override
  String get viewAll => 'Tan-awa ang tanan';

  @override
  String get homePriorityAction => 'Pangunahing Lakang';

  @override
  String get homeCarePlan => 'Care Plan Sa Semana Karon';

  @override
  String get homeRecentScans => 'Mga Miaging Diagnosis';

  @override
  String get homeScanCTA => 'I-scan ang Tanom';

  @override
  String get homeFieldBriefing => 'Field Briefing Karon';

  @override
  String get calendarSetReminder => 'Magbutang og Pahinumdom';
}
