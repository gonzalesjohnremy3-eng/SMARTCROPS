# P6 · Scan flow (capture → review → result) — prototype brief

**Question:** Does a dark HUD, a guided checklist, or a minimal capture frame build the most confidence before the farmer commits a scan?

**Product job served:** Job 1 (what's happening) and Job 2 (what do I do now).

**Data flow / business logic:** `ScanCaptureScreen` → `ScanReviewScreen` → `ScanResultScreen` (unnamed `Navigator` pushes, `scan_capture_screen.dart:45`, `scan_review_screen.dart:123`). Review checks client quota (`scan_quota.dart`), uploads the image to the `scan-images` bucket, invokes `scan-crop` (now JWT-bound — see S2), and presents `DiagnosisView` via `diagnosis_presenter.dart`. Offline/failed scans enqueue via `ScanQueueProvider` (`scan_queue.dart`).

**Reliability / accuracy / security gate (S3):**
- On AI failure, `performAiScan` inserts a **fabricated diagnosis with 68–95% confidence** (`offline_demo_diagnosis.dart`, `smart_crops_service.dart:326`). Required fix: a persistent, unmissable Demo Diagnosis badge on the result, and exclusion of `source=demo_offline` rows from Health Log statistics.
- `enqueueScan` uploads the image, then `processPending()` uploads it again — two Storage objects per queued scan. Fix in this phase.
- `enqueueScan` always returns `true`; distinguish upload failure.
- Quota is client-computed and the premium RLS is self-grantable (fixed in P12). Never show a quota number as authoritative until server-enforced.
- The scan-images bucket is public; images are named `<user_id>/<epoch>.<ext>`. Keep paths user-scoped.

**States:** capture, reviewing, analyzing (staged copy), result, demo result, queued/offline, quota reached, upload failure, reduced motion.

**Design skills applied:** flutter-motion (900ms scan sequence, interruption-safe), impeccable, design-mobile-apps, ui-taste, ai-image-generation.

**Verdict:** A (Viewfinder HUD) chosen for capture; C's result layout chosen with a mandatory Demo Diagnosis badge when `source=demo_offline`. B's guidance becomes inline tips, not a separate step. Overlay: generated field-close-up image on capture, with Forest scrim.

**Glass re-judgment (2026-11-22):** Unchanged — A's reticle is the single glass plate over the viewfinder; C's result and demo badge stay opaque.
