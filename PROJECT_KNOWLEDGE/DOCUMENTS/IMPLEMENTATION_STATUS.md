# Smart Crops (Agri Lynk) - Implementation Status & Feature Tracking Guide

This document tracks the user-accessible reality of every feature against `PROJECT_PLANNING.md`, `WEATHER_FEATURE_PLAN.md`, the PDF design specification, and `UI_UX_BLUEPRINT.md`.

**Audit date:** 2026-11-12 (UI/UX Phase 0)  
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
| Agri Lynk branding | Planning Sec 1, PDF Pages 1-3 | **[~] Partial** | Brand strings and headers exist; no splash screen, onboarding, or consistent tokenized identity. |
| Onboarding (3 pages) | Blueprint Sec 5.2 | **[ ] Not implemented** | No onboarding screens or first-run routing. |
| Email and password authentication | Planning Sec 3-4, PDF Page 4 | **[x] Implemented** | `lib/screens/auth_screen.dart`, `SmartCropsService.signInWithEmail`, `signUpWithEmail`. |
| Google OAuth | Planning Sec 3-4, PDF Page 4 | **[x] Implemented** | `signInWithOAuth(OAuthProvider.google)`; platform configuration should be re-verified before release. |
| Facebook OAuth | Planning Sec 3-4, PDF Page 4 | **[x] Implemented** | `signInWithOAuth(OAuthProvider.facebook)`; platform configuration should be re-verified before release. |
| Phone number and SMS OTP | Planning Sec 3-4, PDF Page 4 | **[~] Partial** | OTP UI and service methods exist; success depends on a configured SMS provider. Phone-only users are supported by the latest migration. |
| Profile setup and multiple crop selection | Planning Sec 4, 7 (Page 5) | **[x] Implemented** | `profile_setup_screen.dart`, `user_crops` relation, multi-select crop list. |
| Dashboard Home | Planning Sec 7 (Page 6) | **[~] Partial** | `dashboard_screen.dart` exists with a banner, weather, and a 5-card grid; not the Field Briefing hierarchy. |
| Weather and location widget | Weather Plan Sec 2-5 | **[x] Implemented** | `weather_service.dart` with `wttr.in`; dashboard loading, error, and refresh states. Offline caching is not integrated. |
| Notification bell and alerts modal | Planning Sec 6-7, PDF Page 6 | **[~] Partial** | Badge and bottom sheet exist; no realtime subscription, no unified Advisories inbox, no deep links. |
| Scan Crop capture UI | Planning Sec 5, 7 (Page 7) | **[~] Partial** | `scan_crop_screen.dart` captures or picks an image, but `performAiScan` sends a placeholder Unsplash URL instead of the captured image. No upload to Storage. |
| AI analysis and multi-key rotation | Planning Sec 3, 5 | **[x] Implemented** | `supabase/functions/scan-crop` plus `ai_keys_pool`; rotation logic unit-tested in `test/ai_key_rotation_test.dart`. Client invocation has a mock fallback. |
| My Crops management | Planning Sec 7, PDF Page 6 | **[~] Partial** | `my_crops_screen.dart` lists selected crops and optimal conditions; no crop photos, growth stages, or care guides. |
| Recommendations engine | Planning Sec 4, 7 | **[~] Partial** | `recommendations_screen.dart` shows a fixed list; not personalized by crop, scan history, or weather. |
| Scan History | Planning Sec 6-7 | **[x] Implemented** | `history_screen.dart` lists past scans with diagnosis, confidence, time, and actions; no filtering or search. |
| Farmer profile and settings | Planning Sec 4 | **[~] Partial** | `profile_screen.dart` handles profile edits, crop management, language selector, and sign out; no notification preferences, privacy, plan, or cooperative management. |
| Main navigation | Blueprint Sec 4 | **[~] Partial** | `main_navigation_screen.dart` has only Home and Profile. No router, guards, preserved branches, or deep links. |
| Supabase schema and RLS (core) | Planning Sec 6 | **[x] Implemented** | Core tables and policies exist in `supabase/migrations/20260311000000_smart_crops_schema.sql`. |
| Push notifications (FCM / Realtime) | Planning Sec 4 (Phase 2) | **[ ] Not implemented** | Notifications are fetched on `initializeUserData`; there is no Realtime channel, FCM integration, or push deep-link handling. |
| Personalized Crop Calendar | Core differentiation strategy | **[~] Partial** | `personalized_crop_calendar_screen.dart`, `crop_calendar_events` table, default event generation, and completion toggle exist. Weather adjustment exists only in `test/crop_calendar_test.dart`, not in production. |
| Offline caching and sync queue | Planning Sec 4 (Phase 2), Weather Plan Sec 5 | **[~] Partial** | `offline_cache_service.dart` exists but is not imported or integrated. `test/sync_queue_test.dart` covers queue logic, not app wiring. |
| Localized language support (EN/TL/CEB) | Planning Sec 4 (Phase 2) | **[~] Partial** | `localization_service.dart` and tests exist; the service is provided but `MaterialApp` has no locale delegates and UI strings are hardcoded. |
| Marketplace / Agri Shop | Planning Sec 4 (Phase 3), 8 | **[B] Backend only** | `merchant_products` table and seed data exist in `20260313000000_marketplace_monetization.sql`. Product matching is test-only in `test/marketplace_test.dart`. No UI or service. |
| Agri Pro subscription and quota | Planning Sec 4 (Phase 3), 8 | **[B] Backend only** | `user_subscriptions` table exists. Quota policy is test-only in `marketplace_test.dart`. No paywall, quota meter, or subscription management. |
| Cooperative / enterprise dashboard | Planning Sec 4 (Phase 3), 8 | **[B] Backend only** | `cooperative_admins`, `cooperative_members`, and `broadcast_advisories` tables exist in `20260314000000_cooperative_enterprise.sql`. Outbreak and broadcast logic is test-only in `cooperative_test.dart`. No UI or service. |
| Design system and tokens | Blueprint Sec 3 | **[ ] Not implemented** | Colors, spacing, radii, and typography are hardcoded across screens. Phase 0 defines the tokens; Phase 1 implements them. |
| Responsive / adaptive layouts | Blueprint Sec 6 | **[ ] Not implemented** | Phone-only layouts despite web and desktop targets. |
| Deep links | Blueprint Sec 4.4 | **[ ] Not implemented** | `app_links` is a dependency only; no routing, intent filters, associated domains, or resolution logic. |
| Analytics and measurement | Blueprint Sec 10 | **[ ] Not implemented** | No event instrumentation or privacy-safe taxonomy in production. |
| Accessibility (WCAG 2.2 AA) | Blueprint Sec 7 | **[ ] Not implemented** | No formal audit, semantics pass, contrast verification, dynamic-type test, or screen-reader validation. |

