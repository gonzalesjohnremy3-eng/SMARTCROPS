# CropCare --- Mobile UI Design System

> **Purpose:** A reusable visual and interaction reference for CropCare,
> an AI-assisted crop-scanning and plant-health application.\
> **Platform target:** Android mobile, with implementation adaptable to
> Flutter or native Android.\
> **Design direction:** Premium, calm, botanical, practical, and easy to
> use in the field.

------------------------------------------------------------------------

## 1. Design principles

1.  **Function first.** Make crop scanning and understanding a diagnosis
    the clearest actions.
2.  **Nature-led, not rustic.** Use botanical colors and imagery with a
    clean, contemporary interface.
3.  **Warm, readable surfaces.** Use a soft ivory foundation rather than
    pure white across large areas.
4.  **Strong action hierarchy.** Reserve amber for the most important
    action and selected navigation state.
5.  **Consistent components.** Reuse the same spacing, radii,
    typography, borders, and interaction states across screens.
6.  **Decoration stays quiet.** Botanical motifs, gradients, and shadows
    should support hierarchy, never compete with content.
7.  **Accessible diagnosis.** Never communicate crop health through
    color alone; pair status colors with labels and icons.

------------------------------------------------------------------------

## 2. Core color tokens

The reference uses a warm ivory, deep botanical green, and harvest amber
palette.

  ------------------------------------------------------------------------
  Token                    HEX                     Intended use
  ------------------------ ----------------------- -----------------------
  `color.background`       `#F5F3E9`               Main app background

  `color.surface`          `#FBF9F1`               Cards and raised
                                                   content surfaces

  `color.surface.subtle`   `#EEEBDD`               Secondary panels and
                                                   quiet containers

  `color.primary`          `#234B38`               Brand green,
                                                   navigation, primary
                                                   text on light surfaces

  `color.primary.dark`     `#173526`               Deep green gradients
                                                   and pressed/darker
                                                   surfaces

  `color.primary.soft`     `#DCE6D8`               Soft green surface,
                                                   subtle selection

  `color.accent`           `#E6AD45`               Main scan action and
                                                   selected navigation

  `color.accent.dark`      `#B77B1F`               Amber pressed state or
                                                   darker accent details

  `color.text.primary`     `#1C2D23`               Main text on light
                                                   backgrounds

  `color.text.secondary`   `#526257`               Supporting text

  `color.text.inverse`     `#FBF9F1`               Text on deep green

  `color.border`           `#DEDCCF`               Subtle borders and
                                                   dividers

  `color.icon.muted`       `#657568`               Secondary icons
  ------------------------------------------------------------------------

### Semantic status colors

Keep diagnostic colors separate from the brand palette. They describe
the result, not the brand.

  -----------------------------------------------------------------------------
  Token                         HEX                     Meaning
  ----------------------------- ----------------------- -----------------------
  `status.healthy`              `#347747`               Healthy / no visible
                                                        issue detected

  `status.healthy.surface`      `#E5F1E5`               Healthy status
                                                        background

  `status.warning`              `#A96A12`               Possible symptoms /
                                                        needs attention

  `status.warning.surface`      `#FFF0D5`               Warning status
                                                        background

  `status.critical`             `#BD4942`               Disease detected /
                                                        urgent attention

  `status.critical.surface`     `#FBE8E5`               Critical status
                                                        background

  `status.processing`           `#60758D`               Image analysis in
                                                        progress

  `status.processing.surface`   `#E9EDF2`               Processing status
                                                        background
  -----------------------------------------------------------------------------

**Usage rules** - Use `color.primary` for brand identity, important
headings, and navigation surfaces. - Use `color.accent` sparingly. The
"Scan Your Crop" action is the clearest amber use case. - Use semantic
colors only for health states, diagnosis feedback, and related
indicators. - Pair every status color with a text label and a
recognizable icon. - Check text contrast in the implementation,
especially amber-on-ivory and green-on-green combinations. Do not use
accent colors for long body text.

------------------------------------------------------------------------

## 3. Color distribution

The visual balance is based on the 60/30/10 principle:

-   **60% --- Ivory:** large backgrounds, open space, and most content
    surfaces.
-   **30% --- Deep green:** navigation, brand elements, important
    headings, and selected dark panels.
-   **10% --- Amber:** primary scan action, selected tab, and small
    attention accents.

