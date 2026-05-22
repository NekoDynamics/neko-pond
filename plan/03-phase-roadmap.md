# 03 — Phase roadmap

Every phase must be small, testable, visually verifiable, and reversible. Future agents must implement exactly one phase per execution.

Common validation command for build phases:

```bash
xcodebuild -project App/iPadOS/NekoPond.xcodeproj -scheme NekoPond -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M4)' -derivedDataPath /tmp/NekoPondDerivedData build
```

If that exact simulator is unavailable, list available iPad simulators and use the nearest iPad landscape target. Report the substituted destination.

Common screenshot requirement for visual phases:

- Launch in iPad landscape simulator.
- Capture at least one full-screen pond screenshot.
- For interaction phases, capture before/after or short video evidence.
- Report screenshot path or clearly state if simulator capture could not be completed.

## Phase 1A — resource integration baseline

### Objective

Ensure frozen runtime asset folders are included in app resources and can be resolved from the bundle.

### Exact files likely to change

Already completed according to current state. If revisited:

- `App/iPadOS/NekoPond.xcodeproj/project.pbxproj`
- `App/iPadOS/NekoPond/PondAssetRegistry.swift`
- `App/iPadOS/NekoPond/PondTextureCache.swift`

### Forbidden files

- `Assets/**` file names/content.
- `Design/**`
- `docs/**`
- SwiftUI UI files unless needed for asset validation display.

### Validation commands

```bash
find Assets/Pond Assets/Water Assets/Koi Assets/Environment -maxdepth 1 -type f | sort
xcodebuild -project App/iPadOS/NekoPond.xcodeproj -scheme NekoPond -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M4)' -derivedDataPath /tmp/NekoPondDerivedData build
```

### Screenshot requirements

None unless a visual debug screen is added, which is not recommended.

### Acceptance criteria

- Build succeeds.
- Xcode resources phase includes Pond, Water, Koi, Environment.
- Registry paths match actual asset names.
- `Environment/lotus_bud_pink.png.png` remains double-extension.

### Rollback plan

- Revert only project resource membership and registry/cache changes made in this phase.
- Do not delete assets.

### Stop conditions

- Xcode project cannot open/build.
- Asset paths are missing or renamed.
- Build resource phase loses any frozen folder.

## Phase 1B — frozen pond background visible

### Objective

Render the frozen pond background full-screen using SpriteKit aspect-fill.

### Exact files likely to change

Already completed according to current state. If revisited:

- `App/iPadOS/NekoPond/PondSpriteScene.swift`
- `App/iPadOS/NekoPond/PondTextureCache.swift` only if loading fails.

### Forbidden files

- `Assets/**`
- `Design/**`
- `docs/**`
- `App/iPadOS/NekoPond/ContentView.swift` unless SKView sizing is proven to be the issue.
- `App/iPadOS/NekoPond.xcodeproj/project.pbxproj` unless resources are absent.

### Validation commands

```bash
xcodebuild -project App/iPadOS/NekoPond.xcodeproj -scheme NekoPond -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M4)' -derivedDataPath /tmp/NekoPondDerivedData build
```

### Screenshot requirements

- Full-screen iPad landscape screenshot showing frozen pond background with no black bars.

### Acceptance criteria

- Background image is visible.
- Aspect-fill covers full scene.
- Procedural floor is used only as fallback.
- Debug log confirms background found in DEBUG if logging is present.

### Rollback plan

- Restore previous `makePondBackgroundLayer` logic.

### Stop conditions

- Background disappears.
- Scene size becomes zero.
- Build fails.

## Phase 1C — water overlay and atmosphere layer

### Objective

Replace procedural water overlays and atmosphere only, using frozen Water assets while preserving the visible Phase 1B pond background.

### Exact files likely to change

- `App/iPadOS/NekoPond/PondSpriteScene.swift`
- `App/iPadOS/NekoPond/PondSpriteModels.swift` only if zPosition naming must be adjusted.
- `App/iPadOS/NekoPond/PondAssetRegistry.swift` only if a helper is needed; existing paths should already be sufficient.

### Forbidden files

