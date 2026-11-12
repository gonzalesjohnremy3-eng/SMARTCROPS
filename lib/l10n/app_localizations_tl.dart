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
  String get homeFieldbriefing => 'Field Briefing Ngayon';

  @override
  String get homePriorityaction => 'Pangunahing Kilos';

  @override
  String get homeScancta => 'I-scan ang Pananim';

  @override
  String get homeCareplan => 'Care Plan Ng Linggang Ito';

  @override
  String get homeRecentscans => 'Mga Nakaraang Diagnosis';

  @override
  String get homeEmptyfarm =>
      'Handa na ang iyong field office. Kumuha ng unang scan upang simulan ang talaan ng kalusugan ng iyong pananim.';

  @override
  String get homeMonitoring =>
      'Ligtas lahat. Patuloy naming bantayan ang iyong mga pananim.';

  @override
  String get cropsTitle => 'Aking mga Pananim';

  @override
  String get cropsAddcrop => 'Magdagdag ng Pananim';

  @override
  String get cropsEmpty =>
      'Wala pang pananim. Magdagdag ng unang pananim para sa personalisadong alaga.';

  @override
  String get cropDetailCareguide => 'Gabay sa Alaga';

  @override
  String get cropDetailGrowingconditions => 'Kaugnayan sa Pagtubo';

  @override
  String get cropDetailGrowthtimeline => 'Timeline ng Paglago';

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
  String get scanResultTreatmentsteps => 'Mga Hakbang ng Gamot';

  @override
  String get scanResultAddtocalendar => 'Idagdag sa Kalendaryo ng Bukid';

  @override
  String get scanResultSetreminder => 'Maglagay ng Paalala';

  @override
  String get scanResultShare => 'Ibahagi';

  @override
  String get scanResultLowconfidenceretake =>
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
  String get calendarWeatheradjusted => 'Naaayon sa panahon';

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
  String get carePlanThisweek => 'Linggang Ito';

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
  String get notificationsScanresults => 'Mga Resulta ng Scan';

  @override
  String get notificationsWeatheradvisories => 'Mga Abiso sa Panahon';

  @override
  String get notificationsCalendarreminders => 'Mga Paalala sa Kalendaryo';

  @override
  String get notificationsCooperativeadvisories => 'Mga Abiso ng Kooperatiba';

  @override
  String get notificationsQuiethours => 'Mga Tahimik na Oras';

  @override
  String get agriProTitle => 'Agri Pro';

  @override
  String get agriProHeadline =>
      'Protektahan nang higit pa ang iyong pinag-aanihan.';

  @override
  String get agriProFreesummary =>
      'Libreng plano: 5 scan/linggo, batayan na kalendaryo.';

  @override
  String get agriProProsummary =>
      'Agri Pro: walang limit na scan, prayoridad na pagsusuri, trend ng kalusugan, paalala na naaayon sa panahon, offline pack.';

  @override
  String get agriProMonthly => 'Buwanan';

  @override
  String get agriProSeasonal => 'Pang-season (6 na buwan)';

  @override
  String get agriProStart => 'Simulan ang Agri Pro';

  @override
  String get agriProNotnow => 'Hindi muna';

  @override
  String get shopTitle => 'Agri Shop';

  @override
  String get shopPartneroffer => 'Alok ng partner';

  @override
  String get shopEmpty =>
      'Walang tumutugmang produkto para sa diagnosis ito. Gumagana pa rin ang iyong plano ng alaga nang walang mga ito.';

  @override
  String get cooperativeTitle => 'Kooperatiba Hub';

  @override
  String get cooperativeJoin => 'Sumapi sa Kooperatiba';

  @override
  String get cooperativeInvitecode => 'Kodigo ng Imbitasyon';

  @override
  String get cooperativeMembers => 'Mga Miyembro';

  @override
  String get cooperativeBroadcasts => 'Mga Broadcast';

  @override
  String get cooperativeOutbreaksummary => 'Buod ng Pagkalat';

  @override
  String get severityHealthy => 'Malusog';

  @override
  String get severityWatch => 'Bantayan';

  @override
  String get severityAtrisk => 'Nasa Panganib';

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
  String get offlineScanqueued =>
      'Nai-save. Susuriin namin ito kapag may koneksyon ka na.';

  @override
  String get viewAll => 'Tingnan ang lahat';

  @override
  String get homePriorityAction => 'Pangunahing Kilos';

  @override
  String get homeCarePlan => 'Care Plan Ng Linggang Ito';

  @override
  String get homeRecentScans => 'Mga Nakaraang Diagnosis';

  @override
  String get homeScanCTA => 'I-scan ang Pananim';

  @override
  String get homeFieldBriefing => 'Field Briefing Ngayon';

  @override
  String get calendarSetReminder => 'Maglagay ng Paalala';
}
