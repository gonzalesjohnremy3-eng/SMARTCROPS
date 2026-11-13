# Smart Crops by Agri Lynk - UI/UX Blueprint

**Status:** Phase 0 approved direction  
**Date:** 2026-11-12  
**Owner:** Product Design + Mobile Engineering  
**Related:** [GLOSSARY.md](../../GLOSSARY.md) · [UI_COPY_DECK.md](UI_COPY_DECK.md) · [wireframes.md](../../design/wireframes.md) · [tokens.json](../../design/tokens.json) · [ADR index](../../docs/adr/)

This document is the source of truth for the Smart Crops interface. It defines the brand, design system, information architecture, navigation, screen behavior, responsive rules, accessibility, measurement, and implementation mapping. When a screen and this document disagree, this document wins until an ADR supersedes it.

---

## 0. How to use this document

1. Read sections 1-4 before designing or coding any screen.
2. Use section 5 as the acceptance spec for each screen.
3. Use sections 6-9 for layout, accessibility, offline, and content decisions.
4. Use section 10 for analytics naming; never invent event names outside it.
5. Use section 12 before changing schema or services.
6. Update this document and the related ADR when a decision changes.

---

## 1. Product context and audit

Smart Crops helps farmers turn a crop photo into a clear next step: a diagnosis, a treatment plan, and a weather-aware schedule. The product must feel like a trusted field companion, not a generic AI utility.

### Current state

| Area | Reality |
|---|---|
| Visual system | Generic Material, hardcoded greens, Roboto, repeated rounded cards |
| Navigation | Home + Profile bottom bar; all other screens pushed with `Navigator` |
| Authentication | Email/password, Google, Facebook, phone OTP UI present |
| Onboarding | Not built |
| Scan | Capture UI exists, but analysis uses a placeholder image URL rather than the captured image |
| Care Plan | Static recommendations, not personalized |
| Calendar | Screen exists; weather adjustment is not wired |
| Advisories | Bottom-sheet notification list; no unified inbox, no realtime |
| Agri Shop / Agri Pro / Cooperative | Schema and tests only; no user-facing surface |
| Localization | Service exists; not applied to `MaterialApp`; strings hardcoded |
| Offline | Cache service exists; not integrated |
| Deep links | `app_links` dependency only; no routing or platform config |
| Responsive | Phone-only layouts on web/desktop targets |
| Documentation | Implementation status overstates user-accessible completeness |

### Product job

When a farmer sees something wrong, Smart Crops should answer three questions in order:

1. What is happening to my crop?
2. What should I do about it now?
3. When should I do it, given the weather and the crop stage?

Every primary screen serves one of those questions. Everything else is secondary.

---

## 2. Brand strategy

### 2.1 Positioning

For Filipino farmers who cannot afford to lose a harvest, Smart Crops is the field companion that turns a photo into a clear next step - diagnosis, treatment, and a weather-aware plan - so every decision protects the harvest.

**Master line:** Detect Early. Protect Your Harvest.  
**In-app promise:** Know what your crop needs - before it costs you the season.  
**Category:** AI-assisted crop health companion.  
**Differentiator:** The Field Calendar adapts to crop stage, scan history, and live weather.

### 2.2 Brand architecture

- **Smart Crops** is the product and the primary in-app name.
- **Agri Lynk** is the parent brand, cooperative network, and trust signature.
- Splash and store listing use: `Smart Crops` with `by Agri Lynk`.
- In-app app bars use `Smart Crops`; the parent signature appears in About, auth, and cooperative surfaces.
- Keep the existing logo mark. Create mono, reversed, and app-icon variants. Do not redraw the mark without brand-owner approval.
- The existing tagline is retained for launch. Do not stack multiple taglines on one screen.

### 2.3 Personality and voice

| Trait | Sounds like | Does not sound like |
|---|---|---|
| Calm | "Rain is likely at 2 PM. Hold off watering." | "URGENT: your crops are in danger!" |
| Knowledgeable | "Leaf spot spreads faster when leaves stay wet." | "Our advanced AI revolutionizes farming." |
| Neighborly | "You're 2 of 5 tasks done this week." | "Unlock your full potential, farmer!" |
| Precise | "92% confidence - the pattern is clear." | "100% accurate diagnosis." |

Voice rules:

- Use plain verbs and short sentences.
- Name the action, not the system: "Add to calendar", not "Create event object".
- Keep the same verb through a flow: "Save changes" produces "Changes saved".
- Explain what happened and how to fix it. Errors never apologize and never blame the farmer.
- Use sentence case. No all-caps labels.
- Avoid jargon: "spots", "pests", "nutrients", not "pathogens", "biotic stress", "NPK index".
- Never overclaim. AI supports judgment; it does not replace an agronomist.

### 2.4 Messaging hierarchy

1. **Harvest protection** - the outcome.
2. **Clear next step** - the product's core value.
3. **Weather-aware timing** - the differentiator.
4. **Record and progress** - the retention reason.
5. **Agri Pro** - the capacity to do more.
6. **Agri Shop** - the practical follow-through.

A screen should carry one message from this hierarchy, not all six.

### 2.5 Marketing psychology map

| Lever | Where | Honest application | Guardrail |
|---|---|---|---|
| Jobs to be done | All onboarding and CTAs | Frame around "protect the harvest" and "know the next step" | No feature lists without an outcome |
| Loss aversion | Onboarding, real weather warnings | "A missed spot can spread." Only when the risk is real | No fabricated urgency |
| Social proof | Cooperative advisories, testimonials | Real cooperative names and farmer stories | Never invent counts or reviews |
| Authority | Diagnosis, Care Plan | Agronomist-reviewed content and clear sources | Show basis, not just a badge |
| Reciprocity | Free tier | 5 free scans/week and a free care guide | State limits clearly |
| Commitment and consistency | Profile wizard, first scan | Small steps: profile, crops, first scan | No forced fields |
| Goal gradient | Weekly plan, season progress | Show "2 of 5 tasks done" | No manipulative streak loss |
| Peak-end rule | Scan result | End with a clear, doable next step | Never celebrate a wrong diagnosis |
| Anchoring | Agri Pro | Seasonal plan anchored to the crop cycle | Transparent pricing and renewal |
| Scarcity | Peak-season queue | Only when queue or weather is genuinely constrained | No fake countdowns |
| Endowment | Health Log, Calendar | The farmer's record and plan gain value over time | Easy export and deletion |
| Status-quo bias | Onboarding | Pre-fill known data and reduce setup friction | No hidden defaults for consent |
| Hick's law | Every screen | One primary action; secondary actions recede | No competing primary buttons |
| BJ Fogg | Scan flow | Motivation (harvest), ability (camera guidance), prompt (scan CTA) | Remove friction before adding persuasion |
| Peak-end + Pratfall | Trust copy | Admit AI limits plainly | Credibility over perfection |

