# P9 · Care Plan — prototype brief

**Question:** Should the Care Plan read as ranked urgency, a flat checklist, or a crop-stage journey?

**Product job served:** Job 2 — what to do now.

**Data flow / business logic:** `CarePlanScreen` (`lib/features/care_plan/screens/care_plan_screen.dart:15`) groups prioritized care recommendations into Today / This Week / Preventive, derived from `crop_calendar_events`, `scan_history` and weather via `BriefingFacts`. It is reachable from Home and Crop Detail.

**Reliability / accuracy / security gate:**
- "Why now" reasons must cite real data; never invent a nearby-outbreak claim (no outbreak service exists for farmers).
- Weather-adjusted items inherit the P5 mock-weather risk — hide the reason when weather is a sample.
- Completing an item mutates a calendar event; owner-only RLS must hold.

**States:** loading, empty, error, one group stale, all done, reduced motion.

**Design skills applied:** flutter-motion (`connected-product-workflows.md` — cross-fade only the changed region), impeccable, ui-taste.

**Verdict:** A (Priority stack) chosen — it answers "what now" in one glance. B is the compact checklist expression; C's stage bar is reused in P7. No overlay. Motion is a short local transition per completed item, never a full-page refresh.
