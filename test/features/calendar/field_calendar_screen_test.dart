import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_crops/app/localization/ceb_fallback_localizations.dart';
import 'package:smart_crops/features/calendar/screens/field_calendar_screen.dart';
import 'package:smart_crops/l10n/app_localizations.dart';
import 'package:smart_crops/models/app_models.dart';
import 'package:smart_crops/services/farm_data_loader.dart';
import 'package:smart_crops/services/farm_snapshot.dart';
import 'package:smart_crops/services/smart_crops_service.dart';
import 'package:smart_crops/services/weather_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final _now = DateTime(2026, 11, 28, 7, 30);

class _StubLoader implements FarmDataLoader {
  _StubLoader(this.snapshot);

  final FarmSnapshot snapshot;

  @override
  Future<List<CropItem>> fetchCropsCatalog() async => snapshot.availableCrops;

  @override
  Future<FarmSnapshot?> fetchFarmData() async => snapshot;
}

CropCalendarEvent _task(
  String id,
  String title,
  DateTime when, {
  String priority = 'Normal',
}) => CropCalendarEvent(
  id: id,
  userId: 'u',
  eventTitle: title,
  eventCategory: 'Pest Control',
  scheduledDate: when,
  isCompleted: false,
  priority: priority,
);

final _tasks = [
  _task('a', 'Scout for pests', DateTime(2026, 11, 27, 8)),
  _task('b', 'Water the rice', DateTime(2026, 11, 28, 9)),
  _task('c', 'Apply fertilizer', DateTime(2026, 11, 29, 10)),
];

Future<void> _pump(
  WidgetTester tester, {
  List<CropCalendarEvent>? tasks,
  String locale = 'en',
  double textScale = 1,
  Size size = const Size(390, 1600),
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final service = SmartCropsService(
    loader: _StubLoader(
      FarmSnapshot(
        availableCrops: const [],
        userCrops: const [],
        scanHistory: const [],
        notifications: const [],
        calendarEvents: tasks ?? _tasks,
        fetchedAt: _now,
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
        home: FieldCalendarScreen(now: _now),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _showWeek(WidgetTester tester) async {
  await tester.tap(find.text('This week'));
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

  testWidgets('today lists the tasks due today', (tester) async {
    await _pump(tester);

    expect(find.text('Water the rice'), findsOneWidget);
  });

  testWidgets('today leaves tomorrow\'s tasks out', (tester) async {
    await _pump(tester);

    expect(find.text('Apply fertilizer'), findsNothing);
  });

  testWidgets('shows the time of each task in the locale\'s format', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.textContaining('9:00 AM'), findsOneWidget);
  });

  testWidgets('this week adds the coming days', (tester) async {
    await _pump(tester);
    await _showWeek(tester);

    expect(find.text('Apply fertilizer'), findsOneWidget);
  });

  testWidgets('this week groups tasks under a dated heading', (tester) async {
    await _pump(tester);
    await _showWeek(tester);

    expect(find.textContaining('Nov 29'), findsOneWidget);
  });

  testWidgets('flags an open task from a past day as overdue', (tester) async {
    await _pump(tester);
    await _showWeek(tester);

    expect(find.text('Overdue'), findsOneWidget);
  });

  testWidgets('each open task has a labelled done button', (tester) async {
    await _pump(tester);

    expect(find.byTooltip('Mark done'), findsOneWidget);
  });

  testWidgets('a high priority task says so in words', (tester) async {
    await _pump(
      tester,
      tasks: [
        _task('h', 'Spray now', DateTime(2026, 11, 28, 9), priority: 'High'),
      ],
    );

    expect(find.text('High priority'), findsOneWidget);
  });

  testWidgets('offers to add a task', (tester) async {
    await _pump(tester);

    expect(find.text('Add Task'), findsOneWidget);
  });

  testWidgets('empty state explains and still offers to add a task', (
    tester,
  ) async {
    await _pump(tester, tasks: const []);

    expect(
      find.text('No tasks yet. Your plan will appear here.'),
      findsOneWidget,
    );
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
        await tester.tap(find.byKey(const Key('calendar_view_week')));
        await tester.pumpAndSettle();
      } finally {
        FlutterError.onError = original;
      }

      expect(errors, isEmpty);
    });
  }
}
