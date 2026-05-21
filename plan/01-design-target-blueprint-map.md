# 01 — Design target blueprint map

This document maps the supplied NEKO POND Design Blueprint V1 sheets into implementation targets. The blueprint images exist at `Design/NEKO POND Design Blueprint V1/NEKO_POND_Design_Blueprint_1.png` through `_8.png`, plus `_s.png`.

## Global target direction

NEKO POND must feel like a premium realistic koi pond for cats:

- Top-down or shallow top-down calm cinematic pond.
- Deep teal-green water.
- Realistic depth and soft underwater fog.
- Natural caustics.
- Mossy stones, lotus leaves, lotus flowers, floating petals.
- Believable koi fish that are large and trackable by cats.
- Gentle touch ripples and non-threatening fish behavior.
- Vanishing minimal human UI.
- iPad landscape full-screen experience.

Forbidden direction:

- No score, coins, hearts, levels, loud particles, neon, casino, fantasy, children-game style, combat, jump scares, sudden flashes, or persistent arcade HUD.

## Sheet 01 — Master Pond Experience

### Visual goal

A full-screen cinematic pond with deep teal-green water, visible frozen pond background, layered water veil, soft fog, low-frequency caustics, subtle vignette, and believable scale. The app should read as a calm physical pond rather than a game board.

### Runtime systems required

- Mood-aware background selection.
- Aspect-fill pond background rendering.
- Water overlay stack.
- Minimal runtime logging.
- Stable landscape full-screen behavior.

### SwiftUI systems required

- Full-screen `ContentView` shell with no persistent intrusive UI.
- Status bar hidden and system overlays suppressed where allowed.
- Human controls hidden during cat play.

### SpriteKit systems required

- Floor/background layer using `Assets/Pond/*.png`.
- Deep water veil using `Assets/Water/water_veil_deep.png` and/or `water_veil_near.png`.
- Caustics using `Assets/Water/caustics_loop_01.png`, `caustics_loop_02.png`, `caustics_soft_large.png`.
- Dark edge vignette using `Assets/Water/dark_edge_vignette.png`.
- Scene resize handling preserving aspect-fill.

### Asset dependencies

- `Pond/pond_background_dawn_2732x2048.png`
- `Pond/pond_background_day_2732x2048.png`
- `Pond/pond_background_moonlight_2732x2048.png`
- `Pond/pond_background_rain_2732x2048.png`
- `Pond/pond_background_winter_2732x2048.png`
- `Water/water_veil_deep.png`
- `Water/water_veil_near.png`
- `Water/caustics_loop_01.png`
- `Water/caustics_loop_02.png`
- `Water/caustics_soft_large.png`
- `Water/dark_edge_vignette.png`

### Acceptance criteria

- On iPad landscape simulator, the pond fills the screen with no black bars.
- The frozen pond background remains visible.
- Water overlays add depth without washing out the background.
- No game-like HUD elements persist during cat play.
- Screenshot reads as premium realistic calm pond.

## Sheet 02 — Cat Interaction States

### Visual goal

Touch should create calm water response and gentle koi attention/flee behavior. The interaction must be legible to cats and non-threatening.

### Runtime systems required

- Multi-touch ripple spawning.
- Tap-near-fish behavior.
- Long-press attraction behavior.
- Gentle flee behavior for direct/near fish touches.
- Return-to-calm behavior after interaction.
- Sensitivity tuning from settings.

### SwiftUI systems required

- Human HUD recall on water tap or corner gesture.
- UI hide timer after human interaction.
- Settings access that does not interfere with cat play.

### SpriteKit systems required

- Ripple pool using frozen ripple textures.
- Touch-to-world coordinate conversion.
- Fish proximity classification.
- Movement component inputs for attention, alert, cooldown, attraction.

### Asset dependencies

- `Water/ripple_ring_01.png`
- `Water/ripple_ring_02.png`
- `Water/ripple_ring_soft_large.png`

### Acceptance criteria

- Single tap creates a soft expanding ring.
- Rapid multi-touch does not flood memory or create loud visuals.
- Near-fish touch causes a short gentle movement, not panic darting.
- Fish settle back into calm swim within a few seconds.
- No persistent touch indicators remain.

## Sheet 03 — Koi Design System

### Visual goal

Large, believable koi with distinct variants, natural orientation, readable silhouettes, soft shadows, gentle body motion, and no cartoon procedural look.

### Runtime systems required

- Frozen koi atlas loading.
- Static atlas-backed sprite replacement first.
- Metadata-driven atlas slicing later.
- Animation frame selection once metadata is confirmed.
- Fish count handling 3–9.
- Depth/scale variation without losing readability.

### SwiftUI systems required

- Fish count control in Settings.
- Interaction sensitivity control in Settings.
- Optional cat-safe mode limiting abrupt fish response.

### SpriteKit systems required

- Koi sprite layer.
- Koi shadow layer.
- Atlas frame extraction.
- Movement sync with rotation and scale.
- Visibility toggling for fish count.

### Asset dependencies

- `Koi/koi_cream_red_atlas.png`
- `Koi/koi_kohaku_atlas.png`
- `Koi/koi_sanke_atlas.png`
- `Koi/koi_shiro_utsuri_atlas.png`
- `Koi/koi_showa_atlas.png`
- `Koi/koi_yamabuki_atlas.png`

