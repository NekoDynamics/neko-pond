# 11 — AI agent execution protocol

This protocol is mandatory for future AI agents working on NEKO POND reconstruction.

## Core rule

One phase per execution. Never continue to the next phase without explicit user instruction.

## Required startup sequence

1. Read `plan/README.md`.
2. Read `plan/00-current-state-and-facts.md`.
3. Read `plan/03-phase-roadmap.md`.
4. Read the specific plan file for the requested phase:
   - Water/rendering: `05-spritekit-rendering-plan.md`, `07-water-environment-interaction-plan.md`
   - Koi: `06-koi-atlas-and-motion-plan.md`
   - Settings: `08-swiftui-settings-ui-reconstruction-plan.md`
   - HUD/onboarding: `09-vanishing-hud-onboarding-plan.md`
   - QA: `10-build-qa-performance-plan.md`
5. Inspect current source before editing.
6. Confirm file allowlist and forbidden files.
7. Implement only the requested phase.
8. Build.
9. Run simulator/screenshot validation for visual phases.
10. Report exact changes.
11. Stop.

## Inspect before edit

Before editing any source file:

- Read the current file.
- Verify symbols/paths still exist.
- If memory/plan facts conflict with current files, trust current files and report the conflict.
- Do not assume line numbers from old plans are still exact.

## Exact file allowlist

Each phase must define allowed files. Edit only those files.

If implementation appears to require a forbidden file:

1. Stop.
2. Explain why the forbidden file seems necessary.
3. Ask the user for permission or propose a narrower alternative.

## No broad refactor

Forbidden:

- Moving many types into new files unless the phase explicitly allows project changes.
- Renaming assets.
- Rewriting app shell while doing visual replacement.
- Converting architecture to a different engine/framework.
- Reformatting unrelated code.
- Cleaning up legacy files opportunistically.

## Build after edit

Every implementation phase must run:

```bash
xcodebuild -project App/iPadOS/NekoPond.xcodeproj -scheme NekoPond -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M4)' -derivedDataPath /tmp/NekoPondDerivedData build
```

If unavailable, substitute nearest iPad simulator and report the exact command.

Do not skip build unless user explicitly says not to build.

## Screenshot after visual edit

Visual phases require simulator evidence:

- Phase 1C: pond water/atmosphere screenshot.
- Phase 1D: static koi screenshot.
- Phase 1E: koi animation evidence.
- Phase 1F: environment screenshot.
- Phase 1G: ripple/touch evidence.
- Phase 2A: Settings screenshot.
- Phase 2B: HUD visible/hidden screenshots.
- Phase 2C: onboarding screenshots.
- Phase 3B: one screenshot per mood.

If screenshot capture cannot be completed, say so explicitly and provide the reason.

## Report exact changes

Final report must include:

- Phase name.
- Files changed.
- What changed in each file.
- Build result.
- Screenshot/video evidence.
- Warnings observed.
- Acceptance criteria status.
- Any unresolved questions.

## Stop on new errors

Stop and report if:

- Build fails.
- A frozen asset path is missing.
- Required metadata is unavailable.
- A forbidden file appears necessary.
- Visual result violates product direction.
- Runtime crashes or hangs.
- Existing baseline is lost, such as pond background disappearing.

## Legacy code rule

Never solve legacy code by adding compatibility API unless active path requires it.

Specifically:

- Do not revive `PondScene.swift` SceneKit path to solve SpriteKit issues.
- Do not add new APIs only for quarantined legacy SceneKit compilation unless the user explicitly requests legacy cleanup.
- Do not delete legacy files in visual reconstruction phases.

## Design direction rule

Never change design direction.

Maintain:

- premium realistic koi pond
- cat-first readability
- calm cinematic top-down pond
- deep teal-green water
- natural caustics/fog
- minimal vanishing UI

Avoid:

- game economy
- loud particles
- neon/fantasy/casino/children-game style
- persistent HUD

## Frozen asset rule

Never rename frozen assets.

Important exact name:

- `Environment/lotus_bud_pink.png.png`

Do not normalize, move, compress, delete, or edit frozen PNG files without explicit user instruction.

## Git safety

- Do not commit unless user explicitly asks.
- Do not push.
- Do not run destructive git commands.
- Do not use broad `git add .` or `git add -A`.
- Preserve user changes in dirty worktree.

## AI prompt handling

When using `plan/12-ready-to-copy-prompts.md`:

- Copy only one phase prompt.
- Do not merge prompts.
- Do not silently expand scope.
- Keep final report in the format requested by that prompt.
