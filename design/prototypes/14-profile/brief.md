# P14 · Profile / settings / language — prototype brief

**Question:** Which organization makes farm identity, language and account controls discoverable without becoming a settings maze?

**Product job served:** Secondary — supports localization and account control.

**Data flow / business logic:** `ProfileScreen` (`lib/features/profile/screens/profile_screen.dart:11`) holds profile editing, crops, Agri Pro/Shop links, language switcher (`_LanguageSection` at `:400`) and sign-out (`:464`). Language changes flow through `LocaleProvider` / `LanguagePreference` and apply immediately. EN/TL/CEB are the three shipped locales.

**Reliability / accuracy / security gate — P13 gate:**
- `ServiceDataCacheStore` uses one global key `farm_data_snapshot`; `signOut()` clears only in-memory lists. A second farmer whose refresh fails can see the first farmer's cached private data. **Fix: clear the cache on sign-out and scope the key by user id.**
- Raw Supabase errors are shown in auth; keep profile errors plain and actionable.
- Language copy is draft for TL/CEB until native review — do not present it as final.

**States:** populated, saving, save failure, language switching, sign-out confirmation, offline (show last updated).

**Design skills applied:** flutter-build-responsive-layout, design-mobile-apps, impeccable, ui-taste.

**Verdict:** A (Grouped sections) chosen for compact; C is the ≥840dp expression. B's identity header is folded in as the top of A. No generated overlay — profile is a utility surface. Motion: immediate locale switch via cross-fade, no full reload.

**Glass re-judgment (2026-11-22):** Unchanged — utility surface. B's identity header is merged into A without glass.
