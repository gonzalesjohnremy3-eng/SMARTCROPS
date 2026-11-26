import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

Future<void> _pumpSetupScreen(
  WidgetTester tester,
  UserProfile? profile, {
  SmartCropsService? service,
}) async {
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SmartCropsService>(
          create: (_) => service ?? _FakeCropsService(profile: profile),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('tl'), Locale('ceb')],
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
}
