import 'package:supabase_flutter/supabase_flutter.dart';

enum AuthFailureKind {
  badCode,
  tooManyAttempts,
  unreachableNumber,
  noConnection,
  unknown,
}

/// What went wrong during phone sign-in, in terms the screen can explain
/// to a Farmer instead of showing raw Supabase text.
class AuthFailure {
  const AuthFailure(this.kind, {this.waitSeconds});

  factory AuthFailure.from(Object error) {
    if (error is AuthRetryableFetchException) {
      return const AuthFailure(AuthFailureKind.noConnection);
    }
    if (error is! AuthException) {
      return const AuthFailure(AuthFailureKind.unknown);
    }
    switch (error.code) {
      case 'otp_expired':
        return const AuthFailure(AuthFailureKind.badCode);
      case 'over_sms_send_rate_limit' || 'over_request_rate_limit':
        final seconds = RegExp(r'(\d+) seconds?').firstMatch(error.message);
        return AuthFailure(
          AuthFailureKind.tooManyAttempts,
          waitSeconds: seconds == null ? null : int.parse(seconds.group(1)!),
        );
      case 'sms_send_failed':
        return const AuthFailure(AuthFailureKind.unreachableNumber);
      default:
        return const AuthFailure(AuthFailureKind.unknown);
    }
  }

  final AuthFailureKind kind;
  final int? waitSeconds;
}
