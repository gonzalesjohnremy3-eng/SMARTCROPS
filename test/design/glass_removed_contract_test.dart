import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('design tokens no longer declare a glass family', () {
    final tokens =
        jsonDecode(File('design/tokens.json').readAsStringSync())
            as Map<String, dynamic>;
    final meta = tokens['meta'] as Map<String, dynamic>;

    expect(tokens.containsKey('glass'), isFalse);
    expect(meta['status'].toString().toLowerCase(), isNot(contains('glass')));
    expect(meta['theme'].toString().toLowerCase(), isNot(contains('glass')));
  });

  test('prototype tokens have no glass variables or live blur', () {
    final css = File('design/prototypes/shared/tokens.css').readAsStringSync();

    expect(css.toLowerCase(), isNot(contains('--glass-')));
    expect(css, isNot(contains('backdrop-filter')));
    expect(css, isNot(contains('.glass')));
  });

  test('prototype pages and briefs have no glass surfaces', () {
    final pages = Directory('design/prototypes')
        .listSync()
        .whereType<Directory>()
        .where((dir) => File('${dir.path}/brief.md').existsSync());

    for (final page in pages) {
      final brief = File('${page.path}/brief.md').readAsStringSync().toLowerCase();
      final html = File('${page.path}/index.html').readAsStringSync().toLowerCase();
      expect(brief, isNot(contains('glass')), reason: '$page brief still has glass');
      expect(html, isNot(contains('glass')), reason: '$page page still has glass');
    }
  });

  test('Flutter source has no glass surfaces or live blur', () {
    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));

    for (final file in files) {
      final source = file.readAsStringSync();
      for (final marker in const [
        'AppGlass',
        'GlassSurface',
        'GlassTone',
        'BackdropFilter',
        'ImageFilter.blur',
      ]) {
        expect(
          source,
          isNot(contains(marker)),
          reason: '${file.path} still contains $marker',
        );
      }
    }
  });

  test('ADR 0013 is superseded', () {
    final adr = File('docs/adr/0013-optimized-glassmorphism.md').readAsStringSync();
    expect(adr, contains('Superseded'));
  });

  test('status no longer presents glass as the active direction', () {
    final status = File(
      'PROJECT_KNOWLEDGE/DOCUMENTS/IMPLEMENTATION_STATUS.md',
    ).readAsStringSync();
    expect(status, isNot(contains('Field Almanac + optimized glass')));
  });
}
