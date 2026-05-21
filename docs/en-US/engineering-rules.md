# Engineering Rules

## Engineering Philosophy

Neko Pond is a real-time iPadOS interaction product. Engineering decisions must protect responsiveness, deterministic behavior, and fast iteration. The product succeeds only if the pond feels alive to a cat on a real iPad.

### Core Rules

- Simplicity over abstraction: build the smallest clear system that supports the current milestone.
- Deterministic behavior: gameplay systems must be reproducible from explicit state and configuration.
- Performance-first thinking: every system must respect frame time, memory, and touch latency budgets.
- Low-latency interaction priority: touch response always outranks visual decoration and feature expansion.
- Gameplay-first development: fish behavior, touch response, and sustained cat engagement define product quality.
- Validation over feature expansion: no new feature is accepted until the current loop is measured on device.
- Native-first implementation: SwiftUI, SpriteKit, and Apple frameworks are the only MVP execution path.
- Local-first operation: MVP must not depend on backend availability, accounts, network requests, or remote config.

### Decision Priority

When tradeoffs conflict, use this order:

1. touch-to-visual responsiveness;
2. stable frame pacing;
3. believable prey behavior;
4. maintainable architecture;
5. visual polish;
6. extensibility;
7. monetization readiness.

A beautiful effect that harms response time is a failed effect. A flexible abstraction that slows iteration is a failed abstraction.

## Swift Rules

### Language Compatibility

- Code must target Swift 6 compatibility.
- New code must compile cleanly under strict concurrency checks where possible.
- APIs must avoid implicit shared mutable state.
- Compiler warnings must be treated as work items, not ignored background noise.

### Concurrency Policy

- Gameplay update logic runs on the main actor through SpriteKit's frame loop.
- Per-frame SpriteKit node mutation must remain on the main thread.
- Asset loading, metrics export, and future model preparation may use async work only outside active frame-critical paths.
- Async tasks must have explicit ownership and cancellation strategy.
- Do not launch untracked `Task {}` blocks from gameplay systems.
- Do not mutate gameplay state from background tasks.
- Use `@MainActor` for app state and scene coordination objects that touch UI or SpriteKit.

### Safety Rules

- No force unwraps in production code.
- No force casts in production code.
- No implicitly unwrapped optionals except Apple framework integration points where unavoidable and documented at declaration.
- Prefer `guard let` and explicit fallback behavior.
- Prefer value types for configuration, parameters, snapshots, and behavior inputs.
- Use reference types only for identity-bearing runtime objects, node owners, coordinators, and services.
- Never store strong reference cycles between scenes, systems, entities, and views.
- Closures capturing `self` from long-lived systems must use explicit capture semantics.

### Naming Conventions

- Types use `UpperCamelCase`.
- Properties, methods, and local variables use `lowerCamelCase`.
- Boolean names must read as predicates: `isFleeing`, `hasActiveTouch`, `shouldSpawnFish`.
- Systems end with `System`: `SteeringSystem`, `RippleSystem`.
- Coordinators end with `Coordinator`: `AudioCoordinator`, `SceneLifecycleCoordinator`.
- Configuration structs end with `Config`: `FishMotionConfig`, `ParticleBudgetConfig`.
- Debug-only helpers begin with `Debug` or live under `Debug/`.
- Avoid ambiguous names such as `Manager`, `Helper`, `Thing`, `Data`, and `Utils` unless scope is extremely narrow.

### Access Control

- Default to `internal` for module-local app code.
- Use `private` for implementation details inside a type.
- Use `fileprivate` only when two closely related types in the same file must share internals.
- Use `public` only for code intended to become a reusable package or SDK.
- Expose immutable state snapshots instead of mutable internal collections.

### File Organization

- One primary type per file.
- File name must match the primary type name.
- Extensions must be small and purpose-specific.
- Keep protocol definitions close to their primary use unless they are stable cross-module contracts.
- Do not create generic protocol hierarchies before two real implementations exist.
- Keep configuration separate from runtime logic.
- Keep debug UI separate from production systems.

## SwiftUI Rules

### Allowed Responsibilities

SwiftUI may handle:

- app entry and lifecycle observation;
- onboarding, settings, and owner-facing controls;
- session start, pause, and exit surfaces;
- embedding SpriteKit through `SpriteView` or a dedicated host view;
- displaying non-realtime debug panels in development builds;
- StoreKit and subscription UI in later phases;
- privacy, safety, and Guided Access guidance.

### Forbidden Responsibilities

SwiftUI must never:

- own fish state;
- run gameplay timers;
- calculate steering;
- process per-frame touch behavior;
- mutate SpriteKit nodes directly from view bodies;
- store SpriteKit scene state in `@State` or `@ObservedObject` for realtime logic;
- trigger gameplay effects from view redraws;
- contain animation loops for pond simulation;
- become the source of truth for session metrics generated in the scene.

### Integration Rule

SwiftUI owns the shell. SpriteKit owns the pond. Communication must use narrow commands and snapshots:

- SwiftUI to scene: start, pause, resume, apply config, end session.
- Scene to SwiftUI: session summary, debug metrics, lifecycle events.

## SpriteKit Rules

### Scene Ownership

- `PondScene` owns SpriteKit nodes, frame updates, touch input, and system orchestration.
- Systems may request node creation only through explicit scene-owned factories or coordinators.
- Entities store references to their own visual nodes only when lifecycle ownership is clear.
- SwiftUI never directly modifies scene graph children.

### Entity Lifecycle

- Entities are created by spawn systems or scene setup.
- Entities are updated by systems, not by independent timers.
- Entities are removed through a lifecycle queue, never during arbitrary collection iteration.
- Every entity must have stable identity for debugging and metrics.
- Entity state changes must be explicit enum transitions.

### Update Loop Responsibilities

The scene update loop must run in this order:

1. compute clamped delta time;
2. ingest queued touch samples;
3. update interaction fields;
4. update behavior state machines;
5. update steering and movement;
6. apply node transforms;
7. update ripples and particles;
8. update audio triggers;
9. record lightweight metrics;
10. update debug overlays in debug builds only.

Do not scatter gameplay updates across `SKAction` completion blocks, async callbacks, or SwiftUI state changes.

### Touch Handling Pipeline

- Touch events are sampled immediately in scene coordinates.
- Raw touches are converted into `TouchSample` values.
- Samples are merged or filtered by `TouchInteractionSystem`.
- Ripple feedback is emitted immediately.
- Fish systems consume disturbance fields during the next update.
- Multi-touch bursts must be bounded by effect budgets.

### Particle Ownership

- Particle emitters are owned by `ParticleSystem` or `ParticleCoordinator`.
- Emitters must be preloaded or pooled before active play when possible.
- Particle nodes must have deterministic lifetimes.
- No unbounded emitter creation during rapid multi-touch.
- Particle density must respect device profile budgets.

### Timing Systems

- Use delta time from SpriteKit update.
- Clamp unusually large delta time after app resume.
- Do not use `Timer` for gameplay simulation.
- Do not rely on `SKAction` chains for core state machines.
- Random decisions must be made through a project random source where reproducibility matters.

### Interpolation Rules

- Fish movement uses velocity, acceleration, heading smoothing, and steering forces.
- Avoid teleportation except controlled spawn/despawn transitions.
- Avoid linear point-to-point motion for fish behavior.
- Escape motion may be sharp but must preserve plausible acceleration and recovery.

### State Synchronization

- The simulation state is authoritative.
- SpriteKit nodes are a visual projection of simulation state.
- Debug overlays read snapshots; they do not mutate gameplay state.
- SwiftUI reads session summaries; it does not poll per-frame entity state.

## Performance Rules

### FPS Targets

- Minimum supported experience: stable 60 fps on target iPads.
- Premium target: 120 fps readiness on ProMotion devices.
- Active touch response must remain stable during rapid paw input.
- Frame pacing consistency is more important than peak visual density.

### Allocation Rules

- No avoidable heap allocation inside per-frame fish update loops.
- No texture loading during active play.
- No audio file loading on first interaction.
- No repeated creation of `SKAction` chains in `update`.
- Use pools for ripples, transient particles, and short-lived visual effects.
- Prefer fixed-capacity arrays for bounded realtime collections where practical.

### Texture Rules

- Use texture atlases for fish, particles, and water details.
- Keep texture sizes appropriate for iPad resolution and visual scale.
- Do not ship oversized placeholder textures.
- Preload critical textures before the session starts.
- Name texture assets consistently and document scale assumptions.

### Particle Limits

- Define per-device particle budgets.
- Cap active ripples.
- Cap touch-spray and bubble emitters.
- Reduce ambient particles during touch storms.
- Prefer fewer particles with precise timing over dense visual noise.

### Update-Loop Rules

- Update complexity must remain bounded and predictable.
- Avoid pairwise entity checks unless entity count is small and capped.
- Avoid expensive trigonometry in inner loops unless measured acceptable.
- Cache reusable calculations where clarity is preserved.
- Use Instruments before optimizing non-obvious code.

### Animation Rules

- Core gameplay animation must be state-driven.
- Use `SKAction` for noncritical decorative transitions only.
- Do not build deeply nested `SKAction` sequences.
- Do not depend on action completion timing for fish AI.
- Easing must preserve natural acceleration.

### GC-Like Behavior Avoidance

Swift has ARC, not garbage collection, but ARC churn can still create frame spikes. Avoid:

- creating many temporary class instances per frame;
- repeatedly attaching and removing large node trees;
- high-frequency closure allocation;
- repeated bridging between Swift collections and Objective-C APIs;
- unbounded autoreleased SpriteKit objects in touch loops.

### Frame Pacing Rules

- Clamp delta time after background resume.
- Degrade particles before degrading fish behavior.
- Degrade ambient effects before degrading touch feedback.
- Keep debug overlays optional and disabled in release.
- Profile on real iPad hardware before accepting performance-sensitive changes.

