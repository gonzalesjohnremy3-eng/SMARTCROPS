# Adopt go_router with stateful shell routes

- **Status:** Accepted
- **Date:** 2026-11-12

## Context

Navigation currently uses `Navigator.push` and `MaterialPageRoute`. There are no guards, no preserved tab state, and no deep-link handling despite `app_links` being a dependency. The product needs auth, profile-completion, and cooperative-role redirects, plus deep links from advisories and scan results.

## Decision

Adopt `go_router` with `StatefulShellRoute.indexedStack` and named routes.

- Each primary destination is a branch that preserves its stack and scroll position.
- Guards resolve auth, profile completion, and cooperative role before entering a route.
- Deep-link intent survives auth and profile setup.
- Unknown or unauthorized links resolve to a safe recovery screen.
- Scan opens as a full-screen route above the shell.

Keep Provider and the existing service layer for Phase 1. Revisit state management only if feature complexity demands it.

## Why

`go_router` provides first-class nested shells, guards, and deep-link handling without a custom routing framework. It is the Flutter team's recommended router, fits the five-destination structure, and removes the current dead-end navigation. Keeping Provider limits the scope of the change.

## Consequences

- Routes become a shared contract; feature code must not push ad-hoc `MaterialPageRoute`s.
- Tests must cover guard behavior and deep-link resolution.
- The existing screens need a migration path, one feature at a time.
- `app_links` requires platform configuration for custom schemes and universal links.

## Considered alternatives

- **Navigator 1.0 + IndexedStack:** no dependency, but hand-rolled guards and deep links would be fragile.
- **auto_route:** powerful, but code generation is unnecessary for this route count.