### 2.6 Ethical marketing rules

These are release-blocking:

- No fake urgency, fake scarcity, fake testimonials, or invented user counts.
- No pre-checked consent, hidden renewal, or disguised ads.
- Every Partner Offer is labeled and discloses commission.
- AI confidence is explained in plain language; low confidence changes the recommended action.
- A farmer can dismiss any upsell without losing access to core care.
- No fear-based diagnosis language when the result is healthy or uncertain.
- Privacy by default: no individual farm data shown to other farmers.

---

## 3. Design system - Field Almanac

### 3.1 Design principles

1. **Decision before data.** Every screen answers "what should I do now?"
2. **Field-first clarity.** Legible in sunlight, one-handed, offline-aware.
3. **Calm authority.** Severity is earned by evidence, not by color.
4. **One memorable element.** The Field Briefing and the scan HUD carry the identity; everything else stays quiet.
5. **Local by design.** Philippine crops, languages, weather, and cooperatives.
6. **Honest intelligence.** Confidence and limitations are visible.
7. **Progressive disclosure.** Scan, then result, then plan, then product.
8. **Trust is a feature.** Clear pricing, privacy, and partner disclosure.

### 3.2 Color

| Token | Hex | Role |
|---|---|---|
| Forest Ink | `#12372A` | Primary text, dark surfaces |
| Canopy | `#1F6B45` | Primary actions and links |
| Leaf | `#7AC943` | Signature accent, reticle, selected state |
| Mist | `#F2F6EC` | Canvas |
| Paper | `#FFFDF7` | Cards and sheets |
| Palay | `#D9A441` | Weather and caution |
| Clay | `#B4482E` | Critical and disease |
| Rain | `#3B6E8F` | Water and weather information |

Neutrals: `#24312B`, `#5C6B62`, `#A8B5AC`, `#E3EAE2`, `#F1F4EF`.

Usage rules:

- Body text on Mist or Paper must meet 4.5:1.
- Leaf is a background/accent, not body text. Use Forest Ink on Leaf.
- Status is never color-only: icon + label + color.
- Critical color is reserved for real risk. Do not use clay for ordinary errors or marketing.
- Dark-mode values are reserved in tokens but not exposed at launch.

### 3.3 Typography

- **Display:** Fraunces, weights 500/600. Onboarding headlines, screen titles, empty-state moments.
- **Body/UI:** Public Sans, weights 400/500/600/700. All controls, data, and reading text.
- **Scale:** Display 32/36, H1 26/32, H2 22/28, H3 18/24, Body 16/24, Small 14/20, Caption 12/16, Data 13/18.
- Use tabular numerals for confidence, temperature, and measurements.
- Maximum line length: 72 characters for reading, 56 for forms.
- No all-caps labels, no letter-spaced eyebrows, no decorative italics.
- Do not use Fraunces for dense data or long body copy.

### 3.4 Spacing and layout

- 4pt base: 4, 8, 12, 16, 20, 24, 32, 40, 48, 64.
- Compact gutters: 16. Medium: 24. Expanded: 32.
- Form width: 560 max. Reading width: 720 max. Dashboard: 1120 max.
- Cards use internal padding 16 or 20. Section gaps 24. Screen bottom padding includes the navigation bar and safe area.
- Do not stretch cards edge-to-edge on tablets; center constrained content.

### 3.5 Shape and elevation

- Buttons: 10. Cards: 16. Sheets: 24. Hero media: 28 bottom corners. Chips: pill.
- Use hairline borders (`#DCE5DA`) instead of diffuse shadows.
- Tinted shadow only for the scan control, floating sheets, and modals.
- Avoid identical card treatment for every content type. Data tiles, photo cards, task rows, and partner offers have distinct shapes.

### 3.6 Iconography

- Custom 24dp core icons for Scan, Crops, Calendar, Advisories, and Shop: organic 2px stroke, rounded caps.
- Material Symbols Rounded for utility actions.
- 18dp inline, 24dp default, 32dp empty-state/hero.
- Never use emoji as an interface icon.
- Status icons: check (healthy), eye (watch), alert triangle (risk), cloud-rain (weather), users (cooperative).

### 3.7 Imagery

- Use real Philippine farm and crop photography. Avoid generic Western stock.
- Crop library images: 4:3, consistent lighting, one subject per frame.
- Scan and crop hero images: 16:9 or full-bleed with a forest gradient scrim for text.
- Custom line illustrations for empty states: seedling, calendar, inbox, cooperative, offline.
- Custom scan HUD: corner brackets, scanning line, subtle leaf/bug marks.
- Compress uploads to a 1600px long edge at JPEG 80. Cache thumbnails.
- Record consent and licensing for identifiable people and farms.

### 3.8 Motion

| Moment | Motion | Reduced motion |
|---|---|---|
| Scan analysis | 900ms reticle sweep with staged copy | Static progress + text updates |
| Result reveal | 250ms fade/slide of the diagnosis card | Immediate |
| Task complete | Check draw + light haptic | Haptic only if enabled |
| Save/upgrade press | 0.98 scale press | No scale |
| Page transitions | Platform default | Platform default |

Rules:

- One orchestrated moment per screen, not scattered entrances.
- No auto-advancing carousels.
- No decorative looping animation.
- Respect `MediaQuery.disableAnimations`.
- Haptics are optional and never the only feedback.

### 3.9 Component inventory

Foundation:

- `AppScaffold`, `AppTopBar`, `AppBottomBar`, `AppNavigationRail`
- `ScanControl`, `PageHeader`, `SectionHeader`, `Divider`
- `PrimaryButton`, `SecondaryButton`, `TextLink`, `IconAction`
- `Field`, `FormSection`, `SearchField`, `FilterChips`

Data and status:

- `FieldBriefingCard`, `WeatherChip`, `PriorityActionCard`
- `CropCard`, `CropStatusPill`, `CropStageTimeline`, `ConditionRow`
- `ScanThumbnail`, `ConfidenceMeter`, `SeverityBadge`
- `TaskRow`, `TaskCheck`, `WeatherAdjustedBadge`
- `AdvisoryTile`, `CriticalAdvisoryBanner`
- `PartnerOfferCard`, `PriceRow`, `PartnerDisclosure`
- `StatTile`, `TrendChart`, `OutbreakTable`

Feedback and structure:

- `LoadingSkeleton`, `EmptyState`, `ErrorState`, `OfflineBanner`, `QueuedScanBanner`
- `BottomSheet`, `ConfirmDialog`, `Toast`, `InlineValidation`
- `PermissionPrimer`, `LanguageSheet`, `PaywallSheet`

Every component is built from tokens. No raw colors, font sizes, or spacing in feature code.

---

## 4. Information architecture and navigation

### 4.1 Navigation model

Five primary destinations with a center Scan action:

| Position | Destination | Job |
|---|---|---|
| 1 | Home | Today's Field Briefing and entry points |
| 2 | Crops | Manage and inspect the farmer's crops |
| 3 | Scan | Capture and analyze a crop photo |
| 4 | Calendar | Plan and complete weather-aware tasks |
| 5 | Profile | Farm, language, plan, cooperative, settings |

Global:

- **Advisories** bell with unread badge in the top bar.
- **Offline/sync** indicator when data is stale or a scan is queued.
- **Scan** is a full-screen flow, not a persistent tab; it opens above the shell and hides the bar.

Secondary, contextual:

- Care Plan from Home and Crop detail.
- Health Log from Home and Crops.
- Agri Shop from Scan result, Care Plan, and Home when relevant.
- Agri Pro from Profile and quota moments.
- Cooperative Hub from Profile and critical Home banners.

### 4.2 Navigation map

```text
Launch / deep link
├─ Splash
├─ First run → Onboarding (3 skippable pages)
└─ Session → Home / Auth

Auth
├─ Phone OTP (when SMS is configured)
├─ Google
├─ Facebook
├─ Email sign in / sign up
└─ Profile wizard
   ├─ Step 1: About you
   ├─ Step 2: Your farm
   ├─ Step 3: Your crops
   └─ Permission priming

Main shell
├─ Home
│  ├─ Field Briefing
│  ├─ Crops pulse
│  ├─ Recent diagnoses → Health Log
│  ├─ Care Plan
│  └─ Contextual Partner Offer → Agri Shop
├─ Crops
│  └─ Crop detail → scans, tasks, care guide
├─ Scan (full-screen)
│  ├─ Capture
│  ├─ Review
│  ├─ Analyzing
│  └─ Result → calendar, shop, share
├─ Calendar
│  └─ Task detail
└─ Profile
   ├─ Farm details
   ├─ Main crops
   ├─ Language
   ├─ Notifications
   ├─ Agri Pro
   ├─ Cooperative Hub
   ├─ Privacy and data
   ├─ Help
   └─ About

Global
├─ Advisories inbox
└─ Offline / sync status
```

### 4.3 Route table

| Route | Screen | Auth | Profile complete | Role |
|---|---|---|---|---|
| `/splash` | Splash | No | No | Any |
| `/onboarding` | Onboarding | No | No | Any |
| `/auth` | Auth | No | No | Any |
| `/auth/otp` | Phone OTP | No | No | Any |
| `/setup/profile` | Profile wizard | Yes | No | Any |
| `/setup/permissions` | Permission priming | Yes | No | Any |
| `/home` | Home | Yes | Yes | Any |
| `/crops` | Crops | Yes | Yes | Any |
| `/crops/:cropId` | Crop detail | Yes | Yes | Any |
| `/scan` | Scan capture | Yes | Yes | Any |
| `/scan/review` | Scan review | Yes | Yes | Any |
| `/scan/analyzing` | Scan progress | Yes | Yes | Any |
| `/scan/result/:scanId` | Scan result | Yes | Yes | Any |
| `/health-log` | Health Log | Yes | Yes | Any |
| `/health-log/:scanId` | Scan detail | Yes | Yes | Any |
| `/care-plan` | Care Plan | Yes | Yes | Any |
| `/calendar` | Field Calendar | Yes | Yes | Any |
| `/calendar/events/:eventId` | Task detail | Yes | Yes | Any |
| `/advisories` | Advisories inbox | Yes | Yes | Any |
| `/advisories/:id` | Advisory detail | Yes | Yes | Any |
| `/shop` | Agri Shop | Yes | Yes | Any |
| `/shop/products/:productId` | Product detail | Yes | Yes | Any |
| `/pro` | Agri Pro paywall | Yes | Yes | Any |
| `/pro/manage` | Manage plan | Yes | Yes | Any |
| `/cooperative` | Cooperative Hub | Yes | Yes | Any |
| `/cooperative/join` | Join cooperative | Yes | Yes | Any |
| `/cooperative/members` | Member roster | Yes | Yes | Admin/Officer |
| `/cooperative/broadcast/new` | Broadcast composer | Yes | Yes | Admin/Officer |
| `/profile/edit` | Edit profile | Yes | Yes | Any |
| `/profile/language` | Language | Yes | Yes | Any |
| `/profile/notifications` | Notification preferences | Yes | Yes | Any |
| `/profile/privacy` | Privacy and data | Yes | Yes | Any |
| `/profile/help` | Help | Yes | Yes | Any |
| `/profile/about` | About | Yes | Yes | Any |

### 4.4 Guards and deep links

Guards run in order:

1. **Auth guard:** no session → `/auth`, preserving the intended destination.
2. **Profile guard:** session but no farm or Main Crop → `/setup/profile`.
3. **Role guard:** cooperative admin routes require a Cooperative Administrator or Extension Officer record.
4. **Not-found:** friendly recovery with `Go home` and `Try again`.

Deep links:

- `smartcrops://scan/<scanId>`
- `smartcrops://advisories/<advisoryId>`
- `smartcrops://calendar/events/<eventId>`
- Universal links on a verified domain, for example `https://app.smartcrops.ph/scan/<scanId>`.

Deep-link intent survives auth and profile setup. Unknown or unauthorized links resolve to a safe screen with an explanation, never a blank page.

### 4.5 Shell behavior

