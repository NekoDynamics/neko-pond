# 00 — Current state and facts

This document records confirmed facts from allowed inspection only. Anything not directly observed is marked as an assumption.

## Confirmed repository and git state

- Project root: `/Users/cc/MyPorject/MiaoMiao/neko-pond`.
- Current branch at inspection: `main...origin/main`.
- The working tree already contained many uncommitted app, asset, design, and docs changes before this planning task.
- This planning task must add only files under `plan/`.

Evidence:

```text
pwd
/Users/cc/MyPorject/MiaoMiao/neko-pond

git status --short --branch
## main...origin/main
A  App/iPadOS/NekoPond/Assets.xcassets/AccentColor.colorset/Contents.json
A  App/iPadOS/NekoPond/Assets.xcassets/AppIcon.appiconset/Contents.json
A  App/iPadOS/NekoPond/Assets.xcassets/Contents.json
 M Assets/README.md
 M SUPPORT.md
 M docs/en-US/README.md
 M docs/zh-CN/README.md
 M docs/zh-CN/product.md
?? .claude/
?? App/iPadOS/NekoPond.xcodeproj/
?? App/iPadOS/NekoPond/ContentView.swift
?? App/iPadOS/NekoPond/EdgeAvoidanceBehavior.swift
?? App/iPadOS/NekoPond/FishEntity.swift
?? App/iPadOS/NekoPond/FishMovementComponent.swift
?? App/iPadOS/NekoPond/FishSteeringSystem.swift
?? App/iPadOS/NekoPond/LaunchScreen.storyboard
?? App/iPadOS/NekoPond/MotionTuning.swift
?? App/iPadOS/NekoPond/NekoPondApp.swift
?? App/iPadOS/NekoPond/PondAssetRegistry.swift
?? App/iPadOS/NekoPond/PondScene.swift
?? App/iPadOS/NekoPond/PondSpriteAssets.swift
?? App/iPadOS/NekoPond/PondSpriteModels.swift
?? App/iPadOS/NekoPond/PondSpriteScene.swift
?? App/iPadOS/NekoPond/PondTextureCache.swift
?? App/iPadOS/NekoPond/SceneLifecycle.swift
?? Assets/Environment/
?? Assets/Koi/
?? Assets/Pond/
?? Assets/Water/
?? Assets/未命名.md
?? Design/
?? docs/en-US/codex-workflow.md
?? docs/en-US/engineering-rules.md
?? docs/en-US/gameplay-systems.md
?? docs/en-US/master-plan.md
?? docs/en-US/milestones.md
?? docs/en-US/project-structure.md
?? docs/en-US/task-system.md
?? docs/en-US/visual-system.md
```

## Confirmed current architecture

- Native iPadOS app using SwiftUI and SpriteKit.
- Active runtime path is `ContentView` → `PondSpriteView` (`UIViewRepresentable`) → `SKView` → `PondSpriteScene`.
- `ContentView` owns `PondSettings` as a `@StateObject` and passes it to `PondSpriteScene.apply(settings:)`.
- `PondSpriteScene` owns fish nodes, fish shadows, fish movement components, ripples, and water/environment SpriteKit layers.
- `PondTextureCache` loads bundle resources by relative path and caches `SKTexture` instances by path.
- `PondAssetRegistry` defines relative paths for Pond, Water, Koi, and Environment frozen runtime assets.

Evidence:

- `App/iPadOS/NekoPond/ContentView.swift:5` defines `struct ContentView: View`.
- `App/iPadOS/NekoPond/ContentView.swift:16` instantiates `PondSpriteView(scene:settings:onTapWater:)`.
- `App/iPadOS/NekoPond/ContentView.swift:100` defines `private struct PondSpriteView: UIViewRepresentable`.
- `App/iPadOS/NekoPond/ContentView.swift:105` creates `SKView`.
- `App/iPadOS/NekoPond/ContentView.swift:115` creates `PondSpriteScene(size:)`.
- `App/iPadOS/NekoPond/ContentView.swift:118` presents the scene into the view.
- `App/iPadOS/NekoPond/PondSpriteScene.swift:4` defines `final class PondSpriteScene: SKScene`.
- `App/iPadOS/NekoPond/PondSpriteScene.swift:52` defines `func apply(settings: PondSettings)`.
- `App/iPadOS/NekoPond/PondTextureCache.swift:4` defines `final class PondTextureCache`.
- `App/iPadOS/NekoPond/PondAssetRegistry.swift:3` defines `enum PondAssetRegistry`.

