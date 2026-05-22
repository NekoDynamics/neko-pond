# 12 — Ready-to-copy prompts

Each prompt is standalone. Use exactly one prompt per execution.

---

## Prompt 1 — Phase 1C: replace water overlay and atmosphere layer only

You are working on NEKO POND, a native iPadOS SwiftUI + SpriteKit app.

Task: Implement Phase 1C only: replace the water overlay and atmosphere layer with frozen Water assets.

Read first:

- `plan/README.md`
- `plan/00-current-state-and-facts.md`
- `plan/03-phase-roadmap.md` Phase 1C
- `plan/04-asset-runtime-pipeline.md`
- `plan/05-spritekit-rendering-plan.md`
- `plan/07-water-environment-interaction-plan.md`
- `plan/11-ai-agent-execution-protocol.md`

Strict rules:

- Implement Phase 1C only.
- Preserve the visible Phase 1B frozen pond background.
- Replace procedural water/atmosphere rendering only.
- Do not replace koi yet.
- Do not replace environment yet.
- Do not reconstruct Settings/HUD/onboarding.
- Do not rename or edit assets.
- Do not commit.

Files allowed to edit:

- `App/iPadOS/NekoPond/PondSpriteScene.swift`
- `App/iPadOS/NekoPond/PondSpriteModels.swift` only if zPosition naming/order must be adjusted
- `App/iPadOS/NekoPond/PondAssetRegistry.swift` only if a tiny helper is required; existing paths should normally be enough

Files forbidden to edit:

- `App/iPadOS/NekoPond/ContentView.swift`
- `App/iPadOS/NekoPond/PondSpriteAssets.swift` unless preserving existing fallback is absolutely necessary
- `App/iPadOS/NekoPond/FishEntity.swift`
- `App/iPadOS/NekoPond/FishMovementComponent.swift`
- `App/iPadOS/NekoPond/FishSteeringSystem.swift`
- `App/iPadOS/NekoPond/EdgeAvoidanceBehavior.swift`
- `App/iPadOS/NekoPond/MotionTuning.swift`
- `App/iPadOS/NekoPond/PondScene.swift`
- `App/iPadOS/NekoPond/SceneLifecycle.swift`
- `App/iPadOS/NekoPond.xcodeproj/project.pbxproj`
- `Assets/**`
- `Design/**`
- `docs/**`
- `plan/**`

Use these frozen Water assets at runtime where appropriate:

- `Water/water_veil_deep.png`
- `Water/water_veil_near.png`
- `Water/caustics_loop_01.png`
- `Water/caustics_loop_02.png`
- `Water/caustics_soft_large.png`
- `Water/dark_edge_vignette.png`
- optionally `Water/mote_soft.png` or `Water/mote_tiny.png` only if replacing the existing mote texture is small and safe

Validation command:

```bash
xcodebuild -project App/iPadOS/NekoPond.xcodeproj -scheme NekoPond -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M4)' -derivedDataPath /tmp/NekoPondDerivedData build
```

Screenshot requirements:

- Launch on an iPad landscape simulator.
- Capture one full pond screenshot before interaction.
- Capture one screenshot after a tap if practical.
- Report screenshot paths, or state exactly why capture was not possible.

Acceptance criteria:

- Frozen pond background remains visible.
- Water overlays use frozen Water assets, not procedural generated textures, for normal runtime.
- Caustics are slow and natural.
- Vignette is subtle.
- Koi and existing environment remain visible.
- Build succeeds.

Stop conditions:

- Any required frozen Water asset fails to load.
- Background becomes hidden or washed out.
- Build fails.
- A forbidden file seems necessary.
- Scope expands beyond Phase 1C.

Final report format:

1. Phase completed or stopped.
2. Files changed.
3. Exact runtime assets now used.
4. Build command/result.
5. Screenshot evidence.
6. Warnings observed.
7. Acceptance criteria status.
8. Rollback notes.

---

## Prompt K1 — regenerate one clean RGBA mesh-deformable koi texture

You are working on NEKO POND, a native iPadOS SwiftUI + SpriteKit app.

Task: Execute Phase K1 only: create or import one clean RGBA mesh-deformable koi texture candidate for SpriteKit warp prototyping.

Read first:

- `plan/README.md`
- `plan/03-phase-roadmap.md` Phase K1
- `plan/04-asset-runtime-pipeline.md`
- `plan/06-koi-atlas-and-motion-plan.md`
- `plan/11-ai-agent-execution-protocol.md`

Strict rules:

- Planning and asset validation scope only unless explicitly allowed to place the candidate asset.
- Do not modify `App/**`.
- Do not modify Xcode project.
- Do not write production Swift code.
- Do not rescue current atlas crops.
- Do not commit.

Required koi texture properties:

- True RGBA PNG.
- Transparent background.
- No checkerboard.
- No white/black baked background.
- Single straight top-down koi body.
- Head facing right, tail left.
- Centered in canvas.
- Transparent padding for warp deformation.
- No baked shadow.

Validation:

```bash
python3 - <<'EOF'
from PIL import Image
from pathlib import Path
p = Path('PATH_TO_CANDIDATE.png')
im = Image.open(p)
print(p, im.mode, im.size)
print('has_alpha', im.mode in ('RGBA', 'LA') or 'transparency' in im.info)
EOF
```

Final report format:

1. Phase completed or stopped.
2. Candidate asset path, if any.
3. Alpha/background validation.
4. Padding/deformation suitability.
5. Files changed.
6. Stop risks.

---

## Prompt K2 — isolated SKWarpGeometryGrid one-fish prototype

You are working on NEKO POND, a native iPadOS SwiftUI + SpriteKit app.

Task: Execute Phase K2 only: build an isolated single-fish `SKWarpGeometryGrid` prototype using one clean RGBA koi texture.

Read first:

- `plan/README.md`
- `plan/03-phase-roadmap.md` Phase K2
- `plan/04-asset-runtime-pipeline.md`
- `plan/05-spritekit-rendering-plan.md`
- `plan/06-koi-atlas-and-motion-plan.md`
- `plan/11-ai-agent-execution-protocol.md`

Strict rules:

- Prototype one fish only.
- Do not integrate into normal pond runtime yet.
- Do not add multi-fish behavior.
- Do not use atlas cropping or frame flipping.
- Do not modify water/environment/Settings/HUD/onboarding.
- Do not commit.

Prototype requirements:

- `SKSpriteNode` with one clean RGBA koi texture.
- Cached original `SKWarpGeometryGrid`.
- Per-frame destination grid update.
- Root node position/heading separate from warp.
- Body curvature from turn intensity.
- Tail beat from speed.
- Independent phase seed.
- No per-frame texture decoding.
- No full atlas sheet display.

Validation command:

```bash
xcodebuild -project App/iPadOS/NekoPond.xcodeproj -scheme NekoPond -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M4)' -derivedDataPath /tmp/NekoPondDerivedData build
```

Screenshot/video requirements:

- Capture still screenshot.
- Capture short video or repeated screenshots showing warp deformation.

Final report format:

1. Phase completed or stopped.
2. Files changed.
3. Grid resolution and deformation model.
4. Build command/result.
5. Screenshot/video evidence.
6. Visual acceptance status.
7. Rollback notes.

---

## Prompt K3 — one-fish PondSpriteScene warp integration

You are working on NEKO POND, a native iPadOS SwiftUI + SpriteKit app.

Task: Execute Phase K3 only: integrate the validated warp koi renderer into `PondSpriteScene` with exactly one active fish.

Read first:

- `plan/README.md`
- `plan/03-phase-roadmap.md` Phase K3
- `plan/04-asset-runtime-pipeline.md`
- `plan/05-spritekit-rendering-plan.md`
- `plan/06-koi-atlas-and-motion-plan.md`
- `plan/11-ai-agent-execution-protocol.md`

Strict rules:

- One warp fish only.
- Preserve existing pond background, water, environment, ripples, and SwiftUI shell.
- Do not expand to variants.
- Do not use atlas crop/frame flipping.
- Do not modify Xcode project unless asset membership was explicitly approved.
- Do not commit.

Runtime requirements:

- Fish root node controls position and heading.
- `SKWarpGeometryGrid` controls body/tail deformation.
- Cached original grid.
- Per-frame destination grid update only.
- Body curvature from smoothed turn intensity.
- Tail beat from smoothed speed.
- No per-frame texture decoding.
- No full atlas sheet display.

Validation command:

```bash
xcodebuild -project App/iPadOS/NekoPond.xcodeproj -scheme NekoPond -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M4)' -derivedDataPath /tmp/NekoPondDerivedData build
```

Screenshot/video requirements:

- iPad landscape screenshot showing one koi in pond.
- Short video or repeated screenshots showing movement and deformation.

Final report format:

1. Phase completed or stopped.
2. Files changed.
3. Runtime asset used.
4. Build command/result.
5. Screenshot/video evidence.
6. Visual acceptance status.
7. Rollback notes.

