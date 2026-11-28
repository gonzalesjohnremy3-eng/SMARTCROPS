# Product

<!-- impeccable:product-schema 1 -->

## Platform

android

Flutter app, phone-first (ADR 0004), shipped to Android first; iOS, web and desktop builds exist from the same code. The Field Almanac brand, not stock Material, sets the visual language on every platform.

## Users

Filipino **Farmers** (see `GLOSSARY.md`) managing small farms of rice, corn, vegetables and fruit trees. They use the app outdoors, often in bright sun, on mid-range Android phones with patchy mobile data, in English, Tagalog or Cebuano.

## Product Purpose

Smart Crops by Agri Lynk helps a Farmer find out what is wrong with a crop and what to do next: scan a leaf, get a diagnosis, then follow a care plan and calendar tuned to their Main Crops, Location and Season. Success is a Farmer acting on correct guidance before a problem spreads.

## Positioning

AI diagnosis tied to a local care calendar, regional advisories and the Agri Lynk cooperative network, in the Farmer's own language, working offline-first.

## Operating Context

- Sign in with a Philippine mobile number and a 6-digit SMS code (phone first); email, Google and Facebook remain secondary.
- Scans can be queued offline and uploaded later (ADR 0007); free Farmers have a weekly scan quota, Pro removes it.
- Field Briefing on Home combines weather, one priority action and a scan prompt.

## Capabilities and Constraints

- Backend is Supabase (auth, database, realtime, edge functions).
- Phone OTP currently runs against Supabase test phone numbers; no SMS provider is configured. Real SMS (for example Twilio) is required before public launch. The UI must still read as production: no "test" or "demo" wording.
- Every user-facing string is localized in EN, TL and CEB (ADR 0008).
- Design tokens are fixed by `design/tokens.json` (ADR 0005, 0010); glassmorphism is banned (contract-tested).

## Brand Commitments

- Name: "Smart Crops" with byline "by Agri Lynk".
- Logo: `assets/images/brand/smartcrops_logo.png` (green rounded square: seedling, scan frame and pest).
- Field Almanac identity: Fraunces for display, Public Sans for UI, palette forest ink, canopy, leaf, mist, paper, palay, clay, rain.
- Vocabulary from `GLOSSARY.md` (Farmer, Main Crop, Field Briefing).

## Evidence on Hand

Photographic overlays in `assets/images/overlays/` (home, onboarding, scan, crop detail, product, pro). No testimonials, user counts or partner logos exist; do not invent them.

## Product Principles

1. Each screen has one job, stated in the Farmer's words and made obvious by hierarchy.
2. Trust before cleverness: never overclaim accuracy, privacy or features that do not exist.
3. Works in the field: large targets, high contrast in sunlight, tolerant of slow or missing data.
4. The Farmer's language first, never an afterthought.

## Accessibility & Inclusion

Minimum 48dp touch targets, WCAG AA contrast, text scaling to 200% without loss, reduced-motion respected, all three languages at full length.
