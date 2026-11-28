import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_crops/app/localization/ceb_fallback_localizations.dart';
import 'package:smart_crops/features/profile/screens/profile_setup_screen.dart';
import 'package:smart_crops/l10n/app_localizations.dart';
import 'package:smart_crops/models/app_models.dart';
import 'package:smart_crops/services/smart_crops_service.dart';

class _FakeCropsService extends SmartCropsService {
  _FakeCropsService({UserProfile? profile, this.failUpdate = false})
    : _profile = profile;

  final UserProfile? _profile;
  final bool failUpdate;
  final List<List<Object?>> updateCalls = [];

  @override
  UserProfile? get currentUserProfile => _profile;

  @override
  Future<void> updateProfile(
    String fullName,
    String farmName,
    String location,
    String? phoneNumber,
  ) async {
    if (failUpdate) throw Exception('save failed');
    updateCalls.add([fullName, farmName, location, phoneNumber]);
  }
}

final _savedProfile = UserProfile(
  id: 'user-1',
  fullName: 'John Doe',
  email: 'john@example.com',
  farmName: 'Green Valley',
  location: 'Red Valley',
);

Future<void> _pumpSetupScreen(
  WidgetTester tester,
  UserProfile? profile, {
  SmartCropsService? service,
  Size size = const Size(390, 1600),
  String locale = 'en',
  double textScale = 1,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SmartCropsService>(
          create: (_) => service ?? _FakeCropsService(profile: profile),
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
        home: const ProfileSetupScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

AppLocalizations _l10nOf(WidgetTester tester) =>
    AppLocalizations.of(tester.element(find.byType(ProfileSetupScreen)));

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

  testWidgets(
    'shows About You step when the user has no saved About You data',
    (tester) async {
      await _pumpSetupScreen(
        tester,
        UserProfile(
          id: 'user-1',
          fullName: 'John Doe',
          email: 'john@example.com',
        ),
      );
      final l10n = _l10nOf(tester);

      expect(find.widgetWithText(TextFormField, l10n.fullName), findsOneWidget);
      expect(find.text(l10n.profileSetupStep2Title), findsNothing);
    },
  );

  testWidgets('prefills the About You form from the saved profile when shown', (
    tester,
  ) async {
    await _pumpSetupScreen(
      tester,
      UserProfile(
        id: 'user-1',
        fullName: 'John Doe',
        email: 'john@example.com',
      ),
    );

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextFormField && widget.controller?.text == 'John Doe',
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'skips the About You step when About You data was already saved',
    (tester) async {
      await _pumpSetupScreen(
        tester,
        UserProfile(
          id: 'user-1',
          fullName: 'John Doe',
          email: 'john@example.com',
          farmName: 'Green Valley',
          location: 'Red Valley',
        ),
      );
      final l10n = _l10nOf(tester);

      expect(find.text(l10n.profileSetupStep2Title), findsOneWidget);
      expect(find.widgetWithText(TextFormField, l10n.fullName), findsNothing);
      expect(find.widgetWithText(TextFormField, l10n.farmName), findsNothing);
      expect(find.widgetWithText(TextFormField, l10n.location), findsNothing);
    },
  );

  testWidgets('saves About You before advancing to the crops step', (
    tester,
  ) async {
    final service = _FakeCropsService();
    await _pumpSetupScreen(tester, null, service: service);
    final l10n = _l10nOf(tester);

    await tester.enterText(
      find.widgetWithText(TextFormField, l10n.fullName),
      'Maria Santos',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, l10n.farmName),
      'Green Valley',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, l10n.location),
      'Nueva Ecija',
    );
    await tester.tap(find.widgetWithText(FilledButton, l10n.next));
    await tester.pumpAndSettle();

    expect(service.updateCalls, [
      ['Maria Santos', 'Green Valley', 'Nueva Ecija', null],
    ]);
    expect(find.text(l10n.profileSetupStep2Title), findsOneWidget);
  });

  testWidgets('stays on About You when saving fails', (tester) async {
    final service = _FakeCropsService(failUpdate: true);
    await _pumpSetupScreen(tester, null, service: service);
    final l10n = _l10nOf(tester);

    await tester.enterText(
      find.widgetWithText(TextFormField, l10n.fullName),
      'Maria Santos',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, l10n.farmName),
      'Green Valley',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, l10n.location),
      'Nueva Ecija',
    );
    await tester.tap(find.widgetWithText(FilledButton, l10n.next));
    await tester.pumpAndSettle();

    expect(find.text(l10n.profileSetupStep2Title), findsNothing);
    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('says which step of three the Farmer is on', (tester) async {
    await _pumpSetupScreen(tester, null);

    expect(find.text('Step 1 of 3'), findsOneWidget);
  });

  testWidgets('asks for each missing required field by name of the problem', (
    tester,
  ) async {
    await _pumpSetupScreen(tester, null);
    await tester.tap(find.widgetWithText(FilledButton, 'Next'));
    await tester.pumpAndSettle();

    expect(find.text('This field is required'), findsNWidgets(3));
  });

  testWidgets('the first step has no Back button', (tester) async {
    await _pumpSetupScreen(tester, null);

    expect(find.byTooltip('Back'), findsNothing);
  });

  group('Main Crops step', () {
    testWidgets('offers crops to choose from', (tester) async {
      await _pumpSetupScreen(tester, _savedProfile);

      expect(find.text('Rice'), findsOneWidget);
    });

    testWidgets('says how many crops are selected', (tester) async {
      await _pumpSetupScreen(tester, _savedProfile);
      await tester.tap(find.text('Rice'));
      await tester.pumpAndSettle();

      expect(find.text('1 crop selected'), findsOneWidget);
    });

    testWidgets('marks a selected crop with a check, not colour alone', (
      tester,
    ) async {
      await _pumpSetupScreen(tester, _savedProfile);
      await tester.tap(find.text('Rice'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    testWidgets('search narrows the list', (tester) async {
      await _pumpSetupScreen(tester, _savedProfile);
      await tester.enterText(find.byType(TextField), 'ric');
      await tester.pumpAndSettle();

      expect(find.text('Pechay'), findsNothing);
    });

    testWidgets('Back from Permissions returns to Main Crops', (tester) async {
      await _pumpSetupScreen(tester, _savedProfile);
      await tester.tap(find.widgetWithText(FilledButton, 'Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();

      expect(find.text('Your Main Crops'), findsOneWidget);
    });

    testWidgets('continues to Permissions with no crops chosen', (
      tester,
    ) async {
      await _pumpSetupScreen(tester, _savedProfile);
      await tester.tap(find.widgetWithText(FilledButton, 'Next'));
      await tester.pumpAndSettle();

      expect(find.text('Complete Setup'), findsOneWidget);
    });
  });

  testWidgets('Permissions explains each permission', (tester) async {
    await _pumpSetupScreen(tester, _savedProfile);
    await tester.tap(find.widgetWithText(FilledButton, 'Next'));
    await tester.pumpAndSettle();

    expect(find.text('Required to scan your crops'), findsOneWidget);
  });

  for (final locale in ['en', 'tl', 'ceb']) {
    testWidgets('About You fits a phone at 200% text in $locale', (
      tester,
    ) async {
      final errors = <FlutterErrorDetails>[];
      final original = FlutterError.onError;
      FlutterError.onError = errors.add;
      try {
        await _pumpSetupScreen(
          tester,
          null,
          size: const Size(375, 667),
          locale: locale,
          textScale: 2,
        );
        await tester.tap(find.byType(FilledButton));
        await tester.pumpAndSettle();
      } finally {
        FlutterError.onError = original;
      }

      expect(errors, isEmpty);
    });

    testWidgets('crops and permissions fit a phone at 200% text in $locale', (
      tester,
    ) async {
      final errors = <FlutterErrorDetails>[];
      final original = FlutterError.onError;
      FlutterError.onError = errors.add;
      try {
        await _pumpSetupScreen(
          tester,
          _savedProfile,
          size: const Size(375, 667),
          locale: locale,
          textScale: 2,
        );
        await tester.tap(find.byType(FilledButton));
        await tester.pumpAndSettle();
      } finally {
        FlutterError.onError = original;
      }

      expect(errors, isEmpty);
    });
  }

  testWidgets('meets tap-target and label guidelines', (tester) async {
    final handle = tester.ensureSemantics();
    await _pumpSetupScreen(tester, null);

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    handle.dispose();
  });
}