This is a visual guideline, not a strict pixel-count requirement.
Diagnostic status colors are semantic exceptions and should appear only
where needed.

------------------------------------------------------------------------

## 4. Typography

Use a clean, highly legible sans-serif family. For Android, **Roboto**
is a reliable default; **Inter** is a suitable alternative if bundled
consistently.

  -------------------------------------------------------------------------------
  Token                       Suggested size               Weight Usage
  --------------------- -------------------- -------------------- ---------------
  `type.display`                    30--34sp           Bold / 700 Greeting or one
                                                                  key screen
                                                                  title

  `type.title.large`                    24sp       Semibold / 600 Main section or
                                                                  screen title

  `type.title.medium`                   20sp       Semibold / 600 Card and
                                                                  section
                                                                  headings

  `type.title.small`                16--18sp       Semibold / 600 Component
                                                                  headings

  `type.body.large`                     16sp        Regular / 400 Primary body
                                                                  copy

  `type.body`                           14sp        Regular / 400 Supporting
                                                                  descriptions

  `type.label`                      13--14sp         Medium / 500 Buttons, tabs,
                                                                  labels

  `type.caption`                        12sp        Regular / 400 Metadata and
                                                                  helper text
  -------------------------------------------------------------------------------

**Typography rules** - Use sentence case for labels and headings. - Keep
body copy short and scannable. - Avoid using too many font weights;
regular, medium, semibold, and bold are sufficient. - Use a comfortable
line height: approximately 1.35--1.5 times the font size for body
text. - Do not rely on font size alone to communicate hierarchy; use
spacing, weight, and contrast too.

------------------------------------------------------------------------

## 5. Spacing and layout tokens

Use a consistent 4dp base grid.

  Token          Value Typical use
  ------------ ------- ------------------------------------------
  `space.1`        4dp Icon-to-label micro gap
  `space.2`        8dp Tight component spacing
  `space.3`       12dp Compact card content
  `space.4`       16dp Standard component padding
  `space.5`       20dp Section internal spacing
  `space.6`       24dp Screen horizontal padding / section gaps
  `space.8`       32dp Large section separation
  `space.10`      40dp Major layout separation
  `space.12`      48dp Large visual breathing room

**Layout guidance** - Use 20--24dp horizontal screen padding as a
starting point. - Keep a consistent left alignment for section titles,
cards, and content. - Use 16--20dp between related components and
24--32dp between major sections. - Respect Android system status and
navigation bar insets. - Make the primary action easy to reach and large
enough for comfortable tapping. - Allow content to scroll behind neither
the system bars nor the bottom navigation.

------------------------------------------------------------------------

## 6. Shape, border, and elevation tokens

  Token               Value Usage
  ----------------- ------- ---------------------------------------
  `radius.small`       10dp Small badges and compact controls
  `radius.medium`      16dp Buttons and small cards
  `radius.large`       20dp Main cards and image containers
  `radius.xlarge`      28dp Large feature panels
  `radius.pill`       999dp Circular or pill-shaped controls only
  `border.subtle`       1dp Card outlines and separators

### Shadow guidance

Use soft, low-opacity shadows rather than strong floating effects.

-   **Card:** `0 4dp 14dp rgba(35, 75, 56, 0.08)`
-   **Raised action:** `0 5dp 12dp rgba(35, 75, 56, 0.14)`
-   **Avoid:** multiple stacked shadows, dark hard edges, or glow
    effects around ordinary controls.

Use borders and surface contrast before adding elevation. Not every card
needs a shadow.

------------------------------------------------------------------------

## 7. Background and overlay system

The reference background is primarily a warm ivory surface with
restrained botanical decoration.

### Layer stack

1.  **Base:** `#F5F3E9`.
2.  **Soft tonal gradient:** a very subtle shift between ivory and a
    slightly lighter cream.
3.  **Botanical motif:** a leaf silhouette positioned near an edge or
    corner, never behind important text.
4.  **Ambient light:** a low-opacity radial highlight to create gentle
    depth.
5.  **Content surfaces:** opaque or near-opaque cards for readable
    information.

### Example CSS

