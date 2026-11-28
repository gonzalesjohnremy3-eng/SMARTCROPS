# 06 · Scan

**Flutter:** `lib/features/scan/screens/scan_capture_screen.dart`

**Purpose:** Get one clear photo of a sick leaf from the right crop, so the diagnosis can be trusted. The Farmer should know before shooting how to frame it and how many free scans they have left.

**Primary action:** Take photo (the shutter). Upload from the gallery is the secondary action.

## Layout

A dark, camera-style screen (forest ink), because it is used outdoors and its job is the photo:

- **Header:** "Scan a crop" in Fraunces, with a quota chip on the right. Free Farmers see "N free scans left this week", and tapping it opens Pro. Pro Farmers see "Unlimited scans with Pro". Counts come from `evaluateScanQuota`, the same rule the review step enforces, including queued offline scans.
- **Viewfinder guide:** a rounded panel with a real example photo (a rice leaf with lesions) inside the scan reticle, plus three tip chips: One leaf · Fill the frame · No shadows.
- **Crop picker:** "Which crop is this?" with one chip per Main Crop, falling back to the crop catalogue. With no crops at all, it explains how to add Main Crops and links to Crops, and the shutter is disabled. There is no hardcoded default crop.
- **Controls:** a large round shutter in the centre ("Take photo"), with Upload on the left. Each has a distinct label; they previously shared one.

The Scan tab has no Back button: it is a destination, not a pushed page.

## States

free with scans left · free with none left (chip in clay) · Pro · no crops · camera permission denied (snackbar, as before) · 200% text in EN, TL and CEB.

## Notes

- Review still opens with `Navigator.push`, unchanged in this pass; moving it into `go_router` belongs with the review screen redesign.
