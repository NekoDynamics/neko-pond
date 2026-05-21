# Neko Pond Product Development Plan

## 1. Current Stage

Neko Pond is in the `Prototype -> Vertical Slice` stage.

It is not in full production, engine architecture, or rendering optimization. The next phase is not about adding systems. It is about proving that the first screen feels like a real premium product.

The working milestone is:

```text
One Perfect Pond
```

The product should first become a single beautiful, believable, watchable pond before it becomes a larger ecosystem.

## 2. Product Definition

Neko Pond is a native iPadOS ambient pond experience.

It is not a casual game, aquarium simulator, management game, collection loop, or toy app. It should feel closer to:

- digital incense;
- digital garden;
- emotional furniture;
- ambient appliance;
- a premium calm space on iPad.

The product promise is simple:

```text
Open the app and enter a quiet living pond that feels worth watching.
```

The first success metric is not feature count. It is whether a user can watch the main pond for three minutes without wanting to exit.

## 3. Strategic Positioning

### Target Category

Neko Pond should be positioned as a premium ambient experience, not a game.

Expected references:

- Apple TV screensaver calmness;
- Japanese pond photography;
- aquarium cinematography;
- Apple Weather restraint;
- Calm / Endel atmosphere;
- Muji digital signage;
- high-end meditation product.

### Forbidden Product Drift

Avoid features that push the product into a casual game category:

- coins;
- levels;
- daily rewards;
- fish collection as the core loop;
- decoration economy;
- quests;
- idle progression;
- achievement popups;
- constant feeding rewards;
- arcade effects.

Food, if present, must be occasional, intentional, and quiet. Every tap must not create food.

## 4. Core Diagnosis

The current project already has a strong foundation:

- native iPadOS direction;
- SwiftUI shell;
- SceneKit prototype scene;
- real-time fish movement;
- touch handling;
- emotional steering concepts such as curiosity, hesitation, attention, calm, alert, and drift.

The current blocker is not behavior depth.

The current blocker is:

```text
visual credibility
```

The app currently reads as a technically capable prototype, not yet as a real App Store Featured-level product.

## 5. Primary Objective

The next development phase must optimize for one thing:

```text
first-second belief
```

When the app opens, the user should immediately feel:

```text
This is surprisingly premium.
```

The paused frame should be strong enough to look like a product screenshot.

## 6. One Perfect Pond Scope

### In Scope

Only the main pond vertical slice:

- cinematic camera composition;
- believable water depth;
- improved koi silhouette and material credibility;
- soft ripple visuals;
- caustic light impression;
- dark pond atmosphere;
- lily pads, petals, moss, stones, and foreground framing;
- disappearing HUD;
- restrained touch response;
- stable real-device performance.

### Out of Scope

Do not build these during One Perfect Pond:

- full weather system;
- full settings screen;
- onboarding sequence;
- photo mode;
- fish collection;
- monetization;
- account system;
- full Metal renderer;
- full GPU water simulation;
- SceneKit removal;
- SpriteKit rewrite;
- ECS migration;
- complex audio middleware integration.

## 7. Technical Direction

The current correct route is:

```text
SwiftUI + SceneKit + selective Metal
```

Do not rewrite the app around Unity. Do not delete SceneKit now. Do not migrate the full scene to SpriteKit.

### SwiftUI Responsibilities

- app shell;
- navigation outside the pond;
- settings later;
- glass panels later;
- iPadOS lifecycle;
- minimal owner controls.

### SceneKit Responsibilities

For the vertical slice, SceneKit should continue to own:

- fish entities;
- pond geometry;
- camera;
- lighting;
- hit testing;
- scene orchestration;
- prototype water material;
- decorative 3D elements.

### Metal Responsibilities

Metal should be introduced only for the highest visual-leverage areas, and only after the vertical slice direction is validated:

- water rendering;
- ripple field;
- caustics;
- fog / veil;
- post-processing;
- blur / light scattering.

### SpriteKit Responsibilities

SpriteKit is optional and should not replace SceneKit. It can be considered later for:

- soft particles;
- floating petals;
- mist;
- 2D ambient overlays;
- non-interactive atmosphere layers.

## 8. Visual Art Direction

### Required Image Structure

The pond must be built as layered space:

```text
foreground frame
midground fish
water depth
fog veil
caustics
background darkness
```

The goal is air perspective and water depth, not flat decoration.

### Composition Rules

- Avoid pure top-down prototype framing.
- Use light perspective and cinematic tilt.
- Keep fish visibly inside water, not pasted onto a plane.
- Use darker edges to hide screen rectangularity.
- Reserve the brightest area for the focal water/fish zone.
- Foreground elements should partially frame the pond.

### Color Direction

- deep blue-green water;
- low saturation;
- warm koi accents;
- pale caustic highlights;
- dark moss/stone edges;
- no neon;
- no arcade bloom.

### UI Direction

The HUD must communicate ambient premium software, not a technical demo.

Remove from production UI:

- SceneKit references;
- native/technical labels;
- fish count chips;
- instructional debug text;
- game-like counters.

Allowed main pond UI:

- `NEKO POND` wordmark;
- calm subtitle;
- time / season / temperature flavor text;
- one small settings control;
- three low-presence circular owner controls if needed;
- auto-fade after a short delay.

## 9. Fish Direction

The current behavior foundation is valuable and should be preserved.

The current fish visual construction must be replaced or heavily revised. Sphere/capsule fish are no longer acceptable for the vertical slice.

### Fish Visual Goal

The goal is not high polygon count. The goal is credible silhouette.

Required qualities:

- tapered koi body;
- readable head/body/tail proportions;
- translucent fins;
- soft specular;
- restrained koi pattern;
- believable swimming arc;
- stable readability from the pond camera.

