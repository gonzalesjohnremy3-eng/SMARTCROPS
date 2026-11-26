import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every prototype verdict has a Flutter implementation map entry', () {
    final pages =
        Directory('design/prototypes')
            .listSync()
            .whereType<Directory>()
            .where((dir) => File('${dir.path}/brief.md').existsSync())
            .toList()
          ..sort((a, b) => a.path.compareTo(b.path));

    expect(pages, hasLength(14));

    final map = File(
      'design/prototypes/IMPLEMENTATION_MAP.md',
    ).readAsStringSync();

    for (final page in pages) {
      final id = page.path.split(Platform.pathSeparator).last;
      expect(
        map,
        contains('`$id`'),
        reason: '$id is missing from the implementation map',
      );
    }

    for (final token in const [
      'wide trust panel',
      'wide split dashboard',
      'critical banner',
      'comparison table',
      'two-column profile',
    ]) {
      expect(
        map,
        contains(token),
        reason: '$token has no mapped implementation',
      );
    }

    final mappedFiles = RegExp(r'`(lib/[^`]+)`')
        .allMatches(map)
        .map((match) => match.group(1)!)
        .toSet();
    expect(mappedFiles, hasLength(14));
    for (final file in mappedFiles) {
      expect(File(file).existsSync(), isTrue, reason: '$file is missing');
    }
  });

  test('design/prototypes is the only design line', () {
    expect(
      Directory('design/prototypes-cropcare').existsSync(),
      isFalse,
      reason: 'the retired CropCare prototypes must not come back',
    );
    expect(
      File('design/prototypes/GLASS_RESKIN.md').existsSync(),
      isFalse,
      reason: 'the retired glass layer must not come back',
    );
  });
}
