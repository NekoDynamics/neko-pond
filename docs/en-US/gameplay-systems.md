# Gameplay System Specification

## System Overview

Neko Pond gameplay is a real-time prey simulation. The core systems must produce believable fish behavior, immediate touch feedback, natural ripples, controlled spawning, ambient motion, and frame-independent timing.

The MVP is not a game loop with points. It is an engagement loop:

1. fish attract attention;
2. cat tracks movement;
3. touch disturbs water;
4. fish react believably;
5. pond recovers;
6. new opportunity appears.

## Fish Entity System

### Entity Model

Each fish has:

- stable identifier;
- position;
- velocity;
- acceleration;
- heading;
- target heading;
- state;
- personality;
- visual descriptor;
- stress value;
- state timer;
- pause timer;
- preferred speed range;
- edge comfort distance;
- interaction sensitivity.

### State Machine

Required MVP states:

- `spawning`: fish enters scene safely;
- `wandering`: fish explores with natural steering;
- `pausing`: fish slows and holds with micro-motion;
- `alert`: fish detects nearby disturbance and prepares to flee;
- `fleeing`: fish accelerates away from disturbance;
- `recovering`: fish slows and returns to normal behavior;
- `edgeAvoiding`: fish steers away from boundaries;
- `hidden`: optional non-rendered state for future hiding zones.

### State Transition Rules

- `spawning -> wandering` after entry animation completes.
- `wandering -> pausing` by weighted decision after minimum wander duration.
- `pausing -> wandering` after pause duration or disturbance.
- `wandering/pausing -> alert` when disturbance is within alert radius.
- `alert -> fleeing` when threat remains close or touch intensity is high.
- `fleeing -> recovering` after safe distance or flee duration.
- `recovering -> wandering` after speed returns to cruise range.
- Any visible state may temporarily apply edge avoidance steering near boundaries.

### Steering

Steering combines weighted vectors:

- wander vector;
- target vector;
- edge avoidance vector;
- separation vector;
- flee vector;
- damping vector.

Vector priority:

1. flee from immediate threat;
2. avoid edge collision;
3. maintain separation;
4. pursue wander target;
5. apply personality drift.

Steering must be acceleration-limited and heading-smoothed. Do not directly set position to target except during controlled spawn/despawn.

### Acceleration

Acceleration rules:

- cruise acceleration is gentle;
- flee acceleration is high but capped;
- recovery applies damping;
- pausing uses deceleration with micro-motion;
- edge avoidance should begin before collision.

All acceleration values belong in configuration.

### Randomness

Randomness applies to decisions, not raw per-frame movement. Randomize:

- next wander target;
- pause probability;
- pause duration;
- speed preference;
- turn bias;
- personality values;
- spawn timing.

Do not randomize position every frame. Do not add jitter that makes fish vibrate.

### Idle Behavior

Idle behavior includes:

- slow drift;
- small heading changes;
- fin-like visual movement when available;
- occasional tiny repositioning;
- reduced speed;
- readiness to react to touch.

Idle must be visually alive but not busy.

### Escape Behavior

Escape behavior inputs:

- nearest disturbance position;
- disturbance intensity;
- fish current heading;
- edge proximity;
- fish personality;
- recent stress.

Escape output:

- flee vector away from threat;
- speed boost;
- wake/ripple event;
- optional bubble event;
- increased stress;
- recovery timer.

Escape must avoid driving fish directly into screen edges. If the flee vector points into an edge, blend with tangent steering.

## Touch Interaction System

### Touch Sample

Each touch sample contains:

- unique touch identity when available;
- position in scene coordinates;
- phase;
- timestamp;
- movement delta;
- estimated intensity;
- active duration.

### Multi-Touch

Multi-touch rules:

- multiple touches produce multiple disturbances;
- nearby touches may merge into one field;
- stationary long touches decay in intensity;
- ended touches fade out quickly;
- active disturbance count is capped;
- touch bursts must not spawn unbounded ripples or audio.

### Latency Handling

