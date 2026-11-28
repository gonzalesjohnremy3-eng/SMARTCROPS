# 17 · Agri Pro paywall

**Flutter:** `lib/features/pro/screens/agri_pro_paywall_screen.dart`

**Purpose:** Show the Farmer plainly what Agri Pro adds, what it costs and when it renews, so they can choose a plan, or decline, without pressure. Prices and renewal terms are never hidden.

**Primary action:** Start Agri Pro for the selected plan. "Not now" is always as easy to reach.

## Layout

- **Back:** a round Back button at the top.
- **Hero:** the Pro photo under a dark scrim, a premium mark, and the headline "Protect more of what you grow." in Fraunces.
- **Quota context:** only when the Farmer arrives from the scan limit, a clay-tinted callout saying how many of the 5 free scans this week they have used.
- **What you get:** one raised surface listing unlimited scans, priority analysis, health trends, weather-adjusted reminders and the offline pack.
- **Compare:** Free, Monthly and Seasonal as stacked rows (plan, price, what is included) on one surface. It no longer scrolls sideways.
- **Plans:** two selectable cards, Seasonal (pre-selected, with its saving) and Monthly, each with the price, a one-line reason and a radio mark. The selected card has a canopy border.
- **Terms:** the renewal line for the selected plan and "Cancel anytime." directly above the button.
- **Start Agri Pro:** a full-width pill button with a loading state while the store responds. Under it, a quiet "Not now", then the payment note.
- **Wide:** content held to the reading width, centred.

## States

Seasonal selected (default) · Monthly selected · from quota · from the Profile row · purchase in progress · store unavailable, failed or succeeded (snackbars, as before) · 200% text in EN, TL and CEB.

## Notes

- Purchase, entitlement refresh and analytics events are unchanged.
- The comparison keeps its `pro-comparison-table` key.
- No new strings.
