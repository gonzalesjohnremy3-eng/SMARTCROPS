# 14 · Crop detail

**Flutter:** `lib/features/crops/screens/crop_detail_screen.dart`

**Purpose:** Show one Main Crop's health and what it needs in one place: how it is doing, the conditions it grows best in, its latest scans and what is coming up, with a scan one tap away.

**Primary action:** Scan this crop.

## Layout

- **Hero:** the crop photo under a dark scrim with the crop's name in Fraunces. Under it, a severity pill from the latest scan (Healthy, Watch, At Risk) and "Last scan: date" in the platform's short date format. A crop never scanned says "Not scanned yet" with no pill. When the screen is pushed, a Back button sits at the top of the hero.
- **Scan this crop:** a full-width pill button straight under the hero. It goes to the Scan tab with `go_router`, replacing an ad-hoc `MaterialPageRoute`.
- **Growing conditions:** one raised surface, one row per catalogue condition with a readable label ("Temperature range") over its value. With no catalogue data it says "Not available" rather than inventing values.
- **Your scans:** the latest two scans for this crop (never other crops), each with the finding, confidence, localized date and a severity pill.
- **Upcoming tasks:** up to two open tasks for this crop or for all crops, with category and localized date, and an "Open calendar" link that drops under the title at large text.
- **Wide:** inside Crops, the same content fills the right pane without a Back button.

## States

never scanned · healthy / watch / at risk · no conditions · no tasks · pushed vs embedded · 200% text in EN, TL and CEB.

## Notes

- The Growth Timeline and Care Guide sections are gone. Both only ever said "Not available" because no data source exists for them. They can return as real sections when one does.
- Only the latest two scans and two tasks are shown, as before; the Health Log and Calendar hold the rest.
- No new strings.