- `StatefulShellRoute` preserves each destination's scroll position and nested stack.
- Tapping the active destination pops that branch to its root.
- Tapping Scan opens a full-screen route above the shell; closing returns to the previous destination.
- The top bar is consistent: screen title, optional back, Advisories bell, optional offline chip.
- The bottom bar hides during the Scan flow and immersive media.
- The system back gesture follows platform convention. On Android, back from a tab root exits the app; from a nested route it pops.

### 4.6 Responsive navigation

| Width | Navigation | Content |
|---|---|---|
| `<600` | Bottom bar with 4 items + center 64dp Scan control | Single column, 16 gutters |
| `600-839` | Bottom bar, wider spacing | Single or two-column grids, 24 gutters, max 720 |
| `840-1199` | Extended NavigationRail 240dp | Master-detail, 32 gutters, max 1120 |
| `>=1200` | Extended rail + optional secondary panel | Max 1120 centered, no stretched cards |

Rules:

- Use `LayoutBuilder` and `MediaQuery.sizeOf`, never hardware-type checks.
- Do not lock orientation. The camera and result screens adapt to landscape.
- Use `GridView` with `SliverGridDelegateWithMaxCrossAxisExtent` for crop, shop, and cooperative grids.
- Use `ListView.builder` for all dynamic lists.
- Constrain forms to 560 and reading content to 720 on wide screens.

---

## 5. Screen specifications

Each screen below lists its job, hierarchy, required states, copy intent, responsive behavior, and analytics. The copy deck holds final strings; the wireframes hold structure.

### 5.1 Splash

**Job:** resolve session and deep-link intent without wasting time.

- Brand lockup, logo, master line. No spinner longer than 800ms.
- Preload cached profile, crops, and last weather.
- Route: valid session and complete profile → `/home`; valid session but incomplete → `/setup/profile`; no session → `/onboarding` on first run, otherwise `/auth`.
- If the deep link is unavailable, continue to the normal destination and show a short, non-blocking message.
- No fake progress. If startup fails, show a retry with a support link.

### 5.2 Onboarding

**Job:** create recognition, relief, and commitment in under a minute.

- Three pages, skippable, no auto-advance.
- Page 1: "Spot trouble before it spreads." Photo of a leaf close-up.
- Page 2: "Know exactly what to do next." Diagnosis plus treatment steps.
- Page 3: "Plan around the weather, not against it." Calendar plus rain.
- Final action: `Get started`; secondary: `I already have an account`.
- Language selector in the top-right, using native language names.
- Real social proof only. If there is no verified proof, omit the slot.
- Analytics: `onboarding_started`, `onboarding_page_viewed`, `onboarding_completed`, `onboarding_skipped`.

### 5.3 Authentication

**Job:** get the farmer in with the least friction and the most trust.

- Primary method depends on configuration:
  - If SMS is configured: `Continue with phone` is primary, OTP is a dedicated step.
  - If SMS is not configured: `Continue with email` is primary, phone is not shown as available.
- Google and Facebook are secondary, with official branding.
- Email sign-up asks only for email and password; profile details move to the wizard.
- Trust row: "Your farm data stays private." Links to Terms and Privacy.
- OTP: 6-digit field, paste support, resend timer, clear rate-limit message.
- Errors are inline at the field. Loading state is per provider; one provider cannot block another.
- After auth, always route through the profile guard.
- Analytics: `auth_started`, `auth_method_selected`, `auth_succeeded`, `auth_failed`, `otp_requested`, `otp_verified`.

### 5.4 Profile wizard

**Job:** personalize without feeling like a form.

- Step 1, About you: full name, mobile number, optional photo.
- Step 2, Your farm: farm name, location search, `Use my location`, optional farm size.
- Step 3, Your crops: searchable crop grid with photos, multi-select, selected count, at least one required.
- Progress indicator and `Step X of 3`. Back is always available. Optional fields can be skipped.
- Explain why: "Your crops shape diagnosis, care, and calendar."
- The wizard can be resumed; save a draft locally.
- End with permission priming, then `Take your first scan` or `Go to my farm`.
- Analytics: `profile_step_completed`, `profile_completed`, `crops_selected`, `location_permission_prompted`, `notification_permission_prompted`.

### 5.5 Permission priming

**Job:** earn the OS permission with context.

- Location: "We use your location for local weather and regional advisories." Options: `Use my location`, `Enter it manually`, `Not now`.
- Notifications: "We'll tell you when a scan is ready or the weather changes your plan." Options: `Turn on advisories`, `Not now`.
- If denied, the app continues with manual location and an in-app Advisories inbox.
- Never block the dashboard on a permission.
- Analytics: `permission_primed`, `permission_granted`, `permission_denied`, `permission_deferred`.

### 5.6 Home - Today's Field Briefing

**Job:** answer "what should I do today?" in one screen.

Hierarchy:

1. Critical Cooperative Advisory banner, if active.
2. Greeting and farm identity.
3. Field Briefing: date, weather, location, one priority action, `Why this?`, `Scan a crop`, `View field calendar`.
4. Crops pulse: horizontal cards with status and next task.
5. Recent diagnoses: last two, with crop, diagnosis, confidence, time, `View health log`.
6. This week's Care Plan: two items with completion.
7. Contextual Partner Offer only when tied to a recent diagnosis; labeled.
8. Offline/stale-data banner when relevant.

Rules:

- The priority action is chosen in this order: critical weather, overdue calendar task, recent at-risk diagnosis, routine care. If none, show a monitoring prompt.
- Never invent a farm health score. Use status based on the latest scan and tasks.
- The scan CTA is always visible above the fold.
- Pull to refresh; skeletons match the final layout.
- Empty farm: "Your field office is ready. Take your first scan to start your crop's health record." with `Scan a crop`.
- Responsive: one column compact; two columns at 600+ with briefing left and actions right; max 1120.
- Analytics: `home_viewed`, `field_briefing_viewed`, `priority_action_opened`, `scan_started_from_home`, `care_plan_opened_from_home`, `partner_offer_viewed`.

### 5.7 Crops

**Job:** see every Main Crop and its current risk at a glance.

