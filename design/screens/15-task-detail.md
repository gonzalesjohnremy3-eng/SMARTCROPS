# 15 · Task detail

**Flutter:** `lib/features/calendar/screens/task_detail_screen.dart`

**Purpose:** Show one field task clearly: what it is, when it is due and why that date, tied to the diagnosis that caused it, so the Farmer can do it and tick it off.

**Primary action:** Mark done. A finished task shows "Completed", which reopens it when tapped.

## Layout

- **Top row:** a round Back button and a round Edit button (tooltip "Edit task", opens the existing task form sheet).
- **Title:** the task in Fraunces, struck through when completed. Under it, pills for the category, the crop, and "High priority" in clay when it applies. A Normal priority is not printed.
- **When and why:** one raised surface. First "Scheduled for" with the localized date and time; if rain moved it, a canopy note with the original and new dates. Then "Why this date" with the reason in plain words (weather, overdue, from a scan, routine).
- **Mark done:** a full-width pill button. Once done it becomes an outlined "Completed" button that undoes it.
- **Related scan:** the latest scan for the task's crop, or whose crop is named in the title, with the finding and "Crop · Confidence: N%". It opens the Health Log.
- **Delete task:** a quiet clay text button at the end that opens the existing confirmation. The delete confirm button is clay.
- **Wide:** content held to the reading width, centred.

## States

open · completed · high priority · weather-adjusted · with and without a related scan · 200% text in EN, TL and CEB.

## Notes

- Fixes a defect: the related scan was matched by comparing a crop name to a crop id, so it only ever matched when the title happened to name the crop. It now matches by the task's crop too.
- Fixes hardcoded English: "at" between date and time and "% confidence" were not localized.
- The weather note used to appear twice (a note and the reason); it now shows once as the dated note, and the reason line below it.
- No new strings.
