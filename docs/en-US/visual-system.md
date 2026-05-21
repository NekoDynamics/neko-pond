# Visual System Specification

## Visual Philosophy

Neko Pond should look and feel like calm ambient computing for cats. The iPad becomes a quiet water surface with living prey, not a game board. The visual system must support feline attention, owner trust, and high-performance native rendering.

### Principles

- Ambient computing: the app should disappear into the environment during play.
- Calm interaction: visual feedback should be immediate but not loud.
- Natural motion: movement must imply living intent, inertia, hesitation, and escape.
- Cinematic realism: use lighting, contrast, and depth to create believability without photorealistic complexity.
- Minimal interface: no HUD, scores, coins, badges, popups, or arcade overlays during cat sessions.

## Forbidden Visual Styles

The following styles are forbidden for production play sessions:

- cartoon UI;
- arcade effects;
- bright saturation overload;
- cheap mobile game aesthetics;
- toy-like buttons over the pond;
- confetti, stars, coins, or reward bursts;
- aggressive glow effects;
- noisy animated backgrounds;
- hard flashing lights;
- repetitive obvious path animations;
- UI chrome visible during cat play.

A premium Neko Pond scene should be readable in a dim room, beautiful in a social video, and calm enough to leave on under supervision.

## Motion Language

### Movement Curves

Fish movement must be curved, weighted, and stateful. Avoid constant-speed lines. Preferred motion sources:

- steering vectors;
- heading smoothing;
- acceleration limits;
- deceleration on approach;
- slight path noise;
- local avoidance;
- state-dependent speed envelopes.

Motion should be readable as intent, not random drift.

### Fish Acceleration Rules

- Acceleration must be bounded by fish personality and state.
- Cruise acceleration should be gentle.
- Escape acceleration may be sharp but must not teleport.
- Recovery should decelerate smoothly after escape.
- Direction changes should rotate body heading before or during velocity change.
- Fish should not instantly reverse direction unless reacting to an immediate nearby threat.

### Idle Motion Rules

Idle fish should:

- drift slowly;
- make small heading corrections;
- pause with micro-movement;
- occasionally flick or shift position;
- avoid perfect stillness for long periods;
- maintain visual readability.

Idle does not mean inactive. It means low-intensity alive behavior.

### Escape Motion Rules

Escape behavior should:

- trigger quickly from nearby touch disturbance;
- accelerate away from threat center;
- curve around edges instead of bouncing;
- produce subtle wake or bubble effects;
- reduce speed after safe distance;
- transition to recover before wander.

Escape must feel like prey agency. It must not look like an object pushed by physics alone.

### Ripple Timing

- Touch-down ripple appears immediately.
- Touch-move ripples are throttled and merged.
- Fish wake ripples are smaller and lower opacity than touch ripples.
- Ripple expansion should ease outward naturally.
- Ripple fade should complete before visual clutter accumulates.
- Ripple lifetime must be capped by performance budget.

### Particle Behavior

Particles should support water depth and interaction:

- ambient motes drift slowly;
- bubbles rise or drift with subtle variation;
- fish wakes trail briefly;
- touch particles appear only on meaningful contact;
- particles fade smoothly and never dominate fish readability.

### Inertia Philosophy

Every moving visual element should appear to have mass or water resistance. Even small particles should not jitter randomly. Fish are living actors moving through water. Ripples are waves losing energy. Bubbles are buoyant and slow. Inertia is the foundation of realism.

## Lighting Rules

### Soft Highlights

- Use soft highlight gradients rather than hard shine.
- Highlights should guide attention toward fish and touch areas.
- Highlight movement must be slow and ambient.
- Avoid high-frequency shimmer that creates visual noise.

### Underwater Diffusion

- Background should suggest depth through diffusion and gradients.
- Distant particles should be lower contrast.
- Fish shadows or depth glows may be used sparingly.
- Water should not look like flat solid color unless intentionally minimal for performance testing.

### Contrast Control

- Fish must remain readable against water.
- Contrast should be highest on active prey and touch feedback.
- Background contrast should remain low.
- Edge regions may be darker to support edge avoidance illusion.

### Glow Usage Limits

- Glow may be used for subtle water highlights or bioluminescent themes.
- Glow must not create arcade energy effects.
- Glow radius and opacity must be capped.
- Multiple glowing fish require stricter particle and contrast budgets.

## Color System

### Water Palette

Recommended base palette:

- deep pond blue: near-black blue-green;
- midnight teal: dark cyan-green;
- soft slate: desaturated blue-gray;
- shallow highlight: low-alpha pale cyan;
- edge shadow: deep navy or green-black.

