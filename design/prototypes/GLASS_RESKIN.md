# Optimized glassmorphism re-skin (2026-11-22)

All 14 prototypes inherit the glass language from `shared/tokens.css`; no per-page copy of the visual tokens exists. Glass is opt-in: only immersive text plates use `.glass-dark`; dense cards, lists, calendars and forms stay opaque per ADR 0013.

| Token (design/tokens.json) | Prototype CSS variable | Flutter constant |
| --- | --- | --- |
| `glass.tint.canvas` | `--glass-canvas` | `AppGlass.tintCanvas` |
| `glass.tint.raised` | `--glass-raised` | `AppGlass.tintRaised` |
| `glass.tint.dark` | `--glass-dark` | `AppGlass.tintDark` |
| `glass.tint.accent` | `--glass-accent` | `AppGlass.tintAccent` |
| `glass.border` | `--glass-border` | `AppGlass.border` |
| `glass.boundary` | `--glass-boundary` | `AppGlass.boundary` |
| `glass.sigma.compact` | `--glass-sigma` | `AppGlass.sigmaCompact` |

Applied only where `.glass-dark` is opted into (Onboarding hero, Auth trust panel, Home hero and mini-heroes, Scan reticle, Agri Pro hero). The previous blanket `.card`/`.bottom-nav` glass override was removed; dense list/calendar/form surfaces stay opaque by decision (ADR 0013). Contrast over worst-case backdrops is enforced in `test/app/theme/tokens_test.dart`; one `BackdropFilter` per screen is enforced in `test/app/widgets/glass_surface_test.dart` and `test/design/prototype_glass_contract_test.dart`.

Decisions and rationale: `docs/adr/0013-optimized-glassmorphism.md`.

## Re-judgment (2026-11-22)

All 14 briefs were re-judged under glass. No A/B/C winner changed: the existing winners already owned the only immersive surfaces, while the nine dense/utility pages correctly stay opaque. Glass is now explicit in five prototype pages; every verdict line records the re-judgment. This matches the added reference guidance (`PROJECT_KNOWLEDGE/DOCUMENTS/REFERENCE.md:300-310`): stronger blur only in image/camera contexts, ordinary cards crisp, no glass on every surface. Contract: `test/design/prototype_glass_contract_test.dart`.