- `App/iPadOS/NekoPond/ContentView.swift`
- `App/iPadOS/NekoPond/PondSpriteAssets.swift` unless preserving fallback is necessary; do not rework procedural art.
- `App/iPadOS/NekoPond/Fish*.swift`
- `App/iPadOS/NekoPond/PondScene.swift`
- `Assets/**`
- `Design/**`
- `docs/**`
- `App/iPadOS/NekoPond.xcodeproj/project.pbxproj`

### Validation commands

```bash
xcodebuild -project App/iPadOS/NekoPond.xcodeproj -scheme NekoPond -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M4)' -derivedDataPath /tmp/NekoPondDerivedData build
```

### Screenshot requirements

- One iPad landscape screenshot before interaction.
- One screenshot after a tap if ripple visuals are not changed, to ensure overlay stack still allows ripples/fish visibility.

### Acceptance criteria

- `water_veil_deep.png`, `water_veil_near.png`, `caustics_loop_01.png`/`02.png` or `caustics_soft_large.png`, and `dark_edge_vignette.png` are used in runtime rendering.
- Pond background remains visible and not washed out.
- Caustics are slow, natural, and low intensity.
- Vignette is subtle.
- Fish and current procedural environment remain visible.
- Build succeeds.

### Rollback plan

- Revert only Phase 1C edits in `PondSpriteScene.swift` and any allowed support file.
- Restore procedural `PondSpriteAssets` overlay calls if frozen overlay causes regression.

### Stop conditions

- Any asset fails to load unexpectedly.
- Background becomes hidden or mostly opaque.
- Build fails.
- More than allowed files need changes.

## Phase K0 — reject failed koi experiment and return to stable baseline

### Objective

Reject the failed atlas-crop/frame-flipping/segmented-sticker koi direction and preserve or restore the last stable koi baseline before new warp work begins.

### Exact files likely to change

Implementation phase only; this planning update changes `plan/**` only. Future execution may touch koi runtime files only if needed to remove broken experiment code.

### Forbidden files

- `Assets/**` unless explicitly reverting generated failed assets in a dedicated asset cleanup phase.
- Unrelated SwiftUI, water, environment, or Xcode project files.

### Validation commands

```bash
xcodebuild -project App/iPadOS/NekoPond.xcodeproj -scheme NekoPond -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M4)' -derivedDataPath /tmp/NekoPondDerivedData build
```

### Acceptance criteria

- Atlas-crop rescue is no longer the planned koi path.
- Runtime is stable enough to begin isolated warp prototyping.
- No production Swift code is added for the new renderer in K0.

### Stop conditions

- Stable baseline cannot be identified.
- Cleanup requires broad unrelated rewrites.

## Phase K1 — regenerate one clean RGBA mesh-deformable koi texture

### Objective

Create or import one clean, single-body, top-down RGBA koi PNG suitable for SpriteKit mesh deformation.

### Required asset properties

- True RGBA PNG.
- Transparent background.
- No checkerboard.
- No white/black baked background.
- Single straight top-down koi body.
- Head facing right, tail left.
- Centered in canvas.
- Transparent padding for warp deformation.
- No baked fish shadow.

### Validation commands

Use image inspection, for example:

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

### Acceptance criteria

- One texture passes alpha/background/padding review.
- Asset is not committed into runtime folders unless the phase explicitly allows resource changes.

### Stop conditions

- Candidate contains baked checkerboard/background.
- Candidate is not suitable for deformation.

## Phase K2 — isolated single-fish SKWarpGeometryGrid prototype

### Objective

Build an isolated one-fish SpriteKit prototype proving `SKWarpGeometryGrid` can create believable swimming from one clean texture.

### Exact files likely to change

To be defined by the execution prompt. Prefer isolated/debug-only scope. Do not integrate into production pond flow yet.

### Required prototype behavior

- Cache original grid.
- Update destination grid per frame.
- Keep root node position/heading separate from deformation.
- Drive body curvature from turn intensity.
- Drive tail beat from speed.
- Use independent phase seed even with one fish.
- Avoid per-frame texture decoding.

### Validation commands

