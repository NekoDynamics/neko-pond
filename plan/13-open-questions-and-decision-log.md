# 13 — Open questions and decision log

This document records unresolved decisions that should not be guessed by future agents.

## Open questions

### 1. Koi warp asset metadata and validated texture set

Status: unresolved.

Need to determine:

- Final clean RGBA koi texture dimensions.
- Transparent padding requirements for deformation.
- Head, body center, tail base, and tail tip control landmarks.
- Grid resolution per variant.
- Tail amplitude and curvature limits per texture.
- Whether an optional alpha mask is needed.
- How many variants can run smoothly on target iPad hardware.

Why it matters:

- The atlas slicing path is rejected. Future koi quality depends on clean mesh-deformable textures and stable warp metadata.

Decision needed before:

- Phase K2 for prototype tuning.
- Phase K4 before multi-fish expansion.

### 2. Whether to keep or remove legacy SceneKit files later

Status: unresolved.

Known:

- `PondScene.swift` exists and appears to contain SceneKit code.
- Current active runtime path uses `PondSpriteScene`.
- User-provided state says legacy SceneKit files were quarantined from target compilation.

Options:

- Keep quarantined files as reference until final release.
- Remove them in a dedicated cleanup phase after SpriteKit path is stable.
- Archive them outside app target if needed.

Do not decide during visual reconstruction phases.

### 3. Whether Settings should be split out of `ContentView.swift`

Status: unresolved.

Current:

- `PondSettings`, `SettingsScreen`, `CatPlayHUD`, `OnboardingView`, and `DesignToken` all live in `ContentView.swift`.

Options:

- Keep one file through Phase 2A to avoid Xcode project edits.
- Split into dedicated SwiftUI files in a later UI organization phase.

Recommendation:

- Do not split during Phase 2A unless `ContentView.swift` becomes unmanageably large and user approves Xcode project changes.

### 4. Final runtime settings model structure

Status: unresolved.

Questions:

- Should `PondSettings` remain `@MainActor ObservableObject`?
- Should settings persistence extend beyond onboarding key?
- Should mood, fish count, soundscape, and cat safe mode persist individually?
- Should runtime settings be split into display/fish/interaction/audio/safety groups?

Decision phase:

- Phase 3A or a dedicated settings model phase.

### 5. Final mood-specific tuning

Status: unresolved.

Need to determine for each mood:

- Pond background.
- Water veil alpha.
- Caustics alpha/speed.
- Vignette alpha.
- Rain overlay usage.
- Fish readability compensation.
- Environment density/visibility.

Decision phase:

- Phase 3B.

### 6. Final audio asset availability

Status: unresolved.

Known:

- `PondSettings.Soundscape` has `off`, `soft`, and `natural`.
- No audio asset inventory was confirmed during this planning task.

Need to determine:

- Whether audio assets exist.
- Whether soundscape is in scope for release.
- Whether cat-safe audio defaults should be off or natural.

Decision phase:

- Future audio-specific phase, not current visual reconstruction.

### 7. Final debug logging removal policy

Status: unresolved.

Known:

- `PondTextureCache` has DEBUG missing asset logs.
- `PondSpriteScene` has DEBUG layer diagnostics.

Questions:

- Which logs remain until final QA?
- Should layer diagnostics be removed after Phase 1C/1F?
- Should asset missing logs remain permanently in DEBUG?

Recommendation:

- Keep missing asset logs in DEBUG.
- Remove or gate verbose layer diagnostics by Phase 4C.

## Decision log

| Date | Decision | Reason | Affected files | Rollback notes |
|---|---|---|---|---|
| 2026-05-21 | Reconstruction remains on native iPadOS SwiftUI shell + SKView + SpriteKit `PondSpriteScene`. | Confirmed active runtime path and avoids premature engine/platform rewrite. | `App/iPadOS/NekoPond/ContentView.swift`, `App/iPadOS/NekoPond/PondSpriteScene.swift` | A future architecture change would require explicit user approval and a new plan. |
| 2026-05-21 | Frozen asset names are immutable, including `Environment/lotus_bud_pink.png.png`. | Current files and registry confirm exact names; renaming would break resource loading and broaden scope. | `Assets/Environment/lotus_bud_pink.png.png`, `App/iPadOS/NekoPond/PondAssetRegistry.swift` | Restore exact file name/path if changed. |
| 2026-05-21 | Phase 1C is the next executable phase. | Phase 1A/1B are confirmed complete by project state; current visual gap begins with water/atmosphere overlays. | `App/iPadOS/NekoPond/PondSpriteScene.swift` primarily | Revert only Phase 1C water overlay edits if visual baseline regresses. |
| 2026-05-21 | Future agents must execute one phase at a time with file allowlists, build, screenshot evidence, and stop. | Prevents broad uncontrolled edits and protects dirty working tree. | `plan/**` | Update plan only if user changes process. |
| 2026-05-21 | Legacy SceneKit should not be deleted or revived during SpriteKit visual reconstruction. | Current runtime path is SpriteKit; SceneKit is quarantined legacy status. | `App/iPadOS/NekoPond/PondScene.swift` | Dedicated cleanup decision required later. |
| 2026-05-22 | Reject atlas crop, frame flipping, and segmented sticker koi; adopt SpriteKit `SKWarpGeometryGrid` mesh-deformable koi pipeline. | Current approach fails visual realism and cat-readable living motion; clean RGBA texture deformation is the preferred native SpriteKit path. | `plan/03-phase-roadmap.md`, `plan/04-asset-runtime-pipeline.md`, `plan/05-spritekit-rendering-plan.md`, `plan/06-koi-atlas-and-motion-plan.md`, `plan/12-ready-to-copy-prompts.md` | Return to stable baseline koi if K2/K3 warp prototype fails; defer Metal/Spine/Rive/Live2D unless SpriteKit warp is rejected. |
