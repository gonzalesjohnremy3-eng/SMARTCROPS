import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_crops/features/crops/widgets/crop_icon.dart';

Future<void> _pump(WidgetTester tester, String name) =>
    tester.pumpWidget(MaterialApp(home: CropIcon(name: name)));

void main() {
  group('cropIconKey', () {
    test('picks the icon drawn for a crop', () {
      expect(cropIconKey('Banana'), 'banana');
    });

    test('ignores case and surrounding spaces', () {
      expect(cropIconKey('  durian '), 'durian');
    });

    test('shares one icon between look-alike crops', () {
      expect(cropIconKey('Pomelo'), cropIconKey('Calamansi'));
    });

    test('has no icon yet for a crop that is not drawn', () {
      expect(cropIconKey('Mango'), isNull);
    });
  });

  test('every icon the app points at has its drawing', () {
    final missing = cropIconKeys.where(
      (key) => !File('assets/icons/crops/$key.svg').existsSync(),
    );

    expect(missing, isEmpty);
  });

  test('the app ships the crop icon folder', () {
    expect(
      File('pubspec.yaml').readAsStringSync(),
      contains('assets/icons/crops/'),
    );
  });

  testWidgets('a drawn crop shows its own icon', (tester) async {
    await _pump(tester, 'Banana');

    expect(find.byType(SvgPicture), findsOneWidget);
  });

  testWidgets('a crop without a drawing falls back to the leaf', (
    tester,
  ) async {
    await _pump(tester, 'Mango');

    expect(find.byIcon(Icons.eco_outlined), findsOneWidget);
  });
}