- Photo cards with crop name, stage, status, last scan, next task.
- Filters: All, Healthy, Watch, At Risk. Sort by risk or name.
- `Add crops` opens the crop step of the profile wizard or a dedicated manage screen.
- Empty state: "No crops yet. Add your main crops so we can personalize your care." with `Add crops`.
- Tapping a card opens Crop detail.
- Responsive: single-column photo cards compact; two-column grid at 600; master-detail at 840.
- Analytics: `crops_viewed`, `crop_opened`, `crop_filter_changed`, `crops_add_started`.

### 5.8 Crop detail

**Job:** understand one crop and act on it.

- Hero photo, name, stage, status, last scan.
- Growing conditions: temperature range, soil, watering. Use honest data from the crop catalog; show `Not available` rather than inventing.
- Growth timeline: seedling, vegetative, flowering, fruiting, harvest; mark the current stage.
- Care guide: expandable sections for spacing, pests, harvest signs.
- Your scans for this crop: latest two plus `View all`.
- Upcoming tasks: two plus `Open calendar`.
- Primary action: `Scan this crop`. Secondary: `Add a task`.
- Responsive: single column compact; detail right of list at 840.
- Analytics: `crop_detail_viewed`, `crop_scan_started`, `crop_task_added`, `care_guide_opened`.

### 5.9 Scan capture

**Job:** capture a usable image without instruction overload.

- Dark forest camera surface. Reticle with corner brackets and a subtle leaf/bug motif.
- One-line tip at a time: fill the frame with one leaf; avoid shadows; shoot both sides if possible.
- Crop chip shows the selected crop; tap to change.
- Controls: gallery, shutter, flash. A help action explains what makes a good photo.
- Do not claim the AI is already analyzing. Show analysis only after the farmer confirms.
- If camera permission is denied, show a clear explanation and a gallery fallback.
- Responsive: reticle scales; landscape moves controls to the side.
- Analytics: `scan_capture_opened`, `scan_photo_taken`, `scan_gallery_opened`, `scan_crop_changed`, `camera_permission_denied`.

### 5.10 Scan review and analyzing

**Job:** confirm the image and make waiting feel trustworthy.

Review:

- Preview, crop confirmation, `Retake` and `Analyze crop`.
- If the image is blurry or too dark, show a non-blocking quality tip.

Analyzing:

- Thumbnail, reticle animation, staged copy: checking leaf color, looking for spots and pests, preparing next steps.
- No fake percentage. A cancel action is available.
- If offline: "Saved. We'll analyze this when you're back online." Show queue status and a notification promise.
- If the service fails: explain, keep the image, offer `Try again`.
- Analytics: `scan_review_viewed`, `scan_analyze_started`, `scan_analyzed`, `scan_failed`, `scan_cancelled`, `scan_queued_offline`.

### 5.11 Scan result

**Job:** turn a diagnosis into a calm, doable next step.

Hierarchy:

1. Crop photo, crop name, time.
2. Diagnosis name, confidence, severity.
3. Plain-language confidence explanation.
4. What we see: short description and spread risk.
5. What to do next: numbered Treatment Steps.
6. Add to Field Calendar and Set a reminder.
7. Partner Offers only when relevant and confidence is usable.
8. Share and the saved-to-Health-Log confirmation.

Rules:

- High confidence: clear plan.
- Low confidence: `Retake in better light` becomes primary; treatment steps are cautious; no partner offers.
- Healthy: reinforce monitoring and next scan timing; do not invent a problem.
- The result auto-saves to Health Log. The confirmation is a short inline message, not a modal.
- The AI limitation notice is linked, not shouted.
- Share exports a simple image plus summary; no personal data beyond the farm name the farmer chooses.
- Responsive: compact single column; expanded two columns with photo left and plan right, max 720 reading width.
- Analytics: `scan_result_viewed`, `confidence_explained`, `treatment_step_expanded`, `diagnosis_added_to_calendar`, `diagnosis_shared`, `partner_offer_viewed`, `partner_link_opened`, `low_confidence_retake`.

### 5.12 Health Log

**Job:** prove progress and make past scans easy to revisit.

- Season summary with honest counts: scans, healthy, need attention.
- Filters: crop, status, date. Search by diagnosis or crop.
- Grouped by month. Each row: thumbnail, crop, diagnosis, confidence, severity, date.
- Empty state: "No scans yet. Your first diagnosis starts here." with `Scan a crop`.
- Responsive: timeline compact; master-detail at 840.
- Analytics: `health_log_viewed`, `health_log_filtered`, `health_log_search`, `scan_detail_opened`.

### 5.13 Care Plan

**Job:** turn diagnosis, crop stage, and weather into a weekly plan.

- Header: "Your plan for this week", location, weather-aware note.
- Segments: Today, This week, Preventive.
- Items: title, crop, why now (scan, weather, stage), actions.
- Each item can be marked done or added to the Field Calendar.
- Completed items move to a collapsed "Done" section or disappear with an undo toast.
- Partner Offers appear only when tied to an item.
- Empty state: "Your plan will appear after your first scan or when your crops need care."
- Responsive: single column; two columns at 840 for Today/This week.
- Analytics: `care_plan_viewed`, `care_plan_item_completed`, `care_plan_item_scheduled`, `care_plan_partner_offer_viewed`.

### 5.14 Field Calendar

**Job:** keep the season on track with weather-aware timing.

- Header: month/week context, `Today`, view toggle.
- Timeline view default: agenda grouped by day; task card with category, crop, priority, weather badge, completion.
- Month view: grid with status dots; selected day agenda below.
- Task detail: why this date, weather note, related crop/scan, edit/delete.
- Add task sheet: title, category, crop, date/time, reminder, recurrence if supported.
- Completion is explicit. No hidden swipe-only actions.
- Weather-adjusted tasks show the original reason and the new timing.
- Empty state: "No tasks yet. Add your crops to generate a personalized calendar."
- Responsive: agenda compact; month + agenda side-by-side at 840.
- Analytics: `calendar_viewed`, `calendar_view_changed`, `task_opened`, `task_completed`, `task_added`, `task_rescheduled`, `weather_adjusted_task_viewed`.

### 5.15 Advisories

**Job:** one trustworthy inbox for crop, weather, and cooperative messages.

- Filters: All, Crop, Weather, Cooperative.
- Unread dot, `Mark all read`, pull to refresh.
- Critical Advisory pinned above the list with a clear severity label.
- Item: title, message preview, source, time, severity. Tap opens the related scan, crop, task, or advisory detail.
- Empty state: "No advisories yet. We'll tell you when something needs attention."
- Push notifications deep-link into this inbox or the related record.
- Responsive: list compact; list + detail at 840.
- Analytics: `advisories_viewed`, `advisory_filtered`, `advisory_opened`, `advisory_marked_read`, `critical_advisory_opened`.