```bash
xcodebuild -project App/iPadOS/NekoPond.xcodeproj -scheme NekoPond -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M4)' -derivedDataPath /tmp/NekoPondDerivedData build
```

### Screenshot/video requirements

- Capture still screenshot and short video or repeated screenshots showing deformation.

### Acceptance criteria

- One fish appears flexible and alive while using one RGBA texture.
- No tearing, clipping, checkerboard, or sticker-like translation.
- Performance remains smooth.

### Stop conditions

- Warp deformation cannot be made believable with clean texture.
- Prototype requires engine/platform switch.

## Phase K3 — integrate warp koi into PondSpriteScene with one fish only

### Objective

Integrate the validated warp koi renderer into `PondSpriteScene` with exactly one active warp fish.

### Acceptance criteria

- Pond background, water, environment, ripples, and UI remain intact.
- One koi uses `SKWarpGeometryGrid` deformation in normal runtime.
- Fish root node handles position/heading; warp handles body/tail shape.
- No full atlas sheet display.
- No per-frame texture decoding.

### Stop conditions

- Integration destabilizes pond rendering.
- Fish becomes less readable than baseline.
- Build fails.

## Phase K4 — expand to 3–6 koi variants after asset validation

### Objective

Add multiple validated mesh-deformable koi textures and expand active warp fish count gradually.

### Acceptance criteria

- 3–6 koi variants pass RGBA/padding validation.
- Each fish has independent phase offset and non-synchronized motion.
- Fish remain cat-readable and do not overlap excessively.
- Performance remains stable.

### Stop conditions

- Any variant has background/alpha artifacts.
- Multi-fish warp cost is too high.

## Phase K5 — connect tap/flee/attraction behavior to warp parameters

### Objective

Couple interaction state to deformation parameters while preserving calm cat-safe behavior.

### Acceptance criteria

- Tap/flee briefly increases tail amplitude/frequency and turn curvature.
- Attraction subtly changes heading and body curve.
- Response feels alive but not startling.
- Fish return to calm state smoothly.

### Stop conditions

- Interaction creates panic darts, jitter, or game-like behavior.

## Phase K6 — final koi visual QA and performance tuning

### Objective

Perform final koi visual QA across moods, fish counts, and iPad landscape runtime.

### Acceptance criteria

- Koi no longer read as stickers.
- No atlas crop/frame-flip artifacts remain.
- All accepted koi assets are clean RGBA.
- Update loop has bounded cost.
- Visual quality is stable under Settings fish count changes.

### Stop conditions

- Performance or visual quality regresses below baseline.

## Phase 1F — environment asset replacement

### Objective

Replace procedural lotus, stones, grasses, and petals with frozen Environment assets only.

### Exact files likely to change

- `App/iPadOS/NekoPond/PondSpriteScene.swift`
- `App/iPadOS/NekoPond/PondSpriteModels.swift` only if layer constants are needed.
- `App/iPadOS/NekoPond/PondAssetRegistry.swift` only if helper mapping is needed.

### Forbidden files

- `App/iPadOS/NekoPond/ContentView.swift`
- `App/iPadOS/NekoPond/Fish*.swift`
- `App/iPadOS/NekoPond/PondScene.swift`
- `Assets/**`
- `Design/**`
- `docs/**`
- Xcode project.

### Validation commands

```bash
xcodebuild -project App/iPadOS/NekoPond.xcodeproj -scheme NekoPond -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M4)' -derivedDataPath /tmp/NekoPondDerivedData build
```

### Screenshot requirements

- iPad landscape screenshot showing lotus/stones/grasses/petals.
- Screenshot after resize/orientation if possible.

### Acceptance criteria

- Environment uses frozen assets.
- `Environment/lotus_bud_pink.png.png` loads using exact double-extension path.
- Environment placement frames the pond and does not block fish readability.
- Petal drift is calm and sparse.
- Build succeeds.

### Rollback plan

- Revert environment replacement and retain procedural assets if placement/loading fails.

### Stop conditions

- Any frozen Environment asset path appears missing.
- Layout obscures fish.
- Build fails.

