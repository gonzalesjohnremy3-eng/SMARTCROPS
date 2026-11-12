import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smart_crops/app/router/app_router.dart';
import 'package:smart_crops/app/theme/app_theme.dart';
import 'package:smart_crops/app/localization/language_preference.dart';
import 'package:smart_crops/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/smart_crops_service.dart';
import 'services/weather_service.dart';

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

  // Initialize profile setup completion flags
  final prefs = await SharedPreferences.getInstance();
  final isOnboardingComplete = prefs.getBool('onboarding_complete') ?? false;
  final isProfileComplete = prefs.getBool('profile_complete') ?? false;

  runApp(SmartCropsApp(
    languagePreference: languagePreference,
    isOnboardingComplete: isOnboardingComplete,
    isProfileComplete: isProfileComplete,
  ));
}

class SmartCropsApp extends StatelessWidget {
  const SmartCropsApp({
    super.key,
    required this.languagePreference,
    this.isOnboardingComplete = true,
    this.isProfileComplete = true,
  });

  final LanguagePreference languagePreference;
  final bool isOnboardingComplete;
  final bool isProfileComplete;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SmartCropsService()),
        ChangeNotifierProvider(create: (_) => WeatherService()),
      ],
      child: ValueListenableBuilder<String>(
        valueListenable: _LocaleNotifier(languagePreference),
        builder: (context, localeCode, _) {
          return MaterialApp.router(
            title: 'Smart Crops (Agri Lynk)',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            locale: Locale(localeCode),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('tl'),
              Locale('ceb'),
            ],
            routerConfig: buildAppRouter(
              isOnboardingComplete: isOnboardingComplete,
              isProfileComplete: isProfileComplete,
            ),
          );
        },
      ),
    );
  }
}

class _LocaleNotifier extends ValueNotifier<String> {
  _LocaleNotifier(this._languagePreference) : super('en') {
    _init();
  }

  final LanguagePreference _languagePreference;

  Future<void> _init() async {
    value = await _languagePreference.load();
  }

  Future<void> setLocale(String languageCode) async {
    await _languagePreference.save(languageCode);
    value = languageCode;
  }
}