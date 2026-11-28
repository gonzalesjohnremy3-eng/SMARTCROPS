# 12 · Care Plan

**Flutter:** `lib/features/care_plan/screens/care_plan_screen.dart`

**Purpose:** Tell the Farmer what their crops need and why it is due now, in the order that matters: today, this week, then preventive work, plus follow-ups suggested by their scans.

**Primary action:** Mark a task done. Adding a suggested follow-up to the Field Calendar is the secondary action.

## Layout

- **Back:** a round Back button at the top (Home opens this page with `push`, so Back returns to Home).
- **Header:** "Care Plan" in Fraunces. On wide screens the content is held to the reading width, centred.
- **Sections:** Today, This Week and Preventive, each a Fraunces title over one raised surface of rows separated by hairlines. Empty sections are not shown.
- **Task row:** a round done button (tooltip "Mark done"; a finished task shows a filled check and is struck through), the title, then "Category · date" in the platform's localized short date. Below it, exactly one reason pill: Weather, Overdue (clay), From scan or Routine, each with its own icon. The old separate "Why now" chip is gone because the pill already says why. A weather-adjusted task adds a canopy note with the old and new dates. Tapping the row opens the task.
- **Suggested for you:** one row per scan that warrants a recheck, with a clear title, "From scan", and an "Add to calendar" pill button under the text, so a long translation never squeezes the title. After adding, a snackbar offers View Calendar.
- **Empty:** the scan reticle around a check mark and "No care items due. Your crops look good."

## States

loading · error with retry · empty · each section · overdue · weather-adjusted · completed · suggestion add success and failure · wide · 200% text in EN, TL and CEB.

## Notes

- Which items appear in which section is unchanged; it comes from `buildCarePlan`.
- No new strings.
