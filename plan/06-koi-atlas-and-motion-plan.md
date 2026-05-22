# 06 — Koi warp rendering and motion plan

This document replaces the failed atlas-crop koi direction with the target koi pipeline: SpriteKit `SKWarpGeometryGrid` deformation driven by movement state and clean single-texture RGBA koi art.

## Decision boundary

The atlas-crop, frame-flipping, and segmented sticker approaches are rejected for final runtime use.

Reasons:

- Static atlas crops looked like translated stickers, not living fish.
- Frame flipping did not create believable swimming.
- Segmented sprite attempts still read as flat translation.
- Current koi/water assets include RGB or baked checkerboard/background problems.
- Cat-readable living motion requires continuous body deformation, not atlas rescue.

## Confirmed current koi state

- `PondSpriteScene` builds up to 9 fish configs.
- `PondSettings.fishCount` clamps active count to 3–9.
- Current production-safe baseline can remain procedural koi until warp koi is validated.
- Current shadows are procedural via `PondSpriteAssets.koiShadowTexture(bodySize:)`.
- Movement is handled by `FishMovementComponent` and `FishSteeringSystem`.

Evidence from earlier inspection:

- `PondSpriteScene.swift` builds fish configs and syncs node position, rotation, scale, and shadow.
- Existing fish movement already exposes position, heading, velocity, depth, life time, sway phase, alert, attention, and cooldown state that can drive deformation.

## Target technical direction

Use native iPadOS SwiftUI shell and SpriteKit runtime:

```text
SwiftUI shell
  -> SKView
  -> PondSpriteScene
  -> KoiWarpRenderer per fish
  -> SKSpriteNode(texture: clean RGBA koi body)
  -> SKWarpGeometryGrid updated from movement state
```

Do not switch to Unity, WebGL, Flutter, or pure Metal in this reconstruction. Metal is deferred. Spine, Rive, and Live2D are deferred unless the SpriteKit warp prototype fails.

## Mesh-deformable koi texture requirements

Final koi runtime textures must be regenerated. Required properties:

- True RGBA PNG with alpha channel.
- Transparent background.
- No checkerboard baked into pixels.
- No white, black, or colored baked background.
- Single straight top-down koi body texture.
- Head facing right, tail facing left.
- Fish centered in the canvas.
- Enough transparent padding around body and tail for warp deformation.
- No baked fish shadow.
- Clean silhouette and readable markings at iPad viewing distance.
- Symmetric enough to bend without exposing texture-edge artifacts.

Optional future asset data:

- Separate alpha mask if silhouette cleanup is needed.
- Control point metadata describing head/body/tail landmarks.
- Normal map is deferred and not required for SpriteKit K phases.

Rejected for final runtime:

- Existing RGB atlases.
- Any atlas with baked checkerboard.
- Any atlas requiring guessed crop rectangles.
- Any multi-frame sheet displayed as a whole texture.
- Any asset whose background has to be hidden by blend tricks.

## SKWarpGeometryGrid prototype plan

Prototype with one fish only before touching multi-fish runtime:

1. Generate or import one clean RGBA koi texture matching the requirements above.
2. Create an isolated SpriteKit scene or debug path with one `SKSpriteNode`.
3. Apply a cached original `SKWarpGeometryGrid` to the node.
4. Update only the destination grid over time.
5. Start with a low-resolution grid such as 5 columns × 2 rows or 6 columns × 3 rows.
6. Treat the x axis as head-to-tail body length and y axis as body width.
7. Keep head deformation minimal.
8. Bend mid-body from turn intensity.
9. Oscillate tail from speed and per-fish phase.
10. Verify no texture tearing, transparent-edge clipping, or sticker-like translation.

Prototype acceptance:

- A stationary root node can appear to swim via deformation alone.
- When moving, fish reads as one flexible body, not sliding art.
- Tail beat is visible but not cartoonish.
- Head remains stable enough for heading readability.
- Texture edges stay transparent and clean.

## Movement-to-deformation coupling

Keep fish translation and heading on the fish root node. Use warp only for body shape.

Root node state:

- `position`: world-to-scene fish center.
- `zRotation`: smoothed heading.
- `xScale/yScale`: depth/readability scale only.
- `alpha`: visibility and mood tuning only.

Warp state:

- Body curvature from turn intensity.
- Tail beat amplitude from speed.
- Tail beat frequency from speed with calm limits.
- Phase offset per fish to prevent synchronized swimming.
- Alert/flee response increases curvature and tail amplitude briefly, with smoothing.

Do not use warp to teleport the fish or correct steering bugs.