``` css
:root {
  --color-background: #F5F3E9;
  --color-surface: #FBF9F1;
  --color-primary: #234B38;
  --color-primary-dark: #173526;
  --color-accent: #E6AD45;
}

.app-background {
  position: relative;
  min-height: 100%;
  overflow: hidden;
  background:
    radial-gradient(
      ellipse at 92% 8%,
      rgba(196, 207, 160, 0.18),
      transparent 36%
    ),
    linear-gradient(
      145deg,
      #FBF9F1 0%,
      #F5F3E9 58%,
      #F0EEDF 100%
    );
}

.botanical-decoration {
  position: absolute;
  top: 0;
  right: 0;
  width: 42%;
  opacity: 0.10;
  pointer-events: none;
  /* Use a simple, custom leaf SVG as the background image. */
}

.green-panel {
  color: #FBF9F1;
  background: linear-gradient(
    145deg,
    #234B38 0%,
    #173526 100%
  );
}
```

### Background rules

-   Keep decorative leaf opacity around 6--12% as a starting point.
-   Use botanical motifs near edges, not behind dense content.
-   Reserve stronger blur for image or camera contexts; ordinary cards
    should remain crisp.
-   Avoid applying glassmorphism to every surface.
-   Use translucent surfaces only when the content behind them remains
    visually quiet.
-   Do not place decorative overlays above buttons, text, or interactive
    controls.

------------------------------------------------------------------------

## 8. Component patterns

### 8.1 App header

**Structure** - Brand mark and app name aligned left. - Optional short
tagline below the name. - Notification or profile action aligned
right. - Consistent horizontal padding and vertical alignment.

**Guidelines** - Use a compact header; do not let branding consume too
much vertical space. - Use a 40--48dp icon/action touch target. -
Notification dot should be small and only shown when needed.

### 8.2 Greeting block

**Structure** - Short greeting or screen heading. - One-line supporting
message. - Optional botanical decoration aligned to the far edge.

**Guidelines** - Use one clear heading and one supporting sentence. -
Keep decoration behind empty space. - Avoid oversized headings that push
the primary action below the fold.

### 8.3 Feature / scan banner

**Structure** - Wide crop or leaf photograph. - Subtle dark scrim at the
bottom if text overlays the image. - Short functional message. -
Optional trailing arrow or affordance.

**Guidelines** - Use real crop imagery with a consistent crop ratio. -
Keep overlaid text readable with a dark scrim, not a heavy gradient. -
The banner can introduce scanning, but the primary scan button should
remain independently obvious.

### 8.4 Primary action button

**Purpose:** Start crop scanning.

-   Background: `color.accent` (`#E6AD45`).
-   Foreground: `color.text.primary` (`#1C2D23`).
-   Height: 56--60dp.
-   Radius: 16--20dp.
-   Leading scan icon and concise label.
-   Full width where it is the main screen action.

**States** - Default: amber background. - Pressed: darker amber
(`color.accent.dark`). - Disabled: muted neutral surface and
reduced-contrast text, while retaining readable contrast. - Loading:
show progress and a clear label such as "Opening camera...".

Do not use the amber button for every action on the screen.

### 8.5 Secondary and outline buttons

-   Secondary filled button: deep green background with ivory text.
-   Outline button: transparent or surface background with a 1dp
    green/neutral border.
-   Use for actions such as "View Guide," "See Details," or "Scan
    Again."
-   Keep button heights consistent with the primary button when they
    share a row.

### 8.6 Quick-access tiles

**Structure** - Simple line or solid icon. - Short label. - Surface
background with subtle border or shadow.

**Guidelines** - Use a consistent icon family and stroke weight. - Keep
tile sizes equal within a row. - Use 12--16dp internal spacing. - Avoid
excessive gradients or decorative illustrations inside small tiles.

### 8.7 Health summary panel

**Structure** - Deep green panel. - Optional small crop/seedling image
or simple plant icon. - Short label and clear status. - Supporting
description. - Optional secondary action.

**Guidelines** - Keep the panel informational, not overloaded with
statistics. - Use a semantic status label and icon. - Maintain
sufficient contrast for ivory text on green.

### 8.8 Tip / article card

**Structure** - Small crop or farming image. - Short title. - One or two
lines of supporting text. - Optional trailing arrow.

**Guidelines** - Keep image dimensions consistent across repeated
cards. - Use a fixed image ratio, such as 4:3 or 1:1, depending on the
layout. - Use a neutral surface and subtle border.

