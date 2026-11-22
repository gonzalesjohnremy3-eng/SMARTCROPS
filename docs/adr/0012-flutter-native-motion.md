# Use Flutter-native motion as the in-app motion engine

- **Status:** Accepted
- **Date:** 2026-11-21

## Context

The upgrade asks for fluid, living animations. HyperFrames renders HTML to video; it can produce marketing loops but cannot animate a Flutter interface at runtime. The `flutter-motion` skill provides a Specify/Implement/Verify loop covering interruption, reduced motion and frame budgets, and the tokens already fix the motion durations and easings.

## Decision

Implement all in-app motion in Flutter using the `flutter-motion` skill: prefer implicit animations, `AnimatedSwitcher` and Hero transitions, animate transform and opacity, dispose controllers, and provide a reduced-motion equivalent. HyperFrames is deferred to an optional final-polish step for at most one short ambient video loop; it is never the app's animation system.

## Why

It keeps motion interactive, state-correct, accessible and performant on baseline hardware, while still allowing a reusable video asset if the tooling becomes available.

## Consequences

- Every new animation must name its purpose and reduced-motion equivalent before implementation.
- Motion values come from `design/tokens.json`, never ad-hoc numbers.
- HyperFrames work is explicitly out of scope unless tooling and ffmpeg are available.

## Considered alternatives

- **HyperFrames as the motion engine:** produces video only, not runtime UI animation.
- **No motion:** misses the continuity and feedback the craft upgrade targets.