### 5.16 Agri Shop

**Job:** make the next step practical without turning care into an ad.

- Search and categories: All, Organic, Fungicide, Fertilizer, Pest control.
- Product card: image, name, merchant, price, `Partner offer` label.
- Product detail: why it matches, application guidance, merchant, price, `Go to merchant`.
- Outbound link shows a confirmation sheet with the Partner Disclosure, then opens the merchant.
- No sponsored ranking without a visible label. Default sort is relevance, then price.
- Safety copy: follow the product label; consult an extension officer when unsure.
- Empty state: "No matching products for this diagnosis. Your care plan still works without them."
- Responsive: two-column grid at 600, three at 1200.
- Analytics: `shop_viewed`, `shop_search`, `shop_filter_changed`, `shop_product_viewed`, `partner_link_opened`, `partner_disclosure_viewed`.

### 5.17 Agri Pro

**Job:** offer more capacity at a moment of demonstrated value.

- Headline: "Protect more of what you grow."
- Free plan summary: 5 scans/week, basic calendar.
- Agri Pro: unlimited scans, priority analysis, health trends, weather-adjusted reminders, offline pack.
- Plans: Monthly and Seasonal (6 months). Seasonal is anchored to one crop season. Prices approved 2026-11-13: ₱99/month and ₱499/6 months (~16% saved, pre-selected); VAT-inclusive; billed by Google Play or the App Store. No founding offer at launch. Renewal and cancellation remain plain, honest terms with no pre-checked auto-renew.
- Primary: `Start Agri Pro`. Secondary: `Not now`.
- Show renewal and cancellation terms plainly. No pre-checked auto-renew.
- Trigger moments: after a successful diagnosis, at the weekly quota, and from Profile. Never interrupt the scan result before the farmer sees the diagnosis.
- Manage plan: status, renewal date, billing, cancel.
- Analytics: `paywall_viewed`, `paywall_plan_selected`, `purchase_started`, `purchase_completed`, `paywall_dismissed`, `manage_plan_viewed`.

### 5.18 Profile and settings

**Job:** give the farmer control and a clear view of their account.

- Header: avatar, name, farm, location, `Edit profile`.
- Grouped list: Farm details, Main crops, Language, Notifications.
- Plan and community: Agri Pro, Cooperative Hub.
- Trust: Privacy and data, Help and support, About.
- Destructive: Sign out, with confirmation.
- Language sheet: English, Tagalog, Cebuano with native names. Apply immediately.
- Notification preferences: scan results, weather advisories, calendar reminders, cooperative advisories; quiet hours.
- Privacy: data export/delete where supported, AI limitation notice, image usage.
- About: version, Agri Lynk parent brand, licenses.
- Responsive: single list; two-column grouped settings at 840.
- Analytics: `profile_viewed`, `profile_edited`, `language_changed`, `notification_preferences_changed`, `privacy_opened`, `sign_out`.

### 5.19 Cooperative Hub

**Job:** coordinate regional care without exposing individual farms.

Member view:

- Cooperative name, region, member since, extension officer contact.
- Latest Cooperative Advisories, critical first.
- Invite a farmer via a shareable code.
- No access to other members' individual data.

Administrator and Extension Officer view:

- Overview: regional snapshot based on the last 30 days, number of scans used as the basis, disease counts, affected farmer counts, average confidence, trend chart, regional map/heatmap if data supports it.
- Members: searchable roster with join date, last scan, risk status. No diagnosis images without explicit consent.
- Advisories: list of broadcasts; composer with title, severity, target crops/region, message, preview, send confirmation.
- Role guard prevents access for regular members.
- Privacy: only aggregated data; minimum cohort size before showing a metric.

Responsive:

- Member view single column.
- Admin view stat tiles compact; two-column at 600; chart + table at 840.

Analytics: `cooperative_viewed`, `cooperative_joined`, `invite_shared`, `outbreak_viewed`, `member_roster_viewed`, `broadcast_started`, `broadcast_sent`, `broadcast_failed`.

### 5.20 Global state patterns

| State | Pattern |
|---|---|
| Loading | Skeletons that match the final layout; no full-screen spinner for cached content |
| Empty | Illustration, one-sentence explanation, one primary action |
| Error | What happened, `Try again`, support link; preserve user input |
| Offline | Banner with last-updated time; cached content remains readable |
| Queued | Clear queue status and a promise to notify |
| Success | Inline confirmation or short toast; no blocking modal |
| Permission denied | Explain the fallback; never dead-end |

Every screen must define these states before implementation. A screen without an empty state and an error state is not ready.

---

## 6. Responsive and adaptive behavior

### Breakpoints

| Name | Width | Behavior |
|---|---|---|
| Compact | `<600` | Bottom bar, single column, 16 gutters, full-height sheets |
| Medium | `600-839` | Bottom bar, two-column grids, 24 gutters, max 720 |
| Expanded | `840-1199` | NavigationRail 240dp, master-detail, 32 gutters, max 1120 |
| Large | `>=1200` | Extended rail, centered max 1120, optional secondary panel |

### Screen adaptation

| Screen | Compact | Expanded |
|---|---|---|
| Home | One column, briefing first | Briefing left, crops/actions right |
| Crops | Photo cards | List + detail |
| Crop detail | One column | Detail right of crop list |
| Scan | Full-screen reticle | Reticle centered, controls at side |
| Result | One column | Photo left, plan right |
| Health Log | Timeline | Timeline + scan detail |
| Calendar | Agenda, month toggle | Month + agenda |
| Advisories | List | List + detail |
| Agri Shop | One column | Two/three-column grid |
| Cooperative | Cards | Stat grid + chart/table |
| Profile | Grouped list | Two-column groups |

### Implementation rules

- `LayoutBuilder` for parent-space decisions; `MediaQuery.sizeOf` for app-window measurements.
- No `OrientationBuilder` near the root. No device-type checks.
- Unlock orientation. Test landscape on the camera and result screens.
- Use `Expanded`/`Flexible` for distribution, not fixed widths that break text scale.
- Constrain content; never stretch a form across a desktop window.
- Use lazy builders for every dynamic list.
- Support mouse, trackpad, and keyboard focus on web/desktop.

