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

  /// Not now permission button
  ///
  /// In en, this message translates to:
  /// **'Not Now'**
  String get notNow;

  /// Complete profile setup button
  ///
  /// In en, this message translates to:
  /// **'Complete Setup'**
  String get completeSetup;

  /// No description provided for @homeFieldbriefing.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Field Briefing'**
  String get homeFieldbriefing;

  /// No description provided for @homePriorityaction.
  ///
  /// In en, this message translates to:
  /// **'Priority Action'**
  String get homePriorityaction;

  /// No description provided for @homeScancta.
  ///
  /// In en, this message translates to:
  /// **'Scan a Crop'**
  String get homeScancta;

  /// No description provided for @homeCareplan.
  ///
  /// In en, this message translates to:
  /// **'This Week\'s Care Plan'**
  String get homeCareplan;

  /// No description provided for @homeRecentscans.
  ///
  /// In en, this message translates to:
  /// **'Recent Diagnoses'**
  String get homeRecentscans;

  /// No description provided for @homeEmptyfarm.
  ///
  /// In en, this message translates to:
  /// **'Your field office is ready. Take your first scan to start your crop\'s health record.'**
  String get homeEmptyfarm;

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

  /// No description provided for @cropsAddcrop.
  ///
  /// In en, this message translates to:
  /// **'Add a Crop'**
  String get cropsAddcrop;

  /// No description provided for @cropsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No crops yet. Add your first crop to get personalized care.'**
  String get cropsEmpty;

  /// No description provided for @cropDetailCareguide.
  ///
  /// In en, this message translates to:
  /// **'Care Guide'**
  String get cropDetailCareguide;

  /// No description provided for @cropDetailGrowingconditions.
  ///
  /// In en, this message translates to:
  /// **'Growing Conditions'**
  String get cropDetailGrowingconditions;

  /// No description provided for @cropDetailGrowthtimeline.
  ///
  /// In en, this message translates to:
  /// **'Growth Timeline'**
  String get cropDetailGrowthtimeline;

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

  /// No description provided for @scanResultTreatmentsteps.
  ///
  /// In en, this message translates to:
  /// **'Treatment Steps'**
  String get scanResultTreatmentsteps;

  /// No description provided for @scanResultAddtocalendar.
  ///
  /// In en, this message translates to:
  /// **'Add to Field Calendar'**
  String get scanResultAddtocalendar;

  /// No description provided for @scanResultSetreminder.
  ///
  /// In en, this message translates to:
  /// **'Set Reminder'**
  String get scanResultSetreminder;

  /// No description provided for @scanResultShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get scanResultShare;

  /// No description provided for @scanResultLowconfidenceretake.
  ///
  /// In en, this message translates to:
  /// **'Retake in better light'**
  String get scanResultLowconfidenceretake;

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

  /// No description provided for @calendarWeatheradjusted.
  ///
  /// In en, this message translates to:
  /// **'Weather-adjusted'**
  String get calendarWeatheradjusted;

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

  /// No description provided for @carePlanThisweek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get carePlanThisweek;

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

  /// No description provided for @notificationsScanresults.
  ///
  /// In en, this message translates to:
  /// **'Scan Results'**
  String get notificationsScanresults;

  /// No description provided for @notificationsWeatheradvisories.
  ///
  /// In en, this message translates to:
  /// **'Weather Advisories'**
  String get notificationsWeatheradvisories;

  /// No description provided for @notificationsCalendarreminders.
  ///
  /// In en, this message translates to:
  /// **'Calendar Reminders'**
  String get notificationsCalendarreminders;

  /// No description provided for @notificationsCooperativeadvisories.
  ///
  /// In en, this message translates to:
  /// **'Cooperative Advisories'**
  String get notificationsCooperativeadvisories;

  /// No description provided for @notificationsQuiethours.
  ///
  /// In en, this message translates to:
  /// **'Quiet Hours'**
  String get notificationsQuiethours;

  /// No description provided for @agriProTitle.
  ///
  /// In en, this message translates to:
  /// **'Agri Pro'**
  String get agriProTitle;

  /// No description provided for @agriProHeadline.
  ///
  /// In en, this message translates to:
  /// **'Protect more of what you grow.'**
  String get agriProHeadline;

  /// No description provided for @agriProFreesummary.
  ///
  /// In en, this message translates to:
  /// **'Free plan: 5 scans/week, basic calendar.'**
  String get agriProFreesummary;

  /// No description provided for @agriProProsummary.
  ///
  /// In en, this message translates to:
  /// **'Agri Pro: unlimited scans, priority analysis, health trends, weather-adjusted reminders, offline pack.'**
  String get agriProProsummary;

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

  /// No description provided for @agriProNotnow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get agriProNotnow;

  /// No description provided for @shopTitle.
  ///
  /// In en, this message translates to:
  /// **'Agri Shop'**
  String get shopTitle;

  /// No description provided for @shopPartneroffer.
  ///
  /// In en, this message translates to:
  /// **'Partner offer'**
  String get shopPartneroffer;

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

  /// No description provided for @cooperativeInvitecode.
  ///
  /// In en, this message translates to:
  /// **'Invite Code'**
  String get cooperativeInvitecode;

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

  /// No description provided for @cooperativeOutbreaksummary.
  ///
  /// In en, this message translates to:
  /// **'Outbreak Summary'**
  String get cooperativeOutbreaksummary;

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

  /// No description provided for @severityAtrisk.
  ///
  /// In en, this message translates to:
  /// **'At Risk'**
  String get severityAtrisk;

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

  /// No description provided for @offlineScanqueued.
  ///
  /// In en, this message translates to:
  /// **'Saved. We\'ll analyze this when you\'re back online.'**
  String get offlineScanqueued;

  /// viewAll
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// homePriorityAction
  ///
  /// In en, this message translates to:
  /// **'Priority Action'**
  String get homePriorityAction;

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

  /// homeScanCTA
  ///
  /// In en, this message translates to:
  /// **'Scan a Crop'**
  String get homeScanCTA;

  /// homeFieldBriefing
  ///
  /// In en, this message translates to:
  /// **'Today\'s Field Briefing'**
  String get homeFieldBriefing;

  /// calendarSetReminder
  ///
  /// In en, this message translates to:
  /// **'Set Reminder'**
  String get calendarSetReminder;
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