## Phase 1G — ripple and touch feedback replacement

### Objective

Replace procedural ripple visuals with frozen Water ripple assets and tune touch feedback.

### Exact files likely to change

- `App/iPadOS/NekoPond/PondSpriteScene.swift`
- `App/iPadOS/NekoPond/PondSpriteModels.swift` only if layer order needs adjustment.

### Forbidden files

- SwiftUI Settings/HUD/onboarding code.
- Fish steering files unless touch behavior tuning is explicitly required.
- `Assets/**`
- `Design/**`
- `docs/**`
- Xcode project.

### Validation commands

```bash
xcodebuild -project App/iPadOS/NekoPond.xcodeproj -scheme NekoPond -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M4)' -derivedDataPath /tmp/NekoPondDerivedData build
```

### Screenshot requirements

- Screenshot or short video for single tap.
- Screenshot or short video for rapid multi-touch.

### Acceptance criteria

- Ripple uses `ripple_ring_01.png`, `ripple_ring_02.png`, or `ripple_ring_soft_large.png`.
- Ripple is gentle, visible, and fades cleanly.
- Multi-touch does not produce excessive nodes or harsh flashes.
- Fish response remains non-threatening.

### Rollback plan

- Restore previous ripple texture generation call or retain frozen texture with lower alpha/scale.

### Stop conditions

- Touch handling breaks.
- Ripple nodes leak or accumulate.
- Visual effect becomes loud or game-like.

## Phase 2A — settings UI reconstruction

### Objective

Reconstruct Settings UI only, matching Sheet 06 premium human-control style.

### Exact files likely to change

- `App/iPadOS/NekoPond/ContentView.swift`

Optional only if explicitly approved inside this phase:

- New SwiftUI component files under `App/iPadOS/NekoPond/` and corresponding Xcode project membership.

### Forbidden files

- `App/iPadOS/NekoPond/PondSpriteScene.swift` unless a binding bug blocks Settings display.
- `App/iPadOS/NekoPond/PondAssetRegistry.swift`
- `App/iPadOS/NekoPond/PondTextureCache.swift`
- `App/iPadOS/NekoPond/PondSpriteModels.swift`
- `App/iPadOS/NekoPond/Fish*.swift`
- `App/iPadOS/NekoPond/PondScene.swift`
- `Assets/**`
- `Design/**`
- `docs/**`

### Validation commands

```bash
xcodebuild -project App/iPadOS/NekoPond.xcodeproj -scheme NekoPond -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M4)' -derivedDataPath /tmp/NekoPondDerivedData build
```

### Screenshot requirements

- iPad landscape screenshot of Settings open.
- Screenshot after changing one segmented control and one slider.
- Screenshot after closing Settings back to pond.

### Acceptance criteria

- Settings visually reads as premium glass UI.
- Sidebar/content layout is clear and stable in landscape.
- Controls remain functional.
- No SpriteKit visual regression.
- No persistent game-style UI is introduced.

### Rollback plan

- Revert only `ContentView.swift` Settings-related changes.
- Keep existing settings model values unless the phase intentionally changed defaults.

### Stop conditions

- Settings controls stop binding.
- Build fails.
- Layout breaks on iPad landscape.

## Phase 2B — vanishing HUD reconstruction

### Objective

Reconstruct HUD behavior and visuals so human UI vanishes during cat play.

### Exact files likely to change

- `App/iPadOS/NekoPond/ContentView.swift`

### Forbidden files

- SpriteKit rendering files unless touch callback routing is proven broken.
- `Assets/**`
- `Design/**`
- `docs/**`

### Validation commands

```bash
xcodebuild -project App/iPadOS/NekoPond.xcodeproj -scheme NekoPond -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M4)' -derivedDataPath /tmp/NekoPondDerivedData build
```

### Screenshot requirements

- HUD visible immediately after recall.
- HUD hidden after timer.
- Settings reveal from HUD/corner behavior.

### Acceptance criteria

- No persistent UI during cat play.
- Human can recall controls reliably.
- HUD is low contrast and premium.
- HUD does not block pond touches except intentional controls.

### Rollback plan