---

## 3. Corrected claims from the previous version

The previous version of this document marked the following as implemented. They are not user-accessible yet:

- **Push notifications / Realtime:** no channel subscription or FCM integration exists.
- **Marketplace and Agri Pro:** schema exists; matching and quota logic live only in tests.
- **Cooperative dashboard:** schema exists; outbreak and broadcast logic live only in tests.
- **Offline caching:** the service exists but is not integrated.
- **Localization:** the service exists but is not applied to the app.
- **Personalized weather adjustment:** the helper exists only in a test.
- **Scan image pipeline:** the app analyzes a placeholder URL, not the captured image.

These gaps are planned in `UI_UX_BLUEPRINT.md`: Phase 1 (core loop, design system, navigation, localization, offline), Phase 2 (Agri Pro, Agri Shop, push, analytics, adaptive polish), Phase 3 (Cooperative Hub).

---

## 4. Maintenance and update guidelines

1. **Status reflects the farmer's experience.** Do not mark a feature `[x]` because a table, function, or test exists.
2. **Cite evidence.** Link the screen, service, migration, or test that proves the status.
3. **Update with the blueprint.** If a feature's UX changes, update `UI_UX_BLUEPRINT.md` and the relevant ADR in the same change.
4. **Keep the legend honest.** Use `[B]` and `[T]` for backend-only and test-only work instead of stretching `[~]`.
5. **Reference this document in pull requests** when a roadmap item moves between statuses.
