import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_crops/app/localization/ceb_fallback_localizations.dart';
import 'package:smart_crops/features/advisories/screens/advisories_screen.dart';
import 'package:smart_crops/l10n/app_localizations.dart';
import 'package:smart_crops/models/app_models.dart';
import 'package:smart_crops/services/farm_data_loader.dart';
import 'package:smart_crops/services/farm_snapshot.dart';
import 'package:smart_crops/services/smart_crops_service.dart';

class _StubLoader implements FarmDataLoader {
  _StubLoader(this.snapshot);

  final FarmSnapshot snapshot;

  @override
  Future<List<CropItem>> fetchCropsCatalog() async => snapshot.availableCrops;

  @override
  Future<FarmSnapshot?> fetchFarmData() async => snapshot;
}

AppNotification _notification(
  String id,
  String title, {
  String? severity,
  bool isRead = false,
}) => AppNotification(
  id: id,
  userId: 'u',
  title: title,
  message: 'Inspect your rice today.',
  isRead: isRead,
  createdAt: DateTime(2026, 11, 22, 14, 5),
  severity: severity,
);

Future<void> _pump(
  WidgetTester tester, {
  bool critical = false,
  List<AppNotification>? notifications,
  Size size = const Size(390, 1600),
  String locale = 'en',
  double textScale = 1,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final snapshot = FarmSnapshot(
    availableCrops: const [],
    userCrops: const [],
    scanHistory: const [],
    notifications:
        notifications ??
        [
          _notification(
            'n1',
            'Blight outbreak in San Isidro',
            severity: critical ? 'critical' : null,
          ),
        ],
    calendarEvents: const [],
    fetchedAt: DateTime(2026, 11, 22),
  );
  final service = SmartCropsService(loader: _StubLoader(snapshot));
  await service.initializeUserData();

  await tester.pumpWidget(
    MultiProvider(
      providers: [ChangeNotifierProvider.value(value: service)],
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
        home: const AdvisoriesScreen(),
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

  testWidgets('pins a real critical advisory above the inbox', (tester) async {
    await _pump(tester, critical: true);

    expect(find.byKey(const Key('critical-advisory-banner')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('critical-advisory-banner')),
        matching: find.text('Blight outbreak in San Isidro'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('does not pin an ordinary advisory as critical', (tester) async {
    await _pump(tester, critical: false);

    expect(find.byKey(const Key('critical-advisory-banner')), findsNothing);
  });

  testWidgets('offers to mark everything read while any is unread', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.text('Mark all as read'), findsOneWidget);
  });

  testWidgets('hides mark all as read when everything is read', (tester) async {
    await _pump(
      tester,
      notifications: [_notification('r', 'Old advisory', isRead: true)],
    );

    expect(find.text('Mark all as read'), findsNothing);
  });

  testWidgets('labels an unread advisory in words, not colour alone', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.text('Unread'), findsOneWidget);
  });

  testWidgets('a read advisory carries no unread label', (tester) async {
    await _pump(
      tester,
      notifications: [_notification('r', 'Old advisory', isRead: true)],
    );

    expect(find.text('Unread'), findsNothing);
  });

  testWidgets('shows the date in the locale\'s format', (tester) async {
    await _pump(tester);

    expect(find.textContaining('Nov 22'), findsOneWidget);
  });

  testWidgets('shows the time in the locale\'s format', (tester) async {
    await _pump(tester);

    expect(find.textContaining('2:05 PM'), findsOneWidget);
  });

  testWidgets('empty state says when advisories will arrive', (tester) async {
    await _pump(tester, notifications: const []);

    expect(
      find.text(
        "No advisories yet. We'll tell you when something needs attention.",
      ),
      findsOneWidget,
    );
  });

  testWidgets('lays out on a wide screen without overflow', (tester) async {
    final errors = <FlutterErrorDetails>[];
    final original = FlutterError.onError;
    FlutterError.onError = errors.add;
    try {
      await _pump(tester, critical: true, size: const Size(1200, 900));
    } finally {
      FlutterError.onError = original;
    }

    expect(errors, isEmpty);
  });

  for (final locale in ['en', 'tl', 'ceb']) {
    testWidgets('fits a phone at 200% text in $locale', (tester) async {
      final errors = <FlutterErrorDetails>[];
      final original = FlutterError.onError;
      FlutterError.onError = errors.add;
      try {
        await _pump(
          tester,
          critical: true,
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
    await _pump(tester, critical: true);

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    handle.dispose();
  });
}