### 8.9 Bottom navigation

**Items:** Home, Scan, History, Profile.

**Guidelines** - Use four destinations at most for the primary
navigation. - Use consistent icons and labels. - Selected item: amber
icon and label. - Unselected items: ivory or muted neutral on a deep
green navigation surface. - Keep the navigation height and system inset
handling consistent. - Ensure every destination has a clear selected
state and accessible label.

------------------------------------------------------------------------

## 9. Iconography

-   Use one coherent icon set throughout the app (for example, Material
    Symbols or another consistent outline icon family).
-   Prefer simple, recognizable icons for scan, history, crop guide,
    support, settings, home, and profile.
-   Use consistent optical size, stroke weight, and alignment.
-   Do not mix filled, outlined, and hand-drawn styles without a
    deliberate system.
-   Do not use emoji as interface icons.
-   Provide accessible labels for icon-only buttons.

Suggested baseline sizes: - Navigation icons: 24dp. - Standard action
icons: 20--24dp. - Small inline icons: 16--18dp. - Icon-only touch
target: at least 48dp.

------------------------------------------------------------------------

## 10. Imagery guidelines

-   Prioritize authentic crop, leaf, soil, and field photography.
-   Use clear, close-up images that support the task.
-   Keep image treatments natural; avoid oversaturation and artificial
    glow.
-   Use rounded image containers consistently.
-   For diagnosis screens, show the actual scanned image prominently and
    avoid replacing it with unrelated stock photography.
-   Provide a neutral placeholder when an image is unavailable.

------------------------------------------------------------------------

## 11. Interaction and feedback patterns

### Scan flow

1.  User taps **Scan Your Crop**.
2.  App opens camera permission/capture flow.
3.  Camera view displays a clear framing guide and capture control.
4.  User captures or selects a crop image.
5.  App displays an analysis state.
6.  App presents the result with status, confidence information (if
    validated), explanation, and next steps.

### Feedback rules

-   Show a visible pressed state for tappable controls.
-   Use loading indicators for actions that take time.
-   Confirm successful saves or completed scans with concise feedback.
-   Explain permission requirements when camera access is unavailable.
-   Provide retry and gallery-selection paths when capture or analysis
    fails.
-   Never show a disease diagnosis as certain if the model result is
    uncertain.

### Diagnosis result structure

1.  Status label and semantic icon.
2.  Scanned crop image.
3.  Detected condition or "No visible issue detected."
4.  Short explanation and uncertainty note where appropriate.
5.  Confidence information, only if the model score is calibrated and
    explained.
6.  Recommended next steps.
7.  Actions such as **Scan Again** and **View Crop Guide**.

------------------------------------------------------------------------

## 12. Accessibility and usability

-   Maintain readable contrast for all text and controls.
-   Do not communicate healthy, warning, or critical status by color
    alone.
-   Use labels and icons alongside status colors.
-   Support Android font scaling and longer translated labels.
-   Ensure touch targets are approximately 48dp or larger.
-   Keep important actions reachable and visually distinct.
-   Avoid small text for critical diagnosis information.
-   Provide meaningful content descriptions for images and icon-only
    controls.
-   Test the interface in bright outdoor conditions, since users may use
    the app in the field.

------------------------------------------------------------------------

## 13. Suggested screen structure

``` text
App
├── Home
│   ├── AppHeader
│   ├── GreetingBlock
│   ├── ScanFeatureBanner
│   ├── PrimaryScanButton
│   ├── QuickAccessSection
│   │   └── QuickAccessTile × N
│   ├── CropHealthSummary
│   ├── FarmingTipCard
│   └── BottomNavigation
│
├── Scanner
│   ├── ScannerTopBar
│   ├── CameraPreview
│   ├── ScanFrameOverlay
│   ├── CaptureControls
│   └── GalleryAction
│
├── Diagnosis
│   ├── ResultTopBar
│   ├── DiagnosisStatus
│   ├── ScannedImage
│   ├── DiagnosisDetails
│   ├── ConfidencePanel (when appropriate)
│   ├── RecommendedAction
│   └── ResultActions
│
├── History
│   ├── AppHeader
│   ├── SearchAndFilter
│   └── ScanHistoryList
│
└── Profile
    ├── ProfileHeader
    ├── FarmSummary
    ├── SettingsList
    └── BottomNavigation
```

