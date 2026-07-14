# Animation & Motion

## Decision Gate — Should This Animate At All?

Before choosing duration or easing, answer this first:

| Trigger Frequency | Decision |
|-------------------|----------|
| 100+/day (keyboard shortcuts, command palette, toggle) | No animation. Ever. |
| Tens of times/day (hover, list nav, tab switch) | Opacity-only or remove entirely |
| Occasional (modals, drawers, toasts) | Standard animation |
| Rare / first-time (onboarding, celebrations) | Full delight |

Hard rules: keyboard-initiated actions MUST NEVER animate. Every motion must serve a UX purpose (guide attention, show state change, reveal relationship) — never decorate. If the action triggers more than tens of times per day, skip the rest of this file.

## Animation Library Selection

Pick the simplest tool that handles the job. Never mix libraries for the same concern.

| Need | Use | Why |
|------|-----|-----|
| Hover, focus, toggle, color change | **CSS transitions** | GPU-composited, interruptible, zero JS. Default for all interactive states. |
| Staged sequences (page load, hero entrance) | **CSS @keyframes** | No JS dependency, runs off main thread under load. |
| Enter/exit, layout animation, shared element | **motion/react** (formerly framer-motion) | `AnimatePresence` handles exit; `layoutId` handles shared element morphs. |
| Scroll-driven reveals, parallax | **CSS `animation-timeline: scroll()`** or **IntersectionObserver** | CSS-only where supported; IO as fallback. Never `scrollTop`/`scrollY` listeners. |
| Complex timeline sequences, pinned scroll sections | **GSAP + ScrollTrigger** | When CSS scroll timelines can't express the choreography. Pin, scrub, and sequence. |
| Drag, dismiss, gesture with momentum | **motion/react springs** | Springs maintain velocity on interrupt; CSS transitions restart from zero. |
| Programmatic one-shot (JS-controlled timing) | **Web Animations API (WAAPI)** | JS control + CSS performance. No library needed. |

**Rules:**
- CSS first. Only reach for JS animation when CSS can't express it (exit animations, gesture physics, complex timelines).
- CSS transitions for interactive state changes — they interrupt cleanly mid-animation. Keyframes only for staged sequences that run once. Rapidly-triggered elements (toasts, toggles) MUST use transitions, not keyframes.
- Check `package.json` before importing any animation library. If missing, output the install command before the code.
- NEVER mix motion/react and GSAP in the same component. Pick one per interaction surface.
- For single-file HTML pages without a build system: CSS transitions + keyframes + WAAPI only. No npm dependencies.

## Duration

```
100-150ms: Instant feedback (button press, toggle, tooltip)
200-300ms: State changes (menu open, hover, accordion)
300-500ms: Layout changes (modal, drawer, panel)
500-800ms: Entrance animations (page load, hero)
```

- Any user-initiated animation ≤300ms total. Interaction feedback <200ms.
- Similar UI elements use identical timing values — never 200ms and 250ms for two dropdowns.
- Open durations longer than close durations. Exits ≈75% of entrance duration. Asymmetric timing: slow where the user is deciding, fast where the system responds.

| Component | Open | Close |
|-----------|------|-------|
| Tooltip | 125ms | 100ms |
| Dropdown | 250ms | 150ms |
| Modal | 250ms | 150ms |
| Panel/drawer | 400ms | 350ms |
| Toast | 400ms | 200ms |

## Easing (use these, not CSS defaults)

```css
--ease-out-quart: cubic-bezier(0.25, 1, 0.5, 1);    /* Default — smooth, refined */
--ease-out-quint: cubic-bezier(0.22, 1, 0.36, 1);   /* Snappier — dominant curve for most UI */
--ease-out-expo:  cubic-bezier(0.16, 1, 0.3, 1);    /* Confident, decisive */
--ease-drawer:    cubic-bezier(0.32, 0.72, 0, 1);   /* iOS-like drawer feel */
```

| Context | Easing |
|---------|--------|
| Entrances | `ease-out` (arrives fast, settles) — NEVER `ease-in`, it delays initial movement and feels sluggish |
| Exits | `ease-in` (builds momentum before departure) |
| On-screen moves | `ease-in-out` (custom: `cubic-bezier(0.77, 0, 0.175, 1)`) |
| Hover/color | `ease` |
| Constant motion (progress bar, marquee) | `linear` |

NEVER bounce or elastic easing on standard UI — acceptable only for gesture physics (drag momentum, decorative mouse tracking).

## Springs & Gestures

For gesture interactions (drag, dismiss, mouse tracking) where the user may interrupt mid-animation, use springs — they maintain velocity when interrupted; CSS transitions restart from zero.

```js
// Apple-style (recommended — easier to reason about):
{ type: "spring", duration: 0.5, bounce: 0.2 }

// Standard UI state changes — no bounce:
{ type: "spring", duration: 0.3, bounce: 0 }
```

Bounce 0.1–0.3 for gestures/decorative only; `bounce: 0` for all standard UI. NEVER bounce on buttons, tabs, menus, or form controls. Safe default config: stiffness 100, damping 20.

