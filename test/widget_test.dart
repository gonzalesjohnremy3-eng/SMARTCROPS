// This is a basic Flutter widget test.
//
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_crops/app/localization/language_preference.dart';
import 'package:smart_crops/main.dart';

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
  testWidgets('Smart Crops app smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    final languagePreference = LanguagePreference(
      store: MemoryLanguageStore(),
    );

    await tester.pumpWidget(SmartCropsApp(languagePreference: languagePreference));

    // Verify that the app loads without errors
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}