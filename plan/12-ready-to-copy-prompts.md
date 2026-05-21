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

## Prompt 2 — Phase 1D: replace koi with static atlas-backed sprites only

You are working on NEKO POND, a native iPadOS SwiftUI + SpriteKit app.

Task: Implement Phase 1D only: replace procedural koi bodies with static atlas-backed sprites.

Read first:

- `plan/README.md`
- `plan/00-current-state-and-facts.md`
- `plan/03-phase-roadmap.md` Phase 1D
- `plan/04-asset-runtime-pipeline.md`
- `plan/05-spritekit-rendering-plan.md`
- `plan/06-koi-atlas-and-motion-plan.md`
- `plan/11-ai-agent-execution-protocol.md`

Strict rules:

- Implement Phase 1D only.
- Use static atlas-backed koi sprites only.
- Do not animate atlas frames yet.
- Do not change fish steering/movement behavior.
- Do not change water overlays except if required to keep fish visible, and ask first if so.
- Do not replace environment.
- Do not modify Settings/HUD/onboarding.
- Do not rename or edit assets.
- Do not commit.

Files allowed to edit:

- `App/iPadOS/NekoPond/PondSpriteScene.swift`
- `App/iPadOS/NekoPond/PondSpriteModels.swift`
- `App/iPadOS/NekoPond/PondAssetRegistry.swift` only if a variant-to-atlas helper is needed

Files forbidden to edit:

- `App/iPadOS/NekoPond/ContentView.swift`
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

Use these frozen Koi assets:

- `Koi/koi_cream_red_atlas.png`
- `Koi/koi_kohaku_atlas.png`
- `Koi/koi_sanke_atlas.png`
- `Koi/koi_shiro_utsuri_atlas.png`
- `Koi/koi_showa_atlas.png`
- `Koi/koi_yamabuki_atlas.png`

Before editing, inspect atlas dimensions. Do not guess slicing if dimensions/layout are unclear. If frame metadata is insufficient to select a clean static crop, stop and report the metadata needed.

Validation command:

```bash
xcodebuild -project App/iPadOS/NekoPond.xcodeproj -scheme NekoPond -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M4)' -derivedDataPath /tmp/NekoPondDerivedData build
```

Screenshot requirements:

- Launch on iPad landscape simulator.
- Capture screenshot showing visible fish.
- If practical, verify fish count 3 and 9 through Settings and capture/report observations.

Acceptance criteria:

- Koi body sprites use frozen Koi atlas textures in normal runtime.
- Procedural koi body texture is no longer used for normal body rendering.
- Fish remain large and trackable.
- No atlas bleed/cropping artifacts.
- Shadows still align.
- Movement behavior remains unchanged.
- Build succeeds.

Stop conditions:

- Atlas metadata/layout cannot be verified enough for a clean static crop.
- Fish become too small or hard to track.
- Atlas artifacts appear.
- Build fails.
- A forbidden file seems necessary.

Final report format:

1. Phase completed or stopped.
2. Files changed.
3. Atlas dimensions and crop strategy.
4. Build command/result.
5. Screenshot evidence.
6. Warnings observed.
7. Acceptance criteria status.
8. Rollback notes.

---

## Prompt 3 — Phase 1E: add koi atlas animation and movement refinement only

You are working on NEKO POND, a native iPadOS SwiftUI + SpriteKit app.

Task: Implement Phase 1E only: add koi atlas animation and small movement presentation refinement.

Read first:

- `plan/README.md`
- `plan/00-current-state-and-facts.md`
- `plan/03-phase-roadmap.md` Phase 1E
- `plan/04-asset-runtime-pipeline.md`
- `plan/05-spritekit-rendering-plan.md`
- `plan/06-koi-atlas-and-motion-plan.md`
- `plan/11-ai-agent-execution-protocol.md`

Strict rules:

- Implement Phase 1E only.
- Start from Phase 1D static atlas-backed koi.
- Do not proceed if atlas frame metadata is still unclear.
- Add subtle swim animation only.
- Keep movement calm and cat-readable.
- Do not rebuild water/environment/Settings/HUD/onboarding.
- Do not rename or edit assets.
- Do not commit.

Files allowed to edit:

- `App/iPadOS/NekoPond/PondSpriteScene.swift`
- `App/iPadOS/NekoPond/PondSpriteModels.swift`
- `App/iPadOS/NekoPond/FishMovementComponent.swift` only if presentation animation state is necessary
- `App/iPadOS/NekoPond/FishSteeringSystem.swift` only for small directly required tuning

Files forbidden to edit:

- `App/iPadOS/NekoPond/ContentView.swift`
- `App/iPadOS/NekoPond/PondScene.swift`
- `App/iPadOS/NekoPond/SceneLifecycle.swift`
- `App/iPadOS/NekoPond.xcodeproj/project.pbxproj` unless user explicitly approves adding a metadata Swift file
- `Assets/**`
- `Design/**`
- `docs/**`
- `plan/**`

Validation command:

```bash
xcodebuild -project App/iPadOS/NekoPond.xcodeproj -scheme NekoPond -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M4)' -derivedDataPath /tmp/NekoPondDerivedData build
```

Screenshot/video requirements:

- Launch on iPad landscape simulator.
- Capture a still screenshot.
- Capture short video or multiple screenshots showing animated fish.

Acceptance criteria:

- Koi animation uses confirmed atlas frames.
- Animation is subtle, smooth, and natural.
- No flicker, wrong frame order, or crop bleed.
- Movement remains calm and organic.
- Fish remain large and trackable.
- Build succeeds.

Stop conditions:

- Frame metadata is not confirmed.
- Animation causes artifacts.
- Fish become jittery/aggressive/hard to track.
- Build fails.
- A forbidden file seems necessary.

Final report format:

1. Phase completed or stopped.
2. Files changed.
3. Animation metadata/frame strategy.
4. Movement tuning changes, if any.
5. Build command/result.
6. Screenshot/video evidence.
7. Warnings observed.
8. Acceptance criteria status.
9. Rollback notes.

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