## Tail beat and body curvature model

Suggested conceptual model:

```text
speed01 = normalized current speed
turn01 = clamped signed heading delta / max comfortable turn
phase = fish.phase + time * lerp(calmFrequency, fastFrequency, speed01)
bodyCurve = turn01 * bodyCurveScale
wave = sin(phase + xAlongBody * waveLag)
tailAmplitude = lerp(calmTailAmp, fastTailAmp, speed01) + alertBoost
lateralOffset(x) = bodyCurve * bodyWeight(x) + wave * tailAmplitude * tailWeight(x)
```

Weighting target:

- Head: near 0 lateral warp for stable direction.
- Front body: low bend.
- Mid body: smooth curvature.
- Tail base: stronger bend.
- Tail tip: strongest oscillation.

Smoothing rules:

- Smooth heading before deriving turn intensity.
- Smooth speed before deriving tail amplitude/frequency.
- Clamp lateral offsets so transparent padding is sufficient.
- Decay alert boost over time.

## Integration plan

### Phase K0 — reject failed koi experiment and return to stable baseline

- Remove atlas-crop rescue from the executable plan.
- Keep or restore the last stable non-broken koi baseline.
- Do not attempt to salvage current atlas crops.

### Phase K1 — regenerate one clean RGBA mesh-deformable koi texture

- Produce one validated PNG for the warp prototype.
- Store only where the phase explicitly allows.
- Validate alpha and absence of checkerboard/background before runtime integration.

### Phase K2 — isolated single-fish SKWarpGeometryGrid prototype

- Build a standalone one-fish proof inside SpriteKit.
- No pond integration and no multi-fish work.
- Tune grid resolution, tail amplitude, body curvature, and padding.

### Phase K3 — one-fish PondSpriteScene integration

- Integrate the validated warp renderer into `PondSpriteScene` with one fish only.
- Preserve water/background/environment layers.
- Keep performance stable and no per-frame texture decoding.

### Phase K4 — 3–6 koi variants after asset validation

- Add more variants only after each texture passes RGBA/padding checks.
- Assign independent phase offsets.
- Avoid synchronized tail beats.

### Phase K5 — tap/flee/attraction coupling

- Connect tap, flee, and attraction state to warp parameters.
- Use brief amplitude/frequency boosts, not panic darts.
- Preserve calm cat-safe behavior.

### Phase K6 — final koi visual QA and performance tuning

- Validate all moods, fish counts, and iPad landscape size.
- Profile update cost.
- Reduce grid resolution or active fish count if needed.

## Cat tap near fish behavior

Current behavior can remain the input source:

- Touch near fish triggers a gentle response.
- Fish attention direction points away from touch.
- Fish gets alert/cooldown/target speed.

Warp target:

- Direct or near-fish tap increases tail beat and curvature briefly.
- Motion remains smooth, not a panic dart.
- Fish remains visible and returns to calm.

## Long press attraction behavior

Target future behavior:

- Long press away from fish creates mild curiosity attraction.
- Fish gradually angle toward the touch area.
- Tail beat and body curve increase subtly as fish turns.
- No feeding UI or game reward.
- Avoid all fish swarming into one pile.

## Fish count handling

Target after K4:

- Preserve 3–9 settings range only after variants and performance are validated.
- Initial warp integration should use one fish only.
- Expand to 3–6 fish first.
- 7–9 fish requires performance and readability proof.

## Acceptance criteria for cat readability

A koi implementation is acceptable only if:

- Fish look like living flexible bodies, not translated stickers.
- Active fish are easy to see against all water moods.
- Fish are large enough for cats to track from a normal viewing distance.
- Motion is smooth and continuous.
- Touch response is calm, not startling.
- Fish do not disappear under water overlays, lotus, or vignette.
- Fish remain inside pond bounds.
- Texture alpha is clean with no checkerboard/background artifacts.
- No per-frame texture decoding or atlas slicing occurs.

## Rollback strategy

- K1 rollback: discard generated candidate texture and keep baseline koi.
- K2 rollback: remove isolated prototype path.
- K3 rollback: disable warp renderer and restore stable baseline fish.
- K4 rollback: reduce to one validated warp fish.
- K5 rollback: decouple interaction state from warp parameters while keeping movement.

## Stop conditions

- Generated texture has RGB-only data, baked checkerboard, or nontransparent background.
- Transparent padding is insufficient for deformation.
- `SKWarpGeometryGrid` creates tearing, clipping, or unacceptable performance.
- Fish still reads as flat sticker translation after K2.
- One-fish integration regresses pond background/water stability.
- Build fails.
