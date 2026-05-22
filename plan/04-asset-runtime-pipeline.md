# 04 — Asset runtime pipeline

This document defines how frozen assets must be used at runtime.

## Asset folder rule

Frozen runtime assets are already organized in app resource folders:

- `Pond`
- `Water`
- `Koi`
- `Environment`

Runtime code must load these as bundle-relative paths, not as source-tree paths. Example runtime path: `Pond/pond_background_day_2732x2048.png`, not `Assets/Pond/pond_background_day_2732x2048.png`.

## Pond backgrounds

### Exact relative bundle paths

- `Pond/pond_background_dawn_2732x2048.png`
- `Pond/pond_background_day_2732x2048.png`
- `Pond/pond_background_moonlight_2732x2048.png`
- `Pond/pond_background_rain_2732x2048.png`
- `Pond/pond_background_winter_2732x2048.png`

### Loading rules

- Use `PondAssetRegistry.PondBackground` for paths.
- Load through `PondTextureCache.texture(for:)`.
- Render as an `SKSpriteNode` with center anchor and aspect-fill size.
- Default/fallback mood during current phases: day or dawn, whichever is already visible and stable.
- Mood-specific switching belongs to Phase 3B.

### Fallback rules

- If a pond background fails to load in DEBUG, log missing path once per attempted path if possible.
- Use existing procedural floor fallback only to preserve build/run stability.
- Treat missing frozen pond background as a phase stop condition.

## Water overlays

### Exact relative bundle paths

- `Water/caustics_loop_01.png`
- `Water/caustics_loop_02.png`
- `Water/caustics_soft_large.png`
- `Water/dark_edge_vignette.png`
- `Water/mote_soft.png`
- `Water/mote_tiny.png`
- `Water/rain_ripple_overlay.png`
- `Water/ripple_ring_01.png`
- `Water/ripple_ring_02.png`
- `Water/ripple_ring_soft_large.png`
- `Water/water_distortion_noise.png`
- `Water/water_veil_deep.png`
- `Water/water_veil_near.png`

### Loading rules

- Use frozen Water assets before procedural `PondSpriteAssets` equivalents.
- For full-screen overlays, use aspect-fill when preserving image ratio matters and direct scene-size stretch only if the asset is designed as a seamless full-screen overlay.
- Set `isUserInteractionEnabled = false` for all water nodes.
- Use low alpha values first; increase only after screenshot validation.

### Layering guidelines

- `water_veil_deep.png`: above background, below caustics/fish; alpha low enough to keep background visible.
- `water_veil_near.png`: optional second veil above caustics or below fish depending visual test; avoid milky washout.
- `caustics_loop_01.png`/`02.png`: additive or screen-like blend if SpriteKit supports the selected blend visually; low alpha and slow drift.
- `caustics_soft_large.png`: broad calm highlight; use very low alpha.
- `dark_edge_vignette.png`: top visual layer; subtle alpha.
- `rain_ripple_overlay.png`: rain mood only, not Phase 1C unless explicitly scoped.
- `mote_soft.png`/`mote_tiny.png`: particle texture or pooled sprite texture.
- `ripple_ring_*.png`: touch feedback only.

### Fallback rules

- If a Water overlay fails to load, stop Phase 1C rather than silently accepting procedural art, unless the user explicitly authorizes fallback.
- Keep procedural generation available only as emergency fallback while debugging.

## Koi mesh-deformable textures

The previous atlas-crop koi assets are rejected for final runtime use. Future koi rendering must use clean single-texture RGBA koi assets that can be deformed by SpriteKit `SKWarpGeometryGrid`.

### Required koi asset properties

- True RGBA PNG with alpha channel.
- Transparent background.
- No checkerboard baked into pixels.
- No white, black, or colored baked background.
- Single straight top-down koi body texture.
- Head facing right, tail facing left.
- Fish centered in the canvas.
- Enough transparent padding for warp deformation.
- No baked fish shadow.
- Clean silhouette and cat-readable markings.

### Optional future koi asset data

