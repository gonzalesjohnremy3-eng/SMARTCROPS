import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const root = 'design/prototypes-cropcare';
  const pages = ['home', 'scan', 'result', 'history', 'profile'];
  const palette = {
    '--bg': '#F5F3E9',
    '--surface': '#FBF9F1',
    '--surface-subtle': '#EEEBDD',
    '--primary': '#234B38',
    '--primary-dark': '#173526',
    '--primary-soft': '#DCE6D8',
    '--accent': '#E6AD45',
    '--accent-dark': '#B77B1F',
    '--text-primary': '#1C2D23',
    '--text-secondary': '#526257',
    '--text-inverse': '#FBF9F1',
    '--border': '#DEDCCF',
  };
  const fieldAlmanac = ['#12372A', '#1F6B45', '#7AC943', '#F2F6EC', '#FFFDF7'];

  test('isolated CropCare prototype set exists', () {
    expect(Directory(root).existsSync(), isTrue);
    expect(File('$root/index.html').existsSync(), isTrue);
    expect(File('$root/shared/tokens.css').existsSync(), isTrue);
    for (final page in pages) {
      expect(
        File('$root/$page/index.html').existsSync(),
        isTrue,
        reason: '$page page missing',
      );
    }
  });

  test(
    'shared tokens define the reference palette and no Field Almanac tokens',
    () {
      final css = File('$root/shared/tokens.css').readAsStringSync();
      palette.forEach((token, value) {
        expect(
          css,
          contains('$token: $value;'),
          reason: '$token must come from REFERENCE.md',
        );
      });
      for (final color in fieldAlmanac) {
        expect(
          css,
          isNot(contains(color)),
          reason: '$color belongs to the other design line',
        );
      }
      expect(css.toLowerCase(), anyOf(contains('roboto'), contains('inter')));
    },
  );

  test('prototypes use the four reference destinations and no live blur', () {
    final css = File('$root/shared/tokens.css').readAsStringSync();
    expect(css, isNot(contains('backdrop-filter')));
    expect(css, isNot(contains('--glass-')));

    for (final page in pages) {
      final html = File('$root/$page/index.html').readAsStringSync();
      for (final label in ['Home', 'Scan', 'History', 'Profile']) {
        expect(html, contains('>$label<'), reason: '$page needs $label in nav');
      }
    }
  });

  test('each screen has exactly one live glass surface', () {
    const glassSurfaces = {
      'home': 'notif-glass',
      'scan': 'cc-glass-capture',
      'result': 'cc-glass-status',
      'history': 'cc-glass-search',
      'profile': 'cc-glass-identity',
    };
    final blur = RegExp(r'^\s*backdrop-filter:', multiLine: true);
    glassSurfaces.forEach((page, marker) {
      final html = File('$root/$page/index.html').readAsStringSync();
      expect(html, contains(marker), reason: '$page missing $marker');
      expect(
        blur.allMatches(html).length,
        1,
        reason: '$page must have one live blur',
      );
    });
  });
}
