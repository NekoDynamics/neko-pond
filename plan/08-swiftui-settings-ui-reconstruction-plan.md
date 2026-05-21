# 08 — SwiftUI Settings UI reconstruction plan

This document defines Phase 2A Settings reconstruction.

## Current confirmed Settings state

- `SettingsScreen` is inside `App/iPadOS/NekoPond/ContentView.swift`.
- It uses a two-column layout with sidebar and content panel.
- It already exposes mood, fish count, sensitivity, soundscape, ripple strength, night brightness, cat safe mode, hide UI timer, and reset.
- User-provided state says Settings UI is prototype-level and must later be reconstructed.

## Target visual style from Sheet 06

Settings should feel like a premium human-only control panel over a calm pond:

- Dark translucent glass panels.
- Deep teal/black water base.
- Warm gold accent strokes.
- Muted jade selected states.
- Koi-white text.
- Generous iPad spacing.
- Mature typography, not playful/game-like.
- Human controls clearly separate from cat play.

## Scope rule

Phase 2A must reconstruct Settings UI only.

Allowed by default:

- `App/iPadOS/NekoPond/ContentView.swift`

Forbidden by default:

- `App/iPadOS/NekoPond/PondSpriteScene.swift`
- `App/iPadOS/NekoPond/PondAssetRegistry.swift`
- `App/iPadOS/NekoPond/PondTextureCache.swift`
- `App/iPadOS/NekoPond/PondSpriteModels.swift`
- `App/iPadOS/NekoPond/Fish*.swift`
- `App/iPadOS/NekoPond/PondScene.swift`
- `Assets/**`
- `Design/**`
- `docs/**`
- Xcode project

Do not touch SpriteKit rendering in this phase unless a binding/display bug makes Settings impossible to validate.

## Glass panel system

Target component behavior:

- Rounded rectangle, continuous corners.
- Dark teal/black fill with translucency.
- Thin warm-gold stroke at low opacity.
- Optional inner highlight at very low opacity.
- Soft shadow if it remains subtle.

Suggested tokens:

- Panel fill: dark teal/black around 0.62–0.78 opacity.
- Stroke: warm gold around 0.14–0.28 opacity.
- Corner radius: 18–26 for large panels, 12–16 for controls.

## Sidebar layout

Target:

- Fixed width around 260–320 points in landscape.
- Brand/header at top.
- Section list:
  - Pond
  - Fish
  - Interaction
  - Audio
  - Display
  - Safety
- Selected row uses muted jade fill and warm-gold accent.
- Rows are large enough for iPad touch.
- Bottom area can hold reset/about only if not cluttered.

Important:

- Sidebar navigation can remain visually static in Phase 2A if implementing section switching would broaden scope.
- If static, make clear the content panel contains core controls.

## Content panel layout

Target:

- Large glass content card.
- Header row with title and close button.
- Grouped sections rather than one long prototype list.
- Controls aligned in a predictable right column.
- Subtitles concise and low-opacity.
- Avoid dense macOS preference-pane feel.

Suggested groups:

1. Pond mood
2. Koi presence
3. Cat interaction
4. Atmosphere/audio
5. Safety and display

## Segmented controls

Used for:

- Mood
- Interaction sensitivity
- Soundscape

Target:

- Wide enough to read labels.
- Low-contrast selected state with jade/gold.
- Avoid bright default iOS tint if it clashes.

## Sliders

Used for:

- Ripple strength
- Night brightness

Target:

- Clear label and numeric/semantic value if space permits.
- Tinted with warm gold or jade.
- No tiny controls.

## Toggles

Used for:

- Cat safe mode
- Pause if exposed

Target:

- Human-readable label and safety explanation.
- Low visual intensity.

## Icon buttons

Used for:

- Close Settings.
- Potential reset/section actions.

Target:

- Circular or rounded glass button.
- Warm-gold icon.
- Minimum 44×44 hit target.
- Close button clearly accessible in top-right of Settings panel.

## Reset button

Target:

- Present but not visually alarming.
- Avoid bright destructive red unless platform role forces it; a warm outlined style may fit better.
- Label: `Reset Pond` or `Restore Calm Defaults`.
- Confirm dialog optional; do not add if it broadens scope.

## Typography

Target:

- Brand: small uppercase with wide tracking.
- Screen title: 28–36 pt, regular/light weight.
- Section headers: 15–18 pt, medium/regular.
- Row title: 17–20 pt.
- Subtitle: 12–15 pt, low opacity.
- Avoid bold playful/game typography.

## Colors

Use or refine existing `DesignToken` values:

- Deep teal
- Jade green
- Dark water black
- Koi white
- Warm gold
- Dark glass

Target:

- Consistent palette across Settings, HUD, onboarding.
- No neon colors.
- No high-saturation game accents.

## Spacing

Target:

- Outer padding: 32–48 pt on iPad landscape.
- Sidebar/content gap: 20–28 pt.
- Panel internal padding: 24–36 pt.
- Row vertical padding: 14–22 pt.
- Control width: 280–380 pt depending available space.

## Corner radius

Target:

- Large panels: 20–26 pt.
- Rows/selected states: 12–16 pt.
- Buttons: 12–22 pt or circular for icon buttons.

## Safe area

Target:

- Settings may ignore safe area backdrop, but content must not collide with corners/system gestures.
- In landscape, respect readable margins.
- Close button must be reachable.

## iPad landscape layout

Target:

- Optimized for 4:3 and modern iPad Pro landscape.
- No clipping at 1024-point height baseline.
- If vertical space is tight, use a scroll view inside content panel only.
- Avoid portrait-first layout.

## Runtime binding plan

Phase 2A:

- Preserve existing settings bindings.
- Do not add new runtime behavior unless necessary.

Phase 3A:

- Verify every Settings control affects runtime where expected.
- Add missing binding for mood backgrounds, rain overlay, fish count, ripple strength, sensitivity, cat-safe mode.

## Exact phase order

1. Phase 2A: reconstruct Settings UI only.
2. Phase 2B: reconstruct vanishing HUD.
3. Phase 2C: reconstruct onboarding.
4. Phase 3A: settings-to-runtime binding.

Do not combine these phases.

## Acceptance criteria

- Settings looks premium and blueprint-aligned.
- Controls remain functional.
- Layout is stable on iPad landscape simulator.
- Closing Settings returns to pond.
- No SpriteKit render changes occur in Phase 2A.
- No new game-like UI or monetization/game language appears.
