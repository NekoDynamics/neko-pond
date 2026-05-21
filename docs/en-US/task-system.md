# Task Execution System

## Core Principle

AI performs best with small, isolated, deterministic, testable tasks. Neko Pond must be built as a sequence of narrow engineering changes, not broad rewrites.

A good task has one objective, a bounded file set, explicit constraints, measurable acceptance criteria, and a validation path. A bad task asks the AI to infer architecture, invent scope, or improve multiple systems at once.

## Task Granularity Rules

### Good Task Examples

- Implement fish edge avoidance steering.
- Add `TouchSample` merging for nearby multi-touch points.
- Create a pooled ripple node lifecycle.
- Add debug overlay for fish state labels.
- Clamp delta time after scene resume.
- Add config values for fish cruise and flee speed.
- Write tests for steering vector selection.

### Bad Task Examples

- Build fish system.
- Make gameplay better.
- Refactor rendering.
- Add AI.
- Polish visuals.
- Optimize performance.
- Create the whole app.
- Make it production-ready.

### Scope Limits

A normal task should:

- touch one primary system;
- affect one to three production files;
- include tests or validation notes;
- avoid architecture changes;
- avoid unrelated formatting.

A large task is allowed only when it includes a written plan and explicit approval. Large tasks include:

- changing folder structure;
- introducing Metal;
- introducing CoreML;
- changing scene ownership;
- adding a new module;
- touching more than five production files.

## Task Template

Use this template for Codex-first execution:

```text
Objective:
Implement <specific behavior>.

Context:
<short description of current system and why the change is needed>.

Affected files:
- <exact file path>
- <exact file path>

Constraints:
- Keep SwiftUI out of gameplay logic.
- Do not change public folder structure.
- Do not introduce backend/network dependencies.
- Keep SpriteKit node mutation on the main thread.
- Preserve existing naming conventions.

Acceptance criteria:
- <measurable behavior>
- <edge case>
- <debug/observability requirement if needed>

Performance constraints:
- No per-frame heap allocation in hot loops.
- No texture or audio loading during active play.
- Must preserve 60 fps target.

Forbidden changes:
- Do not rewrite PondScene.
- Do not introduce a generic ECS framework.
- Do not modify unrelated UI.
- Do not add dependencies.

Testing requirements:
- Run <compile/test command>.
- If visual/touch behavior changed, test on real iPad when available.
- Summarize validation results and residual risks.
```

## Prompt Engineering Rules

### How Prompts Should Be Written

Prompts must be precise and operational. They should define the system boundary and the acceptance criteria before asking for implementation.

Good prompt:

```text
Implement edge avoidance in SteeringSystem only. Fish should begin turning before reaching the screen edge using a configurable comfort distance. Do not use hard bounce. Update FishMotionConfig if needed. Add tests for left, right, top, and bottom edge steering. Do not change PondScene except to call the existing system API if required.
```

Bad prompt:

```text
Make fish movement realistic and clean up the code.
```

### Scope Constraint Rules

Every prompt should state:

- files or folders in scope;
- files or folders out of scope;
- whether refactoring is allowed;
- whether tests are required;
- what performance risks matter.

### Architecture Change Requests

Architecture changes require a two-step process:

1. planning task: ask for a proposed design and affected files only;
2. implementation task: approve a specific plan and file scope.

Do not combine architecture discovery and implementation in one prompt.

### Refactor Approval Rules

Refactors are allowed only when:

- they directly support the task;
- the before/after behavior is unchanged;
- affected files are listed;
- validation is possible;
- no public architecture rule is weakened.

Forbidden refactors:

- broad renames without need;
- protocol extraction without multiple implementations;
- moving code across modules without approval;
- rewriting working systems for style preference;
- mixing behavior changes with formatting sweeps.

## Review Workflow

### Compile Check

Every production code task must pass a compile check when the project exists. If the project cannot compile due to unrelated known issues, the result must document:

- command run;
- unrelated failure location;
- why changed files are not the cause;
- next validation step.

### FPS Validation

For frame-sensitive changes, validate:

- average frame rate;
- visible frame spikes;
- behavior during rapid multi-touch;
- particle count under stress;
- device profile behavior.

Use real iPad hardware for final acceptance of touch or rendering changes.

### Architecture Validation

Review changed code for:

- SwiftUI gameplay leakage;
- scene god object growth;
- global mutable state;
- force unwraps or casts;
- unbounded allocations;
- dependency direction violations;
- unnecessary protocols or abstractions;
- backend/network dependency introduction.

### Regression Checks

Before marking a task validated, confirm:

- fish still move;
- touch still produces immediate feedback;
- scene pause/resume still works;
- existing debug overlays still compile;
- visual style remains consistent;
- no unrelated files changed.

### Visual Consistency Review

For visual tasks, inspect:

- color restraint;
- particle density;
- fish readability;
- edge darkness and screen boundary behavior;
- absence of arcade effects;
- low-light usability;
- video capture quality if relevant.

## AI Safety Rules

### Prevent Random Abstractions

- Do not accept new protocols unless at least two concrete implementations exist or a test seam requires it.
- Do not accept generic managers with broad responsibilities.
- Do not accept “future-proof” layers without a current milestone need.
- Do not accept dependency injection frameworks for MVP.

### Prevent Unnecessary Protocols

Allowed protocols:

- stable renderer boundary for future Metal comparison;
- random source abstraction for deterministic tests;
- audio playback interface for testability;
- clock/time source interface for simulation tests.

Suspicious protocols:

- `FishManaging`;
- `SceneHandling`;
- `GameObjectProtocol`;
- `AnySystem`;
- broad service locator contracts.

### Prevent Dependency Explosions

- No third-party dependencies for MVP gameplay unless explicitly approved.
- Prefer Apple frameworks.
- Do not add package dependencies for simple math, logging, or data structures.
- Do not add analytics SDKs before MVP engagement validation.

### Prevent Speculative Architecture

Before adding a new layer, answer:

- what current milestone requires this layer?
- what code becomes simpler now?
- how will it be tested?
- what is the cost of not adding it yet?

If the answer is future optionality, do not add it.

## Task Lifecycle

### Planned

A task is planned when it has:

- objective;
- affected files;
- constraints;
- acceptance criteria;
- validation method.

### In Progress

A task is in progress when implementation starts. During this state:

- do not expand scope silently;
- record blockers;
- keep changes minimal;
- avoid opportunistic cleanup.

### Review

A task enters review when implementation is complete. Review includes:

- diff inspection;
- architecture check;
- style check;
- validation command;
- performance reasoning if relevant.

### Validated

A task is validated when acceptance criteria are met and validation is documented. Visual and touch-sensitive tasks require real-device validation before final milestone acceptance.

### Merged

A task is merged only after:

- validation is complete;
- commit message matches naming rules;
- milestone status is updated if applicable;
- residual risks are documented.

## Output Contract for AI Tasks

Every Codex task result should report only:

1. changed files;
2. validation steps;
3. residual risks.

No broad explanations unless requested. The goal is traceability, not storytelling.
