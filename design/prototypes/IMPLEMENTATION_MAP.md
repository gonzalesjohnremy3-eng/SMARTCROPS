# Prototype verdict → Flutter implementation map

This map closes the 14 Field Almanac briefs against `master`. Each row records the chosen verdict elements and where they are implemented in Flutter.

| Page | Verdict elements | Flutter evidence |
|---|---|---|
| `01-shell` | A grounded bar compact; B ≥840dp shell | `lib/app/router/app_router.dart` — `StatefulShellRoute`, `NavigationBar`, `NavigationRail` |
| `02-onboarding` | A story spread | `lib/features/onboarding/screens/onboarding_screen.dart` — `PageView`, `OverlayHero` |
| `03-auth` | B phone first; wide trust panel | `lib/features/auth/screens/auth_screen.dart` — inline phone OTP is the default method, email is "Use email instead"; `OverlayHero` beside the card at ≥840px |
| `04-profile-setup` | A wizard steps | `lib/features/profile/screens/profile_setup_screen.dart` — 3-step wizard |
| `05-home` | A Field Briefing hero; wide split dashboard | `lib/features/home/screens/home_screen.dart` — `OverlayHero`; two-column `LayoutBuilder` at ≥840px |
| `06-scan` | A viewfinder HUD; C result layout + Demo badge | `lib/features/scan/screens/scan_capture_screen.dart`, `scan_result_screen.dart` |
| `07-crops` | A card grid; B master-detail ≥840px; C stage bar in detail | `lib/features/crops/screens/crops_screen.dart`, `crop_detail_screen.dart` |
| `08-calendar` | A day agenda; B week tab; C month tab | `lib/features/calendar/screens/field_calendar_screen.dart` |
| `09-care-plan` | A priority stack; B checklist expression | `lib/features/care_plan/screens/care_plan_screen.dart` |
| `10-advisories` | A inbox base; critical banner from B | `lib/features/advisories/screens/advisories_screen.dart` — severity-driven banner above the list |
| `11-health-log` | A stats + list; scan detail from B | `lib/features/health_log/screens/health_log_screen.dart` — master-detail and compact detail sheet |
| `12-shop` | A product grid; disclosure enforced twice | `lib/features/shop/screens/shop_screen.dart`, `product_detail_screen.dart` |
| `13-pro` | B value story; C quota context; comparison table from A | `lib/features/pro/screens/agri_pro_paywall_screen.dart` — hero, quota context, plan comparison table |
| `14-profile` | A grouped sections; B identity header merged in; two-column profile at ≥840px | `lib/features/profile/screens/profile_screen.dart` — grouped columns in `LayoutBuilder` |

The Field Almanac direction is governed by ADR 0010 and the shared `shared/tokens.css`; no A/B/C winner changed. `design/prototypes/` is the only design line.
