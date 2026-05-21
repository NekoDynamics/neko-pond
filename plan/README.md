# NEKO POND reconstruction plan

This directory is the implementation-grade planning system for rebuilding NEKO POND from the current iPadOS SpriteKit baseline into the frozen design blueprint direction.

## How future AI agents must use this directory

Execution rule:

1. Read `plan/README.md` first.
2. Read `plan/00-current-state-and-facts.md`.
3. Read the target phase document or roadmap section for the requested phase.
4. Implement only the target phase.
5. Edit only files explicitly allowed by that phase.
6. Build with the phase validation command.
7. Capture simulator screenshot/video evidence for visual phases.
8. Report exact changes and evidence.
9. Stop.

Do not continue to the next phase without a new user instruction.

## Planning file index

- `00-current-state-and-facts.md` — inspected facts, current architecture, risks, and evidence.
- `01-design-target-blueprint-map.md` — blueprint sheet-to-implementation map.
- `02-target-architecture.md` — target SwiftUI/SpriteKit/module boundaries.
- `03-phase-roadmap.md` — small testable phase sequence from 1A through 4C.
- `04-asset-runtime-pipeline.md` — bundle paths, caching, fallbacks, layering, and asset rules.
- `05-spritekit-rendering-plan.md` — layer stack and SpriteKit rendering reconstruction.
- `06-koi-atlas-and-motion-plan.md` — koi atlas, animation, movement, and cat readability plan.
- `07-water-environment-interaction-plan.md` — caustics, veils, ripples, motes, lotus, stones, petals.
- `08-swiftui-settings-ui-reconstruction-plan.md` — Settings reconstruction plan.
- `09-vanishing-hud-onboarding-plan.md` — HUD and onboarding behavior plan.
- `10-build-qa-performance-plan.md` — build, simulator, screenshot, warning, and release QA policy.
- `11-ai-agent-execution-protocol.md` — mandatory workflow for future AI agents.
- `12-ready-to-copy-prompts.md` — standalone prompts for the next implementation phases.
- `13-open-questions-and-decision-log.md` — unresolved decisions and decision log.

## Non-negotiable product direction

NEKO POND is a premium realistic koi pond for cats: deep teal-green water, natural caustics, soft underwater fog, mossy stones, lotus, petals, believable large koi, gentle ripples, no game economy, no noisy UI, no neon/fantasy/casino/children-game style.

## Scope guard

This plan directory is planning-only. It must not be used as permission to modify `App/`, `Assets/`, `Design/`, `docs/`, or the Xcode project outside a future explicitly requested implementation phase.
