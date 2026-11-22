# P11 · Health Log — prototype brief

**Question:** Do season statistics, a narrative timeline, or a density calendar best show progress without overstating it?

**Product job served:** Record and progress — the fourth message in the hierarchy.

**Data flow / business logic:** `HealthLogScreen` (`lib/features/health_log/screens/health_log_screen.dart:10`) shows a season summary and chronological scan list from `service.scanHistory`. No filters, search or scan-detail screen exists today. The S3 fix (`features/health_log/domain/health_log_statistics.dart`) now excludes `demo_offline` rows from the three statistics and marks demo rows in the list.

**Reliability / accuracy / security gate:**
- Verify demo rows are labeled **and** excluded from counts — covered by `test/features/health_log/health_log_statistics_test.dart`.
- Never present 68–95% fabricated confidence as a real diagnosis.
- Health Log is RLS-scoped per farmer; no cross-farm rows.

**States:** empty ("No scans yet. Your first diagnosis starts here."), populated with real scans, mixed real+demo, error, reduced motion.

**Design skills applied:** impeccable, ui-taste, flutter-motion (list choreography, bounded stagger).

**Verdict:** A (Stats + list) chosen with the demo label and exclusion applied. B is an alternate presentation for a future scan-detail view; C is rejected as too abstract for the audience. No overlay. Motion: subtle bounded list entrance, capped so long histories stay fast.

**Glass re-judgment (2026-11-22):** Unchanged — dense stats/list surface; no live glass.