---

## 7. Accessibility

Target: WCAG 2.2 AA.

- Contrast 4.5:1 for text, 3:1 for large text and UI boundaries.
- Touch targets at least 48dp; 8dp separation.
- Dynamic type to 200% without clipping or overlap. Test at 320x568 and 390x844.
- Screen-reader labels for every icon-only action. Announce scan progress, diagnosis severity, and task completion.
- Focus order follows visual order. Visible focus ring in Leaf.
- Status never relies on color alone.
- Reduced motion replaces scan animation and result reveal.
- Camera and image-heavy screens provide text alternatives and error recovery.
- Forms use persistent labels, not placeholder-only labels.
- Errors are announced and tied to the field.
- Language is set at the app level so screen readers use the correct voice.
- Test with TalkBack and VoiceOver on the primary flow.

---

## 8. Offline and reliability

### Scan queue

1. Farmer captures a photo.
2. If offline, save the image locally and create a queued Scan.
3. Show `Saved. We'll analyze this when you're back online.` with a queue badge.
4. When connectivity returns, upload with exponential backoff.
5. On success, create the Scan Result and an Advisory; notify the farmer.
6. On permanent failure, keep the image and offer retry or delete.
7. Never silently drop a Scan.

### Cached surfaces

- Home briefing, crop list, crop detail, calendar, advisories, and last weather are readable offline.
- Every cached surface shows a last-updated time.
- Mutations that can wait are queued; destructive actions require connectivity.
- Conflict rule: server wins for shared records; local draft wins only for unsaved profile edits.
- Image cache is bounded; clean up after successful upload or a retention window.

### Performance floor

- Baseline: Android 8+, 2GB RAM, 720p.
- Cold start target under 3 seconds on the baseline device.
- Image upload compressed to ~1600px long edge, JPEG 80.
- Lists lazy; images cached; fonts subset; no heavy blur; no continuous animation.
- Test scroll performance and memory on the baseline device, not only on a flagship.

---

## 9. Localization and content

### Languages

- English, Tagalog, and Cebuano at launch.
- English is the fallback.
- Human review by native speakers is required; no unreviewed machine translation.
- Architecture supports Ilocano, Hiligaynon, and Bicolano later.

### Content rules

- All strings come from ARB files. No hardcoded user-facing text.
- Dates, numbers, decimals, and currency use locale-aware formatters.
- Keep sentences short for translation. Avoid idioms that do not translate.
- Use the same term as the glossary. "Care Plan", not "Recommendations".
- Technical terms such as "AI" and "confidence" get plain-language explanations in each language.
- Preserve placeholders and plural rules; translators receive screenshots and context.
- Test long translations at 200% text scale.

### Copy deck

The EN/TL/CEB strings, tone guidance, and review status live in [UI_COPY_DECK.md](UI_COPY_DECK.md).

---

## 10. Analytics and measurement

### North star

Protected actions per active farmer per week: completed scans plus completed care or calendar tasks.

### Funnel

| Stage | Definition | Target to set after baseline |
|---|---|---|
| Activation | First Scan within 24 hours of signup | Baseline in Phase 1 |
| Aha | Scan Result viewed plus one next action within 48 hours | Baseline in Phase 1 |
| Habit | 2+ Scans and 1+ calendar task per week by week 4 | Baseline in Phase 1 |
| Trust | Advisory open rate and low paywall-dismissal churn | Baseline in Phase 2 |
| Monetization | Paywall view → start → purchase | Baseline in Phase 2 |
| Cooperative | Invite acceptance and broadcast open rate | Baseline in Phase 3 |

### Event naming

Use `object_action` in snake case. Every event includes: `language`, `tier`, `source_screen`, and `app_version`. Add `crop`, `disease`, `confidence_bucket`, or `severity` only when relevant. Never send names, phone numbers, images, or precise coordinates.

Events are listed per screen in section 5. The canonical list:

```text
onboarding_started, onboarding_page_viewed, onboarding_completed, onboarding_skipped
auth_started, auth_method_selected, auth_succeeded, auth_failed, otp_requested, otp_verified
profile_step_completed, profile_completed, crops_selected
permission_primed, permission_granted, permission_denied, permission_deferred
home_viewed, field_briefing_viewed, priority_action_opened, scan_started_from_home
crops_viewed, crop_opened, crop_filter_changed, crops_add_started
crop_detail_viewed, crop_scan_started, crop_task_added, care_guide_opened
scan_capture_opened, scan_photo_taken, scan_gallery_opened, scan_crop_changed, camera_permission_denied
scan_review_viewed, scan_analyze_started, scan_analyzed, scan_failed, scan_cancelled, scan_queued_offline
scan_result_viewed, confidence_explained, treatment_step_expanded, diagnosis_added_to_calendar
diagnosis_shared, low_confidence_retake, partner_offer_viewed, partner_link_opened
health_log_viewed, health_log_filtered, health_log_search, scan_detail_opened
care_plan_viewed, care_plan_item_completed, care_plan_item_scheduled
calendar_viewed, calendar_view_changed, task_opened, task_completed, task_added, task_rescheduled
advisories_viewed, advisory_filtered, advisory_opened, advisory_marked_read, critical_advisory_opened
shop_viewed, shop_search, shop_filter_changed, shop_product_viewed, partner_disclosure_viewed
paywall_viewed, paywall_plan_selected, purchase_started, purchase_completed, paywall_dismissed, manage_plan_viewed
cooperative_viewed, cooperative_joined, invite_shared, outbreak_viewed
member_roster_viewed, broadcast_started, broadcast_sent, broadcast_failed
profile_viewed, profile_edited, language_changed, notification_preferences_changed, privacy_opened, sign_out
```

### Privacy

- Analytics is opt-in where required; never block core use.
- No PII, no image contents, no precise location.
- Use coarse region for cooperative analytics.
- Document retention and deletion.

---

## 11. Assets and licensing

- Commission or license Philippine farm and crop photography with model/property releases where needed.
- Build a crop image library with consistent 4:3 crops; record source and license per image.
- Custom illustrations and the scan HUD are original work for Agri Lynk.
- Fraunces and Public Sans are OFL; bundle and subset them.
- Store image credits in `PROJECT_KNOWLEDGE/ASSETS.md` when assets are added.
- Never use a stock photo that implies a real farmer testimonial.

