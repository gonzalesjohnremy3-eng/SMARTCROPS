/// Build-time constants used by instrumentation so they do not depend on
/// platform APIs. Keep [kAppVersion] in sync with `pubspec.yaml`.
const String kAppVersion = '1.0.0+1';

/// Set to true after the `analytics_events` migration is pushed. Until
/// then, events are printed to the debug console instead of the network.
const bool kRemoteAnalyticsEnabled = true;