**Gesture robustness:**
- Capture the initiating pointer (`setPointerCapture`) and ignore secondary touch points during a drag.
- Swipe-to-dismiss accepts distance OR velocity — a quick flick dismisses without a long drag.
- Apply progressively stronger damping when dragging past a boundary (rubber-banding), never a hard stop.
- Verify complex motion frame-by-frame in DevTools slow-motion; test gestures on physical touch hardware.

## Mechanics

- Enter from `scale(0.95)` or higher + `opacity: 0`. NEVER `scale(0)` — it looks broken.
- Button press: `active:scale-[0.97]` with 100ms ease-out. Press slow and deliberate, release always snappy (~200ms ease-out).
- Icon swaps: animate `opacity` (0→1), `scale` (0.25→1), and `blur` (4px→0) instead of toggling visibility. Without a motion library, keep both icons mounted (one absolute) and cross-fade with CSS.
- Popovers/tooltips scale from the trigger: `transform-origin` from trigger position (`var(--radix-popover-content-transform-origin)`). Modals are the exception — always center origin.
- Tooltips: first hover in a group animates normally; subsequent adjacent tooltips open instantly (`transition-duration: 0ms`) while the user is still in the group.
- Context menus: exit animation only, no entrance — users expect instant response at cursor.
- Stagger: 30–50ms per item, max 5–8 items, decorative only — never block interaction during it.
- Hide by own size with percentage translates (`translateY(100%)`), not fixed pixel offsets.
- Gate hover effects: `@media (hover: hover) and (pointer: fine)` to avoid sticky hover on touch devices.
- Prefer `@starting-style` for CSS-only entry transitions where supported; fall back to a mounted-state/data-attribute pattern.
- Skip animation on first render: `AnimatePresence initial={false}` for default-state icon swaps, toggles, tabs, segmented controls. Exempt intentional first-load entrances.
- Reveal animations must enhance an already-visible default. NEVER gate content visibility on a class-triggered transition — transitions pause in hidden tabs and headless renderers, so the reveal never fires and the section ships blank.
- Pause toast auto-dismiss timers while the document/tab is hidden. Pause looping animations when off-screen (IntersectionObserver).
- `clip-path` earns its place for geometric relationships: hold-to-confirm progress (fill slowly while pressed, reset fast on release), comparison sliders, image reveals.
- NEVER `transition: all` — always specify exact properties (`transition-colors`, `transition-transform`, `transition-opacity`).

## Transition Architecture

- **Shared elements morph between states.** When a card expands to a detail view, morph the card — don't unmount/remount. Use `layoutId` (motion/react) or the View Transitions API.
- **Directional consistency:** forward navigation → content enters from right; back → enters from left. Tab switching: indicator and content slide in the tab's direction.
- **Persistent elements don't re-animate.** A header/nav that survives a route change never replays its entrance.
- **Enter/exit pattern:** stagger semantic chunks ~100ms apart. Exits softer than enters — small fixed `translateY`, not full height.
- **Data-dense/professional apps default to NO animation.** Only: state changes that need attention, overlay enter/exit, loading→loaded.

## Scroll Entry Pattern

| Property | Value |
|----------|-------|
| Start state | `translateY(12–16px)` + `opacity: 0` (optional `blur(0–4px)`) |
| End state | `translateY(0)` + `opacity: 1` |
| Duration | 600–800ms with expo ease |
| Trigger | IntersectionObserver with `{ once: true, rootMargin: "-100px" }` |

Prefer CSS `animation-timeline: view()` for scroll-driven effects; never drive animation from `scrollTop`/`scrollY` listeners.

## Reduced Motion

`prefers-reduced-motion` means fewer and gentler, NOT zero — keep opacity/color fades that aid comprehension, remove transform, position, and clip-path movement. The nuclear reset is the floor, not the goal:

```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
```

For crafted design systems, prefer per-component handling that keeps opacity/color transitions:

```jsx
const shouldReduceMotion = useReducedMotion();
const closedX = shouldReduceMotion ? 0 : '-100%';
```

## Performance

Rendering cost, cheapest first — pick the technique before the effect:

- **Composite (free):** `transform`, `opacity` — the only properties to animate by default. For height: `grid-template-rows: 0fr → 1fr`. For layout-like effects on large surfaces: FLIP.
- **Paint (small/isolated surfaces only):** color, borders, filters. Short one-time blur ≤8px is acceptable for icon swaps and crossfade masking; NEVER animate `blur()` continuously or on large surfaces.
- **Layout (never animate):** `width`, `height`, `top`, `left`, `margin`, `padding`, `grid-template-columns`.

Also:
- motion/react shorthand props (`x`, `y`, `scale`) run on the main thread — use the full `transform` string for GPU compositing under load.
- `backdrop-blur` ONLY on fixed/sticky elements — never on scrolling containers, never combined with transitions/animations.
- `will-change: transform` only when first-frame stutter is observed; remove after. Only for `transform`/`opacity`/`filter` — never `all`, never permanent.
- NEVER animate inherited CSS custom properties or update parent CSS variables per frame to drive children — triggers style recalc on all descendants. Apply `transform` directly on the target.
