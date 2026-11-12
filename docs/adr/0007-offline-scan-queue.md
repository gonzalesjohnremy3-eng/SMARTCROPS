# Queue scans offline and analyze when connectivity returns

- **Status:** Accepted
- **Date:** 2026-11-12

## Context

Farmers work in fields with intermittent connectivity. The current app has an unused offline cache service and no queue. Losing a captured scan because the network dropped is unacceptable.

## Decision

Queue scans locally when offline:

1. Capture and persist the image locally.
2. Create a queued scan record visible in the UI.
3. Show "Saved. We'll analyze this when you're back online."
4. Upload with exponential backoff when connectivity returns.
5. On success, create the result and an Advisory; notify the farmer.
6. On permanent failure, keep the image and offer retry or delete.
7. Never silently drop a scan.

Cache Home, crops, crop detail, calendar, advisories, and last weather with explicit last-updated timestamps. Server wins for shared records; local drafts win only for unsaved profile edits.

## Why

This matches the real field condition, protects the farmer's effort, and turns connectivity loss into a trustworthy deferred experience rather than a dead end.

## Consequences

- The app needs persistent local storage and a queue state machine.
- Duplicate-upload and conflict handling must be tested.
- Image storage on device must be bounded and cleaned up.
- Analytics must distinguish online and queued scans.

## Considered alternatives

- **Online-only:** simpler, but frustrating and lossy.
- **On-device AI:** best latency and privacy, far beyond current scope.
