# 06b · Scan result

**Flutter:** `lib/features/scan/screens/scan_result_screen.dart`

**Purpose:** Tell the Farmer what is wrong with the crop, how sure Smart Crops is, and exactly what to do now, then help them put that work on the Field Calendar.

**Primary action:** Add to Field Calendar. When confidence is low, Retake in better light becomes the primary action instead.

## Layout

- **Verdict header:** a tinted band in the severity colour (healthy canopy, watch palay, at-risk clay).
  - The crop name sits small, above the diagnosis in large Fraunces.
  - A severity pill and a single confidence meter follow: a bar plus "High · 87%". Confidence used to be shown twice.
- **Notices:**
  - The demo notice (palay) when the result is a labelled sample.
  - "Not sure about this one" when confidence is low, explaining how to retake.
- **What to do now:** the numbered treatment steps, the most important content, shown open.
- **Learn more:** Why it happens · What you will see · How to prevent it · When to call an expert, as collapsible rows so the steps stay near the top.
- **Action bar:** pinned at the bottom.
  - The primary pill button.
  - Share as an icon button.
  - Scan another crop.
  - Products for this problem, only when partner offers are allowed.

Removed:
- the "Set Reminder" button, which did nothing (the calendar task is the reminder);
- the offline "Saved…" footer, which showed on every result;
- the placeholder grass icon.

## Behaviour

- Retake and Scan another crop go to `/scan`. Retake used to only log an event.
- The follow-up task title is localized ("Recheck {crop}: {diagnosis}").
- `/scan/result` sits above the tab shell, with the diagnosis passed as `extra`; without it, it goes to `/scan`. The route observer logs `scan_result_viewed`.

## States

healthy · watch · at risk · low confidence · demo · partner offers on or off · 200% text.
