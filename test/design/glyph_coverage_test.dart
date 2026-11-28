import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_crops/app/theme/app_theme.dart';

/// Every code point a TrueType font can draw, read from its `cmap` table
/// (formats 4 and 12 cover all the bundled fonts).
Set<int> _codePoints(String path) {
  final bytes = File(path).readAsBytesSync();
  final data = ByteData.sublistView(bytes);
  final tableCount = data.getUint16(4);
  int? cmapOffset;
  for (var i = 0; i < tableCount; i++) {
    final entry = 12 + 16 * i;
    if (utf8.decode(bytes.sublist(entry, entry + 4)) == 'cmap') {
      cmapOffset = data.getUint32(entry + 8);
    }
  }
  final cmap = cmapOffset!;
  final covered = <int>{};
  final subtables = data.getUint16(cmap + 2);
  for (var i = 0; i < subtables; i++) {
    final start = cmap + data.getUint32(cmap + 4 + 8 * i + 4);
    final format = data.getUint16(start);
    if (format == 4) {
      final segments = data.getUint16(start + 6) ~/ 2;
      final ends = start + 14;
      final starts = ends + segments * 2 + 2;
      final deltas = starts + segments * 2;
      final ranges = deltas + segments * 2;
      for (var s = 0; s < segments; s++) {
        final first = data.getUint16(starts + 2 * s);
        final last = data.getUint16(ends + 2 * s);
        if (first == 0xFFFF) continue;
        final delta = data.getInt16(deltas + 2 * s);
        final rangeOffset = data.getUint16(ranges + 2 * s);
        for (var c = first; c <= last; c++) {
          int glyph;
          if (rangeOffset == 0) {
            glyph = (c + delta) & 0xFFFF;
          } else {
            final at = ranges + 2 * s + rangeOffset + 2 * (c - first);
            final raw = data.getUint16(at);
            glyph = raw == 0 ? 0 : (raw + delta) & 0xFFFF;
          }
          // Glyph 0 is the empty "missing" box.
          if (glyph != 0) covered.add(c);
        }
      }
    } else if (format == 12) {
      final groups = data.getUint32(start + 12);
      for (var g = 0; g < groups; g++) {
        final at = start + 16 + 12 * g;
        covered.addAll([
          for (var c = data.getUint32(at); c <= data.getUint32(at + 4); c++) c,
        ]);
      }
    }
  }
  return covered;
}

/// Characters the app can show, from the ARB strings and the Dart sources
/// (comments skipped).
Map<int, Set<String>> _usedCodePoints() {
  final used = <int, Set<String>>{};
  void scan(String path, {bool skipComments = false}) {
    for (final line in File(path).readAsLinesSync()) {
      if (skipComments && line.trimLeft().startsWith('//')) continue;
      for (final rune in line.runes) {
        if (rune > 127) used.putIfAbsent(rune, () => {}).add(path);
      }
    }
  }

  for (final file in Directory('lib').listSync(recursive: true)) {
    if (file is! File) continue;
    if (file.path.endsWith('.arb')) scan(file.path);
    if (file.path.endsWith('.dart')) scan(file.path, skipComments: true);
  }
  return used;
}

void main() {
  test('every character the app shows can be drawn by a bundled font', () {
    final fonts = Directory('assets/fonts')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.ttf'))
        .map((f) => _codePoints(f.path))
        .toList();
    final drawable = fonts.expand((cp) => cp).toSet();

    final missing = {
      for (final entry in _usedCodePoints().entries)
        if (!drawable.contains(entry.key))
          'U+${entry.key.toRadixString(16).toUpperCase().padLeft(4, '0')} '
              '(${String.fromCharCode(entry.key)}) in ${entry.value.first}',
    };

    expect(missing, isEmpty, reason: 'No bundled font can draw these.');
  });

  test('the peso sign is drawn by the bundled fallback font', () {
    final roboto = Directory(
      'assets/fonts/roboto',
    ).listSync().whereType<File>().where((f) => f.path.endsWith('.ttf')).first;

    expect(_codePoints(roboto.path), contains(0x20B1));
  });

  test('every text style falls back to Roboto for symbols the brand fonts lack', () {
    final t = AppTheme.light().textTheme;
    final styles = {
      'displayLarge': t.displayLarge,
      'displayMedium': t.displayMedium,
      'displaySmall': t.displaySmall,
      'headlineLarge': t.headlineLarge,
      'headlineMedium': t.headlineMedium,
      'headlineSmall': t.headlineSmall,
      'titleLarge': t.titleLarge,
      'titleMedium': t.titleMedium,
      'titleSmall': t.titleSmall,
      'bodyLarge': t.bodyLarge,
      'bodyMedium': t.bodyMedium,
      'bodySmall': t.bodySmall,
      'labelLarge': t.labelLarge,
      'labelMedium': t.labelMedium,
      'labelSmall': t.labelSmall,
    };

    final without = [
      for (final e in styles.entries)
        if (!(e.value?.fontFamilyFallback ?? const []).contains('Roboto')) e.key,
    ];

    expect(without, isEmpty);
  });
}
