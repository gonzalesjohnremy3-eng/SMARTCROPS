# Evolve Field Almanac instead of rebranding

- **Status:** Accepted
- **Date:** 2026-11-21

## Context

The UI/UX craft-upgrade brief invited a fresh visual direction. The project already has an approved, token-tested identity (Field Almanac, nine ADRs, a blueprint, wireframes and a copy deck) that farmers, the brand, and the test suite depend on.

## Decision

Keep the Field Almanac tokens, palette, typography, brand mark, information architecture and nine accepted ADRs unchanged. Deliver the upgrade as greater craft: richer but token-compliant layouts, a shared component library, selective photographic overlays, purposeful motion, and rigorous state/a11y coverage.

## Why

It preserves the trust and localization work already shipped, avoids invalidating token-parity tests and approved copy, and directs effort into visible quality rather than churn.

## Consequences

- Feature code may never introduce raw colors, type sizes or spacing; add a token first.
- A future rebrand remains a visual-layer-only change, per ADR 0001.
- The blueprint retains authority when a screen and the document disagree.

## Considered alternatives

- **Replace the identity wholesale:** higher novelty, but breaks ADR 0001, the copy deck and token parity for little user value.
- **Keep screens as-is:** no improvement in the craft the brief asks for.
