# 10 — Build, QA, and performance plan

This document defines validation requirements for implementation phases.

## Standard build command

Use `/tmp` DerivedData to avoid polluting the repo:

```bash
xcodebuild -project App/iPadOS/NekoPond.xcodeproj -scheme NekoPond -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M4)' -derivedDataPath /tmp/NekoPondDerivedData build
```

For final QA, use clean build:

```bash
xcodebuild -project App/iPadOS/NekoPond.xcodeproj -scheme NekoPond -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M4)' -derivedDataPath /tmp/NekoPondDerivedData clean build
```

If the named simulator is unavailable:

```bash
xcrun simctl list devices available | grep -i ipad
```

Then choose the closest available iPad simulator and report the substitution.

## Simulator run requirements

For visual phases:

1. Build successfully.
2. Launch the app on an iPad simulator.
3. Use landscape orientation.
4. Verify full-screen pond coverage.
5. Interact with the pond if the phase affects touch, fish, HUD, Settings, or onboarding.
6. Capture screenshots or short video evidence.

## Screenshot requirements

### Water/atmosphere phases

- Full pond screenshot before touch.
- Tap/ripple screenshot if touch visuals remain visible.

### Koi phases

- Screenshot with visible active fish.
- If fish count is adjustable, verify low and high count manually when possible.
- For animation, capture short video or multiple screenshots.

### Environment phases

- Screenshot showing lotus/stones/grasses/petals.
- Confirm fish are not obscured.

### Settings phase

- Settings open in landscape.
- One changed control visible.
- Settings closed back to pond.

### HUD phase

- HUD visible.
- HUD hidden after timer.
- Settings reveal path.

### Onboarding phase

- First page.
- Safe placement page.
- Start pond result.

### Mood phase

- One screenshot per mood: dawn, day, rain, moonlight, winter.

## Frame/performance checks

During Phase 4A and any heavy visual phase:

- Observe simulator/device frame pacing.
- Look for hitches when Settings changes mood/fish count.
- Look for hitches on first touch/ripple.
- Look for hitches during scene resize/orientation.
- Ensure no texture loading occurs inside `update(_:)`.
- Ensure repeated touch does not create unbounded nodes.

Preferred tools if needed:

- Xcode Debug navigator FPS/memory.
- Instruments Time Profiler for persistent frame drops.
- Allocations if memory growth is suspected.

## Memory checks

Known memory-sensitive assets:

- Pond backgrounds are 2732×2048.
- Full-screen water overlays can be large.
- Koi atlases may be multiple large PNGs.

Checks:

- Do not load all mood backgrounds unless mood switching requires it.
- Cache textures and reuse.
- Avoid repeated atlas cropping/allocation.
- Clean ripple nodes after fade.
- Keep particle count modest.

## Rapid multi-touch checks

For Phase 1G and Phase 3C:

- Tap with multiple fingers/pointer events rapidly.
- Verify ripples remain gentle.
- Verify app does not freeze or leak obvious nodes.
- Verify fish do not panic or jitter.
- Verify Settings/HUD is not accidentally triggered by normal cat-play touches, depending final recall design.

## Orientation checks

Product target:

- iPad landscape full-screen experience.

Checks:

- Landscape left and landscape right if supported.
- No black bars.
- Background aspect-fill remains correct.
- Settings panels fit and are not clipped.
- HUD corner controls remain reachable.
- Touch coordinate mapping remains correct after orientation/size change.

## Info.plist orientation warning plan

Known requirement:

- Create a plan for orientation warnings.

Classification:

- Release blocker if app declares unsupported/mismatched orientations causing launch, rotation, App Store, or UX issues.
- Acceptable only if simulator warning is known benign and app behavior is correct.

Resolution phase:

- Phase 4B.

Possible affected files:

- `App/iPadOS/NekoPond.xcodeproj/project.pbxproj`
- generated Info.plist build settings
- app scene configuration if present

Do not modify orientation declarations during visual phases.

## State update warning plan

Potential issue:

- SwiftUI warnings about publishing state during view updates can occur if scene callbacks mutate state at unsafe times.

Classification:

- Release blocker if reproducible and tied to Settings/HUD/onboarding state updates.
- Must be fixed before final QA.

Resolution approach:

- Ensure UI state changes occur on main actor and not synchronously during view update cycles.
- Use minimal deferral only if needed and justified.
- Do not add broad compatibility shims.

## UIDevice.orientation warning plan

Potential issue:

- If orientation APIs are used later, `UIDevice.orientation` may produce warnings or unreliable state.

Classification:

- Release blocker if code depends on unreliable orientation for layout or scene size.
- Avoid using `UIDevice.orientation` for layout; prefer SwiftUI size, UIKit view bounds, or scene size.

Current status:

- No confirmed active use from inspected files in this task.

## Accessibility simulator duplicate warning classification

Potential issue:

- Simulator accessibility warnings can appear unrelated to app logic.

Classification:

- Acceptable simulator noise if:
  - app builds and launches
  - UI remains accessible enough for human controls
  - warning is known simulator/system duplicate and not tied to app controls
- Release blocker if:
  - Settings buttons/controls are unreachable
  - VoiceOver/accessibility tree is broken by duplicate identifiers
  - warning points to app-defined duplicate controls causing automation failure

## Release blockers vs acceptable simulator noise

### Release blockers

- Build failure.
- Launch crash.
- Missing frozen assets in runtime.
- Black screen or missing pond background.
- Fish invisible or too small to track.
- Touch interaction crash or runaway node growth.
- Settings inaccessible.
- Onboarding prevents entering pond.
- Persistent game-like UI during cat play.
- Orientation behavior breaks iPad landscape.
- Reproducible SwiftUI state update warning tied to app behavior.
- Memory/performance issue that makes interaction laggy.

### Acceptable simulator noise, if documented

- Simulator-only accessibility duplicate logs not tied to app controls.
- Benign system framework logs with no app behavior impact.
- Debug-only asset diagnostics during active reconstruction, if assets load and logs are temporary.

## Final QA report format

For every completed implementation phase, report:

- Files changed.
- Build command and result.
- Simulator/device used.
- Screenshot/video paths or reason capture was not possible.
- Warnings observed and classification.
- Acceptance criteria pass/fail.
- Rollback notes.
- Stop conditions encountered, if any.