- Touch-down should create visual feedback immediately.
- Fish response may update in the next frame but must be visibly quick.
- No asset loading, audio loading, or heavy allocation can happen on first touch.
- Touch processing must occur before fish behavior update in the frame order.

### Interaction Zones

Each disturbance has zones:

- direct zone: strong flee response;
- alert zone: fish becomes alert or changes heading;
- awareness zone: subtle movement influence;
- outside zone: no effect.

Zone radii belong in config and may vary by fish personality.

### Ripple Triggers

Ripple triggers:

- touch began: strong ripple;
- touch moved: throttled smaller ripple;
- touch ended: optional fading ripple;
- fish flee: small wake ripple;
- ambient event: rare subtle ripple.

## Ripple System

### Lifecycle

Ripple states:

- available in pool;
- spawned;
- expanding;
- fading;
- completed;
- returned to pool.

### Rendering

MVP rendering can use:

- `SKShapeNode` ring if performance acceptable;
- pre-rendered ring texture sprite;
- particle emitter for soft edges;
- shader-free alpha and scale animation.

Prefer pre-rendered textures and pooled nodes if shape rendering is costly.

### Blending

- Use additive or alpha blending sparingly.
- Ripples should not overexpose the screen.
- Overlapping ripples should remain water-like.
- Active ripple opacity may scale down as count increases.

### Timing

Configurable values:

- initial radius;
- final radius;
- lifetime;
- fade curve;
- maximum active ripples;
- move ripple cooldown;
- fish wake ripple cooldown.

Ripple timing must be frame-independent.

## Spawn System

### Density Control

Spawn system controls:

- minimum fish count;
- maximum fish count;
- spawn interval;
- spawn delay after touch storms;
- device-tier fish count;
- theme-specific density.

### Boundary Safety

Spawn locations must:

- avoid active touch zones;
- avoid immediate edge collision;
- prefer darker or visually plausible entry regions;
- assign inward initial heading;
- avoid spawning directly on top of existing fish.

### Anti-Clustering

Anti-clustering uses:

- minimum spawn distance;
- soft separation steering;
- target diversity;
- local density checks;
- temporary spawn suppression in crowded regions.

Fish may briefly pass near each other, but persistent overlap is forbidden.

## Environment System

### Ambient Motion

Environment motion includes:

- slow water gradient drift;
- subtle caustic movement;
- rare bubbles;
- slow particle drift;
- low-frequency lighting shifts.

Ambient motion must not compete with fish movement.

### Subtle Parallax

Parallax can create depth through:

- different particle speeds by layer;
- fish shadow offset;
- background caustic drift;
- foreground ripple layer.

Parallax must remain subtle. Excessive movement distracts from prey.

### Background Drift

Background drift should be:

- very slow;
- loop-safe;
- low contrast;
- independent from fish movement;
- disabled or reduced on lower device profiles if needed.

## Timing System

### Delta-Time Rules

- All gameplay movement uses delta time.
- Clamp delta time to a maximum after stalls or app resume.
- Avoid fixed frame assumptions.
- Convert time-based configs into seconds, not frames.

### Interpolation

Use interpolation for:

- fish heading smoothing;
- speed changes;
- ripple alpha;
- ambient light transitions;
- debug visualization smoothing.

Interpolation must be deterministic and time-based.

### Frame Independence

The same fish configuration should produce similar motion at 60 fps and 120 fps. Differences in display refresh should improve smoothness, not change behavior meaningfully.

### Time Sources

- Scene update time is authoritative for gameplay.
- Wall clock may be used for session duration.
- Audio engine time may be used only for audio scheduling.
- Do not mix wall clock directly into fish steering.

## System Integration Order

Per update frame:

1. compute `TimeStep`;
2. update touch interaction system;
3. spawn immediate ripple events;
4. update fish behavior states;
5. update steering and movement;
6. apply edge avoidance and separation;
7. apply visual node transforms;
8. update ripple lifecycle;
9. update particles;
10. update environment motion;
11. trigger throttled audio;
12. record metrics;
13. update debug overlays.

This order protects responsiveness and keeps simulation state authoritative.
