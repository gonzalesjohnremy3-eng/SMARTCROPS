// This is a basic Flutter widget test.
//
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_crops/app/localization/language_preference.dart';
import 'package:smart_crops/app/router/onboarding_controller.dart';
import 'package:smart_crops/features/pro/domain/billing.dart';
import 'package:smart_crops/features/pro/services/agri_pro_entitlement.dart';
import 'package:smart_crops/main.dart';
import 'package:smart_crops/services/smart_crops_service.dart';
import 'package:smart_crops/services/weather_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MemoryLanguageStore implements LanguageStore {
  String? value;

  @override
  Future<String?> load() async => value;

  @override
  Future<void> save(String languageCode) async {
    value = languageCode;
  }
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    try {
      await Supabase.initialize(
        url: 'https://test.supabase.co',
        anonKey: 'test-anon-key',
      );
    } catch (_) {
      // Already initialized
    }
  });

  testWidgets('Smart Crops app smoke test', (tester) async {
    final languagePreference = LanguagePreference(
      store: MemoryLanguageStore(),
    );

    await tester.pumpWidget(SmartCropsApp(
      languagePreference: languagePreference,
      weatherService: WeatherService(),
      smartCropsService: SmartCropsService(),
      onboardingController: OnboardingController(
        onboardingComplete: true,
        profileComplete: true,
      ),
      agriProEntitlement: AgriProEntitlement(
        fetchRow: () async => null,
      ),
      billingRepository: const UnconfiguredBillingRepository(),
    ));
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
