import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_crops/features/auth/domain/auth_failure.dart';

void main() {
  test('an expired or wrong code reads as a bad code', () {
    const error = AuthApiException(
      'Token has expired or is invalid',
      code: 'otp_expired',
    );

    expect(AuthFailure.from(error).kind, AuthFailureKind.badCode);
  });

  test('an SMS rate limit reads as too many attempts', () {
    const error = AuthApiException(
      'For security purposes, you can only request this after 42 seconds.',
      code: 'over_sms_send_rate_limit',
    );

    expect(AuthFailure.from(error).kind, AuthFailureKind.tooManyAttempts);
  });

  test('a rate limit carries the wait time Supabase reports', () {
    const error = AuthApiException(
      'For security purposes, you can only request this after 42 seconds.',
      code: 'over_request_rate_limit',
    );

    expect(AuthFailure.from(error).waitSeconds, 42);
  });

  test('an SMS that cannot be sent reads as an unreachable number', () {
    const error = AuthApiException(
      'Error sending sms',
      code: 'sms_send_failed',
    );

    expect(AuthFailure.from(error).kind, AuthFailureKind.unreachableNumber);
  });

  test('a failed network fetch reads as no connection', () {
    final error = AuthRetryableFetchException(message: 'ClientException');

    expect(AuthFailure.from(error).kind, AuthFailureKind.noConnection);
  });

  test('anything else reads as a generic failure', () {
    expect(AuthFailure.from(StateError('boom')).kind, AuthFailureKind.unknown);
  });
}
