import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_crops/app/localization/ceb_fallback_localizations.dart';
import 'package:smart_crops/app/localization/language_preference.dart';
import 'package:smart_crops/app/localization/locale_provider.dart';
import 'package:smart_crops/features/profile/screens/profile_screen.dart';
import 'package:smart_crops/features/pro/services/agri_pro_entitlement.dart';
import 'package:smart_crops/l10n/app_localizations.dart';
import 'package:smart_crops/models/app_models.dart';
import 'package:smart_crops/services/farm_data_loader.dart';
import 'package:smart_crops/services/farm_snapshot.dart';
import 'package:smart_crops/services/smart_crops_service.dart';

class _MemoryStore extends LanguageStore {
  @override
  Future<String?> load() async => 'en';

  @override
  Future<void> save(String languageCode) async {}
}

class _StubLoader implements FarmDataLoader {
  _StubLoader(this.snapshot);

  final FarmSnapshot snapshot;

  @override
  Future<List<CropItem>> fetchCropsCatalog() async => snapshot.availableCrops;

  @override
  Future<FarmSnapshot?> fetchFarmData() async => snapshot;
}

class _TestService extends SmartCropsService {
  _TestService({super.loader, this.failAvatar = false});

  final bool failAvatar;
  Uint8List? avatarBytes;

  @override
  Future<void> updateAvatar(Uint8List bytes, {String extension = 'jpg'}) async {
    if (failAvatar) throw Exception('upload failed');
    avatarBytes = bytes;
  }
}

final _maria = UserProfile(
  id: 'u',
  fullName: 'Maria Santos',
  email: 'maria@example.com',
  farmName: 'Santos Farm',
  location: 'Nueva Ecija',
);

