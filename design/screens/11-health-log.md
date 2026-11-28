# 11 · Health Log

**Flutter:** `lib/features/health_log/screens/health_log_screen.dart`

**Purpose:** Give the Farmer a trustworthy history of their crops' health: how the season is going at a glance, and the full diagnosis and treatment behind any past scan.

**Primary action:** Open a past scan to read what was found and what to do. With no scans yet, Scan a Crop is the primary action.

## Layout

- **Back:** a round Back button at the top (Home opens this page with `push`, so Back returns to Home).
- **Header:** "Health Log" in Fraunces.
- **Season summary:** one raised surface with three counts in Fraunces: Scans, Healthy (green), Need attention (clay). Demo diagnoses are not counted, so the numbers are never inflated.
- **History:** scans grouped under a month heading ("January 2026", localized). Each month is one raised surface of rows separated by hairlines. A row shows the crop, the finding, confidence and the localized short date, a severity pill (Healthy, Watch, At Risk), and a "Demo diagnosis" pill for demo scans.
- **Detail:** a severity-tinted header with the finding in Fraunces, crop, full date, severity, confidence and the demo label if it applies, then "What to do now" as numbered steps. On a phone it opens as a bottom sheet that scrolls at large text; at expanded width it fills the right pane and the selected row is highlighted.
- **Empty:** the scan reticle around a care icon, "No scans yet. Your first diagnosis starts here." and a Scan a Crop button.

## States

loading · error with retry · no scans · healthy / watch / at risk · demo scan · wide master-detail · compact bottom sheet · 200% text in EN, TL and CEB.

## Notes

- Severity and dates use the same ARB strings and platform date formats as Home.
- Filtering by severity is not part of this pass.
