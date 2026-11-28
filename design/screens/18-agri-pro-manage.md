# 18 · Agri Pro manage

**Flutter:** `lib/features/pro/screens/agri_pro_manage_screen.dart`

**Purpose:** Tell the Farmer exactly where they stand with Agri Pro: whether it is active, when it renews, who bills them and how to cancel, and give a free Farmer a clear way to upgrade.

**Primary action:** For a Pro Farmer, Restore purchase is the only action, kept quiet. For a free Farmer, See Agri Pro plans.

## Layout

- **Back and title:** a round Back button and "Manage Agri Pro" in Fraunces.
- **Pro:** a canopy block with the premium mark, "Current plan", "Agri Pro — Active" in Fraunces and the one-line summary. Below it, one raised surface with Renews (the localized date, or "Until you cancel") and Billing ("Managed by your app store."), then how to cancel with an info icon, then an outlined Restore purchase button.
- **Free:** a raised block saying "You're on the Free plan" with the reason to upgrade, and a full-width See Agri Pro plans pill button to the paywall. There is no Restore button.
- **Loading:** a loading state under the title.
- **Wide:** content held to the reading width, centred.

## States

loading · Pro with a renewal date · Pro until cancelled · free · restore result snackbars (restored, unavailable, failed) · 200% text in EN, TL and CEB.

## Notes

- Fixes hardcoded wording: the renewal date was printed "31/12/2026"; it now uses the platform's localized date.
- Fixes a translation slip: the English "Billing" label was the Tagalog word "Pagbayad".
- Restore and entitlement refresh behave as before.
