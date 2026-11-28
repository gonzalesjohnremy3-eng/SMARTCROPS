import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_crops/features/profile/domain/davao_locations.dart';

DavaoLocations _load() => DavaoLocations.fromJson(
  jsonDecode(
        File('assets/data/davao_del_sur_locations.json').readAsStringSync(),
      )
      as Map<String, dynamic>,
);

void main() {
  final locations = _load();

  group('the official Davao del Sur list', () {
    test('is for the province of Davao del Sur', () {
      expect(locations.province, 'Davao del Sur');
    });

    test('has the eleven cities and municipalities', () {
      expect(locations.areas, hasLength(11));
    });

    test('includes Davao City and Digos City', () {
      expect(
        locations.areas.map((a) => a.name),
        containsAll(['Davao City', 'Digos City']),
      );
    });

    test('lists barangays under Digos City, including Matti', () {
      expect(locations.areaNamed('Digos City')!.barangays, contains('Matti'));
    });

    test('every area has barangays to choose from', () {
      expect(locations.areas.every((a) => a.barangays.isNotEmpty), isTrue);
    });

    test('areas are sorted so they are easy to scan', () {
      final names = locations.areas.map((a) => a.name).toList();

      expect(
        names,
        [...names]..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase())),
      );
    });
  });

  group('areaNamed', () {
    test('ignores letter case', () {
      expect(locations.areaNamed('digos city')?.name, 'Digos City');
    });

    test('returns nothing for a place outside the province', () {
      expect(locations.areaNamed('Cebu City'), isNull);
    });
  });

  group('format', () {
    test('writes barangay, city or municipality, then province', () {
      expect(
        locations.format(area: 'Digos City', barangay: 'Matti'),
        'Matti, Digos City, Davao del Sur',
      );
    });

    test('can write just the area when no barangay is known', () {
      expect(locations.format(area: 'Bansalan'), 'Bansalan, Davao del Sur');
    });
  });

  group('match (what the phone reports to a place in the list)', () {
    test('finds an exact barangay and city', () {
      final match = locations.match(barangay: 'Matti', area: 'Digos City');

      expect((match!.area.name, match.barangay), ('Digos City', 'Matti'));
    });

    test('understands the official "City of" wording', () {
      expect(
        locations.match(barangay: 'Matti', area: 'City of Digos')?.area.name,
        'Digos City',
      );
    });

    test('understands a name without the word City', () {
      expect(
        locations.match(barangay: 'Matti', area: 'Digos')?.area.name,
        'Digos City',
      );
    });

    test('ignores letter case and extra spaces', () {
      expect(
        locations.match(barangay: '  matti ', area: 'DIGOS CITY')?.barangay,
        'Matti',
      );
    });

    test('keeps the area when the barangay is not recognised', () {
      final match = locations.match(barangay: 'Nowhere', area: 'Bansalan');

      expect((match!.area.name, match.barangay), ('Bansalan', null));
    });

    test('keeps the area when the phone gives no barangay', () {
      expect(locations.match(area: 'Sulop')?.barangay, isNull);
    });

    test('finds nothing for a place outside Davao del Sur', () {
      expect(locations.match(barangay: 'Lahug', area: 'Cebu City'), isNull);
    });

    test('finds nothing when the phone reports no area at all', () {
      expect(locations.match(barangay: 'Matti'), isNull);
    });
  });
}
