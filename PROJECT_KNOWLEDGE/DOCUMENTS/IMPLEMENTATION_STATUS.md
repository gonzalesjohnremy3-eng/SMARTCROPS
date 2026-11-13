# Smart Crops (Agri Lynk) - Implementation Status & Feature Tracking Guide

This document tracks the user-accessible reality of every feature against `PROJECT_PLANNING.md`, `WEATHER_FEATURE_PLAN.md`, the PDF design specification, and `UI_UX_BLUEPRINT.md`.

**Audit date:** 2026-11-13 (UI/UX Phase 0 + Phase 1 complete: navigation, screens, offline queue, cached surfaces, global states, accessibility + golden tests)  
**Important:** A backend table, Edge Function, or test-only implementation is not a shipped feature. Statuses below describe what a farmer can actually use in the app today.

---

## 1. Summary Status Legend

- **[x] Implemented:** User-accessible end-to-end and integrated into the Flutter app.
- **[~] Partial:** UI or service exists, but the flow is incomplete, unwired, non-persistent, or placeholder-driven.
- **[B] Backend / schema only:** Migration, table, seed, or Edge Function exists with no app UI or service.
- **[T] Test-only:** Logic exists only in tests, not in production code.
- **[ ] Not implemented:** No user-accessible implementation.

---

## 2. Comprehensive Feature Tracking Table

