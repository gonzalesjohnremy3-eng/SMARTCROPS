import 'dart:async';
import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Route to open when a farmer taps an FCM notification.
///
/// Data payloads may carry either an explicit safe `path` or
/// `target` + `recordId`. Only routes that exist in the router are emitted;
/// everything else falls back to the advisories inbox.
String routeForNotificationData(Map<String, dynamic> data) {
  const safePrefixes = [
    '/home',
    '/crops',
    '/calendar',
    '/advisories',
    '/health-log',
    '/care-plan',
    '/shop',
    '/pro',
  ];
  bool isSafe(String path) =>
      safePrefixes.any((prefix) => path == prefix || path.startsWith('$prefix/'));

  final path = data['path'];
  if (path is String && isSafe(path)) {
    return path;
  }

  final targetRaw = data['target']?.toString();
  final recordId = data['recordId']?.toString();
  switch (targetRaw) {
    case 'task' when recordId != null && recordId.isNotEmpty:
      return '/calendar/events/${Uri.encodeComponent(recordId)}';
    case 'crop' when recordId != null && recordId.isNotEmpty:
      return '/crops/${Uri.encodeComponent(recordId)}';
    case 'scan':
      // Standalone scan detail route does not exist yet (Health Log covers scans).
      return '/health-log';
    case 'advisory':
    case 'cooperative':
    default:
      return '/advisories';
  }
}

/// Optional FCM delivery. Everything here is best-effort:
/// - unsupported platforms and non-configured Firebase stay alive quietly;
/// - token upload failures never block the app.
class PushNotificationsService {
  PushNotificationsService(this.router, {SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  final GoRouter router;
  final SupabaseClient _supabase;
  StreamSubscription<String>? _tokenRefreshSubscription;
  bool _initialized = false;

  bool get _supported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS || Platform.isMacOS);

  Future<void> init() async {
    if (_initialized || !_supported) return;
    _initialized = true;
    try {
      await Firebase.initializeApp();
    } catch (_) {
      // google-services.json missing or Firebase not configured for this build.
      return;
    }

    final messaging = FirebaseMessaging.instance;
    try {
      await messaging.requestPermission();
    } catch (_) {
      // Permission APIs unavailable on this platform; carry on.
    }

    try {
      final token = await messaging.getToken();
      if (token != null) {
        await _saveToken(token);
      }
    } catch (_) {
      // Token unavailable offline or not registered; refresh stream will retry.
    }
    _tokenRefreshSubscription = messaging.onTokenRefresh.listen(
      (token) => unawaited(_saveToken(token)),
    );

    // Foreground: the Supabase Realtime advisory subscription updates the UI live.
    FirebaseMessaging.onMessage.listen((_) {});

    // Background/notification tray tap.
    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) => router.go(routeForNotificationData(message.data)),
    );

    // Terminated app opened from a notification tap.
    final initial = await messaging.getInitialMessage();
    if (initial != null) {
      router.go(routeForNotificationData(initial.data));
    }
  }

  Future<void> _saveToken(String token) async {
    final session = _supabase.auth.currentSession;
    if (session == null) return;
    try {
      await _supabase.from('device_tokens').upsert({
        'user_id': session.user.id,
        'token': token,
        'platform': Platform.isAndroid
            ? 'android'
            : Platform.isIOS
                ? 'ios'
                : 'macos',
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }, onConflict: 'user_id,token');
    } catch (_) {
      // Token sync is best-effort; never break the app over it.
    }
  }

  Future<void> stop() async {
    await _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = null;
  }
}
