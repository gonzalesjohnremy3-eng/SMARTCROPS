# 13 · Advisories

**Flutter:** `lib/features/advisories/screens/advisories_screen.dart`

**Purpose:** Warn the Farmer about what is happening around their farm that needs attention, most urgent first, so they can act before it costs them a crop.

**Primary action:** Read and clear advisories: tapping an unread one marks it read, and "Mark all as read" clears the lot.

## Layout

- **Back:** a round Back button at the top. Home opens this page with `push`, so Back returns to Home instead of leaving the app; with nothing behind it (a notification link) it goes Home.
- **Header:** "Advisories" in Fraunces, with "Mark all as read" beside it only while something is unread. The action drops under the title at large text.
- **Critical banner:** when a critical advisory exists, a clay-tinted block at the top of the list with "Critical advisory", the title in Fraunces and the message. It shows the first critical advisory and animates in and out unless the Farmer has reduced motion on.
- **Advisory card:** a raised card with a campaign icon tile, the title, the message, and a meta line with the localized date and time. An unread advisory has a clay tile, full-strength text and an "Unread" pill, so it never relies on colour alone; a read one is quiet.
- **Empty:** the scan reticle around a bell and "No advisories yet. We'll tell you when something needs attention."
- **Wide:** content held to the reading width, centred.

## States

loading · error with retry · empty · unread · read · critical · wide · 200% text in EN, TL and CEB.

## Notes

- The critical banner now scrolls with the list instead of being fixed above it. A fixed banner could use up the whole screen at 200% text and leave the list unreachable.
- Dates and times use the platform's localized formats.
- No new strings.
