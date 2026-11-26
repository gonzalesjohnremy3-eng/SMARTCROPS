# P7 · Crops + Crop Detail — prototype brief

**Question:** Do farmers think in crop cards, in a master–detail list, or in growth stages?

**Product job served:** Jobs 1 and 3 — crop health status and stage-aware timing.

**Data flow / business logic:** `CropsScreen` (`lib/features/crops/screens/crops_screen.dart:12`) lists `user_crops` with last-scan info; `CropDetailScreen` (`:11`) shows growing conditions, latest scans, upcoming tasks and a "Scan this crop" action. Wide layouts use a master–detail split (`app_router.dart:110`). Missing conditions render "Not available" — never invented.

**Reliability / accuracy / security gate:**
- `user_crops` access is RLS-scoped to the farmer; never render another farmer's crop IDs.
- Scan status is derived from the latest `scan_history` row — demo rows must be labeled and not treated as verified health.
- "Growing conditions not available" must remain honest even when the optimal-conditions JSON is missing.

**States:** loading, empty (no main crops), error, crop with no scans, demo-only scan, expanded master–detail.

**Design skills applied:** flutter-build-responsive-layout, impeccable, ui-taste, flutter-motion (selection cross-fade).

**Verdict:** A (card grid) for compact, B (master–detail) for ≥840dp — the same data, not two products. C (stage timeline) is rejected as a primary view but its stage bar is folded into Crop Detail. Overlay: generated crop-close-up image on Crop Detail hero only.

