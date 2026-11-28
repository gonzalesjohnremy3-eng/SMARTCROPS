import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _seedFile =
    'supabase/migrations/20261128020000_seed_philippine_crops.sql';

/// crop_name -> optimal_conditions, read from the seed's VALUES rows.
Map<String, Map<String, dynamic>> _seededCrops() {
  final sql = File(_seedFile).readAsStringSync();
  final row = RegExp(r"^\('([^']+)',\s*'(\{.*\})'::jsonb\)", multiLine: true);
  return {
    for (final match in row.allMatches(sql))
      match.group(1)!: json.decode(match.group(2)!) as Map<String, dynamic>,
  };
}

void main() {
  test('adds well over the original five crops', () {
    expect(_seededCrops().length, greaterThan(30));
  });

  test('names no crop twice', () {
    final sql = File(_seedFile).readAsStringSync();
    final names = RegExp(
      r"^\('([^']+)',",
      multiLine: true,
    ).allMatches(sql).map((m) => m.group(1)!).toList();

    expect(names.toSet().length, names.length);
  });

  test('covers the crops Davao del Sur is known for', () {
    expect(
      _seededCrops().keys,
      containsAll(['Banana', 'Coconut', 'Cacao', 'Coffee', 'Durian', 'Pomelo']),
    );
  });

  test('covers everyday vegetables and root crops', () {
    expect(
      _seededCrops().keys,
      containsAll(['Ampalaya', 'Sitaw', 'Okra', 'Camote', 'Cassava']),
    );
  });

  test('gives every crop the three conditions the app shows', () {
    final incomplete = _seededCrops().entries
        .where(
          (crop) => ![
            'temperature_range',
            'soil',
            'watering',
          ].every((key) => (crop.value[key] as String?)?.isNotEmpty ?? false),
        )
        .map((crop) => crop.key);

    expect(incomplete, isEmpty);
  });

  test('leaves the original five crops alone and never overwrites a crop', () {
    final sql = File(_seedFile).readAsStringSync();

    expect(sql, contains('on conflict (crop_name) do nothing'));
  });
}
