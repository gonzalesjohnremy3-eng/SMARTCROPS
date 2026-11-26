# P10 · Advisories Inbox — prototype brief

**Question:** Should critical information be pinned, or should the inbox be a neutral reverse-chronological list?

**Product job served:** Jobs 1 and 3 — early warning and timing.

**Data flow / business logic:** `AdvisoriesScreen` (`lib/features/advisories/screens/advisories_screen.dart:10`) lists `notifications` with unread badge, mark-as-read and mark-all-read. Inserts arrive via Supabase Realtime (`smart_crops_service.dart:197`) and FCM taps route through `push_notifications.dart`. `advisory_link_resolver.dart:29` targets `/advisories/:id`, which is **not registered** — P1 fix.

**Reliability / accuracy / security gate:**
- Realtime handles inserts only; unread state on other devices needs a refetch — do not claim instant sync everywhere.
- `broadcast_advisories` SELECT policy lets every farmer read every cooperative's advisories (cross-cooperative exposure). Must be scoped before the Cooperative Hub ships.
- Deep links from critical advisories must resolve; never drop a farmer at a blank screen.
- Critical styling must be reserved for real risk, with icon + label + color (never color alone).

**States:** empty, unread, critical, mark-as-read failure, realtime disconnect, deep-linked detail.

**Design skills applied:** impeccable, design-mobile-apps, flutter-motion (banner entrance), tokens.

**Verdict:** A (Inbox list) is the base; B's critical banner is promoted into A when a real critical advisory exists. C is rejected — grouping hides recency on a field phone. No overlay. Motion: gentle banner entrance only, reduced-motion cross-fade.

