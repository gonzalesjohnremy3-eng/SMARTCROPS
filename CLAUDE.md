# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Smart Crops by Agri Lynk: a Flutter app (Android/iOS/web/desktop targets) giving Filipino farmers AI-assisted crop diagnosis, care calendar and farm guidance. Backend is Supabase (auth, DB, realtime, edge functions). The README is the stock Flutter template; the real context lives in `GLOSSARY.md`, `docs/adr/`, and `PROJECT_KNOWLEDGE/DOCUMENTS/`.

## Commands

```bash
flutter pub get
flutter run                      # needs a .env file at repo root (loaded in main.dart; SUPABASE_URL, SUPABASE_ANON_KEY)
flutter analyze                  # flutter_lints
flutter test                     # whole suite
flutter test test/auth_service_test.dart            # one file
flutter test --plain-name "some test name"          # one test
flutter gen-l10n                 # regenerate lib/l10n/app_localizations*.dart after editing ARB files (pubspec has generate: true)
```

Supabase edge function `scan-crop` is Deno/TypeScript with tests next to it (`supabase/functions/scan-crop/*_test.ts`); run with `deno test` from that directory. The `supabase` CLI is an npm devDependency (`npx supabase ...`). Migrations are in `supabase/migrations/`.

## Architecture

- **Entry/wiring:** `lib/main.dart` initializes dotenv, Supabase, language preference, weather and `SmartCropsService`, the Pro entitlement, onboarding flags (SharedPreferences `onboarding_complete` / `profile_complete`) and analytics, then injects them all into `SmartCropsApp` via Provider. State management is Provider plus a service layer (ADR 0003); don't introduce another.
- **`lib/app/`:** cross-cutting infrastructure: `router/`, `theme/` (design tokens), `localization/`, `analytics/` (event taxonomy, ADR 0009; remote sink gated by `kRemoteAnalyticsEnabled` in `build_config.dart`), `push/`, `deep_link_handler.dart`, shared `widgets/`.
- **Routing:** `go_router` with `StatefulShellRoute.indexedStack` for the five destinations (ADR 0002/0003). Redirects are driven by a pure guard in `router/route_guard.dart` (`RouteContext` → `RouteReason`: onboarding → auth → profile setup → requested location; role-based access for cooperative roles). Deep-link intent must survive auth/profile setup; unmatchable locations redirect to the hub. Scan is a full-screen route above the shell. Never push ad-hoc `MaterialPageRoute`s.
- **`lib/features/<name>/`:** feature-first modules (advisories, auth, calendar, care_plan, crops, health_log, home, onboarding, pro, profile, scan, shop), each typically split into `domain/`, `data/`, `services/`, `screens/`. Scan includes an offline queue (ADR 0007) and weekly quota; Pro entitlement/billing lives in `features/pro`.
- **`lib/services/` + `lib/models/`:** `SmartCropsService` is the central Supabase-backed data service (`farm_data_loader`, `farm_snapshot`, and a cache store support offline); `weather_service.dart` caches weather.
- **Scan pipeline:** the app calls the `scan-crop` edge function, which authorizes the request (`auth.ts`), rotates a pool of AI provider keys (`pool_runner.ts`) across Gemini/OpenAI (`gemini_runner.ts`, `ai_errors.ts`) and returns a normalized diagnosis JSON. `send-campaign` and `set-pro-tester` are the other functions.
- **Localization:** English, Tagalog, Cebuano (ADR 0008). All user-facing strings go in ARB files in `lib/l10n/` (`app_en.arb` is the template); the generated `app_localizations*.dart` files are checked in. Cebuano has a fallback localization delegate.

## Design system and docs (contract-tested)

- Brand is "Field Almanac" (ADR 0001/0010). **Glassmorphism was removed**: `test/design/glass_removed_contract_test.dart` fails if `AppGlass`, `GlassSurface`, `BackdropFilter`, `ImageFilter.blur`, or the word "glass" appear in Flutter source, design tokens or screen specs. ADR 0013 must stay marked Superseded. The CropCare line (`lib/cropcare`, `design/prototypes-cropcare`) was retired.
- `design/tokens.json` is the source of truth for tokens, mirrored in `lib/app/theme/app_tokens.dart`.
- The HTML prototypes were deleted (ADR 0016). Flutter is the only visual source of truth; each redesigned screen gets a spec in `design/screens/NN-name.md` (Flutter file, purpose, primary action, states), enforced by `test/design/screen_spec_contract_test.dart`. The premium redesign runs one screen per PR inside Field Almanac (ADR 0017); product context for design work is in `PRODUCT.md`.
- `test/docs/documentation_contract_test.dart` asserts exact strings in `PROJECT_KNOWLEDGE/DOCUMENTS/IMPLEMENTATION_STATUS.md` and `UI_UX_BLUEPRINT.md` (audit date, section headings, the "flutter test (N passing)" count). When you change the test count or those docs' headings, update the docs and this test together.
- Use the vocabulary in `GLOSSARY.md` (e.g. **Farmer** not "user", **Field Briefing**, **Main Crop**) in code, copy and docs.
