# 02 — Target architecture

This document defines the intended NEKO POND architecture for the reconstruction. It is a target boundary map, not permission for broad refactoring.

## Architecture summary

Target runtime path remains:

```text
SwiftUI app shell
  -> SKView bridge
  -> PondSpriteScene
  -> frozen asset registry + texture cache
  -> SpriteKit layer stack + fish behavior + touch interaction
```

Do not replace this path during current reconstruction.

## SwiftUI shell responsibilities

Files now involved:

- `App/iPadOS/NekoPond/NekoPondApp.swift`
- `App/iPadOS/NekoPond/ContentView.swift`

Target responsibilities:

- Own the app-level SwiftUI composition.
- Host `SKView` through `PondSpriteView`.
- Own human-only UI state:
  - onboarding visible/dismissed
  - HUD visible/hidden
  - Settings visible/hidden
  - hide UI timer task
- Own or inject `PondSettings` until a later split is approved.
- Apply scene lifecycle activation/deactivation on SwiftUI `scenePhase` changes.
- Hide status bar and system overlays for immersive pond mode.
- Provide Settings, HUD, and onboarding overlays without interfering with cat play.

Non-responsibilities:

- Do not draw water, fish, ripples, motes, lotus, stones, or petals in SwiftUI.
- Do not implement fish behavior in SwiftUI.
- Do not add a game HUD, score, coins, levels, or achievements.

## SpriteKit runtime responsibilities

Primary file now involved:

- `App/iPadOS/NekoPond/PondSpriteScene.swift`

Target responsibilities:

- Build and maintain the full pond visual layer stack.
- Load frozen Pond, Water, Koi, and Environment textures through `PondTextureCache`.
- Maintain fish nodes, fish shadows, and fish movement components.
- Convert between scene coordinates and pond world coordinates.
- Handle pond touches, multi-touch ripples, and fish interaction inputs.
- Apply mood and settings changes to visual alpha, active fish count, interaction sensitivity, and later background selection.
- Keep frame updates bounded and smooth.
- Rebuild or resize layers safely on scene size changes.

Non-responsibilities:

- Do not own human Settings UI.
- Do not present SwiftUI overlays.
- Do not load network assets.
- Do not manage persistence beyond runtime state.

## Asset registry responsibilities

Primary file:

- `App/iPadOS/NekoPond/PondAssetRegistry.swift`

Target responsibilities:

- Be the source of truth for frozen asset bundle-relative paths.
- Preserve exact frozen file names.
- Expose clear enum cases for Pond backgrounds, Water overlays, Koi atlases, and Environment assets.
- Provide `allRuntimeAssetPaths` for validation/preload.
- Include special-case exact path `Environment/lotus_bud_pink.png.png`.

Non-responsibilities:

- Do not load images/textures.
- Do not choose scene layout.
- Do not rename or normalize frozen asset names.

## Texture cache responsibilities

Primary file:

- `App/iPadOS/NekoPond/PondTextureCache.swift`

Target responsibilities:

- Resolve safe bundle-relative paths.
- Reject empty paths and traversal paths.
- Cache `SKTexture` instances by asset path.
- Validate asset availability.
- Preload grouped textures where useful.
- Log missing assets only in DEBUG.

Non-responsibilities:

- Do not contain visual layout decisions.
- Do not silently generate procedural substitutes except through caller-controlled fallbacks.
- Do not mutate assets.

## Settings model responsibilities

Current location:

- `App/iPadOS/NekoPond/ContentView.swift:76` defines `PondSettings`.

Target responsibilities:

- Store user-facing pond settings:
  - mood
  - fish count
  - interaction sensitivity
  - soundscape
  - ripple strength
  - night brightness
  - cat safe mode
  - hide UI timer
  - pause state
- Provide safe defaults and reset.
- Later, move to a separate file only if a phase explicitly allows project updates.

Non-responsibilities:

- Do not store SpriteKit nodes.
- Do not know asset file paths unless a future design requires a typed setting.
- Do not perform rendering.

## Scene layer responsibilities

Use `PondLayerZ` or a successor with stable ordering:

1. Floor/background.
2. Deep water or near-water veil.
3. Caustics.
4. Fog/atmosphere veil.
5. Koi shadows.
6. Koi bodies.
7. Environment objects.
8. Petals.
9. Ripples.
10. Motes/particles.
11. Vignette.

Layer-specific responsibilities:

- Background: aspect-fill frozen pond background.
- Deep water: subtle color/veil depth, not an opaque cover.
- Caustics: slow, low-alpha, non-flashing light movement.
- Fog/veil: depth and calm, no milky washout.
- Koi shadow: soft depth cue below fish.
- Koi body: readable atlas-backed fish.
- Environment: lotus, stones, grasses around edges and selected calm focal areas.
- Petals: sparse floating motion.
- Ripples: touch feedback only, pooled or cleaned up.
- Motes: underwater depth, sparse and soft.
- Vignette: subtle edge focus, never heavy black border.

## Touch interaction responsibilities

Current file:

- `App/iPadOS/NekoPond/PondSpriteScene.swift`

Target behavior:

- `touchesBegan`: create strong but gentle ripple, classify fish proximity, trigger near-fish response or water tap response.
- `touchesMoved`: create weaker ripples with throttling if needed.
- Multi-touch: support several simultaneous ripples but cap active nodes.
- Long press: later add attraction/curiosity behavior, not aggressive feeding/game behavior.
- Direct fish touch: gentle flee and return-to-calm.
- Human HUD recall: maintain `onTapWater` callback or a clearer equivalent.

## Fish behavior responsibilities

Current files:

- `App/iPadOS/NekoPond/FishMovementComponent.swift`
- `App/iPadOS/NekoPond/FishSteeringSystem.swift`
- `App/iPadOS/NekoPond/EdgeAvoidanceBehavior.swift`
- `App/iPadOS/NekoPond/MotionTuning.swift`
- `App/iPadOS/NekoPond/PondSpriteScene.swift`
- `App/iPadOS/NekoPond/PondSpriteModels.swift`

Target behavior:

- Calm wandering, schooling spacing, edge avoidance.
- Smooth heading changes; no sudden 180-degree snaps.
- Cat touch response:
  - near fish: gentle flee/attention
  - far water: subtle curiosity/attraction
  - repeated touches: avoid panic escalation
- Fish count 3–9 from Settings.
- Large trackable sprites.
- Koi shadow and depth scale remain consistent.

## Mood/background responsibilities

Target mood modes:

- dawn
- day
- rain
- moonlight
- winter

Each mood should eventually control:

- pond background asset
- water veil alpha
- caustics alpha/speed
- vignette alpha
- rain overlay visibility/alpha
- mote color/alpha
- fish readability compensation

Phase rule:

- Do not implement all mood modes during Phase 1C–1F unless the phase explicitly asks for it. Preserve current mood behavior unless a targeted phase changes it.

## Debug/logging policy

Allowed during visual reconstruction:

- DEBUG-only logs for missing assets.
- Temporary DEBUG-only layer diagnostics only when validating a visual phase.

Not allowed for release readiness:

- Repeated per-frame logs.
- Verbose layer dumps on every resize once the visual baseline is stable.
- Logs that imply missing assets when fallback is acceptable but expected.

Target:

- By Phase 4C, remove or gate noisy debug logs.

## File/module boundaries

Current recommended boundaries:

- `ContentView.swift`: SwiftUI shell, Settings prototype/reconstruction, HUD, onboarding, current settings model.
- `PondSpriteScene.swift`: SpriteKit rendering and interaction assembly.
- `PondSpriteModels.swift`: lightweight render model constants and koi config data.
- `PondAssetRegistry.swift`: asset path enums only.
- `PondTextureCache.swift`: loading/caching only.
- `Fish*` and `MotionTuning.swift`: fish movement logic.
- `PondSpriteAssets.swift`: procedural fallback textures only; usage should shrink as frozen assets replace procedural visuals.
- `PondScene.swift`: quarantined legacy SceneKit; do not use for active path.

Potential future files if explicitly approved:

- `PondSettings.swift`
- `PondSettingsView.swift`
- `PondHUDView.swift`
- `PondOnboardingView.swift`
- `KoiAtlasMetadata.swift`
- `PondEnvironmentLayout.swift`

Creating these requires updating Xcode target membership and is not allowed unless the phase says so.

## What should not be done

- Do not move to Unity.
- Do not move to WebGL.
- Do not move to Flutter.
- Do not replace SpriteKit with Metal in the current phase.
- Do not rebuild the whole app shell prematurely.
- Do not revive SceneKit as the active runtime path.
- Do not rename frozen assets.
- Do not create compatibility APIs for legacy code unless the active SpriteKit path requires them.
- Do not perform broad refactors while replacing visuals.
- Do not modify `Assets/`, `Design/`, `docs/`, or the Xcode project during narrow visual phases unless explicitly allowed.
