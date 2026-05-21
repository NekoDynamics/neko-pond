# Codex Workflow Guide

## Recommended Workflow

Neko Pond is built with a Codex-first workflow, but Codex must operate inside strict engineering boundaries. The default loop is:

1. plan;
2. isolate;
3. implement;
4. validate;
5. commit.

### Plan

Define the objective, affected files, acceptance criteria, and forbidden changes. If the task affects architecture, write a plan first and do not implement until approved.

### Isolate

Limit each session to one system or one bug. Load only the relevant files. Avoid broad repository scans after context is established.

### Implement

Make minimal changes. Preserve naming, folder structure, and dependency direction. Do not rewrite working systems for style preference.

### Validate

Run the narrowest useful validation first. For gameplay and rendering, compile checks are not enough. Real iPad testing is required before milestone acceptance.

### Commit

Commit only validated, coherent changes. Do not mix unrelated fixes. Commit message must identify the system and behavior.

## How To Talk To Codex

### Good Prompts

```text
Implement natural pause behavior in FishBehaviorSystem. Scope is FishBehaviorSystem.swift, FishState.swift, and FishMotionConfig.swift only. Fish should enter pausing from wandering using a configurable probability after a minimum wander duration. During pause, velocity should decay but micro-motion should continue. Do not modify SwiftUI or rendering. Add tests for transition timing.
```

```text
Add a RippleNodePool for touch ripples. Scope is Particles/RippleNodePool.swift and Particles/RippleSystem.swift. The pool must cap active ripples and reuse nodes. Do not create textures during touch handling. Acceptance: rapid 5-finger tapping does not create unbounded nodes.
```

```text
Add a debug touch visualizer behind DEBUG only. Scope is Debug/DebugTouchVisualizer.swift and PondScene integration. It must read touch disturbance snapshots and draw circles. It must not mutate gameplay state or compile into release builds.
```

### Bad Prompts

```text
Build the fish gameplay.
```

```text
Make everything more Apple-like.
```

```text
Refactor the project and improve performance.
```

```text
Add AI behavior, Metal water, and monetization.
```

### Scope Examples

Good scope:

- one system;
- one config group;
- one debug tool;
- one visual effect;
- one test target.

Bad scope:

- all gameplay;
- all rendering;
- app-wide cleanup;
- architecture rewrite;
- feature plus monetization;
- bug fix plus visual redesign.

### Architecture-Safe Prompts

Use architecture-safe phrasing:

- “Do not change folder structure.”
- “Do not introduce new protocols unless required for tests.”
- “Do not move gameplay logic into SwiftUI.”
- “Keep SpriteKit node mutation inside scene/rendering systems.”
- “Do not add network or backend dependencies.”
- “If more files are needed, stop and explain why.”

## Session Management

### One-Task-Per-Session Philosophy

Each Codex session should produce one coherent change. This reduces context drift and makes review possible. A session may include tests and docs for that change, but it must not opportunistically edit unrelated systems.

### Avoiding Context Drift

To avoid drift:

- start from the milestone objective;
- open only top relevant files;
- keep the affected file list visible;
- reject unrelated improvements;
- stop when acceptance criteria are met;
- document residual risks instead of expanding scope.

### Preserving Architecture Consistency

Before asking Codex to modify code, reference the relevant rule document:

- `engineering-rules.md` for global constraints;
- `project-structure.md` for folder ownership;
- `gameplay-systems.md` for simulation behavior;
- `visual-system.md` for art and motion rules;
- `task-system.md` for prompt shape;
- `milestones.md` for phase gates.

## Git Workflow

### Branch Naming

Use `codex/` prefix for AI-assisted branches.

Format:

```text
codex/<milestone>-<system>-<short-objective>
```

Examples:

```text
codex/m2-fish-natural-wander
codex/m3-touch-disturbance-fields
codex/m4-ripple-pooling
```

### Commit Naming

Use imperative commit messages.

Format:

```text
<system>: <specific change>
```

Examples:

```text
Fish: add natural pause transitions
Touch: merge nearby multi-touch samples
Particles: pool ripple nodes
Debug: add fish state overlay
```

### Milestone Tagging

When a milestone is validated, tag it with:

```text
m<number>-<short-name>
```

Examples:

```text
m1-single-fish
m4-ripple-system
m8-five-minute-engagement
```

Tags require documented validation notes.

## Validation Workflow

### Compile Validation

Run compile validation after code changes. Use the project-standard command once the Xcode project exists. If using CLI:

```text
xcodebuild -scheme NekoPond -destination 'platform=iOS Simulator,name=iPad Pro (11-inch)' build
```

Adjust scheme and destination to the actual project.

### FPS Validation

For gameplay/rendering changes:

- run on real iPad;
- enable performance HUD in debug;
- test idle scene;
- test rapid multi-touch;
- test maximum fish count;
- test pause/resume;
- record frame spikes.

Acceptance requires stable 60 fps minimum for MVP milestones.

### Touch Validation

Touch validation checklist:

- touch-down ripple appears immediately;
- fish near touch responds quickly;
- far fish do not all flee unnecessarily;
- multi-touch does not flood particles;
- long stationary touch decays;
- touch after resume does not use stale samples.

### Cat Testing Workflow

For each cat test:

1. clean iPad screen;
2. set safe brightness and volume;
3. enable Guided Access if needed;
4. start recording with external phone;
5. run one parameter preset only;
6. observe without interfering;
7. stop when cat disengages or session target completes;
8. record duration, touch count estimate, and behavior notes;
9. review video for latency and fatigue;
10. tune one parameter group at a time.

## Anti-Patterns

### Giant Prompts

Do not ask Codex to implement entire milestones at once. Giant prompts produce broad diffs, hidden architecture changes, and unreviewable behavior.

### Multi-System Rewrites

Do not rewrite fish, touch, particles, rendering, and UI in one task. System integration must happen through explicit APIs and milestone gates.

### Speculative Optimization

Do not optimize code that has not been measured. Prefer simple clear logic until Instruments or device testing identifies a bottleneck.

### Premature Abstraction

Do not create generic engines, plugin systems, behavior graphs, ECS frameworks, renderer interfaces, or AI pipelines before the MVP proves engagement.

### Visual Overreach

Do not add complex shaders, dense particles, or bright effects before fish behavior and touch response are validated.

### Backend Drift

Do not add accounts, sync, analytics SDKs, or remote config in MVP. Local engagement validation comes first.

## Final Output Format for Codex Sessions

Codex should end implementation sessions with:

```text
Changed files:
- <file>

Validation steps:
- <command or manual validation>

Residual risks:
- <risk or None>
```

This keeps AI-assisted development auditable and prevents narrative drift.
