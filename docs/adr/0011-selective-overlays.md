# Use selective photographic overlays with a gradient fallback

- **Status:** Accepted
- **Date:** 2026-11-21

## Context

The upgrade calls for AI-generated backgrounds with overlays. The app targets Android 8+ devices with 2 GB RAM, works offline, and its tokens already define a forest-gradient scrim for text over imagery. The `belt` CLI used for generation is not installed and needs an account, and an overlay on every dense list or calendar surface would work against field-first clarity.

## Decision

Apply generated photographic overlays only to immersive surfaces: Onboarding, Home's Field Briefing, Scan capture, Crop detail, Agri Shop product detail and the Agri Pro paywall. Each overlay is bundled and compressed locally, sits beneath a forest-gradient scrim, and is credited in `PROJECT_KNOWLEDGE/ASSETS.md`. All other screens stay calm and token-only. When generation tooling is unavailable, use the token-based gradient scrim alone.

## Why

It gives the identity a memorable visual moment where it matters, protects contrast and cold-start performance, and keeps dense task surfaces legible in sunlight.

## Consequences

- Overlay assets are optional progressive enhancement; no screen depends on them.
- Text contrast must still meet WCAG 2.2 AA with the scrim applied.
- Each generated asset needs a licensing/consent note before release.

## Considered alternatives

- **Overlays on every page:** more uniform, but hurts density, performance and readability.
- **No imagery at all:** safe, but loses the photographic identity ADR 0001 chose.