## Active runtime path

Confirmed:

```text
SwiftUI ContentView
  -> PondSpriteView UIViewRepresentable
  -> SKView
  -> PondSpriteScene
  -> SpriteKit layers, fish nodes, touch ripples, mood background color
```

The legacy SceneKit path exists in source as `PondScene.swift`, but current SwiftUI shell uses `PondSpriteScene`, not `PondScene`.

Evidence:

- `ContentView.swift:12` stores `@State private var scene: PondSpriteScene?`.
- `ContentView.swift:115` constructs `PondSpriteScene`.
- `PondScene.swift` appears in grep output with `SCN*` symbols, but current runtime shell references `PondSpriteScene`.

## Current build status

Confirmed by user-provided project state:

- Build baseline currently succeeds.

Not re-verified in this planning task because the user stated planning-only and did not require build for read-only verification.

## Current asset integration status

Confirmed:

- Frozen runtime folders exist under `Assets/`:
  - `Assets/Pond`
  - `Assets/Water`
  - `Assets/Koi`
  - `Assets/Environment`
- Xcode project resources phase includes folder references/build files for:
  - `Pond in Resources`
  - `Water in Resources`
  - `Koi in Resources`
  - `Environment in Resources`
- `PondAssetRegistry` maps these assets to bundle-relative paths.
- `PondTextureCache` expects those relative paths under `Bundle.main.bundleURL`.

Evidence from project file:

- `App/iPadOS/NekoPond.xcodeproj/project.pbxproj:23` defines `Pond in Resources`.
- `project.pbxproj:24` defines `Water in Resources`.
- `project.pbxproj:25` defines `Koi in Resources`.
- `project.pbxproj:26` defines `Environment in Resources`.
- `project.pbxproj:167-170` includes these folders in `PBXResourcesBuildPhase`.

## Frozen runtime asset inventory

### Pond backgrounds

- `Assets/Pond/pond_background_dawn_2732x2048.png`
- `Assets/Pond/pond_background_day_2732x2048.png`
- `Assets/Pond/pond_background_moonlight_2732x2048.png`
- `Assets/Pond/pond_background_rain_2732x2048.png`
- `Assets/Pond/pond_background_winter_2732x2048.png`

### Water overlays

- `Assets/Water/caustics_loop_01.png`
- `Assets/Water/caustics_loop_02.png`
- `Assets/Water/caustics_soft_large.png`
- `Assets/Water/dark_edge_vignette.png`
- `Assets/Water/mote_soft.png`
- `Assets/Water/mote_tiny.png`
- `Assets/Water/rain_ripple_overlay.png`
- `Assets/Water/ripple_ring_01.png`
- `Assets/Water/ripple_ring_02.png`
- `Assets/Water/ripple_ring_soft_large.png`
- `Assets/Water/water_distortion_noise.png`
- `Assets/Water/water_veil_deep.png`
- `Assets/Water/water_veil_near.png`

### Koi atlases

- `Assets/Koi/koi_cream_red_atlas.png`
- `Assets/Koi/koi_kohaku_atlas.png`
- `Assets/Koi/koi_sanke_atlas.png`
- `Assets/Koi/koi_shiro_utsuri_atlas.png`
- `Assets/Koi/koi_showa_atlas.png`
- `Assets/Koi/koi_yamabuki_atlas.png`

### Environment assets

- `Assets/Environment/aquatic_grass_01.png`
- `Assets/Environment/aquatic_grass_02.png`
- `Assets/Environment/lotus_bud_pink.png.png`
- `Assets/Environment/lotus_flower_pink.png`
- `Assets/Environment/lotus_flower_white.png`
- `Assets/Environment/lotus_leaf_01.png`
- `Assets/Environment/lotus_leaf_02.png`
- `Assets/Environment/lotus_leaf_03_small.png`
- `Assets/Environment/moss_stone_01.png`
- `Assets/Environment/moss_stone_02_flat.png`
- `Assets/Environment/moss_stone_03_small.png`
- `Assets/Environment/petal_01.png`
- `Assets/Environment/petal_02.png`
- `Assets/Environment/petal_03_small.png`
- `Assets/Environment/petal_04_pale.png`