------------------------------------------------------------------------

## 14. Suggested design-token starter file

The following CSS custom properties can be used as a web reference or
translated into Flutter `ThemeData`, Android resources, or another token
format.

``` css
:root {
  /* Colors */
  --cc-background: #F5F3E9;
  --cc-surface: #FBF9F1;
  --cc-surface-subtle: #EEEBDD;
  --cc-primary: #234B38;
  --cc-primary-dark: #173526;
  --cc-primary-soft: #DCE6D8;
  --cc-accent: #E6AD45;
  --cc-accent-dark: #B77B1F;

  --cc-text-primary: #1C2D23;
  --cc-text-secondary: #526257;
  --cc-text-inverse: #FBF9F1;
  --cc-border: #DEDCCF;

  /* Semantic colors */
  --cc-healthy: #347747;
  --cc-healthy-surface: #E5F1E5;
  --cc-warning: #A96A12;
  --cc-warning-surface: #FFF0D5;
  --cc-critical: #BD4942;
  --cc-critical-surface: #FBE8E5;
  --cc-processing: #60758D;
  --cc-processing-surface: #E9EDF2;

  /* Spacing */
  --cc-space-1: 4px;
  --cc-space-2: 8px;
  --cc-space-3: 12px;
  --cc-space-4: 16px;
  --cc-space-5: 20px;
  --cc-space-6: 24px;
  --cc-space-8: 32px;
  --cc-space-10: 40px;
  --cc-space-12: 48px;

  /* Radius */
  --cc-radius-sm: 10px;
  --cc-radius-md: 16px;
  --cc-radius-lg: 20px;
  --cc-radius-xl: 28px;
  --cc-radius-pill: 999px;

  /* Borders and elevation */
  --cc-border-width: 1px;
  --cc-shadow-card: 0 4px 14px rgba(35, 75, 56, 0.08);
  --cc-shadow-raised: 0 5px 12px rgba(35, 75, 56, 0.14);

  /* Typography */
  --cc-font-family: "Roboto", sans-serif;
  --cc-text-display: 34px;
  --cc-text-title-lg: 24px;
  --cc-text-title-md: 20px;
  --cc-text-title-sm: 18px;
  --cc-text-body-lg: 16px;
  --cc-text-body: 14px;
  --cc-text-label: 14px;
  --cc-text-caption: 12px;
}
```

------------------------------------------------------------------------

## 15. Flutter implementation mapping

Suggested mapping from these design tokens to Flutter:

  Design token          Flutter implementation
  --------------------- ---------------------------------------------
  Colors                `ColorScheme` and custom theme extension
  Typography            `TextTheme`
  Spacing               Shared constants class
  Radius                `BorderRadius` constants
  Shadows               `BoxShadow` presets
  Buttons               Reusable button widgets
  Cards                 Shared card/container widget
  Status colors         Semantic theme extension
  Background overlays   Reusable `Stack` / `DecoratedBox` widgets
  Navigation            Shared `NavigationBar` or custom bottom bar

Keep tokens in one source of truth. Avoid hardcoding the same color,
radius, or spacing value in multiple screens.

------------------------------------------------------------------------

## 16. Implementation checklist

-   [ ] Define the color tokens in one theme file.
-   [ ] Define typography styles and text scaling behavior.
-   [ ] Define spacing, radius, border, and elevation constants.
-   [ ] Build reusable app header and bottom navigation.
-   [ ] Build primary, secondary, and outline button variants.
-   [ ] Build reusable cards, quick-access tiles, and status badges.
-   [ ] Build the ivory background and optional botanical overlay as
    separate reusable layers.
-   [ ] Keep the scanner camera preview visually unobstructed.
-   [ ] Define healthy, warning, critical, and processing states.
-   [ ] Test contrast and touch targets on a real Android device.
-   [ ] Test the layout with long text, larger font settings, and small
    screens.
-   [ ] Validate diagnosis wording and confidence presentation with the
    ML/model behavior.

------------------------------------------------------------------------

## 17. Final design rule

**Function first. Structure second. Visual polish third. Decoration
last.**

The interface should make it immediately clear how to scan a crop, what
the AI found, how certain the result is, and what the user can do next.
The botanical visual language should make the product recognizable
without reducing clarity or usability.
