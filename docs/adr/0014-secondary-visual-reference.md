# Keep the CropCare reference as secondary visual guidance, not an adopted design

- **Status:** Accepted
- **Date:** 2026-11-22

The supplied `PROJECT_KNOWLEDGE/DOCUMENTS/REFERENCE.md` and `PROJECT_KNOWLEDGE/IMAGES/REFERENCE/HOME_REFERENCE.png` describe a different product design (CropCare): an amber primary action, Roboto/Inter typography, a four-destination navigation, and a fixed home composition. Those choices conflict with the locked Field Almanac identity (ADR 0010), the optimized glass language (ADR 0013), and the five-destination navigation (ADR 0002), so they are not adopted into the current design line.

We record the reference as secondary guidance for colour temperature, 4dp spacing, quiet edge botanical decoration, a dark scrim over real crop photography, status paired with label and icon, accessibility targets, and selective-glass discipline. Its brand mark, amber accent, type stack and information architecture remain out of scope. A future isolated branch may explore a CropCare-derived design for side-by-side comparison, but it must not change this branch's tokens, copy, navigation or ADRs without a new accepted decision.

## Consequences

- The current branch stays Field Almanac + optimized glass (ADR 0013); no amber CTA, Roboto/Inter, or four-tab nav is introduced.
- The reference files stay under `PROJECT_KNOWLEDGE/` as source material, not as executable design tokens.
- Any CropCare-derived implementation lives on a separate branch and is compared with this design line rather than merged into it by default.