---

## 12. Backend and UI dependencies

These must be resolved before the related UI can be complete:

| Dependency | Why the UI needs it |
|---|---|
| `profiles`: avatar, farm size, language, notification preferences | Profile, language, permissions |
| `crops`: image URL, care guide, growth stages | Crops and Crop detail |
| `scan_history`: severity/status and structured diagnosis | Scan Result, Health Log |
| `notifications`: source/type/deep-link; unify personal, weather, cooperative | Advisories and deep links |
| `cooperative_admins`: invite code | Cooperative join |
| `broadcast_advisories`: target crops/region, read receipts | Cooperative advisories and admin |
| `user_subscriptions`: plan, status, renewal, billing provider | Agri Pro |
| `merchant_products`: partner disclosure and availability | Agri Shop |
| Storage buckets with signed URLs and cleanup | Scan images, avatars |
| Deep-link domain + Android intent filters / iOS associated domains | Advisories and result links |
| SMS provider | Phone OTP |
| Analytics destination and retention | Measurement |

Schema changes require their own migration and RLS review. Do not shape the UI around a field that does not exist; add the field deliberately or hide the feature.

---

## 13. Implementation mapping

### Target structure

```text
lib/
├─ app/
│  ├─ app.dart
│  ├─ router/
│  │  ├─ app_router.dart
│  │  ├─ routes.dart
│  │  ├─ guards.dart
│  │  └─ deep_links.dart
│  ├─ theme/
│  │  ├─ app_colors.dart
│  │  ├─ app_typography.dart
│  │  ├─ app_spacing.dart
│  │  ├─ app_radii.dart
│  │  ├─ app_motion.dart
│  │  └─ app_theme.dart
│  └─ l10n/
│     ├─ app_en.arb
│     ├─ app_tl.arb
│     └─ app_ceb.arb
├─ core/
│  ├─ widgets/
│  ├─ analytics/
│  ├─ offline/
│  └─ utils/
├─ features/
│  ├─ auth/
│  ├─ onboarding/
│  ├─ home/
│  ├─ crops/
│  ├─ scan/
│  ├─ health_log/
│  ├─ care_plan/
│  ├─ calendar/
│  ├─ advisories/
│  ├─ shop/
│  ├─ pro/
│  ├─ cooperative/
│  └─ profile/
├─ models/
└─ services/
```

Migration rule: move one feature at a time behind the new router. Keep the existing service layer until a feature is migrated, then replace screen-local state with feature-scoped providers. Do not rewrite all screens in one commit.

### Phase 1 build order

1. Theme tokens, fonts, `AppTheme`, core typography.
2. Router shell, guards, deep-link placeholders, 5-destination navigation.
3. Localization scaffolding and language switching.
4. Onboarding, auth, profile wizard, permission priming.
5. Home Field Briefing.
6. Crops and Crop detail.
7. Scan capture, review, analyzing, result.
8. Field Calendar.
9. Advisories inbox.
10. Care Plan.
11. Health Log.
12. Profile and settings.
13. Offline queue, cached surfaces, global states.
14. Widget, golden, router, localization, and accessibility tests.

### Phase 2-3

- Phase 2: Agri Pro, Agri Shop, FCM/push, analytics, tablet/desktop polish.
- Phase 3: Cooperative member/admin, invite codes, outbreak summary, broadcasts.

---

## 14. Test strategy and seams

TDD applies in vertical slices. No test is written at an unconfirmed seam. The following seams are proposed for Phase 1 and must be confirmed before implementation:

| Seam | Behavior it specifies | Catches | Misses |
|---|---|---|---|
| Auth and route guard | Resolve destination from session, profile completeness, and role | Wrong redirects, deep-link loss, role leaks | Visual polish |
| Scan quota policy | `canPerformScan(tier, scansUsedThisWeek)` | Off-by-one quota, free-tier regressions | Server-side quota race |
| Diagnosis presenter | Map raw diagnosis to severity, confidence bucket, and next-step set | Inconsistent severity, low-confidence handling | Model accuracy |
| Sync queue state machine | enqueue, upload, analyze, retry, fail, delete | Lost scans, duplicate uploads, stuck queues | Network provider behavior |
| Calendar weather adjustment | Apply weather rules to water tasks and preserve reason | Wrong postponement, lost original date | Weather API accuracy |
| Localization lookup | Locale fallback, placeholder preservation, language persistence | Missing strings, broken interpolation | Translation quality |
| Advisories routing | Map advisory source to the correct deep-link destination | Dead links, wrong record opened | Push provider delivery |

Widget seams to confirm after the logic seams:

- Home Field Briefing renders the correct priority action for a given state.
- Scan Result shows the low-confidence path and hides partner offers.
- Crop detail (`CropDetailScreen`) shows honest catalog growing conditions (`Not available` when absent), only this crop's latest scans and upcoming tasks, and `Scan this crop` as the primary action.
- Agri Pro paywall shows the quota context and honest plan terms.
- Cooperative broadcast composer validates required fields and role access.

Validation for Phase 0:

- Documentation links resolve.
- `tokens.json` parses.
- Glossary terms match the blueprint and copy deck.
- No screen spec omits loading, empty, error, and offline states.

---

## 15. Release criteria

A screen is release-ready only when:

- It matches section 5 and uses tokens only.
- It has loading, empty, error, offline, and success states.
- It works at 320, 390, 768, and 1280 widths.
- It passes the 200% text-scale check and TalkBack/VoiceOver pass.
- Its analytics events match section 10.
- Its copy is in the EN/TL/CEB deck and reviewed.
- It has no fake urgency, hidden fees, or unlabeled partner content.
- Its tests pass at the confirmed seams.

---

## 16. Open items

1. Confirm Phone OTP as primary only when the SMS provider is live; otherwise email is primary.
2. Agri Pro prices approved 2026-11-13 (₱99/month, ₱499/6 months, ~16% saved, pre-selected). Billing provider: Google Play / App Store in-app subscriptions; the app ships with billing behind config (an honest "not configured yet" path until the store products are live).
3. Confirm logo retention and variant approval with the brand owner.
4. Confirm Phase 1 test seams before writing tests.
5. Confirm photography budget, licensing, and farmer consent process.
6. Confirm the deep-link domain and universal-link setup.
