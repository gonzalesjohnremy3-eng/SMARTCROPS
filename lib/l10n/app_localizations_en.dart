// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Smart Crops by Agri Lynk';

  @override
  String get scanCrop => 'Scan crop';

  @override
  String get fieldCalendar => 'Field Calendar';

  @override
  String get scanQueuedOffline =>
      'Saved. We\'ll analyze this when you\'re back online.';

  @override
  String cropsSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count crops selected',
      one: '1 crop selected',
      zero: 'No crops selected',
    );
    return '$_temp0';
  }

  @override
  String get skip => 'Skip';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get getStarted => 'Get Started';

  @override
  String get onboardingTitle1 => 'Protect Your Harvest';

  @override
  String get onboardingBody1 =>
      'Smart Crops helps you detect crop problems early so you can protect your harvest.';

  @override
  String get onboardingTitle2 => 'Scan and Know';

  @override
  String get onboardingBody2 =>
      'Take a photo of your crop and get an instant diagnosis with clear next steps.';

  @override
  String get onboardingTitle3 => 'Plan with Weather';

  @override
  String get onboardingBody3 =>
      'Your Field Calendar adjusts tasks based on the forecast so you never waste effort.';

  @override
  String get profileSetupStep1Title => 'About You';

  @override
  String get profileSetupStep1Subtitle =>
      'Tell us about yourself and your farm';

  @override
  String get fullName => 'Full Name';

  @override
  String get farmName => 'Farm Name';

  @override
  String get location => 'Location';

  @override
  String get phoneNumber => 'Phone Number (optional)';

  @override
  String get profileSetupStep2Title => 'Your Main Crops';

  @override
  String get profileSetupStep2Subtitle =>
      'Select the crops you grow so we can personalize your care';

  @override
  String get searchCrops => 'Search crops';

  @override
  String get profileSetupStep3Title => 'Permissions';

  @override
  String get profileSetupStep3Subtitle =>
      'Allow access so we can give you the best experience';

  @override
  String get cameraPermission => 'Camera';

  @override
  String get cameraPermissionDescription => 'Required to scan your crops';

  @override
  String get locationPermission => 'Location';

  @override
  String get locationPermissionDescription =>
      'Used for local weather and advisories';

  @override
  String get notificationsPermission => 'Notifications';

  @override
  String get notificationsPermissionDescription =>
      'Get alerts for weather risks and scan results';

  @override
  String get allow => 'Allow';

  @override
  String get notNow => 'Not Now';

  @override
  String get completeSetup => 'Complete Setup';

  @override
  String get homeFieldbriefing => 'Today\'s Field Briefing';

  @override
  String get homePriorityaction => 'Priority Action';

  @override
  String get homeScancta => 'Scan a Crop';

  @override
  String get homeCareplan => 'This Week\'s Care Plan';

  @override
  String get homeRecentscans => 'Recent Diagnoses';

  @override
  String get homeEmptyfarm =>
      'Your field office is ready. Take your first scan to start your crop\'s health record.';

  @override
  String get homeMonitoring => 'All clear. We\'ll keep monitoring your crops.';

  @override
  String get cropsTitle => 'My Crops';

  @override
  String get cropsAddcrop => 'Add a Crop';

  @override
  String get cropsEmpty =>
      'No crops yet. Add your first crop to get personalized care.';

  @override
  String get cropDetailCareguide => 'Care Guide';

  @override
  String get cropDetailGrowingconditions => 'Growing Conditions';

  @override
  String get cropDetailGrowthtimeline => 'Growth Timeline';

  @override
  String get scanCaptureTitle => 'Scan Your Crop';

  @override
  String get scanCaptureGuidance =>
      'Fill the frame with one leaf. Avoid shadows.';

  @override
  String get scanReviewTitle => 'Review Your Photo';

  @override
  String get scanReviewRetake => 'Retake';

  @override
  String get scanReviewAnalyze => 'Analyze';

  @override
  String get scanAnalyzing => 'Analyzing your crop...';

  @override
  String get scanResultTitle => 'Scan Result';

  @override
  String get scanResultConfidence => 'Confidence';

  @override
  String get scanResultSeverity => 'Severity';

  @override
  String get scanResultDiagnosis => 'Diagnosis';

  @override
  String get scanResultTreatmentsteps => 'Treatment Steps';

  @override
  String get scanResultAddtocalendar => 'Add to Field Calendar';

  @override
  String get scanResultSetreminder => 'Set Reminder';

  @override
  String get scanResultShare => 'Share';

  @override
  String get scanResultLowconfidenceretake => 'Retake in better light';

  @override
  String get calendarTitle => 'Field Calendar';

  @override
  String get calendarToday => 'Today';

  @override
  String get calendarWeek => 'This Week';

  @override
  String get calendarMonth => 'Month';

  @override
  String get calendarTaskCompleted => 'Completed';

  @override
  String get calendarWeatheradjusted => 'Weather-adjusted';

  @override
  String get advisoriesTitle => 'Advisories';

  @override
  String get advisoriesEmpty =>
      'No advisories yet. We\'ll tell you when something needs attention.';

  @override
  String get carePlanTitle => 'Care Plan';

  @override
  String get carePlanToday => 'Today';

  @override
  String get carePlanThisweek => 'This Week';

  @override
  String get carePlanPreventive => 'Preventive';

  @override
  String get carePlanEmpty =>
      'Your plan will appear after your first scan or when your crops need care.';

  @override
  String get healthLogTitle => 'Health Log';

  @override
  String get healthLogEmpty =>
      'No scans yet. Your first diagnosis starts here.';

  @override
  String get profileTitle => 'Farmer Profile';

  @override
  String get profileEdit => 'Edit Profile';

  @override
  String get profileCrops => 'Main Crops';

  @override
  String get profileLanguage => 'Language';

  @override
  String get profileNotifications => 'Notifications';

  @override
  String get profileAgripro => 'Agri Pro';

  @override
  String get profileCooperative => 'Cooperative Hub';

  @override
  String get profilePrivacy => 'Privacy and Data';

  @override
  String get profileHelp => 'Help and Support';

  @override
  String get profileAbout => 'About';

  @override
  String get profileSignout => 'Sign Out';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageTagalog => 'Tagalog';

  @override
  String get languageCebuano => 'Cebuano';

  @override
  String get notificationsScanresults => 'Scan Results';

  @override
  String get notificationsWeatheradvisories => 'Weather Advisories';

  @override
  String get notificationsCalendarreminders => 'Calendar Reminders';

  @override
  String get notificationsCooperativeadvisories => 'Cooperative Advisories';

  @override
  String get notificationsQuiethours => 'Quiet Hours';

  @override
  String get agriProTitle => 'Agri Pro';

  @override
  String get agriProHeadline => 'Protect more of what you grow.';

  @override
  String get agriProFreesummary => 'Free plan: 5 scans/week, basic calendar.';

  @override
  String get agriProProsummary =>
      'Agri Pro: unlimited scans, priority analysis, health trends, weather-adjusted reminders, offline pack.';

  @override
  String get agriProMonthly => 'Monthly';

  @override
  String get agriProSeasonal => 'Seasonal (6 months)';

  @override
  String get agriProStart => 'Start Agri Pro';

  @override
  String get agriProNotnow => 'Not now';

  @override
  String get shopTitle => 'Agri Shop';

  @override
  String get shopPartneroffer => 'Partner offer';

  @override
  String get shopEmpty =>
      'No matching products for this diagnosis. Your care plan still works without them.';

  @override
  String get cooperativeTitle => 'Cooperative Hub';

  @override
  String get cooperativeJoin => 'Join a Cooperative';

  @override
  String get cooperativeInvitecode => 'Invite Code';

  @override
  String get cooperativeMembers => 'Members';

  @override
  String get cooperativeBroadcasts => 'Broadcasts';

  @override
  String get cooperativeOutbreaksummary => 'Outbreak Summary';

  @override
  String get severityHealthy => 'Healthy';

  @override
  String get severityWatch => 'Watch';

  @override
  String get severityAtrisk => 'At Risk';

  @override
  String get confidenceHigh => 'High';

  @override
  String get confidenceMedium => 'Medium';

  @override
  String get confidenceLow => 'Low';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorNetwork =>
      'No connection. Check your internet and try again.';

  @override
  String get errorPermission => 'Permission denied. Please enable in settings.';

  @override
  String get retry => 'Try Again';

  @override
  String get offlineBanner => 'You\'re offline. Showing cached data.';

  @override
  String get offlineScanqueued =>
      'Saved. We\'ll analyze this when you\'re back online.';

  @override
  String get viewAll => 'View all';

  @override
  String get homePriorityAction => 'Priority Action';

  @override
  String get homeCarePlan => 'This Week\'s Care Plan';

  @override
  String get homeRecentScans => 'Recent Diagnoses';

  @override
  String get homeScanCTA => 'Scan a Crop';

  @override
  String get homeFieldBriefing => 'Today\'s Field Briefing';

  @override
  String get calendarSetReminder => 'Set Reminder';
}