## Architecture Rules

### ECS-Inspired Architecture

Neko Pond uses ECS-inspired composition without committing to a heavy framework:

- Entity: identity plus domain state.
- Component: small value describing one aspect of state when useful.
- System: deterministic logic operating on entities or components.
- Coordinator: integration boundary for framework services such as audio or scene lifecycle.
- Config: immutable tuning inputs.

Do not introduce a generic ECS engine until MVP systems prove the need.

### Scene Graph Ownership

- SpriteKit scene graph belongs to scene and rendering systems.
- Simulation systems may request visual changes through explicit APIs.
- Entity state must not be inferred from node position when simulation state exists.
- Node hierarchy must match rendering layers, not arbitrary code ownership.

### Dependency Direction

Allowed direction:

`App -> Gameplay -> Core`

`Scenes -> Gameplay Systems -> Entities/Components -> Core/Utilities`

`Rendering -> Assets/Config/Core`

`Debug -> anything through read-only snapshots`

Forbidden direction:

- Core depending on SpriteKit scenes;
- Entities depending on SwiftUI;
- Systems depending on onboarding or settings views;
- Production gameplay depending on debug tools;
- MVP gameplay depending on backend services.

### Module Boundaries

- `App`: owner UI and app lifecycle.
- `Core`: shared math, time, random, device profiles, and primitives.
- `Gameplay`: fish behavior, touch interaction, timing, spawn, and environment systems.
- `Scenes`: SpriteKit scene composition and lifecycle.
- `Rendering`: visual layers, texture loading, future Metal integration.
- `Audio`: ambient and interaction sound policy.
- `AI`: rule-based adaptation now, CoreML later.
- `Debug`: development-only inspection.

### No God Objects

`PondScene` must not contain all gameplay logic. It may orchestrate systems but must not own detailed fish AI, steering math, ripple pooling logic, audio policy, spawn decisions, and metrics formatting inline.

### No Singleton Abuse

Singletons are forbidden for gameplay state. Limited shared services may exist only when:

- the service is stateless or explicitly immutable;
- lifecycle is app-wide by nature;
- testability is not harmed;
- dependency injection would add more complexity than value.

### Composition Over Inheritance

- Prefer structs, systems, and composed behavior policies.
- Avoid deep class inheritance chains for fish types.
- Use protocols only for stable seams with multiple concrete implementations.
- Do not create protocols solely because AI generated one.

## AI-Assisted Development Rules

### Codex Allowed Changes

Codex may change:

- one bounded system at a time;
- tests for the changed system;
- documentation directly related to the changed behavior;
- configuration values tied to explicit acceptance criteria;
- debug tools when requested;
- small refactors required to complete the task.

### Codex Forbidden Changes

Codex must never rewrite without explicit approval:

- project architecture;
- folder structure;
- public naming conventions;
- multiple unrelated systems;
- rendering strategy from SpriteKit to Metal;
- local-only MVP into backend-dependent architecture;
- SwiftUI views into gameplay owners;
- build settings unrelated to the task;
- generated assets or large binary files.

### Task Granularity

Every Codex task must fit one of these shapes:

- implement one system behavior;
- fix one bug;
- add one debug visualization;
- add one test suite;
- tune one configuration group;
- update one documentation topic.

A task that touches more than five production files requires a written plan before implementation.

### Prompt Style Rules

A good prompt must include:

- objective;
- affected files;
- constraints;
- forbidden changes;
- acceptance criteria;
- validation command;
- performance notes where relevant.

Prompts must not ask Codex to “improve,” “modernize,” “clean up,” or “refactor” without exact boundaries.

### Review Workflow

Before accepting AI-generated code:

1. inspect changed files;
2. verify dependency direction;
3. check for force unwraps and force casts;
4. check for gameplay in SwiftUI;
5. check per-frame allocations;
6. run compile or targeted tests;
7. run on iPad for interaction-sensitive changes;
8. update milestone status only after validation.

### AI-Safe Coding Practices

- Prefer explicit state machines over clever abstractions.
- Prefer small pure functions for math and steering.
- Keep configs typed and documented.
- Keep scene orchestration readable.
- Avoid hidden global state.
- Avoid generated protocols unless they protect a real seam.
- Keep acceptance criteria measurable.

## Forbidden Patterns

The following patterns are not allowed:

- massive scene classes containing all behavior;
- global mutable gameplay state;
- gameplay logic in SwiftUI views;
- deeply nested `SKAction` chains for AI;
- backend calls in MVP gameplay;
- reactive overengineering for realtime state;
- unbounded particle creation;
- texture loading during touch response;
- random abstraction layers with no current use;
- generic managers with unclear ownership;
- force unwraps in gameplay code;
- force casts in scene or entity code;
- hard edge bouncing as default fish behavior;
- fixed looping fish paths;
- UI overlays during cat play;
- analytics calls blocking the frame loop;
- AI-generated rewrites spanning unrelated systems.
