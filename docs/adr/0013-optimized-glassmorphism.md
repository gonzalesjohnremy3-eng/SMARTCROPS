# Adopt Optimized Glassmorphism as a visual-layer re-skin

- **Status:** Superseded (2026-11-26) — the glass layer was fully reverted; Field Almanac under ADR 0010 is the only design
- **Date:** 2026-11-22
- **Supersedes:** 0010 (evolve Field Almanac unchanged)

## Context

ADR 0010 locked the craft upgrade to an unchanged Field Almanac token set. The product now asks for an optimized premium glassmorphism language. Glassmorphism reverses ADR 0001's "hairline borders over diffuse shadows" and requires new translucency, blur and border values, so it cannot be a silent token edit.

## Decision

Adopt an **optimized glass** visual language as a visual-layer re-skin:

- Keep the information architecture, brand mark, Forest/Rain palette, Fraunces + Public Sans, approved copy, localization and all other ADRs.
- Add a `glass` token family (tint, sigma, border, shadow, scrim, text-safe opacity) to `design/tokens.json` and mirror it in Dart.
- Apply glass selectively: immersive surfaces, navigation chrome, sheets and dialogs. Dense list, calendar and form surfaces stay opaque.
- Contrast wins over translucency: text-bearing glass uses an opaque-enough backing (4.5:1 text, 3:1 boundaries) with an automatic opaque fallback.
- Performance budget: at most one live `BackdropFilter` per screen, never animated; static blur/noise elsewhere. No hardware-type checks (ADR 0004).
- Dark mode stays deferred; generated imagery stays optional with a gradient+noise fallback.

## Why

It delivers the requested premium feel without breaking the approved identity, offline fonts, field-first legibility in sunlight, or the 2 GB / 720p baseline.

## Consequences

- ADR 0001's elevation rule is amended for glass surfaces.
- `tokens_test.dart` gains parity, worst-case contrast and one-blur assertions; goldens are regenerated.
- No Supabase, business-logic or security-gate changes; those are re-verified, not rewritten.
- The 14 page prototypes are re-skinned and re-judged before Flutter fold-in.

## Considered alternatives

- **Glass everywhere:** fails contrast and frame budget on dense/task surfaces.
- **Full rebrand (new palette/fonts):** breaks offline font bundling, copy approval and localization density for no functional gain.
