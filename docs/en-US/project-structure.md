# Project Structure Specification

## Purpose

This document defines the scalable engineering structure for Neko Pond. The structure must support native iPadOS development, SpriteKit-first gameplay, future Metal rendering, future CoreML/Vision systems, and AI-assisted development without architectural drift.

The structure is organized around ownership boundaries. Folders are not cosmetic. Each folder defines what code may live there, what dependencies are allowed, and what must never be imported.

## Root Structure

```text
NekoPond/
  App/
  Core/
  Gameplay/
  Scenes/
  Entities/
  Components/
  Systems/
  Rendering/
  Particles/
  Audio/
  Assets/
  Config/
  Utilities/
  Debug/
  AI/
  Experimental/
  Tests/
```

The current repository may use documentation-level folders before the Xcode project exists. When the native app is created, this structure should be mirrored inside the iPadOS target or Swift package layout.

## Folder Specifications

### App/

Purpose: app entry, owner-facing UI, lifecycle, settings, onboarding, and session presentation.

Ownership:

- SwiftUI app shell;
- navigation flow;
- onboarding and safety instructions;
- settings screens;
- session host view;
- StoreKit surfaces in later phases.

Allowed dependencies:

- SwiftUI;
- SpriteKit only for scene hosting types;
- Core configuration;
- scene lifecycle interfaces;
- StoreKit in monetization phases.

Forbidden dependencies:

- fish steering internals;
- entity mutation;
- per-frame systems;
- particle implementation details;
- direct texture atlas manipulation;
- debug-only systems in release code.

### Core/

Purpose: stable primitives shared across modules.

Ownership:

- math primitives;
- time utilities;
- deterministic random source;
- device profiles;
- geometry helpers;
- lightweight result types;
- platform capability descriptions.

Allowed dependencies:

- Foundation;
- CoreGraphics;
- simd when needed.

Forbidden dependencies:

- SwiftUI;
- SpriteKit scene classes;
- app views;
- audio systems;
- AI models;
- debug overlays.

### Gameplay/

Purpose: domain-level gameplay orchestration and behavior policies.

Ownership:

- fish behavior rules;
- engagement loop rules;
- interaction interpretation;
- spawn policies;
- environment simulation policies;
- session metrics events.

Allowed dependencies:

- Core;
- Entities;
- Components;
- Systems;
- Config.

Forbidden dependencies:

- SwiftUI;
- owner onboarding screens;
- StoreKit;
- backend clients;
- debug UI;
- direct asset file loading.

### Scenes/

Purpose: SpriteKit scene composition, scene lifecycle, input entry, and system scheduling.

Ownership:

- `PondScene`;
- scene factory;
- render layer setup;
- touch event entry;
- update-loop orchestration;
- scene pause/resume handling.

Allowed dependencies:

- SpriteKit;
- Gameplay;
- Systems;
- Rendering;
- Particles;
- Audio;
- Config;
- Debug in debug builds only.

Forbidden dependencies:

- SwiftUI state ownership;
- StoreKit;
- backend clients;
- CoreML training or model lifecycle;
- large inline behavior implementations.

### Entities/

Purpose: identity-bearing runtime objects such as fish and environment actors.

Ownership:

- fish identity;
- fish state;
- behavior state enum;
- stable runtime properties;
- references to visual nodes only when ownership is explicit.

Allowed dependencies:

- Core;
- Components;
- Config;
- SpriteKit only for visual node reference wrappers when necessary.

Forbidden dependencies:

- SwiftUI;
- app views;
- scene orchestration;
- audio playback;
- debug UI;
- backend models.

### Components/

Purpose: small values describing aspects of entities.

Ownership:

- motion component;
- steering component;
- visual component descriptor;
- interaction sensitivity;
- spawn metadata;
- stress or alert component.

Allowed dependencies:

- Core;
- Foundation;
- CoreGraphics;
- simd.

Forbidden dependencies:

- SpriteKit nodes;
- SwiftUI views;
- audio engines;
- scene classes;
- file IO.

### Systems/

Purpose: deterministic logic operating on entities and components.

Ownership:

- steering;
- fish behavior transitions;
- touch interaction fields;
- ripple lifecycle coordination;
- spawn decisions;
- edge avoidance;
- timing;
- metrics aggregation.

Allowed dependencies:

- Core;
- Entities;
- Components;
- Config;
- Rendering interfaces when a system owns visual projection;
- Particles through narrow APIs.

Forbidden dependencies:

- SwiftUI;
- onboarding;
- StoreKit;
- raw app lifecycle;
- unbounded global services;
- backend clients in MVP.

### Rendering/

Purpose: visual layer management, texture loading, shader boundaries, and future Metal integration.

