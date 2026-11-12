# Smart Crops - Phase 0 Wireframes

Low-fidelity structural wireframes for review. Visual styling, photography, and final copy live in `UI_UX_BLUEPRINT.md` and `UI_COPY_DECK.md`.

Notation: `[ ]` action, `( )` selectable, `===` strong divider, `~` image or media area.

---

## 1. App shell

### Compact (<600dp)

```text
+----------------------------------+
|  Greeting / Farm name     [bell] |
|  [offline chip when stale]       |
|                                  |
|  screen content                  |
|                                  |
|                                  |
|                                  |
+----------------------------------+
| Home  Crops  (SCAN)  Calendar  Me|
+----------------------------------+
```

- `(SCAN)` is a 64dp raised leaf-lime control with a forest icon and the label "Scan".
- The bar uses a docked FAB notch. The scan control hides while the Scan flow is open.
- Bell opens Advisories. Badge shows unread count.

### Expanded (>=840dp)

```text
+----------+-----------------------------------------------+
| Brand    |  Screen title                    [bell] [me] |
|          |                                               |
| Home     |  content max 1120dp                            |
| Crops    |                                               |
| Scan     |                                               |
| Calendar |                                               |
| Advisories|                                              |
| Shop     |                                               |
|          |                                               |
| Profile  |                                               |
+----------+-----------------------------------------------+
```

- Extended rail 240dp, collapses to 96dp between 840 and 1024.
- Master-detail screens put the list left and detail right.

---

## 2. Onboarding

```text
+----------------------------------+
| English / Tagalog / Cebuano      |
|                                  |
|            ~~~~~~~~              |
|          crop photo              |
|            ~~~~~~~~              |
|                                  |
|  Spot trouble before it spreads. |
|                                  |
|  Take a photo. Get a clear       |
|  diagnosis in seconds.           |
|                                  |
|            [ Next ]              |
|            Skip                  |
|                                  |
|          (o) ( ) ( )             |
+----------------------------------+
```

Pages:

1. Spot trouble before it spreads.
2. Know exactly what to do next.
3. Plan around the weather, not against it.

Final page: `[ Get started ]` and `I already have an account`.

---

## 3. Auth

```text
+----------------------------------+
|            [logo]                |
|          Smart Crops             |
|        by Agri Lynk              |
|                                  |
|  Welcome to your field office.   |
|                                  |
|  [ Continue with phone ]         |
|  [ Continue with Google ]        |
|  [ Continue with Facebook ]      |
|  ----------- or -----------      |
|  [ Use email instead ]           |
|                                  |
|  Your farm data stays private.   |
|  Terms   Privacy                 |
+----------------------------------+
```

Phone OTP state:

```text
+----------------------------------+
|  Enter your mobile number        |
|  [ +63 9xx xxx xxxx          ]   |
|            [ Send code ]         |
|                                  |
|  Enter the 6-digit code          |
|  [ _ _ _ _ _ _ ]                 |
|  Resend in 0:42                  |
|            [ Verify ]            |
+----------------------------------+
```

---

## 4. Profile wizard

```text
+----------------------------------+
|  <-  Step 1 of 3        Skip     |
|  ============--------------------|
|                                  |
|  About you                       |
|  [ Full name                   ] |
|  [ Mobile number               ] |
|  [ Add a photo (optional)      ] |
|                                  |
|            [ Continue ]          |
+----------------------------------+
```

Step 2 - Your farm:

```text
|  Your farm                       |
|  [ Farm name                   ] |
|  [ Location                    ] |
|  [ Use my location ]             |
|  [ Farm size (optional)        ] |
|                                  |
|  Why we ask: weather and         |
|  regional advisories.            |
|            [ Continue ]          |
```

Step 3 - Your crops:

```text
|  Choose your main crops          |
|  Search [                    ]   |
|  +--------+ +--------+ +------+  |
|  | ~pechay| | ~rice  | |~corn |  |
|  | [x]    | | [ ]    | | [ ]  |  |
|  +--------+ +--------+ +------+  |
|  +--------+ +--------+ +------+  |
|  | ~tomato| | ~squash| |~more |  |
|  | [x]    | | [ ]    | |      |  |
|  +--------+ +--------+ +------+  |
|  Selected: 2                     |
|            [ Continue ]          |
```

