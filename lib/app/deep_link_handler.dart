import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:go_router/go_router.dart';

/// Bridges incoming deep links to the router.
///
/// Supported links: `smartcrops://scan/result/<scanId>`, `smartcrops://advisories/<id>`,
/// `smartcrops://calendar/events/<eventId>`, `smartcrops://cooperative`, etc.
/// The link is mapped by the pure resolver; the auth/profile guard
/// runs in `buildAppRouter` before the route is reached.
class DeepLinkHandler {
  DeepLinkHandler(this.router);

  final GoRouter router;
  StreamSubscription<Uri>? _subscription;

  Future<void> start() async {
    try {
      final appLinks = AppLinks();

      // Initial link (app opened from a link)
      Uri? initialUri;
      try {
        initialUri = await appLinks.getInitialLink();
      } catch (_) {
        initialUri = null;
      }
      if (initialUri != null) {
        _handleUri(initialUri);
      }

      // Foreground links while the app is running
      _subscription = appLinks.uriLinkStream.listen(
        _handleUri,
        onError: (_) {},
      );
    } catch (_) {
      // Deep links are unsupported on this platform; stay alive without them.
    }
  }

  void stop() {
    _subscription?.cancel();
    _subscription = null;
  }

  void _handleUri(Uri uri) {
    final path = _pathFromUri(uri);
    if (path != null) {
      router.go(path);
    }
  }

  String? _pathFromUri(Uri uri) {
    // smartcrops://scan/result/42 -> /scan/result/42
    final segments = <String>[...uri.pathSegments];
    if (segments.isEmpty) {
      // smartcrops://home -> /home
      final host = uri.host;
      return host.isEmpty ? '/home' : '/$host';
    }
    return '/${segments.join('/')}';
  }
}