Ownership:

- render layers;
- texture atlas loading;
- fish visual projection;
- water background;
- lighting overlays;
- future Metal renderer adapters.

Allowed dependencies:

- SpriteKit;
- Metal in future phases;
- Core;
- Assets;
- Config.

Forbidden dependencies:

- fish behavior decisions;
- touch interpretation;
- subscription logic;
- camera analysis;
- metrics policy.

### Particles/

Purpose: particle definitions, pooling, budgets, and visual effect lifecycle.

Ownership:

- ripple nodes;
- bubble emitters;
- wake effects;
- touch disturbance particles;
- emitter pools;
- particle budget enforcement.

Allowed dependencies:

- SpriteKit;
- Core;
- Config;
- Rendering layer definitions.

Forbidden dependencies:

- fish AI state transitions except read-only effect triggers;
- SwiftUI;
- app navigation;
- backend;
- audio playback policy.

### Audio/

Purpose: ambient soundscape and interaction sound policy.

Ownership:

- ambient loops;
- ripple sound triggers;
- cooldowns;
- volume policy;
- audio session behavior;
- future adaptive soundscapes.

Allowed dependencies:

- AVFoundation;
- Core;
- Config;
- session lifecycle events.

Forbidden dependencies:

- fish steering calculations;
- particle ownership;
- SwiftUI view bodies;
- backend services;
- direct touch event mutation.

### Assets/

Purpose: project assets and source asset organization.

Ownership:

- texture atlases;
- fish sprites;
- water textures;
- particle textures;
- audio files;
- color palettes;
- theme resources.

Allowed dependencies:

- no code dependencies.

Forbidden dependencies:

- generated code mixed with source assets unless part of documented build pipeline;
- unrelated marketing files inside runtime asset folders;
- oversized temporary art in production asset catalogs.

### Config/

Purpose: typed configuration for tuning behavior, visuals, performance, and themes.

Ownership:

- fish motion config;
- spawn config;
- ripple config;
- particle budgets;
- device profiles;
- theme config;
- debug flags.

Allowed dependencies:

- Core;
- Foundation;
- Codable models where useful.

Forbidden dependencies:

- SpriteKit nodes;
- SwiftUI views;
- runtime scene ownership;
- audio engine instances;
- mutable global configuration changed during frame update without explicit mechanism.

### Utilities/

Purpose: narrow helpers that do not belong to domain systems.

Ownership:

- object pools;
- lightweight logging wrappers;
- clamp and interpolation helpers;
- collection helpers;
- assertion utilities;
- profiling marks.

Allowed dependencies:

- Foundation;
- CoreGraphics;
- Core.

Forbidden dependencies:

- broad app services;
- generic helpers with unclear owners;
- feature-specific gameplay logic;
- SwiftUI screens;
- scene classes.

### Debug/

Purpose: development-only inspection and validation tools.

Ownership:

- performance HUD;
- fish state inspector;
- touch visualizer;
- edge field overlay;
- particle count display;
- session metrics panel.

Allowed dependencies:

- read-only snapshots from all modules;
- SpriteKit debug nodes;
- SwiftUI debug panels when outside active play.

Forbidden dependencies:

- production gameplay mutation;
- release-only code paths;
- hidden dependencies required by production;
- debug flags that change shipped behavior unintentionally.

### AI/

Purpose: behavior adaptation systems, future CoreML models, future Vision integration policies.

Ownership:

- rule-based adaptation;
- local session profiles;
- engagement state inference;
- future CoreML model wrappers;
- future Vision observation modules.

Allowed dependencies:

- Core;
- Gameplay snapshots;
- Config;
- CoreML in future phases;
- Vision in future phases.

Forbidden dependencies:

- direct SpriteKit node mutation;
- SwiftUI view ownership;
- backend dependency in MVP;
- opaque model decisions without fallback rules.

### Experimental/

Purpose: prototypes that are not production commitments.

Ownership:

- shader experiments;
- alternate fish motion prototypes;
- cat testing prototypes;
- performance experiments;
- future ecosystem spikes.

Allowed dependencies:

- any local dependency required for isolated experiments.

Forbidden dependencies:

- production code depending on Experimental;
- experimental files silently shipping in release builds;
- undocumented promotion from experiment to production.

## Naming Standards

### File Naming

- File name matches primary type: `FishEntity.swift`.
- System file names end in `System.swift`.
- Config file names end in `Config.swift`.
- Debug files begin with `Debug` when the primary purpose is inspection.
- Test files end in `Tests.swift`.

### Scene Naming

