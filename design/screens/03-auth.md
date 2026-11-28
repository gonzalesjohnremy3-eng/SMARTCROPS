# 03 · Auth

**Flutter:** `lib/features/auth/screens/auth_screen.dart`

**Purpose:** Get a Farmer into Smart Crops with the number already in their pocket, and show at a glance what the app does for their crops.

**Primary action:** Continue with a Philippine mobile number, then enter the 6-digit SMS code.

## Layout

- **Phone (compact):** the top ~40% is a field photograph under a dark scrim carrying the logo, the wordmark with "by Agri Lynk", and the promise "Know what your crops need." framed by scan-reticle corners (the same motif as the logo and the scan screen). A paper sheet with rounded top corners overlaps the photo and holds the current step.
- **Wide (≥ expanded breakpoint):** two columns. Left: full-height photo panel with the promise and the trust copy ("Welcome to your field office." / "Your farm data stays private."). Right: the form on paper, no card.

## Steps

1. **Phone:** a single field, no visible country prefix, placeholder `0917 123 4567`, digits grouped as typed. Accepts `09XXXXXXXXX`, `9XXXXXXXXX`, `639XXXXXXXXX`, `+639XXXXXXXXX`; `normalizePhilippineMobile` turns them into `+639XXXXXXXXX` before Supabase. Title "Sign in or create your account"; button "Continue".
2. **Code:** six digit boxes, paste fills all six, backspace steps back, one-time-code autofill, auto-submit on the sixth digit. "Sent to 0917 ••• 4567" with "Change number". Resend unlocks after a 60-second countdown. Slides in from the right using `AppMotion.standard`; instant under reduced motion.

Email (with its own sign-in/sign-up toggle), Google and Facebook sit below in a quieter "Other ways to sign in" group.

## States

idle · sending · invalid number · code sent · verifying · wrong code · expired code · too many attempts (with wait time) · no connection · generic failure. Errors appear inline beside the field or code boxes in plain words, never raw Supabase text.

## Notes

- Phone OTP runs against Supabase test numbers today. The UI never says "test" or "demo". A real SMS provider is required before launch.
- No password recovery exists, so none is offered.
