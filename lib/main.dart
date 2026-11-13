import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smart_crops/app/router/app_router.dart';
import 'package:smart_crops/app/router/onboarding_controller.dart';
import 'package:smart_crops/app/theme/app_theme.dart';
import 'package:smart_crops/app/localization/language_preference.dart';
import 'package:smart_crops/app/localization/locale_provider.dart';
import 'package:smart_crops/app/localization/ceb_fallback_localizations.dart';
import 'package:smart_crops/app/deep_link_handler.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_crops/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/smart_crops_service.dart';
import 'services/weather_service.dart';
import 'features/scan/data/shared_preferences_scan_queue_store.dart';
import 'features/scan/services/scan_queue_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env
  await dotenv.load(fileName: ".env");

  // Initialize Supabase with live keys from .env
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? 'https://placeholder-smart-crops.supabase.co',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? 'ey_placeholder_anon_key_for_build_verification',
  );

  // Initialize language preference
  final languagePreference = LanguagePreference(
    store: SharedPreferencesLanguageStore(),
  );
  await languagePreference.load();

  final weatherService = WeatherService();
  await weatherService.restoreCachedWeather();

  final smartCropsService = SmartCropsService();
  await smartCropsService.initializeUserData();

  // Initialize profile setup completion flags
  final prefs = await SharedPreferences.getInstance();
  final onboardingController = OnboardingController(
    onboardingComplete: prefs.getBool('onboarding_complete') ?? false,
    profileComplete: prefs.getBool('profile_complete') ?? false,
  );

  runApp(SmartCropsApp(
    languagePreference: languagePreference,
    weatherService: weatherService,
    smartCropsService: smartCropsService,
    onboardingController: onboardingController,
  ));
}

class SmartCropsApp extends StatefulWidget {
  const SmartCropsApp({
    super.key,
    required this.languagePreference,
    required this.weatherService,
    required this.smartCropsService,
    required this.onboardingController,
  });

  final LanguagePreference languagePreference;
  final WeatherService weatherService;
  final SmartCropsService smartCropsService;
  final OnboardingController onboardingController;

  @override
  State<SmartCropsApp> createState() => _SmartCropsAppState();
}

class _SmartCropsAppState extends State<SmartCropsApp> {
  late final GoRouter _router;
  late final DeepLinkHandler _deepLinks;

  @override
  void initState() {
    super.initState();
    _router = buildAppRouter(
      onboarding: widget.onboardingController,
    );
    _deepLinks = DeepLinkHandler(_router);
    _deepLinks.start();
  }

  @override
  void dispose() {
    _deepLinks.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: widget.smartCropsService),
        ChangeNotifierProvider.value(value: widget.weatherService),
        ChangeNotifierProvider.value(value: widget.onboardingController),
        ChangeNotifierProvider(
          create: (context) => ScanQueueProvider(
            store: SharedPreferencesScanQueueStore(),
            service: context.read<SmartCropsService>(),
          )..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => LocaleProvider(preference: widget.languagePreference),
        ),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, _) {
          return MaterialApp.router(
            title: 'Smart Crops (Agri Lynk)',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            locale: Locale(localeProvider.currentLocale),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              CebMaterialLocalizationsDelegate(),
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              CebCupertinoLocalizationsDelegate(),
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('tl'),
              Locale('ceb'),
            ],
            routerConfig: _router,
          );
        },
      ),
    );
  }
}

