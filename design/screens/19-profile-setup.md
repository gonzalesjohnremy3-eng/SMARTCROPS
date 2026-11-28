# 19 · Profile setup

**Flutter:** `lib/features/profile/screens/profile_setup_screen.dart`

**Purpose:** Get a new Farmer from sign-in to a useful app in three short steps: who they are and where their farm is, which crops they grow, and which permissions to allow. It is also where Manage crops from Profile leads. The Farmer should always know how far along they are and never lose what they typed.

**Primary action:** Next on each step, then Complete Setup on the last.

## Layout

- **Progress header:** three dashes that fill as the Farmer advances, "Step N of 3" beside them (it wraps at large text), and a round Back button from step 2. The old app bar repeating "About You" on every step is gone.
- **About You:** a Fraunces title and one line of context, then Full Name, Farm Name and Location (required) and Phone Number (optional). A missing field says "This field is required" next to it, not a generic error. Fields suggest the right keyboard, capitalise names and move on with the keyboard's Next key.
- **Your Main Crops:** a rounded search field, then crops as pills. A selected crop turns canopy and shows a check mark, so it never relies on colour alone. A running count ("2 crops selected") sits underneath. Choosing none is allowed.
- **Permissions:** one raised surface with Camera, Location and Notifications, each with its reason, a chevron, and a green check once granted. Denying shows the existing message with a Settings action.
- **Next / Complete Setup:** a full-width pill button, with a loading state while saving.

## States

About You skipped when already saved · validation errors · saving · save failed (snackbar, stays on the step) · no crop catalogue (built-in fallback list) · crops selected or none · permission granted, denied, or unavailable on this platform · 200% text in EN, TL and CEB.

## Notes

- Behaviour is unchanged: About You is saved on its own before advancing so closing the app cannot lose it; a profile that already has About You starts at the crops step; Complete Setup writes the completion flags and goes Home.
- Step changes use the shared motion tokens instead of a hardcoded ease.
- One new string, `fieldRequired`, in EN, TL and CEB.
