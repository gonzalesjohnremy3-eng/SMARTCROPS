# Approve the CropCare design line for merge after parity gates

- **Status:** Superseded (2026-11-26) — the CropCare line was retired; `design/prototypes/` is the only design line
- **Date:** 2026-11-22
- **Extends:** 0014 (secondary visual reference)

ADR 0014 kept the CropCare reference on an isolated branch and required a new accepted decision before merging. The isolated `/cropcare/*` route set is now approved as an **additional** design surface, not a replacement for the Field Almanac + optimized glass line of ADR 0013.

Approval is conditional on these parity gates, all verified on the comparison branch:

- All CropCare user-facing strings are externalized to `app_en.arb`, `app_tl.arb`, and `app_ceb.arb` per ADR 0008; no hardcoded English remains in `lib/cropcare/`.
- Field Almanac routes, tokens, copy, and goldens remain unchanged.
- Each CropCare screen has exactly one live glass surface, with dense lists and diagnosis cards opaque.
- Full Flutter tests pass and analyzer reports no new errors.
- PR review is completed before merge.

This decision authorizes converting the draft comparison PR to a reviewable PR when the owner chooses; it does not merge the branch automatically.
