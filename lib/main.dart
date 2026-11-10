import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/smart_crops_service.dart';
import 'screens/auth_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://placeholder-smart-crops.supabase.co',
    anonKey: 'ey_placeholder_anon_key_for_build_verification',
  );

  runApp(const SmartCropsApp());
}

class SmartCropsApp extends StatelessWidget {
  const SmartCropsApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF2E7D32);

    return ChangeNotifierProvider(
      create: (_) => SmartCropsService(),
      child: MaterialApp(
        title: 'Smart Crops (Agri Lynk)',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: primaryGreen),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        home: const AuthScreen(),
      ),
    );
  }
}
