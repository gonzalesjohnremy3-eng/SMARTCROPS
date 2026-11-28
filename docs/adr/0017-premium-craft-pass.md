# Premium craft pass within Field Almanac

- **Status:** Accepted
- **Date:** 2026-11-28

## Context

The screens work but read as stock Material: centred cards, outlined fields, uniform spacing. Smart Crops needs to feel trustworthy and premium to Farmers, and each screen should make its job obvious.

## Decision

Redesign every screen, one per pull request (auth, onboarding, home, scan, crops and calendar, then the rest), inside the Field Almanac identity of ADR 0010: same palette, Fraunces and Public Sans, the Smart Crops logo. Premium comes from craft, guided by the impeccable and high-end-visual-design skills where they agree with this project:

- One job per screen, stated in the Farmer's words; one primary action; secondary actions visibly quieter. No explanatory banners or eyebrow labels.
- Editorial composition: real field photography under a dark scrim, generous whitespace, a clear type scale.
- Depth from soft offset shadows and nested surfaces, never glass or blur (contract-tested).
- Motion from `AppMotion` curves, one authored moment per screen, instant under reduced motion.
- New values become tokens first (ADR 0005).

## Consequences

- Each redesigned screen ships with its spec (ADR 0016) and updated widget tests.
- Copy changes are localized in EN, TL and CEB in the same pull request; TL and CEB drafts are flagged for native review.

## Considered alternatives

- **New visual identity:** breaks ADR 0001/0010, token parity and approved copy for little Farmer value.
