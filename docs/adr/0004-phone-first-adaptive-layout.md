# Design phone-first with adaptive tablet and desktop layouts

- **Status:** Accepted
- **Date:** 2026-11-12

## Context

The repo targets Android, iOS, web, Windows, macOS, and Linux, but every layout is phone-only. The primary user is a farmer on a phone in the field. Supporting large windows does not require a separate desktop product, but stretched phone layouts are unacceptable.

## Decision

Design for phones first and adapt at two structural breakpoints:

- `<600`: bottom bar with center Scan, single column, 16 gutters.
- `600-839`: bottom bar, two-column grids, 24 gutters, max 720 content.
- `>=840`: extended NavigationRail, master-detail, 32 gutters, max 1120 content.
- `>=1200`: centered max-width content; no stretched cards.

Use `LayoutBuilder` for parent-space decisions and `MediaQuery.sizeOf` for app-window measurements. Do not check hardware types. Do not lock orientation. Use lazy builders and max-extent grids.

## Why

This preserves the field-first phone experience while making tablet and desktop targets credible. It follows Flutter's adaptive guidance and keeps a single codebase.

## Consequences

- Every screen needs compact and expanded layouts, increasing design and test effort.
- Master-detail is required for Crops, Health Log, Advisories, Shop, and Cooperative.
- Landscape and foldable windows must be tested.
- Forms and reading content must be constrained, not stretched.

## Considered alternatives

- **Phone-only:** fastest, but wastes existing targets and fails large-window quality.
- **Full desktop parity:** high effort with little value for the primary audience.