---

## Prompt K4 — expand warp koi to 3–6 validated variants

You are working on NEKO POND, a native iPadOS SwiftUI + SpriteKit app.

Task: Execute Phase K4 only: expand validated warp koi from one fish to 3–6 variants after each texture passes RGBA/padding validation.

Read first:

- `plan/README.md`
- `plan/03-phase-roadmap.md` Phase K4
- `plan/04-asset-runtime-pipeline.md`
- `plan/05-spritekit-rendering-plan.md`
- `plan/06-koi-atlas-and-motion-plan.md`
- `plan/11-ai-agent-execution-protocol.md`

Strict rules:

- Add only validated RGBA mesh-deformable koi textures.
- Expand gradually to 3–6 fish, not 9 by default.
- Assign independent phase offsets.
- Do not use atlas cropping/frame flipping.
- Do not modify unrelated water/environment/UI systems.
- Do not commit.

Acceptance criteria:

- 3–6 koi remain readable and alive.
- No synchronized tail beats.
- No checkerboard/background artifacts.
- Performance remains smooth.
- Fish count changes remain stable within the scoped range.

Validation command:

```bash
xcodebuild -project App/iPadOS/NekoPond.xcodeproj -scheme NekoPond -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M4)' -derivedDataPath /tmp/NekoPondDerivedData build
```

Screenshot/video requirements:

- iPad landscape screenshot showing multiple fish.
- Short video or repeated screenshots showing independent motion.

Final report format:

1. Phase completed or stopped.
2. Files changed.
3. Validated koi assets used.
4. Build command/result.
5. Screenshot/video evidence.
6. Performance/readability notes.
7. Rollback notes.

---

## Prompt 4 — Phase 1F: replace environment decorations only

You are working on NEKO POND, a native iPadOS SwiftUI + SpriteKit app.

Task: Implement Phase 1F only: replace environment decorations with frozen Environment assets.

Read first:

- `plan/README.md`
- `plan/00-current-state-and-facts.md`
- `plan/03-phase-roadmap.md` Phase 1F
- `plan/04-asset-runtime-pipeline.md`
- `plan/05-spritekit-rendering-plan.md`
- `plan/07-water-environment-interaction-plan.md`
- `plan/11-ai-agent-execution-protocol.md`

Strict rules:

- Implement Phase 1F only.
- Replace lotus, stones, grasses, and petals only.
- Preserve existing water and koi behavior.
- Do not reconstruct Settings/HUD/onboarding.
- Do not change fish movement.
- Do not rename or edit assets.
- Keep `Environment/lotus_bud_pink.png.png` exactly as-is.
- Do not commit.

Files allowed to edit:

- `App/iPadOS/NekoPond/PondSpriteScene.swift`
- `App/iPadOS/NekoPond/PondSpriteModels.swift` only if layer constants need adjustment
- `App/iPadOS/NekoPond/PondAssetRegistry.swift` only if tiny helper mapping is needed

Files forbidden to edit:

- `App/iPadOS/NekoPond/ContentView.swift`
- `App/iPadOS/NekoPond/FishEntity.swift`
- `App/iPadOS/NekoPond/FishMovementComponent.swift`
- `App/iPadOS/NekoPond/FishSteeringSystem.swift`
- `App/iPadOS/NekoPond/EdgeAvoidanceBehavior.swift`
- `App/iPadOS/NekoPond/MotionTuning.swift`
- `App/iPadOS/NekoPond/PondScene.swift`
- `App/iPadOS/NekoPond/SceneLifecycle.swift`
- `App/iPadOS/NekoPond.xcodeproj/project.pbxproj`
- `Assets/**`
- `Design/**`
- `docs/**`
- `plan/**`

Use these frozen Environment assets:

- `Environment/aquatic_grass_01.png`
- `Environment/aquatic_grass_02.png`
- `Environment/lotus_bud_pink.png.png`
- `Environment/lotus_flower_pink.png`
- `Environment/lotus_flower_white.png`
- `Environment/lotus_leaf_01.png`
- `Environment/lotus_leaf_02.png`
- `Environment/lotus_leaf_03_small.png`
- `Environment/moss_stone_01.png`
- `Environment/moss_stone_02_flat.png`
- `Environment/moss_stone_03_small.png`
- `Environment/petal_01.png`
- `Environment/petal_02.png`
- `Environment/petal_03_small.png`
- `Environment/petal_04_pale.png`

Validation command:

