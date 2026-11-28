# 06a · Scan review

**Flutter:** `lib/features/scan/screens/scan_review_screen.dart`

**Purpose:** Let the Farmer confirm the photo is good enough before spending a scan on it, then analyze it.

**Primary action:** Analyze. Retake is secondary.

## Layout

It continues the dark Scan capture screen, so the flow feels like one camera:

- **Photo:** the captured photo fills the top, framed by the scan reticle.
  - A close button returns to capture (Retake).
  - A pill names the chosen crop.
- **Sheet:** a dark sheet below the photo asks "Is the leaf clear?" with one line on what good looks like.
  - The pill button runs Analyze.
  - Retake sits under it.
- **While analyzing:** a scan line sweeps the photo, and the button shows "Analyzing your crop…". This is the screen's one authored motion; under reduced motion the line holds still.
- **Errors:** inline, in plain words ("We couldn't analyze this photo…"), never raw exception text.

## Routing

`/scan/review` sits above the tab shell, with the photo and crop passed as `extra`. Opening it without them (a reload or deep link) goes to `/scan`. The result replaces it (`/scan/result`). An offline or failed upload queues the scan and returns to `/scan` with the existing "Saved…" snackbar. The route observer logs `scan_review_viewed`.

## States

ready · analyzing · failed (inline) · queued offline (snackbar, back to capture) · weekly limit reached (opens Pro, unchanged).
