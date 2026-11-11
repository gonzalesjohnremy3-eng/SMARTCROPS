import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:app_links/app_links.dart';
import 'services/smart_crops_service.dart';
import 'services/weather_service.dart';
import 'screens/auth_screen.dart';
import 'screens/profile_setup_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env
  await dotenv.load(fileName: ".env");

  // Initialize Supabase with live keys from .env
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? 'https://placeholder-smart-crops.supabase.co',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? 'ey_placeholder_anon_key_for_build_verification',
  );

  runApp(const SmartCropsApp());
}

class SmartCropsApp extends StatefulWidget {
  const SmartCropsApp({super.key});

  @override
  State<SmartCropsApp> createState() => _SmartCropsAppState();
}

class _SmartCropsAppState extends State<SmartCropsApp> {
  final _appLinks = AppLinks();

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  void _initDeepLinks() {
    _appLinks.uriLinkStream.listen((uri) async {
      if (uri.queryParameters.containsKey('code')) {
        try {
          await Supabase.instance.client.auth.exchangeCodeForSession(uri.toString());
        } catch (e) {
          debugPrint('Error exchanging code for session: $e');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF2E7D32);

    Widget homeScreen = const AuthScreen();
    try {
      if (Supabase.instance.client.auth.currentSession != null) {
        homeScreen = const ProfileSetupScreen();
      }
    } catch (_) {}

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SmartCropsService()),
        ChangeNotifierProvider(create: (_) => WeatherService()),
      ],
      child: MaterialApp(
        title: 'Smart Crops (Agri Lynk)',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: primaryGreen),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        home: homeScreen,
      ),
    );
  }
}
