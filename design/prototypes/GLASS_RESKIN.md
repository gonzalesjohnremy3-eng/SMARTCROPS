# Optimized glassmorphism re-skin (2026-11-22)

All 14 prototypes inherit the glass language from `shared/tokens.css`; no per-page copy of the visual tokens exists.

| Token (design/tokens.json) | Prototype CSS variable | Flutter constant |
| --- | --- | --- |
| `glass.tint.canvas` | `--glass-canvas` | `AppGlass.tintCanvas` |
| `glass.tint.raised` | `--glass-raised` | `AppGlass.tintRaised` |
| `glass.tint.dark` | `--glass-dark` | `AppGlass.tintDark` |
| `glass.tint.accent` | `--glass-accent` | `AppGlass.tintAccent` |
| `glass.border` | `--glass-border` | `AppGlass.border` |
| `glass.boundary` | `--glass-boundary` | `AppGlass.boundary` |
| `glass.sigma.compact` | `--glass-sigma` | `AppGlass.sigmaCompact` |

Applied to shared `.card` and `.bottom-nav` surfaces; immersive heroes use the `.glass-dark` utility. Dense list/calendar/form surfaces stay opaque by decision (ADR 0013). Contrast over worst-case backdrops is enforced in `test/app/theme/tokens_test.dart`; one `BackdropFilter` per screen is enforced in `test/app/widgets/glass_surface_test.dart`.

Decisions and rationale: `docs/adr/0013-optimized-glassmorphism.md`.
