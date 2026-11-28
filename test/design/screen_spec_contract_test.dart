import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

List<File> _specs() =>
    Directory('design/screens')
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.md'))
        .toList();

void main() {
  test('HTML prototypes are retired in favour of screen specs', () {
    expect(Directory('design/prototypes').existsSync(), isFalse);
  });

  test('retired design lines do not come back', () {
    expect(Directory('design/prototypes-cropcare').existsSync(), isFalse);
  });

  test('auth has a screen spec', () {
    expect(File('design/screens/03-auth.md').existsSync(), isTrue);
  });

  test('every screen spec states its purpose', () {
    for (final spec in _specs()) {
      expect(
        spec.readAsStringSync(),
        contains('**Purpose:**'),
        reason: '${spec.path} has no purpose line',
      );
    }
  });

  test('every screen spec names a Flutter file that exists', () {
    for (final spec in _specs()) {
      final match = RegExp(
        r'\*\*Flutter:\*\* `(lib/[^`]+)`',
      ).firstMatch(spec.readAsStringSync());
      expect(match, isNotNull, reason: '${spec.path} names no Flutter file');
      expect(File(match!.group(1)!).existsSync(), isTrue);
    }
  });
}
