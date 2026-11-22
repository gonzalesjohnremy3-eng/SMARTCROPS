import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('tester billing grants Pro through a server function, not a client write', () {
    final source = File('lib/features/pro/domain/billing.dart').readAsStringSync();

    expect(
      source,
      contains('set-pro-tester'),
      reason: 'premium grants must go through a server-side function',
    );
    expect(
      source,
      isNot(contains('.upsert(')),
      reason: 'the client must never write the user_subscriptions tier itself',
    );
  });

  test('migration closes self-granted premium', () {
    final migration = File(
      'supabase/migrations/20261122000000_close_self_granted_premium.sql',
    ).readAsStringSync();

    expect(
      migration,
      contains('drop policy if exists "Users can insert own user_subscriptions"'),
    );
    expect(
      migration,
      contains("tier = 'free'"),
      reason: 'client inserts and updates must be constrained to the free tier',
    );
    expect(
      migration,
      contains('to service_role'),
      reason: 'premium grants must be executable only by the server',
    );
  });
}
