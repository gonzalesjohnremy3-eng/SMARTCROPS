import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_crops/app/localization/ceb_fallback_localizations.dart';
import 'package:smart_crops/features/calendar/screens/task_detail_screen.dart';
import 'package:smart_crops/l10n/app_localizations.dart';
import 'package:smart_crops/models/app_models.dart';
import 'package:smart_crops/services/farm_data_loader.dart';
import 'package:smart_crops/services/farm_snapshot.dart';
import 'package:smart_crops/services/smart_crops_service.dart';
import 'package:smart_crops/services/weather_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _StubLoader implements FarmDataLoader {
  _StubLoader(this.snapshot);

  final FarmSnapshot snapshot;

  @override
  Future<List<CropItem>> fetchCropsCatalog() async => snapshot.availableCrops;

  @override
  Future<FarmSnapshot?> fetchFarmData() async => snapshot;
}

CropItem _tomato() => CropItem(
  id: 'crop-tomato',
  cropName: 'Tomato',
  optimalConditions: const {},
);

CropCalendarEvent _event({
  String title = 'Spray fungicide',
  String priority = 'Normal',
  bool completed = false,
}) => CropCalendarEvent(
  id: 'e1',
  userId: 'u',
  cropId: 'crop-tomato',
  eventTitle: title,
  eventCategory: 'Pest Control',
  scheduledDate: DateTime(2026, 11, 28, 9),
  isCompleted: completed,
  priority: priority,
);

ScanHistoryItem _scan() => ScanHistoryItem(
  id: 's1',
  userId: 'u',
  imageUrl: 'https://example.com/a.jpg',
  diseaseDetected: 'Early blight',
  confidenceScore: 90,
  commonCrop: 'Tomato',
  recommendedActions: const ['Keep monitoring'],
  scannedAt: DateTime(2026, 11, 20),
);

Future<void> _pump(
  WidgetTester tester,
  CropCalendarEvent event, {
  List<ScanHistoryItem> scans = const [],
  Size size = const Size(390, 1600),
  String locale = 'en',
  double textScale = 1,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final service = SmartCropsService(
    loader: _StubLoader(
      FarmSnapshot(
        availableCrops: [_tomato()],
        userCrops: [_tomato()],
        scanHistory: scans,
        notifications: const [],
        calendarEvents: [event],
        fetchedAt: DateTime(2026, 11, 28),
      ),
    ),
  );
  await service.initializeUserData();

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: service),
        ChangeNotifierProvider(create: (_) => WeatherService()),
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
        home: TaskDetailScreen(event: event),
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

  testWidgets('shows the task title', (tester) async {
    await _pump(tester, _event());

    expect(find.text('Spray fungicide'), findsOneWidget);
  });

  testWidgets('names the crop the task is for', (tester) async {
    await _pump(tester, _event());

    expect(find.text('Tomato'), findsOneWidget);
  });

  testWidgets('does not print a bare Normal priority', (tester) async {
    await _pump(tester, _event());

    expect(find.text('Normal'), findsNothing);
  });

  testWidgets('says high priority in words', (tester) async {
    await _pump(tester, _event(priority: 'High'));

    expect(find.text('High priority'), findsOneWidget);
  });

  testWidgets('shows the date in the locale\'s format', (tester) async {
    await _pump(tester, _event());

    expect(find.textContaining('Nov 28'), findsOneWidget);
  });

  testWidgets('shows the time in the locale\'s format', (tester) async {
    await _pump(tester, _event());

    expect(find.textContaining('9:00 AM'), findsOneWidget);
  });

  testWidgets('Mark done is the primary action', (tester) async {
    await _pump(tester, _event());

    expect(find.widgetWithText(FilledButton, 'Mark done'), findsOneWidget);
  });

  testWidgets('a finished task says Completed', (tester) async {
    await _pump(tester, _event(completed: true));

    expect(find.text('Completed'), findsOneWidget);
  });

  testWidgets(
    'links the scan for the task\'s crop even if the title omits it',
    (tester) async {
      await _pump(tester, _event(), scans: [_scan()]);

      expect(find.text('Early blight'), findsOneWidget);
    },
  );

  testWidgets('the related scan states confidence in the locale\'s words', (
    tester,
  ) async {
    await _pump(tester, _event(), scans: [_scan()]);

    expect(find.textContaining('Confidence: 90%'), findsOneWidget);
  });

  testWidgets('keeps edit and delete reachable', (tester) async {
    await _pump(tester, _event());

    expect(find.text('Delete task'), findsOneWidget);
    expect(find.byTooltip('Edit task'), findsOneWidget);
  });

  for (final locale in ['en', 'tl', 'ceb']) {
    testWidgets('fits a phone at 200% text in $locale', (tester) async {
      final errors = <FlutterErrorDetails>[];
      final original = FlutterError.onError;
      FlutterError.onError = errors.add;
      try {
        await _pump(
          tester,
          _event(priority: 'High'),
          scans: [_scan()],
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

  testWidgets('meets tap-target and label guidelines', (tester) async {
    final handle = tester.ensureSemantics();
    await _pump(tester, _event(), scans: [_scan()]);

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    handle.dispose();
  });
}
