# 06 — Koi atlas and motion plan

This document defines koi reconstruction.

## Confirmed current koi state

- `PondSpriteScene` builds up to 9 fish configs.
- `PondSettings.fishCount` clamps active count to 3–9.
- Current koi bodies are procedural via `PondSpriteAssets.koiBodyTexture(config:)`.
- Current shadows are procedural via `PondSpriteAssets.koiShadowTexture(bodySize:)`.
- Movement is handled by `FishMovementComponent` and `FishSteeringSystem`.

Evidence:

- `PondSpriteScene.swift:289` defines `buildFish(sceneScale:)`.
- `PondSpriteScene.swift:290` creates configs for 9 fish.
- `PondSpriteScene.swift:305` uses procedural koi body texture.
- `PondSpriteScene.swift:334` syncs fish node position, rotation, scale, and shadow.

## Koi atlas inventory

Frozen atlas assets:

- `Koi/koi_cream_red_atlas.png`
- `Koi/koi_kohaku_atlas.png`
- `Koi/koi_sanke_atlas.png`
- `Koi/koi_shiro_utsuri_atlas.png`
- `Koi/koi_showa_atlas.png`
- `Koi/koi_yamabuki_atlas.png`

Variant mapping target:

- `KoiVariant.creamRed` → `koi_cream_red_atlas.png`
- `KoiVariant.kohaku` → `koi_kohaku_atlas.png`
- `KoiVariant.sanke` → `koi_sanke_atlas.png`
- `KoiVariant.shiroUtsuri` → `koi_shiro_utsuri_atlas.png`
- `KoiVariant.showa` → `koi_showa_atlas.png`
- `KoiVariant.yamabuki` → `koi_yamabuki_atlas.png`

## Atlas size differences

Required before Phase 1D/1E:

- Inspect each atlas dimensions.
- Confirm whether all atlases share identical dimensions.
- Confirm row/column layout or explicit frame rectangles.
- Confirm transparent padding.

Do not assume all atlases use the same grid until confirmed.

Acceptable inspection commands for future phase:

```bash
python3 - <<'PY'
from PIL import Image
from pathlib import Path
for p in sorted(Path('Assets/Koi').glob('*.png')):
    im = Image.open(p)
    print(p, im.size)
PY
```

If PIL is unavailable, use macOS `sips -g pixelWidth -g pixelHeight Assets/Koi/*.png`.

## Metadata requirement before slicing

Before animation, define metadata for each atlas:

- source path
- pixel width/height
- frame rectangle(s)
- frame order
- display size
- anchor point
- optional collision/readability radius
- optional shadow scale/offset

Phase 1D may use a single conservative frame if and only if its rectangle can be confirmed. Phase 1E must not proceed without metadata.

## Initial static sprite plan — Phase 1D

Goal:

- Replace procedural body texture with atlas-backed static fish sprites.
- Do not animate.
- Do not change movement logic.

Implementation approach:

1. Inspect atlas dimensions.
2. Determine safe static frame rectangle per atlas.
3. Add variant-to-atlas path mapping.
4. Use `PondTextureCache.texture(for:)` to load atlas texture.
5. Create cropped `SKTexture(rect:in:)` if needed.
6. Use cropped frame as `SKSpriteNode` texture.
7. Preserve current display size initially, then adjust if screenshot shows fish too small/large.
8. Keep current procedural shadow unless a better shadow solution is available.

Acceptance criteria:

- Runtime koi visually come from frozen atlas art.
- No procedural koi bodies remain in normal path.
- No frame bleed/cropping artifacts.
- Fish remain large and trackable.
- Movement, count, and shadows still work.

## Later animation frame plan — Phase 1E

Goal:

- Animate koi subtly using atlas frames.

Implementation approach:

1. Confirm metadata.
2. Precompute frame textures outside `update(_:)`.
3. Store frame arrays per variant or per fish config.
4. Use `SKAction.animate(with:timePerFrame:)` or manual time-based frame selection.
5. Keep animation speed slow and natural.
6. Avoid changing fish heading/position logic unless needed for visual smoothing.

Rules:

- Do not animate with guessed frame order.
- Do not allocate/crop textures per frame.
- Do not add flashy tail effects.
- Do not make fish appear cartoonish.

## Movement behavior plan

Current movement should remain the foundation:

- Fish have position, heading, velocity, depth, life time, sway phase, alert/attention/cooldown fields.
- `FishSteeringSystem` updates movement within pond bounds.
- `PondSpriteScene.syncFishNode` applies position, rotation, depth scale, body sway, and shadow offset.

Target refinements:

- Smooth heading changes.
- Preserve calm speed range.
- Avoid fish overlapping too much.
- Avoid edge sticking.
- Preserve cat readability over realism if they conflict.

## Cat tap near fish behavior

Current behavior:

- Touch near fish within distance 1.5 triggers `touchFish`.
- Fish attention direction points away from touch.
- Fish gets alert/cooldown/target speed.

Target:

- Direct or near-fish tap should cause a short gentle flee.
- Motion should be smooth, not a panic dart.
- Fish should remain visible and return to calm.

Acceptance:

- A cat tap creates satisfying fish response but no stressful burst.

## Long press attraction behavior

Not confirmed implemented currently.

Target future behavior:

- Long press away from fish creates mild curiosity attraction.
- Fish gradually angle toward the touch area.
- No feeding UI or game reward.
- Stop attraction when touch ends.
- Avoid all fish swarming into one pile.

Implementation phase:

- Phase 3C unless explicitly pulled earlier.

## Flee gently behavior

Target tuning:

- Use limited target speed boost.
- Use cooldown to avoid repeated jitter.
- Turn radius should look organic.
- Avoid fish crossing through stones/lotus if future avoidance exists.

## Return-to-calm behavior

Target:

- Alert and attention timers decay.
- Speed returns to calm swim.
- Fish rejoin wandering/schooling behavior.
- No permanent state after taps.

## Fish count handling

Current:

- `activeFishCount = min(max(settings.fishCount, 3), 9)`.
- Fish nodes and shadows are hidden when index exceeds active count.

Target:

- Preserve 3–9 range.
- Keep fish count changes immediate and stable.
- Avoid rebuilding the whole scene just to change active count.
- Ensure visible variants look balanced at each count.

## Acceptance criteria for cat readability

A koi implementation is acceptable only if:

- At least the active fish are easy to see against all water moods.
- Fish are large enough for cats to track from a normal viewing distance.
- Motion is smooth and continuous.
- Touch response is calm, not startling.
- Fish do not disappear under water overlays, lotus, or vignette.
- Fish do not look like UI icons or stickers.
- Fish remain inside pond bounds.
- No atlas slicing artifacts are visible.

## Rollback strategy

- Phase 1D rollback: restore procedural body texture while keeping all movement code unchanged.
- Phase 1E rollback: disable animation and retain static atlas sprites.
- Movement rollback: revert tuning constants separately from render code.

## Stop conditions

- Atlas dimensions or frame layout cannot be verified.
- Atlas crop shows visible neighboring frames.
- Fish become too small or hard to track.
- Build fails.
- Movement becomes jittery, aggressive, or game-like.
