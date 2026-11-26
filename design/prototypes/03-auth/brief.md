# P3 · Auth — prototype brief

**Question:** Which sign-in layout reduces abandonment without overclaiming privacy or inventing account recovery?

**Product job served:** Access — it precedes all three jobs.

**Data flow / business logic:** `AuthScreen` (`lib/features/auth/screens/auth_screen.dart:9`) signs in/up via `SmartCropsService` (`smart_crops_service.dart:156`) using Supabase email/password, Google/Facebook OAuth and phone OTP (`auth_screen.dart:72`). The `handle_new_user()` trigger creates the profile. Route guard then requires profile setup.

**Reliability / accuracy / security gate:**
- Raw Supabase error strings are shown to farmers (`auth_screen.dart:65,138`) — replace with plain, actionable copy.
- Weak validation (`contains('@')`, 6-char password, no phone format) — validate format client-side but never imply server acceptance.
- No password-reset flow exists — do not advertise "Forgot password?" until implemented. Variant C's link is a prototype-only placeholder to be removed in implementation.
- Session state is checked client-side only; no `onAuthStateChange` listener. Verify token expiry does not strand the farmer.
- Phone OTP depends on an external SMS provider that is not configured locally.

**States:** idle, submitting, invalid input, wrong credentials, network failure, OTP sent / invalid / expired, reduced motion.

**Design skills applied:** impeccable, design-mobile-apps, frontend-design, ui-taste.

**Verdict:** B (Phone first) chosen for the primary mobile path, with A's trust panel as the branded backdrop on wide screens. Remove the unimplemented recovery link in code. Overlay: generated immersive image on the trust panel only.