- Restore previous `CatPlayHUD` and `recallHUD()` behavior.

### Stop conditions

- Settings becomes inaccessible.
- HUD never hides.
- HUD blocks cat touch area.

## Phase 2C — onboarding reconstruction

### Objective

Reconstruct first-run onboarding and safe iPad placement flow.

### Exact files likely to change

- `App/iPadOS/NekoPond/ContentView.swift`

### Forbidden files

- SpriteKit rendering files.
- Asset files.
- Xcode project unless explicitly splitting files.

### Validation commands

```bash
xcodebuild -project App/iPadOS/NekoPond.xcodeproj -scheme NekoPond -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M4)' -derivedDataPath /tmp/NekoPondDerivedData build
```

### Screenshot requirements

- Launch onboarding page.
- Safe iPad placement page.
- Start pond transition/result.

### Acceptance criteria

- Onboarding is calm and premium.
- It clearly communicates safety and vanishing UI.
- First-run state works.
- Starting pond returns to full-screen cat play.

### Rollback plan

- Restore previous `OnboardingView` implementation.

### Stop conditions

- User cannot enter pond.
- `@AppStorage` first-run state breaks.
- Layout fails in landscape.

## Phase 3A — settings-to-runtime binding

### Objective

Complete and verify settings bindings from SwiftUI to SpriteKit runtime.

### Exact files likely to change

- `App/iPadOS/NekoPond/ContentView.swift`
- `App/iPadOS/NekoPond/PondSpriteScene.swift`
- `App/iPadOS/NekoPond/PondSpriteModels.swift` only if typed mapping needed.

### Forbidden files

- Frozen assets.
- Design files.
- Legacy SceneKit files.

### Validation commands

```bash
xcodebuild -project App/iPadOS/NekoPond.xcodeproj -scheme NekoPond -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M4)' -derivedDataPath /tmp/NekoPondDerivedData build
```

### Screenshot requirements

- Fish count low/high.
- Mood change if implemented.
- Ripple strength low/high.

### Acceptance criteria

- Settings changes visibly affect runtime.
- No state update warnings from unsafe SwiftUI update timing.
- Defaults reset correctly.

### Rollback plan

- Revert binding additions while preserving UI layout.

### Stop conditions

- State update warning indicates undefined SwiftUI behavior.
- Runtime crashes when settings change.

## Phase 3B — mood modes dawn/day/rain/moonlight/winter

### Objective

Implement full mood-specific visual tuning.

### Exact files likely to change

- `App/iPadOS/NekoPond/PondSpriteScene.swift`
- `App/iPadOS/NekoPond/PondSpriteModels.swift`
- `App/iPadOS/NekoPond/PondAssetRegistry.swift` only for helper mapping.

### Forbidden files

- Settings UI layout unless mood control is broken.
- Frozen assets.
- Design files.

### Validation commands

```bash
xcodebuild -project App/iPadOS/NekoPond.xcodeproj -scheme NekoPond -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M4)' -derivedDataPath /tmp/NekoPondDerivedData build
```

### Screenshot requirements

- One screenshot for each mood.

### Acceptance criteria

- Each mood uses correct pond background.
- Fish remain readable in all moods.
- Rain/moonlight/winter do not become too dark or noisy.
- Mood transitions are stable.

### Rollback plan

- Restore fixed day background and previous alpha values.

### Stop conditions

- Mood switching hides background/fish.
- Performance drops from rebuilding too often.

## Phase 3C — cat interaction tuning

### Objective

Tune fish and water interaction for cat-first readability and calm behavior.

### Exact files likely to change

- `App/iPadOS/NekoPond/PondSpriteScene.swift`
- `App/iPadOS/NekoPond/FishMovementComponent.swift`
- `App/iPadOS/NekoPond/FishSteeringSystem.swift`
- `App/iPadOS/NekoPond/MotionTuning.swift`
- `App/iPadOS/NekoPond/EdgeAvoidanceBehavior.swift`

### Forbidden files

- SwiftUI Settings reconstruction unless adding a direct binding.
- Assets.
- Design files.
- Legacy SceneKit.

### Validation commands

