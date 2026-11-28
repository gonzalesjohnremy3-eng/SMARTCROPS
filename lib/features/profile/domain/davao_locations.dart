import 'dart:convert';

import 'package:flutter/services.dart';

/// A city or municipality of the province and its barangays.
class LocationArea {
  const LocationArea({
    required this.code,
    required this.name,
    required this.isCity,
    required this.barangays,
  });

  factory LocationArea.fromJson(Map<String, dynamic> json) => LocationArea(
    code: json['code'] as String,
    name: json['name'] as String,
    isCity: json['type'] == 'city',
    barangays: List<String>.from(json['barangays'] as List),
  );

  final String code;
  final String name;
  final bool isCity;
  final List<String> barangays;
}

/// A place the phone reported, found in the list. [barangay] is null when only
/// the city or municipality could be recognised.
class LocationMatch {
  const LocationMatch(this.area, this.barangay);

  final LocationArea area;
  final String? barangay;
}

/// The official Davao del Sur list (PSA PSGC data, bundled with the app).
class DavaoLocations {
  const DavaoLocations({required this.province, required this.areas});

  factory DavaoLocations.fromJson(Map<String, dynamic> json) => DavaoLocations(
    province: json['province'] as String,
    areas: [
      for (final area in json['areas'] as List)
        LocationArea.fromJson(area as Map<String, dynamic>),
    ],
  );

  static const assetPath = 'assets/data/davao_del_sur_locations.json';

  static Future<DavaoLocations> load([AssetBundle? bundle]) async {
    final raw = await (bundle ?? rootBundle).loadString(assetPath);
    return DavaoLocations.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  final String province;
  final List<LocationArea> areas;

  LocationArea? areaNamed(String name) {
    final wanted = _normalize(name);
    for (final area in areas) {
      if (_normalize(area.name) == wanted) return area;
    }
    return null;
  }

  /// "Matti, Digos City, Davao del Sur".
  String format({required String area, String? barangay}) => [
    if (barangay != null && barangay.isNotEmpty) barangay,
    area,
    province,
  ].join(', ');

  /// Finds what the phone reported in the list. Names differ between sources
  /// ("City of Digos", "Digos", "Digos City"), so they are compared loosely.
  /// With no recognised city or municipality there is no match.
  LocationMatch? match({String? barangay, String? area}) {
    if (area == null) return null;
    final found = areaNamed(area);
    if (found == null) return null;
    if (barangay == null) return LocationMatch(found, null);

    final wanted = _normalize(barangay);
    for (final candidate in found.barangays) {
      if (_normalize(candidate) == wanted) {
        return LocationMatch(found, candidate);
      }
    }
    return LocationMatch(found, null);
  }
}

String _normalize(String name) => name
    .toLowerCase()
    .trim()
    .replaceAll(RegExp(r'\s+'), ' ')
    .replaceFirst(RegExp(r'^city of '), '')
    .replaceFirst(RegExp(r' city$'), '')
    .replaceFirst(RegExp(r'^(barangay|brgy\.?) '), '');