### Acceptance criteria

- Koi are visibly asset-backed, not procedural.
- At least six variants can appear across the max fish count.
- Fish are large enough to track from typical cat viewing distance.
- Fish movement is smooth and organic.
- No atlas frame cuts show neighboring frames or transparent padding errors.

## Sheet 04 — Water and Environment System

### Visual goal

Layered water atmosphere with lotus leaves/flowers, mossy stones, aquatic grasses, petals, motes, and mood-specific ambience. Environment must frame fish and improve realism, not clutter the pond.

### Runtime systems required

- Frozen water overlay usage.
- Frozen environment asset placement.
- Petal drift.
- Underwater mote emitter or node pool.
- Mood-specific overlay alpha and placement tuning.

### SwiftUI systems required

- Mood selection control.
- Cat safe mode can reduce intensity.

### SpriteKit systems required

- Environment layer.
- Petal layer.
- Mote layer.
- Optional rain overlay for rain mood.
- Dark vignette and water veil layers.

### Asset dependencies

- Water assets listed in Sheet 01 and Sheet 02.
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

### Acceptance criteria

- Environment assets use frozen files, not procedural substitutes.
- Edges feel natural with stones/grasses/lotus.
- Fish remain visible and unobstructed.
- Petals drift slowly and subtly.
- Rain mode is calm, not noisy.

## Sheet 05 — Vanishing HUD and Human Control Layer

### Visual goal

A minimal, premium, low-contrast human UI that appears briefly for humans and vanishes for cat play.

### Runtime systems required

- HUD visible state.
- Hide timer.
- Corner recall gesture/tap.
- Settings reveal and dismiss.
- No persistent score/game controls.

### SwiftUI systems required

- `CatPlayHUD` reconstruction.
- Settings button or recall affordance.
- Fade transitions.
- Safe-area-aware iPad landscape placement.

### SpriteKit systems required

- None unless HUD touch routing must coordinate with water tap handling.

### Asset dependencies

- No required frozen image asset. Use SwiftUI shapes/text/icons consistent with design tokens.

### Acceptance criteria

- During cat play, no visible UI remains except possibly near-invisible recall affordance.
- Human can reliably reveal Settings.
- HUD does not block pond touches except its own controls.
- UI color, typography, and opacity match premium pond direction.

## Sheet 06 — Settings and Human-only Screens

### Visual goal

A refined human-only Settings interface with dark translucent glass, warm gold/jade accents, mature typography, clear sections, and iPad landscape layout. It should feel like a premium control panel, not a prototype form.

### Runtime systems required

- Settings model owns user-adjustable state.
- Reset to safe defaults.
- Later binding from settings to SpriteKit runtime.

### SwiftUI systems required

- Glass panel system.
- Sidebar navigation.
- Content panel with rows/sections.
- Segmented controls, sliders, toggles, icon buttons, reset button.
- iPad landscape safe area layout.

### SpriteKit systems required

- No rendering changes in Settings reconstruction phase unless a setting binding is explicitly in scope.

### Asset dependencies

- No required frozen image asset.

### Acceptance criteria

- Settings no longer looks prototype-level.
- Controls are readable and finger-friendly on iPad.
- Visual styling matches dark teal/warm gold/koi white direction.
- Closing Settings returns to cat play and HUD hide behavior.

## Sheet 07 — Onboarding and First-run Experience

### Visual goal

A calm first-run flow that teaches safe iPad placement and explains that UI will vanish for cat play. It should be premium, minimal, and non-game-like.

### Runtime systems required

- First-run state via `@AppStorage` or equivalent.
- Start pond transition.
- Optional reset onboarding hook later.

### SwiftUI systems required

- Launch state.
- Page/fade state.
- Safe placement screen.
- Start pond call-to-action.
- Full-screen overlay that dismisses cleanly.

### SpriteKit systems required

- Pond can run behind onboarding or remain visually subdued behind overlay.

### Asset dependencies

- No required frozen image asset.

### Acceptance criteria

- Onboarding clearly communicates safe iPad placement.
- Flow starts pond mode with UI hidden/fading.
- No cartoon/game tutorial style.
- No persistent onboarding artifacts after start.

## Sheet 08 — Design System and Development Blueprint

### Visual goal

A coherent design system and implementation discipline: small phases, controlled file allowlists, repeatable validation, and no broad rewrites.

### Runtime systems required

- Stable module boundaries.
- Debug logging policy.
- Performance and memory budget.
- Release warning classification.

### SwiftUI systems required

- Reusable design tokens/components only when needed by Settings/HUD/onboarding phases.
- No premature large shell rebuild.

### SpriteKit systems required

- Layer stack with named zPositions.
- Asset registry and cache as single source for bundle paths.
- Small visual changes with screenshot verification.

### Asset dependencies

- All frozen asset folders must keep their existing file names.

### Acceptance criteria

- Every implementation phase has an allowlist, forbidden files, build command, screenshot requirement, rollback plan, and stop conditions.
- Agents do not rename assets or change design direction.
- Visual reconstruction proceeds from background → water → koi → environment → interactions → UI → settings bindings → moods → QA.
