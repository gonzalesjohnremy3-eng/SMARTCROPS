import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_crops/app/localization/ceb_fallback_localizations.dart';
import 'package:smart_crops/features/pro/services/agri_pro_entitlement.dart';
import 'package:smart_crops/features/scan/data/shared_preferences_scan_queue_store.dart';
import 'package:smart_crops/features/scan/screens/scan_review_screen.dart';
import 'package:smart_crops/features/scan/services/scan_queue_provider.dart';
import 'package:smart_crops/l10n/app_localizations.dart';
import 'package:smart_crops/services/smart_crops_service.dart';

Future<void> _pump(
  WidgetTester tester, {
  String locale = 'en',
  double textScale = 1,
  Size size = const Size(390, 844),
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final service = SmartCropsService();

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: service),
        ChangeNotifierProvider(
          create: (_) => AgriProEntitlement(fetchRow: () async => null),
        ),
        ChangeNotifierProvider(
          create: (_) => ScanQueueProvider(
            store: SharedPreferencesScanQueueStore(),
            service: service,
          ),
        ),
      ],
      child: MaterialApp(
        locale: Locale(locale),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          CebMaterialLocalizationsDelegate(),
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          CebCupertinoLocalizationsDelegate(),
        ],
        supportedLocales: const [Locale('en'), Locale('tl'), Locale('ceb')],
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: ScanReviewScreen(imageFile: XFile('leaf.jpg'), cropName: 'Rice'),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    try {
      await Supabase.initialize(
        url: 'https://test.supabase.co',
        publishableKey: 'test-anon-key',
      );
    } catch (_) {
      // Already initialized.
    }
  });

  testWidgets('names the crop the photo will be checked against', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.text('Rice'), findsOneWidget);
  });

  testWidgets('asks the Farmer to check the photo first', (tester) async {
    await _pump(tester);

    expect(find.text('Is the leaf clear?'), findsOneWidget);
  });

  testWidgets('Analyze is the primary action', (tester) async {
    await _pump(tester);

    expect(find.text('Analyze'), findsOneWidget);
  });

  testWidgets('Retake is offered alongside', (tester) async {
    await _pump(tester);

    expect(find.text('Retake'), findsOneWidget);
  });

  for (final locale in ['en', 'tl', 'ceb']) {
    testWidgets('fits a phone at 200% text in $locale', (tester) async {
      final errors = <FlutterErrorDetails>[];
      final original = FlutterError.onError;
      FlutterError.onError = errors.add;
      try {
        await _pump(
          tester,
          locale: locale,
          textScale: 2,
          size: const Size(375, 667),
        );
      } finally {
        FlutterError.onError = original;
      }

      expect(errors, isEmpty);
    });
  }
}
