# 08 · Calendar

**Flutter:** `lib/features/calendar/screens/field_calendar_screen.dart`

**Purpose:** Show the Farmer what field work is due and when, so nothing is missed: today first, then the week, then the month. It is the Field Calendar from `GLOSSARY.md`.

**Primary action:** Add Task (the extended button at the bottom). Marking a task done is the steady secondary action.

## Layout

- **Header:** "Field Calendar" in Fraunces, then three view pills: Today, This week, Month. The selected pill is canopy; the others are mist. They wrap under long translations rather than overflow.
- **Days:** tasks sit on one raised surface per day, separated by hairlines. Today's view shows one surface; This week and Month add a dated heading per day ("Today", then the platform's localized date).
- **Task row:** a round done button (tooltip "Mark done"; a finished task shows a filled check and is struck through), the title, then "Category · time" in the platform's time format. Under it, in clay pills, "Overdue" and "High priority" when they apply (priority is written out, not a bare "!"). A weather-adjusted task adds a canopy note with the old and new dates. Tapping the row opens the task.
- **Empty:** the scan reticle around a calendar and "No tasks yet. Your plan will appear here." Add Task stays available.

## States

loading · error with retry · no tasks · each view · overdue · high priority · completed · weather-adjusted · 200% text in EN, TL and CEB.

## Notes

- The clock is injectable (`FieldCalendarScreen.now`) so tests are not date-dependent.
- Which tasks each view shows is unchanged from before.
- The old nested `Scaffold` in each state is gone; one screen owns the add button.
