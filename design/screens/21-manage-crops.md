# 21 · Manage crops

**Flutter:** `lib/features/profile/screens/manage_crops_screen.dart`

**Purpose:** Let a Farmer who has finished setup change which crops they grow, so care, scans and advice stay about the right crops.

**Primary action:** Save changes.

## Layout

- **Back:** a round Back button at the top.
- **Title and context:** "Your Main Crops" in Fraunces with the same one-line explanation as setup.
- **Crop picker:** the same search, crop pills and running count as profile setup (one shared widget). The Farmer's current crops start selected, and a selected crop shows a check, not just a colour. Choosing none is allowed.
- **Save changes:** a full-width pill button with a loading state. On success the page closes and the Profile shows the new crops; on failure it stays and shows the error.

## States

crops selected or none · saving · save failed · 200% text in EN, TL and CEB.

## Notes

- Opened from Profile, Main Crops, Manage, at `/manage-crops`. It replaces sending that button to the setup wizard, which is not a destination once a profile is complete.