- Main playable pond scene: `PondScene`.
- Scene factories: `PondSceneFactory`.
- Scene lifecycle helpers: `SceneLifecycleCoordinator`.
- Avoid generic names such as `GameScene` after the bootstrap stage.

### Texture Naming

Format:

```text
<domain>_<variant>_<state>_<scale>
```

Examples:

```text
fish_koi_idle_1x
fish_koi_turn_1x
water_caustic_soft_2x
particle_ripple_ring_1x
particle_bubble_small_1x
```

Rules:

- use lowercase;
- use underscores;
- include domain first;
- avoid spaces;
- avoid ambiguous final names like `newFish` or `effect2`.

### Audio Naming

Format:

```text
<audio-domain>_<intent>_<variant>
```

Examples:

```text
ambient_water_calm_a
interaction_ripple_soft_b
interaction_bubble_tiny_a
```

Rules:

- use short descriptive names;
- include intensity where useful;
- avoid loudness surprises between variants;
- document looping files.

### Config Naming

Format:

```text
<Feature><Purpose>Config
```

Examples:

- `FishMotionConfig`
- `RippleVisualConfig`
- `ParticleBudgetConfig`
- `SpawnDensityConfig`
- `PondThemeConfig`

## Example File Tree

```text
App/
  NekoPondApp.swift
  AppState.swift
  SceneHostView.swift
  Onboarding/
    SafetyOnboardingView.swift
    GuidedAccessGuideView.swift
  Settings/
    SettingsView.swift

Core/
  TimeStep.swift
  RandomSource.swift
  DeviceProfile.swift
  Geometry.swift
  Interpolation.swift

Entities/
  FishEntity.swift
  FishState.swift
  FishPersonality.swift

Components/
  MotionComponent.swift
  SteeringComponent.swift
  InteractionSensitivityComponent.swift
  VisualDescriptorComponent.swift

Systems/
  FishBehaviorSystem.swift
  SteeringSystem.swift
  EdgeAvoidanceSystem.swift
  TouchInteractionSystem.swift
  SpawnSystem.swift
  SessionMetricsSystem.swift

Scenes/
  PondScene.swift
  PondSceneFactory.swift
  SceneLifecycleCoordinator.swift

Rendering/
  RenderLayer.swift
  PondRenderer.swift
  FishVisualFactory.swift
  TextureAtlasLoader.swift
  LightingOverlayRenderer.swift

Particles/
  RippleSystem.swift
  RippleNodePool.swift
  BubbleEmitterPool.swift
  ParticleBudget.swift

Audio/
  AudioCoordinator.swift
  AmbientSoundscape.swift
  InteractionSoundPolicy.swift

Config/
  FishMotionConfig.swift
  SpawnConfig.swift
  RippleConfig.swift
  PondThemeConfig.swift
  PerformanceConfig.swift

Utilities/
  ObjectPool.swift
  RingBuffer.swift
  DebugLogger.swift

Debug/
  DebugPerformanceHUD.swift
  DebugTouchVisualizer.swift
  DebugFishStateOverlay.swift

AI/
  RuleBasedAdaptationSystem.swift
  LocalSessionProfile.swift
  EngagementState.swift

Experimental/
  MetalWaterPrototype/
  MotionTuningPlayground/
```

## Modular Growth Strategy

### MVP Stage

Keep modules simple. `PondScene` orchestrates systems, systems own logic, entities own state, rendering owns nodes. Avoid package fragmentation until compile time, test boundaries, or reuse needs justify it.

### Post-MVP Stage

Promote stable systems into Swift packages only after APIs stop changing frequently. Candidate packages:

- `NekoCore`;
- `NekoGameplay`;
- `NekoRendering`;
- `NekoAI`.

### Team Stage

When more engineers join, ownership can map to folders:

- gameplay engineer: Gameplay, Entities, Components, Systems;
- iPadOS engineer: App, Scenes, lifecycle;
- rendering engineer: Rendering, Particles, Metal;
- AI engineer: AI, metrics, adaptation;
- technical artist: Assets, Config, visual tuning.

## Future Metal Migration Strategy

Metal must be introduced as a rendering module, not as a rewrite of gameplay.

Migration rules:

- keep fish behavior independent from renderer;
- define render snapshots that Metal can consume;
- preserve SpriteKit touch handling unless there is a measured reason to replace it;
- prototype Metal water in Experimental first;
- compare frame pacing and latency before production adoption;
- keep fallback SpriteKit rendering for older devices until support policy changes.

Metal candidates:

- water displacement;
- caustic lighting;
- GPU ripple field;
- soft refraction;
- advanced particle fields;
- post-processing vignette and bloom limits.

Metal must never be introduced only because it sounds premium. It must solve a measured visual or performance limitation.
