# Replace HTML prototypes with per-screen specs

- **Status:** Accepted
- **Date:** 2026-11-28

## Context

`design/prototypes/` held 14 HTML pages with three variants each, a shared token stylesheet and an implementation map. Once verdicts were folded into Flutter, every visual change had to be made twice (HTML and Dart) and the prototypes drifted from the shipped screens. The premium redesign (ADR 0017) would multiply that cost.

## Decision

Delete `design/prototypes/`. Flutter is the only visual source of truth. Each screen gets a short spec in `design/screens/NN-name.md` stating its purpose, primary action, states and design decisions, and naming the Flutter file it describes. Specs are written as each screen is redesigned, starting with `03-auth.md`. `test/design/screen_spec_contract_test.dart` checks that every spec names an existing Flutter file and states its purpose, and that the prototypes do not return.

## Consequences

- `design/prototypes/IMPLEMENTATION_MAP.md` and `prototype_verdict_coverage_test.dart` are retired; history stays in `IMPLEMENTATION_STATUS.md` §9.
- `design/tokens.json` remains the token source, mirrored only in `lib/app/theme/app_tokens.dart`.
- Design review happens on the running app (web preview or device), not on HTML.

## Considered alternatives

- **Keep prototypes as an unmaintained archive:** misleading once screens change.
- **Design straight in Flutter with no specs:** loses the written statement of each screen's purpose.
