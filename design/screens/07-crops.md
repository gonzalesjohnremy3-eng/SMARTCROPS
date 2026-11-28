# 07 · Crops

**Flutter:** `lib/features/crops/screens/crops_screen.dart`

**Purpose:** Show the Farmer, at a glance, which of their Main Crops is healthy and which needs them, and put a scan one tap away from each. The list is a health board, not a catalogue.

**Primary action:** Scan this crop (the round camera button on each card). Opening a crop for its detail is the card itself.

## Layout

- **Header:** "My Crops" in Fraunces, the count of Main Crops under it, and, only when a crop's latest scan is At Risk, a clay line saying how many need attention.
- **Crop card:** a raised card per Main Crop.
  - Left tile and status pill take their colour from the crop's latest scan: Healthy, Watch, At Risk. A crop never scanned says "Not scanned yet" in a neutral pill. Nothing is guessed.
  - The last scan date uses the platform's localized short date.
  - Up to three growing conditions from the catalogue, as small chips with readable labels (`temperature_range` shows as "Temperature range").
  - The round camera button opens Scan. Its tooltip is "Scan this crop".
- **Empty:** the scan reticle around a leaf and the one-line reason to add crops.
- **Wide (≥ expanded):** the list on the left, the selected crop's detail on the right. The selected card gets a canopy border.

## States

loading · error with retry · no crops · never scanned · healthy · watch · at risk · attention line shown or hidden · wide split · 200% text in EN, TL and CEB.

## Notes

- Status wording comes from the same severity ARB strings as Home.
- The old per-card "Scan this crop" text button is now an icon button, so a list of crops no longer reads as a column of identical primary buttons.