| Module / Feature | Specification Reference | Status | Evidence and gap |
|---|---|---|---|
| Agri Lynk branding | Planning Sec 1, PDF Pages 1-3 | **[~] Partial** | Brand strings, onboarding, and tokenized identity via `AppTheme`; all screens (including auth) use tokens and ARB strings. No dedicated splash screen yet. |
| Onboarding (3 pages) | Blueprint Sec 5.2 | **[x] Implemented** | `lib/features/onboarding/screens/onboarding_screen.dart` — 3 skippable pages, first-run routing via `onboarding_complete` flag and the route guard. |
| Email and password authentication | Planning Sec 3-4, PDF Page 4 | **[x] Implemented** | `lib/features/auth/screens/auth_screen.dart`, `SmartCropsService.signInWithEmail`, `signUpWithEmail`. Full-flavor auth (email/password, Google, Facebook, phone OTP), tokenized UI, localized strings, routed through go_router (`/auth`). |
| Google OAuth | Planning Sec 3-4, PDF Page 4 | **[x] Implemented** | `signInWithOAuth(OAuthProvider.google)`; platform configuration should be re-verified before release. |
| Facebook OAuth | Planning Sec 3-4, PDF Page 4 | **[x] Implemented** | `signInWithOAuth(OAuthProvider.facebook)`; platform configuration should be re-verified before release. |
| Phone number and SMS OTP | Planning Sec 3-4, PDF Page 4 | **[~] Partial** | OTP UI and service methods exist; success depends on a configured SMS provider. Phone-only users are supported by the latest migration. |
| Profile setup and multiple crop selection | Planning Sec 4, 7 (Page 5) | **[x] Implemented** | 3-step wizard in `lib/features/profile/screens/profile_setup_screen.dart` (About You → Main Crops → Permissions), preserving the existing `user_crops` relation; legacy `lib/screens/profile_setup_screen.dart` deleted. |
| Dashboard Home / Field Briefing | Planning Sec 7 (Page 6), Blueprint Sec 5.6 | **[x] Implemented** | `lib/features/home/screens/home_screen.dart` is the routed Home: the priority action is chosen from live service data by `lib/features/home/domain/field_briefing.dart` (unit-tested); the weather panel reflects cached/live weather with a last-updated time; the Care Plan and Recent Diagnoses previews render real `calendarEvents`/`scanHistory` (with honest empty states), the advisory banner shows the latest unread notification only when one exists, and pull-to-refresh reloads data. Widget-tested and golden-tested. |
| Weather and location widget | Weather Plan Sec 2-5 | **[x] Implemented** | `weather_service.dart` with `wttr.in` (parses `precipMM`); weather is cached to SharedPreferences with a last-updated time shown on Home. Home briefing consumes the service for the critical-weather fact. |
| Notification bell and alerts modal | Planning Sec 6-7, PDF Page 6 | **[~] Partial** | `/advisories` is now a real inbox (`lib/features/advisories/screens/advisories_screen.dart`): lists `notifications`, unread badge, `advisoryMarkAllRead`, tap-to-mark-read. Still no realtime subscription, no critical pin, no deep link from a push notification. The legacy notification bell in the dashboard is removed (dashboard deleted). |
| Scan Crop capture UI | Planning Sec 5, 7 (Page 7) | **[~] Partial** | Full capture → review → result flow implemented in `lib/features/scan/screens/`: dark forest viewfinder with reticle, `scan_review_screen.dart` analyzes via `performAiScan`, `scan_result_screen.dart` renders severity/confidence/treatment steps. Captured images upload to the `scan-images` Supabase Storage bucket (authenticated, RLS-scoped), and offline captures enqueue and retry. The scan-quota policy exists but is not yet enforced at capture (Phase 2 paywall work). |
| Scan result presentation | Blueprint Sec 5.11 | **[x] Implemented** | `lib/features/scan/domain/diagnosis_presenter.dart` maps raw diagnosis → severity band, confidence band (low <70%, medium 70–84%, high ≥85%), treatment steps; low confidence makes retake the primary action and hides partner offers. `ScanResultScreen` renders it; widget-tested. |
| AI analysis and multi-key rotation | Planning Sec 3, 5 | **[x] Implemented** | `supabase/functions/scan-crop` plus `ai_keys_pool`; rotation logic unit-tested in `test/ai_key_rotation_test.dart`. Client invocation has a mock fallback. |
| My Crops management | Planning Sec 7, PDF Page 6 | **[x] Implemented** | `lib/features/crops/screens/crops_screen.dart` (routed at `/crops`) lists the farmer's Main Crops with optimal conditions and last-scan info; tapping a card opens `lib/features/crops/screens/crop_detail_screen.dart` (`/crops/:cropId`). Crop detail shows honest catalog growing conditions (`Not available` when missing — never invented), the latest two scans for that crop, upcoming tasks for that crop with an `Open calendar` link, and `Scan this crop` as the primary action; the crop scan button still jumps straight to capture. Widget-tested. Crop photos, growth-stage data, and a built-out care guide await schema fields. |
| Recommendations / Care Plan | Planning Sec 4, 7 | **[~] Partial** | `lib/features/care_plan/screens/care_plan_screen.dart` (routed at `/care-plan`) lists pending calendar care tasks, checkable, with link to Field Calendar. Not yet personalized by crop stage or scan history; no 'Add to Field Calendar' from result flow yet. |
| Health Log | Blueprint Sec 5.12 | **[~] Partial** | `lib/features/health_log/screens/health_log_screen.dart` (routed at `/health-log`) shows a season summary (scans / healthy / at-risk) and the scan list with diagnosis severity derived from the presenter. No filters, search, or scan detail screen yet. |
| Scan History | Planning Sec 6-7 | **[x] Implemented** | Scan history is surfaced by `HealthLogScreen` (`/health-log`): season summary, severity from the diagnosis presenter, per-scan rows. Legacy `history_screen.dart` deleted. Filtering, search, and a scan detail screen are not built. |
| Farmer profile and settings | Planning Sec 4 | **[~] Partial** | `lib/features/profile/screens/profile_screen.dart` (routed at `/profile`) supports inline profile editing, Main Crops display with Manage link, language switching via a `LocaleProvider` (app-wide, persisted), and sign out with confirmation. No notification preferences, privacy, Agri Pro, or Cooperative management yet. |
| Main navigation | Blueprint Sec 4 | **[x] Implemented** | `lib/app/router/app_router.dart` — `go_router` `StatefulShellRoute.indexedStack` with 5 destinations (Home, Crops, Scan, Calendar, Profile), preserved branch state, responsive `NavigationBar` (<840px) / extended `NavigationRail` (≥840px), advisory/care-plan/health-log routes above the shell. Legacy `main_navigation_screen.dart` and `dashboard_screen.dart` removed. |
| Route guards and deep links | Blueprint Sec 4.3-4.4, ADR 0003 | **[~] Partial** | `lib/app/router/route_guard.dart` implements auth/onboarding/profile/role guards (unit-tested S2); wired into `buildAppRouter` redirect. Android/iOS `smartcrops://` schemes configured and `lib/app/deep_link_handler.dart` routes incoming links. Universal links (HTTPS domain) not configured; domain unconfirmed. |
| Supabase schema and RLS (core) | Planning Sec 6 | **[x] Implemented** | Core tables and policies exist in `supabase/migrations/20260311000000_smart_crops_schema.sql`. |
| Push notifications (FCM / Realtime) | Planning Sec 4 (Phase 2) | **[ ] Not implemented** | Notifications are fetched on `initializeUserData`; there is no Realtime channel, FCM integration, or push deep-link handling. |
| Personalized Crop Calendar | Core differentiation strategy | **[~] Partial** | `lib/features/calendar/screens/field_calendar_screen.dart` (routed at `/calendar`) renders real `crop_calendar_events` with Today/Week/Month filters, completion toggle, overdue and weather-adjusted badges, and calls `adjustForWeather` with the live precipitation forecast. `weather_service.dart` now parses `precipMM` from wttr.in. Task detail and add-task flows are not built; default events are still generated imperatively in the service. |
| Offline caching and sync queue | Planning Sec 4 (Phase 2), Weather Plan Sec 5 | **[x] Implemented** | `lib/features/scan/domain/scan_queue.dart` (enqueue → upload → analyze → complete with 3-attempt exponential backoff, manual retry, delete; unit-tested S6) is wired into the capture flow via `ScanQueueProvider` + `SharedPreferencesScanQueueStore`. Farm data is cached: `ServiceDataCacheStore` persists crops/calendar/advisories/scans and `SmartCropsService.initializeUserData` falls back to the snapshot on a failed refresh (unit-tested), so screens show last-known data offline instead of an error. Weather is cached separately (`WeatherCacheStore`). |
| Localized language support (EN/TL/CEB) | Planning Sec 4 (Phase 2), Blueprint Sec 9 | **[x] Implemented** | `gen-l10n` output (`lib/l10n/app_{en,tl,ceb}.arb` + generated `app_localizations*.dart`) is wired into `MaterialApp.router` with `SharedPreferences` persistence and device-locale fallback (`lib/app/localization/language_preference.dart`). Language is switchable from Profile; all routed screens, including auth, use ARB strings. |
| Design system and tokens | Blueprint Sec 3, ADR 0005 | **[x] Implemented** | `lib/app/theme/` implements `AppTheme.light()`; tokens parity and WCAG AA contrast are unit-tested. All routed screens consume tokens and ARB strings. Fraunces + Public Sans are bundled under `assets/fonts/` with OFL licenses. |
| Responsive / adaptive layouts | Blueprint Sec 6, ADR 0004 | **[~] Partial** | The navigation shell adapts (bottom bar → `NavigationRail` at ≥840px). Individual screens are still phone-only; master-detail and breakpoint adaptation is pending. |
| Deep links (advisory → record) | Blueprint Sec 4.4-4.5, ADR 0003 | **[~] Partial** | `lib/app/router/advisory_link_resolver.dart` maps advisory targets (scan, task, crop, advisory, cooperative) to destinations; missing `recordId` falls back to `/advisories` (unit-tested S9). Push delivery is not implemented. |
| Marketplace / Agri Shop | Planning Sec 4 (Phase 3), 8 | **[B] Backend only** | `merchant_products` table and seed data exist in `20260313000000_marketplace_monetization.sql`. Product matching is test-only in `test/marketplace_test.dart`. No UI or service. |
| Agri Pro subscription and quota | Planning Sec 4 (Phase 3), 8 | **[B] Backend only** | `user_subscriptions` table exists. Quota policy is implemented in production code at `lib/features/scan/domain/scan_quota.dart` (5 free scans/week, Monday reset, queued scans reserve a slot) and unit-tested; no paywall UI or subscription management. |
| Cooperative / enterprise dashboard | Planning Sec 4 (Phase 3), 8 | **[B] Backend only** | `cooperative_admins`, `cooperative_members`, and `broadcast_advisories` tables exist in `20260314000000_cooperative_enterprise.sql`. Outbreak and broadcast logic is test-only in `cooperative_test.dart`. No UI or service. |
| Scan quota policy | Blueprint Sec 5.17 | **[x] Implemented** | `lib/features/scan/domain/scan_quota.dart` — pure `evaluateScanQuota`: 5 free scans/week resetting Monday 00:00 local, queued scan reservation, Agri Pro unlimited; unit-tested. Not yet enforced at the scan flow or backed by a paywall. |
| Sync queue / offline scan | Blueprint Sec 8, ADR 0007 | **[~] Partial** | `lib/features/scan/domain/scan_queue.dart` — enqueue, concurrent-safe processing, exponential backoff (30s/2m/10m), manual retry, explicit delete; unit-tested. Not yet wired into the capture flow. |
| Analytics and measurement | Blueprint Sec 10, ADR 0009 | **[ ] Not implemented** | Event taxonomy defined; no production instrumentation. |
| Accessibility (WCAG 2.2 AA) | Blueprint Sec 7 | **[~] Partial** | Automated coverage at the confirmed widget seams (Home, Scan Result): 200% text-scale overflow test (`test/app/accessibility_text_scale_test.dart`), Android/iOS tap-target and labeled-tap-target guideline checks (`test/app/accessibility_guidelines_test.dart`). Not yet a manual TalkBack/VoiceOver pass or a full-semantics audit of every screen. |

