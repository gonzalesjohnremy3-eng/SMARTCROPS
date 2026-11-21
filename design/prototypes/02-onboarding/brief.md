# P2 · Onboarding — prototype brief

**Question:** Does a photographic story, a card stack, or a guided question best earn the first 30 seconds of trust?

**Product job served:** Frames the promise — diagnosis, next step, weather-aware plan.

**Data flow / business logic:** `OnboardingScreen` (`lib/features/onboarding/screens/onboarding_screen.dart:9`) is a 3-page `PageView`; completion writes a flag through `OnboardingController` into `SharedPreferences` (`main.dart:55`). Router redirect reads the same flag (`app_router.dart:176`). No network calls.

**Reliability / accuracy / security gate:**
- Completion flag must survive process restarts and be clearable for tests.
- Skip must land the farmer in Profile Setup with the same flag state as "finish".
- No personal data collected during onboarding; do not introduce analytics PII.

**States:** page 1/2/3, skip, finish, reduced-motion (no parallax).

**Design skills applied:** impeccable, design-mobile-apps, frontend-design, flutter-motion (horizontal page transition + reduced-motion cross-fade), ADR 0001 photography.

**Verdict:** A (Story spread) chosen — the overlay hero gives the Field Almanac identity its one memorable moment; copy comes verbatim from `UI_COPY_DECK.md`. B stays as a fallback for low-memory devices; C's guided question is reused in P4 rather than onboarding. Overlay: generated immersive image + Forest scrim.
