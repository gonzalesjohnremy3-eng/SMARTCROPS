import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _serviceRoleName = 'SUPABASE_SERVICE_ROLE_KEY';

List<String> _bundledAssetPaths() {
  final lines = File('pubspec.yaml').readAsLinesSync();
  final start = lines.indexWhere((line) => line.trim() == 'assets:');
  if (start < 0) return const <String>[];

  final paths = <String>[];
  for (final line in lines.skip(start + 1)) {
    final match = RegExp(r'^\s+-\s+(.+)$').firstMatch(line);
    if (match == null) break;
    paths.add(match.group(1)!.trim());
  }
  return paths;
}

void main() {
  test('bundled env does not expose the service-role key', () {
    final env = File('.env');
    if (!env.existsSync()) {
      return;
    }

    final names = env
        .readAsLinesSync()
        .where((line) => RegExp(r'^\s*[A-Z0-9_]+\s*=').hasMatch(line))
        .map((line) => line.split('=').first.trim())
        .toSet();

    expect(names, contains('SUPABASE_URL'));
    expect(names, contains('SUPABASE_ANON_KEY'));
    expect(
      names,
      isNot(contains(_serviceRoleName)),
      reason: 'The service-role key must never ship inside the app bundle',
    );
  });

  test('no bundled asset contains a service-role key', () {
    for (final path in _bundledAssetPaths()) {
      final file = File(path);
      if (!file.existsSync() || file.lengthSync() > 1024 * 1024) {
        continue;
      }
      expect(
        file.readAsStringSync().contains(_serviceRoleName),
        isFalse,
        reason: 'Bundled asset $path contains a service-role key',
      );
    }
  });
}
