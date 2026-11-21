# P8 · Field Calendar + Task Detail — prototype brief

**Question:** Which time frame do farmers actually plan in — day, week, or month?

**Product job served:** Job 3 — when to act, given weather and crop stage.

**Data flow / business logic:** `FieldCalendarScreen` (`lib/features/calendar/screens/field_calendar_screen.dart:15`) renders Today/This week/Month views from `crop_calendar_events`; `TaskDetailScreen` (`:14`) shows why-now reason, weather note, related scan and edit/delete. `TaskFormSheet` (`widgets/task_form_sheet.dart`) handles add/edit. Weather adjustments come from `WeatherAdjustment` (`features/calendar/domain/`). Every mutation triggers a full `initializeUserData()` refetch.

**Reliability / accuracy / security gate:**
- Weather-adjusted wording is driven by `WeatherService` mock fallback (see P5) — suppress "moved by rain" claims when weather is not live.
- Calendar events are RLS-scoped per farmer; never show another farmer's tasks.
- Full refetch after each mutation is wasteful on 2 GB devices; prefer targeted updates where safe.
- Task completion is a client update — verify RLS allows only the owner to toggle.

**States:** loading, empty (no tasks), error, partial (weather unavailable), task detail, form sheet, reduced motion.

**Design skills applied:** flutter-build-responsive-layout, flutter-motion (reorder/cross-fade), impeccable, ui-taste.

**Verdict:** A (Day agenda) is the default with B (Week strip) as a tab and C (Month grid) as the long-range tab. No overlay — this is a dense task surface. Motion is limited to the changed task row.
