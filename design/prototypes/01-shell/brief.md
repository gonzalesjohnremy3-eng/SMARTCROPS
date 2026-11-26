# P1 · App Shell & Navigation — prototype brief

**Question:** Which shell keeps the five destinations legible on a 720p Android phone while giving Scan the prominence the product job demands?

**Product job served:** All three — the shell is the frame through which every primary screen is reached.

**Data flow / business logic:** `buildAppRouter()` (`lib/app/router/app_router.dart:27`) builds a `StatefulShellRoute.indexedStack` with five branches. Guards run auth → profile → role → not-found (`route_guard.dart:54`). `_ResponsiveBottomNavigation` switches to `NavigationRail` at 840dp and extended at 1024dp. Analytics route observer attaches in `main.dart:120`; deep links and FCM taps enter through `advisory_link_resolver.dart` and `push_notifications.dart`.

**Reliability / accuracy / security gate:**
- Dead deep-link targets `/scan/result/:id` and `/advisories/:id` must resolve or be removed — P1 fix.
- Scan is pushed as an unnamed route from four call sites; back-stack and analytics behavior must be verified, not assumed.
- Client-side role checks are not authorization; cooperative routes stay unregistered until a service exists.

**States:** Shell is always present; offline indicator, unread advisories badge, and queued-scan banner are global overlays to verify.

**Design skills applied:** impeccable, design-mobile-apps, flutter-build-responsive-layout, ui-taste, flutter-motion (rail ↔ bar transition), tokens from ADR 0005.

**Variant verdict:** A (Grounded bar) chosen as the compact default; B is the ≥840dp expression of the same shell; C's persistent briefing strip was rejected for stealing height from task content. Overlay: none (calm shell).

