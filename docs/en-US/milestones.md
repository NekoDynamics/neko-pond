# Neko Pond Milestones

## Milestone Philosophy

Neko Pond is currently moving from prototype to vertical slice.

The next milestone is not feature expansion. It is visual credibility.

The project should not advance into systems, content, monetization, or full engine work until the main pond can stand on its own as a premium ambient scene.

## Current North Star

```text
One Perfect Pond
```

A single pond. Few functions. High atmosphere. Strong first impression.

## P0: Visual Credibility Freeze

### Objective

Stop prototype sprawl and lock the next phase around first-screen believability.

### Scope

- Preserve existing SceneKit prototype.
- Preserve fish behavior work.
- Stop new feature systems.
- Identify prototype UI and interaction artifacts.
- Mark default feeding as a product risk.

### Exit Criteria

- Development plan points to One Perfect Pond.
- No new weather, settings, onboarding, collection, or monetization work is started.

## P1: Cinematic Main Frame

### Objective

Make the paused main pond screenshot feel like a premium product.

### Scope

- Revise camera composition.
- Add light perspective / cinematic tilt.
- Strengthen foreground, midground, depth, and background separation.
- Add or improve lily pads, stones, moss, petals, and dark edges.
- Tune lighting and fog for atmosphere.

### Exit Criteria

- The scene no longer reads as a flat debug plane.
- The first frame communicates calm premium atmosphere.

## P2: HUD Disappearance

### Objective

Remove technical-demo interpretation from the product.

### Scope

- Remove SceneKit/native/debug labels.
- Remove fish count chips from the main pond.
- Replace with restrained ambient identity.
- Add auto-fade or low-presence behavior.
- Keep controls minimal and non-game-like.

### Exit Criteria

- UI supports the pond instead of explaining the engine.
- The product feels like ambient software, not a tech demo.

## P3: Credible Koi Pass

### Objective

Replace geometric fish readability with believable koi silhouette.

### Scope

- Use low-poly stylized realistic koi mesh or revised procedural mesh.
- Improve body taper, fins, tail, and proportions.
- Add translucent fin treatment.
- Improve koi color patterns.
- Preserve current motion system.

### Exit Criteria

- Fish still frames read as koi.
- Motion reads as living swimming, not moving primitives.

## P4: Soft Water Illusion

### Objective

Create water depth and poetic believability without full GPU simulation.

### Scope

- Replace hard torus ripple look.
- Add soft additive ripple visuals.
- Add depth gradient and underwater veil.
- Add caustic impression.
- Tune fish shadows and depth cues.
- Tune bloom/vignette conservatively.

### Exit Criteria

- Fish feel submerged.
- Ripples feel calm and causal.
- Water no longer looks like a flat textured plane.

## P5: Calm Touch Semantics

### Objective

Prevent the product from becoming a feeding game.

### Scope

- Remove food spawning from default tap.
- Tap water creates ripple and curiosity.
- Tap near fish triggers notice/light evade.
- Long press attracts gently.
- Feeding is explicit and occasional.

### Exit Criteria

- Default touch feels like interacting with water.
- Product category remains premium ambient experience.

## P6: One Perfect Pond Validation

### Objective

Validate that the main pond is worth watching before more systems are added.

### Test Protocol

- Real iPad test.
- 3 minutes idle watching.
- 1 minute light interaction.
- 1 minute return to idle.

### Acceptance Criteria

- First second feels premium.
- No obvious prototype UI.
- No arcade effects.
- No visible mechanical loop.
- Stable frame pacing.
- Scene remains pleasant without new features.

## Deferred Milestones

Only after One Perfect Pond passes:

- weather modes;
- night/rain/winter themes;
- settings screen;
- onboarding;
- photo/cinematic mode;
- audio layering;
- Metal ripple field;
- caustics/post-processing pipeline;
- advanced schooling behavior;
- App Store packaging.