## Current visual status

Confirmed by user-provided project state:

- Pond background loading is visible after Phase 1B visibility fix.
- Visual quality is still far from the NEKO POND design blueprint.
- Settings UI is prototype-level.
- Koi, water overlays, environment decorations, ripples, HUD, onboarding, and settings are not fully rebuilt against the frozen design system.

Confirmed by file inspection:

- `PondSpriteScene` currently uses frozen day background in `makePondBackgroundLayer`.
- Several current visual layers are procedural images from `PondSpriteAssets`, not frozen asset files.
- Current koi sprites are procedural from `PondSpriteAssets.koiBodyTexture(config:)`, not atlas-backed sprites.
- Current environment uses procedural lotus, stone, petal textures.
- Current mote and ripple textures are procedural.

Evidence:

- `PondSpriteScene.swift:214` uses `Pond/pond_background_day_2732x2048.png`.
- `PondSpriteScene.swift:146` uses `PondSpriteAssets.deepWaterTexture`.
- `PondSpriteScene.swift:155` uses `PondSpriteAssets.causticsTexture`.
- `PondSpriteScene.swift:166` uses `PondSpriteAssets.fogTexture`.
- `PondSpriteScene.swift:187` uses `PondSpriteAssets.vignetteTexture`.
- `PondSpriteScene.swift:305` uses `PondSpriteAssets.koiBodyTexture(config:)`.
- `PondSpriteScene.swift:370` uses `PondSpriteAssets.lotusLeafTexture`.
- `PondSpriteScene.swift:383` uses `PondSpriteAssets.stoneTexture`.
- `PondSpriteScene.swift:396` uses `PondSpriteAssets.petalTexture`.
- `PondSpriteScene.swift:420` uses `PondSpriteAssets.moteTexture()`.
- `PondSpriteScene.swift:448` uses `PondSpriteAssets.rippleTexture`.

## Current Settings, HUD, onboarding status

Confirmed:

- `ContentView.swift` contains `PondSettings`, `CatPlayHUD`, `SettingsScreen`, `SettingsHeader`, `SettingsNavRow`, `SettingsRow`, `OnboardingView`, and `DesignToken` in one file.
- Settings includes mood, fish count, sensitivity, soundscape, ripple strength, night brightness, cat safe mode, hide UI timer, and reset.
- HUD currently shows a subtle `NEKO POND` label and a gear button.
- Onboarding currently has four pages and a start button.

Evidence:

- `ContentView.swift:76` defines `PondSettings`.
- `ContentView.swift:131` defines `CatPlayHUD`.
- `ContentView.swift:179` defines `SettingsScreen`.
- `ContentView.swift:274` defines `OnboardingView`.
- `ContentView.swift:311` defines `DesignToken`.

## Current known warnings/logs

Confirmed debug logs in source:

- `PondTextureCache` logs missing assets in DEBUG.
- `PondSpriteScene` logs background load failure in DEBUG.
- `PondSpriteScene` logs scene size, background status, background texture/node size, position, zPosition, and overlay alphas in DEBUG.

Evidence:

- `PondTextureCache.swift:49-52` prints `PondTextureCache missing asset` under `#if DEBUG`.
- `PondSpriteScene.swift:220-222` prints background fallback.
- `PondSpriteScene.swift:247-257` prints layer debug diagnostics.

Known warning classes from user requirements:

- Info.plist orientation warning plan is needed.
- State update warning plan is needed.
- `UIDevice.orientation` warning plan is needed.
- Accessibility simulator duplicate warning classification is needed.

Assumption:

- These warning classes have been observed in builds/runs, but they were not reproduced during this planning task.

## Quarantined legacy SceneKit status

Confirmed by user-provided project state:

- Legacy SceneKit files were quarantined from target compilation.

Confirmed by project inspection:

- `PondScene.swift` exists in `App/iPadOS/NekoPond`.
- `PondScene.swift` appears to contain SceneKit runtime code from grep output.
- The current `ContentView` runtime path does not instantiate `PondScene`.

Caution:

- Do not delete `PondScene.swift` in near-term visual reconstruction phases.
- Do not solve SpriteKit implementation issues by reviving SceneKit.
- Future decision about removing legacy SceneKit files belongs in `13-open-questions-and-decision-log.md`.

## Current files that must not be deleted

Do not delete:

- `App/iPadOS/NekoPond/ContentView.swift`
- `App/iPadOS/NekoPond/NekoPondApp.swift`
- `App/iPadOS/NekoPond/PondSpriteScene.swift`
- `App/iPadOS/NekoPond/PondAssetRegistry.swift`
- `App/iPadOS/NekoPond/PondTextureCache.swift`
- `App/iPadOS/NekoPond/PondSpriteModels.swift`
- `App/iPadOS/NekoPond/PondSpriteAssets.swift`
- `App/iPadOS/NekoPond/FishMovementComponent.swift`
- `App/iPadOS/NekoPond/FishSteeringSystem.swift`
- `App/iPadOS/NekoPond/EdgeAvoidanceBehavior.swift`
- `App/iPadOS/NekoPond/MotionTuning.swift`
- `App/iPadOS/NekoPond/FishEntity.swift`
- `App/iPadOS/NekoPond/PondScene.swift`
- `App/iPadOS/NekoPond/SceneLifecycle.swift`
- `App/iPadOS/NekoPond/LaunchScreen.storyboard`
- `App/iPadOS/NekoPond.xcodeproj/project.pbxproj`
- All frozen assets under `Assets/Pond`, `Assets/Water`, `Assets/Koi`, `Assets/Environment`.
- All design blueprint images under `Design/NEKO POND Design Blueprint V1`.

## Current files safe to edit in later phases

Only when the target phase explicitly allows them:

- `App/iPadOS/NekoPond/PondSpriteScene.swift` — visual SpriteKit layer construction, frozen asset usage, touch ripples, koi placement/motion sync.
- `App/iPadOS/NekoPond/PondAssetRegistry.swift` — only if a missing relative path enum/helper is needed; do not rename frozen asset paths.
- `App/iPadOS/NekoPond/PondTextureCache.swift` — only for safe caching/preload improvements.
- `App/iPadOS/NekoPond/PondSpriteModels.swift` — zPosition constants, koi config mapping, atlas metadata types if needed.
- `App/iPadOS/NekoPond/ContentView.swift` — Settings/HUD/onboarding phases only.
- New Swift files under `App/iPadOS/NekoPond/` — only if the phase explicitly allows project file changes and target membership updates.

## Known technical risks

- Atlas slicing cannot be implemented correctly until frame layout metadata is confirmed.
- `PondTextureCache.texture(for:)` uses `SKTexture(imageNamed: url.path)`; if runtime behavior differs across devices/simulators, future phases may need to verify loading and consider `SKTexture(image:)` from `UIImage(contentsOfFile:)` or `Data`.
- `PondSpriteScene.didChangeSize` calls `rebuildLayers()`, which removes and recreates all SpriteKit children; this may be acceptable now but can be expensive during repeated resize/orientation changes.
- `rebuildLayers()` uses randomness for petals and fish depth, so visual state may change on resize.
- `PondSpriteScene.apply(settings:)` changes mood background color but does not yet switch pond background textures by mood.
- Current `PondSettings` lives inside `ContentView.swift`; future splitting requires Xcode project updates.
- Current debug logs may be too noisy for release and must be controlled before release readiness.
- The working tree has many untracked files; future agents must not use broad `git add`, `git clean`, `git reset`, or destructive cleanup.

## Known visual risks

- Procedural water, koi, and environment art clash with frozen realistic assets.
- Over-bright caustics, ripples, or particles can become distracting for cats.
- Koi must remain large and trackable on iPad landscape; small realistic sprites are not acceptable if cats cannot follow them.
- UI must vanish during cat play; persistent labels/buttons can distract from the pond.
- Environment decoration density must not obscure fish.
- Mood modes must preserve cat readability even when darker or rainy.

## Implementation baseline summary

The app is ready for narrow visual replacement phases. Phase 1C should change only water overlays/atmosphere in `PondSpriteScene` using existing frozen Water assets and current texture cache, preserving the visible Phase 1B pond background baseline.
