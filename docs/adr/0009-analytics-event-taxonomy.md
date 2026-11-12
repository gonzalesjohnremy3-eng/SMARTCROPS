# Standardize a privacy-safe analytics taxonomy

- **Status:** Accepted
- **Date:** 2026-11-12

## Context

The product needs to measure activation, habit, trust, and conversion without collecting personal data or image contents. Without a shared taxonomy, event names fragment and dashboards become unreliable.

## Decision

Use `object_action` snake-case event names defined in `UI_UX_BLUEPRINT.md` section 10.

- Every event includes `language`, `tier`, `source_screen`, and `app_version`.
- Add `crop`, `disease`, `confidence_bucket`, or `severity` only when relevant.
- Never send names, phone numbers, images, or precise coordinates.
- Use coarse region for cooperative analytics.
- Analytics is opt-in where required and never blocks core use.
- Document retention and deletion.

## Why

A shared taxonomy makes funnels comparable across releases, supports the trust-first strategy, and prevents accidental PII collection. It also gives TDD a clear behavioral contract for instrumentation tests.

## Consequences

- New events require a blueprint update.
- Analytics wrappers must be feature-agnostic and testable.
- Dashboards must state their basis and date range.
- Privacy review is required before launch.

## Considered alternatives

- **Ad-hoc events per feature:** fast but unmaintainable.
- **No analytics:** protects privacy but makes product decisions blind.
