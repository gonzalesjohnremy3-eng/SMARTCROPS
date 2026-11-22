# Analytics privacy review

- **Status:** Draft for human sign-off
- **Scope:** ADR 0009, UI/UX Blueprint section 10, `analytics_events` migration

## Data collected

Only the privacy-safe envelope is sent: `language`, `tier`, `source_screen`, `app_version`, plus optional `crop`, `disease`, `confidence_bucket`, and `severity`. PII-shaped keys are stripped in `lib/app/analytics/analytics.dart`. No names, phone numbers, images, precise coordinates, or user IDs are stored.

Destination is `public.analytics_events` in Supabase. The table has RLS enabled and allows authenticated inserts only.

Retention: 180 days from `created_at`.

Deletion: events are pseudonymous and carry no `user_id`, so an individual farmer's rows cannot be identified or deleted on request. Deletion is by retention window, not per user. Any dashboard export must be deleted at the same 180-day boundary. If user-level event deletion becomes a requirement, add a `user_id` column deliberately and update RLS before launch.

Basis and date range: every dashboard must state that its basis is `analytics_events` rows and show the exact date range represented. Do not present incomplete same-day data as a trend.

## Taxonomy reconciliation

All events currently emitted by the app are in the canonical list in `UI_UX_BLUEPRINT.md` section 10, enforced by `test/app/analytics/analytics_taxonomy_test.dart`.

Not yet instrumented because the screens do not exist: `auth_started`, `auth_method_selected`, `auth_succeeded`, `auth_failed`, `otp_requested`, `otp_verified`, cooperative events, `notification_preferences_changed`, and `privacy_opened`. These are tracked as missing-screen gaps, not renamed or invented.

Human sign-off: required by ADR 0009 before launch and not yet obtained. This document records the technical policy only; it is not a legal or product approval.