### Fish Behavior Goal

Do not expand behavior complexity until the visuals become credible.

Keep and tune:

- curiosity;
- hesitation;
- attention;
- calm/alert rhythm;
- passive drift;
- edge pressure;
- depth drift.

Add later only after visual credibility:

- alignment;
- cohesion;
- schooling confidence;
- fear propagation;
- comfort memory.

## 10. Water Direction

Current torus ripples should be treated as prototype-only.

Short-term vertical slice water should prioritize poetic believability over physical simulation.

### Immediate Water Goals

- replace hard SCNTorus ripple look with soft sprite/shader-like ripples;
- add depth color gradient;
- add subtle animated caustic impression;
- add underwater veil/fog over fish;
- add fish shadow/depth cues;
- reduce flat-plane feeling;
- keep effects quiet and low contrast.

### Deferred Water Goals

Do not build full GPU water simulation yet. Defer:

- height-field ripple simulation;
- fish wake field;
- rain field;
- normal map generation;
- Metal caustic distortion;
- full post-processing chain.

## 11. Touch Interaction Direction

Touch must feel calm and causal.

Default tap should not feed fish.

### Correct Semantics

```text
tap water      -> soft ripple + nearby curiosity
tap near fish  -> fish notices or lightly evades
long press     -> gentle attention / attraction
drag           -> water trail / disturbance
feed button    -> occasional food, explicit mode only
Apple Pencil   -> quiet water stroke, no reward spam
```

Touch feedback should be immediate but not loud.

## 12. Audio Direction

Audio is important but not the next blocker.

During One Perfect Pond, define only the audio architecture and optionally add a minimal ambient prototype.

Future audio layers:

- water;
- wind;
- distant birds;
- insects;
- bamboo/wood creaks;
- rain;
- fish proximity details;
- touch one-shots.

The target is non-loop-feeling ambient sound, not background music.

## 13. Development Milestones

### M0 — Current Prototype Inventory

Objective: document what exists and freeze feature expansion.

Deliverables:

- current SceneKit prototype retained;
- current fish behavior retained;
- technical demo labels identified for removal;
- food-on-tap marked as product risk;
- One Perfect Pond scope accepted.

Exit criteria:

- no new product systems are added before visual baseline work starts.

### M1 — Cinematic Frame

Objective: make a paused screenshot feel premium.

Deliverables:

- revised camera angle and field of view;
- stronger foreground/midground/background composition;
- darker pond edge treatment;
- lily/stone/moss/petal framing pass;
- reduced flat-plane read.

Exit criteria:

- first frame no longer reads as debug prototype;
- screenshot can be used as internal App Store-style target reference.

### M2 — HUD Disappearance

Objective: remove technical demo language and establish ambient OS tone.

Deliverables:

- remove SceneKit/native/fish-count/debug labels;
- add restrained wordmark/time/season treatment;
- add small settings affordance;
- implement fade/low-presence behavior;
- keep controls non-game-like.

Exit criteria:

- UI no longer changes user interpretation toward game/demo;
- pond remains dominant.

### M3 — Credible Koi Silhouette

Objective: stop the fish from reading as geometric primitives.

Deliverables:

- new low-poly/stylized realistic koi mesh or revised procedural mesh;
- tapered body;
- translucent fins;
- improved patterns;
- material tuning;
- preserved existing movement system.

Exit criteria:

- fish still frame reads as koi-like;
- motion reads as living animal, not AI geometry.

### M4 — Soft Water Illusion

Objective: make water visually poetic without full simulation.

Deliverables:

- soft ripple visual replacement;
- caustic impression layer;
- depth gradient;
- underwater veil;
- fish depth/shadow tuning;
- restrained bloom/vignette.

Exit criteria:

- fish appear inside water;
- touch ripples no longer feel arcade/prototype;
- scene has depth in motion and still frame.

### M5 — Calm Touch Semantics

Objective: remove game-loop interpretation from default touch.

Deliverables:

- tap no longer spawns food;
- tap water creates ripple and curiosity only;
- feed becomes explicit optional control;
- touch near fish triggers notice/evade behavior;
- long press supports gentle attraction.

Exit criteria:

- default interaction feels like disturbing a pond, not collecting rewards.

### M6 — Three-Minute Watch Test

Objective: validate One Perfect Pond.

Test:

- launch app on real iPad;
- watch for three minutes without interacting;
- interact lightly for one minute;
- return to idle for one minute.

Acceptance:

- no obvious prototype UI;
- no visible mechanical loops;
- no distracting effects;
- stable frame pacing;
- scene remains pleasant without feature novelty.

## 14. Performance Targets

Vertical slice targets:

- stable 60 fps minimum;
- 120Hz readiness on iPad Pro where practical;
- no per-frame texture creation;
- no heavy allocations in update loop;
- no unbounded effect node growth;
- touch feedback visible within one frame when possible;
- visual effects must degrade gracefully before frame pacing suffers.

## 15. Decision Rules

When choosing between feature depth and visual credibility, choose visual credibility.

When choosing between rendering purity and faster art direction leverage, choose leverage.

When choosing between a realistic simulation and a more poetic believable illusion, choose the believable illusion.

When choosing between more UI and less UI, choose less UI.

When choosing between game reward and ambient causality, choose ambient causality.

## 16. Definition of Done for One Perfect Pond

One Perfect Pond is done when:

- the first second feels premium;
- a paused frame looks product-grade;
- the fish look credible enough to support their behavior;
- water creates depth and atmosphere;
- HUD nearly disappears;
- default touch is calm and causal;
- the app can be watched for three minutes without needing feature novelty;
- the implementation remains native, stable, and ready for selective Metal upgrades.
