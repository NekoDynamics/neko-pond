# 05 — SpriteKit rendering plan

This document defines the target SpriteKit rendering reconstruction for `PondSpriteScene`.

## Scene coordinate system

Current confirmed behavior:

- `PondSpriteScene` uses `anchorPoint = CGPoint(x: 0.0, y: 0.0)`.
- Scene center is computed as `(size.width * 0.5, size.height * 0.5)`.
- Pond world bounds are `CGRect(x: -10.0, y: -6.0, width: 20.0, height: 12.0)`.
- Scene scale is `min(size.width, size.height) / 12.0`.
- `worldToScene` maps world point to center plus scaled world offset.
- `sceneToWorld` reverses that transform.

Target:

- Keep this coordinate model through early visual phases.
- Use world coordinates for fish and environment placement.
- Use full scene coordinates for background, veils, caustics, vignette, and broad effects.
- Do not change anchor point or world bounds unless a dedicated movement/layout phase requests it.

## Scene lifecycle

Current confirmed behavior:

- `didMove(to:)` sets background color, anchor, scale mode, fallback size, then rebuilds layers.
- `didChangeSize(_:)` rebuilds layers when size changes.
- `activate()` starts simulation and resets time.
- `deactivate()` stops simulation and resets time.

Target:

- Preserve lifecycle semantics.
- Avoid per-frame node creation except touch ripples/particles.
- Long term: replace full rebuild-on-resize with resize/update existing nodes if performance requires it.

## Resize handling

Current:

- `didChangeSize` calls `rebuildLayers()`.

Target for current phases:

- Maintain visual correctness before optimization.
- Ensure background and overlays re-aspect-fill or resize correctly.
- Ensure fish/environment regenerate consistently enough for screenshot validation.

Future optimization:

- Keep stable node references.
- Resize full-screen nodes in place.
- Recalculate fish/environment positions without randomizing persistent state.

## zPosition layer stack

Current `PondLayerZ` values:

- `floor = 0`
- `deepWater = 1`
- `caustics = 2`
- `fogVeil = 3`
- `koiShadow = 4`
- `koi = 5`
- `environment = 6`
- `petals = 7`
- `ripples = 8`
- `particles = 9`
- `vignette = 10`

Target ordering:

1. Floor/background (`0`)
2. Deep water / deep veil (`1`)
3. Caustics (`2`)
4. Near veil / fog (`3`)
5. Koi shadow (`4`)
6. Koi sprite (`5`)
7. Environment (`6`) with per-node offsets if some stones should sit below fish
8. Petals (`7`)
9. Ripples (`8`)
10. Motes/particles (`9`)
11. Vignette (`10`)

Do not place UI in SpriteKit zPositions; human UI belongs to SwiftUI.

## Aspect-fill rules

Use for:

- Pond backgrounds.
- Full-screen vignettes if texture ratio must be preserved.
- Full-screen water overlays when stretching would distort visible features.

Rules:

- Compute `scale = max(targetWidth / textureWidth, targetHeight / textureHeight)`.
- Node size = texture size × scale.
- Anchor = center.
- Position = scene center.
- Crop by scene edges; never letterbox.

## Background layer

Current:

- `makePondBackgroundLayer` loads `Pond/pond_background_day_2732x2048.png` through `PondTextureCache`.

Target:

- Keep frozen background visible at all times.
- Phase 3B should select background by `PondSettings.Mood`.
- Fallback procedural floor may remain for emergency but missing frozen background is a stop condition.

Validation:

- Screenshot must show pond image details, not just teal overlay.

## Deep water layer

Current:

- Procedural `PondSpriteAssets.deepWaterTexture` at alpha 0.16.

Target Phase 1C:

- Replace with `Water/water_veil_deep.png` and optionally `Water/water_veil_near.png`.
- Keep alpha low.
- Use blend mode `.alpha` unless testing supports better result.
- Do not fully cover background.

## Caustics layers

Current:

- One procedural caustics layer with `.add`, drift, and fade.

Target Phase 1C:

- Use one or two frozen caustic textures:
  - `Water/caustics_loop_01.png`
  - `Water/caustics_loop_02.png`
  - `Water/caustics_soft_large.png`
