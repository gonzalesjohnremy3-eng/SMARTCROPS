# Launch with English, Tagalog, and Cebuano

- **Status:** Accepted
- **Date:** 2026-11-12

## Context

The app currently hardcodes English strings. The localization service exists but is not applied to `MaterialApp`. The target audience includes farmers who prefer Tagalog or Cebuano, and local language builds trust and comprehension.

## Decision

Launch with English, Tagalog, and Cebuano:

- All user-facing strings live in ARB files.
- English is the fallback.
- Language is selectable in onboarding and Profile and applies immediately.
- Dates, numbers, and currency are locale-aware.
- Translations are human-reviewed by native speakers; no unreviewed machine translation.
- The architecture supports adding Ilocano, Hiligaynon, and Bicolano later.

## Why

Local language is a trust feature, not a nice-to-have. It improves comprehension of diagnosis and treatment steps. Starting with three languages keeps review and QA feasible while covering the initial audience.

## Consequences

- Every screen must be externalized before release.
- Translation review and screenshot QA are ongoing costs.
- Layouts must survive longer strings and 200% text scale.
- Technical terms need plain-language explanations in each language.

## Considered alternatives

- **English-only:** faster, weaker local trust.
- **Five languages at launch:** broader reach, more copy and QA risk.