Future<_TestService> _pump(
  WidgetTester tester, {
  required Size size,
  UserProfile? profile,
  List<CropItem> crops = const [],
  String locale = 'en',
  double textScale = 1,
  Future<String?> Function(BuildContext)? pickLocation,
  Future<XFile?> Function(ImageSource)? pickAvatar,
  bool failAvatar = false,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final service = _TestService(
    failAvatar: failAvatar,
    loader: _StubLoader(
      FarmSnapshot(
        availableCrops: crops,
        userCrops: crops,
        scanHistory: const [],
        notifications: const [],
        calendarEvents: const [],
        fetchedAt: DateTime(2026, 1, 1),
        profile: profile,
      ),
    ),
  );
  await service.initializeUserData();
  final entitlement = AgriProEntitlement(fetchRow: () async => null);
  await entitlement.load();

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SmartCropsService>.value(value: service),
        ChangeNotifierProvider.value(value: entitlement),
        ChangeNotifierProvider(
          create: (_) => LocaleProvider(
            preference: LanguagePreference(store: _MemoryStore()),
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
        home: ProfileScreen(pickLocation: pickLocation, pickAvatar: pickAvatar),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return service;
}

XFile _photo() => XFile.fromData(
  Uint8List.fromList([1, 2, 3]),
  name: 'me.jpg',
  mimeType: 'image/jpeg',
);

Future<void> _startEditing(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('profile_edit')));
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

  testWidgets('shows two grouped columns at expanded width', (tester) async {
    await _pump(tester, size: const Size(1200, 900));

    expect(find.byKey(const Key('profile-wide-two-column')), findsOneWidget);
    expect(find.byKey(const Key('profile-farm-column')), findsOneWidget);
    expect(find.byKey(const Key('profile-settings-column')), findsOneWidget);
  });

  testWidgets('keeps one grouped list at compact width', (tester) async {
    await _pump(tester, size: const Size(390, 844));

    expect(find.byKey(const Key('profile-wide-two-column')), findsNothing);
  });

  group('identity', () {
    testWidgets('names the Farmer', (tester) async {
      await _pump(tester, size: const Size(390, 1600), profile: _maria);

      expect(find.text('Maria Santos'), findsOneWidget);
    });

    testWidgets('shows the email', (tester) async {
      await _pump(tester, size: const Size(390, 1600), profile: _maria);

      expect(find.text('maria@example.com'), findsOneWidget);
    });

    testWidgets('uses the first initial as the avatar', (tester) async {
      await _pump(tester, size: const Size(390, 1600), profile: _maria);

      expect(find.text('M'), findsOneWidget);
    });
  });

  group('farm details', () {
    testWidgets('shows the farm name, not the Farmer\'s name', (tester) async {
      await _pump(tester, size: const Size(390, 1600), profile: _maria);

      expect(find.text('Santos Farm'), findsOneWidget);
    });

    testWidgets('shows the location', (tester) async {
      await _pump(tester, size: const Size(390, 1600), profile: _maria);

      expect(find.text('Nueva Ecija'), findsOneWidget);
    });

    testWidgets('a missing phone number shows a dash, not a blank', (
      tester,
    ) async {
      await _pump(tester, size: const Size(390, 1600), profile: _maria);

      expect(find.text('—'), findsOneWidget);
    });

    testWidgets('editing reveals the name, farm and phone fields', (
      tester,
    ) async {
      await _pump(tester, size: const Size(390, 1600), profile: _maria);
      await _startEditing(tester);

      expect(find.byType(TextField), findsNWidgets(3));
    });

    testWidgets('the location is chosen from a list, not typed', (
      tester,
    ) async {
      await _pump(tester, size: const Size(390, 1600), profile: _maria);
      await _startEditing(tester);

      expect(find.byKey(const Key('profile_location_field')), findsOneWidget);
    });

    testWidgets('the location field shows the current location', (
      tester,
    ) async {
      await _pump(tester, size: const Size(390, 1600), profile: _maria);
      await _startEditing(tester);

      expect(
        find.descendant(
          of: find.byKey(const Key('profile_location_field')),
          matching: find.text('Nueva Ecija'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('an empty location invites the Farmer to choose one', (
      tester,
    ) async {
      await _pump(
        tester,
        size: const Size(390, 1600),
        profile: UserProfile(
          id: 'u',
          fullName: 'Maria',
          email: 'm@example.com',
        ),
      );
      await _startEditing(tester);

      expect(find.text('Choose your location'), findsOneWidget);
    });

    testWidgets('tapping the location field opens the location picker', (
      tester,
    ) async {
      var opened = 0;
      await _pump(
        tester,
        size: const Size(390, 1600),
        profile: _maria,
        pickLocation: (_) async {
          opened++;
          return null;
        },
      );
      await _startEditing(tester);
      await tester.tap(find.byKey(const Key('profile_location_field')));
      await tester.pumpAndSettle();

      expect(opened, 1);
    });

    testWidgets('a chosen location fills the field', (tester) async {
      await _pump(
        tester,
        size: const Size(390, 1600),
        profile: _maria,
        pickLocation: (_) async => 'Matti, Digos City, Davao del Sur',
      );
      await _startEditing(tester);
      await tester.tap(find.byKey(const Key('profile_location_field')));
      await tester.pumpAndSettle();

      expect(find.text('Matti, Digos City, Davao del Sur'), findsOneWidget);
    });

    testWidgets('closing the picker keeps the old location', (tester) async {
      await _pump(
        tester,
        size: const Size(390, 1600),
        profile: _maria,
        pickLocation: (_) async => null,
      );
      await _startEditing(tester);
      await tester.tap(find.byKey(const Key('profile_location_field')));
      await tester.pumpAndSettle();

      expect(find.text('Nueva Ecija'), findsOneWidget);
    });

    testWidgets('editing offers a clearly labelled save', (tester) async {
      await _pump(tester, size: const Size(390, 1600), profile: _maria);
      await tester.tap(find.byKey(const Key('profile_edit')));
      await tester.pumpAndSettle();

      expect(find.text('Save changes'), findsOneWidget);
    });
  });

  group('Main Crops header', () {
    testWidgets('Manage sits at the right edge, not beside the title', (
      tester,
    ) async {
      await _pump(tester, size: const Size(390, 1600), profile: _maria);

      expect(tester.getTopRight(find.text('Manage')).dx, greaterThan(390 - 48));
    });

    testWidgets('Manage is vertically centred on the title', (tester) async {
      await _pump(tester, size: const Size(390, 1600), profile: _maria);

      final title = tester.getCenter(find.text('Main Crops')).dy;
      final manage = tester.getCenter(find.text('Manage')).dy;

      expect((title - manage).abs(), lessThan(4));
    });
  });

  group('profile photo', () {
    testWidgets('has no camera badge while just viewing', (tester) async {
      await _pump(tester, size: const Size(390, 1600), profile: _maria);

      expect(find.byKey(const Key('profile_avatar_badge')), findsNothing);
    });

    testWidgets('editing adds a camera badge to the photo', (tester) async {
      await _pump(tester, size: const Size(390, 1600), profile: _maria);
      await _startEditing(tester);

      expect(find.byKey(const Key('profile_avatar_badge')), findsOneWidget);
    });

    testWidgets('tapping the photo offers camera or gallery', (tester) async {
      await _pump(tester, size: const Size(390, 1600), profile: _maria);
      await _startEditing(tester);
      await tester.tap(find.byKey(const Key('profile_avatar')));
      await tester.pumpAndSettle();

      expect(find.text('Choose from gallery'), findsOneWidget);
      expect(find.text('Take a photo'), findsOneWidget);
    });

    testWidgets('tapping the photo when not editing does nothing', (
      tester,
    ) async {
      await _pump(tester, size: const Size(390, 1600), profile: _maria);
      await tester.tap(find.byKey(const Key('profile_avatar')));
      await tester.pumpAndSettle();

      expect(find.text('Choose from gallery'), findsNothing);
    });

    testWidgets('a photo from the gallery is uploaded', (tester) async {
      final service = await _pump(
        tester,
        size: const Size(390, 1600),
        profile: _maria,
        pickAvatar: (source) async =>
            source == ImageSource.gallery ? _photo() : null,
      );
      await _startEditing(tester);
      await tester.tap(find.byKey(const Key('profile_avatar')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Choose from gallery'));
      await tester.pumpAndSettle();

      expect(service.avatarBytes, [1, 2, 3]);
    });

    testWidgets('a photo from the camera is uploaded', (tester) async {
      final service = await _pump(
        tester,
        size: const Size(390, 1600),
        profile: _maria,
        pickAvatar: (source) async =>
            source == ImageSource.camera ? _photo() : null,
      );
      await _startEditing(tester);
      await tester.tap(find.byKey(const Key('profile_avatar')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Take a photo'));
      await tester.pumpAndSettle();

      expect(service.avatarBytes, [1, 2, 3]);
    });

    testWidgets('cancelling the picker uploads nothing', (tester) async {
      final service = await _pump(
        tester,
        size: const Size(390, 1600),
        profile: _maria,
        pickAvatar: (_) async => null,
      );
      await _startEditing(tester);
      await tester.tap(find.byKey(const Key('profile_avatar')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Choose from gallery'));
      await tester.pumpAndSettle();

      expect(service.avatarBytes, isNull);
    });

    testWidgets('a failed upload says so', (tester) async {
      await _pump(
        tester,
        size: const Size(390, 1600),
        profile: _maria,
        pickAvatar: (_) async => _photo(),
        failAvatar: true,
      );
      await _startEditing(tester);
      await tester.tap(find.byKey(const Key('profile_avatar')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Choose from gallery'));
      await tester.pumpAndSettle();

      expect(
        find.text("We couldn't upload your photo. Please try again."),
        findsOneWidget,
      );
    });

    testWidgets('a saved photo is shown instead of the initial', (
      tester,
    ) async {
      await _pump(
        tester,
        size: const Size(390, 1600),
        profile: UserProfile(
          id: 'u',
          fullName: 'Maria Santos',
          email: 'maria@example.com',
          avatarUrl: 'https://example.com/me.jpg',
        ),
      );

      expect(find.byKey(const Key('profile_avatar_image')), findsOneWidget);
    });

    testWidgets('the photo is cropped to a circle', (tester) async {
      await _pump(
        tester,
        size: const Size(390, 1600),
        profile: UserProfile(
          id: 'u',
          fullName: 'Maria Santos',
          email: 'maria@example.com',
          avatarUrl: 'https://example.com/me.jpg',
        ),
      );

      expect(
        find.ancestor(
          of: find.byKey(const Key('profile_avatar_image')),
          matching: find.byType(ClipOval),
        ),
        findsOneWidget,
      );
    });
  });

  testWidgets('lists the Main Crops', (tester) async {
    await _pump(
      tester,
      size: const Size(390, 1600),
      profile: _maria,
      crops: [CropItem(id: 'r', cropName: 'Rice', optimalConditions: {})],
    );

    expect(find.text('Rice'), findsOneWidget);
  });

  testWidgets('offers all three languages', (tester) async {
    await _pump(tester, size: const Size(390, 1600), profile: _maria);

    expect(find.text('Cebuano'), findsOneWidget);
  });

  testWidgets('keeps sign out reachable', (tester) async {
    await _pump(tester, size: const Size(390, 1600), profile: _maria);

    expect(find.text('Sign Out'), findsOneWidget);
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
          profile: _maria,
          crops: [
            CropItem(id: 'r', cropName: 'Rice', optimalConditions: {}),
            CropItem(id: 't', cropName: 'Tomato', optimalConditions: {}),
          ],
          locale: locale,
          textScale: 2,
        );
        await tester.tap(find.byKey(const Key('profile_edit')));
        await tester.pumpAndSettle();
      } finally {
        FlutterError.onError = original;
      }

      expect(errors, isEmpty);
    });
  }
}