- Slow drift and subtle alpha pulsing.
- Avoid high-frequency flashing.
- Additive blend may be used if visually natural.

Suggested target:

- Large soft caustics: low alpha, slow drift.
- Loop caustics: lower alpha, opposite slow drift.

## Veil/fog layers

Current:

- Procedural fog texture at alpha 0.12.

Target:

- Use `water_veil_near.png` as near-surface fog/veil if visually appropriate.
- Keep it below fish if it obscures koi; place above fish only if very subtle and necessary for underwater feel.
- Avoid milky gray washout.

## Koi shadow layer

Current:

- Procedural shadow texture generated from body size.

Target:

- Preserve soft shadow while replacing koi body first.
- Shadow can remain procedural until a better frozen shadow asset exists.
- Keep below koi and offset slightly down/right or based on light direction.
- Shadow alpha must not make fish look like floating stickers.

## Koi warp renderer layer

Current:

- Procedural body texture or failed atlas experiments may exist in local history.

Target:

- Use an `SKSpriteNode` with one clean RGBA koi body texture per fish.
- Apply `SKWarpGeometryGrid` as the primary koi deformation technique.
- Cache the original grid when the fish node is created.
- Update the destination grid per frame from movement state.
- Keep fish root node position, heading, depth scale, and visibility separate from deformation.
- Derive body curvature from smoothed turn intensity.
- Derive tail beat amplitude/frequency from smoothed speed.
- Assign independent phase offset per fish.
- Keep head deformation minimal for heading readability.
- Avoid per-frame texture decoding.
- Avoid per-frame atlas cropping.
- Never display a full atlas sheet as a fish.

Implementation constraints:

- Start with one fish only in Phase K3.
- Expand to 3–6 only after each asset passes RGBA/padding validation.
- Keep procedural or previous stable koi as rollback baseline until warp koi is accepted.

## Environment layer

Current:

- Procedural lotus and stones.

Target Phase 1F:

- Use frozen lotus, stone, and grass PNGs.
- Place larger elements near edges/corners.
- Use z offsets to avoid covering fish paths too much.
- Keep environment calm and sparse.

## Petal layer

Current:

- Procedural petals with gentle drift.

Target Phase 1F:

- Use frozen petal assets.
- Keep sparse count.
- Drift slowly with subtle rotation.
- Avoid confetti look.

## Mote layer

Current:

- `SKEmitterNode` with procedural mote texture.

Target:

- Use `Water/mote_soft.png` or `Water/mote_tiny.png` as particle texture.
- Low birth rate and low alpha.
- No loud sparkle effect.
- Avoid excessive particles on older iPads.

## Ripple layer

Current:

- Procedural ring texture, node appended to `ripplePool`, scale/fade action, removed on completion.

Target Phase 1G:

- Use frozen ripple ring textures.
- Cap active ripple nodes or clean aggressively.
- Multi-touch should remain calm.
- Ripple layer above fish/environment is acceptable if alpha is low; if it visually covers fish too much, test below petals or below fish.

## Vignette layer

Current:

- Procedural vignette at alpha 0.32.

Target Phase 1C:

- Use `Water/dark_edge_vignette.png`.
- Keep as top scene layer but low alpha.
- Must not look like a heavy black border.

## Debug logging rules

Allowed:

- DEBUG-only missing asset logs.
- Temporary DEBUG-only one-time layer load logs during active phase verification.

Not allowed:

- Per-frame logs.
- Logs in release builds.
- Repeated resize spam after the baseline is stable.

Before Phase 4C:

- Remove or gate `logPondLayerDebug` if it becomes noisy.

## Screenshot validation checklist

For every SpriteKit visual phase, validate:

- Full-screen iPad landscape, no black bars.
- Frozen pond background remains visible.
- Koi remain large and trackable.
- No harsh neon, arcade, fantasy, casino, or children-game style.
- Water overlays are subtle and natural.
- Touch ripples are gentle and fade.
- Environment does not obscure fish.
- UI does not persist during cat play unless intentionally recalled.
- No obvious missing texture placeholders.
- No excessive debug text/log-dependent behavior.