Water should be dark enough to make fish readable and calm enough for long sessions.

### Fish Palette

Fish colors should be high-readability but restrained:

- warm white;
- pale gold;
- muted orange;
- soft silver;
- koi red used sparingly;
- dark silhouette variants for bright water themes.

Avoid neon colors in MVP unless a later theme intentionally explores them with strict limits.

### Accent Usage

Accent color is reserved for:

- active touch feedback;
- subtle fish detail;
- rare visual novelty;
- owner UI outside play.

Accent colors must not become constant screen noise.

### Contrast Ratios

Cat visual perception differs from human UI accessibility rules, but owner UI still needs accessible contrast. For play visuals:

- fish must be visibly separable from water during motion;
- touch ripples must be visible without overpowering fish;
- ambient particles must be visible only when watched closely;
- background must not compete with prey.

### Dark Environment Optimization

Many sessions will happen indoors at night. The scene should:

- avoid full-screen bright flashes;
- keep water luminance controlled;
- provide readable fish silhouettes;
- avoid eye-straining saturation;
- preserve video capture quality in low light.

## UI Rules

### UI Visibility Philosophy

During active cat play, UI should be absent. The cat should see a pond, not controls. Owner controls belong before or after sessions.

### Overlay Minimization

Allowed overlays during play:

- debug overlays in development builds only;
- owner-only exit affordance if hidden or gesture-based;
- system-required indicators outside app control.

Forbidden overlays during play:

- score;
- timer;
- achievements;
- banners;
- ads;
- subscription prompts;
- instructional text;
- modal dialogs.

### Immersive Interaction

Touch feedback must appear at the touch location and align with water behavior. The app should not show button states, tap rings that look like UI, or generic gesture indicators.

### Touch Feedback Standards

- Every touch-down produces immediate visual feedback unless intentionally filtered as noise.
- Feedback density must be capped under multi-touch.
- Feedback should decay naturally.
- Fish response should be spatially consistent with touch location.

## Particle Rules

### Ripple Density

- Active ripples must be capped globally.
- Nearby touch samples may merge into one ripple.
- Ripple opacity should drop when many are active.
- Ripple radius must remain appropriate to touch intensity and screen size.

### Bubble Behavior

- Ambient bubbles should be rare and subtle.
- Fish escape can trigger tiny bubbles with cooldown.
- Bubble direction should imply water buoyancy or wake, not random spray.
- Bubble lifetime must be short enough to avoid clutter.

### Spawn Frequency

Particle spawn must be driven by:

- touch events;
- fish movement intensity;
- ambient timing;
- device performance budget.

Do not spawn particles every frame by default. Use event-based emission and low-frequency ambient systems.

### Performance Constraints

- Particle systems must support budget scaling by device profile.
- Older devices should reduce ambient particles first.
- Touch ripple feedback must survive budget reductions.
- Particles must not allocate large objects during active play.

## Animation Rules

### Frame Pacing

Animations must remain smooth under 60 fps and improve under 120 fps. Do not assume a fixed frame count. Use delta time and time-normalized interpolation.

### Easing

Preferred easing:

- ease-out for ripple expansion;
- smoothstep for ambient light changes;
- critically damped smoothing for heading;
- acceleration-limited movement for fish.

Avoid bouncy UI easing in prey motion.

### Randomness

Randomness must be bounded:

- use ranges defined in config;
- avoid per-frame independent jitter;
- randomize decisions, not every pixel;
- use weighted choices for behavior states;
- preserve continuity across frames.

### Animation Blending

Fish states must blend visually:

- pause to wander: slow acceleration;
- wander to alert: heading tightening and slight speed increase;
- alert to flee: quick acceleration;
- flee to recover: deceleration and wider turns;
- recover to wander: return to cruise envelope.

Hard visual snaps are allowed only for hidden spawn/despawn transitions.

## Audio Rules

### Ambient Layering

Ambient audio should use a quiet base layer:

- soft water tone;
- gentle room-safe volume;
- subtle loop variation;
- no obvious short repeat cycle;
- no melody that dominates the room.

### Interaction Sounds

Interaction sounds should be short and quiet:

- soft ripple;
- tiny bubble;
- subtle water disturbance;
- slight pitch and volume variation;
- cooldown to prevent stacking.

### Dynamic Silence

Silence is a valid state. The app should not fill every moment with sound. Calm scenes can become more premium when they leave space.

### No Aggressive Effects

Forbidden audio:

- sharp reward sounds;
- coin sounds;
- alarms;
- loud splashes;
- repetitive arcade loops;
- sudden high-frequency effects;
- sounds triggered unbounded by multi-touch storms.
