# Use five destinations with a center Scan action

- **Status:** Accepted
- **Date:** 2026-11-12

## Context

The app has five core jobs: see today's priority, manage crops, scan a crop, plan around weather, and manage the farm profile. The existing two-tab Home/Profile navigation pushes everything else, hides the product's differentiator (the Field Calendar), and does not scale to Agri Shop, Agri Pro, or Cooperative surfaces.

## Decision

Use five primary destinations:

1. Home
2. Crops
3. Scan (center docked action, full-screen flow)
4. Calendar
5. Profile

Advisories remain globally accessible through a bell and a dedicated inbox. Care Plan, Health Log, and Agri Shop are contextual secondary routes. Cooperative Hub is role-gated from Profile and critical Home banners.

Do not add a separate Alerts tab. Do not add a More hub at launch.

## Why

Five destinations is the practical limit for low-cognitive-load mobile navigation. Scanning is the product's primary verb and deserves a persistent, prominent control. Calendar is the unique differentiator and must be visible, not buried. Everything else is reached in context, which keeps the primary bar stable as the product grows.

## Consequences

- History and recommendations are not primary tabs; discoverability depends on Home and crop-detail entry points.
- The scan action opens above the shell and hides the navigation bar.
- Cooperative administrators do not get a sixth tab; their hub lives in Profile and contextual banners.
- Deep links must always resolve within the correct branch.

## Considered alternatives

- **Alerts tab instead of Calendar:** matches the original PDF but buries the differentiator and duplicates the bell.
- **More hub:** scalable but adds a low-value destination and hides core features.
- **Keep the current two-tab grid:** cheapest, but it does not provide a real navigation structure.
