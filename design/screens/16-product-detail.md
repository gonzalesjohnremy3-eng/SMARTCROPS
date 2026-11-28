# 16 · Product detail

**Flutter:** `lib/features/shop/screens/product_detail_screen.dart`

**Purpose:** Let the Farmer judge one partner product, why it fits their diagnosis, what it costs and who sells it, and be told plainly that it is an affiliate offer before they leave the app.

**Primary action:** Go to merchant. The partner disclosure always appears first.

## Layout

- **Top row:** a round Back button and a round Share button (tooltip "Share"). Share moved up from a text link at the bottom.
- **Hero:** the product photo under a dark scrim, a category icon, the product name in Fraunces and the merchant.
- **Price:** the price in Fraunces, tabular figures, with a "Partner offer" label beside it. They stack at large text rather than overflowing.
- **Why this product:** one raised surface with "Why this product", the one-line reason for the diagnosis, and the always-follow-the-label safety note with an info icon.
- **Go to merchant:** a full-width pill button. Tapping it opens the partner disclosure sheet (Fraunces title, the commission wording, a "Continue to merchant" pill and a quiet Cancel). Only Continue leaves the app.
- **Partner disclosure:** a quiet link under the button that opens the same wording in a dialog.
- **Loading and error:** both keep a Back button; the error offers retry.
- **Wide:** content held to the reading width, centred.

## States

passed in vs loaded by id · loading · could not load · disclosure sheet · 200% text in EN, TL and CEB.

## Notes

- Fixes a defect: the price row overflowed by a few pixels on a 390-wide phone at normal text.
- The disclosure sheet and dialog both scroll, so the commission wording stays readable at 200% text.
- No new strings.
