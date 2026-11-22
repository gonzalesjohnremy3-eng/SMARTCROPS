import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Set<String> _canonicalEvents() {
  final blueprint = File(
    'PROJECT_KNOWLEDGE/DOCUMENTS/UI_UX_BLUEPRINT.md',
  ).readAsStringSync();
  final block = blueprint
      .split('The canonical list:')
      .last
      .split('```')
      .elementAt(1);
  return block
      .split(RegExp(r'[,\n]'))
      .map((event) => event.trim())
      .where((event) => event.isNotEmpty && !event.startsWith('text'))
      .toSet();
}

Set<String> _emittedEvents() {
  final emitted = <String>{};
  final call = RegExp(r"track(?:Event)?\(\s*'([a-z0-9_]+)'");
  final route = RegExp(r"'/[^']+':\s*'([a-z0-9_]+)'");

  for (final entity in Directory('lib').listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    final source = entity.readAsStringSync();
    for (final match in call.allMatches(source)) {
      emitted.add(match.group(1)!);
    }
    for (final match in route.allMatches(source)) {
      emitted.add(match.group(1)!);
    }
  }
  return emitted;
}

void main() {
  test('every emitted analytics event is in the canonical taxonomy', () {
    final unknown = _emittedEvents().difference(_canonicalEvents());

    expect(
      unknown,
      isEmpty,
      reason: 'unknown events: ${unknown.toList()..sort()}',
    );
  });

  test('privacy review records retention, deletion, and dashboard basis', () {
    final doc = File(
      'PROJECT_KNOWLEDGE/DOCUMENTS/ANALYTICS_PRIVACY_REVIEW.md',
    ).readAsStringSync();

    expect(doc, contains('Retention: 180 days'));
    expect(doc, contains('Deletion:'));
    expect(doc, contains('Basis and date range'));
    expect(doc, contains('Human sign-off'));
  });
}
