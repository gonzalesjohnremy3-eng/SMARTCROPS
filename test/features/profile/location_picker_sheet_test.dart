import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_crops/app/localization/ceb_fallback_localizations.dart';
import 'package:smart_crops/app/theme/app_theme.dart';
import 'package:smart_crops/features/profile/domain/davao_locations.dart';
import 'package:smart_crops/features/profile/services/device_place_finder.dart';
import 'package:smart_crops/features/profile/widgets/location_picker_sheet.dart';
import 'package:smart_crops/l10n/app_localizations.dart';

class _FakeFinder implements DevicePlaceFinder {
  _FakeFinder(this.result);

  final PlaceResult result;
  int calls = 0;

  @override
  Future<PlaceResult> findCurrentPlace() async {
    calls++;
    return result;
  }
}

final _locations = DavaoLocations.fromJson(
  jsonDecode(
        File('assets/data/davao_del_sur_locations.json').readAsStringSync(),
      )
      as Map<String, dynamic>,
);

/// Opens the sheet from a button and records what it returns.
class _Harness {
  String? picked;
  bool closed = false;
}

Future<_Harness> _pump(
  WidgetTester tester, {
  PlaceResult found = const PlaceUnavailable(),
  String locale = 'en',
  double textScale = 1,
  Size size = const Size(390, 900),
  _FakeFinder? finder,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final harness = _Harness();
  final fake = finder ?? _FakeFinder(found);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
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
              onPressed: () async {
                harness.picked = await showLocationPicker(
                  context,
                  finder: fake,
                  locations: Future.value(_locations),
                );
                harness.closed = true;
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return harness;
}

void main() {
  testWidgets('starts with the province, Davao del Sur', (tester) async {
    await _pump(tester);

    expect(find.text('Davao del Sur'), findsOneWidget);
  });

  testWidgets('offers to use the phone\'s location', (tester) async {
    await _pump(tester);

    expect(find.text('Use my current location'), findsOneWidget);
  });

  testWidgets('lists the cities and municipalities to choose from', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.text('Digos City'), findsOneWidget);
  });

  testWidgets('choosing a city shows its barangays', (tester) async {
    await _pump(tester);
    await tester.tap(find.text('Digos City'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'matti');
    await tester.pumpAndSettle();

    expect(find.text('Matti'), findsOneWidget);
  });

  testWidgets('choosing a barangay returns the full location', (tester) async {
    final harness = await _pump(tester);
    await tester.tap(find.text('Digos City'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'matti');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Matti'));
    await tester.pumpAndSettle();

    expect(harness.picked, 'Matti, Digos City, Davao del Sur');
  });

  testWidgets('search narrows the cities', (tester) async {
    await _pump(tester);
    await tester.enterText(find.byType(TextField), 'digos');
    await tester.pumpAndSettle();

    expect(find.text('Davao City'), findsNothing);
  });

  testWidgets('search narrows the barangays', (tester) async {
    await _pump(tester);
    await tester.tap(find.text('Digos City'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'matti');
    await tester.pumpAndSettle();

    expect(find.text('Zone 1 (Pob.)'), findsNothing);
  });

  testWidgets('a Farmer can go back to choose another city', (tester) async {
    await _pump(tester);
    await tester.tap(find.text('Digos City'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Change city or municipality'));
    await tester.pumpAndSettle();

    expect(find.text('Bansalan'), findsOneWidget);
  });

  group('using the phone\'s location', () {
    testWidgets('fills in a place it recognises without more taps', (
      tester,
    ) async {
      final harness = await _pump(
        tester,
        found: const PlaceFound(barangay: 'Matti', area: 'City of Digos'),
      );
      await tester.tap(find.text('Use my current location'));
      await tester.pumpAndSettle();

      expect(harness.picked, 'Matti, Digos City, Davao del Sur');
    });

    testWidgets('asks only for the barangay when just the city is known', (
      tester,
    ) async {
      await _pump(
        tester,
        found: const PlaceFound(barangay: 'Unknown', area: 'Bansalan'),
      );
      await tester.tap(find.text('Use my current location'));
      await tester.pumpAndSettle();

      expect(
        find.text('We found Bansalan. Now choose your barangay.'),
        findsOneWidget,
      );
    });

    testWidgets('says when location permission is off and keeps the list', (
      tester,
    ) async {
      await _pump(tester, found: const PlaceDenied());
      await tester.tap(find.text('Use my current location'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Location permission is off. You can choose your location below.',
        ),
        findsOneWidget,
      );
      expect(find.text('Digos City'), findsOneWidget);
    });

    testWidgets('says when the phone\'s location is switched off', (
      tester,
    ) async {
      await _pump(tester, found: const PlaceServiceOff());
      await tester.tap(find.text('Use my current location'));
      await tester.pumpAndSettle();

      expect(find.textContaining('location is off'), findsOneWidget);
    });

    testWidgets('says when the Farmer is outside Davao del Sur', (
      tester,
    ) async {
      await _pump(
        tester,
        found: const PlaceFound(barangay: 'Lahug', area: 'Cebu City'),
      );
      await tester.tap(find.text('Use my current location'));
      await tester.pumpAndSettle();

      expect(find.textContaining('only cover Davao del Sur'), findsOneWidget);
    });

    testWidgets('says when the location cannot be found at all', (
      tester,
    ) async {
      await _pump(tester, found: const PlaceUnavailable());
      await tester.tap(find.text('Use my current location'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('couldn\'t get your location'),
        findsOneWidget,
      );
    });

    testWidgets('does not ask the phone until the Farmer taps the button', (
      tester,
    ) async {
      final finder = _FakeFinder(const PlaceUnavailable());
      await _pump(tester, finder: finder);

      expect(finder.calls, 0);
    });
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
          found: const PlaceDenied(),
        );
        await tester.tap(find.byType(OutlinedButton).first);
        await tester.pumpAndSettle();
      } finally {
        FlutterError.onError = original;
      }

      expect(errors, isEmpty);
    });
  }

  testWidgets('meets tap-target and label guidelines', (tester) async {
    final handle = tester.ensureSemantics();
    await _pump(tester);

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    handle.dispose();
  });
}
