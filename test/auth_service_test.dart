import 'package:flutter_test/flutter_test.dart';
import 'package:smart_crops/services/smart_crops_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  group('Auth Service TDD - Seams: Phone OTP & OAuth', () {
    test('signInWithPhoneOtp method exists', () async {
      final service = SmartCropsService();
      expect(service.signInWithPhoneOtp, isNotNull);
    });

    test('verifyPhoneOtp method exists', () async {
      final service = SmartCropsService();
      expect(service.verifyPhoneOtp, isNotNull);
    });

    test('signInWithOAuth method exists', () async {
      final service = SmartCropsService();
      expect(service.signInWithOAuth, isNotNull);
    });
  });
}
