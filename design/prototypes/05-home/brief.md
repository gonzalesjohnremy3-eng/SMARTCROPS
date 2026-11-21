# P5 · Home — Field Briefing prototype brief

**Question:** Which hierarchy answers "what's happening / what do I do now / when" without burying the priority action?

**Product job served:** All three — this is the daily entry point.

**Data flow / business logic:** `HomeScreen` (`lib/features/home/screens/home_screen.dart:15`) renders `_WeatherSummary` (`:235`) and a priority computed by `FieldBriefing` (`lib/features/home/domain/field_briefing.dart`) from tasks, scans and weather. Data arrives via `SmartCropsService.initializeUserData()` → `SupabaseFarmDataLoader.fetchFarmData()` → `FarmSnapshot` → cache → `ChangeNotifier`. Weather comes from `WeatherService` (wttr.in) with `WeatherCacheStore`.

**Reliability / accuracy / security gate:**
- `WeatherService` falls back to **hardcoded mock weather on any error with no marker**. That invented data drives "critical weather" briefings and task rescheduling. Fix: mark the snapshot as `isSample` and suppress weather-adjusted claims until live data returns.
- Cached `FarmSnapshot` is global (`farm_data_snapshot`) and not cleared on sign-out — cross-user leak. Fixed in P13, verified here.
- "Last updated" timestamps must be honest; never present cached data as live.

**States:** loading skeleton, populated, partial (weather unavailable), error, offline, first-use empty.

**Design skills applied:** impeccable, design-mobile-apps, flutter-motion + `connected-product-workflows.md`, ui-taste, frontend-design, ai-image-generation.

**Verdict:** A (Field Briefing hero) chosen — the immersive overlay earns one memorable moment, the priority line is the single message, and the weather card carries an honest timestamp. C is the ≥840dp expression. Overlay: generated farm-dawn image + Forest scrim. Motion: cross-fade partial weather failures, not the whole page.
