# Centralize design tokens and typography

- **Status:** Accepted
- **Date:** 2026-11-12

## Context

Colors, spacing, radii, and typography are hardcoded across screens. The palette has drifted, contrast is unverified, and the app uses Roboto by default with no type hierarchy. This makes consistency and accessibility impossible to maintain.

## Decision

Create a token layer in `lib/app/theme/` covering color, typography, spacing, radii, elevation, motion, and layout. Source values live in `design/tokens.json`; Dart files mirror them.

Typography:

- Fraunces for display and screen-title moments.
- Public Sans for UI and body.
- Sentence case, tabular numerals for data, no all-caps labels.

Feature code may not use raw hex values, font sizes, or arbitrary spacing. Add a token before adding a value.

## Why

Tokens make the Field Almanac direction enforceable, support contrast and text-scale audits, and allow a future theme change without touching every screen. Bundled OFL fonts avoid runtime font fetching and improve offline reliability.

## Consequences

- A small upfront migration cost for existing screens.
- Font assets increase app size; subsetting is required.
- Designers and engineers share one source of truth.
- Adding a value requires a token decision, which prevents drift.

## Considered alternatives

- **ThemeData with inline values:** simple but unenforceable.
- **Google Fonts at runtime:** convenient but fails offline and adds latency.
