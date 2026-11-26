# P13 · Agri Pro paywall + manage — prototype brief

**Question:** What is the honest moment and framing for a subscription ask?

**Product job served:** Monetization — must never interrupt Job 1.

**Data flow / business logic:** `AgriProPaywallScreen` (`lib/features/pro/screens/agri_pro_paywall_screen.dart:11`) and `AgriProManageScreen` (`:9`) read `AgriProEntitlement`. Quota is computed client-side (`features/pro/domain/scan_quota.dart`, `weekly_scan_window.dart`). Billing uses `SimulatedProBilling` because store billing is "not configured yet".

**Reliability / accuracy / security gate — P12 gate:**
- `user_subscriptions` INSERT/UPDATE RLS lets a farmer write `tier='premium'` themselves. **Must be closed before launch** — use a secure server-side verification/billing webhook; the client must not be the authority for entitlement.
- Never show "5 scans" as authoritative until server-enforced; quota is advisory.
- ADR 0006: no fabricated urgency, honest renewal terms, no pre-checked consent, disclose commission-adjacent monetization plainly.
- "Restore purchase" must have a real path or be hidden — do not show a dead control.

**States:** free, quota reached, entitled, billing unavailable ("not configured yet"), restore success/failure, reduced motion.

**Design skills applied:** impeccable, ui-taste, frontend-design, flutter-motion.

**Verdict:** B (Value story) chosen for first exposure after value is proven; C (Quota context) is the honest trigger at the weekly limit; A is the comparison table on the plan screen. Generated overlay on B's hero only. Motion: restrained reveal, no celebratory animation for a purchase.

