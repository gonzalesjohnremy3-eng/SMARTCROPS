# P4 · Profile Setup — prototype brief

**Question:** Does a wizard, one form, or one-question-at-a-time get a farmer set up without feeling like paperwork?

**Product job served:** Personalization — it makes the Field Briefing and diagnosis relevant.

**Data flow / business logic:** `ProfileSetupScreen` (`lib/features/profile/screens/profile_setup_screen.dart:22`) is a 3-step wizard (About You → Main Crops → Permissions). It saves profile + selected crops through `SmartCropsService.updateProfile` / `saveUserCrops` then sets `profileComplete` in `OnboardingController`. Router redirect then opens `/home`.

**Reliability / accuracy / security gate:**
- `saveUserCrops` is a non-atomic delete-then-insert loop (`smart_crops_service.dart:265`); a failure can leave zero crops. Fix or guard before launch.
- Permission priming must not pre-check consent; camera permission is requested by the farmer.
- Location is coarse by design — never collect precise coordinates for analytics.

**States:** step 1/2/3, validation error, save failure, permission denied (continue allowed), reduced motion.

**Design skills applied:** design-mobile-apps, impeccable, ui-taste, flutter-motion (step transition).

**Verdict:** A (Wizard steps) retained — matches the shipped 3-step flow and keeps permissions as an explicit final step. B's single form is offered as the "already set up" edit surface in P14. C's question style is reserved for guided recovery later. Overlay: none.

