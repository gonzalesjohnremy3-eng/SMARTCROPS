import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_crops/app/build_config.dart';

/// Receives the privacy-safe event envelope. Implementations must never
/// throw to callers.
abstract class AnalyticsSink {
  Future<void> send(String name, Map<String, Object?> params);
}

/// Console sink for debug builds and widget tests.
class DebugAnalyticsSink implements AnalyticsSink {
  const DebugAnalyticsSink();

  @override
  Future<void> send(String name, Map<String, Object?> params) async {
    if (kDebugMode) {
      debugPrint('[analytics] $name ${params.isEmpty ? '' : params}');
    }
  }
}

/// Supabase sink: inserts into the `analytics_events` table. Fire-and-forget;
/// failures are dropped silently in release and printed in debug.
class SupabaseAnalyticsSink implements AnalyticsSink {
  const SupabaseAnalyticsSink(this._supabase);

  final SupabaseClient _supabase;

  @override
  Future<void> send(String name, Map<String, Object?> params) async {
    try {
      await _supabase.from('analytics_events').insert({
        'event': name,
        'params': params,
      });
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[analytics] dropped $name: $error');
      }
    }
  }
}

/// Feature-agnostic analytics wrapper.
///
/// Privacy rules (ADR 0009): every event carries `language`, `tier`,
/// `source_screen`, and `app_version`; PII-shaped keys never leave the
/// device; analytics never blocks core flows.
class Analytics {
  const Analytics({
    required this.sink,
    required this.language,
    required this.tier,
    this.appVersion = kAppVersion,
  });

  final AnalyticsSink sink;
  final String Function() language;
  final String Function() tier;
  final String appVersion;

  void track(String event, {Map<String, Object?> params = const {}}) {
    unawaited(trackAsync(event, params: params).catchError((_) {}));
  }

  Future<void> trackAsync(String event, {Map<String, Object?> params = const {}}) async {
    final envelope = <String, Object?>{
      ..._stripPII(params),
      'language': language(),
      'tier': tier(),
      'app_version': appVersion,
    };
    await sink.send(event, envelope);
  }

  static const _piiKeys = <String>[
    'full_name',
    'first_name',
    'last_name',
    'name',
    'phone',
    'phone_number',
    'mobile',
    'email',
    'address',
    'latitude',
    'longitude',
    'coordinates',
    'image',
    'image_url',
    'photo',
    'password',
  ];

  Map<String, Object?> _stripPII(Map<String, Object?> params) {
    final out = <String, Object?>{};
    for (final entry in params.entries) {
      final key = entry.key.toLowerCase();
      final isPii = _piiKeys.any((pii) => key == pii || key.contains(pii));
      if (isPii) continue;
      out[entry.key] = entry.value;
    }
    return out;
  }
}

extension AnalyticsContext on BuildContext {
  /// Best-effort screen tracking from tap handlers without hard coupling to
  /// Provider wiring. Silently no-ops when no [Analytics] is registered or
  /// the route name cannot be resolved.
  void trackEvent(String event, {Map<String, Object?> params = const {}}) {
    try {
      final analytics = Provider.of<Analytics>(this, listen: false);
      final source = ModalRoute.of(this)?.settings.name ?? 'unknown';
      analytics.track(
        event,
        params: <String, Object?>{'source_screen': source, ...params},
      );
    } catch (_) {
      // Analytics never breaks a user flow.
    }
  }
}