---

## 3. Phase 1 progress notes

The following Phase 1 items are now user-accessible or implemented in production code:

- **Navigation shell** replaces the old two-tab `MainNavigationScreen` (deleted); `/home`, `/crops`, `/scan`, `/calendar`, `/profile`, `/advisories`, `/care-plan`, `/health-log`, `/onboarding`, `/setup/profile`, and `/auth` are routed.
- **Onboarding** (3 skippable pages) and **profile setup wizard** (About You → Main Crops → Permissions) are implemented and routed.
- **Home Field Briefing** computes the priority action from live service data (critical weather, overdue tasks, recent at-risk diagnoses, routine care) using the tested domain logic in `lib/features/home/domain/field_briefing.dart`. The Care Plan and Recent Diagnoses previews render real service data (no hardcoded seeds), the advisory banner only appears for a real unread notification, and pull-to-refresh reloads data.
- **Scan capture → review → result** is implemented with a designed capture viewfinder, local image preview, Supabase Storage upload to the `scan-images` bucket (when authenticated, with RLS), an offline queue (`ScanQueueProvider` + `SharedPreferencesScanQueueStore`) that enqueues on network failure or missing connectivity and retries on restore, and a diagnosis presenter (`lib/features/scan/domain/diagnosis_presenter.dart`) that drives severity, confidence, and treatment steps.
- **Advisories** is a real inbox at `/advisories` listing `notifications`, with unread badge and mark-all-read. **Crops**, **Field Calendar**, **Health Log**, **Care Plan**, and **Profile** are all wired to real service data: weather-adjusted tasks (live `precipMM` from wttr.in), season summary with diagnosis severity, care items from pending calendar tasks, editable profile, persisted language switching via `LocaleProvider`.
- **Route guards** enforce auth, onboarding, profile completion, and cooperative role access; **deep links** (`smartcrops://…`) open the matching record via `lib/app/deep_link_handler.dart`; the authentication session is checked client-side only.
- **Localization** (EN/TL/CEB) is wired into the app shell via `gen-l10n` output and `AppLocalizations`; Profile switches locale app-wide; auth uses ARB strings.
- **Fonts** (Fraunces display, Public Sans body) are bundled under `assets/fonts/` with OFL licenses.
- **Offline**: weather is persisted to SharedPreferences (`WeatherCacheStore`) with a last-updated time shown on Home; scan images persist via the offline queue. The Home weather panel reflects the cached value when the network is down.
- **Cached surfaces:** farm data (crops, calendar, advisories, scan history) is persisted via `ServiceDataCacheStore` (`lib/services/service_data_cache_store.dart`, JSON snapshot of `FarmSnapshot`). `SmartCropsService.initializeUserData` (`lib/services/smart_crops_service.dart`) falls back to the cached snapshot on a failed refresh and exposes `lastUpdated`; a successful refresh overwrites the cache. Unit-tested at the service seam (`test/services/smart_crops_service_cache_test.dart`).
- **Crop detail** (`/crops/:cropId`, `lib/features/crops/screens/crop_detail_screen.dart`) opens from a Crops card tap and shows the crop name, honest catalog growing conditions (with `Not available` when absent), the latest two scans for that crop, and upcoming tasks for that crop with an `Open calendar` link; `Scan this crop` is the primary action. Widget-tested (`test/features/crops/crop_detail_screen_test.dart`).
- All legacy screens in `lib/screens/` were migrated to `lib/features/` and deleted; no hardcoded-UI screens remain.
- **Global states:** every routed data screen shows a shared `LoadingState` while the service initializes and an `ErrorState` with retry on failure (`SmartCropsService.errorMessage`, `lib/app/widgets/feedback_states.dart`). Cold start now preloads `initializeUserData` before the first frame.

