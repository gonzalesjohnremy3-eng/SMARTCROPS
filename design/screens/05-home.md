# 05 · Home

**Flutter:** `lib/features/home/screens/home_screen.dart`

**Purpose:** Each morning, tell the Farmer what today needs: the weather on their farm, the one thing to do first, and what is on this week's care list. The Field Briefing (`GLOSSARY.md`) is the screen.

**Primary action:** The Field Briefing's priority action (from `selectPriorityAction`), shown once. Scanning a crop is the steady secondary action.

## Layout

- **Greeting:** today's date (from the platform's localized date format), then a time-of-day greeting in Fraunces with the Farmer's first name, plus a notifications button with an unread dot.
- **Field Briefing card:** the paddies photo under a dark scrim. Top: Location, temperature in Fraunces, condition, humidity and "Updated HH:MM". Unknown weather shows dashes, never invented values. Bottom: the priority action's icon, title, body and a light button to its destination. The priority action appears nowhere else.
- **Advisory strip:** only when an unread advisory exists, a clay-tinted row under the card naming it, linking to Advisories.
- **Scan prompt:** a quiet full-width row with the scan reticle, "Scan a crop" and a one-line reason, going to the Scan tab (`/scan`). It replaces the floating action button, which duplicated the Scan destination and pushed an ad-hoc route.
- **This week's care:** up to three open tasks, each with a round check button to mark it done, then "View all" to the Care Plan.
- **Recent diagnoses:** up to three scans with crop, finding, confidence and a localized relative date ("Today", "Yesterday") and a localized severity pill. Tapping opens the Health Log.
- **Wide (≥ expanded):** briefing, advisory and scan prompt on the left, care and diagnoses on the right.

## States

loading · error with retry · pull to refresh · no weather (dashes) · no tasks · no scans · unread advisory · each of the six priority kinds · 200% text.

## Notes

- Severity, humidity and relative-date wording come from ARB files, not hardcoded English.
- No eyebrow labels; section titles in sentence case.