```bash
xcodebuild -project App/iPadOS/NekoPond.xcodeproj -scheme NekoPond -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M4)' -derivedDataPath /tmp/NekoPondDerivedData build
```

Screenshot requirements:

- Launch on iPad landscape simulator.
- Capture screenshot showing environment assets and fish.
- If practical, capture after a resize/orientation change.

Acceptance criteria:

- Environment visuals use frozen PNG assets in normal runtime.
- Lotus bud double-extension asset loads correctly.
- Placement frames pond naturally.
- Fish remain visible and trackable.
- Petals drift calmly and sparsely.
- Build succeeds.

Stop conditions:

- Any Environment asset fails to load.
- Environment blocks fish readability.
- Build fails.
- A forbidden file seems necessary.

Final report format:

1. Phase completed or stopped.
2. Files changed.
3. Environment assets used.
4. Placement strategy.
5. Build command/result.
6. Screenshot evidence.
7. Warnings observed.
8. Acceptance criteria status.
9. Rollback notes.

---

## Prompt 5 — Phase 2A: reconstruct Settings UI only

You are working on NEKO POND, a native iPadOS SwiftUI + SpriteKit app.

Task: Implement Phase 2A only: reconstruct the Settings UI as a premium human-only control panel.

Read first:

- `plan/README.md`
- `plan/00-current-state-and-facts.md`
- `plan/03-phase-roadmap.md` Phase 2A
- `plan/08-swiftui-settings-ui-reconstruction-plan.md`
- `plan/09-vanishing-hud-onboarding-plan.md` only for interaction boundaries
- `plan/11-ai-agent-execution-protocol.md`

Strict rules:

- Implement Phase 2A only.
- Reconstruct Settings UI only.
- Preserve existing settings values and bindings unless a tiny UI binding fix is required.
- Do not touch SpriteKit rendering.
- Do not change water/koi/environment rendering.
- Do not reconstruct HUD or onboarding in this phase.
- Do not rename or edit assets.
- Do not commit.

Files allowed to edit:

- `App/iPadOS/NekoPond/ContentView.swift`

Optional only if explicitly approved before editing:

- New SwiftUI component files under `App/iPadOS/NekoPond/`
- `App/iPadOS/NekoPond.xcodeproj/project.pbxproj` for target membership of new files

Files forbidden to edit:

- `App/iPadOS/NekoPond/PondSpriteScene.swift`
- `App/iPadOS/NekoPond/PondAssetRegistry.swift`
- `App/iPadOS/NekoPond/PondTextureCache.swift`
- `App/iPadOS/NekoPond/PondSpriteModels.swift`
- `App/iPadOS/NekoPond/PondSpriteAssets.swift`
- `App/iPadOS/NekoPond/FishEntity.swift`
- `App/iPadOS/NekoPond/FishMovementComponent.swift`
- `App/iPadOS/NekoPond/FishSteeringSystem.swift`
- `App/iPadOS/NekoPond/EdgeAvoidanceBehavior.swift`
- `App/iPadOS/NekoPond/MotionTuning.swift`
- `App/iPadOS/NekoPond/PondScene.swift`
- `App/iPadOS/NekoPond/SceneLifecycle.swift`
- `Assets/**`
- `Design/**`
- `docs/**`
- `plan/**`

Target style:

- Dark translucent glass panels.
- Warm gold and jade accents.
- Koi-white text.
- Sidebar + content panel iPad landscape layout.
- Premium mature typography.
- Large touch targets.
- No game-like visual language.

Validation command:

```bash
xcodebuild -project App/iPadOS/NekoPond.xcodeproj -scheme NekoPond -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M4)' -derivedDataPath /tmp/NekoPondDerivedData build
```

Screenshot requirements:

- Launch on iPad landscape simulator.
- Open Settings and capture screenshot.
- Change one segmented control and one slider; capture or report result.
- Close Settings and capture/verify pond returns.

Acceptance criteria:

- Settings no longer looks prototype-level.
- Glass panel system and landscape layout match premium NEKO POND direction.
- Existing controls remain functional.
- Closing Settings works.
- SpriteKit visuals are untouched.
- Build succeeds.

Stop conditions:

- Settings controls stop binding.
- Layout clips or breaks on iPad landscape.
- SpriteKit files seem necessary.
- Build fails.
- Scope expands into HUD/onboarding/rendering.

Final report format:

1. Phase completed or stopped.
2. Files changed.
3. Settings UI changes.
4. Build command/result.
5. Screenshot evidence.
6. Warnings observed.
7. Acceptance criteria status.
8. Rollback notes.
