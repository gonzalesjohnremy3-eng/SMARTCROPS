# 20 · Bottom navigation

**Flutter:** `lib/app/widgets/app_bottom_bar.dart`

**Purpose:** Let the Farmer move between the five places they use every day, Home, Crops, Scan, Calendar and Profile, always knowing where they are, with Scan, the app's main job, one thumb-tap away.

**Primary action:** Scan.

## Layout

- **Island:** the bar is a raised rounded surface that floats above the phone's gesture area with a margin on each side, a hairline border and one soft shadow. It is not a full-width slab stuck to the screen edge, and it has no blur.
- **Destinations:** five equal slots, each an icon in a capsule over a label.
  - The current destination has a soft mist capsule, a filled icon, and a bold canopy label.
  - Other destinations are a quiet outlined icon and a grey label.
  - **Scan** is always a filled canopy capsule with a light icon, even when it is not the current one, so the main action never looks like just another tab.
- **Labels:** localized (English, Tagalog, Cebuano). They were hardcoded English. At large text they scale down to fit their slot instead of overflowing, and the touch targets stay at least 48px.
- **Motion:** the highlight eases between destinations with the shared motion tokens, and is instant when the Farmer has reduced motion on.
- **Tooltips and screen readers:** each slot announces its name, that it is a button, and whether it is selected. Tooltips use the fuller names ("My Crops", "Field Calendar", "Scan a crop").

## States

each destination current · Scan current and not current · bottom gesture inset · 200% text in EN, TL and CEB on a 320px phone.

## Notes

- Scan still opens the capture screen with its existing route; this pass is visual.
- At expanded width the app still uses the navigation rail, now with localized labels.
