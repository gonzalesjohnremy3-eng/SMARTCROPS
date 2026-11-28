# 02 · Onboarding

**Flutter:** `lib/features/onboarding/screens/onboarding_screen.dart`

**Purpose:** In three swipes, show a first-time Farmer the three things Smart Crops does for their crops, in the language they choose, then hand them to sign-in.

**Primary action:** Next, ending in Get started (to `/auth`). Skip and the language choice stay available on every page.

## Layout

Each page is a full-bleed field photograph on top with a paper sheet that rises over its lower edge, the same composition as Auth, so the first-run flow reads as one piece:

1. **Protect your harvest:** a healthy pechay photo. The Smart Crops logo, wordmark and "by Agri Lynk" sit large on the photo, so this page doubles as the brand introduction.
2. **Scan and know:** a rice leaf with blast lesions, framed by the scan reticle with a scan line sweeping through it. This is the screen's one authored motion, and it is off under reduced motion.
3. **Plan with the weather:** misty rice paddies under rain clouds, with an example calendar card on the photo ("Rain tomorrow" / "Spraying moved to Thursday") showing how the Field Calendar adapts.

The top bar over the photo holds the language pill (globe, current language) and Skip, in light text on a top scrim. The bottom bar holds a three-segment progress indicator (announced as "Step N of 3"), an icon Back button from page 2 on, and the primary pill button with its arrow nested in a circle.

## States

first page · middle page · last page (Get started) · language sheet open · 200% text in EN, TL and CEB without overflow · reduced motion.

## Notes

- No eyebrow label above the titles; the title carries the page.
- Titles in sentence case (ADR 0005).
- The example calendar card is illustrative UI, not a claim about the Farmer's data.
