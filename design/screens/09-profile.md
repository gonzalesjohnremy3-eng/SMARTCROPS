# 09 · Profile

**Flutter:** `lib/features/profile/screens/profile_screen.dart`

**Purpose:** Let the Farmer see who and where Smart Crops thinks they are, correct it, and reach the account things that live behind it: Main Crops, Agri Pro, the shop, language and sign out. Accurate farm details drive the weather and advice they get.

**Primary action:** Edit the farm details, then Save changes. Sign out is deliberately quiet and confirmed.

## Layout

- **Identity:** a canopy avatar with the Farmer's first initial, their name in Fraunces, their email, an "Agri Pro" pill when active, and a round edit button (tooltip "Edit Profile", "Cancel" while editing).
- **Farm details:** one raised surface with Farm Name, Location and Phone, each with a leading icon. Missing values show a dash, never a blank. Editing swaps the surface for four fields (name, farm, location, phone) and a "Save changes" pill button with a loading state. The old bare "Edit Profile" text in the app bar is gone.
- **Main Crops:** the Farmer's crops as small chips, with Manage going to crop selection. With none, the same one-line explanation as Crops.
- **Agri Pro and Shop:** two rows on one surface, each with a title, a one-line reason and a chevron.
- **Language:** English, Tagalog and Cebuano as pills; the selected one is canopy. The change applies at once.
- **Sign out:** a clay text button at the end that opens the existing confirmation.
- **Wide (≥ expanded):** farm details and crops on the left, settings on the right.

## States

no profile yet (shows "Farmer") · view · editing · saving · Pro and free · no crops · 200% text in EN, TL and CEB.

## Notes

- Fixes a defect: the read-only Farm Name row used to show the Farmer's full name.
- The old title card repeated "Farmer Profile" on top of the screen title; the identity block replaces both.
