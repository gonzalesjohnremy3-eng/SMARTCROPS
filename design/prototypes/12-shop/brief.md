# P12 · Agri Shop + Product Detail — prototype brief

**Question:** How do we present partner products without disguising commerce as advice?

**Product job served:** Secondary — reached from Scan Result, Care Plan and Home, never as a primary destination.

**Data flow / business logic:** `ShopScreen` (`lib/features/shop/screens/shop_screen.dart:10`) reads `merchant_products` via public RLS read (`smart_crops_service.dart:139`) and ranks client-side with `filterAndSortProducts`. `ProductDetailScreen` (`:11`) shows a merchant disclosure sheet before an outbound `affiliate_link`. Only four seeded products exist and they have no image URLs.

**Reliability / accuracy / security gate:**
- ADR 0006: label Partner Offers and disclose commission; never pre-check consent or disguise an ad. The disclosure sheet must appear before the outbound link.
- Product copy must not claim treatment efficacy the merchant did not state — "Follow the product label."
- Affiliate links are outbound; validate the URL scheme before launching to avoid `javascript:`/`file:` navigation.
- No images exist — use token gradient placeholders, not broken image icons.

**States:** loading, empty, error, search/no-results, disclosure accepted/cancelled, outbound link failure.

**Design skills applied:** frontend-design, impeccable, ui-taste, flutter-build-responsive-layout (adaptive grid).

**Verdict:** A (Product grid) chosen with the disclosure always visible above the grid and enforced again at Product Detail. B's editorial rows are used for the "For your diagnosis" section. No generated overlay needed for dense product lists — token gradient placeholders only.

**Glass re-judgment (2026-11-22):** Unchanged — dense catalog. Gradient placeholders stay static; no live glass on product cards.
