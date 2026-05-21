# 07 — Water environment interaction plan

This document defines water/environment implementation and interaction behavior.

## Caustics strategy

Assets:

- `Water/caustics_loop_01.png`
- `Water/caustics_loop_02.png`
- `Water/caustics_soft_large.png`

Target:

- Use one broad soft caustic layer and optionally one loop caustic layer.
- Move layers slowly in different directions.
- Use low alpha and optional additive blend.
- Avoid flashing, high contrast, or arcade sparkle.

Phase:

- Initial replacement in Phase 1C.
- Mood-specific tuning in Phase 3B.

## Water veil strategy

Assets:

- `Water/water_veil_deep.png`
- `Water/water_veil_near.png`

Target:

- Deep veil above background to unify pond color.
- Near veil/fog layer to create shallow underwater atmosphere.
- Keep fish readable.
- Do not obscure frozen background.

Placement:

- Deep veil: `PondLayerZ.deepWater`.
- Near veil/fog: `PondLayerZ.fogVeil`, or below fish if it hides koi.

## Rain overlay strategy

Asset:

- `Water/rain_ripple_overlay.png`

Target:

- Rain mood only.
- Low alpha, slow drift or static overlay.
- Calm rainy pond, not storm/noisy effect.

Phase:

- Phase 3B, not Phase 1C unless the user explicitly expands scope.

## Dark vignette strategy

Asset:

- `Water/dark_edge_vignette.png`

Target:

- Subtle edge darkening to focus center.
- Top visual layer.
- Do not darken the center or hide fish.
- Tune per mood later.

Phase:

- Initial replacement in Phase 1C.
- Mood tuning in Phase 3B.

## Underwater motes

Assets:

- `Water/mote_soft.png`
- `Water/mote_tiny.png`

Target:

- Sparse, slow, low-alpha depth cues.
- Use `SKEmitterNode` or a small pool of drifting sprites.
- Avoid sparkle/confetti look.
- Lower intensity under cat-safe mode if bound later.

Phase:

- Can be part of Phase 1C if limited to texture replacement.
- Tuning/performance in Phase 4A.

## Ripple pool

Assets:

- `Water/ripple_ring_01.png`
- `Water/ripple_ring_02.png`
- `Water/ripple_ring_soft_large.png`

Target:

- Use frozen ripple textures for touch feedback.
- Expand and fade smoothly.
- Differentiate began/moved touches by alpha/scale/duration, not harsh color.
- Cap or clean active ripples.

Phase:

- Phase 1G.

Suggested constraints:

- Do not spawn more than a reasonable active cap if rapid multi-touch creates excessive nodes.
- Remove nodes on action completion.
- Keep `ripplePool` clean of removed nodes.

## Multi-touch handling

Current:

- `touchesBegan` and `touchesMoved` iterate every touch and spawn a ripple.

Target:

- Preserve multi-touch support.
- If rapid touches flood ripples, add throttling or active cap in Phase 1G.
- Do not drop all but one touch; cats may use multiple paws.
- Avoid per-touch expensive texture creation.

## Lotus placement

Assets:

- `Environment/lotus_leaf_01.png`
- `Environment/lotus_leaf_02.png`
- `Environment/lotus_leaf_03_small.png`
- `Environment/lotus_flower_pink.png`
- `Environment/lotus_flower_white.png`
- `Environment/lotus_bud_pink.png.png`

Target:

- Place lotus clusters near edges/corners and calm side regions.
- Avoid center-heavy placement that blocks fish.
- Mix leaves and flowers sparingly.
- Use rotation/scale variation.

Phase:

- Phase 1F.

## Stone placement

Assets:

- `Environment/moss_stone_01.png`
- `Environment/moss_stone_02_flat.png`
- `Environment/moss_stone_03_small.png`

Target:

- Mossy stones frame pond edges.
- Some stones may be partly under water veil.
- Avoid symmetric game-board placement.
- Keep open swimming lanes.

Phase:

- Phase 1F.

## Grass placement

Assets:

- `Environment/aquatic_grass_01.png`
- `Environment/aquatic_grass_02.png`

Target:

- Use grasses near edges and behind stones/lotus.
- Low density.
- Do not make the scene look like a decorative sticker collage.

Phase:

- Phase 1F.

## Floating petals

Assets:

- `Environment/petal_01.png`
- `Environment/petal_02.png`
- `Environment/petal_03_small.png`
- `Environment/petal_04_pale.png`

Target:

- Sparse petals drifting slowly.
- Low alpha if they compete with fish.
- Natural placement around lotus/edge zones and a few open-water accents.
- No confetti burst behavior.

Phase:

- Phase 1F.

## Mood-specific environment differences

Phase 3B target:

- Dawn: warmer caustics, soft visibility.
- Day: clearest water and highest fish readability.
- Rain: subdued caustics, rain overlay, slightly darker veil.
- Moonlight: darker pond, cool highlights, fish readability compensation.
- Winter: cooler palette, possibly reduced petals/flowers if assets support it.

Do not add new assets for mood differences unless explicitly requested.

## Performance constraints

- Avoid creating textures repeatedly.
- Prefer cached textures and reused nodes.
- Keep particle birth rate low.
- Keep environment node count moderate.
- Avoid expensive filters/shaders unless later profiling allows.
- Do not rebuild entire scene in response to every minor settings change if not required.
- Validate rapid multi-touch does not degrade frame pacing.

## Acceptance criteria

- Water looks layered and calm.
- Environment improves realism and frames the scene.
- Fish remain visible and central to cat experience.
- Touch feedback is gentle and satisfying.
- No effect reads as loud particles, neon, arcade, fantasy, or children-game style.