Permission priming follows: location for weather, notifications for advisories. Each has `Not now`.

---

## 5. Home - Today's Field Briefing

```text
+----------------------------------+
|  Good morning, Maria      [bell] |
|  Sunrise Farm, Digos City        |
|                                  |
|  ===== FIELD BRIEFING ========== |
|  Tue, 12 Nov                     |
|  ~weather icon~  28 C, Partly     |
|  cloudy, 76% humidity            |
|  Rain likely at 2 PM.            |
|                                  |
|  Today's priority                |
|  Hold off watering. Rain will    |
|  do it for you.        [Why?]    |
|                                  |
|  [ Scan a crop ]                 |
|  [ View field calendar ]         |
|  ================================|
|                                  |
|  Your crops                      |
|  [Pechay Healthy] [Rice Watch]   |
|  [Tomato No scan yet]  [Crops ->]|
|                                  |
|  Recent diagnoses                |
|  ~ Leaf Spot - Pechay - 92%      |
|  ~ Healthy - Rice - 88%          |
|  [ View health log ]             |
|                                  |
|  This week's care plan           |
|  [ ] Inspect lower leaves        |
|  [ ] Apply compost               |
|  [ Open care plan ]              |
|                                  |
|  Partner offer (only if relevant)|
|  ~ Organic neem oil  [View]      |
|                                  |
|  [ Scan ] center action          |
+----------------------------------+
```

States: loading skeleton, offline banner, critical cooperative advisory pinned above the briefing, empty farm state.

---

## 6. Crops

```text
+----------------------------------+
|  <-  Crops             [Add +]   |
|  [All] [Healthy] [Watch] [Risk]  |
|                                  |
|  +------------------------------+|
|  | ~~~~~~ pechay photo ~~~~~~   ||
|  | Pechay                       ||
|  | Vegetative - Healthy         ||
|  | Last scan: 2 days ago        ||
|  | Next: Inspect lower leaves   ||
|  +------------------------------+|
|                                  |
|  +------------------------------+|
|  | ~~~~~~ rice photo ~~~~~~~~   ||
|  | Rice                         ||
|  | Flowering - Watch            ||
|  | Last scan: today             ||
|  | Next: Check water level      ||
|  +------------------------------+|
+----------------------------------+
```

Expanded: list left 360dp, crop detail right.

---

## 7. Crop detail

```text
+----------------------------------+
|  <-  Pechay              [Scan]  |
|  ~~~~~~~~~~~~~ hero ~~~~~~~~~~~~ |
|  Vegetative - Healthy            |
|  Last scan: 2 days ago           |
|                                  |
|  Growing conditions              |
|  Temperature   18-24 C           |
|  Soil          Loose, loamy      |
|  Watering      Keep moist        |
|                                  |
|  Growth timeline                 |
|  Seedling == Vegetative == Flower|
|             ^ you are here       |
|                                  |
|  Care guide                      |
|  [v] Spacing and airflow         |
|  [>] Common pests               |
|  [>] Harvest signs              |
|                                  |
|  Your scans for this crop        |
|  ~ Leaf Spot - 92% - 2 days ago  |
|  [ View all ]                    |
|                                  |
|  Upcoming tasks                  |
|  [ ] Inspect lower leaves        |
|  [ Add to calendar ]             |
+----------------------------------+
```

---

## 8. Scan flow

### Capture

```text
+----------------------------------+
|  [X]       Scan crop     [flash] |
|                                  |
|  Fill the frame with one leaf.   |
|  Avoid shadows.                  |
|                                  |
|         +--------------+         |
|         |              |         |
|         |    ~~~~~~    |         |
|         |   leaf view  |         |
|         |              |         |
|         +--------------+         |
|          leaf reticle            |
|                                  |
|  Crop: [Pechay v]                |
|                                  |
|  [gallery]      (o)      [info]  |
|                  shutter         |
+----------------------------------+
```

### Review / analyzing

```text
+----------------------------------+
|  <-  Review photo                |
|  ~~~~~~~~ preview ~~~~~~~~       |
|  Crop: Pechay                    |
|  [ Retake ]   [ Analyze crop ]   |
|                                  |
|  --- analyzing ---               |
|  ~~~~~~~~ preview ~~~~~~~~       |
|  Checking leaf color...          |
|  Looking for spots and pests...  |
|  Preparing your next steps...    |
|  [ Cancel ]                      |
+----------------------------------+
```

