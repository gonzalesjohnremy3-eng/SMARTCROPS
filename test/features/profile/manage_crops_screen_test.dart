import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_crops/app/localization/ceb_fallback_localizations.dart';
import 'package:smart_crops/features/profile/screens/manage_crops_screen.dart';
import 'package:smart_crops/l10n/app_localizations.dart';
import 'package:smart_crops/models/app_models.dart';
import 'package:smart_crops/services/smart_crops_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _FakeService extends SmartCropsService {
  _FakeService({required this.catalog, required this.mine, this.failSave = false});

  final List<CropItem> catalog;
  final List<CropItem> mine;
  final bool failSave;
  List<String>? saved;

  @override
  List<CropItem> get availableCrops => catalog;

  @override
  List<CropItem> get userSelectedCrops => mine;

  @override
  Future<void> saveUserCrops(List<String> cropIds) async {
    if (failSave) throw Exception('save failed');
    saved = cropIds;
  }
}

CropItem _crop(String name) =>
    CropItem(id: 'id-$name', cropName: name, optimalConditions: const {});

final _catalog = [_crop('Rice'), _crop('Corn'), _crop('Tomato')];

Future<_FakeService> _pump(
  WidgetTester tester, {
  List<CropItem>? mine,
  bool failSave = false,
  String locale = 'en',
  double textScale = 1,
  Size size = const Size(390, 1600),
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final service = _FakeService(
    catalog: _catalog,
    mine: mine ?? [_crop('Rice')],
    failSave: failSave,
  );

  await tester.pumpWidget(
    ChangeNotifierProvider<SmartCropsService>.value(
      value: service,
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
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ManageCropsScreen(),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return service;
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

  testWidgets('starts with the Farmer\'s current crops selected', (tester) async {
    await _pump(tester);

    expect(find.text('1 crop selected'), findsOneWidget);
  });

  testWidgets('lists every crop in the catalogue to choose from', (tester) async {
    await _pump(tester);

    expect(find.text('Tomato'), findsOneWidget);
  });

  testWidgets('choosing another crop updates the count', (tester) async {
    await _pump(tester);
    await tester.tap(find.text('Corn'));
    await tester.pumpAndSettle();

    expect(find.text('2 crops selected'), findsOneWidget);
  });

  testWidgets('Save stores the chosen crops by id', (tester) async {
    final service = await _pump(tester);
    await tester.tap(find.text('Corn'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Save changes'));
    await tester.pumpAndSettle();

    expect(service.saved, unorderedEquals(['id-Rice', 'id-Corn']));
  });

  testWidgets('Save returns to the previous screen', (tester) async {
    await _pump(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Save changes'));
    await tester.pumpAndSettle();

    expect(find.text('open'), findsOneWidget);
  });

  testWidgets('a failed save stays on the page and says so', (tester) async {
    await _pump(tester, failSave: true);
    await tester.tap(find.widgetWithText(FilledButton, 'Save changes'));
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('a Farmer can clear every crop', (tester) async {
    final service = await _pump(tester);
    await tester.tap(find.text('Rice'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Save changes'));
    await tester.pumpAndSettle();

    expect(service.saved, isEmpty);
  });

  testWidgets('has a Back button', (tester) async {
    await _pump(tester);

    expect(find.byTooltip('Back'), findsOneWidget);
  });

  for (final locale in ['en', 'tl', 'ceb']) {
    testWidgets('fits a phone at 200% text in $locale', (tester) async {
      final errors = <FlutterErrorDetails>[];
      final original = FlutterError.onError;
      FlutterError.onError = errors.add;
      try {
        await _pump(
          tester,
          size: const Size(375, 667),
          locale: locale,
          textScale: 2,
        );
      } finally {
        FlutterError.onError = original;
      }

      expect(errors, isEmpty);
    });
  }
}
