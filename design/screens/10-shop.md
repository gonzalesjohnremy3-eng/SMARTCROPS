# 10 · Shop

**Flutter:** `lib/features/shop/screens/shop_screen.dart`

**Purpose:** Help the Farmer find a partner product that fits the problem they just diagnosed, and be honest that these are partner offers. Agri Shop never replaces the care plan.

**Primary action:** Open a product to read why it matches and continue to the merchant.

## Layout

- **Header:** a Back button when the shop was opened from another screen (Profile, a scan result), "Agri Shop" in Fraunces, and one line saying what it is for: "Partner products matched to your diagnosis".
- **Search:** one rounded field with a clear button. A diagnosis arriving from a scan pre-fills it, and until the Farmer edits it one meaningful word is enough to match ("Early blight" finds the Blight product). Words under three letters and punctuation are ignored. Once edited, every word must match again.
- **Categories:** All, Organic, Fungicide, Fertilizer, Pest control as pills in a row that scrolls sideways. The selected pill is canopy.
- **Product card:** a raised card with a category icon tile, the product name (up to three lines), the merchant, what it treats (with a care icon), the price in tabular figures, and a quiet "Partner offer" label. Results are ranked by relevance, then price, as before.
- **Columns:** one on a phone, two from 600, three from 1200. Cards size to their content, so nothing is cut off at large text.

## States

loading · could not load, with retry · no products at all ("Products will appear here as partners are added.") · no match for the search or category · each category · 200% text in EN, TL and CEB · tablet and desktop columns.

## Notes

- The "Partner offer" label stays on every card on purpose: the commission disclosure is part of the product detail, and each card is an affiliate link.
- The old grid used a fixed card aspect ratio and clipped content with a non-scrolling scroll view; that is gone.
