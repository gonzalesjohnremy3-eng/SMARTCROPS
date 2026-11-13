import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ceb.dart';
import 'app_localizations_en.dart';
import 'app_localizations_tl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ceb'),
    Locale('en'),
    Locale('tl'),
  ];

  /// Product name shown in the app and about screen
  ///
  /// In en, this message translates to:
  /// **'Smart Crops by Agri Lynk'**
  String get appTitle;

  /// Primary action to start a crop scan
  ///
  /// In en, this message translates to:
  /// **'Scan crop'**
  String get scanCrop;

  /// Name of the weather-aware task calendar
  ///
  /// In en, this message translates to:
  /// **'Field Calendar'**
  String get fieldCalendar;

  /// Confirmation shown when a scan is queued offline
  ///
  /// In en, this message translates to:
  /// **'Saved. We\'ll analyze this when you\'re back online.'**
  String get scanQueuedOffline;

  /// Number of Main Crops selected during profile setup
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No crops selected} =1{1 crop selected} other{{count} crops selected}}'**
  String cropsSelectedCount(int count);

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Protect Your Harvest'**
  String get onboardingTitle1;

  /// No description provided for @onboardingBody1.
  ///
  /// In en, this message translates to:
  /// **'Smart Crops helps you detect crop problems early so you can protect your harvest.'**
  String get onboardingBody1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Scan and Know'**
  String get onboardingTitle2;

  /// No description provided for @onboardingBody2.
  ///
  /// In en, this message translates to:
  /// **'Take a photo of your crop and get an instant diagnosis with clear next steps.'**
  String get onboardingBody2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Plan with Weather'**
  String get onboardingTitle3;

  /// No description provided for @onboardingBody3.
  ///
  /// In en, this message translates to:
  /// **'Your Field Calendar adjusts tasks based on the forecast so you never waste effort.'**
  String get onboardingBody3;

  /// No description provided for @profileSetupStep1Title.
  ///
  /// In en, this message translates to:
  /// **'About You'**
  String get profileSetupStep1Title;

  /// No description provided for @profileSetupStep1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us about yourself and your farm'**
  String get profileSetupStep1Subtitle;

  /// Farmer's full name field
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// Farm name field
  ///
  /// In en, this message translates to:
  /// **'Farm Name'**
  String get farmName;

  /// Farm location field
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// Phone number field
  ///
  /// In en, this message translates to:
  /// **'Phone Number (optional)'**
  String get phoneNumber;

  /// No description provided for @profileSetupStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Your Main Crops'**
  String get profileSetupStep2Title;

  /// No description provided for @profileSetupStep2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Select the crops you grow so we can personalize your care'**
  String get profileSetupStep2Subtitle;

  /// Search crops placeholder
  ///
  /// In en, this message translates to:
  /// **'Search crops'**
  String get searchCrops;

  /// No description provided for @profileSetupStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get profileSetupStep3Title;

  /// No description provided for @profileSetupStep3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Allow access so we can give you the best experience'**
  String get profileSetupStep3Subtitle;

  /// Camera permission label
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get cameraPermission;

  /// Camera permission description
  ///
  /// In en, this message translates to:
  /// **'Required to scan your crops'**
  String get cameraPermissionDescription;

  /// Location permission label
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationPermission;

  /// Location permission description
  ///
  /// In en, this message translates to:
  /// **'Used for local weather and advisories'**
  String get locationPermissionDescription;

  /// Notifications permission label
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsPermission;

  /// Notifications permission description
  ///
  /// In en, this message translates to:
  /// **'Get alerts for weather risks and scan results'**
  String get notificationsPermissionDescription;

  /// Allow permission button
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get allow;

  /// notNow
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// Complete profile setup button
  ///
  /// In en, this message translates to:
  /// **'Complete Setup'**
  String get completeSetup;

  /// homeFieldBriefing
  ///
  /// In en, this message translates to:
  /// **'Today\'s Field Briefing'**
  String get homeFieldBriefing;

  /// homePriorityAction
  ///
  /// In en, this message translates to:
  /// **'Priority Action'**
  String get homePriorityAction;

  /// No description provided for @homeScanCta.
  ///
  /// In en, this message translates to:
  /// **'Scan a Crop'**
  String get homeScanCta;

  /// homeCarePlan
  ///
  /// In en, this message translates to:
  /// **'This Week\'s Care Plan'**
  String get homeCarePlan;

  /// homeRecentScans
  ///
  /// In en, this message translates to:
  /// **'Recent Diagnoses'**
  String get homeRecentScans;

  /// No description provided for @homeEmptyFarm.
  ///
  /// In en, this message translates to:
  /// **'Your field office is ready. Take your first scan to start your crop\'s health record.'**
  String get homeEmptyFarm;

  /// No description provided for @homeMonitoring.
  ///
  /// In en, this message translates to:
  /// **'All clear. We\'ll keep monitoring your crops.'**
  String get homeMonitoring;

  /// No description provided for @cropsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Crops'**
  String get cropsTitle;

  /// No description provided for @cropsAddCrop.
  ///
  /// In en, this message translates to:
  /// **'Add a Crop'**
  String get cropsAddCrop;

  /// No description provided for @cropsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No crops yet. Add your first crop to get personalized care.'**
  String get cropsEmpty;

  /// No description provided for @cropDetailCareGuide.
  ///
  /// In en, this message translates to:
  /// **'Care Guide'**
  String get cropDetailCareGuide;

  /// No description provided for @cropDetailGrowingConditions.
  ///
  /// In en, this message translates to:
  /// **'Growing Conditions'**
  String get cropDetailGrowingConditions;

  /// No description provided for @cropDetailGrowthTimeline.
  ///
  /// In en, this message translates to:
  /// **'Growth Timeline'**
  String get cropDetailGrowthTimeline;

  /// No description provided for @scanCaptureTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan Your Crop'**
  String get scanCaptureTitle;

  /// No description provided for @scanCaptureGuidance.
  ///
  /// In en, this message translates to:
  /// **'Fill the frame with one leaf. Avoid shadows.'**
  String get scanCaptureGuidance;

  /// No description provided for @scanReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review Your Photo'**
  String get scanReviewTitle;

  /// No description provided for @scanReviewRetake.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get scanReviewRetake;

  /// No description provided for @scanReviewAnalyze.
  ///
  /// In en, this message translates to:
  /// **'Analyze'**
  String get scanReviewAnalyze;

  /// No description provided for @scanAnalyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing your crop...'**
  String get scanAnalyzing;

  /// No description provided for @scanResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan Result'**
  String get scanResultTitle;

  /// No description provided for @scanResultConfidence.
  ///
  /// In en, this message translates to:
  /// **'Confidence'**
  String get scanResultConfidence;

  /// No description provided for @scanResultSeverity.
  ///
  /// In en, this message translates to:
  /// **'Severity'**
  String get scanResultSeverity;

  /// No description provided for @scanResultDiagnosis.
  ///
  /// In en, this message translates to:
  /// **'Diagnosis'**
  String get scanResultDiagnosis;

  /// No description provided for @scanResultTreatmentSteps.
  ///
  /// In en, this message translates to:
  /// **'Treatment Steps'**
  String get scanResultTreatmentSteps;

  /// No description provided for @scanResultAddToCalendar.
  ///
  /// In en, this message translates to:
  /// **'Add to Field Calendar'**
  String get scanResultAddToCalendar;

  /// No description provided for @scanResultSetReminder.
  ///
  /// In en, this message translates to:
  /// **'Set Reminder'**
  String get scanResultSetReminder;

  /// No description provided for @scanResultShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get scanResultShare;

  /// No description provided for @scanResultLowConfidenceRetake.
  ///
  /// In en, this message translates to:
  /// **'Retake in better light'**
  String get scanResultLowConfidenceRetake;

  /// No description provided for @calendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Field Calendar'**
  String get calendarTitle;

  /// No description provided for @calendarToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get calendarToday;

  /// No description provided for @calendarWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get calendarWeek;

  /// No description provided for @calendarMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get calendarMonth;

  /// No description provided for @calendarTaskCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get calendarTaskCompleted;

  /// No description provided for @calendarWeatherAdjusted.
  ///
  /// In en, this message translates to:
  /// **'Weather-adjusted'**
  String get calendarWeatherAdjusted;

  /// No description provided for @advisoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Advisories'**
  String get advisoriesTitle;

  /// No description provided for @advisoriesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No advisories yet. We\'ll tell you when something needs attention.'**
  String get advisoriesEmpty;

  /// No description provided for @carePlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Care Plan'**
  String get carePlanTitle;

  /// No description provided for @carePlanToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get carePlanToday;

  /// No description provided for @carePlanThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get carePlanThisWeek;

  /// No description provided for @carePlanPreventive.
  ///
  /// In en, this message translates to:
  /// **'Preventive'**
  String get carePlanPreventive;

  /// No description provided for @carePlanEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your plan will appear after your first scan or when your crops need care.'**
  String get carePlanEmpty;

  /// No description provided for @healthLogTitle.
  ///
  /// In en, this message translates to:
  /// **'Health Log'**
  String get healthLogTitle;

  /// No description provided for @healthLogEmpty.
  ///
  /// In en, this message translates to:
  /// **'No scans yet. Your first diagnosis starts here.'**
  String get healthLogEmpty;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Farmer Profile'**
  String get profileTitle;

  /// No description provided for @profileEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get profileEdit;

  /// No description provided for @profileCrops.
  ///
  /// In en, this message translates to:
  /// **'Main Crops'**
  String get profileCrops;

  /// No description provided for @profileLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguage;

  /// No description provided for @profileNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get profileNotifications;

  /// No description provided for @profileAgripro.
  ///
  /// In en, this message translates to:
  /// **'Agri Pro'**
  String get profileAgripro;

  /// No description provided for @profileCooperative.
  ///
  /// In en, this message translates to:
  /// **'Cooperative Hub'**
  String get profileCooperative;

  /// No description provided for @profilePrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy and Data'**
  String get profilePrivacy;

  /// No description provided for @profileHelp.
  ///
  /// In en, this message translates to:
  /// **'Help and Support'**
  String get profileHelp;

  /// No description provided for @profileAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get profileAbout;

  /// No description provided for @profileSignout.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get profileSignout;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageTagalog.
  ///
  /// In en, this message translates to:
  /// **'Tagalog'**
  String get languageTagalog;

  /// No description provided for @languageCebuano.
  ///
  /// In en, this message translates to:
  /// **'Cebuano'**
  String get languageCebuano;

  /// No description provided for @notificationsScanResults.
  ///
  /// In en, this message translates to:
  /// **'Scan Results'**
  String get notificationsScanResults;

  /// No description provided for @notificationsWeatherAdvisories.
  ///
  /// In en, this message translates to:
  /// **'Weather Advisories'**
  String get notificationsWeatherAdvisories;

  /// No description provided for @notificationsCalendarReminders.
  ///
  /// In en, this message translates to:
  /// **'Calendar Reminders'**
  String get notificationsCalendarReminders;

  /// No description provided for @notificationsCooperativeAdvisories.
  ///
  /// In en, this message translates to:
  /// **'Cooperative Advisories'**
  String get notificationsCooperativeAdvisories;

  /// No description provided for @notificationsQuietHours.
  ///
  /// In en, this message translates to:
  /// **'Quiet Hours'**
  String get notificationsQuietHours;

  /// agriProTitle
  ///
  /// In en, this message translates to:
  /// **'Agri Pro'**
  String get agriProTitle;

  /// agriProHeadline
  ///
  /// In en, this message translates to:
  /// **'Protect more of what you grow.'**
  String get agriProHeadline;

  /// No description provided for @agriProFreeSummary.
  ///
  /// In en, this message translates to:
  /// **'Free plan: 5 scans/week, basic calendar.'**
  String get agriProFreeSummary;

  /// No description provided for @agriProProSummary.
  ///
  /// In en, this message translates to:
  /// **'Agri Pro: unlimited scans, priority analysis, health trends, weather-adjusted reminders, offline pack.'**
  String get agriProProSummary;

  /// No description provided for @agriProMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get agriProMonthly;

  /// No description provided for @agriProSeasonal.
  ///
  /// In en, this message translates to:
  /// **'Seasonal (6 months)'**
  String get agriProSeasonal;

  /// No description provided for @agriProStart.
  ///
  /// In en, this message translates to:
  /// **'Start Agri Pro'**
  String get agriProStart;

  /// No description provided for @agriProNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get agriProNotNow;

  /// No description provided for @shopTitle.
  ///
  /// In en, this message translates to:
  /// **'Agri Shop'**
  String get shopTitle;

  /// No description provided for @shopPartnerOffer.
  ///
  /// In en, this message translates to:
  /// **'Partner offer'**
  String get shopPartnerOffer;

  /// No description provided for @shopEmpty.
  ///
  /// In en, this message translates to:
  /// **'No matching products for this diagnosis. Your care plan still works without them.'**
  String get shopEmpty;

  /// No description provided for @cooperativeTitle.
  ///
  /// In en, this message translates to:
  /// **'Cooperative Hub'**
  String get cooperativeTitle;

  /// No description provided for @cooperativeJoin.
  ///
  /// In en, this message translates to:
  /// **'Join a Cooperative'**
  String get cooperativeJoin;

  /// No description provided for @cooperativeInviteCode.
  ///
  /// In en, this message translates to:
  /// **'Invite Code'**
  String get cooperativeInviteCode;

  /// No description provided for @cooperativeMembers.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get cooperativeMembers;

  /// No description provided for @cooperativeBroadcasts.
  ///
  /// In en, this message translates to:
  /// **'Broadcasts'**
  String get cooperativeBroadcasts;

  /// No description provided for @cooperativeOutbreakSummary.
  ///
  /// In en, this message translates to:
  /// **'Outbreak Summary'**
  String get cooperativeOutbreakSummary;

  /// No description provided for @severityHealthy.
  ///
  /// In en, this message translates to:
  /// **'Healthy'**
  String get severityHealthy;

  /// No description provided for @severityWatch.
  ///
  /// In en, this message translates to:
  /// **'Watch'**
  String get severityWatch;

  /// No description provided for @severityAtRisk.
  ///
  /// In en, this message translates to:
  /// **'At Risk'**
  String get severityAtRisk;

  /// No description provided for @confidenceHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get confidenceHigh;

  /// No description provided for @confidenceMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get confidenceMedium;

  /// No description provided for @confidenceLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get confidenceLow;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No connection. Check your internet and try again.'**
  String get errorNetwork;

  /// No description provided for @errorPermission.
  ///
  /// In en, this message translates to:
  /// **'Permission denied. Please enable in settings.'**
  String get errorPermission;

  /// Retry button
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get retry;

  /// No description provided for @offlineBanner.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. Showing cached data.'**
  String get offlineBanner;

  /// No description provided for @offlineScanQueued.
  ///
  /// In en, this message translates to:
  /// **'Saved. We\'ll analyze this when you\'re back online.'**
  String get offlineScanQueued;

  /// viewAll
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// homeScanCTA
  ///
  /// In en, this message translates to:
  /// **'Scan a Crop'**
  String get homeScanCTA;

  /// calendarSetReminder
  ///
  /// In en, this message translates to:
  /// **'Set Reminder'**
  String get calendarSetReminder;

  /// homeCriticalWeatherTitle
  ///
  /// In en, this message translates to:
  /// **'Critical weather'**
  String get homeCriticalWeatherTitle;

  /// homeCriticalWeatherBody
  ///
  /// In en, this message translates to:
  /// **'Storm or high-wind conditions expected. Secure your crops and structures.'**
  String get homeCriticalWeatherBody;

  /// homeOverdueTaskTitle
  ///
  /// In en, this message translates to:
  /// **'Overdue tasks'**
  String get homeOverdueTaskTitle;

  /// homeOverdueTaskBody
  ///
  /// In en, this message translates to:
  /// **'You have tasks past their scheduled date. Open the Field Calendar to catch up.'**
  String get homeOverdueTaskBody;

  /// homeAtRiskDiagnosisTitle
  ///
  /// In en, this message translates to:
  /// **'Crop needs attention'**
  String get homeAtRiskDiagnosisTitle;

  /// homeAtRiskDiagnosisBody
  ///
  /// In en, this message translates to:
  /// **'A recent scan found a problem that needs action. Review the Health Log.'**
  String get homeAtRiskDiagnosisBody;

  /// homeRoutineCareTitle
  ///
  /// In en, this message translates to:
  /// **'Care needed'**
  String get homeRoutineCareTitle;

  /// homeRoutineCareBody
  ///
  /// In en, this message translates to:
  /// **'You have care tasks waiting this week.'**
  String get homeRoutineCareBody;

  /// homeEmptyFarmTitle
  ///
  /// In en, this message translates to:
  /// **'Your field office is ready'**
  String get homeEmptyFarmTitle;

  /// homeMonitorTitle
  ///
  /// In en, this message translates to:
  /// **'All clear'**
  String get homeMonitorTitle;

  /// cropsScanThisCrop
  ///
  /// In en, this message translates to:
  /// **'Scan this crop'**
  String get cropsScanThisCrop;

  /// cropsLastScan
  ///
  /// In en, this message translates to:
  /// **'Last scan'**
  String get cropsLastScan;

  /// cropsNoScans
  ///
  /// In en, this message translates to:
  /// **'Not scanned yet'**
  String get cropsNoScans;

  /// cropsGrowingConditions
  ///
  /// In en, this message translates to:
  /// **'Growing conditions'**
  String get cropsGrowingConditions;

  /// cropsInOptimal
  ///
  /// In en, this message translates to:
  /// **'Within optimal range'**
  String get cropsInOptimal;

  /// cropsTapToScan
  ///
  /// In en, this message translates to:
  /// **'Tap a crop to scan it'**
  String get cropsTapToScan;

  /// Shown when honest crop data is missing
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get cropDetailNotAvailable;

  /// Crop detail scan history section
  ///
  /// In en, this message translates to:
  /// **'Your scans for this crop'**
  String get cropDetailYourScans;

  /// Crop detail upcoming tasks section
  ///
  /// In en, this message translates to:
  /// **'Upcoming tasks'**
  String get cropDetailUpcomingTasks;

  /// Crop detail link to the field calendar
  ///
  /// In en, this message translates to:
  /// **'Open calendar'**
  String get cropDetailOpenCalendar;

  /// calendarViewToday
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get calendarViewToday;

  /// calendarViewWeek
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get calendarViewWeek;

  /// calendarViewMonth
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get calendarViewMonth;

  /// calendarEmpty
  ///
  /// In en, this message translates to:
  /// **'No tasks yet. Your plan will appear here.'**
  String get calendarEmpty;

  /// calendarCompleteTask
  ///
  /// In en, this message translates to:
  /// **'Mark done'**
  String get calendarCompleteTask;

  /// calendarOverdue
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get calendarOverdue;

  /// calendarUpcoming
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get calendarUpcoming;

  /// advisoriesMarkAllRead
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get advisoriesMarkAllRead;

  /// advisoriesMarkRead
  ///
  /// In en, this message translates to:
  /// **'Mark read'**
  String get advisoriesMarkRead;

  /// advisoriesSource
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get advisoriesSource;

  /// advisoriesUnread
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get advisoriesUnread;

  /// healthLogScans
  ///
  /// In en, this message translates to:
  /// **'Scans'**
  String get healthLogScans;

  /// healthLogHealthy
  ///
  /// In en, this message translates to:
  /// **'Healthy'**
  String get healthLogHealthy;

  /// healthLogAtRisk
  ///
  /// In en, this message translates to:
  /// **'Need attention'**
  String get healthLogAtRisk;

  /// healthLogFilterAll
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get healthLogFilterAll;

  /// healthLogConfidence
  ///
  /// In en, this message translates to:
  /// **'Confidence'**
  String get healthLogConfidence;

  /// carePlanNoItems
  ///
  /// In en, this message translates to:
  /// **'No care items due. Your crops look good.'**
  String get carePlanNoItems;

  /// carePlanItemReason
  ///
  /// In en, this message translates to:
  /// **'Why now'**
  String get carePlanItemReason;

  /// carePlanOpenTask
  ///
  /// In en, this message translates to:
  /// **'Open in Field Calendar'**
  String get carePlanOpenTask;

  /// profileSignOutConfirm
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get profileSignOutConfirm;

  /// profileSignOutConfirmBody
  ///
  /// In en, this message translates to:
  /// **'You will need to sign in again to see your crops.'**
  String get profileSignOutConfirmBody;

  /// profileSignOutAction
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get profileSignOutAction;

  /// profileCancel
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get profileCancel;

  /// profileManageCrops
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get profileManageCrops;

  /// profileName
  ///
  /// In en, this message translates to:
  /// **'Farmer'**
  String get profileName;

  /// languageSheetTitle
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSheetTitle;

  /// languageApply
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get languageApply;

  /// profileUpdated
  ///
  /// In en, this message translates to:
  /// **'Changes saved.'**
  String get profileUpdated;

  /// authSignIn
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignIn;

  /// authCreateAccount
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get authCreateAccount;

  /// authSignUpPrompt
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign up'**
  String get authSignUpPrompt;

  /// authSignInPrompt
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get authSignInPrompt;

  /// authForgotPassword
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authForgotPassword;

  /// authContinueGoogle
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get authContinueGoogle;

  /// authContinueFacebook
  ///
  /// In en, this message translates to:
  /// **'Continue with Facebook'**
  String get authContinueFacebook;

  /// authContinuePhone
  ///
  /// In en, this message translates to:
  /// **'Continue with Phone (OTP)'**
  String get authContinuePhone;

  /// authTagline
  ///
  /// In en, this message translates to:
  /// **'Detect Early. Protect Your Harvest.'**
  String get authTagline;

  /// authEmail
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get authEmail;

  /// authPassword
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// authFullNameRequired
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name'**
  String get authFullNameRequired;

  /// authFarmNameRequired
  ///
  /// In en, this message translates to:
  /// **'Please enter farm name'**
  String get authFarmNameRequired;

  /// authLocationRequired
  ///
  /// In en, this message translates to:
  /// **'Please enter location'**
  String get authLocationRequired;

  /// authEmailInvalid
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get authEmailInvalid;

  /// authPasswordMinLength
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get authPasswordMinLength;

  /// authPhoneLabel
  ///
  /// In en, this message translates to:
  /// **'Mobile Number / Phone (Optional)'**
  String get authPhoneLabel;

  /// authOtpMobile
  ///
  /// In en, this message translates to:
  /// **'Mobile Number (+63...)'**
  String get authOtpMobile;

  /// authOtpCode
  ///
  /// In en, this message translates to:
  /// **'Enter OTP Code'**
  String get authOtpCode;

  /// authSendOtp
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get authSendOtp;

  /// authVerifyOtp
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get authVerifyOtp;

  /// authOtpTitle
  ///
  /// In en, this message translates to:
  /// **'Phone Number (OTP) Login'**
  String get authOtpTitle;

  /// authOtpSent
  ///
  /// In en, this message translates to:
  /// **'OTP sent to your mobile number!'**
  String get authOtpSent;

  /// authCancel
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get authCancel;

  /// authRequired
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get authRequired;

  /// authGoogleError
  ///
  /// In en, this message translates to:
  /// **'Google Sign-In failed. Please try again.'**
  String get authGoogleError;

  /// authFacebookError
  ///
  /// In en, this message translates to:
  /// **'Facebook Sign-In failed. Please try again.'**
  String get authFacebookError;

  /// homeWeatherUpdated
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get homeWeatherUpdated;

  /// homeOfflineBanner
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. Showing cached weather.'**
  String get homeOfflineBanner;

  /// calendarAddTask
  ///
  /// In en, this message translates to:
  /// **'Add Task'**
  String get calendarAddTask;

  /// taskEditTitle
  ///
  /// In en, this message translates to:
  /// **'Edit Task'**
  String get taskEditTitle;

  /// taskTitleLabel
  ///
  /// In en, this message translates to:
  /// **'Task title'**
  String get taskTitleLabel;

  /// taskTitleRequired
  ///
  /// In en, this message translates to:
  /// **'Enter a task title'**
  String get taskTitleRequired;

  /// taskCategoryLabel
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get taskCategoryLabel;

  /// taskCropLabel
  ///
  /// In en, this message translates to:
  /// **'Related crop (optional)'**
  String get taskCropLabel;

  /// taskNoCrop
  ///
  /// In en, this message translates to:
  /// **'No crop'**
  String get taskNoCrop;

  /// taskPriorityLabel
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get taskPriorityLabel;

  /// taskPriorityNormal
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get taskPriorityNormal;

  /// taskPriorityHigh
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get taskPriorityHigh;

  /// taskDateLabel
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get taskDateLabel;

  /// taskSave
  ///
  /// In en, this message translates to:
  /// **'Save task'**
  String get taskSave;

  /// taskSaved
  ///
  /// In en, this message translates to:
  /// **'Task saved'**
  String get taskSaved;

  /// taskSaveError
  ///
  /// In en, this message translates to:
  /// **'Could not save the task. Please try again.'**
  String get taskSaveError;

  /// taskDetailTitle
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get taskDetailTitle;

  /// taskDetailEdit
  ///
  /// In en, this message translates to:
  /// **'Edit task'**
  String get taskDetailEdit;

  /// taskDetailDelete
  ///
  /// In en, this message translates to:
  /// **'Delete task'**
  String get taskDetailDelete;

  /// taskDeleteConfirmTitle
  ///
  /// In en, this message translates to:
  /// **'Delete this task?'**
  String get taskDeleteConfirmTitle;

  /// taskDeleteConfirmBody
  ///
  /// In en, this message translates to:
  /// **'This removes the task from your field calendar.'**
  String get taskDeleteConfirmBody;

  /// taskDeleteAction
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get taskDeleteAction;

  /// taskDeleteCancel
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get taskDeleteCancel;

  /// taskDeleted
  ///
  /// In en, this message translates to:
  /// **'Task deleted'**
  String get taskDeleted;

  /// taskScheduledFor
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get taskScheduledFor;

  /// taskWhyThisDate
  ///
  /// In en, this message translates to:
  /// **'Why this date'**
  String get taskWhyThisDate;

  /// taskReasonWeather
  ///
  /// In en, this message translates to:
  /// **'Postponed because of rain in the forecast.'**
  String get taskReasonWeather;

  /// taskReasonOverdue
  ///
  /// In en, this message translates to:
  /// **'This task is overdue.'**
  String get taskReasonOverdue;

  /// taskReasonScan
  ///
  /// In en, this message translates to:
  /// **'Suggested based on your latest scan.'**
  String get taskReasonScan;

  /// taskReasonRoutine
  ///
  /// In en, this message translates to:
  /// **'Scheduled routine care.'**
  String get taskReasonRoutine;

  /// taskRelatedScan
  ///
  /// In en, this message translates to:
  /// **'Related scan'**
  String get taskRelatedScan;

  /// carePlanSuggested
  ///
  /// In en, this message translates to:
  /// **'Suggested for you'**
  String get carePlanSuggested;

  /// carePlanAddToCalendar
  ///
  /// In en, this message translates to:
  /// **'Add to calendar'**
  String get carePlanAddToCalendar;

  /// carePlanAdded
  ///
  /// In en, this message translates to:
  /// **'Added to your field calendar'**
  String get carePlanAdded;

  /// carePlanReasonWeather
  ///
  /// In en, this message translates to:
  /// **'Weather'**
  String get carePlanReasonWeather;

  /// carePlanReasonOverdue
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get carePlanReasonOverdue;

  /// carePlanReasonScan
  ///
  /// In en, this message translates to:
  /// **'From scan'**
  String get carePlanReasonScan;

  /// carePlanReasonRoutine
  ///
  /// In en, this message translates to:
  /// **'Routine'**
  String get carePlanReasonRoutine;

  /// scanResultAddedToCalendar
  ///
  /// In en, this message translates to:
  /// **'Added to your field calendar'**
  String get scanResultAddedToCalendar;

  /// viewCalendar
  ///
  /// In en, this message translates to:
  /// **'View calendar'**
  String get viewCalendar;

  /// Follow-up recheck task title after a diagnosis
  ///
  /// In en, this message translates to:
  /// **'Recheck {crop} after {diagnosis}'**
  String carePlanSuggestionTitle(String crop, String diagnosis);

  /// agriProFreePlanSummary
  ///
  /// In en, this message translates to:
  /// **'5 scans/week, basic calendar.'**
  String get agriProFreePlanSummary;

  /// agriProFeatureUnlimited
  ///
  /// In en, this message translates to:
  /// **'Unlimited scans'**
  String get agriProFeatureUnlimited;

  /// agriProFeaturePriority
  ///
  /// In en, this message translates to:
  /// **'Priority analysis'**
  String get agriProFeaturePriority;

  /// agriProFeatureTrends
  ///
  /// In en, this message translates to:
  /// **'Health trends'**
  String get agriProFeatureTrends;

  /// agriProFeatureWeather
  ///
  /// In en, this message translates to:
  /// **'Weather-adjusted reminders'**
  String get agriProFeatureWeather;

  /// agriProFeatureOffline
  ///
  /// In en, this message translates to:
  /// **'Offline pack'**
  String get agriProFeatureOffline;

  /// agriProPlanMonthly
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get agriProPlanMonthly;

  /// agriProPlanSeasonal
  ///
  /// In en, this message translates to:
  /// **'Seasonal'**
  String get agriProPlanSeasonal;

  /// agriProPlanSeasonTagline
  ///
  /// In en, this message translates to:
  /// **'One season, six months of unlimited scans.'**
  String get agriProPlanSeasonTagline;

  /// agriProPlanMonthlyTagline
  ///
  /// In en, this message translates to:
  /// **'Try Agri Pro month by month.'**
  String get agriProPlanMonthlyTagline;

  /// agriProPriceMonthly
  ///
  /// In en, this message translates to:
  /// **'₱99/month'**
  String get agriProPriceMonthly;

  /// agriProPriceSeasonal
  ///
  /// In en, this message translates to:
  /// **'₱499/6 months'**
  String get agriProPriceSeasonal;

  /// agriProPerDay
  ///
  /// In en, this message translates to:
  /// **'₱3 a day'**
  String get agriProPerDay;

  /// agriProSavePercent
  ///
  /// In en, this message translates to:
  /// **'Save 16%'**
  String get agriProSavePercent;

  /// agriProPlanRenewsMonthly
  ///
  /// In en, this message translates to:
  /// **'Renews each month at ₱99.'**
  String get agriProPlanRenewsMonthly;

  /// agriProPlanRenewsSeasonal
  ///
  /// In en, this message translates to:
  /// **'Renews every 6 months at ₱499.'**
  String get agriProPlanRenewsSeasonal;

  /// agriProCancelAnytime
  ///
  /// In en, this message translates to:
  /// **'Cancel anytime.'**
  String get agriProCancelAnytime;

  /// agriProPaymentNote
  ///
  /// In en, this message translates to:
  /// **'Prices include VAT. Billing is handled by Google Play or the App Store.'**
  String get agriProPaymentNote;

  /// startAgriPro
  ///
  /// In en, this message translates to:
  /// **'Start Agri Pro'**
  String get startAgriPro;

  /// agriProManageTitle
  ///
  /// In en, this message translates to:
  /// **'Manage Agri Pro'**
  String get agriProManageTitle;

  /// agriProManageCurrentPlan
  ///
  /// In en, this message translates to:
  /// **'Current plan'**
  String get agriProManageCurrentPlan;

  /// agriProManageRenewal
  ///
  /// In en, this message translates to:
  /// **'Renews'**
  String get agriProManageRenewal;

  /// agriProManageBilling
  ///
  /// In en, this message translates to:
  /// **'Pagbayad'**
  String get agriProManageBilling;

  /// agriProManageBilledBy
  ///
  /// In en, this message translates to:
  /// **'Managed by your app store.'**
  String get agriProManageBilledBy;

  /// agriProManageCancelHow
  ///
  /// In en, this message translates to:
  /// **'To cancel, open Google Play → Subscriptions → Smart Crops, or the App Store → Subscriptions. Access continues until the end of the paid period.'**
  String get agriProManageCancelHow;

  /// agriProRestore
  ///
  /// In en, this message translates to:
  /// **'Restore purchase'**
  String get agriProRestore;

  /// agriProPurchaseRestored
  ///
  /// In en, this message translates to:
  /// **'Purchase restored.'**
  String get agriProPurchaseRestored;

  /// billingNotConfigured
  ///
  /// In en, this message translates to:
  /// **'Agri Pro purchases are not available yet. They will open when the store listing is live.'**
  String get billingNotConfigured;

  /// agriProPurchaseFailed
  ///
  /// In en, this message translates to:
  /// **'Purchase failed. Please try again.'**
  String get agriProPurchaseFailed;

  /// agriProUnlocked
  ///
  /// In en, this message translates to:
  /// **'Agri Pro unlocked.'**
  String get agriProUnlocked;

  /// agriProPlanActive
  ///
  /// In en, this message translates to:
  /// **'Agri Pro — Active'**
  String get agriProPlanActive;

  /// agriProPlanFree
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get agriProPlanFree;

  /// agriProManageUpgradeTitle
  ///
  /// In en, this message translates to:
  /// **'You\'re on the Free plan'**
  String get agriProManageUpgradeTitle;

  /// agriProManageFreeSummary
  ///
  /// In en, this message translates to:
  /// **'Upgrade for unlimited scans.'**
  String get agriProManageFreeSummary;

  /// agriProManageProSummary
  ///
  /// In en, this message translates to:
  /// **'You have unlimited scans and priority analysis.'**
  String get agriProManageProSummary;

  /// agriProManageUpgradeCta
  ///
  /// In en, this message translates to:
  /// **'See Agri Pro plans'**
  String get agriProManageUpgradeCta;

  /// agriProRenewalNever
  ///
  /// In en, this message translates to:
  /// **'Until you cancel'**
  String get agriProRenewalNever;

  /// agriProQuotaContext
  ///
  /// In en, this message translates to:
  /// **'You\'ve used {used} of {limit} free scans this week. Agri Pro removes the limit.'**
  String agriProQuotaContext(int used, int limit);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ceb', 'en', 'tl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ceb':
      return AppLocalizationsCeb();
    case 'en':
      return AppLocalizationsEn();
    case 'tl':
      return AppLocalizationsTl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