Offline state: `Saved. We'll analyze when you're back online.` with queue status.

---

## 9. Scan result

```text
+----------------------------------+
|  <-  Diagnosis            [share]|
|  ~~~~~~~~ crop photo ~~~~~~~~    |
|  Pechay - just now               |
|                                  |
|  Leaf Spot            92% high   |
|  Confidence: the pattern is clear|
|  Severity: Watch                 |
|                                  |
|  What we see                     |
|  A fungal leaf spot common in    |
|  pechay. It can spread in humid  |
|  weather if leaves stay wet.     |
|                                  |
|  What to do next                 |
|  1. Remove affected leaves       |
|  2. Improve airflow              |
|  3. Avoid overhead watering      |
|  4. Apply approved treatment     |
|                                  |
|  [ Add to field calendar ]       |
|  [ Set a reminder ]              |
|                                  |
|  Partner offers                  |
|  ~ Neem oil - AgriSupply - P280  |
|  [ View product ]                |
|                                  |
|  Saved to Health Log             |
+----------------------------------+
```

Low confidence variant: `Retake in better light` primary, explanation, no product offers until confidence is usable. Healthy variant: no disease language, reinforce monitoring.

---

## 10. Field Calendar

```text
+----------------------------------+
|  <-  Field Calendar    [Today]   |
|  [Timeline] [Month]              |
|                                  |
|  Tue 12 Nov                      |
|  [x] Inspect lower leaves        |
|      Pechay - Watch              |
|  [ ] Hold watering               |
|      Weather-adjusted - Rain     |
|                                  |
|  Wed 13 Nov                      |
|  [ ] Apply compost               |
|      Rice - Nutrition            |
|                                  |
|  Thu 14 Nov                      |
|  [ ] Check water level           |
|      Rice - Water                |
|                                  |
|  [ + Add task ]                  |
+----------------------------------+
```

Month view: grid with dots for tasks; selected day agenda below. Expanded: month left, agenda right.

Task detail: why this date, weather note, crop, related scan, edit/delete.

---

## 11. Advisories inbox

```text
+----------------------------------+
|  <-  Advisories      [Mark read] |
|  [All] [Crop] [Weather] [Coop]   |
|                                  |
|  ! Critical advisory             |
|  Pest outbreak in your area      |
|  Cooperative: Digos Farmers      |
|  10 min ago              [open]  |
|                                  |
|  ~ Leaf Spot detected in Pechay  |
|  Your scan result is ready.      |
|  2 hours ago             [open]  |
|                                  |
|  ~ Rain expected tomorrow        |
|  Watering task moved.            |
|  Yesterday               [open]  |
+----------------------------------+
```

Empty state: `No advisories yet. We'll tell you when something needs attention.`

---

## 12. Health Log

```text
+----------------------------------+
|  <-  Health Log         [search] |
|  This season: 12 scans           |
|  8 healthy - 4 need attention    |
|  [All crops v] [All statuses v]  |
|                                  |
|  November 2026                   |
|  ~ Leaf Spot - Pechay - 92%     |
|    Watch - 2 hours ago           |
|  ~ Healthy - Rice - 88%          |
|    Healthy - Yesterday           |
|                                  |
|  October 2026                    |
|  ~ Nutrient issue - Tomato - 74% |
|    Watch - Oct 28                |
+----------------------------------+
```

Expanded: timeline left, scan detail right.

---

## 13. Care Plan

```text
+----------------------------------+
|  <-  Care Plan                   |
|  Your plan for this week         |
|  Weather-aware for Digos City    |
|                                  |
|  [Today] [This week] [Preventive]|
|                                  |
|  +------------------------------+|
|  | Inspect lower leaves          ||
|  | Pechay - because of your scan ||
|  | [ ] Mark done  [Add to calendar]|
|  +------------------------------+|
|  +------------------------------+|
|  | Hold off watering             ||
|  | Rain expected at 2 PM         ||
|  | [ ] Mark done  [Add to calendar]|
|  +------------------------------+|
|                                  |
|  Partner offer                   |
|  ~ Neem oil - matches Leaf Spot  |
|  [ View product ]                |
+----------------------------------+
```

---

## 14. Agri Shop