```bash
xcodebuild -project App/iPadOS/NekoPond.xcodeproj -scheme NekoPond -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M4)' -derivedDataPath /tmp/NekoPondDerivedData build
```

### Screenshot requirements

- Short video or repeated screenshots for tap near fish, tap away from fish, rapid touches, and return-to-calm.

### Acceptance criteria

- Koi remain calm, readable, and non-threatening.
- Long press attraction works if implemented.
- Repeated cat taps do not create panic motion.
- Fish return to calm swim.

### Rollback plan

- Revert tuning constants separately from rendering changes.

### Stop conditions

- Fish jitter, spin, escape bounds, or disappear.
- Interaction becomes game-like or stressful.

## Phase 4A — performance optimization

### Objective

Optimize rendering and memory without changing product direction.

### Exact files likely to change

- `App/iPadOS/NekoPond/PondSpriteScene.swift`
- `App/iPadOS/NekoPond/PondTextureCache.swift`
- `App/iPadOS/NekoPond/PondSpriteModels.swift`

### Forbidden files

- UI redesign files unless performance issue is in UI overlays.
- Assets unless a future explicit asset optimization task is approved.

### Validation commands

```bash
xcodebuild -project App/iPadOS/NekoPond.xcodeproj -scheme NekoPond -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M4)' -derivedDataPath /tmp/NekoPondDerivedData build
```

### Screenshot requirements

- Same visual baseline screenshots before/after optimization.

### Acceptance criteria

- No visual regression.
- Stable frame pacing in simulator/device.
- Texture preloading/caching avoids repeated loads.
- Multi-touch remains stable.

### Rollback plan

- Revert optimization commits/edits in smallest chunks.

### Stop conditions

- Optimization changes visuals unexpectedly.
- Memory improves at cost of fish readability.

## Phase 4B — iPad device compatibility and orientation cleanup

### Objective

Verify iPad landscape behavior, orientation declarations, safe area, and system warning status.

### Exact files likely to change

- `App/iPadOS/NekoPond/ContentView.swift`
- `App/iPadOS/NekoPond/NekoPondApp.swift`
- `App/iPadOS/NekoPond.xcodeproj/project.pbxproj` or generated Info.plist settings only if needed.

### Forbidden files

- SpriteKit visual changes unless resize/orientation bug is in scene.
- Assets.
- Design files.

### Validation commands

```bash
xcodebuild -project App/iPadOS/NekoPond.xcodeproj -scheme NekoPond -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M4)' -derivedDataPath /tmp/NekoPondDerivedData build
```

### Screenshot requirements

- Landscape left and landscape right if supported.
- Any portrait behavior if app can rotate there; preferred product is iPad landscape full-screen.

### Acceptance criteria

- App opens in intended iPad orientation.
- No black bars or clipped Settings panels.
- Known warnings are classified or resolved.

### Rollback plan

- Revert orientation/project setting changes if they break launch.

### Stop conditions

- App cannot launch on simulator.
- Orientation change breaks scene size.

## Phase 4C — final QA and release readiness

### Objective

Final validation, warning cleanup, release blocker classification, and readiness report.

### Exact files likely to change

- Minimal targeted fixes only.
- Likely files depend on discovered issues.

### Forbidden files

- Broad redesigns.
- New feature work.
- Asset renames.
- Legacy SceneKit revival.

### Validation commands

```bash
xcodebuild -project App/iPadOS/NekoPond.xcodeproj -scheme NekoPond -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M4)' -derivedDataPath /tmp/NekoPondDerivedData clean build
```

### Screenshot requirements

- Final pond screenshot per mood.
- Settings screenshot.
- HUD hidden/visible screenshots.
- Onboarding screenshots if first-run reset is available.

### Acceptance criteria

- Clean build or only accepted simulator noise.
- No release blocker warnings.
- Visual target matches blueprint direction.
- No game-like UI or effects.
- Cat interaction is calm and readable.

### Rollback plan

- Revert any final targeted fix that introduces regression.

### Stop conditions

- New crash.
- Build failure.
- Major visual regression.
- Any unresolved release blocker.