- Separate alpha mask for silhouette cleanup.
- Control point metadata for head, mid-body, tail base, and tail tip.
- Normal map is deferred and not required for SpriteKit warp phases.

### Loading rules

- Load koi body textures through `PondTextureCache` or a future equivalent cache.
- Decode each texture once during setup/preload, never inside `update(_:)`.
- Apply deformation with `SKWarpGeometryGrid` on an `SKSpriteNode`.
- Cache the original grid and update only destination grid values per frame.
- Do not display a full atlas sheet as a fish.
- Do not crop guessed atlas frames for final runtime koi.

### Rejected koi assets for final runtime

- `Koi/*_atlas.png` as atlas-crop/frame-flip runtime sources.
- RGB-only fish textures.
- PNGs with baked checkerboard.
- PNGs with baked white/black backgrounds.
- Assets that require blend-mode tricks to hide backgrounds.

### Fallback rules

- If no clean RGBA mesh-deformable koi texture exists, stop K1/K2 and keep the stable baseline koi.
- Do not rescue failed atlases by additional cropping or frame flipping.
- Procedural koi may remain only as temporary baseline until warp koi passes validation.

## Environment assets

### Exact relative bundle paths

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

### Double-extension rule

`Environment/lotus_bud_pink.png.png` is the confirmed frozen file name and current registry path. Do not rename it to `lotus_bud_pink.png`. Do not normalize it. Do not create an alias unless a future asset migration is explicitly requested.

### Loading rules

- Use `PondAssetRegistry.EnvironmentAsset` paths.
- Place environment assets in world coordinates converted to scene coordinates.
- Prefer edge framing and sparse composition.
- Preserve fish visibility.

### Fallback rules

- If an Environment asset fails to load in Phase 1F, stop and report the exact missing path.
- Do not substitute procedural environment silently unless user approves.

## Caching rules

- `PondTextureCache` caches by bundle-relative asset path.
- Use one `PondTextureCache` per scene unless future profiling requires a shared cache.
- Preload phase-critical textures at scene setup if it reduces visible hitching.
- Avoid reloading textures inside `update(_:)`.
- Avoid creating new `SKTexture` every frame.
- For touch ripples, reuse the same texture and create/pool nodes as needed.

## Alpha and layering guidelines

Start conservative:

- Deep/near water veil: low alpha, usually 0.08–0.28 depending asset density.
- Caustics: low alpha, usually 0.12–0.35; avoid bright flashing.
- Vignette: low to moderate alpha, never covering fish center.
- Motes: sparse, low alpha, slow movement.
- Rain overlay: mood-specific and subtle.
- Petals: sparse, alpha tuned to feel floating not decorative confetti.

Every alpha change requires screenshot validation.

## Memory considerations

- Pond backgrounds are 2732×2048 and should be loaded deliberately.
- Avoid loading all mood backgrounds during early phases unless testing mood switching.
- Koi warp textures should be cached once; do not decode textures or allocate grids unnecessarily in hot paths.
- Large full-screen overlays should be reused and resized, not recreated per frame.
- `didChangeSize` currently rebuilds layers; future optimization may need resizing existing nodes instead.

## Forbidden asset operations

- Do not rename frozen assets.
- Do not move frozen assets.
- Do not edit PNG contents.
- Do not generate replacement assets into `Assets/`.
- Do not delete unused-looking assets.
- Do not compress, resize, or re-export frozen assets without explicit user instruction.
- Do not change Xcode resource membership during phases that do not allow project edits.

## Future koi metadata plan

Optional metadata may be added only after K1/K2 prove the warp direction:

- Texture path and pixel dimensions.
- Display size range.
- Head, body center, tail base, and tail tip landmarks.
- Transparent padding limits.
- Grid resolution recommendation.
- Per-variant curvature/tail amplitude tuning.
- Optional alpha mask path.

Potential future implementation locations if explicitly approved:

- `App/iPadOS/NekoPond/PondSpriteModels.swift` for simple hardcoded metadata.
- New koi metadata Swift file if project file changes are allowed.

Do not create external JSON metadata unless the phase explicitly allows adding resources and project membership.