```text
+----------------------------------+
|  <-  Agri Shop          [search] |
|  [All] [Organic] [Fungicide]     |
|  [Fertilizer] [Pest control]     |
|                                  |
|  Matching Leaf Spot              |
|  +------------------------------+|
|  | ~ product  Organic neem oil  ||
|  | AgriSupply - P280            ||
|  | Partner offer     [View]     ||
|  +------------------------------+|
|  +------------------------------+|
|  | ~ product  Copper fungicide  ||
|  | GreenFarm - P350             ||
|  | Partner offer     [View]     ||
|  +------------------------------+|
|                                  |
|  Partner offers may earn us a    |
|  commission. Follow label advice.|
+----------------------------------+
```

Product detail: why it matches, application guidance, merchant, price, `[ Go to merchant ]` with confirmation. No sponsored ranking without a label.

---

## 15. Agri Pro paywall

```text
+----------------------------------+
|  [X]                             |
|  Protect more of what you grow.  |
|                                  |
|  Free plan                       |
|  5 scans this week               |
|  Basic field calendar            |
|                                  |
|  Agri Pro                        |
|  Unlimited scans                 |
|  Priority analysis               |
|  Health trends                   |
|  Weather-adjusted reminders      |
|  Offline pack                    |
|                                  |
|  ( ) Monthly      P___ / month   |
|  ( ) Seasonal     P___ / 6 months|
|      Best for one crop season    |
|                                  |
|  [ Start Agri Pro ]              |
|  Not now                         |
|                                  |
|  Cancel anytime. Clear renewal.  |
+----------------------------------+
```

Trigger contexts: after a successful diagnosis, at the weekly quota, from Profile. No fake countdowns.

---

## 16. Profile and settings

```text
+----------------------------------+
|  Profile                         |
|  [avatar] Maria Santos           |
|  Sunrise Farm, Digos City        |
|  [ Edit profile ]                |
|                                  |
|  Farm details              >     |
|  Main crops                >     |
|  App language              >     |
|  Notifications             >     |
|                                  |
|  Agri Pro                  >     |
|  Cooperative Hub           >     |
|                                  |
|  Privacy and data          >     |
|  Help and support          >     |
|  About Smart Crops         >     |
|                                  |
|  [ Sign out ]                    |
+----------------------------------+
```

Language sheet: English, Tagalog, Cebuano. Applying a language updates the UI immediately.

---

## 17. Cooperative Hub

### Member

```text
+----------------------------------+
|  <-  Digos Farmers Cooperative   |
|  Member since May 2026           |
|                                  |
|  Latest advisories               |
|  ! Critical: Pest outbreak       |
|    10 min ago             [open] |
|  ~ Advisory: Fertilizer schedule |
|    Yesterday              [open] |
|                                  |
|  Cooperative info                |
|  Region: Davao del Sur           |
|  Contact: Extension officer      |
|                                  |
|  Invite a farmer   [Share code]  |
+----------------------------------+
```

### Administrator overview

```text
+----------------------------------+
|  <-  Cooperative     [Broadcast] |
|  [Overview] [Members] [Advisories]|
|                                  |
|  Regional snapshot               |
|  Based on 128 scans this month   |
|                                  |
|  Leaf Spot     42 farmers  92%   |
|  Blight        18 farmers  88%   |
|  Nutrient      11 farmers  74%   |
|                                  |
|  [ trend chart ]                 |
|  [ regional map / heatmap ]      |
|                                  |
|  Recent broadcasts               |
|  - Pest outbreak alert           |
|  - Fertilizer schedule           |
+----------------------------------+
```

Broadcast composer:

```text
|  New broadcast                   |
|  Title [                      ]  |
|  Severity (Critical)(Warning)(Info)
|  Target crops [Pechay v]         |
|  Message [                    ]  |
|  Preview                         |
|  [ Send to 42 members ]          |
```

Role guard: only Cooperative Administrators and Extension Officers can open admin routes.

---

## 18. State patterns

```text
Loading:   [skeleton blocks matching final layout]
Empty:     ~illustration~ headline + one action
Error:     what happened + [Try again] + support link
Offline:   banner: "Offline. Showing last updated data."
Queued:    "Saved. We'll analyze this when you're online."
Success:   inline confirmation or short toast, never a blocking modal
```

Every screen must define loading, empty, error, offline, and success states.
