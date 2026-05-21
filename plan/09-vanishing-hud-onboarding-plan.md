# 09 — Vanishing HUD and onboarding plan

This document defines HUD and onboarding reconstruction.

## Product rule

During cat play, the pond should be the experience. Human UI must vanish or become nearly invisible. No score, coins, hearts, levels, persistent buttons, or game-like prompts.

## Current confirmed state

- `ContentView` shows `CatPlayHUD` after onboarding.
- `CatPlayHUD` contains a subtle `NEKO POND` label and gear button.
- `recallHUD()` shows HUD and starts a hide timer using `settings.hideUITimer`.
- `OnboardingView` has four pages and uses `@AppStorage("nekoPond.hasOnboarded")`.

## Launch state

Target:

- If first run: show onboarding over subdued pond or dark glass backdrop.
- If already onboarded: enter pond mode with HUD briefly visible, then fade.
- Scene should be active when app is active.

## Fade state

Target:

- HUD fades out after timer.
- Fade duration should be calm, around 0.35–0.75 seconds.
- Settings overlay fades/scales subtly.
- Onboarding transition to pond is smooth and quiet.

## Cat play state

Target:

- No persistent visible UI.
- Pond responds to touch.
- Koi remain central focus.
- Human recall affordance may be invisible or extremely subtle in a corner.

## Human recall state

Target:

- Human can reveal HUD without needing visible game controls.
- Current `onTapWater` recalls HUD on any water tap; this may be too eager for cat play and should be revisited in Phase 2B/3C.
- Preferred future behavior: corner tap or sustained corner touch reveals controls; ordinary pond taps should prioritize cat interaction.

## Corner tap behavior

Target:

- Reserve one top corner for human recall/settings.
- Hit target should be reliable for humans but visually minimal.
- Avoid blocking central cat play area.
- Consider requiring double tap/long press if cats accidentally trigger Settings.

Phase:

- Phase 2B for HUD recall behavior.

## Settings reveal behavior

Target:

- HUD visible → Settings button opens Settings.
- Settings open → HUD hide timer paused or ignored.
- Settings close → return to pond and restart hide timer.
- Settings should not open accidentally from normal cat paw touches.

## Hide UI timer

Current:

- `PondSettings.hideUITimer` defaults to 8 seconds and ranges 4–14 in Settings.

Target:

- Keep adjustable timer.
- During Settings and onboarding, do not hide the active human screen.
- During cat play, hide HUD automatically.
- Any human recall restarts timer.

## First-run onboarding

Target pages:

1. Welcome to NEKO POND — a quiet koi pond for your cat.
2. Place iPad safely — flat stable surface, secure iPad, supervise as appropriate.
3. Let your cat explore — gentle touches create ripples; koi respond calmly.
4. Start Pond — interface will vanish for cat play.

Tone:

- Calm, premium, minimal.
- Safety-forward.
- No game tutorial language.

## Safe iPad placement screen

Must include:

- Use a flat, stable surface.
- Keep the iPad secure.
- Avoid edges where it can fall.
- Supervise your cat.
- Clean screen/paws if needed may be considered later, but keep copy concise.

## Start pond transition

Target:

- Start button sets onboarded state.
- Onboarding fades out.
- Pond becomes fully visible.
- HUD appears briefly or remains hidden depending final UX decision.
- Koi/water continue smoothly.

## No persistent UI during cat play

Acceptance:

- After hide timer, screenshot of cat play should show pond only.
- Any recall affordance should be nearly invisible and not visually distracting.
- No text label should remain centered or high-contrast.

## Acceptance criteria

- First-run user understands safe iPad placement.
- Starting pond is obvious.
- Settings remains discoverable to humans.
- Cat play mode is visually clean.
- HUD does not block pond touches.
- UI language is premium and calm.

## Rollback strategy

- Phase 2B rollback: restore previous `CatPlayHUD` and `recallHUD` logic.
- Phase 2C rollback: restore previous `OnboardingView`.
- Keep `@AppStorage("nekoPond.hasOnboarded")` key unless a future migration is explicitly required.

## Stop conditions

- User cannot reach Settings.
- User cannot start pond from onboarding.
- HUD never hides.
- Settings opens accidentally from ordinary pond taps.
- Build fails.