Still not done: realtime notifications, universal links (HTTPS), analytics, a manual TalkBack/VoiceOver pass and full-semantics audit (automated tap-target/label checks and the 200% text-scale test now pass at the confirmed seams), adaptive/master-detail layouts beyond the navigation shell, and validating the blueprint against the implementation.

Test coverage added for build-order item 14: router (`test/app/router/app_router_test.dart`), localization (`test/l10n/*`, `test/localization_test.dart`), widget seams (Home Field Briefing in `test/features/home/home_screen_test.dart`, Scan Result low-confidence in `test/features/scan/scan_result_screen_test.dart`), accessibility guidelines, and golden snapshots at the two confirmed widget seams (`test/app/golden_test.dart`, baselines under `test/app/goldens/`). Golden tests load the bundled Fraunces/Public Sans fonts and the SDK Material Icons font so renders are faithful; regenerate with `flutter test --update-goldens`.

These gaps are planned in `UI_UX_BLUEPRINT.md`: Phase 1 (global states, cached surfaces), Phase 2 (Agri Pro, Agri Shop, push, analytics, adaptive polish), Phase 3 (Cooperative Hub).

---

## 4. Maintenance and update guidelines

1. **Status reflects the farmer's experience.** Do not mark a feature `[x]` because a table, function, or test exists.
2. **Cite evidence.** Link the screen, service, migration, or test that proves the status.
3. **Update with the blueprint.** If a feature's UX changes, update `UI_UX_BLUEPRINT.md` and the relevant ADR in the same change.
4. **Keep the legend honest.** Use `[B]` and `[T]` for backend-only and test-only work instead of stretching `[~]`.
5. **Reference this document in pull requests** when a roadmap item moves between statuses.
